local resourceName = GetCurrentResourceName()
local settings = Config.VersionCheck or {}
local pagePrefix = 'https://versions.kojascripts.com/s/'
local startDelay = 10000
local debounceDelay = 15000
local refreshDelay = 6 * 60 * 60 * 1000
local maxResources = 40
local knownStatus = { current = true, outdated = true, critical = true, newer = true, unknown = true }

local versionReport = nil
local scheduleToken = 0
local sending = false
local queued = false
local lastSignature = nil

local function DebugLog(message)
    if Config.Debug then
        print(('^6[koja-lib]^0 versions: %s'):format(message))
    end
end

local function NormalizeVersion(value)
    if type(value) ~= 'string' then return nil end
    local major, minor, patch = value:match('(%d+)%.(%d+)%.(%d+)')
    if major then return ('%d.%d.%d'):format(tonumber(major), tonumber(minor), tonumber(patch)) end
    major, minor = value:match('(%d+)%.(%d+)')
    if major then return ('%d.%d.0'):format(tonumber(major), tonumber(minor)) end
    return nil
end

local function IsValidId(value)
    return type(value) == 'string' and #value == 12 and value:match('^[a-z2-9]+$') ~= nil
end

local function IsValidSecret(value)
    return type(value) == 'string' and #value == 48 and value:match('^[a-f0-9]+$') ~= nil
end

local function HasKojaAuthor(name)
    local author = GetResourceMetadata(name, 'author', 0)
    return type(author) == 'string' and author:lower():find('koja', 1, true) ~= nil
end

local function IsKojaResource(name)
    if GetResourceState(name) ~= 'started' then return false end
    if #name > 64 or not name:match('^[%w][%w_%-]+$') then return false end
    return HasKojaAuthor(name)
end

local function CollectResources()
    local list = {}
    for i = 0, GetNumResources() - 1 do
        local name = GetResourceByFindIndex(i)
        if name and IsKojaResource(name) then
            list[#list + 1] = { name = name, version = NormalizeVersion(GetResourceMetadata(name, 'version', 0)) }
        end
    end
    table.sort(list, function(a, b)
        if a.name == resourceName then return true end
        if b.name == resourceName then return false end
        return a.name < b.name
    end)
    while #list > maxResources do
        table.remove(list)
    end
    return list
end

local function PrintReport(report, count)
    local flagged = {}
    local signature = { report.url }
    for name, entry in pairs(report.resources) do
        signature[#signature + 1] = ('%s:%s:%s'):format(name, tostring(entry.current), entry.status)
        if entry.status == 'outdated' or entry.status == 'critical' then
            flagged[#flagged + 1] = entry
        end
    end
    table.sort(signature)
    local joined = table.concat(signature, '|')
    if joined == lastSignature then return end
    lastSignature = joined

    table.sort(flagged, function(a, b) return a.name < b.name end)
    print(('^5Koja Scripts^0 — %d resource%s checked'):format(count, count == 1 and '' or 's'))
    if #flagged == 0 then
        print('  ^2all up to date^0')
    else
        for _, entry in ipairs(flagged) do
            local color = entry.status == 'critical' and '^1' or '^3'
            print(('  %s%-8s^0 %s  %s → %s%s^0'):format(color, entry.status, entry.name, tostring(entry.current or '?'), color, tostring(entry.latest or '?')))
        end
    end
    print(('  Versions & changelogs: ^5%s^0'):format(report.url))
end

local function HandleResponse(status, body)
    if status == 422 then return DebugLog('no tracked resources') end
    if status == 429 then return DebugLog('rate limited') end
    if status ~= 200 or type(body) ~= 'string' then return DebugLog(('request failed (%s)'):format(tostring(status))) end

    local ok, data = pcall(json.decode, body)
    if not ok or type(data) ~= 'table' then return DebugLog('invalid response') end
    if not IsValidId(data.id) then return DebugLog('invalid id in response') end
    if type(data.url) ~= 'string' or data.url:sub(1, #pagePrefix) ~= pagePrefix then return DebugLog('invalid url in response') end

    if data.secret ~= nil then
        if not IsValidSecret(data.secret) then return DebugLog('invalid credentials in response') end
        SetResourceKvp('koja_versions_id', data.id)
        SetResourceKvp('koja_versions_secret', data.secret)
    end

    local entries = {}
    local count = 0
    for _, item in ipairs(type(data.resources) == 'table' and data.resources or {}) do
        if type(item) == 'table' and type(item.name) == 'string' then
            entries[item.name] = {
                name = item.name,
                current = item.current,
                latest = item.latest,
                status = knownStatus[item.status] and item.status or 'unknown',
                url = item.url,
                changelog = type(item.changelog) == 'table' and item.changelog or {},
                released = item.released,
                minimum = item.minimum,
            }
            count = count + 1
        end
    end

    versionReport = { id = data.id, url = data.url, resources = entries }
    PrintReport(versionReport, count)
    TriggerEvent('koja-lib:versions:ready', versionReport)
end

local ScheduleReport

local function SendReport()
    if sending then
        queued = true
        return
    end
    local resources = CollectResources()
    if #resources == 0 then return end

    local payload = { resources = resources }
    local storedId = GetResourceKvpString('koja_versions_id')
    local storedSecret = GetResourceKvpString('koja_versions_secret')
    if IsValidId(storedId) and IsValidSecret(storedSecret) then
        payload.id = storedId
        payload.secret = storedSecret
    end

    local baseUrl = type(settings.url) == 'string' and settings.url or 'https://versions.kojascripts.com'
    local endpoint = baseUrl:gsub('/+$', '') .. '/report'
    local headers = {
        ['Content-Type'] = 'application/json',
        ['User-Agent'] = ('koja-lib/%s'):format(NormalizeVersion(GetResourceMetadata(resourceName, 'version', 0)) or '0.0.0'),
    }

    sending = true
    PerformHttpRequest(endpoint, function(status, body)
        sending = false
        local ok, err = pcall(HandleResponse, status, body)
        if not ok then DebugLog(('response error: %s'):format(tostring(err))) end
        if queued then
            queued = false
            ScheduleReport(debounceDelay)
        end
    end, 'POST', json.encode(payload), headers)
end

ScheduleReport = function(delay)
    scheduleToken = scheduleToken + 1
    local token = scheduleToken
    SetTimeout(delay, function()
        if token == scheduleToken then SendReport() end
    end)
end

KOJA.Server.GetVersionReport = function()
    return versionReport
end

KOJA.Server.GetVersionStatus = function(name)
    if not versionReport or type(name) ~= 'string' then return nil end
    return versionReport.resources[name]
end

exports('GetVersionReport', KOJA.Server.GetVersionReport)
exports('GetVersionStatus', KOJA.Server.GetVersionStatus)

if settings.enabled == false then return end

AddEventHandler('onResourceStart', function(name)
    if name ~= resourceName and HasKojaAuthor(name) then
        ScheduleReport(debounceDelay)
    end
end)

CreateThread(function()
    ScheduleReport(startDelay)
    while true do
        Wait(refreshDelay)
        ScheduleReport(0)
    end
end)

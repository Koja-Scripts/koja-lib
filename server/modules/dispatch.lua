KOJA.Server.Dispatch = {}
KOJA.Server.Dispatch.cooldowns = {}

local CLIENT_SIDE = { ['ps-dispatch'] = true, ['qs-dispatch'] = true }

local function settings()
    return type(Config.Dispatch) == 'table' and Config.Dispatch or {}
end

local function text(value, max, fallback)
    if type(value) ~= 'string' or value == '' then return fallback end
    return value:sub(1, max)
end

local function toVector(value)
    if type(value) == 'vector3' or type(value) == 'vector4' then return vector3(value.x, value.y, value.z) end
    if type(value) == 'table' and tonumber(value.x) and tonumber(value.y) then
        return vector3(tonumber(value.x) + 0.0, tonumber(value.y) + 0.0, (tonumber(value.z) or 0.0) + 0.0)
    end
    return nil
end

local function jobsOf(data)
    local jobs = {}
    local source = type(data.jobs) == 'table' and data.jobs or (type(data.job) == 'string' and { data.job } or settings().defaultJobs or { 'police' })
    for _, job in ipairs(source) do
        if type(job) == 'string' and job ~= '' then jobs[#jobs + 1] = job:sub(1, 32) end
    end
    return jobs
end

KOJA.Server.Dispatch.Normalize = function(data)
    data = type(data) == 'table' and data or {}
    local src = tonumber(data.source)
    local coords = toVector(data.coords)
    if not coords and src and GetPlayerName(src) then coords = GetEntityCoords(GetPlayerPed(src)) end
    local blip = type(data.blip) == 'table' and data.blip or {}
    return {
        source = src,
        code = text(data.code, 16, '10-00'),
        title = text(data.title, 96, 'Dispatch'),
        message = text(data.message, 500, ''),
        street = text(data.street, 128, nil),
        coords = coords,
        jobs = jobsOf(data),
        priority = math.max(1, math.min(3, math.floor(tonumber(data.priority) or 2))),
        category = text(data.category, 32, nil),
        blip = {
            sprite = math.floor(tonumber(blip.sprite) or 161),
            color = math.floor(tonumber(blip.color) or 1),
            scale = tonumber(blip.scale) or 1.0,
            time = math.floor(tonumber(blip.time) or 60),
        },
    }
end

KOJA.Server.GetDispatchResource = function()
    return Misc.Utils.ResolveIntegration('dispatch')
end

local senders = {}

senders['koja-mdt'] = function(alert)
    return exports['koja-mdt']:CreateDispatch({
        source = alert.source, code = alert.code, title = alert.title, message = alert.message, street = alert.street,
        coords = alert.coords, jobs = alert.jobs, priority = alert.priority,
    }) ~= nil
end

senders['koja-dispatch'] = function(alert)
    return exports['koja-dispatch']:CreateCall({
        source = alert.source, coords = alert.coords, label = alert.title, message = alert.message,
        priority = alert.priority, category = alert.category,
    }) ~= nil
end

senders['cd_dispatch'] = function(alert)
    TriggerClientEvent('cd_dispatch:AddNotification', -1, {
        job_table = alert.jobs, coords = alert.coords, title = ('%s - %s'):format(alert.code, alert.title),
        message = alert.message, flash = 0, unique_id = ('koja-%d-%d'):format(os.time(), math.random(1000, 9999)), sound = 1,
        blip = { sprite = alert.blip.sprite, scale = alert.blip.scale, colour = alert.blip.color, flashes = false, text = alert.title, time = math.max(1, math.floor(alert.blip.time / 60)), radius = 0 },
    })
    return true
end

senders['core_dispatch'] = function(alert)
    for _, job in ipairs(alert.jobs) do
        exports['core_dispatch']:addCall(alert.code, alert.title, { { icon = 'fa-solid fa-circle-info', info = alert.message } },
            { alert.coords.x, alert.coords.y, alert.coords.z }, job, alert.blip.time * 1000, alert.blip.sprite, alert.blip.color)
    end
    return true
end

senders['rcore_dispatch'] = function(alert)
    local priorities = { 'high', 'medium', 'low' }
    TriggerEvent('rcore_dispatch:server:sendAlert', {
        code = alert.code, default_priority = priorities[alert.priority], coords = alert.coords, job = alert.jobs,
        text = alert.message ~= '' and alert.message or alert.title, type = 'alerts', blip_time = math.max(1, math.floor(alert.blip.time / 60)),
        blip = { sprite = alert.blip.sprite, colour = alert.blip.color, scale = alert.blip.scale, text = alert.title, flashes = false, radius = 0 },
    })
    return true
end

---@param data table # { source?, code, title, message, coords?, jobs = { 'police' }, priority = 1-3, street?, category?, blip = { sprite, color, scale, time } }
---@return boolean # Whether a dispatch system took the alert
KOJA.Server.SendDispatch = function(data)
    local alert = KOJA.Server.Dispatch.Normalize(data)
    if not alert.coords then return false end
    local name = KOJA.Server.GetDispatchResource()
    if name == 'none' then return false end

    if CLIENT_SIDE[name] then
        local target = alert.source
        if not target then
            local players = GetPlayers()
            target = players[1] and tonumber(players[1]) or nil
        end
        if not target then return false end
        TriggerClientEvent('koja:Client:SendDispatch', target, alert)
        return true
    end

    local sender = senders[name]
    if not sender then return false end
    local ok, result = pcall(sender, alert)
    if not ok and Config.Debug then print(('^1[koja-lib]^0 dispatch via %s failed: %s'):format(name, tostring(result))) end
    return ok and result == true
end

RegisterNetEvent('koja:Server:SendDispatch', function(data)
    local src = source
    local options = settings()
    if options.allowClient == false then return end
    local now = os.time()
    local last = KOJA.Server.Dispatch.cooldowns[src]
    if last and now - last < (tonumber(options.clientCooldown) or 10) then return end
    KOJA.Server.Dispatch.cooldowns[src] = now

    data = type(data) == 'table' and data or {}
    local alert = KOJA.Server.Dispatch.Normalize(data)
    local ped = GetEntityCoords(GetPlayerPed(src))
    if not alert.coords or #(alert.coords - ped) > (tonumber(options.clientMaxDistance) or 150.0) then alert.coords = ped end
    data.coords = alert.coords
    data.source = src

    local allowed = options.clientJobs
    if type(allowed) == 'table' then
        local filtered = {}
        for _, job in ipairs(alert.jobs) do
            for _, allowedJob in ipairs(allowed) do
                if job == allowedJob then filtered[#filtered + 1] = job end
            end
        end
        if #filtered == 0 then return end
        data.jobs = filtered
    end
    KOJA.Server.SendDispatch(data)
end)

AddEventHandler('playerDropped', function()
    KOJA.Server.Dispatch.cooldowns[source] = nil
end)

exports('SendDispatch', KOJA.Server.SendDispatch)
exports('GetDispatchResource', KOJA.Server.GetDispatchResource)

local CLIENT_SIDE = { ['ps-dispatch'] = true, ['qs-dispatch'] = true }

local function sendLocal(name, alert)
    local coords = alert.coords
    if name == 'ps-dispatch' then
        exports['ps-dispatch']:CustomAlert({
            coords = coords, message = alert.title, code = alert.code, description = alert.message, icon = 'fas fa-circle-info',
            radius = 0, sprite = alert.blip.sprite, color = alert.blip.color, scale = alert.blip.scale, length = math.max(1, math.floor(alert.blip.time / 60)),
            jobs = alert.jobs, priority = alert.priority,
        })
        return true
    elseif name == 'qs-dispatch' then
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = alert.jobs, callLocation = coords, callCode = { code = alert.code, snippet = alert.title }, message = alert.message,
            flashes = false, image = nil,
            blip = { sprite = alert.blip.sprite, scale = alert.blip.scale, colour = alert.blip.color, flashes = false, text = alert.title, time = alert.blip.time * 1000 },
        })
        return true
    end
    return false
end

KOJA.Client.GetDispatchResource = function()
    return Misc.Utils.ResolveIntegration('dispatch')
end

---@param data table # { code, title, message, coords?, jobs = { 'police' }, priority = 1-3, street?, category?, blip = { sprite, color, scale, time } }
---@return boolean
KOJA.Client.SendDispatch = function(data)
    data = type(data) == 'table' and data or {}
    local name = KOJA.Client.GetDispatchResource()
    if name == 'none' then return false end
    if not data.coords then data.coords = GetEntityCoords(PlayerPedId()) end
    if not data.street then
        local street = GetStreetNameAtCoord(data.coords.x, data.coords.y, data.coords.z)
        data.street = GetStreetNameFromHashKey(street)
    end
    if CLIENT_SIDE[name] then
        local blip = type(data.blip) == 'table' and data.blip or {}
        local alert = {
            code = tostring(data.code or '10-00'), title = tostring(data.title or 'Dispatch'), message = tostring(data.message or ''),
            coords = data.coords, jobs = type(data.jobs) == 'table' and data.jobs or { 'police' }, priority = tonumber(data.priority) or 2,
            blip = { sprite = tonumber(blip.sprite) or 161, color = tonumber(blip.color) or 1, scale = tonumber(blip.scale) or 1.0, time = tonumber(blip.time) or 60 },
        }
        local ok, result = pcall(sendLocal, name, alert)
        return ok and result == true
    end
    TriggerServerEvent('koja:Server:SendDispatch', data)
    return true
end

RegisterNetEvent('koja:Client:SendDispatch', function(alert)
    if type(alert) ~= 'table' then return end
    pcall(sendLocal, KOJA.Client.GetDispatchResource(), alert)
end)

exports('SendDispatch', KOJA.Client.SendDispatch)

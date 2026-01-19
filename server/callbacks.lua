KOJA.Callbacks = {}

---@param key string # Callback identifier
---@param func function # Callback function
KOJA.Server.RegisterServerCallback = function(key, func)
    KOJA.Callbacks[key] = func
end

---@param key string # Callback identifier
---@param payload any # Data payload
RegisterNetEvent("koja:Server:HandleCallback", function(key, payload)
    local src = source
    if KOJA.Callbacks[key] then
        KOJA.Callbacks[key](src, payload, function(cb)
            TriggerClientEvent("koja:Client:HandleCallback", src, key, cb)
        end)
    end
end)

---@param key string # Callback identifier
---@param source number # Player ID
---@param payload any # Data payload
---@param cb function # Callback function
KOJA.Server.TriggerCallback = function(key, source, payload, cb)
    if not cb then
        cb = function() end
    end
    if KOJA.Callbacks[key] then
        KOJA.Callbacks[key](source, payload, cb)
    end
end

local PendingClientCallbacks = PendingClientCallbacks or {}

---@param key string # Client callback identifier
---@param playerId number # Player ID
---@param payload any # Data payload (optional)
---@param cb function|nil # Server-side callback when client responds
KOJA.Server.TriggerClientCallback = function(key, playerId, payload, cb)
    if not cb then
        cb = function() end
    end

    local cbid = ("%s:%s:%s"):format(key, math.random(0, 100000), playerId)
    PendingClientCallbacks[cbid] = cb

    if payload == nil then
        TriggerClientEvent("koja:Client:HandleClientCallback", playerId, key, cbid)
    else
        TriggerClientEvent("koja:Client:HandleClientCallback", playerId, key, cbid, payload)
    end
end

RegisterNetEvent("koja:Server:HandleClientCallbackResponse", function(cbid, ...)
    local src = source
    local cb = PendingClientCallbacks and PendingClientCallbacks[cbid]

    if not cb then
        return
    end

    PendingClientCallbacks[cbid] = nil
    cb(...)
end)
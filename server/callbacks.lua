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
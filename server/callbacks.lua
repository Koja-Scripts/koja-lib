KOJA.Callbacks = {}

KOJA.Server.RegisterServerCallback = function(key, func)
    KOJA.Callbacks[key] = func
end

RegisterNetEvent("koja:Server:HandleCallback", function(key, payload)
    local src = source
    if KOJA.Callbacks[key] then
        KOJA.Callbacks[key](src, payload, function(cb)
            TriggerClientEvent("koja:Client:HandleCallback", src, key, cb)
        end)
    end
end)

KOJA.Server.TriggerCallback = function(key, source, payload, cb)
    if not cb then
        cb = function() end
    end
    if KOJA.Callbacks[key] then
        KOJA.Callbacks[key](source, payload, cb)
    end
end
KOJA = {}
KOJA.Framework = Misc.Utils.GetFramework()
KOJA.Misc = Misc.Utils
KOJA.Callbacks = {}
KOJA.Client = {}

KOJA.Client.TriggerServerCallback = function(key, payload, func)
    if not func then
        func = function() end
    end
    KOJA.Callbacks[key] = func
    TriggerServerEvent("koja:Server:HandleCallback", key, payload)
end

RegisterNetEvent("koja:Client:HandleCallback", function(key, data)
    if KOJA.Callbacks[key] then
        KOJA.Callbacks[key](data)
        KOJA.Callbacks[key] = nil
    end
end)

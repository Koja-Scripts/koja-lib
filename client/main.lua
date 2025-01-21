Koja = {}
Koja.Framework = Misc.Utils.GetFramework()
Koja.Misc = Misc.Utils
Koja.Callbacks = {}
Koja.Client = {}

Koja.Client.TriggerServerCallback = function(key, payload, func)
    if not func then
        func = function() end
    end
    Koja.Callbacks[key] = func
    TriggerServerEvent("koja:Server:HandleCallback", key, payload)
end

RegisterNetEvent("koja:Client:HandleCallback", function(key, data)
    if Koja.Callbacks[key] then
        Koja.Callbacks[key](data)
        Koja.Callbacks[key] = nil
    end
end)

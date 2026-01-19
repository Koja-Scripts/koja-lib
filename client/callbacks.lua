KOJA.Callbacks = {}
KOJA.ClientCallbacks = {}

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

---@param key string # Callback identifier on client
---@param func function # Client callback function
KOJA.Client.RegisterClientCallback = function(key, func)
    KOJA.ClientCallbacks[key] = func
end

RegisterNetEvent("koja:Client:HandleClientCallback", function(key, cbid, ...)
    local func = KOJA.ClientCallbacks[key]

    if not func then
        TriggerServerEvent("koja:Server:HandleClientCallbackResponse", cbid, 'cb_invalid')
        return
    end

    local ok, result, r2, r3, r4, r5 = pcall(func, ...)

    if ok then
        TriggerServerEvent("koja:Server:HandleClientCallbackResponse", cbid, result, r2, r3, r4, r5)
    else
        TriggerServerEvent("koja:Server:HandleClientCallbackResponse", cbid, false, result)
    end
end)
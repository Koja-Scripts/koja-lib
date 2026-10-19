local pendingAwait = {}
local requestCounter = 0

---Blocking server callback. Request-id based so any number of calls can be in flight at the same time.
---Must be called from a thread (CreateThread / event handler).
---@param key string # Callback identifier registered with KOJA.Server.RegisterServerCallback
---@param payload any # Data payload
---@param timeoutMs number|nil # Timeout in ms (default 15000)
---@return any # Callback result, nil on timeout
KOJA.Client.AwaitServerCallback = function(key, payload, timeoutMs)
    requestCounter = requestCounter + 1
    local reqId = ('%s:%s:%s'):format(GetPlayerServerId(PlayerId()), requestCounter, GetGameTimer())

    local p = promise.new()
    pendingAwait[reqId] = p

    SetTimeout(tonumber(timeoutMs) or 15000, function()
        if pendingAwait[reqId] then
            pendingAwait[reqId] = nil
            p:resolve(nil)
        end
    end)

    TriggerServerEvent("koja:Server:HandleAwaitCallback", reqId, key, payload)

    return Citizen.Await(p)
end

RegisterNetEvent("koja:Client:HandleAwaitCallback", function(reqId, result)
    local p = pendingAwait[reqId]
    if not p then return end
    pendingAwait[reqId] = nil
    p:resolve(result)
end)

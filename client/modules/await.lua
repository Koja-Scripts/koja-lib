local pendingAwait = {}
local requestCounter = 0

KOJA.Client.AwaitServerCallback = function(key, payload, timeoutMs)
    requestCounter = requestCounter + 1
    local reqId = ('%s:%s:%s'):format(GetPlayerServerId(PlayerId()), requestCounter, GetGameTimer())
    local timeout = tonumber(timeoutMs) or 15000
    local p = promise.new()
    pendingAwait[reqId] = { promise = p, key = key }

    SetTimeout(timeout, function()
        if pendingAwait[reqId] then
            pendingAwait[reqId] = nil
            local failure = {
                code = 'callback_timeout', callback = key, requestId = reqId,
                message = ('No server response after %d ms. Check that the server has the same koja-lib version and the callback resource started successfully.'):format(timeout),
            }
            print(('[koja-lib][Callback][client] %s key=%s request=%s timeout=%dms lib=%s'):format(
                failure.code, tostring(key), reqId, timeout, GetResourceMetadata('koja-lib', 'version', 0) or 'unknown'))
            p:resolve({ failure = failure })
        end
    end)

    TriggerServerEvent('koja:Server:HandleAwaitCallback', reqId, key, payload)
    local response = Citizen.Await(p)
    return response.result, response.failure
end

RegisterNetEvent('koja:Client:HandleAwaitCallback', function(reqId, result, failure)
    local entry = pendingAwait[reqId]
    if not entry then return end
    pendingAwait[reqId] = nil
    entry.promise:resolve({ result = result, failure = failure })
end)

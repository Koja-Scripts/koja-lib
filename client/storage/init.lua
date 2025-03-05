storageData = {}
storageEvents = {}

storage = setmetatable({
    game = GetGameName(),
    resource = GetCurrentResourceName()
}, {
    __index = function(self, key)
        storageEvents[key] = {}

        AddEventHandler(('koja-lib:update:%s'):format(key), function(value)
            local oldValue = self[key]
            TriggerEvent("koja-lib:callback_triggered", key, value, oldValue)
            self[key] = value
        end)

        return rawset(self, key, storageData[key] or false)[key]
    end,

    __call = function(self, key, computeFunc, timeout)
        local value = rawget(self, key)

        if value == nil then
            value = computeFunc()
            rawset(self, key, value)

            if timeout then 
                Citizen.SetTimeout(timeout, function() self[key] = nil end) 
            end
        end

        return value
    end
})

RegisterNetEvent("koja-lib:callback_triggered")
AddEventHandler("koja-lib:callback_triggered", function(key, value, oldValue)
    for i, callback in ipairs(storageEvents[key]) do
        CreateThread(function()
            if Config.Debug then
                KOJA.Client.Print(5, true, "[koja-lib] EXECUTING CALLBACK ["..i.."] FROM EVENT FOR '" .. key .. "'")
            end
            callback(value, oldValue)
        end)
    end
end)

KOJA.storage = storage

return storage

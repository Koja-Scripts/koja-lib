storageData = {}
storageEvents = {}

storage = setmetatable({
    game = GetGameName(),
    resource = GetCurrentResourceName()
}, {
    __index = function(self, key)
        storageEvents[key] = {}

        AddEventHandler(('koja_lib:update:%s'):format(key), function(value)

            local oldValue = self[key]
            local events = storageEvents[key]
        
            if events and type(events) == "table" and #events > 0 then
                for i = 1, #events do
                    if type(events[i]) == "function" then
                        Citizen.CreateThread(function()
                            local success, err = pcall(events[i], value, oldValue)
                            if not success then
                                print("^1[KOJA_LIB] error in metatable callback onUpdate:", err, "^0")
                            end
                        end)
                    end
                end
            end
        
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

storage.onUpdate = function(key, callback)
    if not storageEvents[key] then
        getmetatable(storage).__index(storage, key)
    end

    if type(callback) == "function" then
        table.insert(storageEvents[key], callback)
    end
end


KOJA.storage = storage
KOJA.onUpdate = storage.onUpdate

return storage
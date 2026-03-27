---@param dist number
---@param file string
---@param volume number
---@param soundId string|nil
---@param loop boolean|nil
RegisterNetEvent('koja-lib:server:distanceSound')
AddEventHandler('koja-lib:server:distanceSound', function(dist, file, volume, soundId, loop)
    local src = source
    local distanceLimit = 250.0
    local maxDistance = tonumber(dist) or 0.0
    local baseVolume = tonumber(volume) or 0.5

    if maxDistance <= 0.0 or maxDistance > distanceLimit then
        return
    end

    local sourcePed = GetPlayerPed(src)
    if sourcePed <= 0 then
        return
    end

    local sourceCoords = GetEntityCoords(sourcePed)
    TriggerClientEvent('koja-lib:client:distanceSound', -1, sourceCoords, maxDistance, file, baseVolume, soundId, loop == true)
end)

---@param file string
---@param volume number
---@param soundId string|nil
---@param loop boolean|nil
RegisterNetEvent('koja-lib:server:onlySourceSound')
AddEventHandler('koja-lib:server:onlySourceSound', function(file, volume, soundId, loop)
    local src = source
    TriggerClientEvent('koja-lib:client:onlySourceSound', src, file, volume, soundId, loop == true)
end)

---@param soundId string
RegisterNetEvent('koja-lib:server:stopSound')
AddEventHandler('koja-lib:server:stopSound', function(soundId)
    if type(soundId) ~= 'string' or soundId == '' then
        return
    end

    TriggerClientEvent('koja-lib:client:stopSound', -1, soundId)
end)
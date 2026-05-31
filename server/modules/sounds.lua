-- Per-player rate limiting for client-triggered distance sounds (ms between allowed triggers).
local DISTANCE_SOUND_COOLDOWN = 1000
local lastDistanceSound = {}

---@param dist number
---@param file string
---@param volume number
---@param soundId string|nil
---@param loop boolean|nil
RegisterNetEvent('koja-lib:server:distanceSound')
AddEventHandler('koja-lib:server:distanceSound', function(dist, file, volume, soundId, loop)
    local src = source
    local now = GetGameTimer()

    -- Rate limit: one distance sound per player per second
    if lastDistanceSound[src] and (now - lastDistanceSound[src]) < DISTANCE_SOUND_COOLDOWN then
        return
    end
    lastDistanceSound[src] = now

    if type(file) ~= 'string' or file == '' then return end

    local distanceLimit = 250.0
    local maxDistance = tonumber(dist) or 0.0
    local baseVolume = math.min(1.0, math.max(0.0, tonumber(volume) or 0.5))

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
    if type(file) ~= 'string' or file == '' then return end
    local vol = math.min(1.0, math.max(0.0, tonumber(volume) or 0.5))
    -- Only plays for the triggering player — never relayed to others.
    TriggerClientEvent('koja-lib:client:onlySourceSound', src, file, vol, soundId, loop == true)
end)

---@param soundId string
RegisterNetEvent('koja-lib:server:stopSound')
AddEventHandler('koja-lib:server:stopSound', function(soundId)
    local src = source
    if type(soundId) ~= 'string' or soundId == '' then
        return
    end
    -- Stop only for the player who triggered this, never for all players.
    TriggerClientEvent('koja-lib:client:stopSound', src, soundId)
end)

-- Clean up rate-limit table when a player drops to avoid memory leak.
AddEventHandler('playerDropped', function()
    lastDistanceSound[source] = nil
end)

----------------------------------------------------------------------
-- Exports (other server scripts can call these directly)
----------------------------------------------------------------------

-- Play sound for a specific player.
exports('PlaySoundForSource', function(source, file, volume, soundId, loop)
    if not source or type(file) ~= 'string' or file == '' then return end
    TriggerClientEvent('koja-lib:client:onlySourceSound', source, file, volume, soundId, loop == true)
end)

-- Play sound for all players.
exports('PlaySoundForAll', function(file, volume, soundId, loop)
    if type(file) ~= 'string' or file == '' then return end
    TriggerClientEvent('koja-lib:client:onlySourceSound', -1, file, volume, soundId, loop == true)
end)

-- Play distance-based sound originating from coords.
exports('PlayDistanceSound', function(coords, dist, file, volume, soundId, loop)
    if type(file) ~= 'string' or file == '' then return end
    local maxDist = tonumber(dist) or 0.0
    if maxDist <= 0.0 or maxDist > 250.0 then return end
    TriggerClientEvent('koja-lib:client:distanceSound', -1, coords, maxDist, file, volume, soundId, loop == true)
end)

-- Stop sound for all players.
exports('StopSoundForAll', function(soundId)
    if type(soundId) ~= 'string' or soundId == '' then return end
    TriggerClientEvent('koja-lib:client:stopSound', -1, soundId)
end)
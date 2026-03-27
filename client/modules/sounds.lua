KOJA.Client.Sounds = {
    defaultSoundVolume = 0.5
}

---@param file string
---@param volume number
---@param soundId string|nil
---@param loop boolean|nil
RegisterNetEvent('koja-lib:client:onlySourceSound')
AddEventHandler('koja-lib:client:onlySourceSound', function(file, volume, soundId, loop)
    KOJA.Client.SendReactMessage('koja-lib:nui:createSound', {
        type = 'playSound',
        file = file,
        volume = volume or KOJA.Client.Sounds.defaultSoundVolume,
        soundId = soundId,
        loop = loop == true
    })
end)

---@param coords vector3
---@param dist number
---@param file string
---@param volume number
---@param soundId string|nil
---@param loop boolean|nil
RegisterNetEvent('koja-lib:client:distanceSound')
AddEventHandler('koja-lib:client:distanceSound', function(coords, dist, file, volume, soundId, loop)
    local myCoords = GetEntityCoords(PlayerPedId())
    local distance = #(myCoords - coords)

    if distance < dist then
        local distanceMultiplier = 1.0 - (distance / dist)
        local vol = (tonumber(volume) or KOJA.Client.Sounds.defaultSoundVolume) * math.max(0.0, distanceMultiplier)
        KOJA.Client.SendReactMessage('koja-lib:nui:createSound', {
            type = 'playSound',
            file = file,
            volume = vol,
            soundId = soundId,
            loop = loop == true
        })
    end
end)

---@param soundId string
RegisterNetEvent('koja-lib:client:stopSound')
AddEventHandler('koja-lib:client:stopSound', function(soundId)
    KOJA.Client.SendReactMessage('koja-lib:nui:createSound', {
        type = 'stopSound',
        soundId = soundId
    })
end)

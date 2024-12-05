Koja.Client.SendReactMessage = function(action, data)
    SendNUIMessage({
        action = action, data = data
    })
end

Koja.Client.GetPlayerData = function()
    if Koja.Framework == "esx" then
        return Koja.Framework.GetPlayerData()
    elseif Koja.Framework == "qb" or Koja.Framework == "qbx" then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerData()
    elseif Koja.Framework == "ox" then
        return cache.ped
    end
end
KOJA.Client.GetPlayerData = function()
    if KOJA.Framework == "esx" then
        return ESX.GetPlayerData()
    elseif KOJA.Framework == "qb" then
        return QBCore.Functions.GetPlayerData()
    elseif KOJA.Framework == "ox" then
        return Ox.GetPlayer()
    elseif KOJA.Framework == "custom" then
        return -- Custom function to get PlayerData
    end
end

KOJA.Client.GetPlayerJob = function()
    if KOJA.Framework == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.PlayerData.job.name
    elseif KOJA.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.job.name
    elseif KOJA.Framework == "ox" then
        local player = Ox.GetPlayer()
        return player.get('job')
    elseif KOJA.Framework == 'custom' then
        return --
    end
end

KOJA.Client.IsDead = function()
    IsEntityDead(KOJA.storage.ped)
end
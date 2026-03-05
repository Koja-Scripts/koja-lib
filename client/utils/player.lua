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
        local job = ESX.GetPlayerData().job
        if job then return job.name, job.grade end
    elseif KOJA.Framework == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.job then return PlayerData.job.name, PlayerData.job.grade.level end
    elseif KOJA.Framework == "ox" then
        local player = Ox.GetPlayer()
        if player then 
            local job = player.get('job')
            if job then return job.name, job.grade end
        end
    elseif KOJA.Framework == 'custom' then
        return 'unemployed', 1
    end
    return 'unemployed', 1
end

KOJA.Client.IsDead = function()
    IsEntityDead(KOJA.storage.ped)
end
---@return table # Player data
KOJA.Client.GetPlayerData = function()
    if KOJA.Framework == "esx" then 
        return ESX.GetPlayerData()
    elseif KOJA.Framework == "qb" then 
        return QBCore.Functions.GetPlayerData()
    elseif KOJA.Framework == "ox" then 
        return Ox.GetPlayer()
    end
end

---@return string # Player job
KOJA.Client.GetPlayerJob = function()
    local framework = KOJA.Framework
    if framework == "esx" then 
        return ESX.PlayerData.job.name
    elseif framework == "qb" then 
        return QBCore.Functions.GetPlayerData().job.name
    elseif framework == "ox" then
         return Ox.GetPlayer().get('job')
    end
end

---@return string # Player job label
KOJA.Client.GetPlayerJobLabel = function()
    local framework = KOJA.Framework
    if framework == "esx" then 
        return ESX.PlayerData.job.label
    elseif framework == "qb" then 
        return QBCore.Functions.GetPlayerData().job.label
    elseif framework == "ox" then
         return Ox.GetPlayer().get('job')
    end
end

---@return boolean # Whether the player is dead
KOJA.Client.IsDead = function()
    return IsEntityDead(KOJA.storage.ped)
end
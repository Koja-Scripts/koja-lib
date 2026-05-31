-- Note: KOJA.Client.GetPlayerData lives in client/utils/player.lua (single source).

---@return string # Player job
KOJA.Client.GetPlayerJob = function()
    local framework = KOJA.Framework
    if framework == "esx" then
        return ESX.PlayerData.job.name
    elseif framework == "qb" then
        return QBCore.Functions.GetPlayerData().job.name
    elseif framework == "custom" then
        local fn = CustomFramework and CustomFramework.Client and CustomFramework.Client.GetPlayerJob
        return fn and fn() or nil
    end
end

---@return string # Player job label
KOJA.Client.GetPlayerJobLabel = function()
    local framework = KOJA.Framework
    if framework == "esx" then
        return ESX.PlayerData.job.label
    elseif framework == "qb" then
        return QBCore.Functions.GetPlayerData().job.label
    elseif framework == "custom" then
        local fn = CustomFramework and CustomFramework.Client and CustomFramework.Client.GetPlayerJobLabel
        return fn and fn() or nil
    end
end

---@return boolean # Whether the player is dead
KOJA.Client.IsDead = function()
    return IsEntityDead(KOJA.storage.ped)
end

---@return table # Player data
KOJA.Client.GetPlayerData = function()
    if KOJA.Framework == "esx" then
        return ESX.GetPlayerData()
    elseif KOJA.Framework == "qb" then
        return QBCore.Functions.GetPlayerData()
    elseif KOJA.Framework == "custom" then
        local fn = CustomFramework and CustomFramework.Client and CustomFramework.Client.GetPlayerData
        return fn and fn() or {}
    end
    return {}
end

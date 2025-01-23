KOJA.Client.GetPlayerData = function()
    if KOJA.Framework == "esx" then
        return ESX.GetPlayerData()
    elseif KOJA.Framework == "qb" then
        return QBCore.Functions.GetPlayerData()
    elseif KOJA.Framework == "ox" then
        return Ox.GetPlayer()
    end
end

KOJA.Client.IsDead = function()
    IsEntityDead(cache.ped)
end
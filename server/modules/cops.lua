KOJA.Server.RegisterServerCallback("koja-heistlib:Server:getCopCount", function(source, data, cb)
    local count = 0

    local players = KOJA.Server.GetPlayers()
    if KOJA.Framework == 'esx' then
        for _, player in ipairs(players) do
            local Player = ESX.GetPlayerFromId(player)
            if Config.PoliceGroups[Player.job.name] then
                count += 1
            end
        end 
    elseif KOJA.Framework == 'ox' then
        for _, player in ipairs(players) do
            local Player = KOJA.Server.GetPlayerBySource(player.source)
            local job = Player.getGroup()
            if Config.PoliceGroups[job.name] then
                count += 1
            end
        end
    elseif KOJA.Framework == 'qb' then
        for _, player in ipairs(players) do
            local Player = KOJA.Server.GetPlayerBySource(player)
            if Config.PoliceGroups[Player.PlayerData.job.name] then
                count += 1
            end
        end 
    end 

    cb({ count = count })
end)

KOJA.Server.GetCopCount = function()
    local count = 0

    local players = KOJA.Server.GetPlayers()
    if KOJA.Framework == 'esx' then
        for _, player in ipairs(players) do
            local Player = ESX.GetPlayerFromId(player)
            if Config.PoliceGroups[Player.job.name] then
                count += 1
            end
        end 
    elseif KOJA.Framework == 'ox' then
        for _, player in ipairs(players) do
            local Player = KOJA.Server.GetPlayerBySource(player.source)
            local job = Player.getGroup()
            if Config.PoliceGroups[job.name] then
                count += 1
            end
        end
    elseif KOJA.Framework == 'qb' then
        for _, player in ipairs(players) do
            local Player = KOJA.Server.GetPlayerBySource(player)
            if Config.PoliceGroups[Player.PlayerData.job.name] then
                count += 1
            end
        end 
    end   

    return count
end

exports('getCopCount', KOJA.Server.GetCopCount)
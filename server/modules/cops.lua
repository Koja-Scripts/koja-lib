-- Counts online players whose job/group is flagged as police in Config.PoliceGroups.
local function countCops()
    local count = 0
    local players = KOJA.Server.GetPlayers() or {}

    for _, entry in ipairs(players) do
        -- GetPlayers returns ids (esx/qb) or player objects depending on framework.
        local src = type(entry) == 'table' and entry.source or entry
        local jobName = KOJA.Server.GetPlayerJob(src)
        if jobName and Config.PoliceGroups[jobName] then
            count = count + 1
        end
    end

    return count
end

KOJA.Server.RegisterServerCallback("koja-heistlib:Server:getCopCount", function(source, data, cb)
    cb({ count = countCops() })
end)

KOJA.Server.GetCopCount = function()
    return countCops()
end

exports('getCopCount', KOJA.Server.GetCopCount)

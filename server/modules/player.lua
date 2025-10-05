---@param source number # Player ID
---@return table # Player object based on the current framework
KOJA.Server.GetPlayerBySource = function(source)
    return getPlayer(source)
end

---@param source number # Player ID
---@return string # Character identifier (charID) based on the current framework
KOJA.Server.GetPlayerIdentifier = function(source)
    return getIdentifier(source)
end

---@param source number # Player ID
---@return table # Player job object based on the current framework
KOJA.Server.GetPlayerJob = function(source)
    return getPlayerJob(source)
end

KOJA.Server.GetPlayers = function()
    return GetPlayers()
end

KOJA.Server.GetPlayerGroup = function(source)
    print(source)
    return getPlayerGroup(source)
end
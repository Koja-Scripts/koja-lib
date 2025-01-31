---@param source number # Player ID
---@return table # Player object based on the current framework
KOJA.Server.GetPlayerBySource = function(source)
    return getPlayer(source)
end
exports('GetPlayerBySource', KOJA.Server.GetPlayerBySource)

---@param source number # Player ID
---@return string # Character identifier (charID) based on the current framework
KOJA.Server.GetPlayerIdentifier = function(source)
    return getIdentifier(source)
end
exports('GetPlayerIdentifier', KOJA.Server.GetPlayerIdentifier)

KOJA.Server.getPlayerJob = function(src)
    return getPlayerJob(src) 
end
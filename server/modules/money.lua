---@param source number # Player ID
---@param mtype string # Money type
---@return number # Player's money based on the type
KOJA.Server.getMoney = function(source, mtype)
    return getMoney(source, mtype)
end

---@param source number # Player ID
---@param amount number # Amount to remove
---@param mtype string # Money type
---@param reason string # Reason for removal
---@return boolean # Whether the removal was successful
KOJA.Server.removeMoney = function(source, amount, mtype, reason)
    return removeMoney(source, amount, mtype, reason)
end
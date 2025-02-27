---@param source number # Player ID
---@param mtype string # Money type
---@return number # Player's money based on the type
KOJA.Server.getMoney = function(source, mtype)
    return getMoney(source, mtype)
end

---@param source number # Player ID
---@param amount number # Amount to add
---@param mtype string # Money type
---@param reason string # Reason for add
---@return boolean # Whether the add was successful
KOJA.Server.addMoney = function(source, amount, mtype, reason)
    return addMoney(source, amount, mtype, reason)
end

---@param source number # Player ID
---@param amount number # Amount to remove
---@param mtype string # Money type
---@param reason string # Reason for removal
---@return boolean # Whether the removal was successful
KOJA.Server.removeMoney = function(source, amount, mtype, reason)
    return removeMoney(source, amount, mtype, reason)
end

KOJA.Server.RegisterServerCallback("KOJA_LIB:GetMoney", function(source, data, cb)
    local money = getMoney(source, 'cash')
    local bank = getMoney(source, 'bank')
    cb({ money = money, bank = bank })
end)
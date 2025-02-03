---@param source number # Player ID
---@param name string # Item name
---@param count number # Amount of item
---@return boolean # Whether the item was successfully added
KOJA.Server.addInventoryItem = function(source, name, count)
    return addInventoryItem(source, name, count)
end
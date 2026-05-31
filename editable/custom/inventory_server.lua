--[[
    CUSTOM INVENTORY — SERVER

    Used only when Config.Inventory = "custom".
    Implement your inventory's server-side item logic here. These power
    KOJA.Server.addInventoryItem / removeInventoryItem / getInventoryItemCount /
    HasItem / GetPlayerInventory.

    Return values:
      AddItem / RemoveItem -> boolean (success)
      GetItemCount         -> number
      GetItems             -> table { [itemName] = count }
]]

CustomInventory = CustomInventory or {}

CustomInventory.Server = {

    ---@param src number
    ---@param name string
    ---@param count number
    ---@param metadata? table
    ---@param slot? number
    ---@return boolean
    AddItem = function(src, name, count, metadata, slot)
        return false
    end,

    ---@param src number
    ---@param name string
    ---@param count number
    ---@param metadata? table
    ---@param slot? number
    ---@return boolean
    RemoveItem = function(src, name, count, metadata, slot)
        return false
    end,

    ---@param src number
    ---@param name string
    ---@param metadata? table
    ---@return number
    GetItemCount = function(src, name, metadata)
        return 0
    end,

    ---@param src number
    ---@return table # { [itemName] = count }
    GetItems = function(src)
        return {}
    end,
}

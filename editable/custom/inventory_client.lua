--[[
    CUSTOM INVENTORY — CLIENT

    Used only when Config.Inventory = "custom".
    Implement your inventory's client-side reads here. These power
    KOJA.Client.GetItemCount / GetItems / HasItem.
]]

CustomInventory = CustomInventory or {}

CustomInventory.Client = {

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        return 0
    end,

    ---@return table # { [itemName] = count }
    GetItems = function()
        return {}
    end,
}

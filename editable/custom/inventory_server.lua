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
    -- Bridge v2 hooks (optional): carry check, slot lookup, item list, stashes ---------

    ---@param src number
    ---@param name string
    ---@param count number
    ---@return boolean
    CanCarryItem = function(src, name, count)
        return true
    end,

    ---@param src number
    ---@param name string
    ---@return table # { { slot, count, metadata } }
    GetItemsByName = function(src, name)
        return {}
    end,

    ---@return table # { [itemName] = { label, weight, image } }
    GetItemList = function()
        return {}
    end,

    -- Stash hooks. Leave them as nil to use the built-in KVP backed fallback stash.
    -- RegisterStash = function(id, label, slots, weight, groups) return true end,
    -- OpenStash = function(src, id, label, slots, weight) return true end,
    -- AddStashItem = function(id, item, count, metadata) return true end,
    -- RemoveStashItem = function(id, item, count) return true end,
    -- GetStashItems = function(id) return {} end, -- { { name, count, metadata } }
}

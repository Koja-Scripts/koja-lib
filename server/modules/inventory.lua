-- Server inventory bridge.
--
-- Public API (names kept stable for backwards compatibility):
--   KOJA.Server.addInventoryItem(source, name, count, metadata, slot)
--   KOJA.Server.removeInventoryItem(source, name, count, metadata, slot)
--   KOJA.Server.getInventoryItemCount(source, name, metadata)
--   KOJA.Server.GetPlayerInventory(source)
--
-- New helpers (additive, non-breaking):
--   KOJA.Server.HasItem(source, name, count)
--
-- Each supported inventory resource gets an adapter. When the detected
-- inventory (KOJA.Inventory) has no adapter, or an adapter call fails/returns
-- nil, we fall back to the framework's native item functions defined in
-- server/framework.lua (addInventoryItem / removeInventoryItem /
-- getInventoryItemCount). Those native functions already cover qb-inventory,
-- ps-inventory, mf-inventory, ij-inventory and other forks that keep the
-- framework's item API intact.

local function safeCall(fn, ...)
    local ok, a, b = pcall(fn, ...)
    if ok then
        return a, b
    end
    return nil
end

-- Normalises any inventory's "items" structure into { [itemName] = count }.
local function normaliseItems(items)
    local inventory = {}
    if type(items) ~= 'table' then
        return inventory
    end
    for _, item in pairs(items) do
        if type(item) == 'table' and item.name then
            inventory[item.name] = (inventory[item.name] or 0) + (item.count or item.amount or 0)
        end
    end
    return inventory
end

----------------------------------------------------------------------
-- Adapters
----------------------------------------------------------------------

local Adapters = {}

-- ox_inventory ------------------------------------------------------
Adapters['ox_inventory'] = {
    AddItem = function(src, name, count, metadata, slot)
        local ok = safeCall(function()
            return exports.ox_inventory:AddItem(src, name, count, metadata, slot)
        end)
        return ok == true or ok == 1
    end,
    RemoveItem = function(src, name, count, metadata, slot)
        local ok = safeCall(function()
            return exports.ox_inventory:RemoveItem(src, name, count, metadata, slot)
        end)
        return ok == true or ok == 1
    end,
    GetItemCount = function(src, name, metadata)
        local count = safeCall(function()
            return exports.ox_inventory:GetItemCount(src, name, metadata)
        end)
        return tonumber(count) or 0
    end,
    GetItems = function(src)
        return normaliseItems(safeCall(function()
            return exports.ox_inventory:GetInventoryItems(src)
        end))
    end,
}

-- codem-inventory ---------------------------------------------------
-- API: AddItem(src, item, amount, slot?, info?)
--      RemoveItem(src, itemname, amount, slot?)
--      GetItemsTotalAmount(src, itemname) -> number
--      GetInventory(identifier, src) -> items table
--      HasItem(src, items, amount) -> boolean
Adapters['codem-inventory'] = {
    AddItem = function(src, name, count, metadata, slot)
        local ok = safeCall(function()
            return exports['codem-inventory']:AddItem(src, name, count, slot, metadata)
        end)
        return ok ~= false
    end,
    RemoveItem = function(src, name, count, metadata, slot)
        local ok = safeCall(function()
            return exports['codem-inventory']:RemoveItem(src, name, count, slot)
        end)
        return ok ~= false
    end,
    GetItemCount = function(src, name)
        local count = safeCall(function()
            return exports['codem-inventory']:GetItemsTotalAmount(src, name)
        end)
        return tonumber(count) or 0
    end,
    GetItems = function(src)
        -- GetInventory(identifier, source): identifier can be source when passed as number
        local items = safeCall(function()
            return exports['codem-inventory']:GetInventory(src, src)
        end)
        return normaliseItems(items)
    end,
}

-- jaksam_inventory --------------------------------------------------
-- Resource name: jaksam_inventory (not jacksam-inventory)
-- API: addItem(inventoryId, itemName, amount, metadata?, slotId?) -> success, resultCode
--      removeItem(inventoryId, itemName, amount, metadata?, slotId?) -> success, resultCode
--      getTotalItemAmount(inventoryId, itemName, metadata?) -> number
--      getInventory(inventoryId) -> inventory table
--      hasItem(inventoryId, itemName, quantity?) -> boolean
-- For player inventories, inventoryId = tostring(source)
Adapters['jaksam_inventory'] = {
    AddItem = function(src, name, count, metadata, slot)
        local ok = safeCall(function()
            return exports.jaksam_inventory:addItem(tostring(src), name, count, metadata, slot)
        end)
        return ok == true
    end,
    RemoveItem = function(src, name, count, metadata, slot)
        local ok = safeCall(function()
            return exports.jaksam_inventory:removeItem(tostring(src), name, count, metadata, slot)
        end)
        return ok == true
    end,
    GetItemCount = function(src, name, metadata)
        local count = safeCall(function()
            return exports.jaksam_inventory:getTotalItemAmount(tostring(src), name, metadata)
        end)
        return tonumber(count) or 0
    end,
    GetItems = function(src)
        local inv = safeCall(function()
            return exports.jaksam_inventory:getInventory(tostring(src))
        end)
        if type(inv) == 'table' and inv.items then
            return normaliseItems(inv.items)
        end
        return normaliseItems(inv)
    end,
}

-- custom (Config.Inventory = "custom") ------------------------------
-- Delegates to CustomInventory.Server from editable/custom/inventory_server.lua.
Adapters['custom'] = {
    AddItem = function(src, name, count, metadata, slot)
        local inv = CustomInventory and CustomInventory.Server
        if inv and inv.AddItem then return inv.AddItem(src, name, count, metadata, slot) end
    end,
    RemoveItem = function(src, name, count, metadata, slot)
        local inv = CustomInventory and CustomInventory.Server
        if inv and inv.RemoveItem then return inv.RemoveItem(src, name, count, metadata, slot) end
    end,
    GetItemCount = function(src, name, metadata)
        local inv = CustomInventory and CustomInventory.Server
        if inv and inv.GetItemCount then return inv.GetItemCount(src, name, metadata) end
    end,
    GetItems = function(src)
        local inv = CustomInventory and CustomInventory.Server
        if inv and inv.GetItems then return inv.GetItems(src) end
    end,
}

----------------------------------------------------------------------
-- Bridge
----------------------------------------------------------------------

local function adapter()
    return Adapters[KOJA.Inventory]
end

---@param source number # Player ID
---@param name string # Item name
---@param count number # Amount of item
---@param metadata? table # Optional item metadata (ox/qs)
---@param slot? number # Optional slot
---@return boolean # Whether the item was successfully added
KOJA.Server.addInventoryItem = function(source, name, count, metadata, slot)
    local a = adapter()
    if a and a.AddItem then
        local ok = a.AddItem(source, name, count, metadata, slot)
        if ok ~= nil then
            return ok
        end
    end
    return addInventoryItem(source, name, count)
end

---@param source number # Player ID
---@param name string # Item name
---@param count number # Amount of item
---@param metadata? table # Optional item metadata (ox/qs)
---@param slot? number # Optional slot
---@return boolean # Whether the item was successfully removed
KOJA.Server.removeInventoryItem = function(source, name, count, metadata, slot)
    local a = adapter()
    if a and a.RemoveItem then
        local ok = a.RemoveItem(source, name, count, metadata, slot)
        if ok ~= nil then
            return ok
        end
    end
    return removeInventoryItem(source, name, count)
end

---@param source number # Player ID
---@param name string # Item name
---@param metadata? table # Optional item metadata (ox)
---@return number # Amount of the item the player owns
KOJA.Server.getInventoryItemCount = function(source, name, metadata)
    local a = adapter()
    if a and a.GetItemCount then
        local count = a.GetItemCount(source, name, metadata)
        if count ~= nil then
            return count
        end
    end
    return getInventoryItemCount(source, name) or 0
end

---@param source number # Player ID
---@param name string # Item name
---@param count? number # Minimum amount required (defaults to 1)
---@return boolean # Whether the player owns at least `count` of the item
KOJA.Server.HasItem = function(source, name, count)
    return KOJA.Server.getInventoryItemCount(source, name) >= (count or 1)
end

---@param source number # Player ID
---@return table # Player inventory as { [itemName] = count }
KOJA.Server.GetPlayerInventory = function(source)
    local a = adapter()
    if a and a.GetItems then
        local items = a.GetItems(source)
        if items then
            return items
        end
    end

    -- Framework-native fallback (qb forks keep PlayerData.items; esx getInventory).
    if KOJA.Framework == 'esx' then
        local Player = getPlayer(source)
        if Player and Player.getInventory then
            return normaliseItems(Player.getInventory())
        end
    elseif KOJA.Framework == 'qb' then
        local Player = getPlayer(source)
        if Player and Player.PlayerData and Player.PlayerData.items then
            return normaliseItems(Player.PlayerData.items)
        end
    end

    return {}
end

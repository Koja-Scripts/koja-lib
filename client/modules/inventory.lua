-- Client inventory bridge.
--
-- Public API (names kept stable for backwards compatibility):
--   KOJA.Client.GetItemCount(item)
--
-- New helpers (additive, non-breaking):
--   KOJA.Client.HasItem(item, count)
--   KOJA.Client.GetItems()  -> { [itemName] = count }
--
-- Resolution mirrors the server: a dedicated adapter for the detected
-- inventory resource (KOJA.Inventory) when available, otherwise the active
-- framework's player data is used. qb-inventory and its forks keep the
-- framework item data intact, so they resolve through the framework path.

local function safeCall(fn, ...)
    local ok, a = pcall(fn, ...)
    if ok then
        return a
    end
    return nil
end

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

Adapters['ox_inventory'] = {
    GetItemCount = function(item)
        return tonumber(safeCall(function()
            return exports.ox_inventory:GetItemCount(item)
        end)) or 0
    end,
    GetItems = function()
        return normaliseItems(safeCall(function()
            return exports.ox_inventory:GetPlayerItems()
        end))
    end,
}

-- codem-inventory ---------------------------------------------------
-- Client API: getUserInventory() / GetClientPlayerInventory() -> items table
Adapters['codem-inventory'] = {
    GetItemCount = function(item)
        local items = safeCall(function()
            return exports['codem-inventory']:GetClientPlayerInventory()
        end)
        if type(items) ~= 'table' then
            items = safeCall(function()
                return exports['codem-inventory']:getUserInventory()
            end)
        end
        if type(items) ~= 'table' then return 0 end
        local count = 0
        for _, v in pairs(items) do
            if type(v) == 'table' and v.name == item then
                count = count + (v.amount or v.count or 0)
            end
        end
        return count
    end,
    GetItems = function()
        local items = safeCall(function()
            return exports['codem-inventory']:GetClientPlayerInventory()
        end)
        if type(items) ~= 'table' then
            items = safeCall(function()
                return exports['codem-inventory']:getUserInventory()
            end)
        end
        local inv = {}
        if type(items) ~= 'table' then return inv end
        for _, v in pairs(items) do
            if type(v) == 'table' and v.name then
                inv[v.name] = (inv[v.name] or 0) + (v.amount or v.count or 0)
            end
        end
        return inv
    end,
}

-- jaksam_inventory --------------------------------------------------
-- Client API: getTotalItemAmount(itemName, metadata?) -> number
--             getInventory() -> inventory table (with .items key)
Adapters['jaksam_inventory'] = {
    GetItemCount = function(item)
        return tonumber(safeCall(function()
            return exports.jaksam_inventory:getTotalItemAmount(item)
        end)) or 0
    end,
    GetItems = function()
        local inv = safeCall(function()
            return exports.jaksam_inventory:getInventory()
        end)
        local items = (type(inv) == 'table' and inv.items) and inv.items or inv
        local result = {}
        if type(items) ~= 'table' then return result end
        for _, v in pairs(items) do
            if type(v) == 'table' and v.name then
                result[v.name] = (result[v.name] or 0) + (v.count or v.amount or 0)
            end
        end
        return result
    end,
}

-- custom (Config.Inventory = "custom") ------------------------------
Adapters['custom'] = {
    GetItemCount = function(item)
        local inv = CustomInventory and CustomInventory.Client
        if inv and inv.GetItemCount then return inv.GetItemCount(item) end
    end,
    GetItems = function()
        local inv = CustomInventory and CustomInventory.Client
        if inv and inv.GetItems then return inv.GetItems() end
    end,
}

----------------------------------------------------------------------
-- Framework-native resolution
----------------------------------------------------------------------

local function frameworkItems()
    if KOJA.Framework == 'esx' then
        local data = ESX and ESX.GetPlayerData()
        return normaliseItems(data and data.inventory)
    elseif KOJA.Framework == 'qb' then
        local data = QBCore and QBCore.Functions.GetPlayerData()
        return normaliseItems(data and data.items)
    end
    return {}
end

----------------------------------------------------------------------
-- Bridge
----------------------------------------------------------------------

---@param item string # Item name
---@return number # Amount of the item the player owns
KOJA.Client.GetItemCount = function(item)
    local a = Adapters[KOJA.Inventory]
    if a and a.GetItemCount then
        local count = a.GetItemCount(item)
        if count ~= nil then
            return count
        end
    end
    return frameworkItems()[item] or 0
end

---@return table # Player inventory as { [itemName] = count }
KOJA.Client.GetItems = function()
    local a = Adapters[KOJA.Inventory]
    if a and a.GetItems then
        local items = a.GetItems()
        if items then
            return items
        end
    end
    return frameworkItems()
end

---@param item string # Item name
---@param count? number # Minimum amount required (defaults to 1)
---@return boolean # Whether the player owns at least `count` of the item
KOJA.Client.HasItem = function(item, count)
    return KOJA.Client.GetItemCount(item) >= (count or 1)
end

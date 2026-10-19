---Inventory helpers used by the items / stash / usable modules.
---Detection is owned by the inventory bridge (Misc.Utils.GetInventory -> KOJA.Inventory, see editable/shared/inventory.lua
---and server/modules/inventory.lua). This file only narrows that result down to the variants the stash, image and
---native item helpers care about, plus the framework-native item path (fwAddItem / fwRemoveItem in server/framework.lua).
KOJA.Server.Inv = KOJA.Server.Inv or {}
local Inv = KOJA.Server.Inv

local itemCache = { at = 0, data = nil }

local function toInt(value)
    return math.floor(tonumber(value) or 0)
end

local function started(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function frameworkCall(name, ...)
    local fn = _G[name]
    if type(fn) == 'function' then
        return fn(...)
    end
    return nil
end

local function isModernQb()
    local version = GetResourceMetadata('qb-inventory', 'version', 0) or '0'
    local major = tonumber(tostring(version):match('^(%d+)')) or 0
    return major >= 2
end

local legacyForks = { 'ps-inventory', 'lj-inventory' }

---@return string # 'ox_inventory' | 'qb-inventory' (v2) | 'qb-legacy' (qb-inventory v1 / ps / lj) | 'codem-inventory' | 'jaksam_inventory' | 'custom' | 'framework'
Inv.Name = function()
    local detected = KOJA.Inventory

    if detected == 'qb-inventory' then
        if isModernQb() then return 'qb-inventory' end
        Inv.LegacyResource = 'qb-inventory'
        return 'qb-legacy'
    end

    for _, fork in ipairs(legacyForks) do
        if detected == fork or (detected == 'framework' and started(fork)) then
            Inv.LegacyResource = fork
            return 'qb-legacy'
        end
    end

    return detected or 'framework'
end

Inv.IsOx = function() return Inv.Name() == 'ox_inventory' end
Inv.IsQb = function() return Inv.Name() == 'qb-inventory' end

-- Inventories without an adapter in server/modules/inventory.lua: items go through the framework / qb-inventory exports.
Inv.IsNative = function()
    local name = Inv.Name()
    return name == 'qb-inventory' or name == 'qb-legacy' or name == 'framework'
end

local function itemBox(src, item, action, count)
    if KOJA.Framework ~= 'qb' or GetResourceState('qbx_core') == 'started' then return end
    local items = frameworkCall('getFrameworkItems') or {}
    local def = items[item]
    if def then TriggerClientEvent('qb-inventory:client:ItemBox', src, def, action, count) end
end

---@return number
Inv.GetItemCount = function(src, item)
    if not item then return 0 end
    if Inv.Name() == 'qb-inventory' then
        local ok, count = pcall(function() return exports['qb-inventory']:GetItemCount(src, item) end)
        if ok and count then return toInt(count) end
    end
    return toInt(KOJA.Server.getInventoryItemCount(src, item))
end

---@return boolean
Inv.CanCarry = function(src, item, count, metadata)
    count = toInt(count)
    local name = Inv.Name()
    if name == 'ox_inventory' then
        local ok, res = pcall(function() return exports.ox_inventory:CanCarryItem(src, item, count, metadata) end)
        return ok and res == true
    end
    if name == 'qb-inventory' then
        local ok, res = pcall(function() return exports['qb-inventory']:CanAddItem(src, item, count) end)
        if ok and res ~= nil then
            if type(res) == 'table' then return res[1] == true end
            return res == true
        end
        return true
    end
    if name == 'codem-inventory' or name == 'jaksam_inventory' then return true end
    return frameworkCall('fwCanCarryItem', src, item, count) ~= false
end

---Native add, used by KOJA.Server.addInventoryItem when the item carries metadata and no adapter handled it.
---@return boolean
Inv.NativeAdd = function(src, item, count, metadata)
    count = toInt(count)
    if not item or count <= 0 then return false end
    local name = Inv.Name()
    if name == 'qb-inventory' then
        local ok, res = pcall(function() return exports['qb-inventory']:AddItem(src, item, count, false, metadata, 'koja-lib') end)
        if ok and res then itemBox(src, item, 'add', count) end
        return ok and res and true or false
    end
    local done = frameworkCall('fwAddItem', src, item, count, metadata) == true
    if done and name == 'qb-legacy' then itemBox(src, item, 'add', count) end
    return done
end

---Native remove, used by KOJA.Server.removeInventoryItem when metadata / slot is given and no adapter handled it.
---@return boolean
Inv.NativeRemove = function(src, item, count, metadata, slot)
    count = toInt(count)
    if not item or count <= 0 then return false end
    local name = Inv.Name()
    if Inv.GetItemCount(src, item) < count then return false end
    if name == 'qb-inventory' then
        local ok, res = pcall(function() return exports['qb-inventory']:RemoveItem(src, item, count, slot or false, 'koja-lib') end)
        if ok and res then itemBox(src, item, 'remove', count) end
        return ok and res and true or false
    end
    local done = frameworkCall('fwRemoveItem', src, item, count, metadata, slot) == true
    if done and name == 'qb-legacy' then itemBox(src, item, 'remove', count) end
    return done
end

---@return boolean
Inv.AddItem = function(src, item, count, metadata)
    count = toInt(count)
    if not item or count <= 0 then return false end
    if Inv.IsNative() then return Inv.NativeAdd(src, item, count, metadata) end
    return KOJA.Server.addInventoryItem(src, item, count, metadata) == true
end

---@return boolean
Inv.RemoveItem = function(src, item, count, metadata, slot)
    count = toInt(count)
    if not item or count <= 0 then return false end
    if Inv.IsNative() then return Inv.NativeRemove(src, item, count, metadata, slot) end
    if Inv.GetItemCount(src, item) < count then return false end
    return KOJA.Server.removeInventoryItem(src, item, count, metadata, slot) == true
end

---@return string|nil
Inv.ImageFor = function(item, def)
    local templates = Config.ItemImages or {}
    local name = Inv.Name()
    if name == 'ox_inventory' then
        local image = def and def.client and def.client.image
        if image then
            if image:find('://') then return image end
            return ('nui://ox_inventory/web/images/%s'):format(image)
        end
        return (templates.ox_inventory or 'nui://ox_inventory/web/images/%s.png'):format(item)
    end
    if name == 'qb-inventory' then
        return (templates['qb-inventory'] or 'nui://qb-inventory/html/images/%s'):format(def and def.image or (item .. '.png'))
    end
    if name == 'qb-legacy' then
        return (templates['qb-legacy'] or 'nui://%s/html/images/%s'):format(Inv.LegacyResource or 'qb-inventory', def and def.image or (item .. '.png'))
    end
    return (templates.framework or 'nui://ox_inventory/web/images/%s.png'):format(item)
end

---@param src number # Player ID
---@param name string # Item name
---@param count number # Amount
---@return boolean # Whether the player can carry the items
KOJA.Server.CanCarryItem = function(src, name, count)
    return Inv.CanCarry(src, name, count)
end

---@param src number # Player ID
---@param name string # Item name
---@return table # { { slot, count, metadata } }
KOJA.Server.GetItemsByName = function(src, name)
    local result = {}
    local inv = Inv.Name()

    if inv == 'ox_inventory' then
        local ok, slots = pcall(function() return exports.ox_inventory:Search(src, 'slots', name) end)
        for _, slot in pairs(ok and slots or {}) do
            result[#result + 1] = { slot = slot.slot, count = slot.count, metadata = slot.metadata or {} }
        end
        return result
    end

    if inv == 'qb-inventory' then
        local ok, slots = pcall(function() return exports['qb-inventory']:GetItemsByName(src, name) end)
        if ok and slots then
            for _, slot in pairs(slots) do
                result[#result + 1] = { slot = slot.slot, count = slot.amount or slot.count, metadata = slot.info or {} }
            end
            return result
        end
    end

    return frameworkCall('fwGetItemsByName', src, name) or result
end

---@return table # { [name] = { label, weight, image } } (cached for Config.ItemListCacheSeconds, default 60)
KOJA.Server.GetItemList = function()
    local now = os.time()
    if itemCache.data and now - itemCache.at < (Config.ItemListCacheSeconds or 60) then
        return itemCache.data
    end

    local list = {}
    if Inv.IsOx() then
        local ok, items = pcall(function() return exports.ox_inventory:Items() end)
        for name, def in pairs(ok and items or {}) do
            list[name] = { label = def.label or name, weight = def.weight or 0, image = Inv.ImageFor(name, def) }
        end
    else
        for name, def in pairs(frameworkCall('getFrameworkItems') or {}) do
            list[name] = { label = def.label or name, weight = def.weight or 0, image = Inv.ImageFor(name, def) }
        end
    end

    itemCache = { at = now, data = list }
    return list
end

---@param name string # Item name
---@return string # Item label (item name when unknown)
KOJA.Server.GetItemLabel = function(name)
    local def = KOJA.Server.GetItemList()[name]
    return def and def.label or tostring(name)
end

---@param name string # Item name
---@return string|nil # nui:// image url
KOJA.Server.GetItemImage = function(name)
    local def = KOJA.Server.GetItemList()[name]
    if def and def.image then return def.image end
    return Inv.ImageFor(name, nil)
end

---Name -> count map of the player's inventory, as list of { name, count, label }.
Inv.GetPlayerItems = function(src)
    local result = {}
    for name, count in pairs(KOJA.Server.GetPlayerInventory(src) or {}) do
        if toInt(count) > 0 then
            result[#result + 1] = { name = name, count = toInt(count), label = KOJA.Server.GetItemLabel(name) }
        end
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

---Usable items.
---ox_inventory: handled through the `ox_inventory:usedItem` server event (item must be usable, e.g. `consume = 0`),
---or through the `koja-lib.useItem` export (`server = { export = 'koja-lib.useItem' }` in the item definition).
---Other inventories: framework usable item registration (ESX.RegisterUsableItem / CreateUseableItem).
KOJA.Server.Inv = KOJA.Server.Inv or {}
local Inv = KOJA.Server.Inv

local handlers = {}
local frameworkRegistered = {}
local recent = {}

local function metadataFrom(data)
    if type(data) ~= 'table' then return {} end
    return data.metadata or data.info or {}
end

local function dispatch(src, name, metadata, slot)
    local handler = handlers[name]
    src = tonumber(src)
    if not handler or not src then return end

    -- ox_inventory may notify through both the export and the event for the same use
    local key = ('%s:%s:%s'):format(src, name, tostring(slot or 0))
    local now = GetGameTimer()
    if recent[key] and now - recent[key] < 300 then return end
    recent[key] = now

    local ok, err = pcall(handler, src, name, metadata or {}, slot)
    if not ok then
        print(('^1[koja-lib]^0 usable item handler "%s" failed: %s'):format(name, tostring(err)))
    end
end

---@param name string # Item name
---@param fn function # fn(src, item, metadata, slot)
---@return boolean
KOJA.Server.RegisterUsableItem = function(name, fn)
    if not name or type(fn) ~= 'function' then return false end
    handlers[name] = fn

    if Inv.IsOx and Inv.IsOx() then return true end
    if frameworkRegistered[name] then return true end

    local register = _G.registerFrameworkUsable
    if type(register) ~= 'function' then return false end

    local ok, done = pcall(register, name, function(src, data)
        dispatch(src, name, metadataFrom(data), type(data) == 'table' and data.slot or nil)
    end)
    if ok and done then
        frameworkRegistered[name] = true
        return true
    end
    return false
end

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    dispatch(playerId, name, metadata, slotId)
end)

-- Item definition: server = { export = 'koja-lib.useItem' }
exports('useItem', function(event, item, inventory, slot, data)
    if event ~= 'usingItem' then return end

    local src = type(inventory) == 'table' and inventory.id or inventory
    local metadata
    if type(slot) == 'table' then
        metadata = slot.metadata
    else
        local ok, found = pcall(function() return exports.ox_inventory:GetSlot(src, slot) end)
        metadata = ok and found and found.metadata or nil
    end

    local name = type(item) == 'table' and item.name or item
    if handlers[name] then
        dispatch(src, name, metadata, type(slot) == 'table' and slot.slot or slot)
        return false
    end
end)

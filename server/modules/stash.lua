---Stash API.
---ox_inventory: native stashes. qb-inventory v2: live inventory backed by the `inventories` table.
---Legacy qb-inventory (ps/lj): `stashitems` table. Custom inventory: optional hooks in editable/custom/inventory_server.lua.
---Everything else (codem, jaksam, no inventory): KVP backed stash with a small built in menu.
KOJA.Server.Inv = KOJA.Server.Inv or {}
local Inv = KOJA.Server.Inv

local stashes = {}
local kvpCache = {}
local sessions = {}

local DEFAULT_TABLES = {
    ['qb-inventory'] = { table = 'inventories', identifier = 'identifier', column = 'items' },
    ['qb-legacy'] = { table = 'stashitems', identifier = 'stash', column = 'items' },
}

local function toInt(value)
    return math.floor(tonumber(value) or 0)
end

local function safe(fn)
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

-- Optional stash hook from CustomInventory.Server (only when Config.Inventory = 'custom').
local function customHook(hook)
    if Inv.Name() ~= 'custom' then return nil end
    local inv = CustomInventory and CustomInventory.Server
    local fn = inv and inv[hook]
    if type(fn) == 'function' then return fn end
    return nil
end

local function stashSettings()
    return Config.FallbackStash or {}
end

---@param id string # Stash identifier
---@param label string|nil # Stash label
---@param slots number|nil # Slot count (default 50)
---@param weight number|nil # Max weight (default 100000)
---@param groups table|nil # ox_inventory groups { job = grade }
---@param opts table|nil # { clientOpen = true, coords = vector3, distance = 3.0 } clientOpen lets clients request this stash through KOJA.Client.OpenStash (default: server side opening only); coords/distance limit where it can be opened from
---@return boolean
KOJA.Server.RegisterStash = function(id, label, slots, weight, groups, opts)
    if not id then return false end
    id = tostring(id)
    stashes[id] = {
        label = label or id,
        slots = tonumber(slots) or 50,
        weight = tonumber(weight) or 100000,
        groups = groups,
        clientOpen = type(opts) == 'table' and opts.clientOpen == true,
        coords = type(opts) == 'table' and opts.coords or nil,
        distance = type(opts) == 'table' and tonumber(opts.distance) or nil,
    }

    if Inv.IsOx() then
        local def = stashes[id]
        return safe(function()
            exports.ox_inventory:RegisterStash(id, def.label, def.slots, def.weight, false, def.groups)
            return true
        end) == true
    end

    local hook = customHook('RegisterStash')
    if hook then
        local def = stashes[id]
        return safe(function() return hook(id, def.label, def.slots, def.weight, def.groups) end) ~= false
    end
    return true
end

local function getStashDef(id, label, slots, weight)
    id = tostring(id)
    local def = stashes[id]
    if not def or (label and label ~= def.label) or (slots and tonumber(slots) ~= def.slots) or (weight and tonumber(weight) ~= def.weight) then
        KOJA.Server.RegisterStash(id, label or (def and def.label), slots or (def and def.slots), weight or (def and def.weight), def and def.groups, { clientOpen = def and def.clientOpen, coords = def and def.coords, distance = def and def.distance })
        def = stashes[id]
    end
    return def
end

-- Database backed stash (qb-inventory v2 / legacy qb inventories) ------------------------------

local Db = {}

Db.Def = function()
    local tables = Config.StashTables or {}
    local name = Inv.Name()
    return tables[name] or DEFAULT_TABLES[name] or DEFAULT_TABLES['qb-legacy']
end

Db.Load = function(id)
    local def = Db.Def()
    local rows = safe(function()
        return MySQL.query.await(('SELECT `%s` AS items FROM `%s` WHERE `%s` = ?'):format(def.column, def.table, def.identifier), { id })
    end)
    local decoded = rows and rows[1] and rows[1].items and json.decode(rows[1].items) or {}
    local slots = {}
    for _, entry in pairs(decoded) do
        if type(entry) == 'table' and entry.name then slots[#slots + 1] = entry end
    end
    table.sort(slots, function(a, b) return (tonumber(a.slot) or 0) < (tonumber(b.slot) or 0) end)
    return slots
end

Db.Save = function(id, slots)
    local def = Db.Def()
    local payload = json.encode(slots)
    return safe(function()
        MySQL.query.await(('INSERT INTO `%s` (`%s`, `%s`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `%s` = VALUES(`%s`)'):format(def.table, def.identifier, def.column, def.column, def.column), { id, payload })
        return true
    end) == true
end

Db.Add = function(id, item, count, metadata)
    local stash = getStashDef(id)
    local slots = Db.Load(id)
    local getItems = _G.getFrameworkItems
    local shared = (type(getItems) == 'function' and getItems() or {})[item] or {}
    local hasMeta = metadata and next(metadata) ~= nil

    if not shared.unique and not hasMeta then
        for _, entry in ipairs(slots) do
            if entry.name == item and not (entry.info and next(entry.info)) then
                entry.amount = toInt(entry.amount) + count
                return Db.Save(id, slots)
            end
        end
    end

    local used = {}
    for _, entry in ipairs(slots) do used[tonumber(entry.slot) or 0] = true end
    local free
    for slot = 1, stash.slots do
        if not used[slot] then free = slot break end
    end
    if not free then return false end

    slots[#slots + 1] = {
        name = item, amount = count, info = metadata or {}, label = shared.label or item, description = shared.description or '',
        weight = shared.weight or 0, type = shared.type or 'item', unique = shared.unique or false, useable = shared.useable or false,
        image = shared.image or (item .. '.png'), shouldClose = shared.shouldClose or false, slot = free, combinable = shared.combinable,
    }
    return Db.Save(id, slots)
end

Db.Remove = function(id, item, count)
    local slots = Db.Load(id)
    local total = 0
    for _, entry in ipairs(slots) do
        if entry.name == item then total = total + toInt(entry.amount) end
    end
    if total < count then return false end

    local remaining = count
    local kept = {}
    for _, entry in ipairs(slots) do
        if entry.name == item and remaining > 0 then
            local take = math.min(remaining, toInt(entry.amount))
            entry.amount = toInt(entry.amount) - take
            remaining = remaining - take
        end
        if toInt(entry.amount) > 0 then kept[#kept + 1] = entry end
    end
    return Db.Save(id, kept)
end

-- KVP backed stash (no inventory resource) ------------------------------------------------------

local Kvp = {}

Kvp.Key = function(id)
    return (stashSettings().KvpPrefix or 'koja_stash_') .. tostring(id)
end

Kvp.Load = function(id)
    id = tostring(id)
    if kvpCache[id] then return kvpCache[id] end
    local raw = GetResourceKvpString(Kvp.Key(id))
    local items = raw and json.decode(raw) or {}
    if type(items) ~= 'table' then items = {} end
    kvpCache[id] = items
    return items
end

Kvp.Save = function(id, items)
    id = tostring(id)
    kvpCache[id] = items
    SetResourceKvp(Kvp.Key(id), json.encode(items))
    return true
end

Kvp.Add = function(id, item, count, metadata)
    local stash = getStashDef(id)
    local items = Kvp.Load(id)
    local hasMeta = metadata and next(metadata) ~= nil

    if not hasMeta then
        for _, entry in ipairs(items) do
            if entry.name == item and not (entry.metadata and next(entry.metadata)) then
                entry.count = toInt(entry.count) + count
                return Kvp.Save(id, items)
            end
        end
    end

    if #items >= stash.slots then return false end
    items[#items + 1] = { name = item, count = count, metadata = metadata or {} }
    return Kvp.Save(id, items)
end

Kvp.Remove = function(id, item, count)
    local items = Kvp.Load(id)
    local total = 0
    for _, entry in ipairs(items) do
        if entry.name == item then total = total + toInt(entry.count) end
    end
    if total < count then return false end

    local remaining = count
    local kept = {}
    for _, entry in ipairs(items) do
        if entry.name == item and remaining > 0 then
            local take = math.min(remaining, toInt(entry.count))
            entry.count = toInt(entry.count) - take
            remaining = remaining - take
        end
        if toInt(entry.count) > 0 then kept[#kept + 1] = entry end
    end
    return Kvp.Save(id, kept)
end

-- qb-inventory v2 live inventory helper -----------------------------------------------------------

local function ensureQbStashLoaded(id)
    local live = safe(function() return exports['qb-inventory']:GetInventory(id) end)
    local def = getStashDef(id)

    -- qb-inventory loads saved inventories without maxweight / slots and refuses to add items
    -- until they are set, CreateInventory fills that in for an existing inventory too.
    return safe(function()
        exports['qb-inventory']:CreateInventory(id, { label = def.label, maxweight = def.weight, slots = def.slots })
        if not live then
            local items = {}
            for _, entry in ipairs(Db.Load(id)) do
                items[tonumber(entry.slot) or (#items + 1)] = entry
            end
            exports['qb-inventory']:SetInventory(id, items)
        end
        return true
    end) == true
end

-- Public API --------------------------------------------------------------------------------------

---@param id string # Stash identifier
---@param item string # Item name
---@param count number # Amount
---@param metadata table|nil # Item metadata
---@return boolean
KOJA.Server.AddStashItem = function(id, item, count, metadata)
    count = toInt(count)
    if not id or not item or count <= 0 then return false end
    id = tostring(id)
    getStashDef(id)

    local name = Inv.Name()
    local hook = customHook('AddStashItem')
    if hook then return safe(function() return hook(id, item, count, metadata) end) == true end
    if name == 'ox_inventory' then
        return safe(function() return exports.ox_inventory:AddItem(id, item, count, metadata) end) and true or false
    end
    if name == 'qb-inventory' then
        if ensureQbStashLoaded(id) then
            local ok = safe(function() return exports['qb-inventory']:AddItem(id, item, count, false, metadata, 'koja-lib') end)
            if ok ~= nil then return ok == true end
        end
        return Db.Add(id, item, count, metadata)
    end
    if name == 'qb-legacy' then return Db.Add(id, item, count, metadata) end
    return Kvp.Add(id, item, count, metadata)
end

---@param id string # Stash identifier
---@param item string # Item name
---@param count number # Amount
---@return boolean
KOJA.Server.RemoveStashItem = function(id, item, count)
    count = toInt(count)
    if not id or not item or count <= 0 then return false end
    id = tostring(id)
    getStashDef(id)

    local name = Inv.Name()
    local hook = customHook('RemoveStashItem')
    if hook then return safe(function() return hook(id, item, count) end) == true end
    if name == 'ox_inventory' then
        return safe(function() return exports.ox_inventory:RemoveItem(id, item, count) end) and true or false
    end
    if name == 'qb-inventory' then
        if ensureQbStashLoaded(id) then
            if KOJA.Server.GetStashItemCount(id, item) < count then return false end
            local ok = safe(function() return exports['qb-inventory']:RemoveItem(id, item, count, false, 'koja-lib') end)
            if ok ~= nil then return ok == true end
        end
        return Db.Remove(id, item, count)
    end
    if name == 'qb-legacy' then return Db.Remove(id, item, count) end
    return Kvp.Remove(id, item, count)
end

---@param id string # Stash identifier
---@return table # { { name, count, metadata } }
KOJA.Server.GetStashItems = function(id)
    if not id then return {} end
    id = tostring(id)
    getStashDef(id)

    local result = {}
    local name = Inv.Name()

    local hook = customHook('GetStashItems')
    if hook then
        return safe(function() return hook(id) end) or result
    end

    if name == 'ox_inventory' then
        local items = safe(function() return exports.ox_inventory:GetInventoryItems(id) end) or {}
        for _, slot in pairs(items) do
            if slot and slot.name then result[#result + 1] = { name = slot.name, count = slot.count, metadata = slot.metadata or {} } end
        end
        return result
    end

    if name == 'qb-inventory' and ensureQbStashLoaded(id) then
        local inv = safe(function() return exports['qb-inventory']:GetInventory(id) end)
        if inv and inv.items then
            for _, slot in pairs(inv.items) do
                if slot and slot.name then result[#result + 1] = { name = slot.name, count = slot.amount or slot.count, metadata = slot.info or {} } end
            end
            return result
        end
    end

    if name == 'qb-inventory' or name == 'qb-legacy' then
        for _, slot in ipairs(Db.Load(id)) do
            result[#result + 1] = { name = slot.name, count = toInt(slot.amount), metadata = slot.info or {} }
        end
        return result
    end

    for _, entry in ipairs(Kvp.Load(id)) do
        result[#result + 1] = { name = entry.name, count = toInt(entry.count), metadata = entry.metadata or {} }
    end
    return result
end

---@param id string # Stash identifier
---@param item string # Item name
---@return number
KOJA.Server.GetStashItemCount = function(id, item)
    if Inv.IsOx() then
        local count = safe(function() return exports.ox_inventory:GetItemCount(tostring(id), item) end)
        if count then return toInt(count) end
    end
    local total = 0
    for _, entry in ipairs(KOJA.Server.GetStashItems(id)) do
        if entry.name == item then total = total + toInt(entry.count) end
    end
    return total
end

local function sendFallbackStash(src, id)
    local def = getStashDef(id)
    local stashItems = {}
    for _, entry in ipairs(KOJA.Server.GetStashItems(id)) do
        stashItems[#stashItems + 1] = { name = entry.name, count = entry.count, label = KOJA.Server.GetItemLabel(entry.name) }
    end
    TriggerClientEvent('koja:Client:FallbackStash', src, {
        id = id,
        label = def.label,
        slots = def.slots,
        used = #stashItems,
        items = stashItems,
        inventory = Inv.GetPlayerItems(src),
    })
end

---@param src number # Player ID
---@param id string # Stash identifier
---@param label string|nil # Stash label
---@param slots number|nil # Slot count
---@param weight number|nil # Max weight
---@return boolean # Whether the stash was opened
KOJA.Server.OpenStash = function(src, id, label, slots, weight)
    if not src or not id then return false end
    id = tostring(id)
    local def = getStashDef(id, label, slots, weight)
    local name = Inv.Name()

    local hook = customHook('OpenStash')
    if hook then
        return safe(function() return hook(src, id, def.label, def.slots, def.weight) end) == true
    end

    if name == 'ox_inventory' then
        return safe(function() exports.ox_inventory:forceOpenInventory(src, 'stash', id) return true end) == true
    end

    if name == 'qb-inventory' then
        return safe(function()
            exports['qb-inventory']:OpenInventory(src, id, { label = def.label, maxweight = def.weight, slots = def.slots })
            return true
        end) == true
    end

    if name == 'qb-legacy' then
        TriggerClientEvent('koja:Client:OpenLegacyStash', src, id, def.label, def.slots, def.weight)
        return true
    end

    sessions[src] = { id = id, expires = os.time() + (stashSettings().SessionSeconds or 600) }
    sendFallbackStash(src, id)
    return true
end

-- Forced opening (ox forceOpenInventory / qb OpenInventory) skips the inventory's own
-- group checks, so client requests are validated here.
local function canClientOpen(src, def)
    if type(def.groups) == 'table' and next(def.groups) then
        local job = KOJA.Server.GetJobInfo(src)
        local minGrade = def.groups[job.name]
        if minGrade == nil or (tonumber(job.grade) or 0) < (tonumber(minGrade) or 0) then return false end
    end
    if def.coords then
        local ped = GetPlayerPed(src)
        if ped <= 0 then return false end
        local c = def.coords
        if #(GetEntityCoords(ped) - vector3(c.x, c.y, c.z)) > (def.distance or 3.0) then return false end
    end
    return true
end

-- Client requested open: only stashes registered with opts.clientOpen = true are served
RegisterNetEvent('koja:Server:OpenStash', function(id)
    local src = source
    if type(id) ~= 'string' then return end
    local def = stashes[id]
    if not def or def.clientOpen ~= true then return end
    if not canClientOpen(src, def) then return end
    KOJA.Server.OpenStash(src, id)
end)

local function notify(src, desc)
    KOJA.Server.SendNotify({ source = src, title = 'Stash', desc = desc, type = 'error' })
end

RegisterNetEvent('koja:Server:StashMove', function(stashId, direction, item, amount)
    local src = source
    local session = sessions[src]
    if not session or session.id ~= tostring(stashId) or session.expires < os.time() then return end

    amount = toInt(amount)
    if type(item) ~= 'string' or amount <= 0 then return end

    if direction == 'take' then
        if KOJA.Server.GetStashItemCount(session.id, item) < amount then
            notify(src, 'Not enough items in the stash.')
        elseif not Inv.CanCarry(src, item, amount) then
            notify(src, 'You cannot carry that much.')
        elseif KOJA.Server.RemoveStashItem(session.id, item, amount) then
            if not Inv.AddItem(src, item, amount) then
                KOJA.Server.AddStashItem(session.id, item, amount)
            end
        end
    elseif direction == 'put' then
        if Inv.GetItemCount(src, item) < amount then
            notify(src, 'You do not have enough items.')
        elseif Inv.RemoveItem(src, item, amount) then
            if not KOJA.Server.AddStashItem(session.id, item, amount) then
                Inv.AddItem(src, item, amount)
                notify(src, 'The stash is full.')
            end
        end
    end

    session.expires = os.time() + (stashSettings().SessionSeconds or 600)
    sendFallbackStash(src, session.id)
end)

RegisterNetEvent('koja:Server:StashClose', function()
    sessions[source] = nil
end)

AddEventHandler('playerDropped', function()
    sessions[source] = nil
end)

---Target abstraction for ox_target / qb-target.
---options = { { name, label, icon, distance, canInteract = fn(entity) -> bool, onSelect = fn(entity) } }
KOJA.Client.Target = KOJA.Client.Target or {}
local Target = KOJA.Client.Target

local zones = {}
local entities = {}

local ICON_MAP = {
    clock = 'fas fa-clock', archive = 'fas fa-box-archive', refrigerator = 'fas fa-snowflake', ['chef-hat'] = 'fas fa-utensils',
    receipt = 'fas fa-receipt', monitor = 'fas fa-desktop', ['clipboard-list'] = 'fas fa-clipboard-list',
    ['tablet-smartphone'] = 'fas fa-tablet-screen-button', tablet = 'fas fa-tablet-screen-button', ['hand-platter'] = 'fas fa-hand-holding',
    shirt = 'fas fa-shirt', car = 'fas fa-car', ['car-front'] = 'fas fa-car', image = 'fas fa-image', armchair = 'fas fa-chair',
    chair = 'fas fa-chair', package = 'fas fa-box', box = 'fas fa-box', gem = 'fas fa-gem', music = 'fas fa-music',
    ['door-open'] = 'fas fa-door-open', ['door-closed'] = 'fas fa-door-closed', store = 'fas fa-store', users = 'fas fa-users',
    user = 'fas fa-user', ['user-round'] = 'fas fa-user', ['user-plus'] = 'fas fa-user-plus', ['user-minus'] = 'fas fa-user-minus',
    wallet = 'fas fa-wallet', truck = 'fas fa-truck', sofa = 'fas fa-couch', megaphone = 'fas fa-bullhorn',
    settings = 'fas fa-gear', ['chart-line'] = 'fas fa-chart-line', tags = 'fas fa-tags', tag = 'fas fa-tag', rocket = 'fas fa-rocket',
    ['shopping-cart'] = 'fas fa-cart-shopping', ['shopping-bag'] = 'fas fa-bag-shopping', coffee = 'fas fa-mug-hot',
    utensils = 'fas fa-utensils', wine = 'fas fa-wine-glass', beer = 'fas fa-beer-mug-empty', wrench = 'fas fa-wrench',
    hammer = 'fas fa-hammer', key = 'fas fa-key', lock = 'fas fa-lock', unlock = 'fas fa-lock-open', hand = 'fas fa-hand',
    eye = 'fas fa-eye', info = 'fas fa-circle-info', plus = 'fas fa-plus', trash = 'fas fa-trash', ['trash-2'] = 'fas fa-trash',
    x = 'fas fa-xmark', check = 'fas fa-check', tv = 'fas fa-tv', ['party-popper'] = 'fas fa-champagne-glasses',
    ['building-2'] = 'fas fa-building', building = 'fas fa-building', ['dollar-sign'] = 'fas fa-dollar-sign',
    banknote = 'fas fa-money-bill', ['credit-card'] = 'fas fa-credit-card', ['list-ordered'] = 'fas fa-list-ol',
    ['arrow-down-to-line'] = 'fas fa-arrow-down', ['arrow-up-from-line'] = 'fas fa-arrow-up', pizza = 'fas fa-pizza-slice',
    sandwich = 'fas fa-burger', burger = 'fas fa-burger', ['ice-cream'] = 'fas fa-ice-cream', cake = 'fas fa-cake-candles',
    flame = 'fas fa-fire', fire = 'fas fa-fire', star = 'fas fa-star', bell = 'fas fa-bell', ['hand-coins'] = 'fas fa-hand-holding-dollar',
    scale = 'fas fa-scale-balanced', search = 'fas fa-magnifying-glass', ['map-pin'] = 'fas fa-location-dot', phone = 'fas fa-phone',
    ['square-parking'] = 'fas fa-square-parking', ['clipboard-pen'] = 'fas fa-clipboard', ['package-open'] = 'fas fa-box-open', save = 'fas fa-floppy-disk',
}

local function started(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function detect()
    local wanted = tostring(Config.Target or 'auto'):lower()
    if wanted == 'none' or wanted == 'false' then return 'none' end
    if wanted == 'ox_target' or wanted == 'ox' then return 'ox_target' end
    if wanted == 'qb-target' or wanted == 'qb' then return 'qb-target' end
    if started('ox_target') then return 'ox_target' end
    if started('qb-target') then return 'qb-target' end
    return 'none'
end

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

-- Name is a snapshot taken at load / when a target resource starts, use Target.GetName() for the live value
Target.Name = detect()

---@return string # 'ox_target' | 'qb-target' | 'none' (resolved live)
Target.GetName = function()
    Target.Name = detect()
    return Target.Name
end

---@param icon string|nil # lucide kebab name or FontAwesome class
---@return string # FontAwesome class
Target.Icon = function(icon)
    if type(icon) ~= 'string' or icon == '' then return 'fas fa-circle' end
    if icon:find('^fa') then return icon end
    local overrides = Config.TargetIconMap or {}
    return overrides[icon] or ICON_MAP[icon] or 'fas fa-circle'
end

local function toVector(coords)
    if type(coords) == 'vector3' then return coords end
    if type(coords) == 'vector4' then return vector3(coords.x, coords.y, coords.z) end
    coords = coords or {}
    return vector3(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0)
end

local function entityArg(entity)
    if not entity or entity == 0 then return nil end
    return entity
end

local function maxDistance(options)
    local distance = 0.0
    for _, option in ipairs(options or {}) do
        distance = math.max(distance, tonumber(option.distance) or 0.0)
    end
    if distance <= 0.0 then distance = 2.0 end
    return distance
end

local function toOx(options)
    local result = {}
    for index, option in ipairs(options or {}) do
        result[#result + 1] = {
            name = option.name or ('koja_option_' .. index),
            label = option.label,
            icon = Target.Icon(option.icon),
            distance = option.distance or 2.0,
            canInteract = option.canInteract and function(entity)
                return safe(option.canInteract, entityArg(entity)) == true
            end or nil,
            onSelect = function(data)
                if option.onSelect then safe(option.onSelect, entityArg(data and data.entity)) end
            end,
        }
    end
    return result
end

local function toQb(options)
    local result = {}
    for index, option in ipairs(options or {}) do
        result[#result + 1] = {
            num = index,
            label = option.label,
            icon = Target.Icon(option.icon),
            canInteract = option.canInteract and function(entity)
                return safe(option.canInteract, entityArg(entity)) == true
            end or nil,
            action = function(entity)
                if option.onSelect then safe(option.onSelect, entityArg(entity)) end
            end,
        }
    end
    return result
end

---@param name string # Zone name (re-adding with the same name replaces the zone)
---@param coords vector3 # Center
---@param radius number # Radius
---@param options table # Target options
---@return any # Zone id or nil
Target.AddSphere = function(name, coords, radius, options)
    local provider = Target.GetName()
    if provider == 'none' or not name then return nil end
    Target.Remove(name)

    local center = toVector(coords)
    radius = tonumber(radius) or 1.5

    if provider == 'ox_target' then
        local id = safe(function()
            return exports.ox_target:addSphereZone({ name = name, coords = center, radius = radius, debug = Config.Debug, options = toOx(options) })
        end)
        if id then zones[name] = { kind = 'ox', id = id } end
        return id
    end

    local done = safe(function()
        exports['qb-target']:AddCircleZone(name, center, radius, { name = name, debugPoly = Config.Debug, useZ = true },
            { options = toQb(options), distance = maxDistance(options) })
        return true
    end)
    if done then zones[name] = { kind = 'qb', id = name } end
    return done and name or nil
end

---@param name string # Zone name
---@param coords vector3 # Center
---@param size number|vector3|table # Box size
---@param heading number # Heading
---@param options table # Target options
---@return any # Zone id or nil
Target.AddBox = function(name, coords, size, heading, options)
    local provider = Target.GetName()
    if provider == 'none' or not name then return nil end
    Target.Remove(name)

    local center = toVector(coords)
    local boxSize
    if type(size) == 'number' then
        boxSize = vector3(size, size, size)
    elseif type(size) == 'table' or type(size) == 'vector3' then
        boxSize = vector3(tonumber(size.x or size[1]) or 1.0, tonumber(size.y or size[2]) or 1.0, tonumber(size.z or size[3]) or 1.0)
    else
        boxSize = vector3(1.0, 1.0, 1.0)
    end
    heading = tonumber(heading) or 0.0

    if provider == 'ox_target' then
        local id = safe(function()
            return exports.ox_target:addBoxZone({ name = name, coords = center, size = boxSize, rotation = heading, debug = Config.Debug, options = toOx(options) })
        end)
        if id then zones[name] = { kind = 'ox', id = id } end
        return id
    end

    local done = safe(function()
        exports['qb-target']:AddBoxZone(name, center, boxSize.x, boxSize.y, {
            name = name, heading = heading, debugPoly = Config.Debug,
            minZ = center.z - boxSize.z / 2, maxZ = center.z + boxSize.z / 2,
        }, { options = toQb(options), distance = maxDistance(options) })
        return true
    end)
    if done then zones[name] = { kind = 'qb', id = name } end
    return done and name or nil
end

---@param name string # Zone name
Target.Remove = function(name)
    local zone = name and zones[name]
    if not zone then return end
    zones[name] = nil
    if zone.kind == 'ox' then
        safe(function() exports.ox_target:removeZone(zone.id) end)
    else
        safe(function() exports['qb-target']:RemoveZone(zone.id) end)
    end
end

---@param entity number # Entity handle
---@param options table # Target options
---@return boolean|nil
Target.AddLocalEntity = function(entity, options)
    local provider = Target.GetName()
    if provider == 'none' or not entity or entity == 0 then return nil end

    local store = entities[entity] or {}
    for _, option in ipairs(options or {}) do
        if option.name then store[option.name] = option.label end
    end
    entities[entity] = store

    if provider == 'ox_target' then
        return safe(function() exports.ox_target:addLocalEntity(entity, toOx(options)) return true end)
    end
    return safe(function()
        exports['qb-target']:AddTargetEntity(entity, { options = toQb(options), distance = maxDistance(options) })
        return true
    end)
end

---@param entity number # Entity handle
---@param names string|table|nil # Option name(s) to remove, nil removes everything added through AddLocalEntity
Target.RemoveLocalEntity = function(entity, names)
    local provider = Target.GetName()
    if provider == 'none' or not entity then return end

    local store = entities[entity] or {}
    local list = names and (type(names) == 'table' and names or { names }) or nil

    if provider == 'ox_target' then
        safe(function() exports.ox_target:removeLocalEntity(entity, names) end)
    else
        local labels = {}
        if list then
            for _, optionName in ipairs(list) do labels[#labels + 1] = store[optionName] or optionName end
        else
            for _, label in pairs(store) do labels[#labels + 1] = label end
        end
        safe(function() exports['qb-target']:RemoveTargetEntity(entity, #labels > 0 and labels or nil) end)
    end

    if list then
        for _, optionName in ipairs(list) do store[optionName] = nil end
        if not next(store) then entities[entity] = nil end
    else
        entities[entity] = nil
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == 'ox_target' or resourceName == 'qb-target' then
        Target.Name = detect()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for name in pairs(zones) do Target.Remove(name) end
    for entity in pairs(entities) do Target.RemoveLocalEntity(entity) end
end)

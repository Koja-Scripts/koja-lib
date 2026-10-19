---Clothing abstraction: illenium-appearance / fivem-appearance / qb-clothing / esx_skin (skinchanger).
---Outfit format (appearance style): { components = { { component_id, drawable, texture } }, props = { { prop_id, drawable, texture } } }.
---qb-clothing outfitData and esx_skin clothes tables are converted automatically.
KOJA.Client.Clothing = KOJA.Client.Clothing or {}
local Clothing = KOJA.Client.Clothing

local civilian = nil

local COMPONENT_IDS = { 1, 3, 4, 5, 6, 7, 8, 9, 10, 11 }
local PROP_IDS = { 0, 1, 2, 6, 7 }

local QB_COMPONENTS = { mask = 1, arms = 3, pants = 4, bag = 5, shoes = 6, accessory = 7, ['t-shirt'] = 8, vest = 9, decals = 10, torso2 = 11 }
local QB_PROPS = { hat = 0, glass = 1, ear = 2, watch = 6, bracelet = 7 }
local ESX_COMPONENTS = { mask = 1, arms = 3, pants = 4, bags = 5, shoes = 6, chain = 7, tshirt = 8, bproof = 9, decals = 10, torso = 11 }
local ESX_PROPS = { helmet = 0, glasses = 1, ears = 2, watches = 6, bracelets = 7 }

local function started(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function detect()
    local wanted = tostring(Config.Clothing or 'auto'):lower()
    if wanted == 'none' then return 'none' end
    if wanted == 'illenium' then return 'illenium-appearance' end
    if wanted == 'skinchanger' then return 'esx_skin' end
    if wanted ~= 'auto' then return wanted end
    if started('illenium-appearance') then return 'illenium-appearance' end
    if started('fivem-appearance') then return 'fivem-appearance' end
    if started('qb-clothing') then return 'qb-clothing' end
    if started('skinchanger') then return 'esx_skin' end
    return 'none'
end

local function isAppearance(name)
    return name == 'illenium-appearance' or name == 'fivem-appearance'
end

local function captureNatives(ped)
    local components, props = {}, {}
    for _, id in ipairs(COMPONENT_IDS) do
        components[#components + 1] = { component_id = id, drawable = GetPedDrawableVariation(ped, id), texture = GetPedTextureVariation(ped, id) }
    end
    for _, id in ipairs(PROP_IDS) do
        props[#props + 1] = { prop_id = id, drawable = GetPedPropIndex(ped, id), texture = GetPedPropTextureIndex(ped, id) }
    end
    return { model = GetEntityModel(ped), components = components, props = props }
end

local function normalize(skin)
    if type(skin) ~= 'table' then return nil end
    if skin.components or skin.props then
        return { model = skin.model, components = skin.components or {}, props = skin.props or {} }
    end

    local source = skin.outfitData or skin
    local components, props = {}, {}
    local isQb = false

    for key, id in pairs(QB_COMPONENTS) do
        local entry = source[key]
        if type(entry) == 'table' and entry.item then
            isQb = true
            components[#components + 1] = { component_id = id, drawable = tonumber(entry.item) or 0, texture = tonumber(entry.texture) or 0 }
        end
    end
    if isQb then
        for key, id in pairs(QB_PROPS) do
            local entry = source[key]
            if type(entry) == 'table' and entry.item then
                props[#props + 1] = { prop_id = id, drawable = tonumber(entry.item) or -1, texture = tonumber(entry.texture) or 0 }
            end
        end
        return { components = components, props = props }
    end

    for key, id in pairs(ESX_COMPONENTS) do
        local drawable = source[key == 'arms' and 'arms' or key .. '_1']
        if drawable ~= nil then
            local texture = source[key == 'arms' and 'arms_2' or key .. '_2']
            components[#components + 1] = { component_id = id, drawable = tonumber(drawable) or 0, texture = tonumber(texture) or 0 }
        end
    end
    for key, id in pairs(ESX_PROPS) do
        local drawable = source[key .. '_1']
        if drawable ~= nil then
            props[#props + 1] = { prop_id = id, drawable = tonumber(drawable) or -1, texture = tonumber(source[key .. '_2']) or 0 }
        end
    end

    if #components == 0 and #props == 0 then return nil end
    return { components = components, props = props }
end

local function toQb(skin)
    local outfit = {}
    for _, component in ipairs(skin.components or {}) do
        for key, id in pairs(QB_COMPONENTS) do
            if id == component.component_id then outfit[key] = { item = component.drawable, texture = component.texture } end
        end
    end
    for _, prop in ipairs(skin.props or {}) do
        for key, id in pairs(QB_PROPS) do
            if id == prop.prop_id then outfit[key] = { item = prop.drawable, texture = prop.texture } end
        end
    end
    return outfit
end

local function toEsx(skin)
    local clothes = {}
    for _, component in ipairs(skin.components or {}) do
        for key, id in pairs(ESX_COMPONENTS) do
            if id == component.component_id then
                if key == 'arms' then
                    clothes.arms = component.drawable
                    clothes.arms_2 = component.texture
                else
                    clothes[key .. '_1'] = component.drawable
                    clothes[key .. '_2'] = component.texture
                end
            end
        end
    end
    for _, prop in ipairs(skin.props or {}) do
        for key, id in pairs(ESX_PROPS) do
            if id == prop.prop_id then
                clothes[key .. '_1'] = prop.drawable
                clothes[key .. '_2'] = prop.texture
            end
        end
    end
    return clothes
end

local function applyNatives(ped, skin)
    for _, component in ipairs(skin.components or {}) do
        if component.component_id and component.component_id ~= 0 and component.component_id ~= 2 then
            SetPedComponentVariation(ped, component.component_id, component.drawable or 0, component.texture or 0, 0)
        end
    end
    for _, prop in ipairs(skin.props or {}) do
        if prop.prop_id then
            if (prop.drawable or -1) < 0 then
                ClearPedProp(ped, prop.prop_id)
            else
                SetPedPropIndex(ped, prop.prop_id, prop.drawable, prop.texture or 0, true)
            end
        end
    end
end

local function fullAppearance()
    local name = detect()
    if isAppearance(name) then
        local appearance = safe(function() return exports[name]:getPedAppearance(PlayerPedId()) end)
        if appearance then return appearance end
    end
    return captureNatives(PlayerPedId())
end

---@return table # { model, components, props }
Clothing.GetAppearance = function()
    local name = detect()
    if isAppearance(name) then
        local appearance = safe(function() return exports[name]:getPedAppearance(PlayerPedId()) end)
        if appearance and appearance.components then
            return { model = appearance.model, components = appearance.components, props = appearance.props or {} }
        end
    end
    return captureNatives(PlayerPedId())
end

---Applies an outfit (appearance / qb-clothing / esx_skin format). The current look is cached for RestoreCivilian.
---@param skin table # Outfit
---@return boolean
Clothing.ApplyOutfit = function(skin)
    local outfit = normalize(skin)
    if not outfit then return false end

    local ped = PlayerPedId()
    if not civilian then civilian = fullAppearance() end

    local name = detect()
    if isAppearance(name) then
        local done = safe(function()
            exports[name]:setPedComponents(ped, outfit.components)
            exports[name]:setPedProps(ped, outfit.props)
            return true
        end)
        if done then return true end
    elseif name == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = toQb(outfit) })
        return true
    elseif name == 'esx_skin' then
        local applied = false
        TriggerEvent('skinchanger:getSkin', function(current)
            applied = true
            TriggerEvent('skinchanger:loadClothes', current, toEsx(outfit))
        end)
        if applied then return true end
    end

    applyNatives(ped, outfit)
    return true
end

local function restoreCached()
    local cached = civilian
    if not cached then return false end

    local ped = PlayerPedId()
    local name = detect()
    if isAppearance(name) and cached.headBlend then
        local done = safe(function() exports[name]:setPedAppearance(ped, cached) return true end)
        if done then return true end
    end
    applyNatives(ped, cached)
    return true
end

---Restores the player's real clothes through the clothing resource (falls back to the cached look).
---@return boolean
Clothing.RestoreCivilian = function()
    local name = detect()
    local restored = false

    if name == 'illenium-appearance' then
        TriggerEvent('illenium-appearance:client:reloadSkin', true)
        restored = true
    elseif name == 'qb-clothing' then
        TriggerServerEvent('qb-clothes:loadPlayerSkin')
        restored = true
    elseif name == 'esx_skin' and ESX then
        restored = safe(function()
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                if skin then TriggerEvent('skinchanger:loadSkin', skin) end
            end)
            return true
        end) == true
    elseif name == 'fivem-appearance' and ESX then
        restored = safe(function()
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                if skin then exports['fivem-appearance']:setPlayerAppearance(skin) end
            end)
            return true
        end) == true
    end

    if not restored then restored = restoreCached() end
    civilian = nil
    return restored
end

local function started(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function safe(fn)
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

---@param model string|number # Model name or hash
---@param timeout number|nil # Timeout in ms (default 5000)
---@return number|nil # Model hash or nil when it could not be loaded
KOJA.Client.RequestModel = function(model, timeout)
    local hash = type(model) == 'string' and joaat(model) or model
    if not hash or not IsModelInCdimage(hash) then return nil end
    if HasModelLoaded(hash) then return hash end

    RequestModel(hash)
    local limit = GetGameTimer() + (tonumber(timeout) or 5000)
    while not HasModelLoaded(hash) do
        if GetGameTimer() > limit then return nil end
        Wait(10)
    end
    return hash
end

---@param dict string # Animation dictionary
---@param timeout number|nil # Timeout in ms (default 5000)
---@return boolean
KOJA.Client.RequestAnimDict = function(dict, timeout)
    if not dict or not DoesAnimDictExist(dict) then return false end
    if HasAnimDictLoaded(dict) then return true end

    RequestAnimDict(dict)
    local limit = GetGameTimer() + (tonumber(timeout) or 5000)
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > limit then return false end
        Wait(10)
    end
    return true
end

---@param vehicle number # Vehicle entity
---@return table # Vehicle properties
KOJA.Client.GetVehicleProperties = function(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return {} end

    if KOJA.Framework == 'esx' and ESX and ESX.Game and ESX.Game.GetVehicleProperties then
        local props = safe(function() return ESX.Game.GetVehicleProperties(vehicle) end)
        if props then return props end
    elseif KOJA.Framework == 'qb' and QBCore and QBCore.Functions and QBCore.Functions.GetVehicleProperties then
        local props = safe(function() return QBCore.Functions.GetVehicleProperties(vehicle) end)
        if props then return props end
    end

    local color1, color2 = GetVehicleColours(vehicle)
    local pearlescent, wheelColor = GetVehicleExtraColours(vehicle)
    local props = {
        model = GetEntityModel(vehicle),
        plate = (GetVehicleNumberPlateText(vehicle) or ''):gsub('^%s+', ''):gsub('%s+$', ''),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = GetVehicleBodyHealth(vehicle),
        engineHealth = GetVehicleEngineHealth(vehicle),
        tankHealth = GetVehiclePetrolTankHealth(vehicle),
        fuelLevel = GetVehicleFuelLevel(vehicle),
        dirtLevel = GetVehicleDirtLevel(vehicle),
        color1 = color1,
        color2 = color2,
        pearlescentColor = pearlescent,
        wheelColor = wheelColor,
        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        livery = GetVehicleLivery(vehicle),
        mods = {},
    }
    for i = 0, 49 do
        props.mods[i] = GetVehicleMod(vehicle, i)
    end
    return props
end

---@param vehicle number # Vehicle entity
---@param props table # Properties from GetVehicleProperties
---@return boolean
KOJA.Client.SetVehicleProperties = function(vehicle, props)
    if not vehicle or not DoesEntityExist(vehicle) or type(props) ~= 'table' then return false end

    if KOJA.Framework == 'esx' and ESX and ESX.Game and ESX.Game.SetVehicleProperties then
        if safe(function() ESX.Game.SetVehicleProperties(vehicle, props) return true end) then return true end
    elseif KOJA.Framework == 'qb' and QBCore and QBCore.Functions and QBCore.Functions.SetVehicleProperties then
        if safe(function() QBCore.Functions.SetVehicleProperties(vehicle, props) return true end) then return true end
    end

    SetVehicleModKit(vehicle, 0)
    if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
    if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
    if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
    if props.color1 and props.color2 then SetVehicleColours(vehicle, props.color1, props.color2) end
    if props.pearlescentColor and props.wheelColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor) end
    if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
    if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end
    if props.livery then SetVehicleLivery(vehicle, props.livery) end
    for index, value in pairs(props.mods or {}) do
        local i = tonumber(index)
        if i and value and value ~= -1 then SetVehicleMod(vehicle, i, value, false) end
    end
    return true
end

---@param coords vector3|nil # Search center (defaults to player position)
---@param maxDist number|nil # Maximum distance (default 5.0)
---@return number|nil, number|nil # Vehicle entity and distance
KOJA.Client.GetClosestVehicle = function(coords, maxDist)
    coords = coords or GetEntityCoords(PlayerPedId())
    maxDist = tonumber(maxDist) or 5.0

    local closest, closestDist
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        local dist = #(GetEntityCoords(vehicle) - vector3(coords.x, coords.y, coords.z))
        if dist <= maxDist and (not closestDist or dist < closestDist) then
            closest, closestDist = vehicle, dist
        end
    end
    return closest, closestDist
end

local FUEL_RESOURCES = { 'ox_fuel', 'LegacyFuel', 'cdn-fuel', 'ps-fuel', 'lc_fuel' }

local function fuelName()
    local wanted = tostring(Config.Fuel or 'auto')
    if wanted ~= 'auto' then return wanted end
    for _, name in ipairs(FUEL_RESOURCES) do
        if started(name) then return name end
    end
    return 'native'
end

---@return string # Fuel resource in use ('ox_fuel', 'LegacyFuel', ... or 'native')
KOJA.Client.GetFuelResource = fuelName

---@param vehicle number # Vehicle entity
---@param level number # 0 - 100
---@return boolean
KOJA.Client.SetFuel = function(vehicle, level)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    level = math.max(0.0, math.min(100.0, tonumber(level) or 100.0)) + 0.0

    local name = fuelName()
    if name == 'ox_fuel' then
        Entity(vehicle).state:set('fuel', level, true)
    elseif name ~= 'native' then
        safe(function() exports[name]:SetFuel(vehicle, level) end)
    end
    SetVehicleFuelLevel(vehicle, level)
    return true
end

---Best effort key giving (client side APIs of the supported key resources).
---@param vehicle number|nil # Vehicle entity
---@param plate string|nil # Plate (read from the vehicle when nil)
---@return boolean
KOJA.Client.GiveVehicleKeys = function(vehicle, plate)
    if (not plate or plate == '') and vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    if plate then plate = tostring(plate):gsub('^%s+', ''):gsub('%s+$', ''):upper() end

    local wanted = tostring(Config.VehicleKeys or 'auto')
    local name = wanted
    if wanted == 'auto' then
        name = 'none'
        for _, resource in ipairs({ 'qbx_vehiclekeys', 'qb-vehiclekeys', 'wasabi_carlock', 'mk_vehiclekeys' }) do
            if started(resource) then name = resource break end
        end
    end

    if name == 'qb-vehiclekeys' or name == 'qbx_vehiclekeys' then
        if plate then TriggerEvent('vehiclekeys:client:SetOwner', plate) end
        return plate ~= nil
    elseif name == 'wasabi_carlock' then
        return plate ~= nil and safe(function() exports.wasabi_carlock:GiveKey(plate) return true end) == true
    elseif name == 'mk_vehiclekeys' then
        return vehicle ~= nil and vehicle ~= 0 and safe(function() exports['mk_vehiclekeys']:AddKey(vehicle) return true end) == true
    end
    return false
end

RegisterNetEvent('koja:Client:GiveVehicleKeys', function(netId, plate)
    local vehicle = 0
    if netId then
        local timeout = GetGameTimer() + 3000
        while not NetworkDoesNetworkIdExist(netId) and GetGameTimer() < timeout do Wait(50) end
        if NetworkDoesNetworkIdExist(netId) then vehicle = NetToVeh(netId) end
    end
    KOJA.Client.GiveVehicleKeys(vehicle, plate)
end)

local function parseGender(value)
    if value == nil then return nil end
    local text = tostring(value):lower()
    if text == '1' or text == 'f' or text == 'female' or text == 'woman' then return 'female' end
    if text == '0' or text == 'm' or text == 'male' or text == 'man' then return 'male' end
    return nil
end

---@return string # 'male' or 'female'
KOJA.Client.GetGender = function()
    local gender
    if KOJA.Framework == 'esx' and ESX then
        local data = safe(function() return ESX.GetPlayerData() end)
        gender = data and parseGender(data.sex)
    elseif KOJA.Framework == 'qb' and QBCore then
        local data = safe(function() return QBCore.Functions.GetPlayerData() end)
        gender = data and data.charinfo and parseGender(data.charinfo.gender)
    end
    if gender then return gender end
    return GetEntityModel(PlayerPedId()) == joaat('mp_f_freemode_01') and 'female' or 'male'
end

KOJA.Client.DevTool = {}
KOJA.Client.DevTool.open = false
KOJA.Client.DevTool.allowed = false
KOJA.Client.DevTool.overlay = false
KOJA.Client.DevTool.noclip = false
KOJA.Client.DevTool.inspecting = false
KOJA.Client.DevTool.freezeTime = nil

local function settings()
    return type(Config.DevTool) == 'table' and Config.DevTool or {}
end

local function round(value, digits)
    local factor = 10 ^ (digits or 2)
    return math.floor((tonumber(value) or 0) * factor + 0.5) / factor
end

local function send(action, data)
    SendNUIMessage({ action = 'koja-lib:nui:devtool', data = { action = action, data = data } })
end

local function notify(message, kind)
    KOJA.Client.SendNotify({ title = 'Dev tool', desc = message, type = kind or 'info', time = 3000 })
end

local function entityKind(entity)
    local kinds = { [1] = 'ped', [2] = 'vehicle', [3] = 'object' }
    return kinds[GetEntityType(entity)] or 'unknown'
end

local function archetype(entity)
    local ok, name = pcall(GetEntityArchetypeName, entity)
    if ok and name and name ~= '' then return name end
    if GetEntityType(entity) == 2 then return GetDisplayNameFromVehicleModel(GetEntityModel(entity)):lower() end
    return nil
end

local function describeEntity(entity)
    local coords = GetEntityCoords(entity)
    local rotation = GetEntityRotation(entity, 2)
    local model = GetEntityModel(entity)
    local info = {
        handle = entity,
        kind = entityKind(entity),
        model = archetype(entity),
        hash = model,
        hashHex = ('0x%08X'):format(model % 0x100000000),
        coords = { x = round(coords.x), y = round(coords.y), z = round(coords.z) },
        rotation = { x = round(rotation.x), y = round(rotation.y), z = round(rotation.z) },
        heading = round(GetEntityHeading(entity)),
        networked = NetworkGetEntityIsNetworked(entity),
        netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or nil,
        health = GetEntityHealth(entity),
    }
    if info.kind == 'vehicle' then info.plate = GetVehicleNumberPlateText(entity) end
    return info
end

local function snapshot()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local street, crossing = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local hour, minute = GetClockHours(), GetClockMinutes()
    local data = {
        coords = { x = round(coords.x), y = round(coords.y), z = round(coords.z) },
        heading = round(GetEntityHeading(ped)),
        street = GetStreetNameFromHashKey(street),
        crossing = crossing ~= 0 and GetStreetNameFromHashKey(crossing) or nil,
        zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z)),
        interior = GetInteriorFromEntity(ped),
        time = ('%02d:%02d'):format(hour, minute),
        noclip = KOJA.Client.DevTool.noclip,
        overlay = KOJA.Client.DevTool.overlay,
        frozenTime = KOJA.Client.DevTool.freezeTime ~= nil,
        vehicle = nil,
    }
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        data.vehicle = {
            model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower(),
            plate = GetVehicleNumberPlateText(vehicle),
            speed = math.floor(GetEntitySpeed(vehicle) * 3.6 + 0.5),
            engine = math.floor(GetVehicleEngineHealth(vehicle) + 0.5),
            body = math.floor(GetVehicleBodyHealth(vehicle) + 0.5),
            fuel = KOJA.Client.GetFuel(vehicle),
        }
    end
    return data
end

local function drawText(text, x, y)
    SetTextFont(4)
    SetTextScale(0.36, 0.36)
    SetTextColour(235, 238, 242, 230)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function setOpen(state)
    KOJA.Client.DevTool.open = state
    SetNuiFocus(state, state)
    send(state and 'open' or 'close', state and snapshot() or nil)
    if not state then return end
    CreateThread(function()
        while KOJA.Client.DevTool.open do
            send('state', snapshot())
            Wait(250)
        end
    end)
end

local function overlayLoop()
    CreateThread(function()
        while KOJA.Client.DevTool.overlay do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            drawText(('~b~x~s~ %.2f  ~b~y~s~ %.2f  ~b~z~s~ %.2f  ~b~h~s~ %.1f'):format(coords.x, coords.y, coords.z, GetEntityHeading(ped)), 0.40, 0.012)
            Wait(0)
        end
    end)
end

local function rayFromCamera(distance)
    local rotation = GetGameplayCamRot(2)
    local origin = GetGameplayCamCoord()
    local x, z = math.rad(rotation.x), math.rad(rotation.z)
    local direction = vector3(-math.sin(z) * math.abs(math.cos(x)), math.cos(z) * math.abs(math.cos(x)), math.sin(x))
    local target = origin + direction * distance
    local handle = StartShapeTestLosProbe(origin.x, origin.y, origin.z, target.x, target.y, target.z, 30, PlayerPedId(), 4)
    local result, hit, coords, _, entity = GetShapeTestResult(handle)
    while result == 1 do
        Wait(0)
        result, hit, coords, _, entity = GetShapeTestResult(handle)
    end
    return hit == 1, coords, entity
end

local function inspect()
    if KOJA.Client.DevTool.inspecting then return end
    KOJA.Client.DevTool.inspecting = true
    SetNuiFocus(false, false)
    send('inspecting', true)
    CreateThread(function()
        local outlined = 0
        while KOJA.Client.DevTool.inspecting do
            local hit, coords, entity = rayFromCamera(60.0)
            local valid = hit and entity ~= 0 and DoesEntityExist(entity) and GetEntityType(entity) ~= 0
            if outlined ~= 0 and outlined ~= entity then
                if DoesEntityExist(outlined) then SetEntityDrawOutline(outlined, false) end
                outlined = 0
            end
            if valid and outlined ~= entity then
                SetEntityDrawOutline(entity, true)
                SetEntityDrawOutlineColor(65, 137, 229, 255)
                outlined = entity
            end
            DrawRect(0.5, 0.5, 0.003, 0.005, 255, 255, 255, 200)
            if valid then
                drawText(('%s  ~b~%s~s~   [E] copy   [Backspace] cancel'):format(entityKind(entity), archetype(entity) or GetEntityModel(entity)), 0.40, 0.93)
            elseif hit then
                drawText(('~b~%.2f, %.2f, %.2f~s~   [E] copy point   [Backspace] cancel'):format(coords.x, coords.y, coords.z), 0.40, 0.93)
            else
                drawText('Aim at something   [Backspace] cancel', 0.43, 0.93)
            end
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            if IsControlJustPressed(0, 38) and (valid or hit) then
                send('inspected', valid and describeEntity(entity) or { kind = 'point', coords = { x = round(coords.x), y = round(coords.y), z = round(coords.z) } })
                KOJA.Client.DevTool.inspecting = false
            elseif IsControlJustPressed(0, 177) then
                KOJA.Client.DevTool.inspecting = false
            end
            Wait(0)
        end
        if outlined ~= 0 and DoesEntityExist(outlined) then SetEntityDrawOutline(outlined, false) end
        send('inspecting', false)
        if KOJA.Client.DevTool.open then SetNuiFocus(true, true) end
    end)
end

local function noclipLoop()
    CreateThread(function()
        local ped = PlayerPedId()
        local entity = GetVehiclePedIsIn(ped, false)
        if entity == 0 then entity = ped end
        SetEntityCollision(entity, false, false)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        while KOJA.Client.DevTool.noclip do
            local speed = IsControlPressed(0, 21) and 2.4 or (IsControlPressed(0, 36) and 0.12 or 0.6)
            local rotation = GetGameplayCamRot(2)
            local x, z = math.rad(rotation.x), math.rad(rotation.z)
            local forward = vector3(-math.sin(z) * math.abs(math.cos(x)), math.cos(z) * math.abs(math.cos(x)), math.sin(x))
            local right = vector3(math.cos(z), math.sin(z), 0.0)
            local position = GetEntityCoords(entity)
            local move = vector3(0.0, 0.0, 0.0)
            if IsControlPressed(0, 32) then move = move + forward end
            if IsControlPressed(0, 33) then move = move - forward end
            if IsControlPressed(0, 35) then move = move + right end
            if IsControlPressed(0, 34) then move = move - right end
            if IsControlPressed(0, 44) then move = move + vector3(0.0, 0.0, 1.0) end
            if IsControlPressed(0, 38) then move = move - vector3(0.0, 0.0, 1.0) end
            position = position + move * speed
            SetEntityCoordsNoOffset(entity, position.x, position.y, position.z, true, true, true)
            SetEntityHeading(entity, rotation.z)
            drawText('Noclip   [W/A/S/D] move   [Q/E] up/down   [Shift] fast   [Ctrl] slow', 0.36, 0.95)
            Wait(0)
        end
        SetEntityCollision(entity, true, true)
        FreezeEntityPosition(entity, false)
        SetEntityInvincible(entity, false)
    end)
end

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(25) end
    return HasModelLoaded(hash) and hash or nil
end

local actions = {}

actions.teleportWaypoint = function()
    local blip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blip) then return notify('Set a waypoint first', 'error') end
    local target = GetBlipInfoIdCoord(blip)
    local ped = PlayerPedId()
    local entity = GetVehiclePedIsIn(ped, false)
    if entity == 0 then entity = ped end
    for height = 1000.0, 0.0, -25.0 do
        SetEntityCoordsNoOffset(entity, target.x, target.y, height, false, false, false)
        Wait(20)
        local found, ground = GetGroundZFor_3dCoord(target.x, target.y, height, false)
        if found then
            SetEntityCoordsNoOffset(entity, target.x, target.y, ground + 1.0, false, false, false)
            return
        end
    end
end

actions.teleportCoords = function(payload)
    local x, y, z = tonumber(payload.x), tonumber(payload.y), tonumber(payload.z)
    if not x or not y or not z then return notify('Enter valid coordinates', 'error') end
    local ped = PlayerPedId()
    local entity = GetVehiclePedIsIn(ped, false)
    if entity == 0 then entity = ped end
    SetEntityCoordsNoOffset(entity, x + 0.0, y + 0.0, z + 0.0, false, false, false)
    if tonumber(payload.h) then SetEntityHeading(entity, tonumber(payload.h) + 0.0) end
end

actions.noclip = function()
    KOJA.Client.DevTool.noclip = not KOJA.Client.DevTool.noclip
    if KOJA.Client.DevTool.noclip then
        setOpen(false)
        noclipLoop()
    end
end

actions.overlay = function()
    KOJA.Client.DevTool.overlay = not KOJA.Client.DevTool.overlay
    if KOJA.Client.DevTool.overlay then overlayLoop() end
end

actions.inspect = function()
    inspect()
end

actions.heal = function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)
end

actions.spawnVehicle = function(payload)
    local hash = loadModel(tostring(payload.model or ''):lower())
    if not hash then return notify(('Unknown vehicle model: %s'):format(tostring(payload.model)), 'error') end
    local ped = PlayerPedId()
    local current = GetVehiclePedIsIn(ped, false)
    if current ~= 0 and payload.replace ~= false then
        SetEntityAsMissionEntity(current, true, true)
        DeleteVehicle(current)
    end
    local coords = GetEntityCoords(ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleOnGroundProperly(vehicle)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    KOJA.Client.SetFuel(vehicle, 100.0)
    KOJA.Client.GiveVehicleKeys(vehicle)
end

local function currentVehicle()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then notify('Get in a vehicle first', 'error') return nil end
    return vehicle
end

actions.repairVehicle = function()
    local vehicle = currentVehicle()
    if not vehicle then return end
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
end

actions.fuelVehicle = function()
    local vehicle = currentVehicle()
    if vehicle then KOJA.Client.SetFuel(vehicle, 100.0) end
end

actions.flipVehicle = function()
    local vehicle = currentVehicle()
    if not vehicle then return end
    SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle), 2, true)
    SetVehicleOnGroundProperly(vehicle)
end

actions.deleteVehicle = function()
    local vehicle = currentVehicle()
    if not vehicle then return end
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

actions.keysVehicle = function()
    local vehicle = currentVehicle()
    if vehicle then notify(KOJA.Client.GiveVehicleKeys(vehicle) and 'Keys given' or 'No key resource found', 'info') end
end

actions.setTime = function(payload)
    local hour = math.floor(tonumber(payload.hour) or 12) % 24
    local minute = math.floor(tonumber(payload.minute) or 0) % 60
    NetworkOverrideClockTime(hour, minute, 0)
    if KOJA.Client.DevTool.freezeTime then KOJA.Client.DevTool.freezeTime = { hour, minute } end
end

actions.freezeTime = function()
    if KOJA.Client.DevTool.freezeTime then
        KOJA.Client.DevTool.freezeTime = nil
        NetworkClearClockTimeOverride()
        return
    end
    KOJA.Client.DevTool.freezeTime = { GetClockHours(), GetClockMinutes() }
    CreateThread(function()
        while KOJA.Client.DevTool.freezeTime do
            NetworkOverrideClockTime(KOJA.Client.DevTool.freezeTime[1], KOJA.Client.DevTool.freezeTime[2], 0)
            Wait(500)
        end
    end)
end

local WEATHERS = { EXTRASUNNY = true, CLEAR = true, CLOUDS = true, OVERCAST = true, RAIN = true, THUNDER = true, CLEARING = true, NEUTRAL = true, SMOG = true, FOGGY = true, SNOW = true, BLIZZARD = true, SNOWLIGHT = true, XMAS = true, HALLOWEEN = true }

actions.setWeather = function(payload)
    local weather = tostring(payload.weather or ''):upper()
    if not WEATHERS[weather] then return end
    SetWeatherTypeOvertimePersist(weather, 2.0)
    Wait(2000)
    SetWeatherTypeNowPersist(weather)
end

actions.clearArea = function()
    local coords = GetEntityCoords(PlayerPedId())
    ClearAreaOfEverything(coords.x, coords.y, coords.z, 50.0, false, false, false, false)
end

RegisterNUICallback('koja-lib:devtool:close', function(_, cb)
    setOpen(false)
    cb({})
end)

RegisterNUICallback('koja-lib:devtool:action', function(data, cb)
    cb({})
    if not KOJA.Client.DevTool.allowed or type(data) ~= 'table' then return end
    local handler = actions[data.action]
    if handler then handler(type(data.payload) == 'table' and data.payload or {}) end
end)

RegisterNetEvent('koja-lib:devtool:response', function(allowed)
    KOJA.Client.DevTool.allowed = allowed == true
    if not KOJA.Client.DevTool.allowed then return notify('You are not allowed to use the dev tool', 'error') end
    setOpen(true)
end)

CreateThread(function()
    local options = settings()
    if options.enabled == false then return end
    RegisterCommand(options.command or 'kojadev', function()
        if KOJA.Client.DevTool.noclip then
            KOJA.Client.DevTool.noclip = false
            return
        end
        if KOJA.Client.DevTool.open then return setOpen(false) end
        TriggerServerEvent('koja-lib:devtool:request')
    end, false)
    if options.key and options.key ~= '' then
        RegisterKeyMapping(options.command or 'kojadev', 'Koja dev tool', 'keyboard', options.key)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    KOJA.Client.DevTool.noclip = false
    KOJA.Client.DevTool.inspecting = false
    if KOJA.Client.DevTool.freezeTime then NetworkClearClockTimeOverride() end
end)

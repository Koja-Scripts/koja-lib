local function started(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function keysName()
    return Misc.Utils.ResolveIntegration('keys')
end

local function normalizePlate(plate)
    if not plate then return nil end
    plate = tostring(plate):gsub('^%s+', ''):gsub('%s+$', ''):upper()
    if plate == '' then return nil end
    return plate
end

---@param src number # Player ID
---@param plate string|nil # Vehicle plate
---@param netId number|nil # Vehicle network id
---@return boolean # Whether a key resource was found and asked to give the keys
KOJA.Server.GiveVehicleKeys = function(src, plate, netId)
    if not src then return false end
    plate = normalizePlate(plate)

    local name = keysName()
    if name == 'none' then return false end

    local vehicle = netId and NetworkGetEntityFromNetworkId(netId) or 0

    if name == 'qbx_vehiclekeys' and vehicle ~= 0 then
        local ok = pcall(function() exports.qbx_vehiclekeys:GiveKeys(src, vehicle, true) end)
        if ok then return true end
    elseif name == 'qb-vehiclekeys' and plate then
        -- client event vehiclekeys:client:SetOwner is marked backwards compatibility only upstream
        local ok = pcall(function() exports['qb-vehiclekeys']:GiveKeys(src, plate) end)
        if ok then return true end
    elseif name == 'wasabi_carlock' and plate then
        local ok = pcall(function() exports.wasabi_carlock:GiveKey(src, plate) end)
        if ok then return true end
    elseif name == 'MrNewbVehicleKeys' and vehicle ~= 0 then
        local ok = pcall(function() exports.MrNewbVehicleKeys:GiveKeys(src, vehicle) end)
        if ok then return true end
    end

    TriggerClientEvent('koja:Client:GiveVehicleKeys', src, netId, plate)
    return true
end

---@param src number # Player ID
---@param plate string|nil # Vehicle plate
---@param netId number|nil # Vehicle network id
---@return boolean # Whether a key resource was found and asked to remove the keys
KOJA.Server.RemoveVehicleKeys = function(src, plate, netId)
    if not src then return false end
    plate = normalizePlate(plate)

    local name = keysName()
    if name == 'none' then return false end

    local vehicle = netId and NetworkGetEntityFromNetworkId(netId) or 0

    if name == 'qbx_vehiclekeys' and vehicle ~= 0 then
        local ok = pcall(function() exports.qbx_vehiclekeys:RemoveKeys(src, vehicle, true) end)
        if ok then return true end
    elseif name == 'wasabi_carlock' and plate then
        local ok = pcall(function() exports.wasabi_carlock:RemoveKey(src, plate) end)
        if ok then return true end
    elseif name == 'MrNewbVehicleKeys' and vehicle ~= 0 then
        local ok = pcall(function() exports.MrNewbVehicleKeys:RemoveKeys(src, vehicle) end)
        if ok then return true end
    end

    TriggerClientEvent('koja:Client:RemoveVehicleKeys', src, netId, plate)
    return true
end

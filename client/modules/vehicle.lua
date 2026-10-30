---@param vehicle number # Vehicle ID
---@return boolean # Whether the vehicle is locked
KOJA.Client.isVehicleLocked = function(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    local status = GetVehicleDoorLockStatus(vehicle)
    return status ~= 0 and status ~= 1
end

---@param vehicle number # Vehicle ID
---@return boolean # Whether the vehicle lights are on
KOJA.Client.areVehicleLightsOn = function(vehicle)
    if DoesEntityExist(vehicle) then
        local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
        return lightsOn == 1 or lightsOn == true or highbeamsOn == 1 or highbeamsOn == true
    end
    return false
end

---@param vehicle number # Vehicle ID
---@return boolean # Whether the vehicle engine is on
KOJA.Client.isVehicleEngineOn = function(vehicle)
    return DoesEntityExist(vehicle) and GetIsVehicleEngineRunning(vehicle)
end

---@param vehicle number # Vehicle ID
---@return string # Type of vehicle
KOJA.Client.checkVehicleType = function(vehicle)
    local model = GetEntityModel(vehicle)
    if IsThisModelACar(model) then return "car"
    elseif IsThisModelAPlane(model) then return "plane"
    elseif IsThisModelABoat(model) then return "boat"
    elseif IsThisModelABicycle(model) then return "bicycle"
    elseif IsThisModelABike(model) then return "motorcycle"
    elseif IsThisModelAHeli(model) then return "helicopter"
    elseif IsThisModelATrain(model) then return "train"
    else return "unknown" end
end

---@param number number # Number to round
---@return number # Rounded number
KOJA.Client.RoundNumber = function(number)
    return math.floor(number + 0.5)
end

---@param vehicle number # Vehicle ID
---@return number|boolean # Fuel level or false if unavailable
KOJA.Client.GetFuel = function(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local name = KOJA.Client.GetFuelResource()
    local level
    if (name == 'ox_fuel' or name == 'Renewed-Fuel') then
        level = Entity(vehicle).state.fuel
    elseif name ~= 'native' then
        local ok, result = pcall(function() return exports[name]:GetFuel(vehicle) end)
        level = ok and tonumber(result) or nil
    end

    return KOJA.Client.RoundNumber(level or GetVehicleFuelLevel(vehicle))
end
---@param vehicle number # Vehicle ID
---@return boolean # Whether the vehicle is locked
KOJA.Client.isVehicleLocked = function(vehicle)
    return DoesEntityExist(vehicle) and GetVehicleDoorLockStatus(vehicle) ~= 1
end

---@param vehicle number # Vehicle ID
---@return boolean # Whether the vehicle lights are on
KOJA.Client.areVehicleLightsOn = function(vehicle)
    if DoesEntityExist(vehicle) then
        local lightsOn = GetVehicleLightsState(vehicle)
        return lightsOn == 1
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
    elseif IsThisModelAMotorcycle(model) then return "motorcycle"
    elseif IsThisModelAHeli(model) then return "helicopter"
    elseif IsThisModelATrain(model) then return "train"
    else return "unknown" end
end

---@param number number # Number to round
---@return number # Rounded number
KOJA.Client.RoundNumber = function(number)
    return math.round(number, 0.5)
end

---@param vehicle number # Vehicle ID
---@return number|boolean # Fuel level or false if unavailable
KOJA.Client.GetFuel = function(vehicle)
    if GetResourceState("ox_fuel") == "started" then
        return KOJA.Client.RoundNumber(Entity(vehicle).state.fuel or 0)
    elseif GetResourceState("LegacyFuel") == "started" then
        return KOJA.Client.RoundNumber(exports["LegacyFuel"]:GetFuel(vehicle))
    else
        return KOJA.Client.RoundNumber(GetVehicleFuelLevel(vehicle))
    end
end
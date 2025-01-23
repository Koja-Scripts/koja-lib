KOJA.Client.isVehicleLocked = function(vehicle)
    if DoesEntityExist(vehicle) then
        local lockStatus = GetVehicleDoorLockStatus(vehicle)
        return lockStatus ~= 1 
    end
    return false
end

KOJA.Client.areVehicleLightsOn = function(vehicle)
    if DoesEntityExist(vehicle) then
        local lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
        return lightsOn == 1
    end
    return false
end

KOJA.Client.isVehicleEngineOn = function(vehicle)
    if DoesEntityExist(vehicle) then
        return GetIsVehicleEngineRunning(vehicle)
    end
    return false
end

KOJA.Client.checkVehicleType = function(vehicle)
    local model = GetEntityModel(vehicle)

    if IsThisModelACar(model) then
        return "car"
    elseif IsThisModelAPlane(model) then
        return "plane"
    elseif IsThisModelABoat(model) then
        return "boat"
    elseif IsThisModelABicycle(model) then
        return "bicycle"
    elseif IsThisModelAMotorcycle(model) then
        return "motorcycle"
    elseif IsThisModelAHeli(model) then
        return "helicopter"
    elseif IsThisModelATrain(model) then
        return "train"
    else
        return "unknown"
    end
end

KOJA.Client.RoundNumber = function(number)
    return math.round(number, 0.5)
end

KOJA.Client.GetFuel = function(vehicle)
    if GetResourceState("ox_fuel") == "started" then
        print("Fuel Resource Detected: OX_FUEL")
        if Entity(vehicle) then
            local ent = Entity(vehicle).state.fuel or 0
            return KOJA.Client.RoundNumber(ent)
        else
            return false
        end
    elseif GetResourceState("LegacyFuel") == "started" then
        print("Fuel Resource Detected: Legacy Fuel")
        return KOJA.Client.RoundNumber(exports["LegacyFuel"]:GetFuel(vehicle))
    else
        return KOJA.Client.RoundNumber(GetVehicleFuelLevel(vehicle))
    end
end
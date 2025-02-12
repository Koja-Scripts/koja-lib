storage.playerId = PlayerId()
storage.serverId = GetPlayerServerId(storage.playerId)

function storage:set(key, value)
    if value ~= self[key] then
        TriggerEvent(('koja_lib:update:%s'):format(key), value, self[key])
        self[key] = value
        return true
    end
end

local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
local GetCurrentPedWeapon = GetCurrentPedWeapon

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        storage:set('ped', ped)

        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle > 0 then
            storage:set('vehicle', vehicle)

            if not storage.seat or GetPedInVehicleSeat(vehicle, storage.seat) ~= ped then
                for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                    if GetPedInVehicleSeat(vehicle, i) == ped then
                        storage:set('seat', i)
                        break
                    end
                end
            end
        else
            storage:set('vehicle', false)
            storage:set('seat', false)
        end

        local hasWeapon, currentWeapon = GetCurrentPedWeapon(ped, true)
        storage:set('weapon', hasWeapon and currentWeapon or false)

        Wait(100)
    end
end)

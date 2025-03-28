RegisterNetEvent('koja-lib:setDoorState')
AddEventHandler('koja-lib:setDoorState', function(index, state) 
 	Config.DoorList[index].locked = state
end)

Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, door in ipairs(Config.DoorList) do
            if not door.object then
                door.object = GetClosestObjectOfType(door.coords, 1.0, door.model, false, false, false)
            end

            if door.object and DoesEntityExist(door.object) then
                door.distanceToPlayer = #(playerCoords - door.coords)

                if door.locked and door.heading and KOJA.Client.MathRound(GetEntityHeading(door.object)) ~= door.heading then
                    SetEntityHeading(door.object, door.heading)
                end
            else
                door.distanceToPlayer = nil
            end

            if door.distanceToPlayer and door.distanceToPlayer < 50 then
                FreezeEntityPosition(door.object, door.locked)
            end
        end

        Citizen.Wait(500)
    end
end)
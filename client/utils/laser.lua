KOJA.Client.RotationToDirection = function(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

KOJA.Client.RayCastGamePlayCamera = function(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = KOJA.Client.RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, hit, coords = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return hit, coords
end

local activeLaser = false

RegisterCommand("laser", function()
    activeLaser = not activeLaser
    CreateThread(function()
        while activeLaser do
            local wait = 0
            local color = {r = 255, g = 255, b = 255, a = 200}
            local position = GetEntityCoords(PlayerPedId())
            local hit, coords = KOJA.Client.RayCastGamePlayCamera(1000.0)

            DisableControlAction(0, 200)
            DisableControlAction(0, 26)
            DisableControlAction(0, 73)

            if hit and coords.x ~= 0.0 and coords.y ~= 0.0 then
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
                local heading = GetEntityHeading(PlayerPedId())
                local reverseHeading = (heading + 180.0) % 360.0
                print(("Coords: x = %.2f, y = %.2f, z = %.2f, h = %.2f, reverseH = %.2f"):format(coords.x, coords.y, coords.z, heading, reverseHeading))
            end

            if IsDisabledControlJustReleased(0, 200) or IsDisabledControlJustReleased(0, 73) then
                activeLaser = false
            end
            Wait(wait)
        end
    end)
end, false)

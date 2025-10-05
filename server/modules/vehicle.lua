KOJA.Server.GetRandomString = function(length, charset)
    local output = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        output = output .. charset:sub(rand, rand)
    end
    return output
end

KOJA.Server.GeneratePlate = function()
    local generatedPlate

    while true do
        Citizen.Wait(0)
        generatedPlate = string.upper(KOJA.Server.GetRandomString(Config.SaveVehicleConfig.Letters, Config.SaveVehicleConfig.Charset)..Config.SaveVehicleConfig.Separator..KOJA.Server.GetRandomString(Config.SaveVehicleConfig.Numbers, Config.SaveVehicleConfig.NumberCharset))

        local exists = exports.oxmysql.scalar_async('SELECT 1 FROM owned_vehicles WHERE plate = ?', { generatedPlate })

        if not exists then
            break
        end
    end

    return generatedPlate
end
exports('GeneratePlate', KOJA.Server.GeneratePlate)

KOJA.Server.SaveVehicleToGarage = function(data)
    local xPlayer = data.player
    if KOJA.Framework == 'esx' then
        exports.oxmysql.insert(
            'INSERT INTO owned_vehicles (owner, plate, vehicle, state) VALUES (?, ?, ?, ?)',
            {
                data.identifier,
                data.vehicle.plate,
                json.encode({model = joaat(data.vehicle.name), plate = data.vehicle.plate}),
                1
            },
            function(rowsChanged)
                local data = {
                    message = string.format("**Player:** %s\n**Saved Vehicle**\n**Vehicle Model:** %s\n**License Plate:** %s\n**Price:** %s", GetPlayerName(xPlayer.source), data.vehicle.name, data.vehicle.plate, data.vehicle.price),
                    title = 'Saved Vehicle',
                    footertext = 'koja-lib'
                }
                KOJA.Server.LogMessage(data, 'main')
            end
        )
    elseif KOJA.Framework == 'qb' then
        exports.oxmysql.insert(
            'INSERT INTO player_vehicles (owner, plate, vehicle, state, garage, type, jobVehicle, jobGarage, tag, impound_data, favorite) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {
                data.identifier,
                data.vehicle.plate,
                json.encode({model = joaat(data.vehicle.name), plate = data.vehicle.plate}),
                1,
                'OUT',
                'vehicle',
                '',
                '',
                nil,
                '',
                0
            },
            function(rowsChanged)
                local data = {
                    message = string.format("**Player:** %s\n**Saved Vehicle**\n**Vehicle Model:** %s\n**License Plate:** %s\n**Price:** %s", GetPlayerName(xPlayer.source), data.vehicle.name, data.vehicle.plate, data.vehicle.price),
                    title = 'Saved Vehicle',
                    footertext = 'koja-lib'
                }
                KOJA.Server.LogMessage(data, 'main')
            end
        )
    else
        exports.oxmysql.insert(
            'INSERT INTO owned_vehicles (owner, plate, vehicle, state) VALUES (?, ?, ?, ?)',
            {
                data.identifier,
                data.vehicle.plate,
                json.encode({model = joaat(data.vehicle.name), plate = data.vehicle.plate}),
                1
            },
            function(rowsChanged)
                local data = {
                    message = string.format("**Player:** %s\n**Saved Vehicle**\n**Vehicle Model:** %s\n**License Plate:** %s\n**Price:** %s", GetPlayerName(xPlayer.source), data.vehicle.name, data.vehicle.plate, data.vehicle.price),
                    title = 'Saved Vehicle',
                    footertext = 'koja-lib'
                }
                KOJA.Server.LogMessage(data, 'main')
            end
        )
    end
end
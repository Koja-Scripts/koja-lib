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
    local plateTable = KOJA.Framework == 'qb' and 'player_vehicles' or 'owned_vehicles'

    for _ = 1, 50 do
        generatedPlate = string.upper(KOJA.Server.GetRandomString(Config.SaveVehicleConfig.Letters, Config.SaveVehicleConfig.Charset)..Config.SaveVehicleConfig.Separator..KOJA.Server.GetRandomString(Config.SaveVehicleConfig.Numbers, Config.SaveVehicleConfig.NumberCharset))

        local exists = MySQL.scalar.await(('SELECT 1 FROM %s WHERE plate = ?'):format(plateTable), { generatedPlate })

        if not exists then
            break
        end
    end

    return generatedPlate
end
exports('GeneratePlate', KOJA.Server.GeneratePlate)

KOJA.Server.SaveVehicleToGarage = function(data)
    local src = data.source or (data.player and (data.player.source or (data.player.PlayerData and data.player.PlayerData.source)))
    if KOJA.Framework == 'esx' then
        MySQL.insert(
            'INSERT INTO owned_vehicles (owner, plate, vehicle, state) VALUES (?, ?, ?, ?)',
            {
                data.identifier,
                data.vehicle.plate,
                json.encode({model = joaat(data.vehicle.name), plate = data.vehicle.plate}),
                1
            },
            function(rowsChanged)
                local data = {
                    message = string.format("**Player:** %s\n**Saved Vehicle**\n**Vehicle Model:** %s\n**License Plate:** %s\n**Price:** %s", GetPlayerName(src) or 'unknown', data.vehicle.name, data.vehicle.plate, data.vehicle.price),
                    title = 'Saved Vehicle',
                    footertext = 'koja-lib'
                }
                KOJA.Server.LogMessage(data, 'main')
            end
        )
    elseif KOJA.Framework == 'qb' then
        MySQL.insert(
            'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {
                src and GetPlayerIdentifierByType(src, 'license') or nil,
                data.identifier,
                data.vehicle.name,
                joaat(data.vehicle.name),
                json.encode({model = joaat(data.vehicle.name), plate = data.vehicle.plate}),
                data.vehicle.plate,
                data.garage or 'pillboxgarage',
                1
            },
            function(rowsChanged)
                local data = {
                    message = string.format("**Player:** %s\n**Saved Vehicle**\n**Vehicle Model:** %s\n**License Plate:** %s\n**Price:** %s", GetPlayerName(src) or 'unknown', data.vehicle.name, data.vehicle.plate, data.vehicle.price),
                    title = 'Saved Vehicle',
                    footertext = 'koja-lib'
                }
                KOJA.Server.LogMessage(data, 'main')
            end
        )
    else
        MySQL.insert(
            'INSERT INTO owned_vehicles (owner, plate, vehicle, state) VALUES (?, ?, ?, ?)',
            {
                data.identifier,
                data.vehicle.plate,
                json.encode({model = joaat(data.vehicle.name), plate = data.vehicle.plate}),
                1
            },
            function(rowsChanged)
                local data = {
                    message = string.format("**Player:** %s\n**Saved Vehicle**\n**Vehicle Model:** %s\n**License Plate:** %s\n**Price:** %s", GetPlayerName(src) or 'unknown', data.vehicle.name, data.vehicle.plate, data.vehicle.price),
                    title = 'Saved Vehicle',
                    footertext = 'koja-lib'
                }
                KOJA.Server.LogMessage(data, 'main')
            end
        )
    end
end
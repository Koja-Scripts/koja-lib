webhook = function(embed, hook)
    PerformHttpRequest(KOJA.Server.Webhooks[hook], function(err, text, headers) end, 'POST', json.encode({embeds = {embed}}), {['Content-Type'] = 'application/json'})
end

KOJA.Server.LogMessage = function(data, hook)
    local xPlayer = data.player
    local vehicle = data.vehicle
    local logMessage = string.format("**Player:** %s\n**Purchased Vehicle**\n**Vehicle Model:** %s\n**License Plate:** %s\n**Price:** %s", GetPlayerName(xPlayer.source), vehicle.name, vehicle.plate, vehicle.price)
    local embed = {
        title = "Vehicle Purchase",
        description = logMessage,
        color = 65280,
        footer = {
            text = "Vehicle System",
        },
    }
    webhook(embed, hook)
end
webhook = function(embed, hook)
    if KOJA.Server.Webhooks[hook] then
        PerformHttpRequest(KOJA.Server.Webhooks[hook], function(err, text, headers) end, 'POST', json.encode({embeds = {embed}}), {['Content-Type'] = 'application/json'})
    else
        print('[^2KOJA_LIB^7] Webhook to ^1'..hook..'^7 does not exist!')
    end
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
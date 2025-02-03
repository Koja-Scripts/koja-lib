webhook = function(embed, hook)
    if KOJA.Server.Webhooks[hook] then
        PerformHttpRequest(KOJA.Server.Webhooks[hook], function(err, text, headers) end, 'POST', json.encode({embeds = {embed}}), {['Content-Type'] = 'application/json'})
    else
        print('[^2KOJA_LIB^7] Webhook to ^1'..hook..'^7 does not exist!')
    end
end

KOJA.Server.LogMessage = function(data, hook)
    local logMessage = data.message
    local embed = {
        title = data.title,
        description = logMessage,
        color = 65280,
        footer = {
            text = data.footertext,
        },
    }
    webhook(embed, hook)
end
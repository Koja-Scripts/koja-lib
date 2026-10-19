webhook = function(embed, hook)
    local url
    if type(hook) == 'string' and hook:sub(1, 4) == 'http' then
        url = hook
    else
        url = KOJA.Server.Webhooks[hook]
    end

    if url and url ~= '' then
        PerformHttpRequest(url, function(err, text, headers) end, 'POST', json.encode({embeds = {embed}}), {['Content-Type'] = 'application/json'})
    else
        print('[^2koja-lib^7] Webhook to ^1'..tostring(hook)..'^7 does not exist!')
    end
end

KOJA.Server.LogMessage = function(data, hook)
    local logMessage = data.message
    local embed = {
        title = data.title,
        description = logMessage,
        color = data.color or 65280,
        fields = data.fields,
        footer = {
            text = data.footertext,
        },
    }
    webhook(embed, hook)
end
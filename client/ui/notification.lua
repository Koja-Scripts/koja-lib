KOJA.Client.LibNotify = function(data)
    local colors = {
        success = '#22c55e',
        warning = '#f97316', 
        error = '#ef4444',
        question = '#3b82f6',
        info = '#ffffff'
    }
    KOJA.Client.SendReactMessage('koja-lib:nui:createNotification', {
        label = data.label or data.title or 'Powiadomienie',
        tag = data.tag,
        description = data.description or data.desc or 'Wiadomość',
        color = colors[data.type] or '#ffffff',
        type = data.type or 'info',
        duration = data.duration or data.time or 5,
        position = data.position or 'top'
    })
end
exports('LibNotify', KOJA.Client.LibNotify)

RegisterNetEvent('koja-lib:nui:createNotification')
AddEventHandler('koja-lib:nui:createNotification', function(data)
    KOJA.Client.LibNotify(data)
end)

-- RegisterCommand('testnotify', function(source, args)
--     local notifyType = args[1] or 'success'
--     local position = args[2] or 'top'
--     local message = table.concat(args, ' ', 3) or 'Test notyfikacji'
    
--     local colors = {
--         success = '#22c55e',
--         warning = '#f97316', 
--         error = '#ef4444',
--         question = '#3b82f6',
--         info = '#ffffff'
--     }
    
--     KOJA.Client.LibNotify({
--         label = 'Test Notyfikacji',
--         tag = 'DEBUG',
--         description = 'Testowa notyfikacja <span class="text-green-400">' .. message .. '</span><br/>Pozycja: ' .. position,
--         color = colors[notifyType] or '#ffffff',
--         type = notifyType,
--         duration = 5,
--         position = position
--     })
-- end, false)


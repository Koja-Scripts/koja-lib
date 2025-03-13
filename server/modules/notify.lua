---@param data table # Notification data with this params:

---@param source number # Player ID
---@param type string # Notification type (e.g., 'success', 'error')
---@param icon string # Notification icon (if using customNotify)
---@param color string # Notification color (if using customNotify)
---@param title string # Notification title
---@param desc string # Notification description
---@param time number # Duration of the notification (in ms)
KOJA.Server.SendNotify = function(data)
    if Config.Notify == "esx" then
        if KOJA.Framework == "esx" then
            TriggerClientEvent("esx:ShowNotification", data.source, data.desc)
        end
    elseif Config.Notify == "qb" then
        if KOJA.Framework == "qb" then
            TriggerClientEvent("QBCore:Notify", data.source, data.title, data.type)
        end
    elseif Config.Notify == 'ox' then
        if KOJA.Framework == 'ox' then
            local duration = data.time or 5000
            TriggerClientEvent('ox_lib:notify', data.source, {title = data.title, description = data.desc, type = data.type, duration = duration})
        end
    elseif KOJA.Framework == 'custom' then
        Misc.Utils.customNotify(data)
    end
end

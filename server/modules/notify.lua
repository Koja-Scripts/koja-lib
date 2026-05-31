---@param data table # Notification data with this params:

---@param source number # Player ID
---@param type string # Notification type (e.g., 'success', 'error')
---@param icon string # Notification icon (if using customNotify)
---@param color string # Notification color (if using customNotify)
---@param title string # Notification title
---@param desc string # Notification description
---@param time number # Duration of the notification (in ms)
KOJA.Server.SendNotify = function(data)
    local backend = Config.Notify

    if backend == "esx" then
        TriggerClientEvent("esx:ShowNotification", data.source, data.desc)
    elseif backend == "qb" then
        TriggerClientEvent("QBCore:Notify", data.source, data.desc or data.title, data.type or "primary")
    elseif backend == 'ox' then
        TriggerClientEvent('ox_lib:notify', data.source, {
            title = data.title,
            description = data.desc,
            type = data.type or 'inform',
            duration = data.time or 5000
        })
    else
        Misc.Utils.customNotify(data)
    end
end

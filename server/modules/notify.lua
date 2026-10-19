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
        -- QBCore only knows primary / success / error, map the rest to primary.
        local qbTypes = { info = 'primary', warning = 'primary', question = 'primary' }
        local nType = data.type or "primary"
        TriggerClientEvent("QBCore:Notify", data.source, data.desc or data.title, qbTypes[nType] or nType, data.time)
    elseif backend == 'ox' then
        TriggerClientEvent('ox_lib:notify', data.source, {
            title = data.title,
            description = data.desc,
            type = data.type or 'inform',
            duration = data.time or 5000
        })
    elseif backend == 'lib' then
        TriggerClientEvent('koja-lib:nui:createNotification', data.source, {
            label = data.title, description = data.desc, type = data.type, duration = data.time,
        })
    else
        Misc.Utils.customNotify(data)
    end
end

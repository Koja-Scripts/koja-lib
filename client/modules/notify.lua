---@param data table # Notification data with this params:

---@param source number # Player ID
---@param type string # Notification type (e.g., 'success', 'error')
---@param icon string # Notification icon (if using customNotify)
---@param color string # Notification color (if using customNotify)
---@param title string # Notification title
---@param desc string # Notification description
---@param time number # Duration of the notification (in ms)
KOJA.Client.SendNotify = function(data)
    if Config.Notify == "esx" then
        if KOJA.Framework == "esx" then
            ESX.ShowNotification(data.desc)
        end
    elseif Config.Notify == "qb" then
        if KOJA.Framework == "qb" then
            QBCore.Functions.Notify(data.desc, "success")
        end
    elseif Config.Notify == 'ox' then
        if KOJA.Framework == 'ox' then
            lib.notify({
                title = data.title,
                description = data.desc,
                type = 'success'
            })
        end
    elseif KOJA.Framework == 'custom' then
        Misc.Utils.customNotify(data)
    end
end

KOJA.Client.ShowFreemodeMessage = function(data)
    if Config.Notify == "esx" then
        if KOJA.Framework == "esx" then
            ESX.Scaleform.ShowFreemodeMessage(data.title, data.desc, data.time or 5)
        end

    elseif Config.Notify == "qb" then
        if KOJA.Framework == "qb" then
            QBCore.Functions.Notify(data.desc, "success")
        end

    elseif Config.Notify == 'ox' then
        if KOJA.Framework == 'ox' then
            lib.notify({
                title = data.title,
                description = data.desc,
                type = 'success'
            })
        end

    elseif KOJA.Framework == 'custom' then
        Misc.Utils.customNotify(data)

    else
        local scaleform = RequestScaleformMovie("mp_big_message_freemode")

        while not HasScaleformMovieLoaded(scaleform) do
            Wait(0)
        end

        BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
        PushScaleformMovieMethodParameterString(data.title or "~y~WARNING")
        PushScaleformMovieMethodParameterString(data.desc or "No description.")
        EndScaleformMovieMethod()

        local timer = GetGameTimer() + ((data.time or 5) * 1000)
        while GetGameTimer() < timer do
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
            Wait(0)
        end

        SetScaleformMovieAsNoLongerNeeded(scaleform)
    end
end
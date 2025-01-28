KOJA.Client.SendNotify = function(data)
    if KOJA.Framework == "esx" then
        ESX.ShowNotification(data.desc)
    elseif KOJA.Framework == "qb" then
        QBCore.Functions.Notify(data.desc, "success")
    elseif KOJA.Framework == 'ox' then
        lib.notify({
            title = data.title,
            description = data.desc,
            type = 'success'
        })
    elseif KOJA.Framework == 'custom' then
        -- Custom Function to send notify
    end
end
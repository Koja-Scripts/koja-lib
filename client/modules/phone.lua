RegisterNetEvent('koja:Client:PhoneMail', function(name, mail)
    if type(mail) ~= 'table' then return end
    if name == 'qs-smartphone' or name == 'qs-smartphone-pro' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', { sender = mail.sender, subject = mail.subject, message = mail.message, button = {} })
    elseif name == 'gksphone' then
        TriggerServerEvent('gksphone:NewMail', { sender = mail.sender, image = '/html/static/img/icons/mail.png', subject = mail.subject, message = mail.message })
    end
end)

RegisterNetEvent('koja:Client:PhoneNotification', function(name, title, message)
    local shown = false
    if name == 'qs-smartphone' or name == 'qs-smartphone-pro' then
        shown = pcall(function() TriggerEvent('qs-smartphone:client:notify', { title = title, text = message, icon = './img/apps/whatsapp.png', timeout = 7000 }) end)
    elseif name == 'gksphone' then
        shown = pcall(function() exports['gksphone']:Notification({ title = title, message = message, icon = 'fas fa-bell', duration = 7000 }) end)
    end
    if not shown then KOJA.Client.SendNotify({ title = title, desc = message, type = 'info', time = 7000 }) end
end)

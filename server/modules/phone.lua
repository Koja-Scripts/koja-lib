KOJA.Server.GetPhoneResource = function()
    return Misc.Utils.ResolveIntegration('phone')
end

local function text(value, max, fallback)
    if type(value) ~= 'string' or value == '' then return fallback end
    return value:sub(1, max)
end

local function notifyFallback(src, title, message)
    KOJA.Server.SendNotify({ source = src, title = title, desc = message, type = 'info', time = 7000 })
    return false
end

---@param src number # Player ID
---@param data table # { title, message, app? }
---@return boolean # Whether a phone took the notification (false means a normal notify was shown)
KOJA.Server.SendPhoneNotification = function(src, data)
    src = tonumber(src)
    if not src or not GetPlayerName(src) then return false end
    data = type(data) == 'table' and data or {}
    local title = text(data.title, 64, 'Notification')
    local message = text(data.message, 300, '')
    local name = KOJA.Server.GetPhoneResource()

    local ok = false
    if name == 'lb-phone' then
        ok = pcall(function() exports['lb-phone']:SendNotification(src, { app = data.app, title = title, content = message }) end)
    elseif name == 'qb-phone' then
        TriggerClientEvent('qb-phone:client:CustomNotification', src, title, message, 'fas fa-bell', '#4189e5', 7000)
        ok = true
    elseif name ~= 'none' then
        TriggerClientEvent('koja:Client:PhoneNotification', src, name, title, message)
        ok = true
    end
    if not ok then return notifyFallback(src, title, message) end
    return true
end

---@param src number # Player ID
---@param data table # { sender, subject, message }
---@return boolean # Whether a phone took the mail (false means a normal notify was shown)
KOJA.Server.SendPhoneMail = function(src, data)
    src = tonumber(src)
    if not src or not GetPlayerName(src) then return false end
    data = type(data) == 'table' and data or {}
    local mail = {
        sender = text(data.sender, 64, 'Koja Scripts'),
        subject = text(data.subject, 96, 'Message'),
        message = text(data.message, 2000, ''),
    }
    local name = KOJA.Server.GetPhoneResource()

    if name == 'qb-phone' then
        local player = KOJA.Server.GetPlayerBySource and KOJA.Server.GetPlayerBySource(src)
        local citizenid = player and player.PlayerData and player.PlayerData.citizenid
        if citizenid then
            TriggerEvent('qb-phone:server:sendNewMailToOffline', citizenid, { sender = mail.sender, subject = mail.subject, message = mail.message, button = {} })
            return true
        end
    elseif name == 'qs-smartphone' or name == 'qs-smartphone-pro' or name == 'gksphone' then
        TriggerClientEvent('koja:Client:PhoneMail', src, name, mail)
        return true
    elseif name == 'lb-phone' then
        return KOJA.Server.SendPhoneNotification(src, { app = 'Mail', title = mail.subject, message = mail.message })
    end
    return notifyFallback(src, mail.subject, mail.message)
end

exports('SendPhoneNotification', KOJA.Server.SendPhoneNotification)
exports('SendPhoneMail', KOJA.Server.SendPhoneMail)
exports('GetPhoneResource', KOJA.Server.GetPhoneResource)

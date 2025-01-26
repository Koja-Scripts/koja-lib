KOJA = {}

KOJA.Framework = Misc.Utils.GetFramework()
KOJA.Misc = Misc.Utils
KOJA.Server = {
    MySQL = {
        Async = {},
        Sync = {}
    }
}

KOJA.Server.GetPlayerBySource = function(source)
    return getPlayer(source)
end
exports('GetPlayerBySource', KOJA.Server.GetPlayerBySource)

KOJA.Server.GetPlayerIdentifier = function(source)
    return getIdentifier(source)
end
exports('GetPlayerIdentifier', KOJA.Server.GetPlayerIdentifier)

KOJA.Server.SendNotify = function(source, type, icon, color, title, desc, time)
    if not time then time = 1500 end
    if KOJA.Notify == "qb" then
        if KOJA.Framework == "qb" then
            TriggerClientEvent("QBCore:Notify", source, title, type)
        end
    elseif KOJA.Notify == "esx" then
        if KOJA.Framework== "esx" then
            TriggerClientEvent("esx:showNotification", source, title, type, time)
        end
    elseif KOJA.Notify == "ox" then
        if KOJA.Framework == "ox" then
            TriggerClientEvent('ox_lib:notify', source, {title = title, description = desc, type = type})
        end
    elseif KOJA.Notify == "custom" then
        Misc.Utils.customNotify(source, icon, color, title, desc, time)
    end
end
exports('SendNotify', KOJA.Server.SendNotify)

KOJA.Server.GetPlayers = function()
    return GetPlayers()
end

AddEventHandler("onResourceStart", function(resource)
    local _source = source
    if resource == GetCurrentResourceName() then
        local resourceName = GetCurrentResourceName()
        local realname = 'KOJA_LIB'
        if resourceName ~= realname then
            StopResource(GetCurrentResourceName())
            local reason = 'CHANGE THE NAME OF THE SCRIPT TO: '..realname..'!'
            print(reason)
        end
    end
end)

AddEventHandler('koja:getSharedObject', function(cb)
    cb(KOJA)
end)
  
exports('getSharedObject', function()
    return KOJA
end)
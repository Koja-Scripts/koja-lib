KOJA = {}
KOJA.Framework = Misc.Utils.GetFramework()
KOJA.Misc = Misc.Utils
KOJA.Server = {
    MySQL = {
        Async = {},
        Sync = {}
    }
}
KOJA.Callbacks = {}

KOJA.Server.RegisterServerCallback = function(key, func)
    KOJA.Callbacks[key] = func
end

RegisterNetEvent("koja:Server:HandleCallback", function(key, payload)
    local src = source
    if KOJA.Callbacks[key] then
        KOJA.Callbacks[key](src, payload, function(cb)
            TriggerClientEvent("koja:Client:HandleCallback", src, key, cb)
        end)
    end
end)

KOJA.Server.TriggerCallback = function(key, source, payload, cb)
    if not cb then
        cb = function() end
    end
    if KOJA.Callbacks[key] then
        KOJA.Callbacks[key](source, payload, cb)
    end
end

KOJA.Server.GetPlayerBySource = function(source)
    return getPlayer(source)
end

KOJA.Server.GetPlayerIdentifier = function(source)
    return getCharID(source)
end

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

exports('GetPlayerBySource', KOJA.Server.GetPlayerBySource)
exports('GetPlayerIdentifier', KOJA.Server.GetPlayerIdentifier)
exports('SendNotify', KOJA.Server.SendNotify)

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
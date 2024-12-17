Koja = {}
Koja.Framework = Misc.Utils.GetFramework()
Koja.Misc = Misc.Utils
Koja.Server = {
    MySQL = {
        Async = {},
        Sync = {}
    }
}
Koja.Callbacks = {}

Koja.Server.RegisterServerCallback = function(key, func)
    Koja.Callbacks[key] = func
end

RegisterNetEvent("koja:Server:HandleCallback", function(key, payload)
    local src = source
    if Koja.Callbacks[key] then
        Koja.Callbacks[key](src, payload, function(cb)
            TriggerClientEvent("koja:Client:HandleCallback", src, key, cb)
        end)
    end
end)

Koja.Server.TriggerCallback = function(key, source, payload, cb)
    if not cb then
        cb = function() end
    end
    if Koja.Callbacks[key] then
        Koja.Callbacks[key](source, payload, cb)
    end
end

Koja.Server.GetPlayerBySource = function(source)
    if Koja.Framework == "esx" then
        return getPlayer(source)
    elseif Koja.Framework == "qb" then
        return getPlayer(source)
    elseif Koja.Framework == "ox" then
        return getPlayer(source)
    end
end

Koja.Server.GetPlayerIdentifier = function(source)
    if Koja.Framework == "esx" then
        return getCharID(source)
    elseif Koja.Framework == "qb" then
        return getCharID(source)
    elseif Koja.Framework == "ox" then
        return getCharID(source)
    end
    return nil
end

Koja.Server.SendNotify = function(source, type, icon, color, title, desc, time)
    if not time then time = 1500 end
    if KOJA.Notify == "qb" then
        if Koja.Framework == "qb" then
            TriggerClientEvent("QBCore:Notify", source, title, type)
        end
    elseif KOJA.Notify == "esx" then
        if Koja.Framework== "esx" then
            TriggerClientEvent("esx:showNotification", source, title, type, time)
        end
    elseif KOJA.Notify == "ox" then
        if Koja.Framework == "ox" then
            TriggerClientEvent('ox_lib:notify', source, {title = title, description = desc, type = type})
        end
    elseif KOJA.Notify == "custom" then
        Misc.Utils.customNotify(source, icon, color, title, desc, time)
    end
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
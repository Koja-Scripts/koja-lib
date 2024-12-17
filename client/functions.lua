local translations = {}

Koja.Client.SendReactMessage = function(action, data)
    SendNUIMessage({
        action = action, data = data
    })
end

Koja.Client.GetPlayerData = function()
    if Koja.Framework == "esx" then
        return Koja.Framework.GetPlayerData()
    elseif Koja.Framework == "qb" or Koja.Framework == "qbx" then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerData()
    elseif Koja.Framework == "ox" then
        return cache.ped
    end
end


RegisterNUICallback('loadLocale', function(_, cb)
    local resource = GetCurrentResourceName()
    local locale = KOJA.Locale
    local jsonFile = LoadResourceFile(resource, ('locales/%s.json'):format(locale)) or LoadResourceFile(resource, 'locales/en.json')
    translations = json.decode(jsonFile)
    SendNUIMessage({
        action = 'setLocale',
        data = json.decode(jsonFile)
    })
    cb(true)
end)

function substituteVariables(text, variables)
    if variables then
        for varName, varValue in pairs(variables) do
            text = string.gsub(text, "%%" .. varName, tostring(varValue))
        end
    end
    return text
end

function getTranslation(key, default)
    local keys = {}
    for k in string.gmatch(key, "[^%.]+") do
        table.insert(keys, k)
    end

    local result = translations
    for _, k in ipairs(keys) do
        if result[k] then
            result = result[k]
        else
            print("Missing key: " .. key)
            return default
        end
    end

    if type(result) == "string" then
        result = string.gsub(result, "%%([%a%d_]+)", function(varName)
            return "%" .. varName
        end)
    end
    return result or default
end

function Koja.Client.SendNotify(data)
    local title = getTranslation(data.title, "Missing translate(TITLE): "..data.title)
    local desc = getTranslation(data.desc, "Missing translate(DESC): "..data.desc)
    
    desc = substituteVariables(desc, data.variables)

    if KOJA.Notify == "esx" then
        if Koja.Framework == "esx" then
            Koja.Framework.ShowNotification(title, "success", data.time)
        end
    elseif KOJA.Notify == "qb" then
        if Koja.Framework == "qb" then
            Koja.Framework.Functions.Notify(title, "success")
        end
    elseif KOJA.Notify == "ox" then
        lib.notify({
            position = 'top',
            title = title,
            description = desc or "", 
        })
    elseif KOJA.Notify == "custom" then
        Misc.Utils.customNotify(nil, icon, color, title, desc, data.time)
    end
end
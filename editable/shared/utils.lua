Misc = {}
Misc.Utils = {}

Misc.Utils.GetFramework = function()
    local frameworks = {
        ['es_extended'] = 'esx',
        ['qb-core']  = 'qb',
        ['ox_core'] = 'ox'
    }

    for framework, id in pairs(frameworks) do
        if GetResourceState(framework) == 'started' then
            if framework == 'es_extended' then
                return id
            elseif framework == 'qb-core' or framework == 'qbx_core' then
                return id
            elseif framework == 'ox_core' then
                return id
            end
        end
    end
    return 'custom'
end

Misc.Utils.splitId = function(str)
    local output
    for s in string.gmatch(str, "([^:]+)") do
        output = s
    end
    return output
end

Misc.Utils.percent = function(value, max)
    if not max or max == 0 then
        return 0
    end
    local percentage = (value * 100) / max
    return percentage > 100 and 100 or percentage < 0 and 0 or percentage
end

Misc.Utils.extractDiscordIdentifier = function(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "discord") then
            return Misc.Utils.splitId(id)
        end
    end
end

Misc.Utils.customNotify = function(source, type, icon, color, title, desc, time)
    if source and source > 0 then -- server

    else -- client

    end
end

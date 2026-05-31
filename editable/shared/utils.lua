Misc = {}
Misc.Utils = {}

---@return string # 'esx' | 'qb' | 'custom'
Misc.Utils.GetFramework = function()
    local override = Config and Config.Framework

    if override and override ~= '' and override ~= 'auto' then
        return override
    end

    -- Ordered detection. qbx_core ships qb-core compatibility, both map to 'qb'.
    local frameworks = {
        { resource = 'es_extended', id = 'esx' },
        { resource = 'qbx_core',    id = 'qb'  },
        { resource = 'qb-core',     id = 'qb'  },
    }

    for _, framework in ipairs(frameworks) do
        if GetResourceState(framework.resource) == 'started' then
            return framework.id
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

Misc.Utils.customNotify = function(data)
    if data.source and data.source > 0 then
        -- Server side
    else
        -- Client side
    end
end

local function settings()
    return type(Config.DevTool) == 'table' and Config.DevTool or {}
end

KOJA.Server.CanUseDevTool = function(src)
    local options = settings()
    if options.enabled == false then return false end
    return KOJA.Server.IsAdmin(src, options.groups, options.ace)
end

RegisterNetEvent('koja-lib:devtool:request', function()
    local src = source
    local allowed = KOJA.Server.CanUseDevTool(src)
    TriggerClientEvent('koja-lib:devtool:response', src, allowed == true)
end)

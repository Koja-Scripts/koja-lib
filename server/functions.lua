KOJA = {}

KOJA.Framework = Misc.Utils.GetFramework()
KOJA.Misc = Misc.Utils
KOJA.Server = {
    MySQL = {
        Async = {},
        Sync = {}
    }
}

AddEventHandler("onResourceStart", function(resource)
    local _source = source
    if resource == GetCurrentResourceName() then
        local resourceName = GetCurrentResourceName()
        local realname = 'KOJA_LIB'
        if resourceName ~= realname then
            StopResource(GetCurrentResourceName())
            KOJA.Client.Print(5, true, '[KOJA_LIB] THE NAME OF THE SCRIPT TO: '..realname..'!')
        end
    end
end)

AddEventHandler('koja:getSharedObject', function(cb)
    cb(KOJA)
end)
  
exports('getSharedObject', function()
    return KOJA
end)
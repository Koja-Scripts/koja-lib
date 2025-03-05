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
        local realname = 'koja-lib'
        if resourceName ~= realname then
            StopResource(GetCurrentResourceName())
            KOJA.Client.Print(5, true, '[koja-lib] THE NAME OF THE SCRIPT TO: '..realname..'!')
        end
    end
end)

AddEventHandler('koja:getSharedObject', function(cb)
    cb(KOJA)
end)
  
exports('getSharedObject', function()
    return KOJA
end)
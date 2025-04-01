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
    if resource == GetCurrentResourceName() then
        local expectedName = 'koja-lib'
        local actualName = GetCurrentResourceName()

        if actualName ~= expectedName then
            StopResource(actualName)
            print(string.format('^1[koja-lib]^0 CHANGE THE NAME OF THE SCRIPT TO: ^3%s^0', expectedName))
        end
    end
end)

AddEventHandler('koja:getSharedObject', function(cb)
    cb(KOJA)
end)
  
exports('getSharedObject', function()
    return KOJA
end)
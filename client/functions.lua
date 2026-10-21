KOJA = {}
KOJA.Framework = Misc.Utils.GetFramework()
KOJA.Inventory = Misc.Utils.GetInventory()
KOJA.Misc = Misc.Utils
KOJA.Client = {}

KOJA.Client.SendReactMessage = function(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

if KOJA.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif KOJA.Framework == 'qb' then
    -- Also covers qbx_core, which provides exports['qb-core'] through its bridge.
    pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
end

AddEventHandler('koja:getSharedObject', function(cb)
	cb(KOJA)
end)

exports('getSharedObject', function()
	return KOJA
end)

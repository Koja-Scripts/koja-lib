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
    pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
    if not QBCore then
        pcall(function() QBCore = exports.qbx_core:GetCoreObject() end)
    end
end

AddEventHandler('koja:getSharedObject', function(cb)
	cb(KOJA)
end)

exports('getSharedObject', function()
	return KOJA
end)

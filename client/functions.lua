KOJA = {}
KOJA.Framework = Misc.Utils.GetFramework()
KOJA.Misc = Misc.Utils
KOJA.Client = {}

if KOJA.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif KOJA.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif KOJA.Framework == 'ox' then
    player = Ox.GetPlayer()
end

AddEventHandler('koja:getSharedObject', function(cb)
	cb(KOJA)
end)

exports('getSharedObject', function()
	return KOJA
end)

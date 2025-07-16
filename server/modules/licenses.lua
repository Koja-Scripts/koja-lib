KOJA.Server.RegisterServerCallback("koja-lib:HasLicense", function(source, licenseName, cb)
    local framework = KOJA.Framework

    if framework == 'esx' then
        TriggerEvent('esx_license:getLicense', source, licenseName, function(has)
            cb(has)
        end)
    elseif framework == 'ox' then
        local player = Ox.GetPlayer(source) or exports.ox_core:GetPlayer(source)
        local allLic = player.getLicenses() or {}
        cb(allLic[licenseName] ~= nil)
    elseif framework == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local ply = QBCore.Functions.GetPlayer(source)
        local meta = ply.PlayerData.metadata.licenses or {}
        cb(meta[licenseName] == true)
    else
        cb(false)
    end
end)
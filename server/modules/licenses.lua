KOJA.Server.RegisterServerCallback("koja-lib:HasLicense", function(source, licenseName, cb)
    local framework = KOJA.Framework

    if framework == 'esx' then
        TriggerEvent('esx_license:getLicense', source, licenseName, function(has)
            cb(has)
        end)
    elseif framework == 'qb' then
        local ply = KOJA.Server.GetPlayerBySource(source)
        local meta = ply and ply.PlayerData and ply.PlayerData.metadata and ply.PlayerData.metadata.licenses or {}
        cb(meta[licenseName] == true)
    else
        cb(false)
    end
end)
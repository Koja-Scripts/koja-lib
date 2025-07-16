KOJA.Client.HasLicense = function(licenseName, cb)
    KOJA.Client.TriggerServerCallback("koja-lib:HasLicense", licenseName, function(result)
        cb(result)
    end)
end
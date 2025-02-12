KOJA.Client.GetMoney = function(data)
    KojaLib.Client.TriggerServerCallback("KOJA_LIB:GetMoney", data, function(result)
        return result
    end)
end
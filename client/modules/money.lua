KOJA.Client.GetMoney(data)
    KojaLib.Client.TriggerServerCallback("KOJA_LIB:GetMoney", data, function(result)
        return result
    end)
end
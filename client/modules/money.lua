KOJA.Client.GetMoney = function(data)
    KOJA.Client.TriggerServerCallback("KOJA_LIB:GetMoney", data, function(result)
        return result
    end)
end

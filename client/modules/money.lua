KOJA.Client.GetMoney = function()
    KOJA.Client.TriggerServerCallback("KOJA_LIB:GetMoney", data, function(result)
        return result.money, result.bank
    end)
end

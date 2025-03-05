KOJA.Client.GetMoney = function()
    KOJA.Client.TriggerServerCallback("koja-lib:GetMoney", data, function(result)
        return result.money, result.bank
    end)
end

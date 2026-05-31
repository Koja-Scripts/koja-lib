---@param cb fun(cash: number, bank: number) # Receives cash and bank balances
KOJA.Client.GetMoney = function(cb)
    KOJA.Client.TriggerServerCallback("koja-lib:GetMoney", nil, function(result)
        if cb then
            cb(result.money, result.bank)
        end
    end)
end

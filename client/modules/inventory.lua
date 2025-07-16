---@return number # Liczba określonych przedmiotów w ekwipunku
KOJA.Client.GetItemCount = function(item)
    if KOJA.Framework == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        local playerData = ESX.GetPlayerData()
        for _, inventoryItem in ipairs(playerData.inventory) do
            if inventoryItem.name == item then
                return inventoryItem.count
            end
        end
        return 0
    elseif KOJA.Framework == "qb" then
        local playerData = QBCore.Functions.GetPlayerData()
        local count = 0
        for _, inventoryItem in pairs(playerData.items) do
            if inventoryItem.name == item then
                count = inventoryItem.amount
                break
            end
        end
        return count
    elseif KOJA.Framework == "ox" then
        return exports.ox_inventory:GetItemCount(item)
    else
        return 0
    end
end
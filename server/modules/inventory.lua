---@param source number # Player ID
---@param name string # Item name
---@param count number # Amount of item
---@return boolean # Whether the item was successfully added
KOJA.Server.addInventoryItem = function(source, name, count)
    return addInventoryItem(source, name, count)
end

---@param source number # Player ID
---@param name string # Item name
---@param count number # Amount of item
---@return boolean # Whether the item was successfully added
KOJA.Server.removeInventoryItem = function(source, name, count)
    return removeInventoryItem(source, name, count)
end

KOJA.Server.getInventoryItemCount = function(source, name)
    return getInventoryItemCount(source, name)
end

KOJA.Server.GetPlayerInventory = function(src)
    local inventory = {}

    local function resourceStarted(name)
        if type(GetResourceState) == "function" then
            return GetResourceState(name) == "started"
        end
        return exports[name] ~= nil
    end

    local function safeExportCall(fn, ...)
        local ok, res = pcall(fn, ...)
        if ok then
            return res
        end
        return nil
    end

    if resourceStarted("ox_inventory") then
        local items = safeExportCall(function() return exports.ox_inventory:GetInventoryItems(src) end)
        if items then
            for _, item in pairs(items) do
                if item and item.name then
                    inventory[item.name] = item.count or 0
                end
            end
            return inventory
        end
    end

    if resourceStarted("qb-inventory") then
        local playerItems = nil
        local Player = safeExportCall(function() 
            if exports['qb-core'] then 
                return exports['qb-core']:GetPlayer(src) 
            end
            return nil
        end)
        if Player and Player.PlayerData then
            playerItems = Player.PlayerData.items or {}
        else
            local items = safeExportCall(function() 
                if exports["qb-inventory"] and exports["qb-inventory"].GetInventoryItems then 
                    return exports["qb-inventory"]:GetInventoryItems(src) 
                end
                return nil
            end)
            if items then
                playerItems = items
            end
        end

        if playerItems then
            for _, item in pairs(playerItems) do
                if item and item.name then
                    inventory[item.name] = item.amount or item.count or 0
                end
            end
            return inventory
        end
    end

    if resourceStarted("es_extended") then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            for _, item in pairs(xPlayer.getInventory()) do
                inventory[item.name] = item.count
            end
        end
        return inventory
    end

    return inventory
end
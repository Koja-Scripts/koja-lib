if not Config.CustomFramework then

    if GetResourceState('es_extended') == 'started' then     

        local ESX = exports['es_extended']:getSharedObject()

        local convertMoney = {
            ["cash"] = "money",
            ["bank"] = "bank"
        }

        GetPlayers = function()
            return ESX.GetPlayers()
        end

        getPlayer = function(src)
            return ESX.GetPlayerFromId(src)
        end

        getIdentifier = function(src)
            local Player = getPlayer(src)
            if Player then
                return Player.identifier
            else
                return nil
            end
        end

        getPlayerJob = function(src)
            local Player = getPlayer(src)
            return Player.job.name, Player.job.grade
        end

        getMoney = function(src, mtype)
            local Player = getPlayer(src)
            if not Player then return end
            mtype = convertMoney[mtype] or mtype
            local account = Player.getAccount(mtype)
            if not account then print('[ESX] Account missed, add ESX accounts for the script to work properly') end
            return Player.getAccount(mtype).money
        end

        addMoney = function(src, amount, mtype, reason)
            local mtype = convertMoney[mtype] or mtype

            local Player = getPlayer(src)
            if not Player then
                return false
            end

            Player.addAccountMoney(mtype, amount, reason)
            return true
        end

        removeMoney = function(src, amount, mtype, reason)
            local mtype = convertMoney[mtype] or mtype

            local Player = getPlayer(src)
            if not Player then
                return false
            end

            if Player.getAccount(mtype).money < amount then
                return false
            end

            Player.removeAccountMoney(mtype, amount, reason)
            return true
        end

        addInventoryItem = function(src, name, count)

            local Player = getPlayer(src)
            if not Player then
                return false
            end

            Player.addInventoryItem(name, count)

            return true
        end

        removeInventoryItem = function(src, name, count)

            local Player = getPlayer(src)
            if not Player then
                return false
            end

            Player.removeInventoryItem(name, count)

            return true
        end

    elseif GetResourceState('ox_core') == 'started' then

        GetPlayers = function()
            return Ox.GetPlayers()
        end

        getPlayer = function(id)
            return Ox.GetPlayer(id)
        end
        
        getIdentifier = function(src)
            local Player = getPlayer(src)
            if Player then
                return Player.identifier
            else
                return nil
            end
        end
        
        getPlayerJob = function(src)
            local player = getPlayer(src)
            return player.getGroup()
        end
        
        getMoney = function(src, mtype)
            if mtype == 'cash' then
                return exports.ox_inventory:GetItemCount(src, 'money')
            else
                return exports.ox_inventory:GetItemCount(src, 'money')
            end
        end

        addMoney = function(src, amount, mtype)
            if mtype == 'cash' then
                return exports.ox_inventory:AddItem(src, 'money', amount)
            else
                return
            end
        end
        
        removeMoney = function(src, amount, mtype)
            if mtype == 'cash' then
                return exports.ox_inventory:RemoveItem(src, 'money', amount)
            else
                return
            end
        end

        addInventoryItem = function(src, name, count)
            exports.ox_inventory:AddItem(src, name, count)
            return true
        end

        removeInventoryItem = function(src, name, count)
            exports.ox_inventory:RemoveItem(src, name, count)
            return true
        end

    elseif GetResourceState('qb-core') == 'started' then

        local QBCore = exports['qb-core']:GetCoreObject()

        getPlayers = function()
            return QBCore.Functions.GetPlayers()
        end

        getPlayer = function(src)
            return QBCore.Functions.GetPlayer(src)
        end

        getIdentifier = function(src)
            local Player = getPlayer(src)
            if Player then
                return Player.PlayerData.citizenid
            else
                return nil
            end
        end

        getPlayerJob = function(src)
            local player = getPlayer(src)
            return player.PlayerData.job.name, player.PlayerData.job.grade.level
        end

        getMoney = function(src, mtype)
            local player = getPlayer(src)
            if not player then return end
            return player.PlayerData.money[mtype]
        end

        addMoney = function(src, amount, mtype, reason)
            local player = getPlayer(src)
            if not player then return end

            return player.Functions.AddMoney(mtype, amount, reason or "unknown")
        end

        removeMoney = function(src, amount, mtype, reason)
            local player = getPlayer(src)
            if not player then return end

            if player.PlayerData.money[mtype] < amount then
                return
            end

            return player.Functions.RemoveMoney(mtype, amount, reason or "unknown")
        end

        addInventoryItem = function(src, name, count)
            exports['qb-inventory']:AddItem(src, name, count, false, false, 'Add inventory item')
            return true
        end

        removeInventoryItem = function(src, name, count)
            exports['qb-inventory']:RemoveItem(src, name, count, false, 'Remove inventory item')
            return true
        end

    end
else

    GetPlayers = function()
        return --
    end

    getPlayer = function(src)
        return --
    end

    getIdentifier = function(src)
        return --
    end

    getPlayerJob = function(src)
        return --
    end

    getMoney = function(src, mtype)
        return --
    end

    removeMoney = function(src, amount, mtype, reason)
        return --
    end

end

local resourceName = GetCurrentResourceName()
local manifestFile = 'fxmanifest.lua'

isResourceStarted = function(name)
    return GetResourceState(name) == 'started'
end

ensureEntries = function(lines, useOx, useESX)
    local hasOx, hasESX = false, false
    local insertIdx

    for idx, line in ipairs(lines) do
        if line:match("^%s*shared_scripts%s*{") then
            insertIdx = idx + 1
        end
        if line:match("[\"']@ox_core/lib/init%.lua[\"']") then
            hasOx = true
        end
        if line:match("[\"']@es_extended/imports%.lua[\"']") then
            hasESX = true
        end
    end

    if insertIdx then
        if not hasOx then
            local prefix = useOx and "" or "-- "
            table.insert(lines, insertIdx, prefix .. "'@ox_core/lib/init.lua',")
        end
        if not hasESX then
            local prefix = useESX and "" or "-- "
            table.insert(lines, insertIdx + (hasOx and 1 or 0), prefix .. "'@es_extended/imports.lua',")
        end
    end

    return lines
end

processManifest = function()
    local content = LoadResourceFile(resourceName, manifestFile)
    if not content then
        print(('[%s] ❌ Failed to load %s'):format(resourceName, manifestFile))
        return
    end

    local useOx  = isResourceStarted('ox_core')
    local useESX = isResourceStarted('es_extended')

    if useOx  then print(('> ox_core detected — uncommenting init.lua')) end
    if not useOx  then print(('> ox_core not detected — commenting init.lua')) end
    if useESX then print(('> es_extended detected — uncommenting imports.lua')) end
    if not useESX then print(('> es_extended not detected — commenting imports.lua')) end

    local lines = {}
    for line in content:gmatch('[^\r\n]+') do
        if line:match("[\"']@ox_core/lib/init%.lua[\"']") then
            if useOx then
                line = line:gsub("^%s*%-%-%s*", "")
            else
                line = "-- " .. line
            end
        end
        if line:match("[\"']@es_extended/imports%.lua[\"']") then
            if useESX then
                line = line:gsub("^%s*%-%-%s*", "")
            else
                line = "-- " .. line
            end
        end
        table.insert(lines, line)
    end

    lines = ensureEntries(lines, useOx, useESX)

    local newContent = table.concat(lines, "\n")
    local success = SaveResourceFile(resourceName, manifestFile, newContent, -1)
    if success then
        print(('[%s] ✅ Successfully updated %s'):format(resourceName, manifestFile))
    else
        print(('[%s] ❌ Failed to save %s'):format(resourceName, manifestFile))
    end
end 

AddEventHandler('onResourceStart', function(resName)
    if resName == resourceName then
        processManifest()
    end
end)

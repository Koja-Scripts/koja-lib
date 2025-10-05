if not Config.CustomFramework then

    if GetResourceState('es_extended') == 'started' then     

        local ESX = exports['es_extended']:getSharedObject()

        local convertMoney = {
            ["cash"] = "money",
            ["bank"] = "bank",
            ["black"] = "black_money"
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

        getInventoryItemCount = function(src, name)

            local Player = getPlayer(src)
            if not Player then
                return false
            end

            local item = Player.getInventoryItem(name)
            if not item then 
                return 0
            end

            return item.count
        end

        getPlayerGroup = function(src)
            local Player = getPlayer(src)
            if not Player then
                return false
            end

            return Player.getGroup()
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

        getInventoryItemCount = function(src, name)
            local total = 0
            local items = exports.ox_inventory:GetInventoryItems(src)
        
            if not items then return 0 end
        
            for _, item in pairs(items) do
                if item.name == name then
                    total = total + (item.count or 0)
                end
            end
        
            return total
        end

        getPlayerGroup = function(src)
            local player = getPlayer(src)
            print(json.encode(player))
            print(player:getGroup())
            return  player:getGroup()
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

        getInventoryItemCount = function(src, name)
            local Player = getPlayer(src)
            if not Player then
                return 0
            end

            local item = Player.Functions.GetItemByName(name)
            if not item then 
                return 0
            end

            return item.count
        end

        getPlayerGroup = function(src)
            local Player = getPlayer(src)
            if not Player then
                return false
            end

            return Player.PlayerData.group
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

local resourceName = GetCurrentResourceName()
local manifestFile = 'fxmanifest.lua'

isResourceStarted = function(name)
    return GetResourceState(name) == 'started'
end

processManifest = function()
    local content = LoadResourceFile(resourceName, manifestFile)
    if not content then
        print(('[%s] Failed to load %s'):format(resourceName, manifestFile))
        return
    end

    local useOx  = isResourceStarted('ox_core')
    local useESX = isResourceStarted('es_extended')

    print(useOx and '> ox_core detected — ensuring init.lua entry' or '> ox_core not detected — removing init.lua entry')
    print(useESX and '> es_extended detected — ensuring imports.lua entry' or '> es_extended not detected — removing imports.lua entry')

    local lines = {}
    for line in content:gmatch('[^\r\n]+') do
        lines[#lines+1] = line
    end

    local startIdx, endIdx
    for i, line in ipairs(lines) do
        if line:match('^%s*shared_scripts%s*{') then
            startIdx = i
        elseif startIdx and line:match('^%s*}') then
            endIdx = i
            break
        end
    end

    if not startIdx or not endIdx then
        print(('[%s] shared_scripts block not found'):format(resourceName))
        return
    end

    local existing = {}
    for i = startIdx + 1, endIdx - 1 do
        local l = lines[i]
        if not l:find("@ox_core/lib/init.lua") and not l:find("@es_extended/imports.lua") then
            existing[#existing+1] = l
        end
    end

    local desired = {}
    if useOx  then desired[#desired+1] = "    '@ox_core/lib/init.lua'," end
    if useESX then desired[#desired+1] = "    '@es_extended/imports.lua'," end

    local currentBlock = {}
    for i = startIdx + 1, endIdx - 1 do
        currentBlock[#currentBlock+1] = lines[i]
    end

    local newBlock = {}
    for _, v in ipairs(desired)   do newBlock[#newBlock+1] = v end
    for _, v in ipairs(existing)  do newBlock[#newBlock+1] = v end

    local unchanged = #currentBlock == #newBlock
    if unchanged then
        for i = 1, #currentBlock do
            if currentBlock[i] ~= newBlock[i] then
                unchanged = false
                break
            end
        end
    end

    if unchanged then
        print(('[%s] No changes needed for %s'):format(resourceName, manifestFile))
        return
    end

    local updated = {}
    for i = 1, startIdx do updated[#updated+1] = lines[i] end
    for _, v in ipairs(newBlock)  do updated[#updated+1] = v end
    updated[#updated+1] = lines[endIdx]
    for i = endIdx + 1, #lines do updated[#updated+1] = lines[i] end

    local newContent = table.concat(updated, "\n")
    local success = SaveResourceFile(resourceName, manifestFile, newContent, -1)
    if success then
        print(('[%s] Successfully updated %s'):format(resourceName, manifestFile))
    else
        print(('[%s] Failed to save %s'):format(resourceName, manifestFile))
    end
end

AddEventHandler('onResourceStart', function(resName)
    if resName == resourceName then
        processManifest()
    end
end)

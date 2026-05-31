local FRAMEWORK = Misc.Utils.GetFramework()

if FRAMEWORK == 'esx' then

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

    getPlayerName = function(src)
        local Player = getPlayer(src)
        if not Player then return GetPlayerName(src) or '' end
        local first = (Player.get and Player.get('firstName')) or (Player.PlayerData and Player.PlayerData.firstName)
        local last = (Player.get and Player.get('lastName')) or (Player.PlayerData and Player.PlayerData.lastName)
        if first and last then return (tostring(first) .. ' ' .. tostring(last)):gsub('^%s+', ''):gsub('%s+$', '') end
        return GetPlayerName(src) or ''
    end

    getPlayerJob = function(src)
        local Player = getPlayer(src)
        if not Player then return nil end
        return Player.job.name, Player.job.grade
    end

    getMoney = function(src, mtype)
        local Player = getPlayer(src)
        if not Player then return end
        mtype = convertMoney[mtype] or mtype
        local account = Player.getAccount(mtype)
        if not account then
            print('[ESX] Account missing, add ESX accounts for the script to work properly')
            return 0
        end
        return account.money
    end

    addMoney = function(src, amount, mtype, reason)
        local mtype = convertMoney[mtype] or mtype
        local Player = getPlayer(src)
        if not Player then return false end
        Player.addAccountMoney(mtype, amount, reason)
        return true
    end

    removeMoney = function(src, amount, mtype, reason)
        local mtype = convertMoney[mtype] or mtype
        local Player = getPlayer(src)
        if not Player then return false end
        local account = Player.getAccount(mtype)
        if not account or account.money < amount then
            return false
        end
        Player.removeAccountMoney(mtype, amount, reason)
        return true
    end

    addInventoryItem = function(src, name, count)
        local Player = getPlayer(src)
        if not Player then return false end
        Player.addInventoryItem(name, count)
        return true
    end

    removeInventoryItem = function(src, name, count)
        local Player = getPlayer(src)
        if not Player then return false end
        Player.removeInventoryItem(name, count)
        return true
    end

    getInventoryItemCount = function(src, name)
        local Player = getPlayer(src)
        if not Player then return 0 end
        local item = Player.getInventoryItem(name)
        if not item then return 0 end
        return item.count
    end

    getPlayerGroup = function(src)
        local Player = getPlayer(src)
        if not Player then return false end
        return Player.getGroup()
    end

elseif FRAMEWORK == 'qb' then

    -- Resolve the QBCore object defensively so neither a missing qb-core
    -- nor qbx_core's compatibility shim crashes this file on load.
    local QBCore
    if GetResourceState('qb-core') == 'started' then
        pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
    end
    if not QBCore and GetResourceState('qbx_core') == 'started' then
        pcall(function() QBCore = exports.qbx_core:GetCoreObject() end)
    end

    GetPlayers = function()
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

    getPlayerName = function(src)
        local Player = getPlayer(src)
        if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then return GetPlayerName(src) or '' end
        local c = Player.PlayerData.charinfo
        local first = c.firstname or c.firstName
        local last = c.lastname or c.lastName
        if first and last then return (tostring(first) .. ' ' .. tostring(last)):gsub('^%s+', ''):gsub('%s+$', '') end
        return GetPlayerName(src) or ''
    end

    getPlayerJob = function(src)
        local player = getPlayer(src)
        if not player then return nil end
        local job = player.PlayerData.job
        -- qb grade is a table { level = n }, qbx may expose grade directly.
        local grade = type(job.grade) == 'table' and job.grade.level or job.grade
        return job.name, grade
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

    -- Item helpers work across every qb-core version and inventory fork that
    -- keeps the framework's Player.Functions API (qb-inventory, ps-inventory,
    -- lj-inventory, mf-inventory, ij-inventory, jacksam-inventory, codem...).
    -- Falls back to qb-inventory exports when Player.Functions is unavailable.
    addInventoryItem = function(src, name, count)
        local Player = getPlayer(src)
        if Player and Player.Functions and Player.Functions.AddItem then
            Player.Functions.AddItem(name, count)
            return true
        elseif GetResourceState('qb-inventory') == 'started' then
            exports['qb-inventory']:AddItem(src, name, count, false, false, 'koja-lib')
            return true
        end
        return false
    end

    removeInventoryItem = function(src, name, count)
        local Player = getPlayer(src)
        if Player and Player.Functions and Player.Functions.RemoveItem then
            Player.Functions.RemoveItem(name, count)
            return true
        elseif GetResourceState('qb-inventory') == 'started' then
            exports['qb-inventory']:RemoveItem(src, name, count, false, 'koja-lib')
            return true
        end
        return false
    end

    getInventoryItemCount = function(src, name)
        local Player = getPlayer(src)
        if not Player then return 0 end
        local item = Player.Functions.GetItemByName(name)
        if not item then return 0 end
        return item.amount or item.count or 0
    end

    getPlayerGroup = function(src)
        local Player = getPlayer(src)
        if not Player then return false end
        return Player.PlayerData.group
    end

else

    -- Custom framework: implementations live in editable/custom/framework_server.lua
    -- (CustomFramework.Server). Item helpers defer to CustomInventory.Server so
    -- the inventory bridge's framework-fallback still works.
    local function CF()
        return CustomFramework and CustomFramework.Server or {}
    end

    GetPlayers = function()
        local fn = CF().GetPlayers
        return fn and fn() or {}
    end

    getPlayer = function(src)
        local fn = CF().GetPlayer
        return fn and fn(src) or nil
    end

    getIdentifier = function(src)
        local fn = CF().GetIdentifier
        return fn and fn(src) or nil
    end

    getPlayerName = function(src)
        local fn = CF().GetPlayerName
        return fn and fn(src) or (GetPlayerName(src) or '')
    end

    getPlayerJob = function(src)
        local fn = CF().GetPlayerJob
        if fn then return fn(src) end
        return nil
    end

    getPlayerGroup = function(src)
        local fn = CF().GetPlayerGroup
        return fn and fn(src) or nil
    end

    getMoney = function(src, mtype)
        local fn = CF().GetMoney
        return fn and fn(src, mtype) or 0
    end

    addMoney = function(src, amount, mtype, reason)
        local fn = CF().AddMoney
        return fn and fn(src, amount, mtype, reason) or false
    end

    removeMoney = function(src, amount, mtype, reason)
        local fn = CF().RemoveMoney
        return fn and fn(src, amount, mtype, reason) or false
    end

    addInventoryItem = function(src, name, count)
        local inv = CustomInventory and CustomInventory.Server
        if inv and inv.AddItem then return inv.AddItem(src, name, count) end
        return false
    end

    removeInventoryItem = function(src, name, count)
        local inv = CustomInventory and CustomInventory.Server
        if inv and inv.RemoveItem then return inv.RemoveItem(src, name, count) end
        return false
    end

    getInventoryItemCount = function(src, name)
        local inv = CustomInventory and CustomInventory.Server
        if inv and inv.GetItemCount then return inv.GetItemCount(src, name) end
        return 0
    end

end

----------------------------------------------------------------------
-- Manifest auto-management: keeps @es_extended/imports.lua in shared_scripts
-- only when es_extended is running, so non-ESX servers don't load it.
----------------------------------------------------------------------

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

    local useESX = isResourceStarted('es_extended')
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

    -- Keep every line except the managed framework imports.
    local existing = {}
    for i = startIdx + 1, endIdx - 1 do
        local l = lines[i]
        if not l:find("@ox_core/lib/init.lua") and not l:find("@es_extended/imports.lua") then
            existing[#existing+1] = l
        end
    end

    local newBlock = {}
    if useESX then newBlock[#newBlock+1] = "    '@es_extended/imports.lua'," end
    for _, v in ipairs(existing) do newBlock[#newBlock+1] = v end

    local currentBlock = {}
    for i = startIdx + 1, endIdx - 1 do
        currentBlock[#currentBlock+1] = lines[i]
    end

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
    for _, v in ipairs(newBlock) do updated[#updated+1] = v end
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

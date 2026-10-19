-- Small private helpers used by the bridge v2 functions below
-- (jobs / identity / items / usable items / admin).
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function parseGender(value)
    if value == nil then return nil end
    local text = tostring(value):lower()
    if text == '1' or text == 'f' or text == 'female' or text == 'woman' then return 'female' end
    if text == '0' or text == 'm' or text == 'male' or text == 'man' then return 'male' end
    return nil
end

local function inList(list, value)
    if value == nil then return false end
    for _, entry in ipairs(list or {}) do
        if entry == value then return true end
    end
    return false
end

-- Default tables used for offline job changes (override with Config.OfflineJobTables).
local offlineTables = Config.OfflineJobTables or {
    esx = { table = 'users', job = 'job', grade = 'job_grade', identifier = 'identifier' },
    qb = { table = 'players', column = 'job', identifier = 'citizenid' },
}

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


    -- Jobs / identity / items (bridge v2, see server/modules/jobs.lua, items.lua, usable.lua, admin.lua)
    getJobInfo = function(src)
        local Player = getPlayer(src)
        if not Player or not Player.job then return nil end
        local job = Player.job
        return {
            name = job.name,
            label = job.label or job.name,
            grade = tonumber(job.grade) or 0,
            gradeLabel = job.grade_label or job.grade_name or '',
            onDuty = job.onDuty ~= false,
        }
    end

    setJob = function(src, job, grade)
        local Player = getPlayer(src)
        if not Player then return false end
        return safe(function() Player.setJob(job, grade) return true end) == true
    end

    setOfflineJob = function(identifier, job, grade)
        local def = offlineTables.esx
        local affected = safe(function()
            return MySQL.update.await(('UPDATE `%s` SET `%s` = ?, `%s` = ? WHERE `%s` = ?'):format(def.table, def.job, def.grade, def.identifier), { job, grade, identifier })
        end)
        return (tonumber(affected) or 0) > 0
    end

    setJobDuty = function(src, state)
        local Player = getPlayer(src)
        if not Player or not Player.job then return false end
        local job = Player.job
        -- Plain ESX has no duty flag, only forks that expose job.onDuty react to this.
        if job.onDuty == nil or job.onDuty == state then return true end
        return safe(function() Player.setJob(job.name, job.grade, state) return true end) == true
    end

    getRawJobs = function()
        local raw = safe(function() return ESX.GetJobs() end)
        if raw and next(raw) then return raw end
        local jobs = {}
        local jobRows = safe(function() return MySQL.query.await('SELECT name, label FROM jobs') end) or {}
        for _, row in ipairs(jobRows) do
            jobs[row.name] = { label = row.label, grades = {} }
        end
        local gradeRows = safe(function() return MySQL.query.await('SELECT job_name, grade, name, label, salary FROM job_grades') end) or {}
        for _, row in ipairs(gradeRows) do
            local job = jobs[row.job_name]
            if job then
                job.grades[tonumber(row.grade) or 0] = { label = row.label or row.name, payment = row.salary, isboss = row.name == 'boss' }
            end
        end
        return jobs
    end

    getSourceByIdentifier = function(identifier)
        local Player = safe(function() return ESX.GetPlayerFromIdentifier(identifier) end)
        return Player and Player.source or nil
    end

    getGender = function(src)
        local Player = getPlayer(src)
        if not Player then return nil end
        local sex = safe(function() return Player.get('sex') end) or (Player.variables and Player.variables.sex)
        local parsed = parseGender(sex)
        if parsed then return parsed end
        local rows = safe(function() return MySQL.query.await('SELECT sex FROM users WHERE identifier = ?', { Player.identifier }) end)
        return rows and rows[1] and parseGender(rows[1].sex) or nil
    end

    isGroupAdmin = function(src, groups)
        local Player = getPlayer(src)
        local group = Player and safe(function() return Player.getGroup() end)
        return inList(groups, group)
    end

    getFrameworkItems = function()
        local items = {}
        local source = ESX.Items
        if type(source) == 'table' and next(source) then
            for name, def in pairs(source) do items[name] = { label = def.label or name, weight = def.weight or 0 } end
            return items
        end
        local rows = safe(function() return MySQL.query.await('SELECT name, label, weight FROM items') end) or {}
        for _, row in ipairs(rows) do items[row.name] = { label = row.label or row.name, weight = tonumber(row.weight) or 0 } end
        return items
    end

    registerFrameworkUsable = function(name, handler)
        return safe(function()
            ESX.RegisterUsableItem(name, function(src, _, data) handler(src, data) end)
            return true
        end) == true
    end

    -- Framework native inventory (used when the active inventory has no dedicated adapter)
    fwCanCarryItem = function(src, name, count)
        local Player = getPlayer(src)
        if not Player then return false end
        if not Player.canCarryItem then return true end
        return safe(function() return Player.canCarryItem(name, count) end) ~= false
    end

    fwAddItem = function(src, name, count, metadata)
        local Player = getPlayer(src)
        if not Player then return false end
        if not fwCanCarryItem(src, name, count) then return false end
        return safe(function() Player.addInventoryItem(name, count, metadata) return true end) == true
    end

    fwRemoveItem = function(src, name, count)
        local Player = getPlayer(src)
        if not Player then return false end
        return safe(function() Player.removeInventoryItem(name, count) return true end) == true
    end

    fwGetItemsByName = function(src, name)
        local count = getInventoryItemCount(src, name)
        if type(count) == 'number' and count > 0 then
            return { { slot = nil, count = count, metadata = {} } }
        end
        return {}
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


    -- Jobs / identity / items (bridge v2, see server/modules/jobs.lua, items.lua, usable.lua, admin.lua)
    local isQbx = GetResourceState('qbx_core') == 'started'

    getJobInfo = function(src)
        local Player = getPlayer(src)
        if not Player or not Player.PlayerData or not Player.PlayerData.job then return nil end
        local job = Player.PlayerData.job
        local grade = type(job.grade) == 'table' and job.grade or { level = job.grade, name = '' }
        return {
            name = job.name,
            label = job.label or job.name,
            grade = tonumber(grade.level) or 0,
            gradeLabel = grade.name or '',
            onDuty = job.onduty == true,
        }
    end

    setJob = function(src, job, grade)
        grade = tonumber(grade) or 0
        if isQbx then
            local identifier = getIdentifier(src)
            local done = safe(function()
                exports.qbx_core:AddPlayerToJob(identifier, job, grade)
                exports.qbx_core:SetPlayerPrimaryJob(identifier, job)
                return true
            end)
            if done then return true end
        end
        local Player = getPlayer(src)
        if not Player then return false end
        return safe(function() return Player.Functions.SetJob(job, grade) ~= false end) == true
    end

    local buildJobTable = function(job, grade)
        local raw = safe(function() return isQbx and exports.qbx_core:GetJobs() or QBCore.Shared.Jobs end) or {}
        local def = raw[job] or { label = job, grades = {} }
        local gradeDef = (def.grades and (def.grades[grade] or def.grades[tostring(grade)])) or { name = tostring(grade) }
        return {
            name = job,
            label = def.label or job,
            payment = gradeDef.payment or 0,
            onduty = false,
            isboss = gradeDef.isboss or false,
            type = def.type,
            grade = { name = gradeDef.name or tostring(grade), level = grade },
        }
    end

    setOfflineJob = function(identifier, job, grade)
        grade = tonumber(grade) or 0
        if isQbx then
            local done = safe(function()
                exports.qbx_core:AddPlayerToJob(identifier, job, grade)
                exports.qbx_core:SetPlayerPrimaryJob(identifier, job)
                return true
            end)
            if done then return true end
        end
        local def = offlineTables.qb
        local payload = json.encode(buildJobTable(job, grade))
        local affected = safe(function()
            return MySQL.update.await(('UPDATE `%s` SET `%s` = ? WHERE `%s` = ?'):format(def.table, def.column, def.identifier), { payload, identifier })
        end)
        return (tonumber(affected) or 0) > 0
    end

    setJobDuty = function(src, state)
        if isQbx then
            local done = safe(function() exports.qbx_core:SetJobDuty(src, state) return true end)
            if done then return true end
        end
        local Player = getPlayer(src)
        if not Player then return false end
        local current = Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.onduty
        if current == state then return true end
        local done = safe(function() Player.Functions.SetJobDuty(state) return true end)
        if done then
            TriggerClientEvent('QBCore:Client:SetDuty', src, state)
            TriggerEvent('QBCore:Server:SetDuty', src, state)
        end
        return done == true
    end

    getRawJobs = function()
        if isQbx then
            local jobs = safe(function() return exports.qbx_core:GetJobs() end)
            if jobs then return jobs end
        end
        return QBCore and QBCore.Shared and QBCore.Shared.Jobs or {}
    end

    getSourceByIdentifier = function(identifier)
        local Player
        if isQbx then
            Player = safe(function() return exports.qbx_core:GetPlayerByCitizenId(identifier) end)
        end
        Player = Player or safe(function() return QBCore.Functions.GetPlayerByCitizenId(identifier) end)
        return Player and Player.PlayerData and Player.PlayerData.source or nil
    end

    getGender = function(src)
        local Player = getPlayer(src)
        if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then return nil end
        return parseGender(Player.PlayerData.charinfo.gender)
    end

    isGroupAdmin = function(src, groups)
        for _, group in ipairs(groups or {}) do
            if safe(function() return QBCore.Functions.HasPermission(src, group) end) then return true end
        end
        return false
    end

    getFrameworkItems = function()
        return QBCore and QBCore.Shared and QBCore.Shared.Items or {}
    end

    registerFrameworkUsable = function(name, handler)
        return safe(function()
            if isQbx then
                exports.qbx_core:CreateUseableItem(name, function(src, data) handler(src, data) end)
            else
                QBCore.Functions.CreateUseableItem(name, function(src, data) handler(src, data) end)
            end
            return true
        end) == true
    end

    -- Framework native inventory (legacy qb-inventory / ps-inventory / lj-inventory, no adapter)
    fwCanCarryItem = function(src, name, count)
        return true
    end

    fwAddItem = function(src, name, count, metadata)
        local Player = getPlayer(src)
        if not Player then return false end
        return safe(function() return Player.Functions.AddItem(name, count, false, metadata) end) == true
    end

    fwRemoveItem = function(src, name, count, metadata, slot)
        local Player = getPlayer(src)
        if not Player then return false end
        return safe(function() return Player.Functions.RemoveItem(name, count, slot) end) == true
    end

    fwGetItemsByName = function(src, name)
        local result = {}
        local Player = getPlayer(src)
        if not Player or not Player.PlayerData then return result end
        for _, entry in pairs(Player.PlayerData.items or {}) do
            if entry and entry.name == name then
                result[#result + 1] = { slot = entry.slot, count = entry.amount or entry.count, metadata = entry.info or {} }
            end
        end
        return result
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


    -- Jobs / identity / items (bridge v2). Optional hooks in CustomFramework.Server;
    -- item hooks defer to CustomInventory.Server (CanCarryItem / GetItemsByName / GetItemList).
    getJobInfo = function(src)
        local fn = CF().GetJobInfo
        return fn and fn(src) or nil
    end

    setJob = function(src, job, grade)
        local fn = CF().SetJob
        return fn and fn(src, job, grade) or false
    end

    setOfflineJob = function(identifier, job, grade)
        local fn = CF().SetOfflineJob
        return fn and fn(identifier, job, grade) or false
    end

    setJobDuty = function(src, state)
        local fn = CF().SetJobDuty
        return fn and fn(src, state) or false
    end

    getRawJobs = function()
        local fn = CF().GetJobs
        return fn and fn() or {}
    end

    getSourceByIdentifier = function(identifier)
        local fn = CF().GetSourceByIdentifier
        return fn and fn(identifier) or nil
    end

    getGender = function(src)
        local fn = CF().GetGender
        return fn and fn(src) or nil
    end

    isGroupAdmin = function(src, groups)
        local fn = CF().IsGroupAdmin
        return fn and fn(src, groups) or false
    end

    registerFrameworkUsable = function(name, handler)
        local fn = CF().RegisterUsableItem
        return fn and fn(name, handler) or false
    end

    local function CI()
        return CustomInventory and CustomInventory.Server or {}
    end

    getFrameworkItems = function()
        local fn = CI().GetItemList
        return fn and fn() or {}
    end

    fwCanCarryItem = function(src, name, count)
        local fn = CI().CanCarryItem
        if fn then return fn(src, name, count) ~= false end
        return true
    end

    fwAddItem = function(src, name, count, metadata)
        local fn = CI().AddItem
        return fn and fn(src, name, count, metadata) == true or false
    end

    fwRemoveItem = function(src, name, count, metadata, slot)
        local fn = CI().RemoveItem
        return fn and fn(src, name, count, metadata, slot) == true or false
    end

    fwGetItemsByName = function(src, name)
        local fn = CI().GetItemsByName
        return fn and fn(src, name) or {}
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

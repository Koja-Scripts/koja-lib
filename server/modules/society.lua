---Society / business account sync.
---Supported: Renewed-Banking, okokBanking, qb-banking, qb-management, esx_society (esx_addonaccount).

local function started(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function safe(fn)
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

local aliases = {
    none = 'none', ['false'] = 'none',
    ['renewed-banking'] = 'Renewed-Banking', renewed = 'Renewed-Banking',
    ['qb-banking'] = 'qb-banking', ['qb-management'] = 'qb-management',
    okokbanking = 'okokBanking', okok = 'okokBanking',
    esx_society = 'esx_society', society = 'esx_society',
}

local function bankingName()
    local wanted = aliases[tostring(Config.Banking or 'auto'):lower()]
    if wanted then return wanted end
    if started('Renewed-Banking') then return 'Renewed-Banking' end
    if started('okokBanking') then return 'okokBanking' end
    if started('qb-banking') then return 'qb-banking' end
    if started('qb-management') then return 'qb-management' end
    if started('esx_society') and started('esx_addonaccount') then return 'esx_society' end
    return 'none'
end

local function getBalance(name, account)
    if name == 'Renewed-Banking' then
        return safe(function() return exports['Renewed-Banking']:getAccountMoney(account) end)
    elseif name == 'qb-banking' then
        -- GetAccountBalance returns 0 for missing accounts, GetAccount returns nil.
        local data = safe(function() return exports['qb-banking']:GetAccount(account) end)
        return data and (tonumber(data.account_balance) or 0) or nil
    elseif name == 'qb-management' then
        return safe(function() return exports['qb-management']:GetAccount(account) end)
    elseif name == 'okokBanking' then
        return safe(function() return exports['okokBanking']:GetAccount(account) end)
    end
    return nil
end

local function ensureAccount(name, account, balance)
    if name == 'Renewed-Banking' then
        return safe(function() return exports['Renewed-Banking']:CreateJobAccount({ name = account, label = account }, balance) end)
    elseif name == 'qb-banking' then
        return safe(function() return exports['qb-banking']:CreateJobAccount(account, balance) end)
    end
    return nil
end

local function adjust(name, account, delta)
    local amount = math.abs(delta)
    local adding = delta > 0
    if name == 'Renewed-Banking' then
        return safe(function()
            if adding then return exports['Renewed-Banking']:addAccountMoney(account, amount) end
            return exports['Renewed-Banking']:removeAccountMoney(account, amount)
        end)
    elseif name == 'qb-banking' then
        return safe(function()
            if adding then return exports['qb-banking']:AddMoney(account, amount, 'koja-lib sync') end
            return exports['qb-banking']:RemoveMoney(account, amount, 'koja-lib sync')
        end)
    elseif name == 'qb-management' then
        return safe(function()
            if adding then return exports['qb-management']:AddMoney(account, amount) end
            return exports['qb-management']:RemoveMoney(account, amount)
        end)
    elseif name == 'okokBanking' then
        return safe(function()
            if adding then return exports['okokBanking']:AddMoney(account, amount) end
            return exports['okokBanking']:RemoveMoney(account, amount)
        end)
    end
    return nil
end

---Sets the balance of a job / society account in the running banking resource.
---@param account string # Society account name (job name)
---@param balance number # Balance to enforce
---@return boolean # Whether a banking resource handled the sync
KOJA.Server.SyncSocietyBalance = function(account, balance)
    local name = bankingName()
    if name == 'none' or type(account) ~= 'string' or account == '' then return false end
    balance = math.floor(tonumber(balance) or 0)

    if name == 'esx_society' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(shared)
            if shared then safe(function() shared.setMoney(balance) end) end
        end)
        return true
    end

    local current = getBalance(name, account)
    if current == nil or current == false then
        ensureAccount(name, account, balance)
        current = getBalance(name, account)
        if current == nil or current == false then return false end
    end

    current = math.floor(tonumber(type(current) == 'table' and (current.balance or current.amount or current.money) or current) or 0)
    local delta = balance - current
    if delta ~= 0 then adjust(name, account, delta) end
    return true
end

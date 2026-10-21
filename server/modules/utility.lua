-- Small gameplay helpers built on top of the bridge (jobs / money / notify).

local function playerList()
    local list = {}
    for _, entry in ipairs(KOJA.Server.GetPlayers() or {}) do
        -- GetPlayers returns ids (esx/qb) or player objects depending on framework.
        local src = tonumber(type(entry) == 'table' and entry.source or entry)
        if src then list[#list + 1] = src end
    end
    return list
end

---@param job string|table # Job name or list of job names
---@param onDuty boolean|nil # true = only players on duty
---@return number[] # Player IDs
KOJA.Server.GetPlayersByJob = function(job, onDuty)
    local wanted = {}
    for _, name in ipairs(type(job) == 'table' and job or { job }) do wanted[name] = true end

    local result = {}
    for _, src in ipairs(playerList()) do
        local info = KOJA.Server.GetJobInfo(src)
        if info and wanted[info.name] and (not onDuty or info.onDuty) then
            result[#result + 1] = src
        end
    end
    return result
end
exports('GetPlayersByJob', KOJA.Server.GetPlayersByJob)

---@param job string|table # Job name or list of job names
---@param data table # Same data as KOJA.Server.SendNotify (source is filled in)
---@param onDuty boolean|nil # true = only players on duty
---@return number # How many players were notified
KOJA.Server.NotifyJob = function(job, data, onDuty)
    local players = KOJA.Server.GetPlayersByJob(job, onDuty)
    for _, src in ipairs(players) do
        local payload = {}
        for k, v in pairs(data or {}) do payload[k] = v end
        payload.source = src
        KOJA.Server.SendNotify(payload)
    end
    return #players
end
exports('NotifyJob', KOJA.Server.NotifyJob)

---Charges a player trying the accounts in order (default cash, then bank).
---@param src number # Player ID
---@param amount number # Price
---@param accounts table|nil # e.g. { 'cash', 'bank' }
---@param reason string|nil # Reason for the removal
---@return boolean, string|nil # success, account that was charged
KOJA.Server.ChargePlayer = function(src, amount, accounts, reason)
    amount = tonumber(amount)
    if not src or not amount or amount < 0 then return false end
    if amount == 0 then return true, nil end

    for _, account in ipairs(accounts or { 'cash', 'bank' }) do
        local balance = tonumber(KOJA.Server.getMoney(src, account)) or 0
        if balance >= amount and KOJA.Server.removeMoney(src, amount, account, reason) ~= false then
            return true, account
        end
    end
    return false
end
exports('ChargePlayer', KOJA.Server.ChargePlayer)

local cooldowns = {}

-- Keyed by character identifier so reconnecting doesn't reset a player's cooldown.
local function cooldownId(key, src)
    if not src then return key end
    return ('%s:%s'):format(key, KOJA.Server.GetPlayerIdentifier(src) or src)
end

---Per-player (or global when src is nil) cooldown.
---Returns true and starts the cooldown when it is free, false + seconds left otherwise.
---@param key string # Cooldown name, e.g. 'fleeca_robbery'
---@param src number|nil # Player ID, nil for a global cooldown
---@param seconds number # Cooldown length
---@return boolean, number|nil
KOJA.Server.Cooldown = function(key, src, seconds)
    local id = cooldownId(key, src)
    local now = os.time()
    local expires = cooldowns[id]
    if expires and expires > now then
        return false, expires - now
    end
    cooldowns[id] = now + (tonumber(seconds) or 0)
    return true
end

---@param key string # Cooldown name
---@param src number|nil # Player ID, nil for a global cooldown
KOJA.Server.ResetCooldown = function(key, src)
    local id = cooldownId(key, src)
    cooldowns[id] = nil
end

exports('Cooldown', KOJA.Server.Cooldown)
exports('ResetCooldown', KOJA.Server.ResetCooldown)

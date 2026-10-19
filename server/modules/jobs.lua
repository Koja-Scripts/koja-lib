local function frameworkCall(name, ...)
    local fn = _G[name]
    if type(fn) == 'function' then
        return fn(...)
    end
    return nil
end

local jobsCache = { at = 0, data = nil }

local function normalizeGrades(grades)
    local result = {}
    for key, value in pairs(grades or {}) do
        local level = tonumber(type(value) == 'table' and value.grade or nil) or tonumber(key)
        if level and type(value) == 'table' then
            result[level] = {
                label = value.label or value.name or tostring(level),
                payment = value.payment or value.salary,
                isboss = value.isboss or value.isBoss or value.name == 'boss',
            }
        end
    end
    return result
end

---@param src number # Player ID
---@return table # { name, label, grade, gradeLabel, onDuty } (unemployed table when the player is unknown)
KOJA.Server.GetJobInfo = function(src)
    local info = frameworkCall('getJobInfo', src)
    if type(info) == 'table' then
        return info
    end
    return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '', onDuty = false }
end

---@param src number # Player ID
---@param job string # Job name
---@param grade number # Job grade
---@return boolean # Whether the job was set
KOJA.Server.SetJob = function(src, job, grade)
    if not src or not job then return false end
    return frameworkCall('setJob', src, job, tonumber(grade) or 0) == true
end

---@param identifier string # Character identifier (ESX identifier / citizenid)
---@param job string # Job name
---@param grade number # Job grade
---@return boolean # Whether the job was changed (online players are changed through SetJob)
KOJA.Server.SetOfflineJob = function(identifier, job, grade)
    if not identifier or not job then return false end
    grade = tonumber(grade) or 0
    local online = KOJA.Server.GetSourceByIdentifier(identifier)
    if online then
        return KOJA.Server.SetJob(online, job, grade)
    end
    return frameworkCall('setOfflineJob', identifier, job, grade) == true
end

---@param src number # Player ID
---@param state boolean # Duty state
---@return boolean
KOJA.Server.SetJobDuty = function(src, state)
    return frameworkCall('setJobDuty', src, state == true) == true
end

---@return table # { [name] = { label, type, grades = { [grade] = { label, payment, isboss } } } } (cached for 30s)
KOJA.Server.GetJobs = function()
    local now = os.time()
    if jobsCache.data and now - jobsCache.at < 30 then
        return jobsCache.data
    end

    local raw = frameworkCall('getRawJobs') or {}
    local jobs = {}
    for name, def in pairs(raw) do
        if type(def) == 'table' then
            jobs[name] = { label = def.label or name, type = def.type, grades = normalizeGrades(def.grades) }
        end
    end

    jobsCache = { at = now, data = jobs }
    return jobs
end

---@param identifier string # Character identifier
---@return number|nil # Player source if the character is online
KOJA.Server.GetSourceByIdentifier = function(identifier)
    if not identifier then return nil end
    return frameworkCall('getSourceByIdentifier', identifier)
end

---@param src number # Player ID
---@return string # 'male' or 'female'
KOJA.Server.GetGender = function(src)
    local gender = frameworkCall('getGender', src)
    if gender == 'male' or gender == 'female' then
        return gender
    end

    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 and GetEntityModel(ped) == joaat('mp_f_freemode_01') then
        return 'female'
    end
    return 'male'
end

--[[
    CUSTOM FRAMEWORK — SERVER

    Used only when Config.Framework = "custom".
    Fill in these functions with your own framework's logic. They are wired into
    the same internal API the built-in ESX/QBCore bridges use, so every
    KOJA.Server.* function will keep working without changing any script.

    Leave a function as-is (returning the safe default) if you don't need it.
]]

CustomFramework = CustomFramework or {}

CustomFramework.Server = {

    ---@return table # Array of online player ids
    GetPlayers = function()
        return nil -- nil = fall back to the native player list
    end,

    ---@param src number
    ---@return table|nil # Your framework's player object
    GetPlayer = function(src)
        return nil
    end,

    ---@param src number
    ---@return string|nil # Unique character identifier
    GetIdentifier = function(src)
        return nil
    end,

    ---@param src number
    ---@return string # Character display name
    GetPlayerName = function(src)
        return GetPlayerName(src) or ''
    end,

    ---@param src number
    ---@return string name, number grade
    GetPlayerJob = function(src)
        return nil
    end,

    ---@param src number
    ---@return string|nil # Permission group (admin/user/police...)
    GetPlayerGroup = function(src)
        return nil
    end,

    ---@param src number
    ---@param mtype string # 'cash' | 'bank' | 'black' | custom
    ---@return number
    GetMoney = function(src, mtype)
        return 0
    end,

    ---@param src number
    ---@param amount number
    ---@param mtype string
    ---@param reason? string
    ---@return boolean
    AddMoney = function(src, amount, mtype, reason)
        return false
    end,

    ---@param src number
    ---@param amount number
    ---@param mtype string
    ---@param reason? string
    ---@return boolean
    RemoveMoney = function(src, amount, mtype, reason)
        return false
    end,
    -- Bridge v2 hooks (optional): jobs, identity, admin, usable items ------------------

    ---@param src number
    ---@return table|nil # { name, label, grade, gradeLabel, onDuty }
    GetJobInfo = function(src)
        return nil
    end,

    ---@param src number
    ---@param job string
    ---@param grade number
    ---@return boolean
    SetJob = function(src, job, grade)
        return false
    end,

    ---@param identifier string
    ---@param job string
    ---@param grade number
    ---@return boolean
    SetOfflineJob = function(identifier, job, grade)
        return false
    end,

    ---@param src number
    ---@param state boolean
    ---@return boolean
    SetJobDuty = function(src, state)
        return false
    end,

    ---@return table # { [name] = { label = '', grades = { [grade] = { label = '' } } } }
    GetJobs = function()
        return {}
    end,

    ---@param identifier string
    ---@return number|nil # Online player id
    GetSourceByIdentifier = function(identifier)
        return nil
    end,

    ---@param src number
    ---@return string|nil # 'male' | 'female'
    GetGender = function(src)
        return nil
    end,

    ---@param src number
    ---@param groups table # Array of group names considered admin
    ---@return boolean
    IsGroupAdmin = function(src, groups)
        return false
    end,

    ---@param name string # Item name
    ---@param handler function # Call handler(src, data) when the item is used
    ---@return boolean # Whether the registration succeeded
    RegisterUsableItem = function(name, handler)
        return false
    end,
}

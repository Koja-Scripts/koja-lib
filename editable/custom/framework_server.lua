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
        return GetPlayers()
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
}

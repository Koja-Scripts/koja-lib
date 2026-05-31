--[[
    CUSTOM FRAMEWORK — CLIENT

    Used only when Config.Framework = "custom".
    Implement your framework's client-side player accessors here. They power
    KOJA.Client.GetPlayerData / GetPlayerJob / GetPlayerJobLabel.
]]

CustomFramework = CustomFramework or {}

CustomFramework.Client = {

    ---@return table # Local player data table
    GetPlayerData = function()
        return {}
    end,

    ---@return string|nil # Local player's job name
    GetPlayerJob = function()
        return nil
    end,

    ---@return string|nil # Local player's job label
    GetPlayerJobLabel = function()
        return nil
    end,
}

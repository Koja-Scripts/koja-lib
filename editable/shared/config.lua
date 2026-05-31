Config = {}

Config.Locale = 'pl'

-- Boolean to receive system logs.
Config.Debug = false -- Console logs

-- Notifications systems
-- "esx", "qb", "ox" (ox = ox_lib notify), "lib" (built-in koja-lib notify)
Config.Notify = "esx"

-- Framework used by your server.
-- "auto"   -> detects es_extended / qb-core / qbx_core automatically
-- "esx"    -> force ESX
-- "qb"     -> force QBCore / Qbox
-- "custom" -> use the functions you implement in editable/custom/framework_*.lua
Config.Framework = "auto"

-- Inventory system used by your server.
-- "auto"   -> detects the running inventory resource automatically
-- "custom" -> use the functions you implement in editable/custom/inventory_*.lua
-- or force one by resource name, e.g.:
-- "ox_inventory", "qb-inventory", "codem-inventory", "jaksam_inventory"
Config.Inventory = "auto"

Config.PoliceGroups = {
    ["police"] = true,
}

Config.Laser = {
    enable = true,
    command = 'laser'
}

Config.SaveVehicleConfig = {
    Charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    NumberCharset = "0123456789",
    Letters = 4, -- Number of letters in the license plate
    Numbers = 4,  -- Number of digits in the license plate
    Separator = "" -- Separator between characters on the license plate
}

Config.UI = {
    -- ProgressBar Configuration
    ProgressBar = {
        -- Theme options: "orange", "darkGray", "darkBlack", "navy", "green", "purple", "red"
        theme = "darkBlack",
        -- Distance from bottom in vw units
        bottomOffset = 1,
    },
    
    -- TextUI Configuration
    TextUI = {
        -- Theme options: "orange", "darkGray", "darkBlack", "navy", "green", "purple", "red"
        theme = "darkBlack",
        -- Distance from bottom in vw units
        bottomOffset = 5.5,
    }
}

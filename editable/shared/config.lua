Config = {}

Config.Locale = 'pl'

-- Boolean to receive system logs.
Config.Debug = false -- Console logs

-- Notifications systems
-- "esx", "qb", "ox"
Config.Notify = "lib"

Config.CustomFramework = false

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

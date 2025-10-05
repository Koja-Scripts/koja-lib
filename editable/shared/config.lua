Config = {}

Config.Locale = 'pl'

-- Boolean to receive system logs.
Config.Debug = false -- Console logs

-- Notifications systems
-- "esx", "qb", "ox"
Config.Notify = "ox"

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

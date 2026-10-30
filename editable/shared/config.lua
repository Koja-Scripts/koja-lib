Config = {}

Config.Locale = 'pl'

-- Boolean to receive system logs.
Config.Debug = false -- Console logs

-- Koja Scripts version checker: reports the versions of your Koja resources
-- and prints one link with versions and changelogs.
Config.VersionCheck = {
    enabled = true,
    url = 'https://versions.kojascripts.com',
}

-- Notifications systems
-- "esx", "qb", "ox" (ox = ox_lib notify), "lib" (built-in koja-lib notify),
-- "okok" (okokNotify), "mythic" (mythic_notify), "pnotify" (pNotify)
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

-- Integrations used by the bridge style functions (items, stash, target, clothing, keys, fuel, dispatch, phone ...).
-- Every value can stay on 'auto'. Set a resource name (or 'none') to force a specific one.
-- (The inventory is selected with Config.Inventory above; stash/items follow it.)
-- The auto-detection order of every category lives in editable/shared/integrations.lua.
Config.Banking = 'auto'     -- 'auto' | 'Renewed-Banking' | 'okokBanking' | 'qb-banking' | 'qb-management' | 'esx_society' | 'none'
Config.VehicleKeys = 'auto' -- 'auto' | 'qbx_vehiclekeys' | 'qb-vehiclekeys' | 'wasabi_carlock' | 'mk_vehiclekeys' | 'MrNewbVehicleKeys' | 'qs-vehiclekeys' | 'Renewed-Vehiclekeys' | 'cd_garage' | 'okokGarage' | 'none'
Config.Target = 'auto'      -- 'auto' | 'ox_target' | 'qb-target' | 'qtarget' | 'none' (koja-interactions provides ox_target)
Config.Clothing = 'auto'    -- 'auto' | 'illenium-appearance' | 'fivem-appearance' | 'qb-clothing' | 'esx_skin' | 'none'
Config.Fuel = 'auto'        -- 'auto' | 'ox_fuel' | 'Renewed-Fuel' | 'LegacyFuel' | 'cdn-fuel' | 'ps-fuel' | 'lc_fuel' | 'qs-fuelstations' | 'okokGasStation' | 'lj-fuel' | 'ti_fuel' | 'native'
Config.Phone = 'auto'       -- 'auto' | 'lb-phone' | 'qs-smartphone' | 'qs-smartphone-pro' | 'gksphone' | 'qb-phone' | 'none'

-- KOJA.Server.SendDispatch / KOJA.Client.SendDispatch
Config.Dispatch = {
    system = 'auto',              -- 'auto' | 'koja-mdt' | 'koja-dispatch' | 'ps-dispatch' | 'cd_dispatch' | 'core_dispatch' | 'rcore_dispatch' | 'qs-dispatch' | 'none'
    defaultJobs = { 'police' },   -- jobs that get an alert when the caller does not name any
    allowClient = true,           -- let client scripts send alerts through KOJA.Client.SendDispatch
    clientCooldown = 10,          -- seconds between client alerts per player
    clientMaxDistance = 150.0,    -- client coords further than this from the player are replaced with the player position
    clientJobs = { 'police', 'sheriff', 'ambulance' }, -- jobs a client alert may target (nil = any)
}
Config.Sound = 'auto'       -- 'auto' | 'xsound' | 'none'

-- In-game dev tool: /kojadev (position, entity inspector, vehicle and world helpers). Admins only (Config.Admin rules).
Config.DevTool = {
    enabled = true,
    command = 'kojadev',
    key = '',          -- optional key mapping, e.g. 'F10'
    ace = nil,         -- extra ACE that grants access, nil uses Config.Admin
    groups = nil,      -- extra framework groups, nil uses Config.Admin
}

-- KOJA.Server.IsAdmin defaults
Config.Admin = {
    Ace = 'command',                                  -- ACE permission, nil to disable
    Groups = { 'admin', 'superadmin', 'god' },        -- framework groups
    Identifiers = {},                                 -- extra whitelisted identifiers
}

-- Fallback stash (no ox_inventory / qb-inventory): items are kept in resource KVP
Config.FallbackStash = {
    KvpPrefix = 'koja_stash_',
    SessionSeconds = 600,
}

-- Database tables used for qb-inventory stashes (change if your inventory uses different names)
Config.StashTables = {
    ['qb-inventory'] = { table = 'inventories', identifier = 'identifier', column = 'items' },
    ['qb-legacy'] = { table = 'stashitems', identifier = 'stash', column = 'items' },
}

-- Tables used by KOJA.Server.SetOfflineJob
Config.OfflineJobTables = {
    esx = { table = 'users', job = 'job', grade = 'job_grade', identifier = 'identifier' },
    qb = { table = 'players', column = 'job', identifier = 'citizenid' },
}

-- Item image url templates for KOJA.Server.GetItemImage
Config.ItemImages = {
    ox_inventory = 'nui://ox_inventory/web/images/%s.png',
    ['qb-inventory'] = 'nui://qb-inventory/html/images/%s',
    ['qb-legacy'] = 'nui://%s/html/images/%s',
    framework = 'nui://ox_inventory/web/images/%s.png',
}
Config.ItemListCacheSeconds = 60

-- Extra lucide -> FontAwesome icon names for KOJA.Client.Target (merged over the built in map)
Config.TargetIconMap = {}

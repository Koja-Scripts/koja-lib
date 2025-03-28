Config = {}

Config.Locale = 'pl'

-- Boolean to receive system logs.
Config.Debug = false -- Console logs

-- Notifications systems
-- "esx", "qb", "ox"
Config.Notify = "ox"

Config.CustomFramework = false


--DOORLOCKS

Config.Doorlocksystem = 'standalone' -- ox, standalone
Config.DoorList = {
	{
        name = 'doorlock_1',
        coords = vec3(-110.642303, 6462.012695, 31.793337),
        model = 2063730765,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 135
    },

    {
        name = 'doorlock_2',
        coords = vec3(-104.705734, 6473.917969, 31.787983),
        model = -368548260,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 45
    },

    {
        name = 'doorlock_3',
        coords = vec3(-100.112297, 6474.392090, 31.787979),
        model = -147325430,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 315
    },

    {
        name = 'doorlock_4',
        coords = vec3(-100.621742, 6467.989258, 31.793346),
        model = 1754616769,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 45
    },

    {
        name = 'doorlock_5',
        coords = vec3(-104.837128, 6463.773926, 31.793346),
        model = 2110946875,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 225
    },

    {
        name = 'doorlock_6',
        coords = vec3(-100.241867, 6464.549316, 31.884604),
        model = -2050208642,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 225
    },

    {
        name = 'doorlock_7',
        coords = vec3(-111.042694, 6475.328125, 31.787979),
        model = -56652918,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 225
    },

    {
        name = 'doorlock_8',
        coords = vec3(-116.512687, 6478.9599609375, 31.78797912597656),
        model = 1248599813,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 225
    },

    {
        name = 'doorlock_9',
        coords = vec3(-96.708656, 6474.056641, 31.787979),
        model = 1248599813,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 135
    },

    {
        name = 'doorlock_10',
        coords = vec3(-92.232231, 6468.960449, 31.787979),
        model = -147325430,
        locked = true,
        groups = { police = 0 },
        hideUi = true,
        heading = 225
    }
}
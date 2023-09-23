Config = {}
Config.CoreName = "qb-core"
Config.TargetName = "qb-target"
Config.LockpickItem = 'lockpick'
Config.AdvancedLockpickItem = 'advancedlockpick'
Config.ThermiteItem = 'thermite'
Config.Vangelico = {
    RequiredStoreRobberies = 5, -- How many store robberies you have to do before robbing Vangelico
    RobbingCooldown = 30, --Minutes until vangelico is robable again
    FuseBoxTarget = {
        Coords = vector3(-592.52, -284.4, 50.32),
        Heading = 27
    },
    FrontDoorsTarget = {
        Coords = vector3(-631.5, -237.6, 38.08),
        Heading = 308
    },
    DeskTarget = {
        Coords = vector3(-631.35, -230.17, 38.06),
        Heading = 308
    },
    CaseZones ={
        vector3(-626.83, -235.35, 38.05), vector3(-625.81, -234.7, 38.05), vector3(-626.95, -233.14, 38.05), vector3(-628.0, -233.86, 38.05), vector3(-625.7, -237.8, 38.05), vector3(-626.7, -238.58, 38.05), vector3(-624.55, -231.06, 38.05), vector3(-623.13, -232.94, 38.05), vector3(-620.29, -234.44, 38.05), vector3(-619.15, -233.66, 38.05), vector3(-620.19, -233.44, 38.05), vector3(-617.63, -230.58, 38.05), vector3(-618.33, -229.55, 38.05), vector3(-619.7, -230.33, 38.05), vector3(-620.95, -228.6, 38.05), vector3(-619.79, -227.6, 38.05), vector3(-620.42, -226.6, 38.05), vector3(-623.94, -227.18, 38.05), vector3(-624.91, -227.87, 38.05), vector3(-623.94, -228.05, 38.05)  
    },
    Rewards = {
        { item = 'rolex', amountMin = 1, amountMax = 4},
        { item = 'diamond_ring', amountMin = 1, amountMax = 4},
        { item = 'goldchain', amountMin = 1, amountMax = 4},
    }
}
Config.Stores = {
    SafeReward = math.random(2500, 5000),
    RegisterReward = math.random(150, 500),
    ShopKeeperPedHashes = {416176080}, -- We recommend usnig the default qb-shops ped type mp_m_shopkeep_01
    RobbingCooldown = 30, -- Minutes until that specific store is robable again
    Locations = {
        {
            Name = "Grove Street LTD",
            SafeTarget = {
                Coords = vector3(-43.98, -1748.11, 29.4),
                Heading = 50
            },
            RegisterTarget = {
                Coords = vector3(-47.26, -1757.47, 29.67),
                Heading = 50
            },
        },
        {
            Name = "Prosperity Robs Liquor",
            SafeTarget = {
                Coords = vector3(-1478.48, -375.88, 39.64),
                Heading = 220,
            },
            RegisterTarget = {
                Coords = vector3(-1486.84, -378.58, 40.55),
                Heading = 130,
            },
        },
        {
            Name = "San Andreas Robs Liquor",
            SafeTarget = {
                Coords = vector3(-1220.85, -916.06, 11.32),
                Heading = 130,
            },
            RegisterTarget = {
                Coords = vector3(-1222.44, -907.86, 13.49),
                Heading = 190,
            },
        },
        {
            Name = "Vespucci LTD",
            SafeTarget = {
                Coords = vector3(-709.71, -904.22, 19.22),
                Heading = 95,
            },
            RegisterTarget = {
                Coords = vector3(-706.69, -914.15, 20.38),
                Heading = 270,
            },
        },
        {
            Name = "Mirror Park Robs Liquor",
            SafeTarget = {
                Coords = vector3(1126.57, -980.31, 45.42),
                Heading = 2,
            },
            RegisterTarget = {
                Coords = vector3(1134.79, -982.5, 47.58),
                Heading = 90,
            },
        },
        {
            Name = "Mirror Park Robs Liquor",
            SafeTarget = {
                Coords = vector3(1159.7, -314.04, 69.2),
                Heading = 113,
            },
            RegisterTarget = {
                Coords = vector3(1164.14, -322.95, 70.45),
                Heading = 277,
            },
        },
        {
            Name = "Mirror Park LTD",
            SafeTarget = {
                Coords = vector3(1159.7, -314.04, 69.2),
                Heading = 113,
            },
            RegisterTarget = {
                Coords = vector3(1164.14, -322.95, 70.45),
                Heading = 277,
            },
        },
        {
            Name = "Clinton 24/7",
            SafeTarget = {
                Coords = vector3(378.08, 333.24, 103.57),
                Heading = 5,
            },
            RegisterTarget = {
                Coords = vector3(373.75, 328.48, 104.96),
                Heading = 63,
            },
        },
        {
            Name = "N Rockford Drive LTD",
            SafeTarget = {
                Coords = vector3(-1829.27, 798.83, 138.19),
                Heading = 126,
            },
            RegisterTarget = {
                Coords = vector3(-1820.64, 793.96, 139.28),
                Heading = 312.88,
            },
        },
        {
            Name = "Ocean Freeway Robs Liquor",
            SafeTarget = {
                Coords = vector3(-2959.59, 387.05, 14.04),
                Heading = 190,
            },
            RegisterTarget = {
                Coords = vector3(-2966.88, 390.79, 16.21),
                Heading = 263.76,
            },
        },
        {
            Name = "Ocean Freeway 24/7 #2",
            SafeTarget = {
                Coords = vector3(-3047.67, 585.66, 7.91),
                Heading = 111,
            },
            RegisterTarget = {
                Coords = vector3(-3047.67, 585.66, 7.91),
                Heading = 200,
            },
        },
        {
            Name = "Ocean Freeway 24/7 #1",
            SafeTarget = {
                Coords = vector3(-3249.86, 1004.33, 12.83),
                Heading = 80,
            },
            RegisterTarget = {
                Coords = vector3(-3244.53, 1000.52, 14.01),
                Heading = 194,
            },
        },
        {
            Name = "Route 68 24/7",
            SafeTarget = {
                Coords = vector3(546.54, 2663.0, 42.16),
                Heading = 186,
            },
            RegisterTarget = {
                Coords = vector3(548.85, 2668.66, 43.28),
                Heading = 255,
            },
        },
        {
            Name = "Route 68 Robs Liquor",
            SafeTarget = {
                Coords = vector3(1169.12, 2717.99, 37.16),
                Heading = 283.35,
            },
            RegisterTarget = {
                Coords = vector3(1165.99, 2710.09, 39.48),
                Heading = 75.42,
            },
        },
        {
            Name = "Senora Freeway 24/7",
            SafeTarget = {
                Coords = vector3(2672.71, 3286.62, 55.24),
                Heading = 38,
            },
            RegisterTarget = {
                Coords = vector3(2676.18, 3281.06, 56.57),
                Heading = 155,
            },
        },
        {
            Name = "Sandy Shores 24/7",
            SafeTarget = {
                Coords = vector3(1959.32, 3748.77, 32.34),
                Heading = 32,
            },
            RegisterTarget = {
                Coords = vector3(1959.27, 3742.3, 33.52),
                Heading = 127,
            },
        },
        {
            Name = "Ocean Freeway Gas 24/7",
            SafeTarget = {
                Coords = vector3(1734.77, 6420.91, 35.04),
                Heading = 336,
            },
            RegisterTarget = {
                Coords = vector3(1729.37, 6417.14, 36.36),
                Heading = 70,
            },
        },

    }
}
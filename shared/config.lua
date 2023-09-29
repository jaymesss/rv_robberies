Config = {}
Config.CoreName = "qb-core"
Config.TargetName = "qb-target"
Config.LockpickItem = 'lockpick'
Config.AdvancedLockpickItem = 'advancedlockpick'
Config.ThermiteItem = 'thermite'
Config.FlashdriveItem = 'flashdrive'
Config.FleecaKeycardItem = 'fleeca_keycard'
Config.PaletoKeycardItem = 'paleto_keycard'
Config.DrillItem = 'drill'
Config.UsingPsDispatch = false
Config.PoliceJobNames = {"police", "leo"}
Config.FlashdriveTraders = {
    MissionCooldown = 10, -- Global cooldown in minutes until a mission is available
    RequiredPolice = 1,
    Types = {
        Green = {
            Cost = 15000,
            Ped = {
                Coords = vector4(2546.29, 385.63, 107.62, 83.93),
                Model = 'a_m_m_afriamer_01'
            },
            Target = {
                Coords = vector3(2546.29, 385.63, 108.62),
                Heading = 265.28
            }
        },
        Blue = {
            Cost = 35000,
            Ped = {
                Coords = vector4(2565.53, 4644.57, 33.08, 231.32),
                Model = 'a_m_m_afriamer_01'
            },
            Target = {
                Coords = vector3(2565.53, 4644.57, 34.08),
                Heading = 50
            }
        },
        Red = {
            Cost = 50000,
            Ped = {
                Coords = vector4(285.1, -2944.83, 4.54, 3.07),
                Model = 'a_m_m_afriamer_01'
            },
            Target = {
                Coords = vector3(285.1, -2944.83, 5.54),
                Heading = 180
            }
        }
    },
}
Config.Vault = {
    RequiredPacificRobberies = 5,
    RequiredPolice = 5,
    LaptopItem = 'laptop_gold',
    USBItem = 'vault_flashdrive',
    KeycardItem = 'vault_keycard',
    SafeRewards = {
        Cash = {
            amountMin = 5000, amountMax = 9000
        },
        Items = {
            { item = 'goldbar', amountMin = 1, amountMax = 3}
        }
    },
    TrollyRewards = {
        Items = {
            { item = 'markedbills', amountMin = 3, amountMax = 8 }
        }
    },
}
Config.Pacific = {
    RequiredPaletoRobberies = 3,
    RequiredPolice = 5,
    LaptopItem = 'laptop_red',
    KeysItem = 'pacific_keys',
    KeycardItem = 'pacific_keycard',
    SafeRewards = {
        Cash = {
            amountMin = 5000, amountMax = 9000
        },
        Items = {
            { item = 'goldbar', amountMin = 1, amountMax = 3}
        }
    },
    TrollyRewards = {
        Items = {
            { item = 'markedbills', amountMin = 3, amountMax = 8 }
        }
    },
}
Config.Paleto = {
    RequiredFleecaRobberies = 5,
    KidnapCooldown = 15, -- Minutes until an employee can be kidnapped again
    RequiredPolice = 4,
    Kidnapping = {
        Coords = vector3(-116.89, -2679.26, 6.01)
    },
    EmployeeItems = { 'paleto_keycard', 'flashdrive' },
    LaptopItem = 'laptop_blue',
    SafeRewards = {
        Cash = {
            amountMin = 5000, amountMax = 9000
        },
        Items = {
            { item = 'goldbar', amountMin = 1, amountMax = 3}
        }
    },
    TrollyRewards = {
        Items = {
            { item = 'markedbills', amountMin = 3, amountMax = 8 }
        }
    },
}
Config.Fleecas = {
    RequiredVangelicoRobberies = 3,
    RobbingCooldown = 30, -- Minutes until a fleeca is robbable again
    KidnapCooldown = 15, -- Minutes until an employee can be kidnapped again
    RequiredPolice = 3,
    Kidnapping = {
        Coords = vector3(1392.47, 3606.45, 38.94)
    },
    EmployeeItems = { 'fleeca_keycard', 'flashdrive' },
    LaptopItem = 'laptop_green',
    SafeRewards = {
        Cash = {
            amountMin = 2000, amountMax = 5000
        },
        Items = {
            { item = 'goldbar', amountMin = 1, amountMax = 2}
        }
    },
    TrollyRewards = {
        Items = {
            { item = 'markedbills', amountMin = 2, amountMax = 3 }
        }
    },
}
Config.Vangelico = {
    RequiredStoreRobberies = 5, -- How many store robberies you have to do before robbing Vangelico
    RobbingCooldown = 30, --Minutes until vangelico is robbable again
    RequiredPolice = 2,
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
    RareSafeItem = 'vpn',
    ShopKeeperPedHashes = {416176080}, -- We recommend usnig the default qb-shops ped type mp_m_shopkeep_01
    RobbingCooldown = 30, -- Minutes until a store is robbable again
    RequiredCops = 2,
}
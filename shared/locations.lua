Locations = {}
Locations.Vault = {
    {
        Name = 'Pacific Standard Vault',
        FuseBoxes = {
            { Coords = vector3(765.86, 1274.24, 360.3), Heading = 108.86, Name = '#1'},
            { Coords = vector3(760.44, 1280.42, 360.3), Heading = 183.63, Name = '#2'},
            { Coords = vector3(751.03, 1273.66, 360.3), Heading = 285.86, Name = '#3'},
        },
        Keypad = {
            Coords = vector3(257.51, 227.84, 101.68),
            Heading = 340,
            AnimCoords = vector3(256.31, 226.75, 101.88)
        },
        VaultDoor = {
            Model = -1520917551,
            Coords = vector3(258.29, 240.03, 102.24),
            Heading = {
                Closed = 160,
                Open = 35
            }
        },
        Doors = {
            { Coords = vector3(256.34, 240.18, 101.7), Heading = 345, Id = 'Main'},
            { Coords = vector3(255.74, 245.16, 101.69), Heading = 67, Id = 'One', Model = -1735710},
            { Coords = vector3(257.75, 250.75, 101.69), Heading = 67, Id = 'Two', Model = -1735710},
            { Coords = vector3(259.84, 256.47, 101.69), Heading = 67, Id = 'Three', Model = -1735710},
            { Coords = vector3(264.25, 254.68, 101.69), Heading = 250, Id = 'Four', Model = -1735710},
            { Coords = vector3(262.28, 249.25, 101.69), Heading = 250, Id = 'Five', Model = -1735710},
            { Coords = vector3(260.27, 243.72, 101.69), Heading = 250, Id = 'Six', Model = -1735710},
        },
        Lockers = {
            { Coords = vector3(257.11, 233.43, 101.68), Heading = 350 },
            { Coords = vector3(259.42, 232.6, 101.68), Heading = 350 },
            { Coords = vector3(261.48, 235.2, 101.68), Heading = 247 },
            { Coords = vector3(258.98, 234.34, 101.68), Heading = 160 },
        },
        Computer = {
            Coords = vector3(251.58, 236.03, 101.68),
            Heading = 240
        },
        Trollys = {
            vector4(263.25, 242.28, 101.69, 318.48),
            vector4(265.42, 247.88, 101.69, 45.33),
            vector4(267.18, 255.04, 101.69, 68.32),
            vector4(256.91, 257.23, 101.69, 66.28),
            vector4(254.95, 252.32, 101.69, 131.08),
            vector4(253.04, 246.4, 101.69, 300.91)
        }
    }
}
Locations.Pacific = {
    {
        Name = "Pacific Standard Bank",
        FrontDesk = {
            Coords = vector3(243.56, 225.03, 107.28),
            Heading = 345
        },
        Drawers = {
            { Coords = vector3(242.12, 230.35, 106.29), Heading = 73 },
            { Coords = vector3(244.41, 232.24, 106.29), Heading = 345 },
            { Coords = vector3(249.11, 230.54, 106.29), Heading = 345 },
        },
        Doors = {
            { Coords = vector3(256.79, 220.14, 106.29), Heading = 345, Id = 'Main'},
            { Coords = vector3(265.9, 218.31, 110.28), Heading = 160, Id = 'Keys'},
            { Coords = vector3(261.78, 222.11, 106.28), Heading = 250, Id = 'Lower Bank'},
            { Coords = vector3(252.66, 221.38, 101.68), Heading = 250, Id = 'Vault 1'},
            { Coords = vector3(261.0, 215.23, 101.68), Heading = 250, Id = 'Vault 2'},
        },
        DisableSystems = {
            Coords = vector3(261.53, 204.85, 110.29),
            Heading = 350
        },
        Keypad = {
            Coords = vector3(253.22, 228.33, 101.68),
            Heading = 30,
            AnimCoords = vector3(253.47, 228.16, 101.68)
        },
        VaultDoor = {
            Model = 961976194,
            Coords = vector3(255.23, 223.98, 102.39),
            Heading = {
                Closed = 160,
                Open = 35
            }
        },
        Safes = {
            { Coords = vector3(258.47, 214.28, 101.68), Heading = 157 },
            { Coords = vector3(259.57, 217.98, 101.68), Heading = 340 },
            { Coords = vector3(264.76, 215.94, 101.68), Heading = 340 },
            { Coords = vector3(266.04, 213.56, 101.68), Heading = 257 },
            { Coords = vector3(263.23, 212.4, 101.68), Heading = 150 },
        },
        Trollys = {
            vector4(263.41, 214.47, 101.68, 5.6),
            vector4(265.06, 215.18, 101.68, 259.79),
            vector4(265.04, 212.84, 101.68, 132.64)
        }
    },
}
Locations.Paleto = {
    {
        Name = "Blaine County Savings",
        LockedDoor = {
            Coords = vector3(-106.15, 6475.29, 31.63),
            Heading = 315
        },
        Fusebox = {
            Coords = vector3(-109.58, 6483.65, 31.47),
            Heading = 225
        },
        Employee = {
            Coords = vector4(-102.51, 6469.41, 30.63, 153.72),
            Heading = 270,
            Model = 'a_f_y_business_04'
        },
        Keypad = {
            Coords = vector3(-105.47, 6471.54, 31.63),
            Heading = 50,
            AnimCoords = vector3(-104.41, 6471.23, 31.63)
        },
        Safes = {
            { Coords = vector3(-107.58, 6475.7, 31.63), Heading = 50 },
            { Coords = vector3(-107.11, 6473.76, 31.63), Heading = 145 },
            { Coords = vector3(-103.0, 6478.02, 31.63), Heading = 325 },
            { Coords = vector3(-102.83, 6475.7, 31.63), Heading = 222 },
        },
        Trollys = {
            vector4(-105.95, 6477.27, 31.63, 341.41),
            vector4(-104.99, 6478.75, 31.64, 257.95)
        }
    },
}
Locations.Fleecas = {
    {
        Name = "Pink Cage Bank",
        Door = {
            Model = 2121050683,
            Coords = vector3(312.36, -282.73, 54.3),
            Heading = {
                Closed = 250,
                Open = 160
            }
        },
        LockedDoor = {
            Coords = vector3(314.03, -285.41, 54.14),
            Heading = 150
        },
        Employee = {
            Coords = vector4(306.81, -282.51, 53.16, 318.42),
            Heading = 130,
            Model = 'a_f_y_business_04'
        },
        Keypad = {
            Coords = vector3(311.2, -284.43, 54.16),
            Heading = 241,
            AnimCoords = vector3(310.83, -283.46, 54.17)
        },
        Safes = {
            { Coords = vector3(314.12, -283.33, 54.14), Heading = 350 },
            { Coords = vector3(315.54, -284.8, 54.14), Heading = 250 },
        },
        Trollys = {
            vector4(313.47, -289.25, 54.14, 320.27),
            vector4(311.61, -287.69, 54.14, 305.18)
        }
    },
    {
        Name = "Legion Square Fleeca",
        Door = {
            Model = 2121050683,
            Coords = vector3(148.03, -1044.36, 29.51),
            Heading = {
                Closed = 250,
                Open = 160
            }
        },
        LockedDoor = {
            Coords = vector3(149.66, -1047.01, 29.35),
            Heading = 162
        },
        Employee = {
            Coords = vector4(142.36, -1043.99, 28.37, 314.04),
            Heading = 130,
            Model = 'a_f_y_business_04'
        },
        Keypad = {
            Coords = vector3(146.37, -1044.93, 29.38),
            Heading = 245,
            AnimCoords = vector3(146.37, -1044.93, 29.38)
        },
        Safes = {
            { Coords = vector3(151.21, -1046.59, 29.35), Heading = 250 },
            { Coords = vector3(149.81, -1044.98, 29.35), Heading = 340 },
        },
        Trollys = {
            vector4(147.13, -1049.60, 29.34, 311.47),
            vector4(149.51, -1050.76, 29.34, 291.46)
        }
    },
    {
        Name = "Del Perro Fleeca",
        Door = {
            Model = 2121050683,
            Coords = vector3(-1211.26, -334.58, 37.92),
            Heading = {
                Closed = 296,
                Open = 206
            }
        },
        LockedDoor = {
            Coords = vector3(-1208.23, -335.17, 37.76),
            Heading = 208
        },
        Employee = {
            Coords = vector4(-1215.34, -338.12, 36.78, 16.03),
            Heading = 130,
            Model = 'a_f_y_business_04'
        },
        Keypad = {
            Coords = vector3(-1210.74, -336.55, 37.78),
            Heading = 290,
            AnimCoords = vector3(-1212.05, -336.26, 37.79)
        },
        Safes = {
            { Coords = vector3(-1207.67, -333.87, 37.76), Heading = 300 },
            { Coords = vector3(-1209.67, -333.83, 37.76), Heading = 35 },
        },
        Trollys = {
            vector4(-1207.97, -338.97, 37.75, 353.90),
            vector4(-1205.89, -338.06, 37.75, 340.50)
        }
    },
    {
        Name = "Hawick Ave Fleeca",
        Door = {
            Model = 2121050683,
            Coords = vector3(-352.74, -53.57, 49.18),
            Heading = {
                Closed = 250,
                Open = 160
            }
        },
        LockedDoor = {
            Coords = vector3(-351.05, -56.05, 49.01),
            Heading = 160
        },
        Employee = {
            Coords = vector4(-358.28, -53.21, 48.04, 301.61),
            Heading = 90,
            Model = 'a_f_y_business_04'
        },
        Keypad = {
            Coords = vector3(-353.82, -55.15, 49.04),
            Heading = 250,
            AnimCoords = vector3(-354.41, -54.05, 49.05)
        },
        Safes = {
            { Coords = vector3(-349.72, -55.71, 49.01), Heading = 250 },
            { Coords = vector3(-351.1, -54.25, 49.01), Heading = 340 },
        },
        Trollys = {
            vector4(-353.64, -59.04, 49.01, 309.62),
            vector4(-351.62, -59.91, 49.01, 296.23)
        }
    },
    {
        Name = "Great Ocean Fwy Fleeca",
        Door = {
            Model = -63539571,
            Coords = vector3(-2958.54, 482.27, 15.84),
            Heading = {
                Closed = 357,
                Open = 267
            }
        },
        LockedDoor = {
            Coords = vector3(-2956.65, 484.48, 15.68),
            Heading = 290
        },
        Employee = {
            Coords = vector4(-2957.64, 476.7, 14.7, 56.13),
            Heading = 260,
            Model = 'a_f_y_business_04'
        },
        Keypad = {
            Coords = vector3(-2956.57, 481.7, 15.7),
            Heading = 340,
            AnimCoords = vector3(-2957.4, 480.48, 15.71)
        },
        Safes = {
            { Coords = vector3(-2957.32, 485.72, 15.68), Heading = 340 },
            { Coords = vector3(-2958.35, 484.27, 15.68), Heading = 113 },
        },
        Trollys = {
            vector4(-2953.08, 482.78, 15.67, 49.13),
            vector4(-2952.88, 485.22, 15.67, 37.42)
        }
    },
    {
        Name = "Route 68 Fleeca",
        Door = {
            Model = 2121050683,
            Coords = vector3(1175.54, 2710.86, 38.23),
            Heading = {
                Closed = 90,
                Open = 0
            }
        },
        LockedDoor = {
            Coords = vector3(1173.17, 2712.64, 38.07),
            Heading = 4
        },
        Employee = {
            Coords = vector4(1180.98, 2712.04, 37.09, 150.26),
            Heading = 150,
            Model = 'a_f_y_business_04'
        },
        Keypad = {
            Coords = vector3(1176.04, 2712.85, 38.09),
            Heading = 82,
            AnimCoords = vector3(1177.16, 2711.94, 38.1)
        },
        Safes = {
            { Coords = vector3(1172.02, 2711.93, 38.07), Heading = 90 },
            { Coords = vector3(1173.7, 2710.94, 38.07), Heading = 190 },
        },
        Trollys = {
            vector4(1174.64, 2716.20, 38.06, 141.10),
            vector4(1171.65, 2716.27, 38.06, 231.91)
        }
    },
}
Locations.Stores = {
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
    }
}
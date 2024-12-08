Config = Config or {}

Config.MaxPlayersPerTeam = 9
Config.ScoreLimit = 10
Config.FriendlyFire = false

Config.PreGameTimer = 5
Config.GameTimer = 50

Config.MaxHealth = 100
Config.MaxArmor = 50

Config.HealthRegen = false


Config.DefaultCarModel = "adder"
Config.DefaultWeapon = "WEAPON_PISTOL"
Config.Weapons = {
    'WEAPON_PISTOL',
    'WEAPON_HEAVYPISTOL',
    'WEAPON_BAT',
    'WEAPON_RPG'
}
Config.DefaultMap = "Map1"
Config.Maps = {
    ["Map1"] = {
        MapName = "Life Invader",
        SpawnLocations = {
            Red = { {x = -1445.75, y = -355.86, z = 44.13 - 1} },
            Blue = { {x = -1445.75, y = -355.86, z = 44.13 -1} },
            Defense = { {x = -1057.53, y = -239.53, z = 44.02 - 1} },
            Attack = { {x = -1082.15, y = -264.98, z = 37.75 - 1} }
        }
    },
    ["Map2"] = {
        MapName = "Mandem",
        SpawnLocations = {
            Red = { {x = -1594.71, y = -254.16, z = 53.72 - 1} },
            Blue = { {x = -1515.41, y = -266.5, z = 50.34 - 1} },
            Defense = { {x = -1577.05, y = -235.9, z = 60.42 -1} },
            Attack = { {x = -1515.41, y = -266.5, z = 50.34 - 1} }
        }
    },
    ["Map3"] = {
        MapName = "Arena",
        SpawnLocations = {
            Red = { {x = -1445.75, y = -355.86, z = 44.13} },
            Blue = { {x = -1445.75, y = -355.86, z = 44.13} },
            Defense = { {x = -1445.75, y = -355.86, z = 44.13} },
            Attack = { {x = -1445.75, y = -355.86, z = 44.13} }
        }
    },
    ["Map4"] = {
        MapName = "Airport",
        SpawnLocations = {
            Red = { {x = -1445.75, y = -355.86, z = 44.13} },
            Blue = { {x = -1445.75, y = -355.86, z = 44.13} },
            Defense = { {x = -1445.75, y = -355.86, z = 44.13} },
            Attack = { {x = -1445.75, y = -355.86, z = 44.13} }
        }
    },
    ["Map5"] = {
        MapName = "Gun Bench",
        SpawnLocations = {
            Red = { {x = -1445.75, y = -355.86, z = 44.13} },
            Blue = { {x = -1445.75, y = -355.86, z = 44.13} },
            Defense = { {x = -1445.75, y = -355.86, z = 44.13} },
            Attack = { {x = -1445.75, y = -355.86, z = 44.13} }
        }
    }
}

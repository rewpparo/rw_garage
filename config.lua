Config = {}

Config.Locale = "en"


--progressbar in ms
Config.StoreTimer = 1000
Config.TakeTimer = 1000

---------------------
-- Default Visuals --
---------------------

--Default Blip
Config.DefaultBlip = {
    Show = true,
    Category = "Garage",
    Sprite = 357,
    Color = 29,
    Scale = 1.0,
    Display = 2,
}

--Default Marker
Config.DefaultMarker = {
    Size = 2.0,
    Marker = 27,
    Color = {64,64,255,128},
    DrawDistance = 25,
}

------------------------
-- Garage definitions --
------------------------

Config.Garages = {
    --Public Garage
    {
        Name = "PaletoW",
        Label = "West Paleto",
        AllowOwned = true,
        Fee = 100,
        Spawn = {
            Location = vector3(-276.16, 6137.63, 31.5),
            Spawns = {
                vector4(-282.5, 6132.6, 31.8, 226.7),
            },
        },
        Dropoff = {
            Location = vector3(-303.3, 6112.32, 31.49),
            Size = 6.0,
            DrawDistance = 50,
        },
    },
    {
        Name = "Pillbox",
        Label = "Pillbox Hill",
        AllowOwned = true,
        Fee = 100,
        Spawn = {
            Location = vector3(213.5, -809.17, 31.0),
            Spawns = {
                vector4(220.44, -806.57, 30.67, 249.45),
                vector4(221.63, -803.95, 30.68, 249.45),
                vector4(222.55, -801.5, 30.66, 249.45),
                vector4(223.37, -799.05, 30.66, 249.45),
                vector4(232.72, -808.1, 30.4, 62.4),
                vector4(233.9, -805.7, 30.42, 62.4),
                vector4(234.9, -803.2, 30.4, 62.4),
            },
        },
        Dropoff = {
            Location = vector3(217.33, -799.45, 30.76),
            Size = 6.0,
            DrawDistance = 50,
        },
    },
}

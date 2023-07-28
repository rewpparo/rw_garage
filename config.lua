Config = {}

Config.Locale = "en"

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
        SocietyFee = 'society_paletomairie',
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
    --Garage mairie
    {
        Name = "paletomairie",
        Label = "Paleto Mairie",
        Job = {["paletomairie"]=0},
        Spots = 10,
        AllowOwned = true,
        AllowJob = true,
        Spawn = {
            Location = vector3(-141.63, 6279.76, 31.5),
            Spawns = {
                vector4(-138.63, 6276.3, 31.3, 226.7),
                vector4(-141.63, 6273.64, 31.33, 226.7),
                vector4(-136.13, 6278.83, 31.31, 226.7),
            },
        },
        Dropoff = {
            Location = vector3(-133.5, 6270.2, 31.3),
            Size = 6.0,
            DrawDistance = 50,
        },
        Blip = {
            Show = false,
        }
    },
}

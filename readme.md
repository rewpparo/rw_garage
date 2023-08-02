
# A very customizable garage script for ESX. 
Rewritten from scratch with esx_garage as an inspiration
## Features :
 - Store your character's cars and retrieve them in garage spots
 - Uses esx onesync for persistant server side vehicles
 - Job garages
 - Advanced permission system to control who can store and retrieve what and where
 - Configurable time to store and take
 - Cutomizable blips and markers
 - Garage capacity
 - Pay to take vehicle out
 - Impoud system integrated with garage system

Aims to keep the database a basic esx_vehicleshop, and may support extra features  
Required database fields in owned_vehicles : owner, plate, vehicle, job, stored, parking, pound  
Optional : name (will show in garage menu)

Impound works differently in the databse than esx_garage to make space for more functionality. Instead of setting stored to 2, parking to nil, and pound to impound name, you set stored to 1, parking to pound name, and pound to the price you need to pay to retrieve your car. This works for paying parkings and for impounds. It souldn't be any trouble when the two systems run side by side, as a car is either in one system or another. However when transitioning from one system to the other, recretating garages into another system it could be a problem for impounded vehicles.

ox_target and qtarget integration should be easy. Just register a garage with spawn and/or dropoff Marker set to -1 to prevent marker from drawing and being interacted with, then implement the targeting as you like to call the client exports to open and close the garage menu or store the vehicle. Location and permissions are still checked server side. 

## TODO :
 - Hourly fees for garages
 - Garage vehicle type limitations (plane, car...)
 - Polish cop access to impound, put fee, etc...
 - Job vehicle permission per model and job/Grade ?
 - Script to convert esx_garage impound entries
 - Look into simplifying custom garages by exposing functionality

## Garage declaration (in config.lua and when calling RegisterGarage)--
```
Name : string (MANDATORY)
    unique garage identifier
Label : string
    Garage name for display
Job : table of string,number pairs
    Jobs and minimum grade to access the garage. Example : Job = {["police"] = 0, ["ambulance"] = 2}
Spots : number
    Number of cars that can be stored in this garage. Unspecified = unlimited
Fee : number
    How much you need to  pay to store your car, as a one time payment
HourlyFee : number TODO
    How much you have to pay to store your car, per hour
SocietyFee : string
    Transfer the fees to this society account in addon_accounts. Requires esx_society

Permissions : you need to specify at least one or you won't be able to store anything in the garage
 AllowOwned : false, "store", "retrieve", true
    true allow you to store and retrieve vehicle you own from the parking. "store" and "retrieve" allow you only to store or only  to retrieve. false means the garage doesn't work that way, same as if you  don't specify anything
 AllowJob : false, "store", "retrieve", true
    true allow you to store and retrieve vehicle from  your job from the parking. "store" and "retrieve" allow you only to store or only to retrieve. false means the garage doesn't work that way, same as if you don't specify anything
 AllowAll : false, "store", "retrieve", true
    true allow you to store and retrieve any vehicle from the parking. "store" and "retrieve" allow you only to store or only to retrieve. false means the garage doesn't work that way, same as if you don't specify anything. 

Spawn = {
    Location : vector3 (REQUIRED)
        the location of the spot where you can take out vehicles. That's where the blip will be.
    Spawns : vector4 or array of vector4 (REQUIRED)
        a list of spawn points for vehicles. Position and heading.
    Size : float
        the size of the interactable zone. Affects interaction and marker
    Marker : integer
        Marker sprite https://docs.fivem.net/docs/game-references/markers/
    Color : vector4
        RGBA color value for the marker 
    DrawDistance : float
        Max distance to draw marker
}

Dropoff = {
    Location : vector3 (REQUIRED)
        location where you can take vehicles to store them
    Size : float
        the size of the interactable zone. Affects interaction and marker. Will use default marker value from config.lua if unspecified
    Marker : integer
        Marker sprite https://docs.fivem.net/docs/game-references/markers/ Will use default value from config.lua if unspecified
    Color : table
        RGBA color value (0-255) for the marker. Will use default value from config.lua if unspecified
    DrawDistance : float
        Max distance to draw marker. Will use default value from config.lua if unspecified
}

Blip = { -- Anything you don't specify will take the default value from config.lua
    Location : vector3
        Location of the blip. defaults to the location of the spawn marker
    Category : string
        The text the blip will be listed as on the main map.
    Show : bool
    Sprite : integer
        https://docs.fivem.net/docs/game-references/blips/#blips
    Color : integer
        https://docs.fivem.net/docs/game-references/blips/#blip-colors
    Scale : float
    Display : integer
        0 : hidden
        2 : main map (selectable) & minimap 
        3 : main map (selectable) 
        5 : minimap 
        8 : main map (not selectable) & minimap
}
```


---------------------------------
-- INITIALISATION AND MAIN LOOP--
---------------------------------

--Main garage database received from server
Garages = {}

--Main loop
CreateThread(function()
	while not ESX.PlayerLoaded do Wait(10) end

    --Main loop
    while true do
        Wait(1)

        for i,v in pairs(Garages) do
            if CanPlayerOpenGarage(v) then
                if IsPedInAnyVehicle(PlayerPedId(), false) then 
                    HandleDropoff(v)
                else 
                    HandleLocation(v)
                end
            end
        end

    end
end)

--Marker drawing. Takes either a Spawn or Dropoff object from a garage structure
function GarageMarker(marker, label, distance)
    if label == nil or label =="" then label = "Garage" end

    if distance<marker.DrawDistance then
        DrawMarker(marker.Marker, 
            marker.Location.x, marker.Location.y, marker.Location.z-0.95,
		    0.0, 0.0, 0.0,
    		0.0, 0.0, 0.0,
	    	marker.Size, marker.Size, 1.0,
		    marker.Color[1], marker.Color[2], marker.Color[3], marker.Color[4],
		    false, false, 2, false, nil, nil, false )
    end
    if distance<marker.Size/2 and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), name) then
        ESX.ShowHelpNotification('~INPUT_CONTEXT~ '..label , true, false, 50)
    end
end

---------------------------------
-- GARAGES UPDATES FROM SERVER --
---------------------------------

--creates a fresh set of blips
function CreateBlips()
    for i,v in pairs(Garages) do
       if CanPlayerOpenGarage(v) and v.Blip.Show==true then
            --Draw blip for public parkings
            v.Blip.Object = AddBlipForCoord(v.Blip.Location.x, v.Blip.Location.y, v.Blip.Location.z)
            SetBlipSprite(v.Blip.Object, v.Blip.Sprite)
            SetBlipColour(v.Blip.Object, v.Blip.Color)
            SetBlipScale(v.Blip.Object, v.Blip.Scale)
            SetBlipDisplay(v.Blip.Object, v.Blip.Display)
            SetBlipAsShortRange(v.Blip.Object, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Blip.Category)
            EndTextCommandSetBlipName(v.Blip.Object)
        end
    end
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Citizen.Trace("Stopping resource")
        for i,v in pairs(Garages) do
            if v.Blip and v.Blip.Object then
                RemoveBlip(v.Blip.Object)
            end
        end
    end
end)

RegisterNetEvent('rw_garage:update') 
AddEventHandler('rw_garage:update', function(g)
	while not ESX.PlayerLoaded do Wait(1) end

    for i,v in pairs(g) do
        if v.Blip and v.Blip.Object then 
            RemoveBlip(v.Blip.Object)
        end
    end
    Garages = g
    CreateBlips()
end)

------------------
-- ACCESS CHECK --
------------------

--When you change this change the server equivalent too
function CanPlayerOpenGarage(garage)
    if garage.Job then
        for k,v in pairs(garage.Job)  do
            if k==ESX.GetPlayerData().job.name and v<=ESX.GetPlayerData().job.grade then return true end
        end
    else return true end
    return false
end

-------------
-- TAKE OUT--
-------------

function OpenGarageMenu(garagename)
    if IsGarageMenuOpen(garagename) then return end

    ESX.TriggerServerCallback('rw_garage:listVehicles', function(vehicles, label, count, spots)
        --make menu elements TODO : make two columns job vehicles on one side on job garages
        local Elements = {}

        for i,v in pairs(vehicles) do 
            local l = v.Name
            if not l or l=="" then 
                l = v.Plate.." - "..GetDisplayNameFromVehicleModel(v.Model) 
            end
            if v.Fee and v.Fee~="" then 
                l = l.." - $"..vehicles[i].Fee.." fee" 
            end
            table.insert(Elements, {data = garagename, cols = {l,'{{Take|'..v.Plate..'}}'}})
        end

        --Add placeholder if no other items
        if #Elements<1 then
            table.insert(Elements, {data = garagename, cols = {"Pas de vehicle",''}})
        end

        --menu's ready, let's start it
        local l =label
        if spots then l = l.." "..count.."/"..spots end
        ESX.UI.Menu.Open("list", GetCurrentResourceName(), garagename, 
            {
                head = {l, 'Actions'},
                rows = Elements
            }, 

            --Element selected
            function(data,menu)
                --Spawn la voituure !
                Citizen.Trace(data.value..'\n')
                if data.value ~="NoVehicle" then
                    menu.close()
                    ESX.Progressbar("Taking vehicle", Config.TakeTimer,{
                        FreezePlayer = true, 
                        onFinish = function()
                            TriggerServerEvent("rw_garage:takeVehicle", garagename, data.value )
                        end
                    })
                end
            end,

            --Menu canceled
            function(data, menu)
                menu.close()
            end
        )
    end, garagename)
end

function CloseGarageMenu(garagename)
    return ESX.UI.Menu.Close("default", GetCurrentResourceName(), garagename)
end

function IsGarageMenuOpen(garagename)
    return ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), garagename)
end

--Handling of the spawn spot, where you take out your car
function HandleLocation(garage)
    if garage.Spawn.Marker==-1 then return end
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - garage.Spawn.Location)

    GarageMarker(garage.Spawn, garage.Label, distance)

    --Handle Menu
    if distance < garage.Spawn.Size/2 then 
        if IsControlJustPressed(0,51) and not IsGarageMenuOpen() then
            OpenGarageMenu(garage.Name)
        end
    else
        if IsGarageMenuOpen(garage.Name) and (distance>garage.Spawn.Size*2 or distance > 20) then
            CloseGarageMenu(garage.Name)
        end
    end
end

-------------
-- DROPOFF --
-------------

function StoreVehicle(vehicle, garagename)
    ESX.Progressbar("Storing vehicle", Config.TakeTimer,{
        FreezePlayer = true, 
        onFinish = function()
            TriggerServerEvent("rw_garage:storeVehicle", garagename, NetworkGetNetworkIdFromEntity(vehicle))
        end
    })
end

--Handling of the Dropoff spot, to store cars
function HandleDropoff(garage)
    if garage.Dropoff.Marker==-1 then return end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - garage.Dropoff.Location)

    GarageMarker(garage.Dropoff, label, distance)

    if distance < garage.Dropoff.Size/2 then 
        if IsControlJustPressed(0,51) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            StoreVehicle(vehicle, garage.Name)
            return
        end
    end
end

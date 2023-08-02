
Garages = {}

-----------------------------------
-- REGISTER / UNREGISTER GARAGES --
--       Those are exports       --
-----------------------------------

--Export function to register a garage
function RegisterGarage(garage)
    _RegisterGarage(garage)
    --Update everyone on the new Garage
    TriggerClientEvent('rw_garage:update', -1, Garages) 
end

-- register a garage
function _RegisterGarage(garage)
    --Check the necessary components are here
    if type(garage.Name) ~= 'string' or garage.Name =='' then
        Citizen.Trace("Failed to register nameless garage\n")
        return false
    end
    if type(garage.Spawn) ~= 'table' then
        Citizen.Trace("Failed to register spawnless garage "..garage.Name.."\n")
        return false
    end
    if type(garage.Spawn.Location) ~= 'vector3' then
        Citizen.Trace("Failed to register garage with no spawn location "..garage.Name.."\n")
        return false
    end
    if type(garage.Spawn.Spawns) ~= 'vector3' then
        if type(garage.Spawn.Spawns) ~= 'table' then
            Citizen.Trace("Failed to register garage with no spawn points "..garage.Name.."\n")
            return false
        else
            --Spawns are a table, check that they're all vectors
            for k,v in pairs(garage.Spawn.Spawns) do
                if type(v) ~= 'vector4' then
                    Citizen.Trace("Failed to register garage with incorrect spawn list "..type(v).." "..garage.Name.."\n")
                    return false
                end
            end
        end
    else
        --Turn single position to a table for consistent use
        garage.Spawn.Spawns = {garage.Spawn.Spawns}
    end
    if type(garage.Dropoff) ~= 'table' then
        Citizen.Trace("Failed to register garage with no dropoff "..garage.Name.."\n")
        return false
    end
    if type(garage.Dropoff.Location) ~= 'vector3' then
        Citizen.Trace("Failed to register garage with no dropoff location "..garage.Name.."\n")
        return false
    end

    --Normalize optional components. Incorrect values become nil
    if type(garage.Label) ~= 'string' and type(garage.Label) ~= 'nil' then
        garage.Label = nil
    end
    if type(garage.Job) ~= 'nil' then
        if type(garage.Job) ~= 'table' then
            garage.Job = nil
        else
            for k,v in pairs(garage.Job) do
                if type(k)~='string' or type(v)~='number' then
                    Citizen.Trace("Wrong definition of job")
                    table.remove(garage.Job, k) --WARNING : Modify a table while reading it ?
                end
            end
        end
    end
    if type(garage.Spots)~='number' then garage.Spots=nil end
    if type(garage.Fee)~='number' then garage.Fee=nil end
    if type(garage.HourlyFee)~='number' then garage.HourlyFee=nil end
    if type(garage.SocietyFee)~='string' then garage.SocietyFee=nil end

    if garage.AllowOwned == nil then garage.AllowOwned = false end
    if garage.AllowOwned ~= false and garage.AllowOwned ~= 'store' and garage.AllowOwned ~= 'retrieve' and garage.AllowOwned ~= true then
        Garage.AllowOwned = false
    end
    if garage.AllowJob == nil then garage.AllowJob = false end
    if garage.AllowJob ~= false and garage.AllowJob ~= 'store' and garage.AllowJob ~= 'retrieve' and garage.AllowJob ~= true then
        Garage.AllowJob = false
    end
    if garage.AllowAll == nil then garage.AllowAll = false end
    if garage.AllowAll ~= false and garage.AllowAll ~= 'store' and garage.AllowAll ~= 'retrieve' and garage.AllowAll ~= true then
        Garage.AllowAll = false
    end

    --Fill default values
    if type(garage.Spawn.Size) ~= 'number' then
        garage.Spawn.Size = Config.DefaultMarker.Size
    end
    if type(garage.Spawn.Marker) ~= 'number' then
        garage.Spawn.Marker = Config.DefaultMarker.Marker
    end
    if type(garage.Spawn.Color) ~= 'table' then
        garage.Spawn.Color = Config.DefaultMarker.Color
    end
    if type(garage.Spawn.DrawDistance) ~= 'number' then
        garage.Spawn.DrawDistance = Config.DefaultMarker.DrawDistance
    end

    if type(garage.Dropoff.Size) ~= 'number' then
        garage.Dropoff.Size = Config.DefaultMarker.Size
    end
    if type(garage.Dropoff.Marker) ~= 'number' then
        garage.Dropoff.Marker = Config.DefaultMarker.Marker
    end
    if type(garage.Dropoff.Color) ~= 'table' then
        garage.Dropoff.Color = Config.DefaultMarker.Color
    end
    if type(garage.Dropoff.DrawDistance) ~= 'number' then
        garage.Dropoff.DrawDistance = Config.DefaultMarker.DrawDistance
    end

    if type(garage.Blip) ~= 'table' then
        garage.Blip = {}
    end
    if type(garage.Blip.Location) ~= 'vector3' then
        garage.Blip.Location = garage.Spawn.Location
    end
    if type(garage.Blip.Show) ~= 'boolean' then
        garage.Blip.Show = Config.DefaultBlip.Show
    end
    if type(garage.Blip.Sprite) ~= 'number' then
        garage.Blip.Sprite = Config.DefaultBlip.Sprite
    end
    if type(garage.Blip.Color) ~= 'number' then
        garage.Blip.Color = Config.DefaultBlip.Color
    end
    if type(garage.Blip.Scale) ~= 'number' then
        garage.Blip.Scale = Config.DefaultBlip.Scale
    end
    if type(garage.Blip.Display) ~= 'number' then
        garage.Blip.Display = Config.DefaultBlip.Display
    end
    if type(garage.Blip.Category) ~= 'string' then
        garage.Blip.Category = Config.DefaultBlip.Category
    end


    table.insert(Garages, garage)
    return true
end

--Unregister garage with garage name
function UnregisterGarage(garageName)
    for i,v in ipairs(Garages) do
        if v.Name == garageName then
            Citizen.Trace("Unregistered garage "..v.Name.."\n")
            table.remove(Garages, i) 
            TriggerClientEvent('rw_garage:update', -1, Garages)
            return true
        end
    end
    return false
end

--------------------------------
-- INITIALIZATION AND UPDATES --
--------------------------------

--Initialization
AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        --Check we have the default values we need, or just make them up
        if type(Config.DefaultBlip) ~= 'table' then
            Config.DefaultBlip = {}
        end
        if type(Config.DefaultBlip.Show) ~= 'boolean' then
            Config.DefaultBlip.Show = true
        end
        if type(Config.DefaultBlip.Category) ~= 'string' then
            Config.DefaultBlip.Category = "Garage"
        end
        if type(Config.DefaultBlip.Sprite) ~= 'number' then
            Config.DefaultBlip.Sprite = 50
        end
        if type(Config.DefaultBlip.Color) ~= 'number' then
            Config.DefaultBlip.Color = 26
        end
        if type(Config.DefaultBlip.Scale) ~= 'number' then
            Config.DefaultBlip.Scale = 1.0
        end
        if type(Config.DefaultBlip.Display) ~= 'number' then
            Config.DefaultBlip.Display = 2
        end

        if type(Config.DefaultMarker) ~= 'table' then
            Config.DefaultMarker = {}
        end
        if type(Config.DefaultMarker.Size) ~= 'number' then
            Config.DefaultMarker.Size = 1.0
        end
        if type(Config.DefaultMarker.Marker) ~= 'number' then
            Config.DefaultMarker.Marker = 27
        end
        if type(Config.DefaultMarker.Color) ~= 'table' then
            Config.DefaultMarker.Color = {64,64,255,128}
        end
        if type(Config.DefaultMarker.DrawDistance) ~= 'number' then
            Config.DefaultMarker.DrawDistance = 25
        end
        --Load garages from config file
        for i,v in pairs(Config.Garages) do 
            _RegisterGarage(v)
        end
        --Update everyone on the new Garage
        Wait(100) --Give time for clients to load in case of resource restart
        TriggerClientEvent('rw_garage:update', -1, Garages)
    end
end)

--Update new players with up to date garage information
RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    TriggerClientEvent('rw_garage:update', player, Garages)
end)

------------------
-- ACCESS CHECK --
------------------

--When you change this change the client equivalent too
function CanPlayerOpenGarage(garage, xPlayer)
    if garage.Job then
        for k,v in pairs(garage.Job)  do
            if k==xPlayer.getJob().name and v<=xPlayer.getJob().grade then return true end
        end
    else return true end
    return false
end

--garage is garage object, car is a sql querry result, xplayer is the esx object of the player requesting
function CanPlayerTakeCar(garage, car, xPlayer)
    if (garage.AllowAll ==true or garage.AllowAll =="retrieve" )  then return true end
    if (garage.AllowOwned ==true or garage.AllowOwned =="retrieve" ) and car.owner == xPlayer.getIdentifier() then return true end
    if (garage.AllowJob ==true or garage.AllowJob =="retrieve" ) and garage.job == xPlayer.getJob().name and garage.job == car.job then return true end
    return false
end

--garage is garage object, car is a sql querry result, xplayer is the esx object of the player requesting
function CanPlayerStoreCar(garage, car, xPlayer)
    if (garage.AllowAll ==true or garage.AllowAll =="store" )  then return true end
    if (garage.AllowOwned ==true or garage.AllowOwned =="store" ) and car.owner == xPlayer.getIdentifier() then return true end
    if (garage.AllowJob ==true or garage.AllowJob =="store" ) and garage.job == xPlayer.getJob().name and garage.job == car.job then return true end
    return false
end

-----------------------
-- TAKE OUT VEHICLES --
-----------------------
 
-- List vehicles
ESX.RegisterServerCallback('rw_garage:listVehicles', function(source, cb, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
    local playerCoords = xPlayer.getCoords(true)
    local r = {}

    --Check user is autorized to use this garage
    Garageobj = nil
    for i,v in ipairs(Garages) do 
        distance = #(playerCoords - v.Spawn.Location)
        if distance<v.Spawn.Size*2 and v.Name==garage then --A bit of leeway in distance for server lag
            if CanPlayerOpenGarage(v, xPlayer) then Garageobj = v end
        end
    end
    if not Garageobj then
        TriggerClientEvent('esx:showNotification', source, Translate('rwg_garagenotfound'), "error")
        cb(r,-1)
        return
    end

    --Build the list of cars in garage
    local count = -1
    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE stored > 0 AND parking = ?', 
        { garage })
    if result then
        count = #result
        for i,v in ipairs(result) do
            if CanPlayerTakeCar(Garageobj, v, xPlayer) then
                local vehicleProps = json.decode(v.vehicle)
                local fee = 0
                if type(v.pound)=='number' then fee = v.pound end
                table.insert(r, {
                    Plate = v.plate, 
                    Model = vehicleProps["model"], 
                    Name = v.name,
                    Fee = v.pound,
                })
            end
        end
    end
    cb(r, count)
end)

-- sortir vehicules
RegisterServerEvent('rw_garage:takeVehicle')
AddEventHandler('rw_garage:takeVehicle', function(garage, plate)
    local source = source
    for i, v in pairs(Garages) do
        if v.Name == garage then
            --Got the right garage
            local xPlayer = ESX.GetPlayerFromId(source)
            local playerCoords = xPlayer.getCoords(true)
            distance = #(playerCoords - v.Spawn.Location)

            --Can the player access the garage ?
            if distance > v.Spawn.Size*2 then
                TriggerClientEvent('esx:showNotification', source, Translate('rwg_toofar'), "error")
                return
            end
            if not CanPlayerOpenGarage(garage, xPlayer) then 
                TriggerClientEvent('esx:showNotification', source, Translate('rwg_accessdenied'), "error")
                return 
            end

            --Check vehicle is in the garage and the player is allowed to take it out
            local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ? AND stored = 1 AND parking = ?',
                { plate, garage})
            if not result or #result~=1 then
                TriggerClientEvent('esx:showNotification', source, Translate('rwg_carnotfound'), "error")
                return
            end
            if not CanPlayerTakeCar(v, result[1], xPlayer) then  --plate is unique
                TriggerClientEvent('esx:showNotification', source, Translate('rwg_cardenied'), "error")
                return
            end

            -- Pay the fee
            local fee = tonumber(result[1].pound)
            if fee then
                xPlayer.removeAccountMoney('bank',fee)
                TriggerClientEvent('esx:showNotification', source, Translate('rwg_fee')..fee, "success")
                --add money to a society account
                if v.SocietyFee then
                    local rows = MySQL.update.await('UPDATE addon_account_data SET money = money + ? WHERE account_name = ?', {fee, v.SocietyFee} )
                end
            end
 
            --All good, take it out !
            local props = json.decode(result[1].vehicle)
            TriggerClientEvent('rw_garage:spawncar', source, v.Spawn.Spawns, props)
            --Update db
            MySQL.update('UPDATE owned_vehicles SET stored = 0, pound = NULL WHERE plate = ?', { plate }, function(affectedRows) end)
            --All done !
            return
        end
    end
end)

---------------------
-- DROPOFF VEHICLE --
---------------------

-- Rentrer vehicule
RegisterServerEvent('rw_garage:storeVehicle')
AddEventHandler('rw_garage:storeVehicle', function(garage, plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    --check we're at garage dropoff
    local garageobj = nil
    for i,v in ipairs(Garages) do 
        if v.Name == garage then
            local distance = #(v.Dropoff.Location - xPlayer.getCoords(true))
            if distance < v.Dropoff.Size*2 then -- Leeway on distance for server lag
                garageobj = v
                break
            end
        end
    end
    if not garageobj then
        TriggerClientEvent('esx:showNotification', source, Translate('rwg_toofar'), "error")
        return
    end

    --Check that garage is not full
    if garageobj.Spots then
        local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE stored = 1 AND parking = ?', 
            { garage })
        if result then
            if #result>=garageobj.Spots then
                TriggerClientEvent('esx:showNotification', source, Translate('rwg_full'), "error")
                return
            end
        end
    end

    --actually store the car
    MySQL.query('SELECT * FROM owned_vehicles WHERE plate = ?', { plate }, function(result)
        --Log inconsitent results
        if not result or #result<1 then
            TriggerClientEvent('esx:showNotification', source, Translate('rwg_noplate'), "error")
            return
        end
        if #result>1 then 
            TriggerClientEvent('esx:showNotification', source, Translate('rwg_duplicateplate'), "error")
            Citizen.Trace("ERROR ! Plate "..plate.." is not unique !\n")
            --TODO : still look for a match ? with model or something ?
            return
        end
        if result[1].stored~=0 then 
            Citizen.Trace("Vehicle "..plate.." duped, storing already stored vehicle. Player id : "..xPlayer.identifier.."\n") 
        end

        --Check the player can store that car
        if not CanPlayerStoreCar(garageobj, result[1], xPlayer) then 
            TriggerClientEvent('esx:showNotification', source, Translate('rwg_storedenied'), "error")
            return 
        end
        --Calculate the fee
        local fee = 0
        if tonumber(result[1].pound) then fee +=tonumber(result[1].pound) end --Keep existing fee
        if garageobj.Fee then fee+=garageobj.Fee end --Add flat fee
        --formating fee
        if fee>0 then fee = tostring(fee)
        else fee = nil end

        --All good !
        local rows = MySQL.update.await('UPDATE owned_vehicles SET stored = 1, parking = ?, pound = ? WHERE plate = ?', {garage, fee, plate} )
        if rows==1 then TriggerClientEvent('rw_garage:despawncar', source)
        else TriggerClientEvent('esx:showNotification', source, Translate('rwg_carnotfound'), "error") end
    end)
end)

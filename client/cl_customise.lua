-- ██████   ██████  ██      ██  ██████ ███████      █████  ██      ███████ ██████  ████████ 
-- ██   ██ ██    ██ ██      ██ ██      ██          ██   ██ ██      ██      ██   ██    ██    
-- ██████  ██    ██ ██      ██ ██      █████       ███████ ██      █████   ██████     ██    
-- ██      ██    ██ ██      ██ ██      ██          ██   ██ ██      ██      ██   ██    ██    
-- ██       ██████  ███████ ██  ██████ ███████     ██   ██ ███████ ███████ ██   ██    ██    
                                                                                                                                                                                  
function PoliceCall(vehicle)
    if Config.Dispatch == "ps" then
        exports['ps-dispatch']:VehicleTheft(vehicle)
    elseif Config.Dispatch == "qb"
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local msg = ''
        local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        local streetLabel = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        if street2 ~= nil and street2 ~= '' then
            streetLabel = streetLabel .. ' ' .. street2
        end
        local alertTitle = ''
        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
            if QBCore.Shared.Vehicles[modelName] ~= nil then
                Name = QBCore.Shared.Vehicles[modelName]['brand'] .. ' ' .. QBCore.Shared.Vehicles[modelName]['name']
            else
                Name = 'Unknown'
            end
            local modelPlate = QBCore.Functions.GetPlate(vehicle)
            local msg = 'Vehicle theft attempt at ' .. streetLabel .. '. Vehicle: ' .. Name .. ', Licenseplate: ' .. modelPlate
            local alertTitle = 'Vehicle theft attempt at'
            TriggerServerEvent('police:server:VehicleCall', pos, msg, alertTitle, streetLabel, modelPlate, Name)
        else
            local vehicle = QBCore.Functions.GetClosestVehicle()
            local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
            local modelPlate = QBCore.Functions.GetPlate(vehicle)
            if QBCore.Shared.Vehicles[modelName] ~= nil then
                Name = QBCore.Shared.Vehicles[modelName]['brand'] .. ' ' .. QBCore.Shared.Vehicles[modelName]['name']
            else
                Name = 'Unknown'
            end
            local msg = 'Vehicle theft attempt at ' .. streetLabel .. '. Vehicle: ' .. Name .. ', Licenseplate: ' .. modelPlate
            local alertTitle = 'Vehicle theft attempt at'
            TriggerServerEvent('police:server:VehicleCall', pos, msg, alertTitle, streetLabel, modelPlate, Name)
        end
    else
        -- Impliment your dispatch here
    end
end

-- ██       ██████   ██████ ██   ██ ██████  ██  ██████ ██   ██ 
-- ██      ██    ██ ██      ██  ██  ██   ██ ██ ██      ██  ██  
-- ██      ██    ██ ██      █████   ██████  ██ ██      █████   
-- ██      ██    ██ ██      ██  ██  ██      ██ ██      ██  ██  
-- ███████  ██████   ██████ ██   ██ ██      ██  ██████ ██   ██ 
                                                                                                                        
function lockpickFinish(success)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify(Config.Lang['vehicle_door_opened'], 'success')
        SetVehicleDoorsLocked(vehicle, 1)
    else
        PoliceCall(vehicle)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify(Config.Lang['pd_was_called'], 'error')
    end
    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['advancedlockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'advancedlockpick', 1)
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['lockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'lockpick', 1)
        end
    end
end

function hotwireFinish(success)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify(Config.Lang['success.successful_hotwire'], 'success')
        SetVehicleDoorsLocked(vehicle, 1)
        local plate = QBCore.Functions.GetPlate(vehicle)
		AddTempKey(plate)
    else
        PoliceCall(vehicle)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify(Config.Lang['error.someone_called_the_police'], 'error')
    end
    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['advancedlockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'advancedlockpick', 1)
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['lockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'lockpick', 1)
        end
    end
end

function UseLockpick(isAdvanced)
    local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	if IsPedInAnyVehicle(ped, false) then
		local veh = GetVehiclePedIsIn(ped)
		local plate = QBCore.Functions.GetPlate(veh)
		local driver = GetPedInVehicleSeat(veh, -1)
		if driver == ped then
			if not HasVehicleKey(plate) then
				usingAdvanced = isAdvanced
				TriggerEvent('qb-lockpick:client:openLockpick', hotwireFinish)
			end
		end
	else
		local veh = QBCore.Functions.GetClosestVehicle(pos)
		local plate = QBCore.Functions.GetPlate(veh)
		if veh ~= nil and veh ~= 0 and not HasVehicleKey(plate) then
			local vehpos = GetEntityCoords(veh)
			if #(pos - vehpos) < 2.5 then
				local vehLockStatus = GetVehicleDoorLockStatus(veh)
				if (vehLockStatus > 0) then
					usingAdvanced = isAdvanced
					TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
				end
			end
		end
	end
end

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    UseLockpick(isAdvanced)
end)
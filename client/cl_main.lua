KeyList = {}
IsVehicleEngineOn = false
IsEnteringVehicle = false
IsInVehicle = false
QBCore = exports[Config.CoreName]:GetCoreObject()

-- ███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████ 
-- ██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██      
-- █████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████ 
-- ██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██ 
-- ██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████ 
                                                                                                                                                  
function HasVehicleKey(plate)
	local has = false
	for _, v in pairs(KeyList) do
		if plate == v then
			has = true
			break
		end
	end
	return has
end
exports('HasVehicleKey', HasVehicleKey)

function AddVehicleKey(plate, isperm)
	if isperm then TriggerServerEvent('cad-keys:addVehKeys', plate) end
	if not HasVehicleKey(plate) then
		KeyList[#KeyList+1] = plate
	end
end

function RemoveVehicleKey(plate, isperm)
	local got = false
	for i, key in pairs(KeyList) do
		if key == plate then
			table.remove(KeyList, i)
		end
	end
	if isperm then TriggerServerEvent('cad-keys:deleteKeys', plate) end
end

function GetVehicleByPlate(kPlate)
	local vehicle = 0
	local vehicles = GetGamePool("CVehicle")
	for _, veh in pairs(vehicles) do
		local vPlate = GetVehicleNumberPlateText(veh)
		if kPlate == vPlate then
			vehicle = veh
			break
		end
	end
	return vehicle
end
exports('GetVehicleByPlate', GetVehicleByPlate)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

-- ███████ ██    ██ ███████ ███    ██ ████████ ███████ 
-- ██      ██    ██ ██      ████   ██    ██    ██      
-- █████   ██    ██ █████   ██ ██  ██    ██    ███████ 
-- ██       ██  ██  ██      ██  ██ ██    ██         ██ 
-- ███████   ████   ███████ ██   ████    ██    ███████ 
                                                                                                    
RegisterNetEvent('cad-keys:getClientKeys', function()
	local p = promise.new()
	QBCore.Functions.TriggerCallback('cad-keys:getKeys', function(keys)
		p:resolve(keys)
	end)
	KeyList = Citizen.Await(p)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	CreateThread(function()
		Wait(2000)
		TriggerEvent('cad-keys:getClientKeys')
	end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    KeysList = {}
end)

RegisterNetEvent('cad-keys:addClientKeys', function(plate, isperm)
	if isperm == nil then isperm = false end
	AddVehicleKey(plate, isperm)
end)

RegisterNetEvent('cad-keys:deleteClientKeys', function(plate)
    TriggerServerEvent('cad-keys:deleteKeys', plate)
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate, isperm)
	if isperm == nil then isperm = false end
	AddVehicleKey(plate, isperm)
end)


RegisterNetEvent('cad-keys:addClientData', function(plate)
	local has = false
	for _, v in pairs(KeyList) do
		if plate == v then
			has = true
		end
	end
	if not has then KeyList[#KeyList+1] = plate end
end)

RegisterNetEvent('cad-keys:removeClientData', function(plate)
	local got = false
	for i, key in pairs(KeyList) do
		if key == plate then
			table.remove(KeyList, i)
		end
	end
end)

RegisterNetEvent('cad-keys:toggleEngine', function()
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped, false) then
		local veh = GetVehiclePedIsIn(ped)
		local plate = QBCore.Functions.GetPlate(veh)
		if HasVehicleKey(plate) then
			IsVehicleEngineOn = not IsVehicleEngineOn
		else
			ShowNotification(Config.Lang['you_dont_have_keys'], 'error')
		end
	end
end)

RegisterNetEvent('cad-keys:lockVehicle',function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = QBCore.Functions.GetClosestVehicle(pos)
	if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
    end
    local plate = QBCore.Functions.GetPlate(veh)
    local vehpos = GetEntityCoords(veh)    
    if veh ~= nil and #(pos - vehpos) < 7.5 then
		if HasVehicleKey(plate) then
			local vehLockStatus = GetVehicleDoorLockStatus(veh)
			LoadAnimDict('anim@mp_player_intmenu@key_fob@')
			TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)
			if vehLockStatus == 1 then
				Wait(500)
				ClearPedTasks(ped)
				TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'lock', 0.2)
				SetVehicleDoorsLocked(veh, 2)
				if (GetVehicleDoorLockStatus(veh) == 2) then
					if not IsPedInAnyVehicle(ped) then
						if GetIsVehicleEngineRunning(veh) then
							SetVehicleEngineOn(veh, false, false, true)
							IsVehicleEngineOn = false
						end
						SetVehicleLights(veh, 2)
						Wait(250)
						SetVehicleLights(veh, 1)
						Wait(200)
						SetVehicleLights(veh, 0)
					end
					ShowNotification(Config.Lang['vehicle_locked'])
				else
					ShowNotification(Config.Lang['something_gone_wrong'])
				end
			else
				Wait(500)
				ClearPedTasks(ped)
				TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'unlock', 0.2)
				SetVehicleDoorsLocked(veh, 1)
				if (GetVehicleDoorLockStatus(veh) == 1) then
					if not IsPedInAnyVehicle(ped) then
						SetVehicleLights(veh, 2)
						Wait(250)
						SetVehicleLights(veh, 1)
						Wait(200)
						SetVehicleLights(veh, 0)
					end
					ShowNotification(Config.Lang['vehicle_unlocked'])
				else
					ShowNotification(Config.Lang['something_gone_wrong'])
				end
			end
		else
			ShowNotification(Config.Lang['you_dont_have_keys'], 'error')
		end
    end
end)

-- ██    ██ ███████ ██   ██ ██  ██████ ██      ███████      █████  ███    ██ ██████      ██       ██████   ██████ ██   ██ ███████ 
-- ██    ██ ██      ██   ██ ██ ██      ██      ██          ██   ██ ████   ██ ██   ██     ██      ██    ██ ██      ██  ██  ██      
-- ██    ██ █████   ███████ ██ ██      ██      █████       ███████ ██ ██  ██ ██   ██     ██      ██    ██ ██      █████   ███████ 
--  ██  ██  ██      ██   ██ ██ ██      ██      ██          ██   ██ ██  ██ ██ ██   ██     ██      ██    ██ ██      ██  ██       ██ 
--   ████   ███████ ██   ██ ██  ██████ ███████ ███████     ██   ██ ██   ████ ██████      ███████  ██████   ██████ ██   ██ ███████ 
                                                                                                                               
AddEventHandler("baseevents:enteringVehicle", function(targetVehicle, vehicleSeat, vehicleDisplayName)
	CreateThread(function()
		IsEnteringVehicle = true
		while DoesEntityExist(targetVehicle) and IsEnteringVehicle do
			local ped = PlayerPedId()			
			local veh = targetVehicle
            local lock = GetVehicleDoorLockStatus(veh)
			local plate = QBCore.Functions.GetPlate(veh)
			local driver = (vehicleSeat == -1)
			local luck = math.random(1, 100)
            if HasVehicleKey(plate) then
				SetVehicleDoorsLocked(veh, 1)
				SetVehicleDoorsLockedForAllPlayers(veh, false)
			end			
			if driver and Config.CanPedBeDraggedOut then
                SetPedCanBeDraggedOut(driver, false)
            end
            if Config.VehicleUnlockedChance >= 100 then
                Config.VehicleUnlockedChance = 100
            elseif Config.VehicleUnlockedChance <= 0 then
                Config.VehicleUnlockedChance = 0
            end
            if (Config.VehicleUnlockedChance >= luck) then
                SetVehicleDoorsLocked(veh, 1)
            elseif (GetConvertibleRoofState(veh) == 1) or (GetConvertibleRoofState(veh) == 2) then
                SetVehicleDoorsLocked(veh, 1)
            elseif (IsVehicleDoorFullyOpen(veh, 0)) or (IsVehicleDoorFullyOpen(veh, 1)) or (IsVehicleDoorFullyOpen(veh, 2)) or (IsVehicleDoorFullyOpen(veh, 3)) or not DoesVehicleHaveDoor(veh, 0) then
                SetVehicleDoorsLocked(veh, 1)
            elseif lock == 0 or lock == 7 or lock == 3 then
                SetVehicleDoorsLocked(veh, 2)
            end
			Wait(500)
		end
	end)
end)
                                                                                                                           
AddEventHandler("baseevents:enteringAborted", function()
	IsEnteringVehicle = false
end)

AddEventHandler("baseevents:enteredVehicle", function(currentVehicle, currentSeat, vehicleDisplayName)
	IsEnteringVehicle = false
	CreateThread(function()
		IsInVehicle = true
		while DoesEntityExist(currentVehicle) and IsInVehicle do
			local veh = currentVehicle
			local plate = QBCore.Functions.GetPlate(veh)
			local driver = GetPedInVehicleSeat(veh, -1)
			if driver then
				if HasVehicleKey(plate) then
					if not IsVehicleEngineOn then
						SetVehicleEngineOn(veh, false, false, true)
					else
						SetVehicleEngineOn(veh, true, false, true)
						SetVehicleUndriveable(veh, false)
						SetVehicleJetEngineOn(veh, true)
					end
				else
					SetVehicleEngineOn(veh, false, false, true)
					IsVehicleEngineOn = false
				end
			end
			Wait(100)
		end
	end)
end)

AddEventHandler("baseevents:leftVehicle", function(currentVehicle, currentSeat, vehicleDisplayName)
	IsInVehicle = false
	IsEnteringVehicle = false
end)

-- ███    ██  ██████  ████████ ██ ███████ ██  ██████  █████  ████████ ██  ██████  ███    ██ ███████ 
-- ████   ██ ██    ██    ██    ██ ██      ██ ██      ██   ██    ██    ██ ██    ██ ████   ██ ██      
-- ██ ██  ██ ██    ██    ██    ██ █████   ██ ██      ███████    ██    ██ ██    ██ ██ ██  ██ ███████ 
-- ██  ██ ██ ██    ██    ██    ██ ██      ██ ██      ██   ██    ██    ██ ██    ██ ██  ██ ██      ██ 
-- ██   ████  ██████     ██    ██ ██      ██  ██████ ██   ██    ██    ██  ██████  ██   ████ ███████ 
                                                                                                 
function ShowNotification(msg)
    TriggerEvent("QBCore:Notify", msg, "primary", 5000)
end

-- ██████   ██████  ██      ██  ██████ ███████      █████  ██      ███████ ██████  ████████ 
-- ██   ██ ██    ██ ██      ██ ██      ██          ██   ██ ██      ██      ██   ██    ██    
-- ██████  ██    ██ ██      ██ ██      █████       ███████ ██      █████   ██████     ██    
-- ██      ██    ██ ██      ██ ██      ██          ██   ██ ██      ██      ██   ██    ██    
-- ██       ██████  ███████ ██  ██████ ███████     ██   ██ ███████ ███████ ██   ██    ██    
                                                                                                                                                                                  
function PoliceCall(vehicle)
    if Config.Dispatch == "ps" then
        exports['ps-dispatch']:VehicleTheft(vehicle)
    elseif Config.Dispatch == "qb" then
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
        ShowNotification(Config.Lang['vehicle_door_opened'], 'success')
        SetVehicleDoorsLocked(vehicle, 1)
    else
        PoliceCall(vehicle)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        ShowNotification(Config.Lang['pd_was_called'], 'error')
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
        ShowNotification(Config.Lang['successful_hotwire'], 'success')
        SetVehicleDoorsLocked(vehicle, 1)
        local plate = QBCore.Functions.GetPlate(vehicle)
		AddVehicleKey(plate, false)
    else
        PoliceCall(vehicle)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        ShowNotification(Config.Lang['pd_was_called'], 'error')
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

-- ██       ██████   ██████ ██   ██     ██    ██ ███████ ██   ██ ██  ██████ ██      ███████ 
-- ██      ██    ██ ██      ██  ██      ██    ██ ██      ██   ██ ██ ██      ██      ██      
-- ██      ██    ██ ██      █████       ██    ██ █████   ███████ ██ ██      ██      █████   
-- ██      ██    ██ ██      ██  ██       ██  ██  ██      ██   ██ ██ ██      ██      ██      
-- ███████  ██████   ██████ ██   ██       ████   ███████ ██   ██ ██  ██████ ███████ ███████ 
                                                                                                                                                                                  
RegisterCommand("lockvehicle", function()
	TriggerEvent("cad-keys:lockVehicle")
end, false)
RegisterKeyMapping('lockvehicle', 'Lock/Unlock Vehicle', 'keyboard', 'L')
TriggerEvent('chat:removeSuggestion', '/lockvehicle')

-- ███████ ███    ██  ██████  ██ ███    ██ ███████ 
-- ██      ████   ██ ██       ██ ████   ██ ██      
-- █████   ██ ██  ██ ██   ███ ██ ██ ██  ██ █████   
-- ██      ██  ██ ██ ██    ██ ██ ██  ██ ██ ██      
-- ███████ ██   ████  ██████  ██ ██   ████ ███████ 
                                                
RegisterCommand("engine", function()
	TriggerEvent("cad-keys:toggleEngine")
end, false)
RegisterKeyMapping('engine', 'Toggle Engine', 'keyboard', 'G')
TriggerEvent('chat:addSuggestion', '/engine', 'Turn Vehicle Engine On/Off')


-- ██████  ███████ ██████  ██    ██  ██████  
-- ██   ██ ██      ██   ██ ██    ██ ██       
-- ██   ██ █████   ██████  ██    ██ ██   ███ 
-- ██   ██ ██      ██   ██ ██    ██ ██    ██ 
-- ██████  ███████ ██████   ██████   ██████  

RegisterCommand("list", function()
	print(json.encode(KeyList))
end, false)
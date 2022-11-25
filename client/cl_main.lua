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
	TriggerEvent('cad-keys:getClientKeys')
	Wait(100)
	for _, v in pairs(KeyList) do
		if plate == v then
			has = true
			break
		end
	end
	return has
end
exports('HasVehicleKey', HasVehicleKey)

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
		TriggerServerEvent('cad-keys:deleteWasteKeys')
	end)
end)

RegisterNetEvent('cad-keys:addClientVehKeys', function(plate)
    TriggerServerEvent('cad-keys:addVehKeys', plate)
end)

RegisterNetEvent('cad-keys:deleteClientKeys', function(plate)
    TriggerServerEvent('cad-keys:deleteKeys', plate)
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('cad-keys:addVehKeys', plate)
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
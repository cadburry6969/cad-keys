QBCore = exports[Config.CoreName]:GetCoreObject()

--  ██████  █████  ██      ██      ██████   █████   ██████ ██   ██ ███████ 
-- ██      ██   ██ ██      ██      ██   ██ ██   ██ ██      ██  ██  ██      
-- ██      ███████ ██      ██      ██████  ███████ ██      █████   ███████ 
-- ██      ██   ██ ██      ██      ██   ██ ██   ██ ██      ██  ██       ██ 
--  ██████ ██   ██ ███████ ███████ ██████  ██   ██  ██████ ██   ██ ███████ 
                                                                                                                                                                                                   
QBCore.Functions.CreateCallback('cad-keys:getKeys', function(source, cb)
    local src = source
    local retval = {}
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local items = Player.Functions.GetItemsByName('cadkeys')
		if items then
			for _, v in pairs(items) do
				retval[#retval +1] = v.info.plate
			end
		end
    end
    cb(retval)
end)

-- ███████ ██    ██ ███████ ███    ██ ████████ ███████ 
-- ██      ██    ██ ██      ████   ██    ██    ██      
-- █████   ██    ██ █████   ██ ██  ██    ██    ███████ 
-- ██       ██  ██  ██      ██  ██ ██    ██         ██ 
-- ███████   ████   ███████ ██   ████    ██    ███████ 

RegisterNetEvent('cad-keys:addVehKeys', function(plate)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local info = {}
	info.citizenid = Player.PlayerData.citizenid
	info.plate = plate
	Player.Functions.AddItem('cadkeys', 1, nil, info)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cadkeys'], 'add', 1)
end)

RegisterNetEvent('cad-keys:deleteKeys', function(plate)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
		local items = Player.Functions.GetItemsByName('cadkeys')
		if items then
			for _, v in pairs(items) do										
				if v.info.citizenid == plate then
					Player.Functions.RemoveItem(v.name, 1, v.slot)
					TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.name], 'remove', 1)
				end
			end
		end
    end
end)

-- Never use this event it can cause issues
RegisterNetEvent('cad-keys:deleteWasteKeys', function()
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
		local items = Player.Functions.GetItemsByName('cadkeys')
		if items then
			for _, v in pairs(items) do
				MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?',{v.info.plate}, function(result)
					if result then
						for k, v1 in pairs(result) do
							if v.info.citizenid ~= v1.citizenid then
								Player.Functions.RemoveItem(v.name, 1, v.slot)
								TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.name], 'remove', 1)
							end
						end
					end
				end)
			end
		end
    end
end)

-- ██ ████████ ███████ ███    ███ ███████ 
-- ██    ██    ██      ████  ████ ██      
-- ██    ██    █████   ██ ████ ██ ███████ 
-- ██    ██    ██      ██  ██  ██      ██ 
-- ██    ██    ███████ ██      ██ ███████ 
                                                                              
QBCore.Functions.CreateUseableItem("lockpick", function(source, item)
	TriggerClientEvent('lockpicks:UseLockpick', source, false)
end)

QBCore.Functions.CreateUseableItem("advancedlockpick", function(source, item)
	TriggerClientEvent('lockpicks:UseLockpick', source, true)
end)
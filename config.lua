--  ██████  ██████  ███    ██ ███████ ██  ██████  
-- ██      ██    ██ ████   ██ ██      ██ ██       
-- ██      ██    ██ ██ ██  ██ █████   ██ ██   ███ 
-- ██      ██    ██ ██  ██ ██ ██      ██ ██    ██ 
--  ██████  ██████  ██   ████ ██      ██  ██████  

Config = {}
Config.CoreName = 'qb-core'
-- NOTE: `client/cl_customise.lua` & `server/sv_customise.lua` are editable if you want to make any changes

-- ██       █████  ███    ██  ██████  
-- ██      ██   ██ ████   ██ ██       
-- ██      ███████ ██ ██  ██ ██   ███ 
-- ██      ██   ██ ██  ██ ██ ██    ██ 
-- ███████ ██   ██ ██   ████  ██████  
                                                                      
Config.Lang = {	
	['someone_called_the_police'] = 'Someone called the police!',
	['not_enough_money'] = 'Not enough money!',
	['you_dont_have_the_keys_of_the_vehicle'] = 'You don\'t have the keys of the vehicle..',
	['successful_hotwire'] = 'Successful hotwire!',
	['vehicle_locked'] = 'Vehicle locked!',
	['something_went_wrong_with_the_locking_system'] = 'Something went wrong with the locking system!',
	['vehicle_unlocked'] = 'vehicle_unlocked',
	['vehicle_door_opened'] = 'Door is now open',
	['pd_was_called'] = 'Someone Called The Police',
}

--  ██████  ███████ ███    ██ ███████ ██████   █████  ██      
-- ██       ██      ████   ██ ██      ██   ██ ██   ██ ██      
-- ██   ███ █████   ██ ██  ██ █████   ██████  ███████ ██      
-- ██    ██ ██      ██  ██ ██ ██      ██   ██ ██   ██ ██      
--  ██████  ███████ ██   ████ ███████ ██   ██ ██   ██ ███████ 
                                                                                                                      
Config.CanPedBeDraggedOut = true -- If you can drag out peds from driving seat
Config.VehicleUnlockedChance = 0  -- Chance of vehicle being unlocked over the map

-- ██████  ██ ███████ ██████   █████  ████████  ██████ ██   ██ 
-- ██   ██ ██ ██      ██   ██ ██   ██    ██    ██      ██   ██ 
-- ██   ██ ██ ███████ ██████  ███████    ██    ██      ███████ 
-- ██   ██ ██      ██ ██      ██   ██    ██    ██      ██   ██ 
-- ██████  ██ ███████ ██      ██   ██    ██     ██████ ██   ██ 
                                                                                                                        
-- NOTE: Refer `client/cl_customise.lua` to edit the dispatch and hotwire to your liking
Config.Dispatch = "qb" --  Use `qb` or `ps` or `custom` [Add your own dispatch in `client/cl_customise.lua`]

-- This is only usefull if you are using `qb` as your dispatch
Config.RemoveLockpickNormal = 0.5 -- Chance to remove lockpick on fail
Config.RemoveLockpickAdvanced = 0.2 -- Chance to remove advanced lockpick on fail
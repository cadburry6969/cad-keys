QBCore = exports[Config.CoreName]:GetCoreObject()
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
# Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core) (Latest)
- [qb-target](https://github.com/qbcore-framework/qb-target) (Latest)

## Installation

* Add item info to `qb-inventory\html\js\app.js`

```lua
} else if (itemData.name == "cadkeys") {
    $(".item-info-title").html('<p>' + itemData.label+ '</p>');
    $(".item-info-description").html(
        '<p>Vehicle ID: ' + itemData.info.citizenid +
        '</p><p>Plate: ' + itemData.info.plate +'</p>'
    );
}
```

* Add `images/carkeys.png` to `qb-inventory\html\images`
* Add to `qb-core\shared\items.lua`:

```lua
['cadkeys']  = { ['name'] = 'cadkeys', ['label'] = 'Vehicle Key', ['weight'] = 0, ['type'] = 'item', ['image'] = 'cadkeys.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil,['description'] = '' },
```
* Compare and replace the below functions in `qb-inventory/server/main.lua` (Latest QBCore Only)
```lua
---Add an item to the inventory of the player
---@param source number The source of the player
---@param item string The item to add to the inventory
---@param amount? number The amount of the item to add
---@param slot? number The slot to add the item to
---@param info? table Extra info to add onto the item to use whenever you get the item
---@return boolean success Returns true if the item was added, false it the item couldn't be added
local function AddItem(source, item, amount, slot, info)
	local Player = QBCore.Functions.GetPlayer(source)

	if not Player then return false end

	local totalWeight = GetTotalWeight(Player.PlayerData.items)
	local itemInfo = QBCore.Shared.Items[item:lower()]
	if not itemInfo and not Player.Offline then
		QBCore.Functions.Notify(source, "Item does not exist", 'error')
		return false
	end

	amount = tonumber(amount) or 1
	slot = tonumber(slot) or GetFirstSlotByItem(Player.PlayerData.items, item)
	info = info or {}

	if itemInfo['type'] == 'weapon' then
		info.serie = info.serie or tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
		info.quality = info.quality or 100
	end
	if (totalWeight + (itemInfo['weight'] * amount)) <= Config.MaxInventoryWeight then
		if item == "cadkeys" then
			TriggerClientEvent("cad-keys:addClientData", source, info.plate)
		end
		if (slot and Player.PlayerData.items[slot]) and (Player.PlayerData.items[slot].name:lower() == item:lower()) and (itemInfo['type'] == 'item' and not itemInfo['unique']) then
			Player.PlayerData.items[slot].amount = Player.PlayerData.items[slot].amount + amount
			Player.Functions.SetPlayerData("items", Player.PlayerData.items)

			if Player.Offline then return true end

			TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.PlayerData.citizenid .. ' | id: ' .. source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. Player.PlayerData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. Player.PlayerData.items[slot].amount)

			return true
		elseif not itemInfo['unique'] and slot or slot and Player.PlayerData.items[slot] == nil then
			Player.PlayerData.items[slot] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = slot, combinable = itemInfo['combinable'] }
			Player.Functions.SetPlayerData("items", Player.PlayerData.items)

			if Player.Offline then return true end

			TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.PlayerData.citizenid .. ' | id: ' .. source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. Player.PlayerData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. Player.PlayerData.items[slot].amount)

			return true
		elseif itemInfo['unique'] or (not slot or slot == nil) or itemInfo['type'] == 'weapon' then
			for i = 1, Config.MaxInventorySlots, 1 do
				if Player.PlayerData.items[i] == nil then
					Player.PlayerData.items[i] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = i, combinable = itemInfo['combinable'] }
					Player.Functions.SetPlayerData("items", Player.PlayerData.items)

					if Player.Offline then return true end

					TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.PlayerData.citizenid .. ' | id: ' .. source .. ')** got item: [slot:' .. i .. '], itemname: ' .. Player.PlayerData.items[i].name .. ', added amount: ' .. amount .. ', new total amount: ' .. Player.PlayerData.items[i].amount)

					return true
				end
			end
		end
	elseif not Player.Offline then
		QBCore.Functions.Notify(source, "Inventory too full", 'error')
	end
	return false
end

exports("AddItem", AddItem)

---Remove an item from the inventory of the player
---@param source number The source of the player
---@param item string The item to remove from the inventory
---@param amount? number The amount of the item to remove
---@param slot? number The slot to remove the item from
---@return boolean success Returns true if the item was remove, false it the item couldn't be removed
local function RemoveItem(source, item, amount, slot)
	local Player = QBCore.Functions.GetPlayer(source)

	if not Player then return false end

	amount = tonumber(amount) or 1
	slot = tonumber(slot)

	if slot then
		if item == "cadkeys" then
			TriggerClientEvent("cad-keys:removeClientData", source, Player.PlayerData.items[slot].info.plate)
		end
		if Player.PlayerData.items[slot].amount > amount then
			Player.PlayerData.items[slot].amount = Player.PlayerData.items[slot].amount - amount
			Player.Functions.SetPlayerData("items", Player.PlayerData.items)

			if not Player.Offline then
				TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.PlayerData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. Player.PlayerData.items[slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. Player.PlayerData.items[slot].amount)
			end

			return true
		elseif Player.PlayerData.items[slot].amount == amount then
			Player.PlayerData.items[slot] = nil
			Player.Functions.SetPlayerData("items", Player.PlayerData.items)

			if Player.Offline then return true end

			TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.PlayerData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. item .. ', removed amount: ' .. amount .. ', item removed')

			return true
		end
	else
		local slots = GetSlotsByItem(Player.PlayerData.items, item)
		local amountToRemove = amount

		if not slots then return false end

		for _, _slot in pairs(slots) do
			if item == "cadkeys" then
				TriggerClientEvent("cad-keys:removeClientData", source, Player.PlayerData.items[_slot].info.plate)
			end
			if Player.PlayerData.items[_slot].amount > amountToRemove then
				Player.PlayerData.items[_slot].amount = Player.PlayerData.items[_slot].amount - amountToRemove
				Player.Functions.SetPlayerData("items", Player.PlayerData.items)

				if not Player.Offline then
					TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.PlayerData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. _slot .. '], itemname: ' .. Player.PlayerData.items[_slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. Player.PlayerData.items[_slot].amount)
				end

				return true
			elseif Player.PlayerData.items[_slot].amount == amountToRemove then
				Player.PlayerData.items[_slot] = nil
				Player.Functions.SetPlayerData("items", Player.PlayerData.items)

				if Player.Offline then return true end

				TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.PlayerData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. _slot .. '], itemname: ' .. item .. ', removed amount: ' .. amount .. ', item removed')

				return true
			end
		end
	end
	return false
end

exports("RemoveItem", RemoveItem)
```

# Events and Event

`exports['cad-keys']:HasVehicleKey(plate)` -- Client Export

`exports['cad-keys']:GetVehicleByPlate(plate)` -- Client Export

`TriggerEvent("cad-keys:toggleEngine")` -- Client Event

`TriggerEvent("cad-keys:lockVehicle")` -- Client Event

`TriggerEvent("cad-keys:addClientVehKeys", plate)` -- Client Event

`TriggerEvent("cad-keys:deleteClientKeys", plate)` -- Client Event

`TriggerServerEvent("cad-keys:deleteWasteKeys")` -- Server Event

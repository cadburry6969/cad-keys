# Dependencies:

- [qb-core](https://github.com/qbcore-framework/qb-core) (Latest)
- [qb-target](https://github.com/BerkieBb/qb-target) (Latest)

## Installation:

* Add item info to qb-inventory\html\js\app.js

```
} else if (itemData.name == "cadkeys") {
	$(".item-info-title").html(
		'<p>' + itemData.label+ '</p>'
	);
	$(".item-info-description").html(
		'<p>Vehicle ID: ' + itemData.info.citizenid +
		'</p><p>Plate: ' + itemData.info.plate +'</p>'
	);
}
```

* Add `images/carkeys.png` to `qb-inventory\html\images`

![carkeys](https://i.imgur.com/JmRS6v9.png)

#### qb-core:

Add to qb-core\shared\items.lua:

```
['cadkeys']  = { ['name'] = 'cadkeys', ['label'] = 'Vehicle Key', ['weight'] = 0, ['type'] = 'item', ['image'] = 'cadkeys.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil,['description'] = '' },
```

Event:

- Check vehicles key:

```
if exports['MojiaVehicleKeys']:CheckHasKey(plate) then
```

- Lock/Unlock Vehicles:

```
'MojiaVehicleKeys:client:lockVehicle'
```

- On/Off Engine:

```
'MojiaVehicleKeys:client:Engine'
```

- Add new key:

```
TriggerServerEvent('MojiaVehicleKeys:server:AddVehicleKey', plate, model)
```

- Change owner:

```
TriggerClientEvent('MojiaVehicleKeys:client:AddVehicleKey',target, plate, model)
```

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

# Events and Event

`exports['cad-keys']:HasVehicleKey(plate)` -- Client Export

`TriggerEvent("cad-keys:toggleEngine")` -- Client Event

`TriggerEvent("cad-keys:lockVehicle")` -- Client Event

`TriggerEvent("cad-keys:addClientVehKeys", plate)` -- Client Event

`TriggerEvent("cad-keys:deleteClientKeys", plate)` -- Client Event

`TriggerServerEvent("cad-keys:deleteWasteKeys")` -- Server Event

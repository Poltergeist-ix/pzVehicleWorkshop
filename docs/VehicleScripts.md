# Vehicle Script

## Modules
You can use different modules from "Base" for vehicle scripts but in some cases you will need to use the module + id within your files if you do that.  
Examples where you need to specify the module if it's not `Base`
- `template = module.template/part/part,`
- `model id { file = module.model, }`

## Notes

Vector3f in script example:
```
offset = 0 1.2 0.4321,
```

The `*` wildcard can be used for part and passenger blocks to target previously loaded blocks. It can be used by itself `part * {}`, in the start `part *Left {}` or the end `part Door* {}`. 
It supports more advanced matching as well. When an id contains `*`, all previously added parts are checked for a match to a pattern.

# Part Script

## values

| key | Type | brief |
| --- | --- | --- |
| area | String | vehicle area |
| category | String | category |
| hasLightsRear | Boolean | adds rear lights |
| itemType | String | item types that can be added |
| mechanicRequireKey | Boolean | require key to perform mechanics actions |
| parent | String | parent part to sync animations |
| repairMechanic | Boolean | part can be fixed while installed if there is a fixing script |
| setAllModelsVisible | Boolean | Enables all part models when part is installed |
| specificItem | Boolean | affects the itemType |
| wheel | String | vehicle wheel |

> specificItem: when true: the item type is item type + mechanicType of vehicle  

## anim block

| key | Type | brief |
| --- | --- | --- |
| angle | Vector3f |  |
| anim | String |  |
| animate | Boolean |  |
| loop | Boolean |  |
| reverse | Boolean |  |
| rate | Float |  |
| offset | Vector3f |  |
| sound | String |  |

**Vanilla Door Anims**: open, opened, close, closed

> for animations the model should be `static = false,`

## container block

| key | Type | brief |
| --- | --- | --- |
| capacity | Integer | container maximum capacity |
| conditionAffectsCapacity | Boolean | capacity scales with condition |
| contentType | String | container contents |
| seat | String | vehicle seat |
| test | String | lua function |

> capacity priority is from item first, then from part container, conditionAffectsCapacity works when item capacity is used
> 
> contentType is used for other contents than inventory items e.g. air and fuel
> 
> test is called to check if player can access container when player is near or inside vehicle

## door block

Adds door to part, has no usable values

```
door {}
```

## lua block

Creates a new HashMap with lua functions. 

```
lua {
    create = Vehicles.Create.Engine,
}
```

> Keys are not limited to only to a set of keys but can be used to add custom functions too.


**Vanilla lua function**

- create
    > called when part is created on server
- init
    > called after creation, when loaded and repaired
- update
    > called when updated on server, needPartsUpdate() or isMechanicUIOpen() must return true to trigger update
- use
    > called on client when checking all parts to get usable part for interaction
- checkEngine
    > called when checking all parts to see if the engine can work
- checkOperate
    > called when checking all parts to see if the vehicle can operate, (v.41.78 only used for tires, always returns true)

**Custom lua function**

- AcceptItemFunction
    > set to the ItemContainer in `PZVW_Script.Init.Container`

## model block

see [vehicle / part model block](#vehicle--part-model-block)

## table block

The table block is parsed into a KahluaTable. If a table exists, then it is added to; otherwise, a new table is created, and values are set, overwriting previous values.

```
table tableId {...}
```

Add a value; a comma is needed, similar to a script value:  
`x = y,`  
Add a table; doesn't need comma similar to a script block:  
`subtableId {...}`  
You can remove a value from table:  
`x = ,`  
By default everything is of String type, often `;` is used for multiple values that are later split:  
`requireInstalled = BrakeFrontLeft;SuspensionFrontLeft,`  
Create a sorted table, keys are converted to integers when possible:  
`subtableId { 1 = a, 2 = b, }`  
You can not remove a table from a part using a vehicle script after it has been added.


**Vanilla Tables**
```
table install {
    items {
        1 {
            type = Wrench,
            count = 1,
            keep = true,
            equip = primary,
        }
    }
    requireInstalled = DoorFrontLeft,
    skill = Mechanics:3,
    recipe = Basic Mechanics,
    time = 240,
    complete = Vehicles.InstallComplete.Window,
    test = Vehicles.InstallTest.Default,
}
```
```
table uninstall {
    items {
        1 {
            type = Wrench,
            count = 1,
            keep = true,
            equip = primary,
        }
    }
    requireUninstalled = WindowFrontLeft,
    skill = Mechanics:3,
    recipe = Basic Mechanics,
    time = 240,
    complete = Vehicles.UninstallComplete.Window,
    test = Vehicles.UninstallTest.Default,
}
```

>   - requireUninstalled can not have multiple values (v.41.78)
>   - items only use `keep = true`, support for removing items is minimal if any

**Custom**
- table install
    - blocksUninstall
    - canBeCrafted
    - testTooltip
- table armor || Used to initialize armor data
    - protectedParts
    - maxArmorProtection
- table containerModels
    - capacity table
    - ItemCounts table
- table mountRecipes / unmountRecipes

## window block

Adds window to part.
```
window { openable = true, }
```
| key | Type | brief |
| --- | --- | --- |
| openable | Boolean | describes if window can be opened |

# Template Vehicle

The vehicle templates are used as scripts that can be added to other template vehicles or the vehicle scripts. They use the same syntax as the vehicle scripts.

Create a vehicle template:
```
template vehicle templateId {...}
```

Copy all areas, parts, passengers and wheels from the template:
```
template = templateId,
```

Copy a specific part from the template:
```
template = template/part/partId,
```

Parse the body of the template to the script:
```
template! = templateId,
```

> when templates add a part that exists, they fully replace it while keeping same index, they are not additive (v.41.78).

## Example 1: add parts from template

```
template = Tire,
```
> copies all tires from the Tire template

```
template = GloveBox,
part GloveBox
{
    container
    {
        capacity = 5,
    }
}
```
> adds the GloveBox template, then changes the Glovebox container capacity

## Example 2: change all added by loading template with *

```
template vehicle PassengerCommon
{
    passenger * { ... }
}

template vehicle PassengerSeat6
{
    template = PassengerSeat4/passenger/FrontLeft,
    template = PassengerSeat4/passenger/FrontRight,
    ...
    template! = PassengerCommon,
}
```
> We create a template that only has a `passenger *` and then load it after we create the passengers we need. This loads the body of the template and the `passenger *` applies to all passengers that we added.

## Example 3: add vehicle values from template

```
vehicle CarLights
{
    template! = CarLights,
    ...
}
```
> creates the CarLights vehicle script and loads the CarLights template's body with all it's values.

# Model Scripts

## model block (ModelScript)

Creates a model script, which is not used exclusively for vehicles. More details can be found on [pzwiki](https://pzwiki.net/wiki/Scripts_guide/Model_Script_Guide). 

```
model SportsCar_door_left
{
    mesh = vehicles/SportsCarWithDoors|DoorFrontLeft_mesh,
    shader = vehicle,
    static = FALSE,
    scale = 0.31,
}
```
> list of keys: `mesh, scale, shader, static, texture, invertX, boneweight, animationsMesh`  
> list of children blocks: `attachment`

An fbx file can containt multiple models, the `|` separator is used in scripts e.g. `VehicleCarNormalArmor|CarNormalFrontBumper1`. 
When such models are used for Item WorldStaticModels they will generate a warning during loading because they look for specific file with that name.
```
ModelScript.checkMesh> no such mesh "WorldItems/StaticItems|WheelArmor" for Vanilla-Cars-Modifications.WheelArmor
```

It is possible to make a part model fitting for use with item script and then rotate and offset them in the part model script, instead of making two models.

## vehicle / part model block

sets a model for the vehicle / part.
```
model id {
    file = module.modelId,
    offset = 0 0 0.02,
    rotate = 0.002 0 -0.002,
    scale = 0.004,
}
```

| key | value | notes |
| --- | --- | --- |
| file | String | full type of base model, the `Base` module can be omitted |
| offset | Vector3f |  |
| rotate | Vector3f |  |
| scale | Float |  |

> the first model is used as the vehicle model 
> 
> unnamed `model {...}` is common for the vehicle model and parts that have only one model and don't use `setAllModelsVisible = false,`
> 
> most vanilla parts don't have models, they use unistall textures for the uninstalled parts effect
> 
> File can be: 
>   - the models created for the vehicle
>   - item models that have a texture, e.g. `file = Log,`
>   - weapon models, e.g. `file = FireAxe, rotate = 90 90 0,`
>
> Models without texture like DuffelBag_Ground do not work well.

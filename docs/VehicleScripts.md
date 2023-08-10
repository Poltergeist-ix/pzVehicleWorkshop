# Vehicle Script

## Modules
You can use different modules from "Base" for vehicle scripts but in some cases you will need to use the module + id within your files if you do that.  
Examples where you need to specify the module if it's not `Base`
- `template = module.template/part/part,`
- `model id { file = module.model, }`

## General

`template! = ,` is used to load a full template, it doesn't support partial load like `template = template/part/part,`
template parts replace existing parts with template part copies when loaded, they are not additive (v.41.78)

# Part Script

## Table Blocks

add a value, needs comma 
`x = y,` 
add table, doesn't need comma 
`myTable {...}` 
normally all values are of type string and often `;` is used for multiple values that are later split
make a sorted table, keys are converted to integers when possible 
`myTable { 1 = a, 2 = b, }` 
remove a value from table 
`x = ,` 

when you use getTable("mytable") you get a copy of the table

## Lua Block - luaFunctions

makes a new HashMap every time, fully replacing any previous luaFunctions

## Used Variables

- table install
    - blocksUninstall
- table armor || Used to initialize armor data
    - protectedParts
    - maxArmorProtection

# Models Scripts

## base model - global

Not all model use applies to vehicles models.  
list of keys: mesh, scale, shader, static, texture, invertX, boneweight, animationsMesh  
list of children blocks: attachment  

```
model VehicleOffRoad213_SpareTire {
    mesh = vehicles/VehicleOffRoad213|SpareTire,
    texture = vehicles/VehicleOffRoad213_SpareTire,
    scale = 0.004,
}
```
```
	// The name XXX is used in these places:
	//   items.txt    weaponSprite= or StaticModel=
	//   recipes.txt  Prop1: or Prop2:
	//   BaseTimedAction:setOverrideHandModels(XXX, XXX)
	model XXX
	{
		// Path is relative to "media/models_x/".  Extension is optional.
		mesh = Weapons/1Handed/SaucePan,

		// Path is relative to "media/textures/".  Extension is optional.
		texture = Weapons/1Handed/SaucePan,

		// Default is "basicEffect".
		shader = basicEffect,

		// Default is TRUE.
		static = TRUE,

		// Default is 1.0.
		scale = 1.0,
	}
```

you can have multiple models in an fbx and use them with `|` separator e.g. `VehicleCarNormalArmor|CarNormalFrontBumper1`
When such models are used for Item WorldStaticModels they will generate a warning during loading because they look for specific file with that name.
```
ModelScript.checkMesh> no such mesh "WorldItems/StaticItems|WheelArmor" for Vanilla-Cars-Modifications.WheelArmor
```

It is possible to make a part model fitting for use with item script and then rotate and offset them in the part model script.

## part model

| key | value | notes |
| --- | --- | --- |
| file | module.type | name of base model, adding the Base module is not required  |
| offset | x z y |  |
| rotate | x z y |  |
| scale | x |  |

```
part partId {
    model modelId {
        file = module.modelId,
        offset = 0 0 0.02,
        rotate = 0.002 0 -0.002,
        scale = 0.004,
    }
}
```
> numbers can use `.` decimal point

> `model {...}` is common for parts that have only one model and don't use `setAllModelsVisible = false,`

> most vanilla parts don't have models, they use unistall textures for the uninstalled parts effect

> File can be: 
>    - item models that have a texture, e.g. `file = Log,`
>    - weapon models, e.g. `file = FireAxe, rotate = 90 90 0,`
>
> Models without texture like DuffelBag_Ground do not work.

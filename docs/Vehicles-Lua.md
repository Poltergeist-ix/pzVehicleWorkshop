# Snippets

## scripts

To change a vehicle script we can use `VehicleScript:Load(name,block)`, first argument is the name of the vehicle, second is the vehicle script block you want to load in addition to what has been loaded already.

```lua
local VehicleScript = getScriptManager():getVehicle("module.name")
VehicleScript:Load(VehicleScript:getName(),"{ key = value, }")
```

To get a part's script table we use `VehiclePart:getTable("tableId")`, this return a new copy of the table.

```lua
local t = VehiclePart:getTable("tableId")
```

To get and call a lua function we use `VehiclePart:getLuaFunction(key)`. These functions are typically invoked using `VehicleUtils.callLua(functionName, arg1, arg2, arg3, arg4)` from Lua. Java uses distinct private methods from the `BaseVehicle` class.

```lua
local functionName = VehiclePart:getLuaFunction(key)
VehicleUtils.callLua(functionName, arg1, arg2, arg3, arg4)
```

# Distributions

VehicleZoneDistribution:
>  spawnChance is used to define the odds of spawning this car or another (the total for a zone should always be 100)

However that is fixed later in java and new spawnChances are printed.

# MP Sync
Most Vehicle changes should be done on the server.

**Server**
- Blood: transmit function
- Models: auto synced to clients
- Part Condition: transmit function
- Part Door: transmit function
- Part Item: transmit function
- Part ModData: transmit function
- Part UsedDelta: transmit function
- Part Window: transmit function

**Client**
- Animations: play on clients, send command to other clients

Client?
- transmitCharacterPosition (enter vehicle)
- Enter / Exit Vehicle

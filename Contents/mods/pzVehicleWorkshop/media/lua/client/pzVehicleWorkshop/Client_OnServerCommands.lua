if not isClient() then return end
local wantNoise = getDebug()

local Commands = pzVehicleWorkshop.ClientCommands or {}

Commands.doorAnim = function(args)
    local vehicle = getVehicleById(args.id)
    if vehicle ~= nil then
        vehicle:playPartAnim(vehicle:getPartById(args.partId), args.open and "Open" or "Close")
    end
end

--Commands.partAnim = function(args)
--    local vehicle = getVehicleById(args.id)
--    if vehicle ~= nil then
--        vehicle:playPartAnim(vehicle:getPartById(args.partId), args.anim)
--    end
--end

local function OnServerCommand(module,command,args)
    if module == "pzVehicleWorkshop" then
        if wantNoise then print(module..": received command "..command) end
        if Commands[command] ~= nil then Commands[command](args) end
    end
end

Events.OnServerCommand.Add(OnServerCommand)

pzVehicleWorkshop.OnServerCommands = Commands

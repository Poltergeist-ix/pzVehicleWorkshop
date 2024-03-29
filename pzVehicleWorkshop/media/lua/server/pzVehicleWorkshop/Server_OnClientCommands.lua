if isClient() then return end

local pzVehicleWorkshop = pzVehicleWorkshop
local OnClientCommands = pzVehicleWorkshop.OnClientCommands or {}
local wantNoise = getDebug()
local Util = require "pzVehicleWorkshop/Util"
local VehicleUtil = require "pzVehicleWorkshop/VehicleUtil"

-----------------------------------------------------------------------------------------
--- pzVehicleWorkshop Commands
-----------------------------------------------------------------------------------------

OnClientCommands.pzVehicleWorkshop = OnClientCommands.pzVehicleWorkshop or {}

function OnClientCommands.pzVehicleWorkshop.setPartItem(player,args)
    local vehicle = getVehicleById(args.vehicle)
    if vehicle == nil then return end
    local part = vehicle:getPartById(args.part)
    if part == nil then return end

    if args.item == false then
        part:setInventoryItem(nil)
        part:setAllModelsVisible(false)
    elseif instanceof(args.item,"InventoryItem") then
        part:setInventoryItem(args.item)
        if args.setModelFromType then
            part:setModelVisible(args.item:getFullType(),true)
        end
    end
    vehicle:transmitPartItem(part)
end

function OnClientCommands.pzVehicleWorkshop.doorAnim(player,args)
    local vehicle = getVehicleById(args.vehicleId)
    if not vehicle then return end
    VehicleUtil.DoorAnimOnServer(vehicle,vehicle:getPartById(args.partId),player,args.open)
end

function OnClientCommands.pzVehicleWorkshop.OnEnterVehicle(player,args)
    local vehicle = player:getVehicle()
    if not vehicle then return end
    vehicle:setNeedPartsUpdate(true)
end

function OnClientCommands.pzVehicleWorkshop.checkDirtyContainers(player,args)
    for vehicleId,t in pairs(args) do
        local vehicle = getVehicleById(vehicleId)
        if vehicle ~= nil then
            for i = 1, #t do
                local part = vehicle:getPartById(t[i])
                if part ~= nil and part:getItemContainer():isDirty() then
                    part:getItemContainer():setDirty(false)
                    VehicleUtil.resetPartModels(vehicle,part)
                end
            end
        end
    end
end

-----------------------------------------------------------------------------------------
--- Vehicle Commands Extensions
-----------------------------------------------------------------------------------------

pzVehicleWorkshop.serverVehicleCommands = pzVehicleWorkshop.serverVehicleCommands or {}
OnClientCommands.vehicle = OnClientCommands.vehicle or {}

function OnClientCommands.vehicle.setHeadlightsOn(player,args)
    local vehicle = player:getVehicle()
    if vehicle ~= nil then
        pzVehicleWorkshop.EventHandler.triggerNoEvent("OnSetHeadLightsOn",vehicle,player,args.on)
    end
end

-----------------------------------------------------------------------------------------

local function OnClientCommand(module, command, player, args)
    if wantNoise and module == "pzVehicleWorkshop" then print("pzVehicleWorkshop: received command "..command) end
    if not OnClientCommands[module] or not OnClientCommands[module][command] then return end
    OnClientCommands[module][command](player,args)
end

Events.OnClientCommand.Add(OnClientCommand)

pzVehicleWorkshop.OnClientCommands = OnClientCommands

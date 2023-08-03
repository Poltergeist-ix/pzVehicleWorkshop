local pzVehicleWorkshop = pzVehicleWorkshop
local VehicleUtil = require "pzVehicleWorkshop/VehicleUtil"
pzVehicleWorkshop.ServerPatches = pzVehicleWorkshop.ServerPatches or {}

PZVW_Script = {}

---called when part is created on server
---
---vehicle: BaseVehicle, part: VehiclePart
PZVW_Script.Create = {}

---called when part is initialised after creation and when vehicle is loaded
---BaseVehicle.InitParts (BaseVehicle.createPhysics), Part.repair
---
---vehicle: BaseVehicle, part: VehiclePart
PZVW_Script.Init = {}

--- called when part is updated on Server
--- needPartsUpdate() or isMechanicUIOpen() must return true to trigger update
---
---vehicle: BaseVehicle, part: VehiclePart, elapsedTime: double
PZVW_Script.Update = {}

---called to test if part can be installed
---
---vehicle: BaseVehicle, part: VehiclePart, character: IsoGameCharacter
PZVW_Script.InstallTest = {}

---called when part is installed
---
---vehicle: BaseVehicle, part: VehiclePart
PZVW_Script.InstallComplete = {}

---called to test if part can be uninstalled
---
---vehicle: BaseVehicle, part: VehiclePart, character: IsoGameCharacter
PZVW_Script.UninstallTest = {}

---called when part is uninstalled
---
---vehicle: BaseVehicle, part: VehiclePart, item: InventoryItem
PZVW_Script.UninstallComplete = {}

---called when checking all parts to see if the engine can work  
---ISVehicleMechanics:checkEngineFull, ISVehicleDashboard:checkEngineFull, BaseVehicle.isEngineWorking
---
---vehicle: BaseVehicle, part: VehiclePart
PZVW_Script.CheckEngine = {}

---called when checking all parts to see if the vehicle can operate, (v.41.78 only used for tires, always returns true)  
---BaseVehicle.isOperational
---
---vehicle: BaseVehicle, part: VehiclePart
PZVW_Script.CheckOperate = {}

---called when checking all parts to get usable part for interaction
---BaseVehicle.isOperational
---
---vehicle: BaseVehicle, part: VehiclePart, character: IsoGameCharacter
PZVW_Script.Use = {}

---called to check if container can be accessed by character, 
---set as test in part container script block
PZVW_Script.ContainerAccess = {}

---called to test items before being added to container
PZVW_Script.AcceptItemFunction = {}

---### Description:
---> called after a successful item transfer to / from a vehicle part container on client
---### Parameters:
---> part: VehiclePart, item: InventoryItem, isAdd: Boolean
PZVW_Script.OnTransferItem = {}

---called by RecipeManager to check if player can perform the recipe
PZVW_Script.OnCanPerform = {}

---called by RecipeManager when recipe result item is created
PZVW_Script.OnCreate = {}

-----------------------------------------------------------------------------------------

pzVehicleWorkshop.ServerPatches["Vehicles.Create.Engine"] = function()
    local original = Vehicles.Create.Engine
    Vehicles.Create.Engine = function(...)
        return pzVehicleWorkshop.EventHandler.triggerOverride("OnCreateEngine",...) or original(...)
    end
end

function PZVW_Script.Create.Empty(vehicle, part)
    part:setCondition(0)
end

-----------------------------------------------------------------------------------------

function PZVW_Script.Init.Models(vehicle,part)
    VehicleUtil.resetPartModels(vehicle,part)
end

function PZVW_Script.Init.Container(vehicle,part)
    VehicleUtil.resetPartModels(vehicle,part)
    if part:getItemContainer() ~= nil then
        part:getItemContainer():setAcceptItemFunction(part:getLuaFunction("AcceptItemFunction"))
    end
end

-----------------------------------------------------------------------------------------

pzVehicleWorkshop.ServerPatches["Vehicles.Update.Engine"] = function()
    local original = Vehicles.Update.Engine
    Vehicles.Update.Engine = function(vehicle,...)
        original(vehicle,...)
        if not vehicle:needPartsUpdate() then
            for i = 1, vehicle:getMaxPassengers() - 1 do --skip 0 driver's seat
                if vehicle:getCharacter(i) ~= nil then vehicle:setNeedPartsUpdate(true) break end
            end
        end
    end
end

function PZVW_Script.Update.Armor(vehicle,part)
    if not part:getInventoryItem() then return end
    local armorData = part:getModData().armorData
    if not armorData or part:getCondition() > armorData.prevArmorCondition then
        VehicleUtil.initArmorData(vehicle,part)
        armorData = part:getModData().armorData
    end

    local armorCondition = armorData.armorCondition - armorData.prevArmorCondition + part:getCondition()

    for prId,prevCond in pairs(armorData.protectedParts) do
        local protectedPart = vehicle:getPartById(prId)
        local cond = protectedPart:getCondition()
        if cond < prevCond then
            armorCondition = armorCondition + cond - prevCond
            if armorCondition < 0 then
                cond = prevCond + armorCondition
                armorCondition = 0
            else
                cond = prevCond
            end
            protectedPart:setCondition(cond)
        end
        armorData.protectedParts[prId] = cond
        vehicle:transmitPartCondition(protectedPart)
    end

    if armorCondition ~= armorData.armorCondition then
        local newCondition = armorCondition / armorData.armorConditionMax * 100
        if newCondition == 0 and not armorData.keepDestroyed then --fixme uninstall logic or unmount for armor
            part:setInventoryItem(nil)
            vehicle:transmitPartItem(part)
            VehicleUtil.resetPartModels(vehicle,part)
        end
        part:setCondition(newCondition)
        armorData.armorCondition = armorCondition
        armorData.prevArmorCondition = newCondition
        -- vehicle:transmitPartModData(part)
    end
    vehicle:transmitPartCondition(part)
end

-----------------------------------------------------------------------------------------

pzVehicleWorkshop.ServerPatches["Vehicles.InstallComplete.Default"] = function()
    local original = Vehicles.InstallComplete.Default
    Vehicles.InstallComplete.Default = function(vehicle,part)
        original(vehicle,part)
        if part:getTable("install").blocksUninstall ~= nil then
            for _,blockedId in ipairs(part:getTable("install").blocksUninstall:split(";")) do
                local blocked = vehicle:getPartById(blockedId)
                if blocked ~= nil then
                    if not blocked:getModData().blockedUninstall then blocked:getModData().blockedUninstall = {part:getId()}
                    else table.insert(blocked:getModData().blockedUninstall,part:getId())
                    end
                    vehicle:transmitPartModData(blocked)
                end
            end
        end
    end
end

function PZVW_Script.InstallComplete.Default(vehicle,part)
    Vehicles.InstallComplete.Default(vehicle,part)
    VehicleUtil.resetPartModels(vehicle,part)
end

function PZVW_Script.InstallComplete.Armor(vehicle,part)
    Vehicles.InstallComplete.Default(vehicle,part)
    VehicleUtil.resetPartModels(vehicle,part)
    VehicleUtil.initArmorData(vehicle,part)
end

-----------------------------------------------------------------------------------------

pzVehicleWorkshop.ServerPatches["Vehicles.UninstallTest.Default"] = function()
    local original = Vehicles.UninstallTest.Default
    Vehicles.UninstallTest.Default = function(vehicle,part,...)
        if not original(vehicle,part,...) then return false end
        if part:getModData().blockedUninstall ~= nil then
            local blockParts = part:getModData().blockedUninstall
            for i = #blockParts, 1, -1 do
                local blockPart = vehicle:getPartById(blockParts[i])
                if blockPart ~= nil and blockPart:getInventoryItem() ~= nil then
                    return false
                else
                    table.remove(blockParts,i)
                end
            end
        end
        return true
    end
end

function PZVW_Script.UninstallTest.Container(vehicle,part,character)
    return (ISVehicleMechanics.cheat or part:getItemContainer():isEmpty()) and Vehicles.UninstallTest.Default(vehicle,part,character)
end

function PZVW_Script.UninstallTest.childrenRemoved(vehicle,part,character)
    for i=0,part:getChildCount()-1 do
        if part:getChild(i):getInventoryItem() ~= nil then return false end
    end
    return Vehicles.UninstallTest.Default(vehicle,part,character)
end

-----------------------------------------------------------------------------------------

pzVehicleWorkshop.ServerPatches["Vehicles.UninstallComplete.Default"] = function()
    local original = Vehicles.UninstallComplete.Default
    Vehicles.UninstallComplete.Default = function(vehicle,part,...)
        original(vehicle,part,...)
        if part:getTable("install").blocksUninstall ~= nil then
            for _,blockedId in ipairs(part:getTable("install").blocksUninstall:split(";")) do
                local blocked = vehicle:getPartById(blockedId)
                if blocked ~= nil and blocked:getModData().blockedUninstall ~= nil then
                    for i, v in ipairs(blocked:getModData().blockedUninstall) do
                        if v == part:getId() then
                            table.remove(blocked:getModData().blockedUninstall,i)
                            break
                        end
                    end
                end
            end
        end
    end
end

function PZVW_Script.UninstallComplete.Default(vehicle,part,item)
    Vehicles.UninstallComplete.Default(vehicle,part)
    VehicleUtil.resetPartModels(vehicle,part)
end

function PZVW_Script.UninstallComplete.Armor(vehicle,part,item)
    Vehicles.UninstallComplete.Default(vehicle,part)
    VehicleUtil.resetPartModels(vehicle,part)
    part:getModData().armorData = nil
end

-----------------------------------------------------------------------------------------

function PZVW_Script.ContainerAccess.OutsideOpenContainer(vehicle, part, chr)
	if chr:getVehicle() then return false end
	if not vehicle:isInArea(part:getArea(), chr) then return false end
    if not part:getInventoryItem() and part:getItemType() ~= nil and not part:getItemType():isEmpty() then return false end
	return true
end

-----------------------------------------------------------------------------------------

function PZVW_Script.AcceptItemFunction.RoofRack(container,item)
    if item:getActualWeight() >= 1 then return true end
    return false
end

function PZVW_Script.AcceptItemFunction.SpiffoRoofRack(container,item)
    if item:getActualWeight() >= 1 or item:getType() == "Spiffo" then return true end
    return false
end

-----------------------------------------------------------------------------------------

do
    local pendingUpdate = {}
    local function sendUpdate()
        sendClientCommand("pzVehicleWorkshop","resetModelsMul",pendingUpdate)
        pendingUpdate = {}
    end

    function PZVW_Script.OnTransferItem.resetModels(part,item,isAdd)
        local id = part:getVehicle():getId()
        pendingUpdate[id] = pendingUpdate[id] or {}
        pendingUpdate[id][part:getId()] = true
        pzVehicleWorkshop.Timing.debounce(0.5,sendUpdate)
    end
end

-----------------------------------------------------------------------------------------

function PZVW_Script.OnCanPerform.VehicleRecipe(recipe, player, item)
    local vehicle = item and item:getModData().vehicleObj
    if not vehicle then return false end

    return player:getVehicle() == nil and vehicle:getSquare() ~= nil and player:DistTo(vehicle:getX(), vehicle:getY()) < 7
    --etc distance / vehicle:getSquare():getMovingObjects():indexOf(vehicle) < 0 -  / player:getUseableVehicle() == vehicle or player:getNearVehicle() == vehicle
end

-----------------------------------------------------------------------------------------

function PZVW_Script.OnCreate.ArmorRecipe(items, result, player)
    local mod = player:getPerkLevel(Perks.Mechanics) + player:getPerkLevel(Perks.MetalWelding) - 5

    result:setCondition(math.min(100,ZombRand(50+mod*2,101+mod*mod)))
end

function PZVW_Script.OnCreate.RemoveArmorRecipe(items, result, player)
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local data = item:getModData()
        if data.vehicleObj and data.unmountCarPart then
            local item = data.unmountCarPart:getInventoryItem()
            local cond = data.unmountCarPart:getCondition()
            if item:getType() == "ArmorMetalSheet" then
                for i = 1, ZombRand(4 * cond / 100) do
                    player:getSquare():AddWorldInventoryItem("Base.SheetMetal", 0.5, 0.5, 0.5)
                end
            else
                for i = 1, ZombRand(6 * cond / 100) do
                    player:getSquare():AddWorldInventoryItem("Base.ScrapMetal", 0.5, 0.5, 0)
                end
            end
            return
        end
    end
end

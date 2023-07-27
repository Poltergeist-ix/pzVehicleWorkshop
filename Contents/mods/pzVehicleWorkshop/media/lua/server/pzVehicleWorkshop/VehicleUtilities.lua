local pzVehicleWorkshop = pzVehicleWorkshop

local VehicleUtilities = {
    OnCreate = {},
    Update = {},
    InstallComplete = {},
    UninstallTest = {},
    UninstallComplete = {},
}

---functions called when part is initialised after creation and when vehicle is loaded
VehicleUtilities.PartInit = {}

---functions used to test items for being added to container
VehicleUtilities.AcceptItemFunction = {}

---functions used to determine if container can be accessed by character
VehicleUtilities.ContainerAccess = {}

-----------------------------------------------------------------------------------------

function VehicleUtilities.changeVehicleScript(vehicle,scriptName,skinIndex)
    vehicle:setScriptName(scriptName)
    if not isClient() and not isServer() then
        vehicle:scriptReloaded()
    end
    --if skinIndex then vehicle:setSkinIndex(skinIndex) end
end

function VehicleUtilities.createEmpty(vehicle, part)
    part:setCondition(0)
end

function VehicleUtilities.DoorAnimOnServer(vehicle,part,player,open)
    if not part or part:getDoor():isOpen() == open then return end

    vehicle:playPartSound(part, player, open and "Open" or "Close")
    if isServer() then
        sendServerCommand("pzVehicleWorkshop","doorAnim",{ id = vehicle:getId(), partId = part:getId(), open = open })
    else
        vehicle:playPartAnim(part, open and "Open" or "Close")
    end
    part:getDoor():setOpen(open)
    vehicle:transmitPartDoor(part)
end

function VehicleUtilities.initBaseArmor(vehicle, part)
    local item = part:getInventoryItem()
    if item == nil then return end
    part:setModelVisible(item:getFullType(),true)
end

function VehicleUtilities.updateBaseArmor(vehicle,part)
    if not part:getInventoryItem() then return end
    local armorData = part:getModData().armorData
    if not armorData or part:getCondition() > armorData.prevArmorCondition then
        pzVehicleWorkshop.ArmoredVehicles.initArmorData(vehicle,part)
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
        if newCondition == 0 and not armorData.keepDestroyed then
            part:setInventoryItem(nil)
            vehicle:transmitPartItem(part)
            VehicleUtilities.resetPartModels(vehicle,part)
        end
        part:setCondition(newCondition)
        armorData.armorCondition = armorCondition
        armorData.prevArmorCondition = newCondition
        -- vehicle:transmitPartModData(part)
    end
    vehicle:transmitPartCondition(part)
end

function VehicleUtilities.resetPartModels(vehicle,part)
    part:setAllModelsVisible(false)

    if part:getInventoryItem() ~= nil then
        part:setModelVisible(part:getInventoryItem():getFullType(),true)
    end

    vehicle:doDamageOverlay()
end

-----------------------------------------------------------------------------------------

function VehicleUtilities.PartInit.RoofRack(vehicle,part)
    if part:getInventoryItem() ~= nil then
        VehicleUtilities.resetPartModels(vehicle,part)
        part:getItemContainer():setAcceptItemFunction("pzVehicleWorkshop.VehicleUtilities.AcceptItemFunction.RoofRack")
    end
end

-----------------------------------------------------------------------------------------

function VehicleUtilities.AcceptItemFunction.RoofRack(container,item)
    if item:getActualWeight() >= 1 then return true end
    return false
end

-----------------------------------------------------------------------------------------

function VehicleUtilities.ContainerAccess.OutsideOpenContainer(vehicle, part, chr)
	if chr:getVehicle() then return false end
    -- if not part:getInventoryItem() then return end
	if not vehicle:isInArea(part:getArea(), chr) then return false end
	return true
end

-----------------------------------------------------------------------------------------

function VehicleUtilities.BasicVehicleRecipe_OnCanPerform(recipe, player, item)
    local vehicle = item and item:getModData().vehicleObj
    if not vehicle then return false end

    return player:getVehicle() == nil and vehicle:getSquare() ~= nil and player:DistTo(vehicle:getX(), vehicle:getY()) < 7
    --etc distance / vehicle:getSquare():getMovingObjects():indexOf(vehicle) < 0 -  / player:getUseableVehicle() == vehicle or player:getNearVehicle() == vehicle
end

-----------------------------------------------------------------------------------------

function VehicleUtilities.OnCreate.ArmorRecipe(items, result, player)
    local mod = player:getPerkLevel(Perks.Mechanics) + player:getPerkLevel(Perks.MetalWelding) - 5

    result:setCondition(math.min(100,ZombRand(50+mod*2,101+mod*mod)))
end

function VehicleUtilities.OnCreate.RemoveArmorRecipe(items, result, player)
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

-----------------------------------------------------------------------------------------

function VehicleUtilities.InstallComplete.DefaultHook(vehicle,part)
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

function VehicleUtilities.InstallComplete.Default(vehicle,part)
    Vehicles.InstallComplete.Default(vehicle,part)
    VehicleUtilities.resetPartModels(vehicle,part)
end

function VehicleUtilities.InstallComplete.Armor(vehicle,part)
    VehicleUtilities.InstallComplete.Default(vehicle,part)
    pzVehicleWorkshop.ArmoredVehicles.initArmorData(vehicle,part)
end

-----------------------------------------------------------------------------------------

---called when Vehicles.UninstallTest.Default returns true
function VehicleUtilities.UninstallTest.DefaultHook(vehicle,part,character)
    if part:getModData().blockedUninstall then
        local blockParts = part:getModData().blockedUninstall
        for i = #blockParts, 1, -1 do
            local blockPart = vehicle:getPartById(blockParts[i])
            if blockPart ~= nil and blockPart:getInventoryItem() ~= nil then return false
            else table.remove(blockParts,i)
            end
        end
    end
    return true
end

function VehicleUtilities.UninstallTest.childrenRemoved(vehicle,part,character)
    for i=0,part:getChildCount()-1 do
        if part:getChild(i):getInventoryItem() ~= nil then return false end
    end
    return Vehicles.UninstallTest.Default(vehicle,part,character)
end

-----------------------------------------------------------------------------------------

function VehicleUtilities.UninstallComplete.DefaultHook(vehicle,part,item)
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

function VehicleUtilities.UninstallComplete.Default(vehicle,part,item)
    Vehicles.UninstallComplete.Default(vehicle,part)
    VehicleUtilities.resetPartModels(vehicle,part)
end

function VehicleUtilities.UninstallComplete.Armor(vehicle,part,item)
    VehicleUtilities.UninstallComplete.Default(vehicle,part)
    part:getModData().armorData = nil
end

-----------------------------------------------------------------------------------------

-- TODO pick one
pzVehicleWorkshop.VehicleUtilities = VehicleUtilities
pzVehicleWorkshop.Util = VehicleUtilities

local pzVehicleWorkshop = pzVehicleWorkshop

local ActionUtil = {}

function ActionUtil.equipWeldingTools(player,recipe,containers)
    local required = RecipeManager.getAvailableItemsNeeded(recipe,player,containers,nil,nil)
    local BlowTorch, WeldingMask
    for i = 0, required:size() -1 do
        local item = required:get(i)
        if item:getType() == "BlowTorch" then BlowTorch = item; if WeldingMask ~= nil then break end
        elseif item:hasTag("WeldingMask") then WeldingMask = item; if BlowTorch ~= nil then break end
        end
    end

    if not BlowTorch or not WeldingMask then return end

    ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), BlowTorch, true, false)
    ISInventoryPaneContextMenu.transferIfNeeded(player, WeldingMask)
    ISTimedActionQueue.add(ISWearClothing:new(player, WeldingMask, 50))

    return true
end

function ActionUtil.equipForRecipe(player, recipe, containers)
    --ISVehiclePartMenu.transferRequiredItems(player, part, tbl)
    --ISVehiclePartMenu.equipRequiredItems(player, part, tbl)
    --ISWearClothing:new
    local valid = true

    --local WeldingMask, BlowTorch
    --for i = 0, recipe:getSource():size() - 1 do
    --    local sourceItems = recipe:getSource():get(i):getItems()
    --    if sourceItems ~= nil then
    --        for i = 0, sourceItems:size() - 1 do
    --            local item = sourceItems:get(i)
    --            if item == "BlowTorch" then BlowTorch = true break
    --            elseif item == "WeldingMask" then WeldingMask = true break
    --            end
    --        end
    --    end
    --end
    --if BlowTorch and WeldingMask then valid = valid and Util.equipWeldingTools(player,containers) end

    local prop1, prop2 = recipe:getProp1(), recipe:getProp2()

    if prop1 == "BlowTorch" then valid = ActionUtil.equipWeldingTools(player,recipe,containers) end

    --if not prop1 and not prop2 then
    --    --
    --elseif prop1 == "BlowTorch" then
    --    valid = Util.equipWeldingTools(player,recipe,containers)
    --else
    --    local required = RecipeManager.getAvailableItemsNeeded(recipe,player,containers,nil,nil)
    --    local tool1, tool2
    --    for i = 0, required:size() -1 do --check type?
    --        local item = required:get(i)
    --        if not tool1 and prop1 ~= nil and item:hasTag(prop1) then tool1 = item; if prop2 == nil or tool2 ~= nil then break end
    --        elseif not tool2 and prop2 ~= nil and item:hasTag(prop2) then tool2 = item; if prop1 == nil or tool1 ~= nil then break end
    --        end
    --    end
    --
    --    if tool1 then ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), BlowTorch, true, false) end
    --    if tool2 then ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), BlowTorch, true, false) end
    --end

    --transfer items if not valid without containers?

    return valid
end

function ActionUtil.pathToPart(player,vehicle,part)
    if player:getVehicle() ~= nil then ISVehicleMenu.onExit(player) end
    local ISPathFindAction = ISPathFindAction:pathToVehicleArea(player, vehicle, part:getArea())
    ISTimedActionQueue.add(ISPathFindAction)
    return ISPathFindAction
end

---Vanilla Craft and Install chain
function ActionUtil.onCraftAndInstallPart(character,vehicle,part,itemType,recipe)
    local containers = ISInventoryPaneContextMenu.getContainers(character)
    if not RecipeManager.IsRecipeValid(recipe, character, nil, containers) then return end

    local availableItems = RecipeManager.getAvailableItemsNeeded(recipe, character, containers, nil, nil)
    if availableItems:isEmpty() then return end
    -- local neededItems = {}
    local transferItems = {}
    for i=0,availableItems:size() - 1 do
        local item = availableItems:get(i)
        -- table.insert(neededItems, item)
        if not recipe:isCanBeDoneFromFloor() and item:getContainer() ~= character:getInventory() then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(character, item, item:getContainer(), character:getInventory(), nil))
            table.insert(transferItems, item)
        end
    end

    -- local container = itemsUsed[1]:getContainer()
    -- if not recipe:isCanBeDoneFromFloor() then
    --     container = character:getInventory()
    --     for _,item in ipairs(itemsUsed) do
    --         if item:getContainer() ~= character:getInventory() then
    --             table.insert(returnToContainer, item)
    --         end
    --     end
    -- end

    local craftAction = ISCraftAction:new(character, availableItems:get(0), recipe:getTimeToMake(), recipe, character:getInventory(), containers)
    ISTimedActionQueue.add(craftAction)
    ISCraftingUI.ReturnItemsToOriginalContainer(character, transferItems)

    craftAction:setOnComplete(function()
        local item = character:getInventory():getBestTypeEval(itemType,function(a,b)return a:getCondition() - b:getCondition() end)
        if item ~= nil then
            local pathAction = pzVehicleWorkshop.ActionUtil.pathToPart(character, vehicle, part)
            pathAction:setOnComplete(function()
                if character:getInventory():contains(item) and vehicle:canInstallPart(character, part) then
                    ISTimedActionQueue.add(ISInstallVehiclePart:new(character, part, item, 200)) --time
                end
            end)
        end
    end)

end

function ActionUtil.onMountArmor(player, vehicle, part, item, recipe, containers)
    if ISVehicleMechanics.cheat then
        ISTimedActionQueue.add(pzVehicleWorkshop.installAction:new(player, vehicle, part, item, recipe, containers))
    else
        local pathAction = pzVehicleWorkshop.ActionUtil.pathToPart(player, vehicle, part)
        pathAction:setOnComplete(function()
            if RecipeManager.IsRecipeValid(recipe, player, item, containers) then
                pzVehicleWorkshop.ActionUtil.equipForRecipe(player, recipe, containers)
                ISTimedActionQueue.add(pzVehicleWorkshop.installAction:new(player, vehicle, part, item, recipe, containers))
            end
        end)
    end
end

function ActionUtil.onUnmountArmor(player, vehicle, part, item, recipe, containers)
    if ISVehicleMechanics.cheat then
        ISTimedActionQueue.add(pzVehicleWorkshop.uninstallAction:new(player, vehicle, part, item, recipe, containers))
    else
        local pathAction = pzVehicleWorkshop.ActionUtil.pathToPart(player, vehicle, part)
        pathAction:setOnComplete(function()
            if RecipeManager.IsRecipeValid(recipe, player, item, containers) then
                pzVehicleWorkshop.ActionUtil.equipForRecipe(player, recipe, containers)
                ISTimedActionQueue.add(pzVehicleWorkshop.uninstallAction:new(player, vehicle, part, item, recipe, containers))
            end
        end)
    end
end

pzVehicleWorkshop.ActionUtil = ActionUtil
require "pzVehicleWorkshop/UI"
local pzVehicleWorkshop = pzVehicleWorkshop
local VehicleUtil = require "pzVehicleWorkshop.VehicleUtil"

-----------------------------------------------------------------------------------------
--- ISVehicleMechanics
-----------------------------------------------------------------------------------------

local VehicleMechanics = {}

--- Banner on top part of UI
--function Mechanics.updateTitle(window,vehicleSettings)
--    window.extraTitleSpace = 0
--    local prevTitle = window.VWTitle
--    local newTitle = vehicleSettings and vehicleSettings:get("VehicleMechanicsTitle",window)
--    if prevTitle and prevTitle ~= newTitle then
--        prevTitle:setVisible(false)
--    end
--    if newTitle ~= nil then
--        window.VWTitle = newTitle
--        window.extraTitleSpace = newTitle.y
--    end
--end

function VehicleMechanics.sortBodyworkArmorParts(vehicleSettings,window)
    if not vehicleSettings.partParents then VehicleUtil.generatePartParents(vehicleSettings,window.vehicle) end

    local index = 0
    for i, item in ipairs(copyTable(window.bodyworklist.items)) do
        index = index + 1

        local part = item.item.part
        local partId = part and part:getId()

        item.itemindex = index
        window.bodyworklist.items[index] = item

        if vehicleSettings.partParents[partId] then
            index = index + 1
            local prPart = window.vehicle:getPartById(vehicleSettings.partParents[partId])
            local newPart = {
                name = getText("IGUI_VehiclePart" .. prPart:getId()),
                part = prPart
            }
            local item = window.bodyworklist:addItem(newPart.name,newPart)
            item.itemindex = index
            window.bodyworklist.items[index] = item
        end
    end

end

function VehicleMechanics.drawArmorItems(vehicleSettings, window, y, item, alt)
    if item.item.part ~= nil and item.item.part:getInventoryItem() == nil and item.item.part:getId():find("^Armor_") ~= nil then
        window:drawText(item.item.name, 20, y, 0.4, 0.32, 0.32, 1, UIFont.Small)

        return y + window.itemheight
    end
end

function VehicleMechanics.AltDrawItems(vehicleSettings, window, y, item, alt)
    return VehicleMechanics.drawArmorItems(vehicleSettings, window, y, item, alt)
end

---TODO add to event
function VehicleMechanics.doPartContextMenuHook(vehicleSettings, self, part, x, y)
    local context = self.context
    if part:getInventoryItem() ~= nil then
        local unmount = part:getTable("unmountRecipes")
        if unmount ~= nil then
            local player = self.playerObj
            local playerInv = player:getInventory()
            local containers = ISInventoryPaneContextMenu.getContainers(player)
            local partText = getText("IGUI_VehiclePart" .. part:getId())
            for _,recipeName in ipairs(unmount) do
                local recipe = getScriptManager():getRecipe(recipeName)
                if recipe ~= nil then
                    --local fullType = recipe:getSource():get(0):getItems():get(0)
                    --local item = playerInv:getFirstType(fullType) or ISVehicleMechanics.cheat and playerInv:AddItem(fullType)
                    --local valid = item and RecipeManager.IsRecipeValid(recipe, player, item, containers) or ISVehicleMechanics.cheat
                    --local option = context:addOption(getText("IGUI_Uninstall") .. " " .. partText, player, ArmoredVanillaCars.onRemoveArmor, self.vehicle, part, containers) --text
                    --if not valid then
                    --    option.notAvailable = true
                    --end

                    local keyInv = InventoryItemFactory.CreateItem("KeyRing"):getInventory()
                    containers:add(keyInv)
                    local item = keyInv:AddItem("CarKey")
                    item:getModData().vehicleObj = self.vehicle
                    item:getModData().unmountCarPart = part
                    local valid = RecipeManager.IsRecipeValid(recipe, player, item, containers) or ISVehicleMechanics.cheat

                    local option = context:addOption(getText("IGUI_Uninstall") .. " " .. partText, player, ArmoredVanillaVehicles.onRemoveArmor, self.vehicle, part, item, recipe, containers) --text
                    if not valid then
                        option.notAvailable = true
                    end
                    local tooltip = ISRecipeTooltip.addToolTip()
                    tooltip.character = player
                    tooltip.recipe = recipe
                    tooltip:setName(recipe:getName())
                    --if resultItem:getTexture() and resultItem:getTexture():getName() ~= "Question_On" then
                    --    tooltip:setTexture(resultItem:getTexture():getName())
                    --end
                    option.toolTip = tooltip


                else
                    local option = context:addOption(getText("Recipe %1 not found ",recipeName))
                    option.notAvailable = true
                end
            end
        end
    else
        if part:getTable("install") and part:getTable("install").canBeCrafted then
            local containers = ISInventoryPaneContextMenu.getContainers(self.playerObj)
            local partText = getText("IGUI_VehiclePart" .. part:getId())

            local itemTypes = part:getItemType()
            for i = 0, itemTypes:size() - 1 do
                local itemType = itemTypes:get(i)
                local recipe = getScriptManager():getRecipe(itemType.." Craft")
                if recipe ~= nil then
                    local option = context:addOption(getText("IGUI_CraftUI_CraftOne") .. " " .. partText, self.playerObj, pzVehicleWorkshop.ActionUtil.onCraftAndInstallPart, self.vehicle, part, itemType, recipe)
                    if not (RecipeManager.IsRecipeValid(recipe, self.playerObj, nil, containers) or ISVehicleMechanics.cheat) then
                        option.notAvailable = true
                    end
                    option.toolTip = ISRecipeTooltip.addToolTip()
                    option.toolTip.character = self.playerObj
                    option.toolTip.recipe = recipe
                    option.toolTip:setName(recipe:getName())
                end
            end
        end
        local mount = part:getTable("mountRecipes")
        if mount ~= nil then
            local player = self.playerObj
            local playerInv = player:getInventory()
            local containers = ISInventoryPaneContextMenu.getContainers(player)
            local partText = getText("IGUI_VehiclePart" .. part:getId())
            for _,recipeName in ipairs(mount) do
                local recipe = getScriptManager():getRecipe(recipeName)
                if recipe ~= nil then

                    --local fullType = recipe:getSource():get(0):getItems():get(0)
                    --local item = playerInv:getFirstType(fullType) or ISVehicleMechanics.cheat and playerInv:AddItem(fullType)
                    --local valid = item and RecipeManager.IsRecipeValid(recipe, player, item, containers) or ISVehicleMechanics.cheat

                    --local fullType = "Base.CarKey"
                    --local item = self.vehicle:createKey()
                    --local item = InventoryItemFactory.CreateItem("CarKey")
                    local keyInv = InventoryItemFactory.CreateItem("KeyRing"):getInventory()
                    containers:add(keyInv)
                    local item = keyInv:AddItem("CarKey")
                    item:getModData().vehicleObj = self.vehicle
                    local valid = RecipeManager.IsRecipeValid(recipe, player, item, containers) or ISVehicleMechanics.cheat

                    local option = context:addOption(getText("IGUI_Install") .. " " .. partText, player, ArmoredVanillaVehicles.onAddArmor, self.vehicle, part, item, recipe, containers) --text
                    if not valid then
                        option.notAvailable = true
                    end
                    local tooltip = ISRecipeTooltip.addToolTip()
                    tooltip.character = player
                    tooltip.recipe = recipe
                    tooltip:setName(recipe:getName())
                    --if resultItem:getTexture() and resultItem:getTexture():getName() ~= "Question_On" then
                    --    tooltip:setTexture(resultItem:getTexture():getName())
                    --end
                    option.toolTip = tooltip

                else
                    local option = context:addOption(getText("Recipe %1 not found ", recipeName))
                    option.notAvailable = true
                end
            end
        end
    end
end

function VehicleMechanics.doMenuTooltipHook(self, part, option, lua, name)
    local vehicle = part:getVehicle()
    local tooltip = option.toolTip
    if lua == "uninstall" and part:getModData().blockedUninstall then
        local blockParts = part:getModData().blockedUninstall
        for i = #blockParts, 1, -1 do
            local blockPart = vehicle:getPartById(blockParts[i])
            if blockPart ~= nil and blockPart:getInventoryItem() ~= nil then
                tooltip.description = tooltip.description .. " <LINE> " .. ISVehicleMechanics.bhs .. " " .. getText("Tooltip_vehicle_requireUnistalled", getText("IGUI_VehiclePart" .. blockParts[i]))
                -- option.notAvailable = true
            end
        end
    end
end

Events.OnVehicleMechanicsDoMenuTooltip.Add(VehicleMechanics.doMenuTooltipHook)

-----------------------------------------------------------------------------------------
--- ISVehicleMechanics Patches
-----------------------------------------------------------------------------------------

VehicleMechanics.Patches = {}

--function MechanicsPatches.titleBarHeight(titleBarHeight) --doesn't work as intended // makes title bar bigger
--    return function(self)
--        return titleBarHeight(self) + (self.extraTitleSpace or 0)
--    end
--end

function VehicleMechanics.Patches.initParts(initParts) -- TODO: add/remove elements or replace with custom ui
    return function(self)
        initParts(self)
        if not self.vehicle then return end

        self.vwVehicleSettings = pzVehicleWorkshop.VehicleSettings.get(self.vehicle:getScriptName())

        --[[ undo prev ]]
        --[[ check new ]]
        pzVehicleWorkshop.EventHandler.triggerDef("OnVehicleMechanicsOpen",self.vwVehicleSettings,self)
    end
end

function VehicleMechanics.Patches.doPartContextMenu(doPartContextMenu)
    return function(self,part,x,y)

        doPartContextMenu(self,part,x,y)

        if isGamePaused() then return end
        if not self.playerObj then self.playerObj = getSpecificPlayer(self.playerNum) end
        if self.playerObj:getVehicle() ~= nil and not (isDebugEnabled() or (isClient() and (isAdmin() or getAccessLevel() == "moderator"))) then return end

        pzVehicleWorkshop.EventHandler.triggerDef("OnVehicleMechanicsPartContext",self.vwVehicleSettings,self,part,x,y)

        if JoypadState.players[self.playerNum + 1] then
            pzVehicleWorkshop.EventHandler.triggerDef("OnVehicleMechanicsVehicleContext",self.vwVehicleSettings,self,x,y)
        end

        if #self.context.options > 0 then self.context:setVisible(true) end
    end
end

function VehicleMechanics.Patches.doDrawItem(doDrawItem)
    return function(self,...)
        return pzVehicleWorkshop.EventHandler.triggerDefReplace("OnVehicleMechanicsDrawItems",self.parent.vwVehicleSettings,self,...) or doDrawItem(self,...)
    end
end

function VehicleMechanics.Patches.onRightMouseUp(onRightMouseUp)
    return function(self,x,y)

        onRightMouseUp(self,x,y)

        pzVehicleWorkshop.EventHandler.triggerDef("OnVehicleMechanicsVehicleContext",self.vwVehicleSettings,self,x,y)
    end
end

function VehicleMechanics.Patches.doMenuTooltip(doMenuTooltip)
    return function(self,...)
        doMenuTooltip(self,...)
        pzVehicleWorkshop.EventHandler.triggerDef("OnVehicleMechanicsDoMenuTooltip",self.vwVehicleSettings,self,...)
    end
end

-----------------------------------------------------------------------------------------

if not pzVehicleWorkshop.ClientPatches then pzVehicleWorkshop.ClientPatches = {} end

function pzVehicleWorkshop.ClientPatches.ISVehicleMechanics()
    require "Vehicles/ISUI/ISVehicleMechanics"
    local ISVehicleMechanics = ISVehicleMechanics
    for key,patchFn in pairs(VehicleMechanics.Patches) do
        ISVehicleMechanics[key] = patchFn(ISVehicleMechanics[key])
    end
    VehicleMechanics.Patches = nil
end

pzVehicleWorkshop.VehicleMechanics = VehicleMechanics

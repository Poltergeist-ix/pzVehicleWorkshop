require "pzVehicleWorkshop/UI"
local pzVehicleWorkshop = pzVehicleWorkshop

-----------------------------------------------------------------------------------------
--- ISVehicleMechanics
-----------------------------------------------------------------------------------------

local Mechanics = {}

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

-----------------------------------------------------------------------------------------
--- ISVehicleMechanics Patches
-----------------------------------------------------------------------------------------

Mechanics.Patches = {}

--function MechanicsPatches.titleBarHeight(titleBarHeight) --doesn't work as intended // makes title bar bigger
--    return function(self)
--        return titleBarHeight(self) + (self.extraTitleSpace or 0)
--    end
--end

function Mechanics.Patches.initParts(initParts) -- TODO: add/remove elements or replace with custom ui
    return function(self)
        initParts(self)
        if not self.vehicle then return end

        self.vwVehicleSettings = pzVehicleWorkshop.VehicleSettings.get(self.vehicle:getScriptName())

        --[[ undo prev ]]
        --[[ check new ]]
        pzVehicleWorkshop.EventHandler.triggerDef("OnVehicleMechanicsOpen",self.vwVehicleSettings,self)
    end
end

function Mechanics.Patches.doPartContextMenu(doPartContextMenu)
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

function Mechanics.Patches.doDrawItem(doDrawItem)
    return function(self,...)
        return pzVehicleWorkshop.EventHandler.triggerDefReplace("OnVehicleMechanicsDrawItems",self.parent.vwVehicleSettings,self,...) or doDrawItem(self,...)
    end
end

function Mechanics.Patches.onRightMouseUp(onRightMouseUp)
    return function(self,x,y)

        onRightMouseUp(self,x,y)

        pzVehicleWorkshop.EventHandler.triggerDef("OnVehicleMechanicsVehicleContext",self.vwVehicleSettings,self,x,y)
    end
end

-----------------------------------------------------------------------------------------

if not pzVehicleWorkshop.ClientPatches then pzVehicleWorkshop.ClientPatches = {} end

function pzVehicleWorkshop.ClientPatches.ISVehicleMechanics()
    require "Vehicles/ISUI/ISVehicleMechanics"
    local ISVehicleMechanics = ISVehicleMechanics
    for key,patchFn in pairs(Mechanics.Patches) do
        ISVehicleMechanics[key] = patchFn(ISVehicleMechanics[key])
    end
    Mechanics.Patches = nil
end

pzVehicleWorkshop.VehicleMechanics = Mechanics

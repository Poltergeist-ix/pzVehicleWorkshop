require "Vehicles/Vehicles"

local pzVehicleWorkshop = pzVehicleWorkshop

pzVehicleWorkshop.ServerPatches = pzVehicleWorkshop.ServerPatches or {}

---Hook to check more parts that need to be uninstalled
pzVehicleWorkshop.ServerPatches["Vehicles.UninstallTest.Default"] = function()
    local Default = Vehicles.UninstallTest.Default
    Vehicles.UninstallTest.Default =  function(vehicle, part, character)
        local r = Default(vehicle, part, character)
        if not r then return r end
        local t = part:getTable("uninstall")
        if not (t and t.requireUninstalledList) then return r end
        for _,partId in ipairs(t.requireUninstalledList) do
            if vehicle:getPartById(partId):getInventoryItem() ~= nil then return false end
        end
        return r
    end
end

---Override Hook for the Create Engine
pzVehicleWorkshop.ServerPatches["Vehicles.Create.Engine"] = function()
    local Engine = Vehicles.Create.Engine
    Vehicles.Create.Engine = function(vehicle,...)
        return pzVehicleWorkshop.EventHandler.triggerOverride("OnCreateEngine",vehicle,...) or Engine(vehicle,...)
    end
end

---Hook to Update Engine
---keep updating parts if other characters (not driver) are inside
pzVehicleWorkshop.ServerPatches["Vehicles.Update.Engine"] = function()
    local Engine = Vehicles.Update.Engine
    Vehicles.Update.Engine = function(vehicle,...)
        Engine(vehicle,...)
        if not vehicle:needPartsUpdate() then
            for i = 1, vehicle:getMaxPassengers() - 1 do
                if vehicle:getCharacter(i) ~= nil then vehicle:setNeedPartsUpdate(true) break end
            end
        end
    end
end

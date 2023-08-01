require "Vehicles/Vehicles"
require "pzVehicleWorkshop/VehicleUtilities"

local pzVehicleWorkshop = pzVehicleWorkshop

pzVehicleWorkshop.ServerPatches = pzVehicleWorkshop.ServerPatches or {}

pzVehicleWorkshop.ServerPatches["Vehicles.InstallComplete.Default"] = function()
    local original = Vehicles.InstallComplete.Default
    local hook = pzVehicleWorkshop.VehicleUtilities.InstallComplete.DefaultHook
    Vehicles.InstallComplete.Default = function(...) original(...); hook(...) end
end

pzVehicleWorkshop.ServerPatches["Vehicles.UninstallTest.Default"] = function()
    local original = Vehicles.UninstallTest.Default
    local hook = pzVehicleWorkshop.VehicleUtilities.UninstallTest.DefaultHook
    Vehicles.UninstallTest.Default = function(...) return original(...) and hook(...) end
end

pzVehicleWorkshop.ServerPatches["Vehicles.UninstallComplete.Default"] = function()
    local original = Vehicles.UninstallComplete.Default
    local hook = pzVehicleWorkshop.VehicleUtilities.UninstallComplete.DefaultHook
    Vehicles.UninstallComplete.Default = function(...) original(...); hook(...) end
end

pzVehicleWorkshop.ServerPatches["Vehicles.Create.Engine"] = function()
    local Engine = Vehicles.Create.Engine
    Vehicles.Create.Engine = function(vehicle,...) return pzVehicleWorkshop.EventHandler.triggerOverride("OnCreateEngine",vehicle,...) or Engine(vehicle,...) end
end

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

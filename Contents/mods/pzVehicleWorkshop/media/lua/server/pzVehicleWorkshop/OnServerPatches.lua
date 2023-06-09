local pzVehicleWorkshop = pzVehicleWorkshop

local Patches = pzVehicleWorkshop.ServerPatches or {}

Patches["UninstallTest.Default"] = function(uninstall)
    return function(vehicle, part, character)
        local r = uninstall(vehicle, part, character)
        if not r then return r end
        local t = part:getTable("uninstall")
        if not (t and t.requireUninstalledList) then return r end
        for _,partId in ipairs(t.requireUninstalledList) do
            if vehicle:getPartById(partId):getInventoryItem() ~= nil then return false end
        end
        return r
    end
end

function Patches.patchCreateEngine(CreateEngine)
    return function(vehicle,...)
        return pzVehicleWorkshop.EventHandler.triggerOverride("OnCreateEngine",vehicle,...) or CreateEngine(vehicle,...)
    end
end

pzVehicleWorkshop.ServerPatches = Patches
require "Vehicles/Vehicles"
require "pzVehicleWorkshop/PZVW_Script"

for _,patch in pairs(pzVehicleWorkshop.ServerPatches) do
    patch()
end

pzVehicleWorkshop.ServerPatches = nil

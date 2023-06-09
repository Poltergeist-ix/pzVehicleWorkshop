require "pzVehicleWorkshop/VehicleMechanics"
require "pzVehicleWorkshop/VehicleMenu"

for _,patch in pairs(pzVehicleWorkshop.ClientPatches) do
    patch()
end
pzVehicleWorkshop.ClientPatches = nil

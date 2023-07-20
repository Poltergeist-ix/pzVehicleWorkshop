require "pzVehicleWorkshop/OnServerPatches"

for _,patch in pairs(pzVehicleWorkshop.ServerPatches) do
    patch()
end

pzVehicleWorkshop.ServerPatches = nil

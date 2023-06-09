require "pzVehicleWorkshop/OnServerPatches"
require "Vehicles/Vehicles"
Vehicles.Create.Engine = pzVehicleWorkshop.ServerPatches.patchCreateEngine(Vehicles.Create.Engine)
--Vehicles.UninstallTest.Default = pzVehicleWorkshop.ServerPatches["UninstallTest.Default"](Vehicles.UninstallTest.Default) --fixme test patch

pzVehicleWorkshop.ServerPatches = nil

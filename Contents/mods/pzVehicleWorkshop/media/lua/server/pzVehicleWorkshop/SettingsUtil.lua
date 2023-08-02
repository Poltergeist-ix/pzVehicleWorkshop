local pzVehicleWorkshop = pzVehicleWorkshop
local VehicleUtil = require "pzVehicleWorkshop/VehicleUtil"

pzVehicleWorkshop.SettingsUtil = {}

function pzVehicleWorkshop.SettingsUtil.checkFlipLamps(settings,vehicle,player,open)
    if settings.flipLamps ~= nil then
        VehicleUtil.DoorAnimOnServer(vehicle,vehicle:getPartById(settings.flipLamps),player,open)
    end
end

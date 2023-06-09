local pzVehicleWorkshop = pzVehicleWorkshop

pzVehicleWorkshop.SettingsUtil = {}

function pzVehicleWorkshop.SettingsUtil.checkFlipLamps(settings,vehicle,player,open)
    if settings.flipLamps ~= nil then
        pzVehicleWorkshop.VehicleUtilities.DoorAnimOnServer(vehicle,vehicle:getPartById(settings.flipLamps),player,open)
    end
end

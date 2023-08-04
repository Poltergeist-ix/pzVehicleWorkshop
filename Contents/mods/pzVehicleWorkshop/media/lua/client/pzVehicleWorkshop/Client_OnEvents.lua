require "pzVehicleWorkshop.Client_Events"

local OnEvents = {}

---send command for server trigger and update parts
OnEvents.OnEnterVehicle = function(character)
    sendClientCommand(character,"pzVehicleWorkshop","OnEnterVehicle",{})
end

Events.OnEnterVehicle.Add(OnEvents.OnEnterVehicle)

return OnEvents
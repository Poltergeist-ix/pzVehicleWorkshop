local Tweaks = {}

---Send Command for server trigger
Tweaks.OnEnterVehicle = function(character)
    sendClientCommand(character,"pzVehicleWorkshop","OnEnterVehicle",{})
end

Events.OnEnterVehicle.Add(Tweaks.OnEnterVehicle)

return Tweaks
require "pzVehicleWorkshop.Client_Events"

local Tweaks = {}

local function partTransferItem(part,item,isAdd)
    if part ~= nil and part:getLuaFunction("OnTransferItem") ~= nil then
        pzVehicleWorkshop.VehicleUtilities.callLua(part:getLuaFunction("OnTransferItem"),part,item,isAdd)
    end
end

---Send Command for server trigger
Tweaks.OnEnterVehicle = function(character)
    sendClientCommand(character,"pzVehicleWorkshop","OnEnterVehicle",{})
end

Tweaks.OnTransferItem = function (action,item)
    partTransferItem(action.srcContainer:getVehiclePart(),item,false)
    partTransferItem(action.destContainer:getVehiclePart(),item,true)
end

Events.OnEnterVehicle.Add(Tweaks.OnEnterVehicle)
Events.OnTransferItem.Add(Tweaks.OnTransferItem)

return Tweaks
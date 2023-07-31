require "pzVehicleWorkshop.Client_Events"

local Tweaks = {}

local callLua = require("pzVehicleWorkshop.Util").callLua

local function partTransferItem(part,item,isAdd)
    if part:getLuaFunction("OnTransferItem") ~= nil then
        callLua(part:getLuaFunction("OnTransferItem"),part,item,isAdd)
    end
end

---Send Command for server trigger
Tweaks.OnEnterVehicle = function(character)
    sendClientCommand(character,"pzVehicleWorkshop","OnEnterVehicle",{})
end

Tweaks.OnTransferItem = function (action,item)
    if action.srcContainer:getVehiclePart() ~= nil then
        partTransferItem(action.srcContainer:getVehiclePart(),item,false)
    end
    if action.destContainer:getVehiclePart() ~= nil then
        partTransferItem(action.destContainer:getVehiclePart(),item,true)
    end
end

Events.OnEnterVehicle.Add(Tweaks.OnEnterVehicle)
Events.OnTransferItem.Add(Tweaks.OnTransferItem)

return Tweaks
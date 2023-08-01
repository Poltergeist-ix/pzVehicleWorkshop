require "pzVehicleWorkshop.Client_Events"

local OnEvents = {}

local callLua = require("pzVehicleWorkshop/Util").callLua

local function partTransferItem(part,item,isAdd)
    if part:getLuaFunction("OnTransferItem") ~= nil then
        callLua(part:getLuaFunction("OnTransferItem"),part,item,isAdd)
    end
end

---Send Command for server trigger
OnEvents.OnEnterVehicle = function(character)
    sendClientCommand(character,"pzVehicleWorkshop","OnEnterVehicle",{})
end

OnEvents.OnTransferItem = function (action,item)
    if action.srcContainer:getVehiclePart() ~= nil then
        partTransferItem(action.srcContainer:getVehiclePart(),item,false)
    end
    if action.destContainer:getVehiclePart() ~= nil then
        partTransferItem(action.destContainer:getVehiclePart(),item,true)
    end
end

Events.OnEnterVehicle.Add(OnEvents.OnEnterVehicle)
Events.OnTransferItem.Add(OnEvents.OnTransferItem)
zx.setKeyFunc(Keyboard.KEY_X,function(player)
    local vehicle = getPlayer():getVehicle()
    if not vehicle then return end
    local part = vehicle:getPartById("ATA2InteractiveTrunkRoofRack")
    if not part then return end
    print("zxLog ",part:getCondition()," / ",part:getContainerCapacity())
end)

return OnEvents
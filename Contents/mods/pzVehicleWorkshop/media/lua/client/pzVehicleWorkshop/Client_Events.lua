if not Events.OnTransferItem then
    LuaEventManager.AddEvent("OnTransferItem")
    local original = ISInventoryTransferAction.transferItem
    ISInventoryTransferAction.transferItem = function (self,item)
        if self.destContainer:contains(item) then return end --original
        original(self,item)
        if self.destContainer:contains(item) then
            triggerEvent("OnTransferItem",self,item)
        end
    end
end

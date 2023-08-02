local VehicleUtil = {}

function VehicleUtil.resetPartModels(vehicle,part)
    part:setAllModelsVisible(false)

    if part:getInventoryItem() ~= nil then
        part:setModelVisible(part:getInventoryItem():getFullType(),true)

        if part:getTable("containerModels") ~= nil and part:getItemContainer() ~= nil then
            local models = part:getTable("containerModels")
            if models.Capacity ~= nil then
                local full = part:getItemContainer():getContentsWeight() / part:getItemContainer():getCapacity()
                if full > 1 then full = 1 end
                full = math.ceil(full * #models.Capacity)
                if full <= 0 then --skip
                elseif models.Capacity.onlyOne then
                    part:setModelVisible(models.Capacity[full],true)
                else
                    for i = 1, full do
                        part:setModelVisible(models.Capacity[i],true)
                    end
                end
            end

            if models.ItemCounts ~= nil then
                local counts = {}
                local items = part:getItemContainer():getItems()
                for i = 0, items:size() -1 do
                    local ft = items:get(i):getFullType()
                    counts[ft] = (counts[ft] or 0) + 1
                end

                for i = 1, #models.ItemCounts do
                    local t = models.ItemCounts[i]
                    local count = 0
                    for it = 1, #t.itemTypes do
                        count = count + (counts[t.itemTypes[it]] or 0)
                    end
                    if count == 0 then --skip
                    elseif t.umodels then
                        for im = #t.umodels, 1, -1 do
                            if count >= tonumber(t.umodels[im].count) then
                                part:setModelVisible(t.umodels[im].model,true)
                                if t.onlyOne then break end
                            end
                        end
                    else
                        if t.onlyOne then
                            part:setModelVisible(t[math.min(count,#t)],true)
                        else
                            for im = 1, math.min(count,#t) do
                                part:setModelVisible(t[im],true)
                            end
                        end
                    end
                end
            end
        end

    end

    vehicle:doDamageOverlay()
end

function VehicleUtil.DoorAnimOnServer(vehicle,part,player,open)
    if not part or part:getDoor():isOpen() == open then return end

    vehicle:playPartSound(part, player, open and "Open" or "Close")
    if isServer() then
        sendServerCommand("pzVehicleWorkshop","doorAnim",{ id = vehicle:getId(), partId = part:getId(), open = open })
    else
        vehicle:playPartAnim(part, open and "Open" or "Close")
    end
    part:getDoor():setOpen(open)
    vehicle:transmitPartDoor(part)
end

---fixme has issues
function VehicleUtil.changeVehicleScript(vehicle,scriptName,skinIndex)
    vehicle:setScriptName(scriptName)
    if not isClient() and not isServer() then
        vehicle:scriptReloaded()
    end
    --if skinIndex then vehicle:setSkinIndex(skinIndex) end
end


function VehicleUtil.generatePartParents(settings,vehicle)
    settings.partParents = {}
    local partsFound = {}
    local partsPending = {}
    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        local partId = part:getId()
        if part:getCategory() == "nodisplay" and partId:find("^Armor") ~= nil then
            local sub = partId:gsub("^Armor_","")
            if partsFound[sub] ~= nil then
                settings.partParents[sub] = partId
            else
                partsPending[sub] = partId
            end
        elseif partsPending[partId] then
            settings.partParents[partId] = partsPending[partId]
            partsPending[partId] = nil
        end
        partsFound[partId] = part
    end

    if not table.isempty(partsPending) then print("pzVehicleWorkshop: unassigned armor parts"); for k,v in pairs(partsPending) do print("no match for part "..v) end end
end

function VehicleUtil.initArmorData(vehicle,part)
    local armor = part:getTable("armor")
    local armorData = part:getModData().armorData or {}
    armorData.prevArmorCondition = part:getCondition()
    armorData.armorConditionMax = part:getInventoryItem() ~= nil and part:getInventoryItem():getModData().maxProtection or armor.maxProtection
    armorData.armorCondition = armorData.armorConditionMax * armorData.prevArmorCondition / 100
    if not armorData.protectedParts then armorData.protectedParts = {} end
    if armor.protectedParts then
        for i = 1, #armor.protectedParts do
            local prPart = vehicle:getPartById(armor.protectedParts[i])
            armorData.protectedParts[armor.protectedParts[i]] = prPart and prPart:getCondition()
        end
    end

    part:getModData().armorData = armorData
end

return VehicleUtil
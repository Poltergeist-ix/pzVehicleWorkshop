require "!_pzVehicleWorkshop_Init"

local ArmoredVehicles = {}

function ArmoredVehicles.generatePartParents(settings,vehicle)
    settings.partParents = {}
    local partsFound = {}
    local partsPending = {}
    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        local partId = part:getId()
        local sub, n = partId:gsub("^Armor_","",1)
        if n == 1 then
            if partsFound[sub] then
                settings.partParents[sub] = partId
            else
                partsPending[sub] = partId
            end
        elseif partsPending[partId] then
            settings.partParents[partId] = partsPending[partId]
            partsPending[partId] = nil
        end
        partsFound[partId] = true
    end

    if not table.isempty(partsPending) then print("pzVehicleWorkshop: unassigned armor parts") end
end

function ArmoredVehicles.initArmorData(vehicle,part)
    local armorData = part:getModData().armorData or {}
    armorData.prevArmorCondition = part:getCondition()
    armorData.armorConditionMax = part:getInventoryItem():getModData().maxProtection or 9999
    armorData.armorCondition = armorData.armorConditionMax * armorData.prevArmorCondition / 100
    local prPartId = part:getId():gsub("^Armor_","")
    local prPart = vehicle:getPartById(prPartId)
    if prPart ~= nil then
        armorData.protectedParts = { [prPartId] = prPart:getCondition() }
    else
        armorData.protectedParts = {}
    end
    if prPartId == "TrunkDoor" then
        armorData.protectedParts["TruckBed"] = vehicle:getPartById("TruckBed"):getCondition()
    end

    part:getModData().armorData = armorData
end

pzVehicleWorkshop.ArmoredVehicles = ArmoredVehicles
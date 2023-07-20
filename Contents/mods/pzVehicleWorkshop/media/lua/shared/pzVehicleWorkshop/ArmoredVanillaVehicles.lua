require "!_pzVehicleWorkshop_Init"

local ArmoredVanillaVehicles = {
    armorVehicles = {},
    vanillaVehicles = {},
}

function ArmoredVanillaVehicles.addArmoredCar(armorTypes,vanillaTypes)
    if type(armorTypes) ~= "table" or type(vanillaTypes) ~= "table" then return print("ArmoredVanillaVehicles: invalid addArmoredCar call") end
    for _,v in ipairs(armorTypes) do
        ArmoredVanillaVehicles.armorVehicles[v] = vanillaTypes
    end
    for _,v in ipairs(vanillaTypes) do
        ArmoredVanillaVehicles.vanillaVehicles[v] = armorTypes
    end
end

function ArmoredVanillaVehicles.generatePartParents(settings,vehicle)
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

---deprecated
pzVehicleWorkshop.ArmoredVanillaVehicles = ArmoredVanillaVehicles
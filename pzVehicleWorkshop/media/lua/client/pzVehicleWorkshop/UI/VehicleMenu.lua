local pzVehicleWorkshop = pzVehicleWorkshop
--local getOptions = pzVehicleWorkshop.UI.getOptions
-----------------------------------------------------------------------------------------
--- VehicleMenu
-----------------------------------------------------------------------------------------

local Menu = {}

function Menu.onDoorAnims(vehicle,part,player,open)
    sendClientCommand(player, 'pzVehicleWorkshop', 'doorAnim', { vehicleId = vehicle:getId(), partId = part:getId(), open = open })
end

function Menu.addDoorAnimOption(menu,optionName,vehicle,partId,player)
    if not partId then return end
    local part = vehicle:getPartById(partId)
    if not part then return end
    --local sliceSettings = getOptions(optionName,partId)

    if part:getDoor():isOpen() then
        menu:addSlice(getText("IGUI_pzVehicleWorkshop_AnimClose_"..optionName), getTexture("media/ui/pzVehicleWorkshop/AnimClose_"..optionName..".png"), Menu.onDoorAnims, vehicle, part, player, false)
        --menu:addSlice(sliceSettings.TextClose, sliceSettings.TextureClose, Menu.onDoorAnims, vehicle, part, player, false)
    else
        menu:addSlice(getText("IGUI_pzVehicleWorkshop_AnimOpen_"..optionName), getTexture("media/ui/pzVehicleWorkshop/AnimOpen_"..optionName..".png"), Menu.onDoorAnims, vehicle, part, player, true)
        --menu:addSlice(sliceSettings.TextOpen, sliceSettings.TextureOpen, Menu.onDoorAnims, vehicle, part, player, true)
    end
end

function Menu.checkDriverOptions(settings,vehicle,player,menu)
    if not vehicle:isDriver(player) then return end

    for _,key in ipairs({"flipLamps","convertible"}) do
        Menu.addDoorAnimOption(menu,key,vehicle,settings[key],player)
    end

end

function Menu.checkCustomRadialOptions(settings,vehicle,player,menu)
    Menu.checkDriverOptions(settings,vehicle,player,menu)
end

-----------------------------------------------------------------------------------------
--- ISVehicleMenu Patches
-----------------------------------------------------------------------------------------

Menu.Patches = {}

--- getVehicleToInteractWith searches for vehicles around player, best to cache the result
function Menu.Patches.getVehicleToInteractWith(getVehicleToInteractWith)
    return function(playerObj)
        Menu.interactVehicle = getVehicleToInteractWith(playerObj)
        return Menu.interactVehicle
    end
end

function Menu.Patches.showRadialMenu(showRadialMenu)
    return function(playerObj)
        Menu.interactVehicle = nil
        showRadialMenu(playerObj)

        if isGamePaused() then return end
        local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
        if menu:isReallyVisible() then return end -- TODO: test undisplay effect

        if playerObj:getVehicle() ~= nil then
            pzVehicleWorkshop.EventHandler.triggerEvent("OnShowVehicleRadial", playerObj:getVehicle(), playerObj, menu)
        elseif Menu.interactVehicle ~= nil then
            pzVehicleWorkshop.EventHandler.triggerEvent("OnShowVehicleRadialOutside", Menu.interactVehicle, playerObj, menu)
        end
    end
end

-----------------------------------------------------------------------------------------

if not pzVehicleWorkshop.ClientPatches then pzVehicleWorkshop.ClientPatches = {} end

function pzVehicleWorkshop.ClientPatches.patchISVehicleMenu()
    require "Vehicles/ISUI/ISVehicleMenu"
    local ISVehicleMenu = ISVehicleMenu
    for key,patchFn in pairs(Menu.Patches) do
        ISVehicleMenu[key] = patchFn(ISVehicleMenu[key])
    end
    Menu.Patches = nil
end

pzVehicleWorkshop.VehicleMenu = Menu

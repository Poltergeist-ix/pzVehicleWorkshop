local pzVehicleWorkshop = pzVehicleWorkshop

local UI = {}
--UI.settings = {
--    fontSmallHeight = getTextManager():getFontHeight(UIFont.Small),
--    fontMediumHeight = getTextManager():getFontHeight(UIFont.Medium),
--}

local Options = {
    --flipLamps = {},
    --convertible = {},
}

UI.loadOptions = {}

--function UI.loadOptions.flipLamps()
--    return {
--        TextOpen = getText("IGUI_pzVehicleWorkshop_AnimOpen_flipLamps"),
--        TextClose = getText("IGUI_pzVehicleWorkshop_AnimClose_flipLamps"),
--        TextureOpen = getTexture("media/ui/AnimOpen_flipLamps.png"),
--        TextureClose = getTexture("media/ui/AnimClose_flipLamps.png"),
--    }
--end

--function UI.loadOptions.convertible()
--    return {
--        TextOpen = getText("IGUI_pzVehicleWorkshop_AnimOpen"),
--        TextClose = getText("IGUI_pzVehicleWorkshop_AnimClose"),
--        TextureOpen = getTexture("Moodle_Bkg_Good_4"),
--        TextureClose = getTexture("Moodle_Bkg_Bad_3"),
--    }
--end

function UI.getOptions(name,select)
    if Options[name][select] ~= nil then return Options[name][select] end
    if Options[name]["default"] ~= nil then return Options[name]["default"] end
    Options[name]["default"] = UI.loadOptions[name]()
    return Options[name]["default"]
end

UI.Options = Options
pzVehicleWorkshop.UI = UI

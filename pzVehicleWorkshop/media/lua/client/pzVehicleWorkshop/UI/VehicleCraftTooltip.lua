require "ISUI/ISInventoryPaneContextMenu"
require "pzVehicleWorkshop/UI/UI"

local Tooltip = ISRecipeTooltip:derive("VehicleCraftTooltip")
local lineHeight = math.max(getTextManager():getFontHeight(UIFont.Small), 20 + 2)
local CarKeyName = getItemNameFromFullType("Base.CarKey")
function Tooltip:layoutContents(x, y)
    if self.contents then return self.contentsWidth, self.contentsHeight end
    ISRecipeTooltip.layoutContents(self,x,y)
    local x1 = x + 20
    local y1 = y + 0 + self.contentsHeight

    if self.removeCarKey then
        local last
        for i = 3, #self.contents, 3 do
            if self.contents[i].text == CarKeyName then
                table.remove(self.contents,i)
                table.remove(self.contents,i-1)
                table.remove(self.contents,i-2)
                last = i - 2
                y1 = y1 - lineHeight
                break
            end
        end
        if last ~= nil then
            for i = last, #self.contents do
                self.contents[i].y = self.contents[i].y - lineHeight
            end
        end
    end

    if self.recipe:getRequiredSkillCount() > 0 then

        for i=0,self.recipe:getRequiredSkillCount()-1 do
            local skill = self.recipe:getRequiredSkill(i)
            local perk = PerkFactory.getPerk(skill:getPerk())
            local playerLevel = self.character and self.character:getPerkLevel(skill:getPerk()) or 0
            local perkName = perk and perk:getName() or skill:getPerk():name()
            local text = perkName .. ": " .. tostring(playerLevel) .. " / " .. tostring(skill:getLevel())
            local r,g,b = 0,1,0
            if self.character and (playerLevel < skill:getLevel()) then
                r = 1
                g = 0
                b = 0
            end
            self:addText(x1, y1,text,r,g,b)
            y1 = y1 + lineHeight
        end

    end

    if self.recipe:needToBeLearn() then
        if self.character:isRecipeKnown(self.recipe) then
            self:addText(x1,y1,getText("Tooltip_Recipe_Known"),0,1,0)
        else
            self:addText(x1,y1,getText("Tooltip_Recipe_NotKnown"),1,0,0)
        end
        y1 = y1 + lineHeight
    end

    self.contentsHeight = y1 - y

    return self.contentsWidth, self.contentsHeight
end

pzVehicleWorkshop.UI.VehicleCraftTooltip = Tooltip

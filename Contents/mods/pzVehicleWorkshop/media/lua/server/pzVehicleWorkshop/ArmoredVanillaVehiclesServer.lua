---deprecated

if isClient() then return end

local avv = {}

function avv.createEngine(def,vehicle,part)
    --vehicle:removeFromWorld()
    local ticks = 0
    local function doOnce()
        if ticks <= 0  then
            Events.OnTick.Remove(doOnce)
            local script = def.replaceTypes and def.replaceTypes[1]
            --local skinIndex = vehicle:getSkinIndex()
            --print("create Engine, ",vehicle,script,skinIndex)
            vehicle:setScript(script)
            --pzVehicleWorkshop.VehicleUtilities.changeVehicleScript(vehicle,script,skinIndex)
            --vehicle:addToWorld()
        else
            ticks = ticks - 1
        end
    end
    Events.OnTick.Add(doOnce)

    return false
end

-- do
--     local VehicleSettings = pzVehicleWorkshop.VehicleSettings

--     for base,mod in pairs(pzVehicleWorkshop.ArmoredVanillaVehicles.vanillaVehicles ) do
--         VehicleSettings.add{ id = base, OnCreateEngine = avv.createEngine, replaceTypes = mod }
--     end
-- end

return avv
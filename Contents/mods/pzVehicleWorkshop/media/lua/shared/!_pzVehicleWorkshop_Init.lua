-----------------------------------------------------------------------------------------
--- Vehicle Settings
-----------------------------------------------------------------------------------------

local VehicleSettings = {}

local allSettings = {}
local proxies = {}

local function functionField(t, k, v)
    if type(v) ~= "function" then print("pzVehicleWorkShop: "..k.." is not a function") return end
    return true
end

--local function multiFunctionField(t, k, v)
--    if type(v) ~= "function" then print("pzVehicleWorkShop: "..k.." is not a function") return end
--    if t[k] then table.insert(t[k],v) else t[k] = {v} end
--end

local function tableField(t,k,v)
    if type(v) ~= "table" then print("pzVehicleWorkShop: "..k.." is not a table") return end
    return true
end

local specialFields = {
    id = function() end,
    partParents = tableField,
    --DriverDoorAnims = tableField,
    OnVehicleMechanicsDrawItems = functionField,
    OnSetHeadlightsOn = functionField,
}

local function setFieldValue(t,k,v)
    t = t.__index
    --t = getmetatable(t).__index -- if ref removed
    if not specialFields[k] or specialFields[k](t,k,v) then
        t[k] = v
    end
end

function VehicleSettings.add(...)
    local args = {...}
    local scriptName = type(args[1]) == "table" and args[1].id or args[1]
    if type(scriptName) ~= "string" then return print("pzVehicleWorkShop: invalid scriptName") end

    local proxy = proxies[scriptName]

    if not proxy then
        local settings = {id = scriptName}
        allSettings[scriptName] = settings
        proxy = setmetatable({}, {__index=settings,__newindex=setFieldValue})
        --proxy.__index = proxy --should remove ref?
        proxies[scriptName] = proxy
    end

    for _,arg in ipairs(args) do
        if type(arg) == "table" then
            for k,v in pairs(arg) do
                setFieldValue(proxy,k,v)
            end
        end
    end
end

function VehicleSettings.set(scriptName,k,v)
    if not allSettings[scriptName] and v == nil then
        return
    elseif v == nil then
        allSettings[scriptName][k] = nil
    elseif not allSettings[scriptName] then
        VehicleSettings.add{scriptName, { [k] = v }}
    else
        setFieldValue(allSettings[scriptName],k,v)
    end
end

function VehicleSettings.get(scriptName)
    return proxies[scriptName]
end

-----------------------------------------------------------------------------------------
--- Add Events
-----------------------------------------------------------------------------------------

do
    local _addEvent = LuaEventManager.AddEvent

    local function addEvent(name)
        _addEvent(name)
        specialFields[name] = functionField
    end

    addEvent("OnVehicleMechanicsOpen")
    addEvent("OnVehicleMechanicsPartContext")
    addEvent("OnVehicleMechanicsVehicleContext")
    addEvent("OnVehicleMechanicsDoMenuTooltip")
    addEvent("OnShowVehicleRadial")
    addEvent("OnShowVehicleRadialOutside")
    addEvent("OnCreateEngine")

end

-----------------------------------------------------------------------------------------
--- EventHandler
-----------------------------------------------------------------------------------------

local EventHandler = {}

function EventHandler.triggerEvent(eventName,vehicle,...)
    triggerEvent(eventName,vehicle,...)
    local settings = proxies[vehicle:getScriptName()]
    if settings ~= nil and settings[eventName] ~= nil then settings[eventName](settings,vehicle,...) end
end

function EventHandler.triggerOverride(eventName,vehicle,...)
    local def = proxies[vehicle:getScriptName()]
    if def ~= nil and def[eventName] ~= nil and def[eventName](def,vehicle,...) then
        return true
    else
        triggerEvent(eventName,vehicle,...)
    end
end

function EventHandler.triggerNoEvent(eventName,vehicle,...)
    local settings = proxies[vehicle:getScriptName()]
    if settings ~= nil and settings[eventName] ~= nil then
        return settings[eventName](settings,vehicle,...)
    end
end

function EventHandler.triggerDef(eventName,def,...)
    triggerEvent(eventName,...)
    if def ~= nil and def[eventName] ~= nil then def[eventName](def,...) end
end

function EventHandler.triggerDefReplace(eventName,def,...)
    if def ~= nil and def[eventName] ~= nil then return def[eventName](def,...) end
end

-----------------------------------------------------------------------------------------
--- pzVehicleWorkshop
-----------------------------------------------------------------------------------------

pzVehicleWorkshop = {
    VehicleSettings = VehicleSettings,
    EventHandler = EventHandler,
}

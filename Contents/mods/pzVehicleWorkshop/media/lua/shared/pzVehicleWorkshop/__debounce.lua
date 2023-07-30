--[[
-- local lastTick = 0 ---can be used in framework for performance instead of os.time
--pending[i]:next() --need mt
pzVehicleWorkshop.Util = pzVehicleWorkshop.Util or {}
check if has new args?

]]

---check for Timer Framework
if false then return end

local isempty,insert,time = table.isempty,table.insert, os.time

local pending = {}
local debouncePending = {}

local function queue(t,fn,...)
    table.insert(pending,{
        fn = fn,
        next = time() + t,
        args = {...},
    })
end

local function debounce(t,fn,...)
    if debouncePending[fn] ~= nil then
        debouncePending[fn].next = os.time() + t
        insert(debouncePending[fn].args,{...})
    else
        debouncePending[fn] = {
            fn = fn,
            next = os.time() + t,
            args = {...},
        }
        table.insert(pending,debouncePending[fn])
    end
end

local function tick()
    if isempty(pending) then return end
    local current = os.time()
    for i = #pending, 1, -1 do
        if pending[i].next <= current then
            local t = pending[i]
            t.fn(t.args)
            debouncePending[t.fn] = nil
            table.remove(pending,i)
        end
    end
end

Events.OnTickEvenPaused.Add(tick)

pzVehicleWorkshop.Timing = { queue = queue, debounce = debounce }
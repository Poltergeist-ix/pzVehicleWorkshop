local Util = {}

function Util.callLua(name,...)
    local v = _G
    for _,key in ipairs(name:split("\\.")) do
        v = v[key]
    end
    return v(...)
end

return Util
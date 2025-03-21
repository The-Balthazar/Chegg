function math.easeDecay(a,b,d,dt) return b+(a-b)*math.exp(-d*dt) end
function math.clamp(n, min, max) return math.min(max, math.max(n, min)) end
function math.round(n) return math.floor(n+0.5) end
function math.sign(n) return n<0 and -1 or n==0 and 0 or 1 end

function table.find(a,f)
    for i, v in ipairs(a) do
        if v==f then
            return i
        end
    end
end

function table.removeByValue(t, v)
    local f = table.find(t, v)
    if f then
        return table.remove(t, f)
    end
end

function table.randomSort(t)
    if not t[1] and not t[2] then return t end
    for i=1, #t do
        local r = love.math.random(i, #t)
        if r~=i then
            t[i], t[r] = t[r], t[i]
        end
    end
    return t
end

function repr(t)
    if not t then return end
    for i, v in pairs(t) do
        print(i, v)
    end
end

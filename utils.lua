function math.easeDecay(a,b,d,dt) return b+(a-b)*math.exp(-d*dt) end
function math.clamp(n, min, max) return math.min(max, math.max(n, min)) end
function math.round(n) return math.floor(n+0.5) end
function math.sign(n) return n<0 and -1 or n==0 and 0 or 1 end

function table.copy(t,new)
    new=new or {}
    if t then
        for k, v in pairs(t) do
            new[k]=v
        end
    end
    return new
end

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

function table.randomSort(gen, t)
    if not t[1] and not t[2] then return t end
    for i=1, #t do
        local r = gen:random(i, #t)
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

function table.maxi(a)
    local n
    for i, v in pairs(a) do
        if 'number' == type(i) then
            n = not n and i or math.max(n, i)
        end
    end
    return n
end

function table.len(a)
    local n = 0
    for i, v in pairs(a) do
        n = n+1
    end
    return n
end

local reserved = {
    ['and']    = 'and',
    ['break']  = 'break',
    ['do']     = 'do',
    ['else']   = 'else',
    ['elseif'] = 'elseif',
    ['goto']   = 'goto',

    ['end']      = 'end',
    ['false']    = 'false',
    ['for']      = 'for',
    ['function'] = 'function',
    ['if']       = 'if',

    ['in']    = 'in',
    ['local'] = 'local',
    ['nil']   = 'nil',
    ['not']   = 'not',
    ['or']    = 'or',

    ['repeat'] = 'repeat',
    ['return'] = 'return',
    ['then']   = 'then',
    ['true']   = 'true',
    ['until']  = 'until',
    ['while']  = 'while',
}

function table.serialize(val, key, depth)
    depth = depth or 0

    local buffer = {string.rep('    ', depth)}
    if type(key) ~= 'number' then
        table.insert(buffer, (key and key..' = ' or 'return '))
    end

    local valtype = type(val)
    if valtype == 'table' then
        if next(val) then
            table.insert(buffer, "{\n")
            if table.len(val) == #val and table.maxi(val) == #val then
                for i, v in ipairs(val) do
                    table.insert(buffer, table.serialize(v, i, depth + 1) .. ",\n")
                end
            else
                for k, v in pairs(val) do
                    if type(k) == 'number' then
                        k = '['..tostring(k)..']'
                    elseif k:find'^%A' or k:find'[^%w_]' or reserved[k] then
                        k = string.format("[%q]", tostring(k) )
                    end
                    table.insert(buffer, table.serialize(v, k, depth + 1) .. ",\n")
                end
            end
            table.insert(buffer, string.rep('    ', depth) .. '}')

        else
            table.insert(buffer, '{}')
        end

    elseif valtype == 'number' or valtype == 'boolean' then
        table.insert(buffer, tostring(val))

    elseif valtype == 'string' then
        table.insert(buffer, string.format("%q", val))

    else
        table.insert(buffer, string.format("%q", tostring(val)))
    end
    return table.concat(buffer)
end

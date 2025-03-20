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

function repr(t)
    if not t then return end
    for i, v in pairs(t) do
        print(i, v)
    end
end

local activeboard, activepreview

function love.load()
    spriteAtlas = love.graphics.newImage'sprites.png'
    spriteAtlas:setFilter('nearest', 'nearest')

    spriteSize = 50
    function genQuad(xi, yi)
        return love.graphics.newQuad((xi-1)*spriteSize, (yi-1)*spriteSize, spriteSize, spriteSize, spriteAtlas)
    end

    activeboard = require'board'.new{
        rows = 10,
        cols = 8,
    }
    activepreview = require'preview'.new{
        getPreviewItem = function()
            local piece = activeboard:getSelectedPiece()
            if piece then
                return require'pieces'.getTypeData(piece.type)
            end
        end,
        getResourceCount = function()
        end,
        getTurnNumber = function()
            return activeboard.turn
        end,
        endTurn = function()
            activeboard:endTurn()
        end,
    }
    activeboard:summonAt('king', 2, 10)
    activeboard:summonAt('blaze', 3, 10)
    activeboard:summonAt('phantom', 6, 10)
    activeboard:summonAt('pufferfish', 8, 10)

    activeboard:summonAt('box', 4, 10)
    activeboard:summonAt('zombie', 5, 8)
    activeboard:summonAt('slime', 4, 8)
    activeboard:summonAt('sniffer', 3, 8)

    activeboard:summonAt('wither', 3, 4)
    activeboard:summonAt('golem', 2, 4)
    activeboard:summonAt('creeper', 4, 4)
    activeboard:summonAt('pig', 5, 4)
    activeboard:summonAt('rabbit', 6, 4)
    activeboard:summonAt('frog', 7, 4)
    activeboard:summonAt('skeleton', 8, 4)
    activeboard:summonAt('farlander', 8, 5)
    activeboard:summonAt('cat', 8, 9)
end

function love.update(delta)
    if activeboard then
        activeboard:update(delta)
    end
end

function love.draw()
    love.graphics.clear(1/2,1/2,1/2)
    love.graphics.setColor(0,0,0)

    if activeboard then
        activeboard:draw() -- love.graphics.getWidth()/2,love.graphics.getHeight()/2
    end
    if activepreview then
        activepreview:draw()
    end
end

function love.mousemoved(x, y, xDelta, yDelta, istouch)
    if activepreview and activepreview:mousemoved(x, y, xDelta, yDelta, istouch) then return end
    if activeboard   and   activeboard:mousemoved(x, y, xDelta, yDelta, istouch) then return end
end

function love.mousepressed(x, y, button, istouch, presses)
    if activepreview and activepreview:mousepressed(x, y, button, istouch, presses) then return end
    if activeboard   and   activeboard:mousepressed(x, y, button, istouch, presses) then return end
end

function love.mousereleased(x, y, button, istouch, presses)
    if activepreview and activepreview:mousereleased(x, y, button, istouch, presses) then return end
    if activeboard   and   activeboard:mousereleased(x, y, button, istouch, presses) then return end
end

function love.wheelmoved(x, y)
    if activeboard then
        activeboard:wheelmoved(x, y)
    end
end

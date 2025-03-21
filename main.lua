local activeboard, activepreview, activeplayer

function love.load()
    require'utils'

    spriteAtlas = love.graphics.newImage'sprites.png'
    spriteAtlas:setFilter('nearest', 'nearest')

    spriteSize = 50
    function genQuad(xi, yi)
        return love.graphics.newQuad((xi-1)*spriteSize, (yi-1)*spriteSize, spriteSize, spriteSize, spriteAtlas)
    end

    activeplayer = require'player'.new{}

    activeboard = require'board'.new{
        rows = 10,
        cols = 8,
        players = {activeplayer}
    }
    activepreview = require'preview'.new{
        board = activeboard,
        player = activeplayer,
        getPreviewItem = function()
            local piece = activeboard:getSelectedPiece()
            if piece then
                return require'pieces'.getTypeData(piece.type)
            end
        end,
        getManaCount = function() return activeplayer:getMana() end,
        getTurnNumber = function() return activeboard.turn end,
        endTurn = function()
            activeboard:endTurn(activeplayer)
        end,
        canEndTurn = function() return activeboard:canEndTurn(activeplayer) end,
        getHand = function() return activeplayer:getHand() end,
    }
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
        activeboard:draw()
    end
    if activepreview then
        activepreview:draw()
    end
end

function love.mousemoved(x, y, xDelta, yDelta, istouch)
    local intercepted
    if activepreview then intercepted = activepreview:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
    if activeboard   then intercepted =   activeboard:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
end

function love.mousepressed(x, y, button, istouch, presses)
    local intercepted
    if activepreview then intercepted = activepreview:mousepressed(x, y, button, istouch, presses, intercepted) end
    if activeboard   then intercepted =   activeboard:mousepressed(x, y, button, istouch, presses, intercepted) end
end

function love.mousereleased(x, y, button, istouch, presses)
    local intercepted
    if activepreview then intercepted = activepreview:mousereleased(x, y, button, istouch, presses, intercepted) end
    if activeboard   then intercepted =   activeboard:mousereleased(x, y, button, istouch, presses, intercepted) end
end

function love.wheelmoved(x, y)
    if activeboard then
        activeboard:wheelmoved(x, y)
    end
end

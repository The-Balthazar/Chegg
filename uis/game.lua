local game = {}
game.__index = game

function game:new()
    setmetatable(self, game)

    self.activeplayer = require'player'.new{
        deck = self.deck,
    }

    self.activeboard = require'board'.new{
        rows = 10,
        cols = 8,
        players = {self.activeplayer}
    }
    self.activepreview = require'preview'.new{
        board = self.activeboard,
        player = self.activeplayer,
        getPreviewItem = function()
            local piece = self.activeboard:getSelectedPiece()
            if piece then
                return require'pieces'.getTypeData(piece.type)
            end
        end,
        getManaCount = function() return self.activeplayer:getMana() end,
        getTurnNumber = function() return self.activeboard.turn end,
        getHand = function() return self.activeplayer:getHand() end,
        getDeckSize = function() return self.activeplayer:getDeckSize() end,
        buttons = {
            {
                xy = function() return spriteSize*3, love.graphics.getHeight()-(spriteSize*2)+20 end,
                widthheight = function() return 200, 100-40 end,
                press = function() self.activeboard:endTurn(self.activeplayer) end,
                text = ('End turn'):lower(),
                activeIf = function() return self.activeboard:canEndTurn(self.activeplayer) end,
            }
        }
    }
    return self
end

function game:update(delta)
    if self.activeboard then
        self.activeboard:update(delta)
    end
end

function game:draw()
    love.graphics.clear(1/2,1/2,1/2)
    love.graphics.setColor(0,0,0)

    if self.activeboard   then self.activeboard:draw()   end
    if self.activepreview then self.activepreview:draw() end
end

function game:mousemoved(x, y, xDelta, yDelta, istouch)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
    if self.activeboard   then intercepted =   self.activeboard:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
end

function game:mousepressed(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousepressed(x, y, button, istouch, presses, intercepted) end
    if self.activeboard   then intercepted =   self.activeboard:mousepressed(x, y, button, istouch, presses, intercepted) end
end

function game:mousereleased(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousereleased(x, y, button, istouch, presses, intercepted) end
    if self.activeboard   then intercepted =   self.activeboard:mousereleased(x, y, button, istouch, presses, intercepted) end
end

function game:wheelmoved(x, y)
    if self.activeboard then
        self.activeboard:wheelmoved(x, y)
    end
end

return game

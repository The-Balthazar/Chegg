local game = {}
game.__index = game

function game:new()
    setmetatable(self, game)

    self.localplayer = require'player'.new{
        deck = self.deck,
    }

    if self.opponentDeck then
        self.otherplayer = require'player'.new{
            deck = self.opponentDeck,
        }
    end

    local first = self.isStartingPlayer

    self.activeboard = require'board'.new{
        rows = 10,
        cols = 8,
        players = {
            first and self.localplayer or self.otherplayer,
            first and self.otherplayer or self.localplayer,
        },
        localplayer = self.localplayer,
        otherplayer = self.otherplayer,
        othertype = self.opponentType,
    }
    self.activepreview = require'preview'.new{
        board = self.activeboard,
        player = self.localplayer,
        getPreviewItem = function()
            local piece = self.activeboard:getSelectedPiece()
            if piece then
                return require'pieces'.getTypeData(piece.type)
            end
        end,
        getManaCount = function() return self.localplayer:getMana() end,
        getTurnNumber = function() return self.activeboard.turn end,
        getHand = function() return self.localplayer:getHand() end,
        getDeckSize = function() return self.localplayer:getDeckSize() end,
        buttons = {
            {
                xy = function() return spriteSize*3, love.graphics.getHeight()-(spriteSize*2)+20 end,
                widthheight = function() return 200, 100-40 end,
                press = function()
                    self.activeboard:endTurn(self.localplayer)
                end,
                text = ('End turn'):lower(),
                activeIf = function() return self.activeboard:canEndTurn(self.localplayer) end,
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

local text = love.graphics.newImageFont('bigtext.png', ' abcdefghijklmnopqrstuvwxyz!?')
text:setFilter('nearest', 'nearest')

function game:draw()
    love.graphics.clear(1/2,1/2,1/2)
    if self.activeboard   then self.activeboard:draw()   end
    if self.activepreview then self.activepreview:draw() end
    love.graphics.setColor(0,0,0)
    if self.otherplayer and self.otherplayer.dead and not self.localplayer.dead then
        love.graphics.printf('you win!?', text, 0, 100, love.graphics.getWidth()/2, 'center', 0, 2, 2)
    elseif self.otherplayer and self.otherplayer.dead and self.localplayer.dead then
        love.graphics.printf('draw!?', text, 0, 100, love.graphics.getWidth()/2, 'center', 0, 2, 2)
    elseif self.otherplayer and not self.otherplayer.dead and self.localplayer.dead then
        love.graphics.printf('you lose!?', text, 0, 100, love.graphics.getWidth()/2, 'center', 0, 2, 2)
    end
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

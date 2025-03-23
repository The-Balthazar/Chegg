local menu = {}
menu.__index = menu

function menu:new()
    setmetatable(self, menu)

    local savedDeck = love.filesystem.getInfo'decks/deck.lua'

    self.activepreview = require'preview'.new{
        buttons = {
            {
                xy = function() return love.graphics.getWidth()/2-100, love.graphics.getHeight()/2-30 end,
                widthheight = function() return 200, 60 end,
                press = function() setMode(require'uis.deckbuild'.new{}) end,
                text = savedDeck and 'edit deck' or 'create deck',
            },
            {
                xy = function() return love.graphics.getWidth()/2-100, love.graphics.getHeight()/2+40 end,
                widthheight = function() return 200, 60 end,
                press = function() setMode(require'uis.game'.new{
                    deck = love.filesystem.load'decks/deck.lua'(),
                }) end,
                text = 'play',
                activeIf = function() return savedDeck end,
            },
        }
    }
    return self
end

function menu:draw()
    love.graphics.clear(1/2,1/2,1/2)
    -- love.graphics.setColor(0,0,0)

    if self.activepreview then self.activepreview:draw() end
end

function menu:mousemoved(x, y, xDelta, yDelta, istouch)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
end

function menu:mousepressed(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousepressed(x, y, button, istouch, presses, intercepted) end
end

function menu:mousereleased(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousereleased(x, y, button, istouch, presses, intercepted) end
end

return menu

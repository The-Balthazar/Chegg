local menu = {}
menu.__index = menu

local version = 2
local goodToStart = true
local connection

require'enet.handlers'

function menu:new()
    setmetatable(self, menu)

    self.ipbutton = {
        xy = function()
            return 600, 50
        end,
        widthheight = function() return 500, 50 end,
        press = function()
            if connection then return end
            self.ipbutton.selpress = not self.ipbutton.selpress
        end,
        onHover = function()
            if connection then return end
            self.ipbutton.hover = true
        end,
        activeIf = function() return not connection end,
        text = 'localhost:25565',
        getText = function()
            return (self.ipbutton.hover or self.ipbutton.selpress) and not connection and (math.floor(love.timer.getTime()*1.5)%2)==1 and ' '..self.ipbutton.text..'|'
        end
    }

    function self.START(button, secondPlayer)
        if not self.deck then return end
        if connection and self.opponentType~='remote' then return end
        if not goodToStart then return end
        setMode(require'uis.game'.new{
            deck = self.deck,
            isStartingPlayer = not secondPlayer,
            opponentType = self.opponentType,
            opponentDeck = self.opponentDeck,
        })
        if self.opponentType=='remote' then
            love.thread.getChannel'comOut':push('START')
        end
    end

    self.activepreview = require'preview'.new{
        buttons = {
            {
                xy = function()
                    return 50, 50
                end,
                widthheight = function() return 200, 50 end,
                press = function()
                    if connection then return end
                    EnetInit(self.ipbutton.text, true)
                    self.ipbutton.selpress = nil
                    connection = true
                    goodToStart = nil
                    self.ipbutton.text = ('hosting on udp port %s'):format(self.ipbutton.text:match':([%d]+)' or '25565')
                end,
                activeIf = function() return not connection end,
                text = 'host',
            },
            {
                xy = function()
                    return 300, 50
                end,
                widthheight = function() return 200, 50 end,
                press = function()
                    if connection then return end
                    EnetInit(self.ipbutton.text)
                    self.ipbutton.selpress = nil
                    connection = true
                    goodToStart = nil
                    local i, p = (self.ipbutton.text:match'^([%w%.]+)' or 'localhost'), (self.ipbutton.text:match'(:[%d]+)' or ':25565')
                    self.ipbutton.text = ('connecting to %s%s'):format(i, p)
                end,
                activeIf = function() return not connection end,
                text = 'join',
            },
            {
                xy = function()
                    return 550, 50
                end,
                widthheight = function() return 50, 50 end,
                press = self.ipbutton.press,
                onHover = self.ipbutton.onHover,
                activeIf = function() return not connection end,
                text = 'ip',
            },
            self.ipbutton,
            {
                xy = function()
                    local w = love.graphics.getWidth()
                    return w-250, w>1355 and 50 or 100
                end,
                widthheight = function() return 200, 50 end,
                press = function() setMode(require'uis.mainmenu'.new{}) end,
                text = 'go back',
            },
            {
                xy = function()
                    return love.graphics.getWidth()-250, love.graphics.getHeight()-100
                end,
                widthheight = function() return 200, 50 end,
                press = self.START,
                text = 'play',
                activeIf = function() return self.deck and goodToStart end,
            },
        }
    }
    return self
end

function menu:draw()
    love.graphics.clear(1/2,1/2,1/2)
    if self.activepreview then self.activepreview:draw() end
end

function menu:update(delta)
    EnetHandle(function(data)
        if data:find'^MSG: ' then
            self.ipbutton.text = data:match'^MSG: (.*)'
            local com = love.thread.getChannel'comOut'
            com:push('SCENARIO: '..table.serialize({
                deck = self.deck,
                version = version,
            }))
        elseif data:find'^DECK: return ' then
            self.ipbutton.text = 'other is running an old version'
        elseif data:find'^SCENARIO: return ' then
            local success, chunk = pcall(setfenv, loadstring(data:match'^SCENARIO: (.*)', "remote player data"), {})
            if success then
                local data = chunk()
                repr(data)
                self.opponentDeck = data.deck
                self.opponentType = 'remote'
                if data.version==version then
                    goodToStart = true
                else
                    self.ipbutton.text = ('version missmatch error (%d vs %d)'):format(version, data.version)
                end
            else
                self.ipbutton.text = ('connected player sent bad data')
            end
        elseif data=='START' then
            self.START(nil, true)
        end
    end)
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

function menu:keypressed(k)
    if connection then return end
    if not (self.ipbutton.hover or self.ipbutton.selpress) then return end
    if k=='backspace' and self.ipbutton.text~='' then
        self.ipbutton.text = self.ipbutton.text:sub(1, -2)
    end
end

function menu:textinput(t)
    if connection then return end
    if not (self.ipbutton.hover or self.ipbutton.selpress) then return end
    self.ipbutton.text = self.ipbutton.text..t:lower()
end

return menu

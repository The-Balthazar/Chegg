local deckbuild = {}
deckbuild.__index = deckbuild

local baseItemWidth = 100

local function getGroupWidth(self)
    return math.min(love.graphics.getWidth()-680, #self.cardsArray*baseItemWidth)
end

local function selectionPosData(self)
    local groupWidth = getGroupWidth(self)

    local width = groupWidth/#self.cardsArray
    local height = width
    local scale = width/spriteSize

    local x = love.graphics.getWidth()/2-(groupWidth/2)
    local y = love.graphics.getHeight()/2-height/2

    return width, height, x, y, scale
end

function deckbuild:new()
    setmetatable(self, deckbuild)

    self.cardsArray = {}
    self.cardsHash = require'pieces'.getTypesData()
    self.deckHash = {}
    self.deckCount = 0

    self.keysByCost = {}
    self.highestCost = 0
    for k, v in pairs(self.cardsHash) do
        if v.deck then
            table.insert(self.cardsArray, k)
            self.deckHash[k] = 0
            if not self.keysByCost[v.cost] then self.keysByCost[v.cost] = {} end
            table.insert(self.keysByCost[v.cost], k)
            self.highestCost = math.max(self.highestCost, v.cost)
        end
    end
    for i=1, self.highestCost do
        if self.keysByCost[i] then
            self.keysByCost[i].getCount = function()
                local count = 0
                for _, key in ipairs(self.keysByCost[i]) do
                    count = count+self.deckHash[key]
                end
                return count
            end
        end
    end

    local savedDeck = love.filesystem.getInfo'decks/deck.lua'
    if savedDeck then
        savedDeck = love.filesystem.load'decks/deck.lua'()
        for i, key in ipairs(savedDeck) do
            if self.deckHash[key] then
                self.deckHash[key] = self.deckHash[key]+1
                self.deckCount = self.deckCount+1
            end
        end
    end

    table.sort(self.cardsArray, function(a, b)
        local acost, bcost = self.cardsHash[a].cost, self.cardsHash[b].cost
        if acost==bcost then return a<b end
        return acost<bcost
    end)

    local previewItem

    self.activepreview = require'preview'.new{
        getPreviewItem = function()
            return self.cardsHash[previewItem]
        end,
        buttons = {
            {
                xy = function()
                    return love.graphics.getWidth()-250, love.graphics.getHeight()-100
                end,
                widthheight = function()
                    return 200, 50
                end,
                press = function()
                    if self.deckCount~=15 then return end
                    local deckArray = {}
                    for k, count in pairs(self.deckHash) do
                        for i=1, count do
                            table.insert(deckArray, k)
                        end
                    end
                    love.filesystem.createDirectory'decks'
                    love.filesystem.write('decks/deck.lua', table.serialize(deckArray))
                end,
                text = 'save deck',
                activeIf = function() return self.deckCount==15 end,
            }
        }
    }

    for i, key in ipairs(self.cardsArray) do
        table.insert(self.activepreview.buttons, {
            xy = function()
                local width, height, x, y, scale = selectionPosData(self)
                return x+(i-1)*width, y
            end,
            widthheight = function() return selectionPosData(self) end,
            onHover = function() previewItem = key end,
        })
        table.insert(self.activepreview.buttons, {
            xy = function()
                local width, height, x, y, scale = selectionPosData(self)
                return x+(i-0.9)*width, y-height
            end,
            widthheight = function()
                local width, height = selectionPosData(self)
                return width*0.8, height*0.8
            end,
            onHover = function() previewItem = key end,
            press = function()
                if self.deckCount>=15 then return end
                self.deckCount = self.deckCount+1
                self.deckHash[key] = self.deckHash[key]+1
            end,
            text = '+',
            activeIf = function() return self.deckCount<15 end,
        })
        table.insert(self.activepreview.buttons, {
            xy = function()
                local width, height, x, y, scale = selectionPosData(self)
                return x+(i-0.9)*width, y+height*1.2
            end,
            widthheight = function()
                local width, height = selectionPosData(self)
                return width*0.8, height*0.8
            end,
            onHover = function() previewItem = key end,
            press = function()
                if self.deckHash[key]<=0 then return end
                self.deckCount = self.deckCount-1
                self.deckHash[key] = self.deckHash[key]-1
            end,
            text = '-',
            activeIf = function() return self.deckHash[key]>0 end,
        })
    end
    return self
end

function deckbuild:update(delta)
    -- if self.activeboard then
    --     self.activeboard:update(delta)
    -- end
end

local text = love.graphics.newImageFont('text.png', ' abcdefghijklmnopqrstuvwxyz1234567890+-/().,:;')
text:setFilter('nearest', 'nearest')

local teenyGem = genQuad(10, 7)

function deckbuild:draw()
    love.graphics.clear(1/2,1/2,1/2)

    if self.activepreview then self.activepreview:draw() end

    local width, height, x, y, scale = selectionPosData(self)

    if self.deckCount>0 then
        love.graphics.setColor(0,0,0)
        love.graphics.print(('Deck list:'):lower(), text, 10, 10, 0, 2, 2)
        local deckYPos = 35
        for i, key in ipairs(self.cardsArray) do
            if self.deckHash[key]>0 then
                local item = self.cardsHash[key]
                love.graphics.setColor(1,1,1)
                love.graphics.draw(item.image, item.quad, 10, deckYPos, 0, 0.5, 0.5)
                love.graphics.setColor(0,0,0)
                love.graphics.print(('%dx - %s'):format(self.deckHash[key], item.name:lower()), text, 40, deckYPos, 0, 2, 2)
                deckYPos = deckYPos+25
            end
        end
        love.graphics.print(('%d/15'):format(self.deckCount), text, 20, deckYPos+5, 0, 2, 2)

        love.graphics.print(('Mana curve:'):lower(), text, 340, 10, 0, 2, 2)
        local peak = 0
        for i=1, self.highestCost do
            local count = self.keysByCost[i].getCount()
            peak = math.max(peak, count)
        end
        for i=1, self.highestCost do
            local x = 340+(i-1)*width
            local count = self.keysByCost[i].getCount()
            local barHeightTotal = y-height-120
            local barHeight = barHeightTotal*(count/peak)
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle('fill', x, 50+barHeightTotal-barHeight, width, barHeight)

            if count~=0 then
                local x, y = x+width/2, 50+barHeightTotal-barHeight
                local subDiv = barHeight/count
                local scale = math.min(width/spriteSize,subDiv/spriteSize)
                y = y+subDiv/2
                for i, key in ipairs(self.keysByCost[i]) do
                    for i=1, self.deckHash[key] do
                        love.graphics.draw(self.cardsHash[key].image, self.cardsHash[key].quad, x, y, 0, scale, scale, 25, 25)
                        y = y+subDiv
                    end
                end
            end

            love.graphics.draw(spriteAtlas, teenyGem, x+width/2, y-height-50, 0, 2, 2, 25, 25)
            for x=x, x+4, 2 do
                for y=y-height-60-2, y-height-60+2, 2 do
                    love.graphics.printf(i, text, x, y, width/2, 'center', 0, 2, 2)
                end
            end

            love.graphics.setColor(0,0,0)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle('line', x, 50+barHeightTotal-barHeight, width, barHeight)
            love.graphics.printf(i, text, x+2, y-height-60, width/2, 'center', 0, 2, 2)
        end
    end

    love.graphics.setColor(1,1,1)
    for i, key in ipairs(self.cardsArray) do
        local item = self.cardsHash[key]
        love.graphics.draw(item.image, item.quad, math.floor(x+(i-1)*width), math.floor(y), 0, scale, scale)
    end

    -- if self.activeboard   then self.activeboard:draw()   end
end

function deckbuild:mousemoved(x, y, xDelta, yDelta, istouch)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
    -- if self.activeboard   then intercepted =   self.activeboard:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
end

function deckbuild:mousepressed(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousepressed(x, y, button, istouch, presses, intercepted) end
    -- if self.activeboard   then intercepted =   self.activeboard:mousepressed(x, y, button, istouch, presses, intercepted) end
end

function deckbuild:mousereleased(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousereleased(x, y, button, istouch, presses, intercepted) end
    -- if self.activeboard   then intercepted =   self.activeboard:mousereleased(x, y, button, istouch, presses, intercepted) end
end

function deckbuild:wheelmoved(x, y)
    -- if self.activeboard then
    --     self.activeboard:wheelmoved(x, y)
    -- end
end

return deckbuild

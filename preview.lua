local preview = {}
preview.__index = preview

function preview.new(data)
    local new = setmetatable(data, preview)
    data.buttons = {}
    if data.endTurn then
        table.insert(data.buttons, {
            xy = function() return spriteSize*3, love.graphics.getHeight()-(spriteSize*2)+20 end,
            widthheight = function() return 200, 100-40 end,
            press = data.endTurn,
            text = ('End turn'):lower(),
            activeIf = data.canEndTurn,
        })
    end

    return new
end

local text = love.graphics.newImageFont('text.png', ' abcdefghijklmnopqrstuvwxyz1234567890+-/().,:;')
text:setFilter('nearest', 'nearest')

local gemz = {
    blue  = genQuad(4, 7),
    blueG = genQuad(5, 7),
    grey  = genQuad(6, 7),
    white = genQuad(7, 7),
    nul   = genQuad(8, 7),
    teeny = genQuad(10, 7),
}

local handCardPreview, handHoverIndex, handPressIndex

function preview:draw()
    if handCardPreview or self.getPreviewItem then
        local item = handCardPreview or self.getPreviewItem()
        local width, height = 340, 520
        local x, y = love.graphics.getWidth()-width, love.graphics.getHeight()/2-height/2
        if item then
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill", x, y, width, height)
            love.graphics.setColor(0,0,0)
            love.graphics.printf(item.name:lower(), text, x+10, y+10, width/2-10, 'center', 0, 2, 2)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", x, y, width, height)
            love.graphics.rectangle("line", x+5, y+5, width-10, height-10)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(item.image, item.quad, x+10, y+30, 0, 2, 2)
            if item.quadM then
                love.graphics.draw(item.image, item.quadM, x+10+110, y+30, 0, 2, 2)
            end
            if item.quadA then
                love.graphics.draw(item.image, item.quadA, x+10+220, y+30, 0, 2, 2)
            end
            if item.desc then
                love.graphics.setColor(0,0,0)
                love.graphics.printf(('Summon cost: %d\n\n%s'):lower():format(item.cost, item.desc:lower()), text, x+10, y+135, width/2-10, 'left', 0, 2, 2)
            end
        end
    end
    if self.getManaCount then
        local count, max = self.getManaCount()
        local y = love.graphics.getHeight()

        love.graphics.setColor(1,1,1)
        for i=1, math.max(count, max, 6) do
            love.graphics.draw(
                spriteAtlas,
                i<=count and gemz.blue or i<=max and gemz.grey or gemz.nul,
                i%2~=0 and spriteSize or 0,
                y-(i*spriteSize*1.5)-spriteSize*0.5,
                0, 2, 2
            )
        end
    end
    for i, v in ipairs(self.buttons) do
        local x, y = v.xy()
        local active = not v.activeIf or v.activeIf()
        local lum = active and 0 or 0.75
        local width, height = v.widthheight()
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(lum,lum,lum)
        love.graphics.rectangle("line", x, y, width, height)
        if not v.hover or not active then
            love.graphics.rectangle("line", x+5, y+5, width-10, height-10)
        end
        love.graphics.setColor(lum,lum,lum,v.pressed and active and 0.5 or 1)
        love.graphics.printf(v.text, text, x+10, y+20, width/2-10, 'center', 0, 2, 2)
    end
    if self.getTurnNumber then
        local count = tonumber(self.getTurnNumber())
        if count then
            local x, y = spriteSize*3, love.graphics.getHeight()-(spriteSize*2)
            love.graphics.setColor(0,0,0)
            local orderTurn = count%2==1 and 'First Player' or 'Second Player'
            love.graphics.printf(('Turn: %d - %s'):lower():format(math.max(0,math.ceil(count/2)), orderTurn:lower()), text, x-5, y-5, 200, 'left', 0, 2, 2)
        end
    end
    if self.getDeckSize then
        local deck = self.getDeckSize()
        local width, height = 140, 80
        local x, y = love.graphics.getWidth()-width, love.graphics.getHeight()-height
        local king = require'pieces'.getTypeData'king'

        for i=1, deck do
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill", x, y, width, height)
            love.graphics.setColor(0.5,0,0.5)
            love.graphics.rectangle("fill", x+5, y+5, width-10, height-10)
            love.graphics.setColor(0,0,0)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", x, y, width, height)
            love.graphics.rectangle("line", x+5, y+5, width-10, height-10)
            love.graphics.setColor(1,1,1)
            y=y-10
        end
        if deck~=0 then
            love.graphics.draw(king.image, king.quad, x+15, y+80, -math.pi/2, 1.25, 2)
        end
    end
    if self.getHand then
        local hand = self.getHand()
        local width, height = 140, 140
        local marginX = 5

        if hand[1] then
            local x, y = love.graphics.getWidth()/2-(#hand/2*width), love.graphics.getHeight()-height

            if handPressIndex and not handHoverIndex and self.board then
                local mx, my = love.mouse.getPosition()
                local hoverBoard = self.board:screenPosIsOverBoard(mx, my)
                love.graphics.setLineWidth(self.board.scale*2.5)
                local tx, ty = self.board:getGridCoordAtPos(mx, my)
                if hoverBoard and self.board:canSummonAt(self.player, hand[handPressIndex], tx, ty) then
                    love.graphics.setColor(0, 0, 1, 1)
                    love.graphics.line(x+(handPressIndex-0.5)*width, y+height/2, self.board:getTileAbsPos(tx, ty))
                else
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.line(x+(handPressIndex-0.5)*width, y+height/2, mx, my)
                end
            end

            for i, v in ipairs(hand) do
                local item = require'pieces'.getTypeData(v)
                local y = handHoverIndex==i and y-20 or y

                x = x+marginX
                local width = width-marginX-marginX

                love.graphics.setColor(1,1,1)
                love.graphics.rectangle("fill", x, y, width, height)
                love.graphics.setColor(0,0,0)
                love.graphics.printf((item.name_short or item.name):lower(), text, x+10, y+10, width/2-10, 'center', 0, 2, 2)
                love.graphics.setLineWidth(handPressIndex==i and 4 or 2)
                love.graphics.rectangle("line", x, y, width, height)
                if handHoverIndex~=i then
                    love.graphics.setLineWidth(2)
                    love.graphics.rectangle("line", x+5, y+5, width-10, height-10)
                end
                love.graphics.setColor(1,1,1)
                love.graphics.draw(item.image, item.quad, x+10, y+30, 0, 2, 2)
                love.graphics.draw(item.image, gemz.teeny, x+width, y+10, 0, 2, 2, 25, 25)
                for x=x+width-22, x+width-18 do
                    for y=y-2, y+2 do
                        love.graphics.printf(item.cost, text, x, y, 20, 'center', 0, 2, 2)
                    end
                end
                love.graphics.setColor(0,0,0)
                love.graphics.printf(item.cost, text, x+width-20, y+0, 20, 'center', 0, 2, 2)

                x = x+width+marginX
            end
        end
    end
end

local function mouseOverButton(v, x, y)
    local bx, by = v.xy()
    local width, height = v.widthheight()
    return bx<x and by<y and x<bx+width and y<by+height
end

local function mouseOverCard(self, x, y)
    if self.getHand then
        local hand = self.getHand()
        local width, height = 140, 140
        local hx, hy = love.graphics.getWidth()/2-(#hand/2*width), love.graphics.getHeight()-height
        local hwidth = width*#hand
        if hx<x and hy<y and x<hx+hwidth and y<hy+height then
            return math.ceil((x-hx)/width)
        end
    end
end

function preview:mousemoved(x, y, xDelta, yDelta, istouch, intercepted)
    for i, v in ipairs(self.buttons) do v.hover = nil end
    handHoverIndex = mouseOverCard(self, x, y)
    if handHoverIndex then
        handCardPreview = require'pieces'.getTypeData(self.getHand()[handHoverIndex])
        return true
    else
        handCardPreview = nil
        if handPressIndex and self.board:screenPosIsOverBoard(x,y) then
            self.board:setHighlightDamageSpawnFor(self.getHand()[handPressIndex], self.board:getGridCoordAtPos(x,y))
            return true
        end
    end
    for i, v in ipairs(self.buttons) do
        v.hover = mouseOverButton(v, x, y)
        if v.hover then
            return true
        end
    end
end

function preview:mousepressed(x, y, button, istouch, presses, intercepted)
    for i, v in ipairs(self.buttons) do v.hover = nil end
    handPressIndex = mouseOverCard(self, x, y)
    if handHoverIndex and not self.board:canSummon(self.player, self.getHand()[handHoverIndex]) then
        handPressIndex = nil
        return true
    end
    if handPressIndex then
        self.board:setHighlightSpawnFor(self.player)
        return true
    end
    for i, v in ipairs(self.buttons) do
        v.hover = mouseOverButton(v, x, y)
        if v.hover and v.press then
            v:press()
            v.pressed = true
            return true
        end
    end
end

function preview:mousereleased(x, y, button, istouch, presses, intercepted)
    self.board:setHighlightSpawnFor(nil)
    for i, v in ipairs(self.buttons) do v.pressed = nil end
    if handPressIndex and not handHoverIndex then
        local hand = self.getHand()
        if self.board:canSummon(self.player, hand[handPressIndex]) then
            local hoverBoard = self.board:screenPosIsOverBoard(x, y)
            local tx, ty = self.board:getGridCoordAtPos(x, y)
            if hoverBoard
            and self.board:canSummonAt(self.player, hand[handPressIndex], tx, ty)
            and self.board:summonAt(self.player, hand[handPressIndex], tx, ty) then
                table.remove(hand, handPressIndex)
            end
        end
        handPressIndex = nil
        return true
    end
end

return preview

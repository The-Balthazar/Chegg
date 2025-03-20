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
        })
    end

    return new
end

local text = love.graphics.newImageFont('text.png', ' abcdefghijklmnopqrstuvwxyz1234567890+-/().,:;')
text:setFilter('nearest', 'nearest')

local gemz = {
    genQuad(4, 7),
    genQuad(5, 7),
    genQuad(6, 7),
    genQuad(7, 7),
    genQuad(8, 7),
}

function preview:draw()
    if self.getPreviewItem then
        local item = self.getPreviewItem()
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
    if self.getResourceCount then
        local count = self.getResourceCount()
        local y = love.graphics.getHeight()

        love.graphics.setColor(1,1,1)
        for i=1, 6 do

            love.graphics.draw(spriteAtlas, gemz[5], i%2~=0 and spriteSize or 0, y-(i*spriteSize*1.5)-spriteSize*0.5, 0, 2, 2)
        end
    end
    for i, v in ipairs(self.buttons) do
        local x, y = v.xy()
        local width, height = v.widthheight()
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("line", x, y, width, height)
        if not v.hover then
            love.graphics.rectangle("line", x+5, y+5, width-10, height-10)
        end
        if not v.pressed then
            love.graphics.printf(v.text, text, x+10, y+20, width/2-10, 'center', 0, 2, 2)
        end
    end
    if self.getTurnNumber then
        local count = tonumber(self.getTurnNumber())
        if count then
            local x, y = spriteSize*3, love.graphics.getHeight()-(spriteSize*2)
            love.graphics.setColor(0,0,0)
            love.graphics.printf(('Turn: %d'):lower():format(math.max(0,count)), text, x-5, y-5, 200, 'left', 0, 2, 2)
        end
    end
end

local function mouseOverButton(v, x, y)
    local bx, by = v.xy()
    local width, height = v.widthheight()
    return bx<x and by<y and x<bx+width and y<by+height
end

function preview:mousemoved(x, y, xDelta, yDelta, istouch)
    for i, v in ipairs(self.buttons) do v.hover = nil end
    for i, v in ipairs(self.buttons) do v.hover = mouseOverButton(v, x, y) break end
end

function preview:mousepressed(x, y, button, istouch, presses)
    for i, v in ipairs(self.buttons) do v.hover = nil end
    for i, v in ipairs(self.buttons) do
        v.hover = mouseOverButton(v, x, y)
        if v.hover and v.press then
            v:press()
            v.pressed = true
            return true
        end
    end
end

function preview:mousereleased(x, y, button, istouch, presses)
    for i, v in ipairs(self.buttons) do v.pressed = nil end
end

return preview

local preview = {}
preview.__index = preview

function preview.new(data)
    local new = setmetatable(data, preview)

    return new
end

local text = love.graphics.newImageFont('text.png', ' abcdefghijklmnopqrstuvwxyz1234567890+-/().,:;')
text:setFilter('nearest', 'nearest')

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
end

return preview

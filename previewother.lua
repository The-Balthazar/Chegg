local preview = {}
preview.__index = preview

function preview.new(data)
    local new = setmetatable(data, preview)

    return new
end

local function drawCardBack(x, y, width, height)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0,0.5,0.5)
    love.graphics.rectangle("fill", x+5, y+5, width-10, height-10)
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.rectangle("line", x+5, y+5, width-10, height-10)
    love.graphics.setColor(1,1,1)
end

local handHoverIndex, handPressIndex

function preview:draw()
    -- if self.getManaCount then
    --     local count, max = self.getManaCount()
    --     local y = love.graphics.getHeight()
    --
    --     love.graphics.setColor(1,1,1)
    --     for i=1, math.max(count, max, 6) do
    --         love.graphics.draw(
    --             spriteAtlas,
    --             i<=count and gemz.blue or i<=max and gemz.grey or gemz.nul,
    --             i%2~=0 and spriteSize or 0,
    --             y-(i*spriteSize*1.5)-spriteSize*0.5,
    --             0, 2, 2
    --         )
    --     end
    -- end
    if self.getDeckSize then
        local deck = self.getDeckSize()
        local width, height = 140, 80
        local x, y = 0, 80
        local king = require'pieces'.getTypeData'king'
        for i=1, deck do
            drawCardBack(x, y, width, height)
            y=y-10
        end
        if deck~=0 then
            love.graphics.draw(king.image, king.quad, x+125, y+20, math.pi/2, 1.25, 2)
        end
    end
    if self.getHand then
        local hand = self.getHand()
        local width, height = 140, 140
        local squeeze
        local marginX = 5

        if hand[1] then
            local handwidth = #hand*width
            if handwidth>love.graphics.getWidth()-700 then
                handwidth = love.graphics.getWidth()-700
                squeeze = handwidth/#hand
            end

            local x, y = love.graphics.getWidth()/2-handwidth/2, -90

            if handPressIndex and not handHoverIndex and self.board and self.board.otherHoverTile[1] and self.board.otherHoverTile[2] then
                local tx, ty = unpack(self.board.otherHoverTile)
                local mx, my = self.board:getTileAbsPos(tx, ty)
                local x = x+(handPressIndex-1)*(squeeze or width)+(squeeze and width-marginX-marginX or width)/2
                -- if hoverBoard and self.board:canSummonAt(self.player, hand[handPressIndex], tx, ty) then
                --     love.graphics.setColor(0, 0, 1, 1)
                -- else
                    love.graphics.setColor(1, 1, 1, 1)
                -- end
                love.graphics.setLineWidth(self.board.scale*2.5)
                love.graphics.line(x, y-(squeeze and 40 or 20), mx, my)
            end

            local king = require'pieces'.getTypeData'king'

            for i, v in ipairs(hand) do
                local item = require'pieces'.getTypeData(v)
                local y = (handHoverIndex==i or handPressIndex==i) and y-(squeeze and 40 or 20) or y

                if not squeeze then
                    x = x+marginX
                end
                local width = width-marginX-marginX

                drawCardBack(x, y, width, height)
                love.graphics.draw(king.image, king.quad, x+10, y+30, 0, 2, 2)

                if not squeeze then
                    x = x+width+marginX
                else
                    x = x+squeeze
                end
            end
        end
    end
end

local function correctHandOffset(self, i)
    if self.getHand and i then
        return #self.getHand()+1-i
    end
    return i
end

function preview:setHandHoverIndex(i) handHoverIndex=correctHandOffset(self, i) end
function preview:setHandPressIndex(i) handPressIndex=correctHandOffset(self, i) end

return preview

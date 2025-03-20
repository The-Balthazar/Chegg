local board = {}
board.__index = board

function board.new(data)
    data.grid = {}
    data.pos = {love.graphics.getWidth()/2,love.graphics.getHeight()/2}
    data.offset = {0,0}
    data.scale = 1
    data.scaleT = 1
    data.hoverTile = {}
    local new = setmetatable(data, board)

    data.rows = data.rows or 10
    data.cols = data.cols or 8
    data.homeRows = data.homeRows or 2

    data.turn = data.turn or -1

    for x=1, data.cols do
        new.grid[x] = {}
        for y=1, data.rows do
            new.grid[x][y] = {}
        end
    end

    return new
end

local particles = {
    explosion    = require'particles.explosion',
    pfish        = require'particles.puffy',
    scratch      = require'particles.scratch',
    scratchred   = require'particles.scratchred',
    scratchblack = require'particles.scratchblack',
    fireball     = require'particles.fireball',
    swipe        = require'particles.swipe',
    hit          = require'particles.hit',
}

function board:update(delta)
    self.pos[1], self.pos[2] = love.graphics.getWidth()/2,love.graphics.getHeight()/2
    self.scale = math.easeDecay(self.scale, self.scaleT, 24, delta)
    for y=1, self.rows do
        for x=1, self.cols do
            local grid = self.grid[x][y]
            for i, piece in ipairs(grid) do
                piece:update(delta)
            end
        end
    end
    for k, v in pairs(particles) do
        v:update(delta)
    end
end

local white, black = {0.8,0.8,0.8}, {0.2,0.2,0.2}
local gridSize = 50
local highlightBorder = 2

local selectedPiece, dragWithPiece

function board:getSelectedPiece() return selectedPiece end

function board:createEffectAt(effect, x, y)
    if not particles[effect] then return end
    particles[effect]:setPosition(gridSize/2*(x-0.5), gridSize/2*(y-0.5))
    particles[effect]:emit(1)
end

function board:draw()
    xPos = self.pos[1]-self.cols/2*gridSize*self.scale+self.offset[1]*self.scale
    yPos = self.pos[2]-self.rows/2*gridSize*self.scale+self.offset[2]*self.scale

    if self.mouseOver then
        love.graphics.rectangle("fill", xPos-highlightBorder*self.scale, yPos-highlightBorder*self.scale, gridSize*self.cols*self.scale+highlightBorder*self.scale*2, gridSize*self.rows*self.scale+highlightBorder*self.scale*2)
    end

    for y=0, self.rows-1 do
        for x=0, self.cols-1 do
            love.graphics.setColor(x%2==y%2 and black or white)
            love.graphics.rectangle("fill", gridSize*self.scale*x+xPos, gridSize*self.scale*y+yPos, gridSize*self.scale, gridSize*self.scale)
        end
    end

    if self.hoverTile[1] and self.hoverTile[2] then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.25)
        love.graphics.circle("fill", gridSize*self.scale*(self.hoverTile[1]-0.5)+xPos, gridSize*self.scale*(self.hoverTile[2]-0.5)+yPos, gridSize*self.scale/2)
    end

    love.graphics.setColor(1, 0, 0, 0.25)
    love.graphics.rectangle("fill",
        xPos,
        yPos,
        gridSize*self.cols*self.scale,
        gridSize*self.homeRows*self.scale
    )
    love.graphics.setColor(0, 0, 1, 0.25)
    love.graphics.rectangle("fill",
        xPos,
        yPos+gridSize*(self.rows-self.homeRows)*self.scale,
        gridSize*self.cols*self.scale,
        gridSize*self.homeRows*self.scale
    )

    if selectedPiece then
        local p = selectedPiece.pos
        local r = selectedPiece.moveRange
        if p and r then
            for y=math.max(1, p[2]-r), math.min(p[2]+r, self.rows) do
                for x=math.max(1, p[1]-r), math.min(p[1]+r, self.cols) do
                    local isHover = self.hoverTile[1]==x and self.hoverTile[2]==y
                    if selectedPiece:canTravelTo(x,y) then
                        if self:getLivingPieceAt(x, y) then
                            local c = selectedPiece.attackMoveHighlightColour
                            love.graphics.setColor(c and c[1] or 1, c and c[2] or 0, c and c[3] or 0, isHover and 1 or 0.75)
                        else
                            love.graphics.setColor(0, 0, 1, isHover and 1 or 0.75)
                        end
                        love.graphics.rectangle("fill", gridSize*self.scale*(x-0.9)+xPos, gridSize*self.scale*(y-0.9)+yPos, gridSize*self.scale*0.8, gridSize*self.scale*0.8)
                    end
                end
            end
        end
        local r = selectedPiece.attackRange
        if p and r then
            for y=math.max(1, p[2]-r), math.min(p[2]+r, self.rows) do
                for x=math.max(1, p[1]-r), math.min(p[1]+r, self.cols) do
                    local isHover = dragWithPiece and self.hoverTile[1]==x and self.hoverTile[2]==y
                    if selectedPiece:canAttackTo(x,y) then
                        love.graphics.setColor(1, 0, 0, isHover and 1 or 0.5)
                        love.graphics.setLineWidth(self.scale*5)
                        if isHover and selectedPiece.getAttackSplash then
                            local coords = {selectedPiece:getAttackSplash(x, y)}
                            for i=1, #coords, 2 do
                                local x, y = coords[i], coords[i+1]
                                if self:isWithinBounds(x, y) then
                                    love.graphics.rectangle("line", gridSize*self.scale*(x-0.95)+xPos, gridSize*self.scale*(y-0.95)+yPos, gridSize*self.scale*0.9, gridSize*self.scale*0.9)
                                end
                            end
                        else
                            love.graphics.rectangle("line", gridSize*self.scale*(x-0.95)+xPos, gridSize*self.scale*(y-0.95)+yPos, gridSize*self.scale*0.9, gridSize*self.scale*0.9)
                        end
                    end
                end
            end
        end
    end
    if dragWithPiece then
        love.graphics.setLineWidth(self.scale*4)
        local x, y = unpack(self.hoverTile)
        local inbounds = self:isWithinBounds(x, y)
        local canMoveTo = inbounds and dragWithPiece:canTravelTo(x, y)
        local canAttack = inbounds and dragWithPiece:canAttackTo(x, y)
        local canTarget = inbounds and (canMoveTo or canAttack)
        if inbounds and self:getLivingPieceAt(x, y) then
            local c = canMoveTo and dragWithPiece.attackMoveHighlightColour
            love.graphics.setColor(c and c[1] or 1, c and c[2] or 0, c and c[3] or 0, canTarget and 1 or inbounds and 0.25 or 0.05)
        else
            love.graphics.setColor(0, 0, 1, canTarget and 1 or inbounds and 0.25 or 0.05)
        end
        love.graphics.line(
            gridSize*self.scale*(dragWithPiece.pos[1]-0.5)+xPos,
            gridSize*self.scale*(dragWithPiece.pos[2]-0.5)+yPos,
            canTarget and gridSize*self.scale*(x-0.5)+xPos or love.mouse.getX(),
            canTarget and gridSize*self.scale*(y-0.5)+yPos or love.mouse.getY()
        )
    end

    love.graphics.setColor(1, 1, 1, 1)
    for y=1, self.rows do
        for x=1, self.cols do
            local grid = self.grid[x][y]
            if grid[1] then
                for i=#grid, 1, -1 do
                    local piece = grid[i]
                    if piece.draw then
                        piece:draw(xPos, yPos,
                            gridSize*self.scale*(x-0.5)+xPos,
                            gridSize*self.scale*(y-0.5)+yPos
                        )
                    end
                end
            end
        end
    end

    for k, v in pairs(particles) do
        love.graphics.draw(v, xPos, yPos, 0, self.scale*2, self.scale*2)
    end
end

local mousePressedX, mousePressedY

function board:canEndTurn() return true end -- TODO

function board:endTurn()
    if not self:canEndTurn() then return end
    self.turn = self.turn+1
    print(self.turn)
end

function board:isWithinBounds(x, y)
    return x and y and x>0 and y>0 and x<self.cols+1 and y<self.rows+1
end

function board:getRelativeMouse(x, y)
    return  x-self.pos[1]+self.cols/2*gridSize*self.scale-self.offset[1]*self.scale,
            y-self.pos[2]+self.rows/2*gridSize*self.scale-self.offset[2]*self.scale
end

function board:screenPosIsOverBoard(x,y)
    local relativeX, relativeY = self:getRelativeMouse(x, y)
    return self:relativePosIsOverBoard(relativeX, relativeY)
end

function board:relativePosIsOverBoard(relativeX, relativeY)
    return relativeX>0 and relativeY>0
        and relativeX<self.cols*gridSize*self.scale
        and relativeY<self.rows*gridSize*self.scale
end

function board:getGridCoordAtRelativePos(relativeX, relativeY)
    return math.ceil(relativeX/(gridSize*self.scale)), math.ceil(relativeY/(gridSize*self.scale))
end

function board:getGridCoordAtPos(posX, posY)
    return self:getGridCoordAtRelativePos(self:getRelativeMouse(posX, posY))
end

function board:mousemoved(x, y, xDelta, yDelta, istouch)
    if mousePressedX and mousePressedY then
        self.offset[1], self.offset[2] = x/self.scale-mousePressedX, y/self.scale-mousePressedY
    else
        local relativeX, relativeY = self:getRelativeMouse(x, y)
        self.mouseOver = self:relativePosIsOverBoard(relativeX, relativeY)
        if self.mouseOver then
            self.hoverTile[1], self.hoverTile[2] = self:getGridCoordAtRelativePos(relativeX, relativeY)
        else
            self.hoverTile[1], self.hoverTile[2] = nil, nil
        end
    end
end

function board:getPiecesAt(x, y)
    return self:isWithinBounds(x, y) and self.grid[x][y]
end

function board:getLivingPieceAt(x, y)
    if not (x and y) then return end
    for i, p in ipairs(self.grid[x][y]) do
        if p:isAlive() then
            return p
        end
    end
end

function board:mousepressed(x, y, button, istouch, presses)
    self.mouseOver = self:screenPosIsOverBoard(x,y)
    if self.mouseOver then
        local pieces = self:getLivingPieceAt(self.hoverTile[1], self.hoverTile[2])
        if pieces then
            selectedPiece, dragWithPiece = pieces, pieces
        else
            mousePressedX, mousePressedY = x/self.scale-self.offset[1], y/self.scale-self.offset[2]
            selectedPiece, dragWithPiece = nil, nil
        end
    end
end

function board:mousereleased(x, y, button, istouch, presses)
    mousePressedX, mousePressedY = nil, nil
    if self.mouseOver then
        self.mouseOver = self:screenPosIsOverBoard(x,y)
    end
    if dragWithPiece and self.mouseOver then
        local tX, tY = self:getGridCoordAtPos(x, y)
        if not self:movePiece(dragWithPiece, tX, tY) then
            self:attackWithPiece(dragWithPiece, tX, tY)
        end
    end
    dragWithPiece = nil
end

function board:wheelmoved(x, y)
    if self.mouseOver and y and y~=0 then
        self.scaleT = self.scaleT*(1.25^y)
    end
end

function board:deleteFrom(piece)
    local px, py = unpack(piece.pos)
    if table.removeByValue(self.grid[px][py], piece) then return true end
    for y=1, self.rows do
        for x=1, self.cols do
            if table.removeByValue(self.grid[x][y], piece) then return true end
        end
    end
end

function board:summonAt(pType, x, y)
    local piece = require'pieces'.new{
        type = pType,
        board = self,
        pos = {x, y},
        summonTurn = self.turn,
    }
    table.insert(self.grid[x][y], piece)
end

function board:moveTo(piece, x, y)
    local px, py = unpack(piece.pos)
    table.insert(self.grid[x][y], 1, table.removeByValue(self.grid[px][py], piece))
    piece.pos[1], piece.pos[2] = x, y

    return true
end

function board:attack(piece, x, y)
    if self:isWithinBounds(x, y) then
        if piece.attackEffect then
            piece:attackEffect(x, y)
        end
        for i, p in ipairs(self.grid[x][y]) do
            if p:isAlive() then
                if piece.attack then
                    piece:attack(p)
                else
                    p:kill(piece)
                end
            end
        end
    end
end

function board:movePiece(piece, x, y)
    if not piece then return end
    if not piece:canTravelTo(x, y) then return end
    if piece.onMoveTo then
        piece:onMoveTo(x, y)
    end
    if piece.move then
        return piece:move(x, y)
    else
        if self:getLivingPieceAt(x, y) then
            self:attack(piece, x, y)
        end
        return self:moveTo(piece, x, y)
    end
end

function board:attackWithPiece(piece, x, y)
    if not piece then return end
    if not piece:canAttackTo(x, y) then return end
    if self:getLivingPieceAt(x, y) then
        if piece.getAttackSplash then
            local coords = {piece:getAttackSplash(x, y)}
            for i=1, #coords, 2 do
                local x, y = coords[i], coords[i+1]
                self:attack(piece, x, y)
            end
        else
            self:attack(piece, x, y)
        end
        return true
    end
end

return board

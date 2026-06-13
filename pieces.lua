local function basic1move(self, targetX, targetY)
    return
        math.abs(self.pos[1]-targetX)<=1 and
        math.abs(self.pos[2]-targetY)<=1 and
        not self.board:getLivingPieceAt(targetX, targetY)
end

local function basic1attack(self, targetX, targetY)
    return
        math.abs(self.pos[1]-targetX)<=1 and
        math.abs(self.pos[2]-targetY)<=1 and
        self.board:getLivingPieceAt(targetX, targetY)
end

local function basic1cardinalMove(self, targetX, targetY)
    return
        math.abs(self.pos[1]-targetX)+math.abs(self.pos[2]-targetY)<=1 and
        not self.board:getLivingPieceAt(targetX, targetY)
end

local function basic1cardinalAttack(self, targetX, targetY)
    return
        math.abs(self.pos[1]-targetX)+math.abs(self.pos[2]-targetY)<=1 and
        self.board:getLivingPieceAt(targetX, targetY)
end

local function nope() return false end

local function nearestCardinalAttack(self, targetX, targetY)
    local lx, ly = self.pos[1], self.pos[2]
    if not (lx==targetX or ly==targetY) then return end
    if not self.board:getLivingPieceAt(targetX, targetY) then return end
    local x, y = (lx-targetX), (ly-targetY)
    local sign = math.sign(lx==targetX and y or x)
    for i=sign, (lx==targetX and y or x)-sign, sign do
        if self.board:getLivingPieceAt(
            lx==targetX and targetX or lx-i,
            ly==targetY and targetY or ly-i
        ) then return end
    end
    return true
end

local function nearestDiagonalAttack(self, targetX, targetY)
    if not (math.abs(self.pos[1]-targetX)==math.abs(self.pos[2]-targetY)) then return end
    if not self.board:getLivingPieceAt(targetX, targetY) then return end
    local lx, ly = self.pos[1], self.pos[2]
    local x, y = (lx-targetX), (ly-targetY)
    local signX, signY = math.sign(x), math.sign(y)
    for i=1, math.abs(x)-1 do
        if self.board:getLivingPieceAt(
            lx-i*signX,
            ly-i*signY
        ) then return end
    end
    return true
end

local function range1estimate(self, targetX, targetY)
    return
        targetX+1,targetY+1, targetX+1,targetY+0, targetX+1,targetY-1,
        targetX+0,targetY+1,                      targetX+0,targetY-1,
        targetX-1,targetY+1, targetX-1,targetY+0, targetX-1,targetY-1
end

local function cardinal1estimate(self, targetX, targetY)
    return
        targetX+1,targetY+0, targetX+0,targetY+1,
        targetX+0,targetY-1, targetX-1,targetY+0
end

local function FX_explosion(self, targetX, targetY)
    local board = self.board
    board:createEffectAt('explosion', targetX, targetY)
end

local piecetypes = {
    king = {
        name = 'King',
        desc = 'The players avatar, death constitutes a game loss for its controller.\n\nIt can move to or attack any space within 1 range.',
        cost = 0,
        moveRange = 1,
        attackRange = 1,
        moveCost = 1,
        dashCost = 1,
        attackCost = 1,
        canTravelTo = basic1move,
        canAttackTo = basic1attack,
        soundMove = 'shwing',
        soundDeath = 'metal_hit_reverb',
        soundAttack = 'shwing',
        soundSummon = 'shwing',
        quad = genQuad(1, 1),
        quadM = genQuad(9, 2),
        quadA = genQuad(10, 2),
        quadU = genQuad(1, 8),
        image = spriteAtlas,
        teleportImmune = true,
        attackEffect = function(self, targetX, targetY)
            local board = self.board
            board:createEffectAt('swipe', targetX, targetY)
        end,
        attackAreaPreview = range1estimate,
        onKill = function(self, instigator)
            self.player:defeat(instigator)
        end,
        onSummon = function(self)
            if self.player==self.board.localplayer then
                self.board:endTurn(self.player)
            end
        end,
    },
    zombie = {
        name = 'Zombie',
        desc = 'Zombies can only move forwards and diagonally forwards, and can only attack directly adjacent spaces.',
        cost = 1,
        deck = true,
        moveRange = 1,
        attackRange = 1,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        quad = genQuad(2, 1),
        quadM = genQuad(1, 3),
        quadA = genQuad(2, 3),
        quadU = genQuad(2, 8),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            return
                math.abs(self.pos[1]-targetX)<=1 and
                targetY==self.pos[2]-(self.player==self.board.localplayer and 1 or -1) and
                not self.board:getLivingPieceAt(targetX, targetY)
        end,
        canAttackTo = basic1cardinalAttack,
        attackEffect = function(self, targetX, targetY)
            local board = self.board
            board:createEffectAt('scratchred', targetX, targetY)
        end,
        attackAreaPreview = cardinal1estimate,
    },
    creeper = {
        name = 'Creeper',
        desc = 'Creepers can move 1 space in any direction, and attack by exploding, killing everything within 1 range.',
        cost = 1,
        deck = true,
        moveRange = 1,
        attackRange = 1,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = 'fireball',
        soundSummon = '',
        canTravelTo = basic1move,
        canAttackTo = basic1attack,
        attackEffect = FX_explosion,
        quad = genQuad(3, 1),
        quadM = genQuad(3, 3),
        quadA = genQuad(4, 3),
        quadU = genQuad(3, 8),
        image = spriteAtlas,
        getAttackSplash = function(self, targetX, targetY)
            return  self.pos[1], self.pos[2],
                    self.pos[1]+1, self.pos[2]+1,
                    self.pos[1]+1, self.pos[2]-1,
                    self.pos[1]-1, self.pos[2]+1,
                    self.pos[1]-1, self.pos[2]-1,
                    self.pos[1]+1, self.pos[2],
                    self.pos[1]-1, self.pos[2],
                    self.pos[1], self.pos[2]+1,
                    self.pos[1], self.pos[2]-1
        end,
        attackAreaPreview = function(self, targetX, targetY)
            return
                targetX+1,targetY+1, targetX+1,targetY+0, targetX+1,targetY-1,
                targetX+0,targetY+1, targetX,  targetY,   targetX+0,targetY-1,
                targetX-1,targetY+1, targetX-1,targetY+0, targetX-1,targetY-1
        end,
    },
    pig = {
        name = 'Pig',
        desc = 'Pigs can move 1 space in any direction, and can\'t attack.\n\nWhen summoned or killed, its controller draws.',
        cost = 1,
        deck = true,
        moveRange = 1,
        attackRange = 0,
        moveCost = 0,
        dashCost = 1,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        canTravelTo = basic1move,
        canAttackTo = nope,
        quad = genQuad(4, 1),
        quadM = genQuad(5, 3),
        quadU = genQuad(4, 8),
        image = spriteAtlas,
        onSummon = function(self)
            self.player:draw()
        end,
        onKill = function(self, instigator)
            self.player:draw()
        end,
    },
    rabbit = {
        name = 'Rabbit',
        desc = 'Rabbits can jump 2 tiles in any cardinal direction, and can\'t attack.\n\nIf they jump over another creature, its controller draws a card.',
        cost = 2,
        deck = true,
        moveRange = 2,
        attackRange = 0,
        moveCost = 0,
        dashCost = 1,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        quad = genQuad(5, 1),
        quadM = genQuad(6, 3),
        quadU = genQuad(5, 8),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            local x, y = math.abs(self.pos[1]-targetX), math.abs(self.pos[2]-targetY)
            return (x+y)==2 and math.abs(x-y)==2 and not self.board:getLivingPieceAt(targetX, targetY)
        end,
        onMoveTo = function(self, targetX, targetY)
            if self.board:getLivingPieceAt((self.pos[1]+targetX)/2, (self.pos[2]+targetY)/2) then
                self.player:draw()
            end
        end,
    },
    pufferfish = {
        name = 'Pufferfish',
        name_short = 'P-fish',
        desc = 'Pufferfish can move 1 in any cardinal direction, and can attack all diagonally adjacent tiles simultaniously.',
        cost = 2,
        deck = true,
        moveRange = 1,
        attackRange = 1,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        canTravelTo = basic1cardinalMove,
        quad = genQuad(6, 1),
        quadM = genQuad(7, 3),
        quadA = genQuad(8, 3),
        quadU = genQuad(6, 8),
        image = spriteAtlas,
        canAttackTo = function(self, targetX, targetY)
            local x, y = math.abs(self.pos[1]-targetX)==1, math.abs(self.pos[2]-targetY)==1
            return x and y and self.board:getLivingPieceAt(targetX, targetY)
        end,
        getAttackSplash = function(self, targetX, targetY)
            return  self.pos[1]+1, self.pos[2]+1,
                    self.pos[1]+1, self.pos[2]-1,
                    self.pos[1]-1, self.pos[2]+1,
                    self.pos[1]-1, self.pos[2]-1
        end,
        attackEffect = function(self, targetX, targetY)
            local board = self.board
            board:createEffectAt('pfish', unpack(self.pos))
        end,
        attackAreaPreview = function(self, targetX, targetY)
            return
                targetX+1,targetY+1, targetX+1,targetY-1,
                targetX-1,targetY+1, targetX-1,targetY-1
        end,
    },
    golem = {
        name = 'Golem',
        desc = 'Golems can move 1 in any direction, and can attack any cardinally adjacent space, dealing splash damage to the two diagonally adjacent spaces next to that.',
        cost = 2,
        deck = true,
        moveRange = 1,
        attackRange = 1,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = 'wood_footstep_medium',
        soundDeath = 'wood_footstep_heavy',
        soundAttack = 'wood_footstep_heavy',
        soundSummon = 'wood_footstep_medium',
        canTravelTo = basic1move,
        canAttackTo = basic1cardinalAttack,
        quad = genQuad(7, 1),
        quadM = genQuad(9, 3),
        quadA = genQuad(10, 3),
        quadU = genQuad(7, 8),
        image = spriteAtlas,
        getAttackSplash = function(self, targetX, targetY)
            local x = self.pos[1]==targetX and 1 or 0
            local y = self.pos[2]==targetY and 1 or 0
            return  targetX, targetY,
                    targetX+x, targetY+y,
                    targetX-x, targetY-y
        end,
        attackEffect = function(self, targetX, targetY)
            local board = self.board
            board:createEffectAt('swipe', targetX, targetY)
        end,
        attackAreaPreview = cardinal1estimate,
    },
    frog = {
        name = 'Frog',
        desc = 'Frogs can jump to any space up to 2 cardinally adjacent spaces away.\n\nTheir attack doesn\'t deal damage, but can pull the nearest creature in a given cardinal direction 2 spaces towards them.',
        cost = 2,
        deck = true,
        moveRange = 2,
        attackRange = 10,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        quad = genQuad(8, 1),
        quadM = genQuad(1, 4),
        quadA = genQuad(2, 4),
        quadU = genQuad(8, 8),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            local x, y = math.abs(self.pos[1]-targetX), math.abs(self.pos[2]-targetY)
            return x+y<=2 and not self.board:getLivingPieceAt(targetX, targetY)
        end,
        canAttackTo = function(self, targetX, targetY)
            local x, y = math.abs(self.pos[1]-targetX), math.abs(self.pos[2]-targetY)
            return x+y>1 and nearestCardinalAttack(self, targetX, targetY)
        end,
        attack = function(self, target)
            local board = self.board
            local tX, tY = unpack(target.pos)
            local sX, sY = unpack(self.pos)
            local rX, rY = tX-sX, tY-sY
            local mX, mY = math.abs(rX)==2 and 1 or 2, math.abs(rY)==2 and 1 or 2
            board:moveNoSend(target, tX-math.clamp(rX, -mX, mX), tY-math.clamp(rY, -mY, mY))
            return true
        end,
        -- attackAreaPreview = function(self, targetX, targetY)
        --     local coords = {}
        --     for x=targetX-2, targetX+2 do
        --     end
        --     for y=targetY-2, targetY+2 do
        --             table.insert(coords, x)
        --             table.insert(coords, y)
        --     end
        --     return unpack(coords)
        -- end,
    },
    skeleton = {
        name = 'Skeleton',
        name_short = 'Skelly',
        desc = 'Skeletons can move 1 in any cardinal direction, and can attack the nearest creature down a given diagonal, up to 3 spaces away.',
        cost = 3,
        deck = true,
        moveRange = 1,
        attackRange = 3,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = 'skeleton_hurt',
        soundDeath = 'skeleton_death',
        soundAttack = 'skeleton_hurt',
        soundSummon = 'skeleton_hurt',
        quad = genQuad(9, 1),
        quadM = genQuad(3, 4),
        quadA = genQuad(4, 4),
        quadU = genQuad(9, 8),
        image = spriteAtlas,
        canTravelTo = basic1cardinalMove,
        canAttackTo = nearestDiagonalAttack,
        attackEffect = function(self, targetX, targetY)
            local board = self.board
            board:createEffectAt('hit', targetX, targetY)
        end,
        attackAreaPreview = function(self, targetX, targetY)
            return
                targetX+3,targetY+3, targetX+3,targetY-3,
                targetX+2,targetY+2, targetX+2,targetY-2,
                targetX+1,targetY+1, targetX+1,targetY-1,
                targetX-1,targetY+1, targetX-1,targetY-1,
                targetX-2,targetY+2, targetX-2,targetY-2,
                targetX-3,targetY+3, targetX-3,targetY-3
        end,
    },
    blaze = {
        name = 'Blaze',
        desc = 'Blazes can move 1 in any diagonal, and can attack the nearest creature down a given cardinal direction, up to 2 spaces away.',
        cost = 3,
        deck = true,
        moveRange = 1,
        attackRange = 2,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = 'fire_ignite',
        soundDeath = 'fire_ignite',
        soundAttack = 'fireball',
        soundSummon = 'fireball',
        quad = genQuad(10, 1),
        quadM = genQuad(5, 4),
        quadA = genQuad(6, 4),
        quadU = genQuad(10, 8),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            local x, y = math.abs(self.pos[1]-targetX)==1, math.abs(self.pos[2]-targetY)==1
            return x and y and not self.board:getLivingPieceAt(targetX, targetY)
        end,
        canAttackTo = nearestCardinalAttack,
        attackEffect = function(self, targetX, targetY)
            local board = self.board
            board:createEffectAt('fireball', targetX, targetY)
        end,
        attackAreaPreview = function(self, targetX, targetY)
            return
                targetX+2,targetY+0, targetX+0,targetY+2,
                targetX+1,targetY+0, targetX+0,targetY+1,
                targetX+0,targetY-1, targetX-1,targetY+0,
                targetX+0,targetY-2, targetX-2,targetY+0
        end,
    },
    phantom = {
        name = 'Phantom',
        desc = 'Phantoms can move to any black space within 2 spaces cardinally or diagonally, and can attack-move to the same.',
        cost = 3,
        deck = true,
        moveRange = 2,
        attackRange = 2,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        attackMove = true,
        quad = genQuad(1, 2),
        quadM = genQuad(7, 4),
        quadA = genQuad(8, 4),
        quadU = genQuad(1, 9),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            local x, y = targetX%2, targetY%2
            return x==y
        end,
        attackAreaPreview = function(self, targetX, targetY)
            local coords = {}
            for x=targetX-2, targetX+2 do
                for y=targetY-2, targetY+2 do
                    if (y%2)==(x%2) then
                        table.insert(coords, x)
                        table.insert(coords, y)
                    end
                end
            end
            return unpack(coords)
        end,
    },
    farlander = {
        name = 'Enderman',
        name_short = 'E-man',
        desc = 'Endermen get no free move, but can swap places within any creature besides a king that shares a row or column with it, and isn\'t within attack range. It can attack any of the 8 adjacent spaces.',
        cost = 4,
        deck = true,
        moveRange = 10,
        attackRange = 1,
        dashCost = 1,
        attackCost = 1,
        soundMove = 'woosh',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        quad = genQuad(2, 2),
        quadM = genQuad(9, 4),
        quadA = genQuad(10, 4),
        quadU = genQuad(2, 9),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            local x, y = math.abs(self.pos[1]-targetX), math.abs(self.pos[2]-targetY)
            local target = self.board:getLivingPieceAt(targetX, targetY)
            return x+y>1 and target and not target.typeData.teleportImmune and (self.pos[1]==targetX or self.pos[2]==targetY)
        end,
        canAttackTo = basic1attack,
        attackEffect = function(self, targetX, targetY)
            local board = self.board
            board:createEffectAt('scratchblack', targetX, targetY)
        end,
        attackMoveHighlightColour = {0, 0, 1},
        move = function(self, targetX, targetY)
            local sX, sY = unpack(self.pos)
            local board = self.board

            for i, piece in ipairs(board:getPiecesAt(targetX, targetY)) do
                board:moveNoSend(piece, sX, sY)
            end
            board:moveNoSend(self, targetX, targetY)

            return true
        end,
        attackAreaPreview = range1estimate,
    },
    slime = {
        name = 'Slime',
        desc = 'Slimes can jump to any of the 8 spaces 2 spaces away cardinally or diagonally, and can attack-move to the same.',
        cost = 4,
        deck = true,
        moveRange = 2,
        attackRange = 2,
        moveCost = 0,
        dashCost = 1,
        attackCost = 1,
        attackMove = true,
        soundMove = 'slime_squelch',
        soundDeath = 'slime_death',
        soundAttack = 'slime_squelch',
        soundSummon = 'slime_light_squelch',
        quad = genQuad(3, 2),
        quadM = genQuad(1, 5),
        quadA = genQuad(2, 5),
        quadU = genQuad(3, 9),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            local x, y = math.abs(self.pos[1]-targetX), math.abs(self.pos[2]-targetY)
            return (x+y==4 or x+y==2 and x~=y)
        end,
        attackAreaPreview = function(self, targetX, targetY)
            return
                targetX+2,targetY+2, targetX+2,targetY+0, targetX+2,targetY-2,
                targetX+0,targetY+2,                      targetX+0,targetY-2,
                targetX-2,targetY+2, targetX-2,targetY+0, targetX-2,targetY-2
        end,
    },
    box = {
        name = 'Shulker',
        desc = 'Shulkers can only attack-move, and can only do so targetting the nearest creature down a given knights-move going long-ways first.',
        cost = 4,
        deck = true,
        moveRange = 2,
        moveCost = 0,
        attackCost = 1,
        attackMove = true,
        attackMoveOnly = true,
        soundMove = 'woosh',
        soundDeath = 'book_grab',
        soundAttack = 'woosh',
        soundSummon = '',
        quad = genQuad(4, 2),
        quadM = genQuad(3, 5),
        quadU = genQuad(4, 9),
        image = spriteAtlas,
        canTravelTo = function(self, targetX, targetY)
            if not self.board:getLivingPieceAt(targetX, targetY) then return end

            local lx, ly = self.pos[1], self.pos[2]
            local x, y = (lx-targetX), (ly-targetY)
            local ax, ay = math.abs(x), math.abs(y)

            if ax+ay==1 then
                return true

            elseif ax+ay==2 and math.abs(ax-ay)==2 and not self.board:getLivingPieceAt(lx-x/2, ly-y/2) then
                return true

            elseif ax+ay==3 and math.abs(ax-ay)==1 and not (
                self.board:getLivingPieceAt(ax==1 and lx or targetX, ay==1 and ly or targetY) or
                self.board:getLivingPieceAt(ax==1 and lx or  lx-x/2, ay==1 and ly or  ly-y/2)
            ) then
                return true

            end
        end,
    },
    -- parrot = {
    --     name = 'Parrot',
    --     desc = 'Parrots can jump to any space up to 2 cardinally adjacent spaces away or 2 spaces away diagonally. They can copy the attack of a laterally adjacent non-parrot creature, prioritising the closest to the edge of the board.',
    --     cost = 5,
    --     deck = true,
    --     moveRange = 2,
    --     attackRange = 0,
    --     moveCost = 0,
    --     dashCost = 1,
    --     attackCost = 1,
        -- soundMove = '',
        -- soundDeath = 'bug_hit',
        -- soundAttack = '',
        -- soundSummon = '',
    --     quad = genQuad(5, 2),
    --     quadM = genQuad(4, 5),
    --     quadA = genQuad(5, 5),
    --     quadU = genQuad(5, 9),
    --     image = spriteAtlas,
    --     canTravelTo = function(self, targetX, targetY)
    --         local xy = math.abs(self.pos[1]-targetX)+math.abs(self.pos[2]-targetY)
    --         return (xy==4 or xy==2 or xy==1) and not self.board:getLivingPieceAt(targetX, targetY)
    --     end,
    --     --canAttackTo -- TODO
    -- },
    cat = {
        name = 'Cat',
        desc = 'Cats don\'t move or attack; instead each grant its controller 1 extra mana each turn.',
        cost = 5,
        deck = true,
        moveRange = 0,
        attackRange = 0,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = '',
        soundSummon = '',
        quad = genQuad(6, 2),
        quadU = genQuad(6, 9),
        image = spriteAtlas,
        canTravelTo = nope,
        canAttackTo = nope,
        onStartTurn = function(self)
            self.player:takeMana(-1)
        end,
    },
    -- sniffer = {
    --     name = 'Sniffer',
    --     desc = 'Sniffers can move 1 in any direction, and can\'t attack.\n\nWhen summoned you draw 2 from your opponents deck. When killed you discard 2 at random.',
    --     cost = 5,
    --     deck = true,
    --     moveRange = 1,
    --     attackRange = 0,
    --     moveCost = 0,
    --     dashCost = 1,
    --     canTravelTo = basic1move,
    --     canAttackTo = nope,
        -- soundMove = '',
        -- soundDeath = 'bug_hit',
        -- soundAttack = '',
        -- soundSummon = '',
    --     quad = genQuad(7, 2),
    --     quadM = genQuad(6, 5),
    --     quadU = genQuad(7, 9),
    --     image = spriteAtlas,
    --     onSummon = function(self)
    --         local enemy = self.board:getOpponent(self.player)
    --         if enemy then
    --             -- TODO Sync hand
    --             self.player:addToHand(enemy:mill())
    --             self.player:addToHand(enemy:mill())
    --         end
    --     end,
    --     onKill = function(self, instigator)
    --         self.player:discardRandom()
    --         self.player:discardRandom()
    --     end,
    -- },
    wither = {
        name = 'Wither',
        desc = 'On summon the Wither explodes, killing anything within 1 range.\n\nIt can move 1 in any direction, and can attack the nearest creature down a given cardinal direction, up to 3 spaces away. This inflicts splash damage to the 4 adjacent tiles.',
        cost = 6,
        deck = true,
        moveRange = 1,
        attackRange = 3,
        moveCost = 0,
        dashCost = 1,
        attackCost = 2,
        soundMove = '',
        soundDeath = 'bug_hit',
        soundAttack = 'fireball',
        soundSummon = 'fireball',
        canTravelTo = basic1move,
        canAttackTo = nearestCardinalAttack,
        quad = genQuad(8, 2),
        quadM = genQuad(7, 5),
        quadA = genQuad(8, 5),
        quadU = genQuad(8, 9),
        image = spriteAtlas,
        getSpawnSplash = range1estimate,
        getAttackSplash = function(self, targetX, targetY)
            return  targetX, targetY,
                    targetX+1, targetY,
                    targetX-1, targetY,
                    targetX, targetY+1,
                    targetX, targetY-1
        end,
        attackEffect = FX_explosion,
        onSummon = function(self)
            local board = self.board
            for x=-1, 1 do
                for y=-1, 1 do
                    if not (x==0 and y==0) then
                        local tx, ty = self.pos[1]+x, self.pos[2]+y
                        board:createEffectAt('explosion', tx, ty)
                        local grid = board:getPiecesAt(tx, ty)
                        if grid then
                            for i, piece in ipairs(grid) do
                                -- board:sendData(self.player, ('KILL: %d %d'):format(tx, ty))
                                piece:kill(self)
                            end
                        end
                    end
                end
            end
        end,
        attackAreaPreview = function(self, targetX, targetY)
            return
                targetX+3,targetY+0, targetX+0,targetY+3,
                targetX+2,targetY+0, targetX+0,targetY+2,
                targetX+1,targetY+0, targetX+0,targetY+1,
                targetX+0,targetY-1, targetX-1,targetY+0,
                targetX+0,targetY-2, targetX-2,targetY+0,
                targetX+0,targetY-3, targetX-3,targetY+0
        end,
    },
}

local piece = {}
piece.__index = piece

function piece.sanitiseDecklist(deck)
    if type(deck)~='table' then deck = {} end
    for i, card in ipairs(deck) do
        if i>15 then
            deck[i] = nil
        elseif not (piecetypes[card] and piecetypes[card].deck) then
            deck[i] = 'pig'
        end
    end
    if #deck<15 then
        for i=#deck+1, 15 do
            deck[i] = 'pig'
        end
    end
    return deck
end

function piece.getTypeData(t) return piecetypes[t] end

function piece.getTypesData() return piecetypes end

function piece:new()
    local new = setmetatable(self, piece)

    local pType = self.type or 'error'
    local typeData = piecetypes[pType]

    self.getAttackSplash = typeData.getAttackSplash
    self.moveRange = typeData.moveRange
    self.attackMoveHighlightColour = typeData.attackMoveHighlightColour
    self.attackHighlightColour = typeData.attackHighlightColour
    self.attackAreaPreview = typeData.attackAreaPreview
    self.attackRange = typeData.attackRange
    self.attackEffect = typeData.attackEffect
    self.move = typeData.move
    self.attack = typeData.attack
    self.typeData = typeData
    self.onStartTurn = typeData.onStartTurn

    self.player:insertSummon(self)

    if typeData.onSummon then
        typeData.onSummon(self)
    end

    local hasSS = typeData.soundSummon and typeData.soundSummon~=''
    sounds.play('woosh', hasSS and 0.35 or 1, 0.95+0.1*love.math.random())
    sounds.play(typeData.soundSummon, 1, 0.95+0.1*love.math.random())

    return self
end

function piece:canMove()
    if self:hasSummoningSickness() then return end
    return (self.typeData.moveCost and self.typeData.moveCost<=self.player.mana) and (not self.lastMoved or self.lastMoved<self.board.turn) and (not self.lastSpecialed or self.lastSpecialed<self.board.turn)
end

function piece:canDash()
    if self:hasSummoningSickness() then return end
    return (self.typeData.dashCost and self.typeData.dashCost<=self.player.mana) and (not self.lastSpecialed or self.lastSpecialed<self.board.turn)
end

function piece:canAttack()
    if self:hasSummoningSickness() then return end
    return (self.typeData.attackCost and self.typeData.attackCost<=self.player.mana) and (not self.lastSpecialed or self.lastSpecialed<self.board.turn)
end

function piece:canSpecial()
    if self:hasSummoningSickness() then return end
    return ((self.typeData.dashCost and self.typeData.dashCost<=self.player.mana) or (self.typeData.attackCost and self.typeData.attackCost<=self.player.mana)) and (not self.lastSpecialed or self.lastSpecialed<self.board.turn)
end

function piece:canTravelTo(targetX, targetY)
    if self.dead then return end
    if not self.board:isActivePlayer(self.player) then return end
    if not (self:canMove() or self:canDash()) then return end
    if self.pos[1]==targetX and self.pos[2]==targetY then return end
    if not self:canAttack() and self.board:getLivingPieceAt(targetX, targetY) then return end
    return self.typeData.canTravelTo(self, targetX, targetY)
end

function piece:onMoveTo(targetX, targetY)
    if self.typeData.onMoveTo then
        self.typeData.onMoveTo(self, targetX, targetY)
    end
    if self:canMove() then
        self.player:takeMana(self.typeData.moveCost)
        self.lastMoved = self.board.turn
    elseif self:canDash() then
        self.player:takeMana(self.typeData.dashCost)
        self.lastSpecialed = self.board.turn
    end
    sounds.play(self.typeData.soundMove, 1, 0.95+0.1*love.math.random())
end

function piece:canAttackTo(targetX, targetY)
    if self.dead then return end
    if not self.board:isActivePlayer(self.player) then return end
    if self.typeData.attackMove then return end
    if not (self:canAttack()) then return end
    if not self.typeData.attackRange or self.typeData.attackRange==0 then return end
    if self.pos[1]==targetX and self.pos[2]==targetY then return end
    return self.typeData.canAttackTo and self.typeData.canAttackTo(self, targetX, targetY)
end

function piece:onAttackTo(targetX, targetY)
    local board = self.board
    board:sendData(self.player, ('ATTACK: %d %d %d %d'):format(board:sendXYXY(self.pos[1], self.pos[2], targetX, targetY)) )
    if self.typeData.onAttackTo then
        self.typeData.onAttackTo(self, targetX, targetY)
    end
    self.player:takeMana(self.typeData.attackCost)
    self.lastSpecialed = self.board.turn
    sounds.play(self.typeData.soundAttack, 1, 0.95+0.1*love.math.random())
end

function piece:update(delta)
    if not self.dead then return end
    self.dead = self.dead+delta
    self.rotation = math.min(math.pi/2, self.dead*6)
    if self.dead>2.5 then
        self.board:deleteFrom(self)
    end
end

function piece:isAlive()
    return not self.dead
end

function piece:isDead()
    return self.dead
end

function piece:kill(instigator)
    if self.dead then return end
    self.dead = 0
    if self.typeData.onKill then self.typeData.onKill(self, instigator) end
    if self.player then
        self.player:removeSummon(self)
    end
    sounds.play(self.typeData.soundDeath, 1, 0.95+0.1*love.math.random())
end

local summonSickSpiral = genQuad(9, 7)

local hsvcolour = love.graphics.newShader'hsvcolour.vs'

function piece:draw(boardXPos, boardYPos, gridXPos, gridYPos)
    local opponent = self.player~=self.board.localplayer
    if opponent then
        love.graphics.setColor(1,0,0)
    else
        love.graphics.setColor(0,0,1)
    end
    love.graphics.draw(spriteAtlas, piecetypes[self.type].quadU, gridXPos, gridYPos+self.board.scale*spriteSize*0.25, (self.rotation or 0)+(opponent and math.pi or 0), self.board.scale, self.board.scale, spriteSize/2, spriteSize*(opponent and 0.25 or 0.75))
    love.graphics.setShader(hsvcolour)
    local v = self:canMove() and 1 or self:canSpecial() and 0.5 or 0
    love.graphics.setColor(1, v, 0.5+0.5*v)
    love.graphics.draw(spriteAtlas, piecetypes[self.type].quad, gridXPos, gridYPos+self.board.scale*spriteSize*0.25, (self.rotation or 0)+(opponent and math.pi or 0), self.board.scale, self.board.scale, spriteSize/2, spriteSize*(opponent and 0.25 or 0.75))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader()
    if self:hasSummoningSickness() and self:isAlive() then
        love.graphics.setBlendMode'add'
        local scale = self.board.scale+self.board.scale*0.25*math.sin(love.timer.getTime()+(self.pos[1]%self.pos[2]))
        local scale2 = self.board.scale+self.board.scale*0.25*math.sin(love.timer.getTime()+0.8+(self.pos[1]%self.pos[2]))
        local rot = love.timer.getTime()+(self.pos[1]%self.pos[2])
        love.graphics.draw(spriteAtlas, summonSickSpiral, gridXPos, gridYPos, -rot, scale, scale, spriteSize/2, spriteSize/2)
        love.graphics.draw(spriteAtlas, summonSickSpiral, gridXPos, gridYPos, -rot*1.2, scale2, scale2, spriteSize/2, spriteSize/2)
        love.graphics.setBlendMode'alpha'
    end
end

function piece:getCurrentTurn() return self.board.turn end
function piece:hasSummoningSickness() return self.board.turn==self.summonTurn end

-- function piece:mousemoved(x, y, xDelta, yDelta, istouch)
-- end
--
-- function piece:mousepressed(x, y, button, istouch, presses)
-- end
--
-- function piece:mousereleased(x, y, button, istouch, presses)
-- end
--
-- function piece:wheelmoved(x, y)
-- end

return piece

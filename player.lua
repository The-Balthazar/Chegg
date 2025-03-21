local player = {}
player.__index = player

function player:new()
    setmetatable(self, player)
    self.mana = self.mana or 0
    self.manaMax = self.manaMax or 0
    self.hand = self.hand or {'king'}
    self.summons = self.summons or {}
    self.deck = self.deck or {
        'zombie',
        'creeper',
        'pig',
        'rabbit',
        'pufferfish',

        'golem',
        'frog',
        'skeleton',
        'blaze',
        'phantom',

        'farlander',
        'box',
        'cat',
        'sniffer',
        'wither',
    }
    return self
end

function player:setBoard(board)
    if not board then return end
    self.board = board
end

function player:shuffle()
    if not self.deck then return end
    table.randomSort(self.deck)
    return true
end

function player:draw()
    if not self.hand or not self.deck or not self.deck[1] then return end
    table.insert(self.hand, table.remove(self.deck))
    return true
end

function player:discardRandom()
    if not self.hand or not self.hand[1] then return end
    table.remove(self.hand, love.math.random(1, #self.hand))
end

function player:addToHand(item)
    if not self.hand or not item then return end
    table.insert(self.hand, item)
    return true
end

function player:mill()
    if not self.deck[1] then return end
    return table.remove(self.deck)
end

function player:canEndTurn()
    return self.summons and self.summons[1]
end

function player:insertSummon(summon)
    table.insert(self.summons, summon)
end

function player:removeSummon(summon)
    return table.removeByValue(self.summons, summon)
end

function player:startTurn()
    local turnNo = self.board.turn
    if turnNo<=0 then return true end
    if math.ceil(turnNo/2)==1 then
        self:shuffle()
        self:draw()
        self:draw()
        self:draw()
    else
        self:draw()
    end
    self.manaMax = math.min(6, self.manaMax+1)
    self.mana = self.manaMax
    for i, summon in ipairs(self.summons) do
        if summon.onStartTurn then
            summon:onStartTurn()
        end
    end
    return true
end

function player:takeMana(count)
    if count>self.mana then return end
    self.mana = self.mana-count
    return true
end

function player:getMana()
    return self.mana, self.manaMax
end

function player:getHand()
    return self.hand
end

return player

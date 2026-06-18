local game = {}
game.__index = game

function game:new()
    setmetatable(self, game)

    local function endscreen(player, instigator)
        if self.gameover then return end
        self.gameover = true
        if self.otherplayer then
            table.insert(self.activepreview.buttons,{
                xy = function() return love.graphics.getWidth()/2-250, 400 end,
                widthheight = function() return 200, 60 end,
                press = function()
                    setMode(require'uis.mainmenu'.new{})
                    EnetDisconnect()
                end,
                text = ('Main menu'):lower(),
            })
            table.insert(self.activepreview.buttons,{
                xy = function() return love.graphics.getWidth()/2+50, 400 end,
                widthheight = function() return 200, 60 end,
                press = function()
                    setMode(require'uis.game'.new{
                        deck = self.localplayer.startingDeck,
                        isStartingPlayer = not self.isStartingPlayer,
                        opponentType = self.activeboard.othertype,
                        opponentDeck = self.otherplayer.startingDeck,
                        seed = self.seed,
                        rng = self.rng,
                    })
                    if self.activeboard.othertype=='remote' then
                        love.thread.getChannel'comOut':push('RESTART')
                    end
                end,
                activeIf = function() return not self.otherDisconnected end,
                text = ('Rematch'):lower(),
            })
        else
            table.insert(self.activepreview.buttons,{
                xy = function() return love.graphics.getWidth()/2-100, 400 end,
                widthheight = function() return 200, 60 end,
                press = function()
                    setMode(require'uis.mainmenu'.new{})
                    EnetDisconnect()
                end,
                text = ('Main menu'):lower(),
            })
        end
    end

    self.rng = self.rng or love.math.newRandomGenerator(self.seed)

    self.localplayer = require'player'.new{
        deck = self.deck,
        startingDeck = table.copy(self.deck),
        onDefeat = endscreen,
        rng = self.rng,
    }
    self.deck = nil

    if self.opponentDeck then
        self.otherplayer = require'player'.new{
            deck = self.opponentDeck,
            startingDeck = table.copy(self.opponentDeck),
            onDefeat = endscreen,
            rng = self.rng,
        }
        self.opponentDeck = nil
    end

    local first = self.isStartingPlayer

    self.activeboard = require'board'.new{
        rows = 10,
        cols = 8,
        players = {
            first and self.localplayer or self.otherplayer,
            first and self.otherplayer or self.localplayer,
        },
        localplayer = self.localplayer,
        otherplayer = self.otherplayer,
        othertype = self.opponentType,
    }
    self.opponentType = nil

    self.activepreview = require'preview'.new{
        board = self.activeboard,
        player = self.localplayer,
        getPreviewItem = function()
            local piece = self.activeboard:getSelectedPiece()
            if piece then
                return require'pieces'.getTypeData(piece.type)
            end
        end,
        getPreviewItemAttack = function()
            local piece = self.activeboard:getSelectedPiece()
            if piece and piece.attackAs then
                return require'pieces'.getTypeData(piece.attackAs)
            elseif piece then
                return require'pieces'.getTypeData(piece.type)
            end
        end,
        getManaCount = function() return self.localplayer:getMana() end,
        getTurnNumber = function() return self.activeboard.turn end,
        getHand = function() return self.localplayer:getHand() end,
        getDeckSize = function() return self.localplayer:getDeckSize() end,
        buttons = {
            {
                xy = function() return spriteSize*3, love.graphics.getHeight()-(spriteSize*2)+20 end,
                widthheight = function() return 200, 100-40 end,
                press = function()
                    self.activeboard:endTurn(self.localplayer)
                end,
                text = ('End turn'):lower(),
                activeIf = function() return self.activeboard:canEndTurn(self.localplayer) end,
            }
        }
    }
    if self.otherplayer then
        self.otherpreview = require'previewother'.new{
            board = self.activeboard,
            player = self.otherplayer,
            getHand = function() return self.otherplayer:getHand() end,
            getDeckSize = function() return self.otherplayer:getDeckSize() end,
        }
    end
    return self
end

function game:update(delta)
    if self.activeboard then
        self.activeboard:update(delta)
    end
    EnetHandle(function(data)
        if data=='MSG: disconnected' then
            self.otherDisconnected = true
            if not self.gameover then
                table.insert(self.activepreview.buttons,{
                    xy = function() return love.graphics.getWidth()/2-300, 400 end,
                    widthheight = function() return 600, 60 end,
                    press = function()
                        setMode(require'uis.mainmenu'.new{})
                        EnetDisconnect()
                    end,
                    text = ('Other player disconnected - main menu'):lower(),
                })
            end
            EnetDisconnect()
        elseif data=='MSG: connection timed out' then
            self.otherDisconnected = true
            if not self.gameover then
                table.insert(self.activepreview.buttons,{
                    xy = function() return love.graphics.getWidth()/2-300, 400 end,
                    widthheight = function() return 600, 60 end,
                    press = function()
                        setMode(require'uis.mainmenu'.new{})
                        EnetDisconnect()
                    end,
                    text = ('Other player timed out - main menu'):lower(),
                })
            end
        elseif data=='RESTART' and (self.otherplayer.dead or self.localplayer.dead) then --Check dead just as a minimal exploit prevention
            setMode(require'uis.game'.new{
                deck = self.localplayer.startingDeck,
                isStartingPlayer = not self.isStartingPlayer,
                opponentType = self.activeboard.othertype,
                opponentDeck = self.otherplayer.startingDeck,
                seed = self.seed,
                rng = self.rng,
            })
        elseif data=='ENDTURN' then
            if self.activeboard:canEndTurn(self.otherplayer) then
                self.activeboard:endTurn(self.otherplayer)
            else
                error"DESYNC ERROR: Opponent tried to end turn when they shouldn't be able to."
            end

        elseif data:find'^SUMMON:' then
            local t, x, y = data:match': (%a*) (%d*) (%d*)'
            local hand = self.otherplayer:getHand()
            local pressI = self.otherpreview:getHandPressIndex()
            if hand[pressI]==t then
                table.remove(hand, pressI)
            else
                local found = table.find(hand,pressI)
                if found then
                    print"WARNING: Opponent summoned a creature that doesn't match what they were mousing over."
                    table.remove(hand, found)
                else
                    error"DESYNC ERROR: Opponent tried to summon a creature not found in their hand."
                end
            end
            self.activeboard:summonAt(self.otherplayer, t, tonumber(x), tonumber(y))

        elseif data:find'^MOVE:' then
            local sx, sy, x, y = data:match': (%d*) (%d*) (%d*) (%d*)'
            local piece = self.activeboard:getLivingPieceAt(tonumber(sx), tonumber(sy))
            if not self.activeboard:movePiece(piece.player, piece, tonumber(x), tonumber(y)) then
                error"DESYNC ERROR: Opponent made a seemingly illegal move"
            end

        elseif data:find'^ATTACK:' then
            local sx, sy, x, y = data:match': (%d*) (%d*) (%d*) (%d*)'
            local piece = self.activeboard:getLivingPieceAt(tonumber(sx), tonumber(sy))
            if not self.activeboard:attackWithPiece(piece.player, piece, tonumber(x), tonumber(y)) then
                error"DESYNC ERROR: Opponent made a seemingly illegal attack"
            end

        elseif data:find'^PREVIEW HOVER:' then
            local val = data:match': (.*)'
            self.otherpreview:setHandHoverIndex(tonumber(val))

        elseif data:find'^PREVIEW PRESS:' then
            local val = data:match': (.*)'
            self.otherpreview:setHandPressIndex(tonumber(val))

        elseif data:find'^BOARD HOVER:' then
            local x, y = data:match': ([^ ]*) ([^ ]*)'
            self.activeboard:setOtherHover(tonumber(x), tonumber(y))
        else
            print("unused recieved data: ", data)
        end
    end)
end

local text = love.graphics.newImageFont('bigtext.png', ' abcdefghijklmnopqrstuvwxyz!?')
text:setFilter('nearest', 'nearest')

function game:draw()
    love.graphics.clear(1/2,1/2,1/2)
    if self.activeboard   then self.activeboard:draw()   end
    if self.otherpreview  then self.otherpreview:draw()  end
    if self.activepreview then self.activepreview:draw() end
    love.graphics.setColor(0,0,0)
    if self.otherplayer and self.otherplayer.dead and not self.localplayer.dead then
        love.graphics.printf('you win!?', text, 0, 100, love.graphics.getWidth()/2, 'center', 0, 2, 2)
    elseif self.otherplayer and self.otherplayer.dead and self.localplayer.dead then
        love.graphics.printf('draw!?', text, 0, 100, love.graphics.getWidth()/2, 'center', 0, 2, 2)
    elseif self.otherplayer and not self.otherplayer.dead and self.localplayer.dead then
        love.graphics.printf('you lose!?', text, 0, 100, love.graphics.getWidth()/2, 'center', 0, 2, 2)
    end
end

function game:mousemoved(x, y, xDelta, yDelta, istouch)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
    if self.activeboard   then intercepted =   self.activeboard:mousemoved(x, y, xDelta, yDelta, istouch, intercepted) end
end

function game:mousepressed(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousepressed(x, y, button, istouch, presses, intercepted) end
    if self.activeboard   then intercepted =   self.activeboard:mousepressed(x, y, button, istouch, presses, intercepted) end
end

function game:mousereleased(x, y, button, istouch, presses)
    local intercepted
    if self.activepreview then intercepted = self.activepreview:mousereleased(x, y, button, istouch, presses, intercepted) end
    if self.activeboard   then intercepted =   self.activeboard:mousereleased(x, y, button, istouch, presses, intercepted) end
end

function game:wheelmoved(x, y)
    if self.activeboard then
        self.activeboard:wheelmoved(x, y)
    end
end

return game

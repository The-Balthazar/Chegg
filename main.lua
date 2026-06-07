local activeMode

function love.load()
    require'utils'

    spriteAtlas = love.graphics.newImage'sprites.png'
    spriteAtlas:setFilter('nearest', 'nearest')

    spriteSize = 50
    function genQuad(xi, yi)
        return love.graphics.newQuad((xi-1)*spriteSize, (yi-1)*spriteSize, spriteSize, spriteSize, spriteAtlas)
    end

    activeMode = require'uis.mainmenu'.new{}
end

function setMode(mode)
    activeMode = mode or activeMode
end

function love.update(delta)
    if activeMode and activeMode.update then
        activeMode:update(delta)
    end
end

function love.draw()
    if activeMode then
        activeMode:draw()
    end
end

function love.mousemoved(x, y, xDelta, yDelta, istouch)
    if activeMode and activeMode.mousemoved then
        activeMode:mousemoved(x, y, xDelta, yDelta, istouch)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if activeMode and activeMode.mousepressed then
        activeMode:mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if activeMode and activeMode.mousereleased then
        activeMode:mousereleased(x, y, button, istouch, presses)
    end
end

function love.wheelmoved(x, y)
    if activeMode and activeMode.wheelmoved then
        activeMode:wheelmoved(x, y)
    end
end

function love.keypressed(...)
    if activeMode and activeMode.keypressed then
        activeMode:keypressed(...)
    end
end

function love.textinput(...)
    if activeMode and activeMode.textinput then
        activeMode:textinput(...)
    end
end

function love.quit()
    if EnetDisconnect and EnetDisconnect() then
        EnetHandle()
    end
end


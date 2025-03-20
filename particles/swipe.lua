local scratch = love.graphics.newParticleSystem(spriteAtlas, 10)
scratch:setDirection(2)
scratch:setEmitterLifetime(-1)
scratch:setParticleLifetime(0.1, 0.2)
scratch:setSpeed(50, 45)
scratch:setSizes(0.5)
scratch:setQuads(
    love.graphics.newQuad(0,   300, 50, 50, 500, 500),
    love.graphics.newQuad(50,  300, 50, 50, 500, 500),
    love.graphics.newQuad(100, 300, 50, 50, 500, 500)
)

return scratch

local FX_exp = love.graphics.newParticleSystem(spriteAtlas, 80)
FX_exp:setEmitterLifetime(-1)
FX_exp:setParticleLifetime(0.25, 0.4)
FX_exp:setRotation(-math.pi, math.pi)
FX_exp:setQuads(
    love.graphics.newQuad(0,   250, 50, 50, 500, 500),
    love.graphics.newQuad(50,  250, 50, 50, 500, 500),
    love.graphics.newQuad(100, 250, 50, 50, 500, 500),
    love.graphics.newQuad(150, 250, 50, 50, 500, 500),
    love.graphics.newQuad(200, 250, 50, 50, 500, 500),
    love.graphics.newQuad(250, 250, 50, 50, 500, 500)
)

return FX_exp

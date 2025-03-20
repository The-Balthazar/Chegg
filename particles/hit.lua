local hit = love.graphics.newParticleSystem(spriteAtlas, 10)
hit:setEmitterLifetime(-1)
hit:setParticleLifetime(0.1, 0.2)
-- hit:setSizes(0.5)
hit:setQuads(
    love.graphics.newQuad(400, 200, 50, 50, 500, 500),
    love.graphics.newQuad(450, 200, 50, 50, 500, 500)
)

return hit

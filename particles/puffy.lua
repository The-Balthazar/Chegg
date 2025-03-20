local FX_PFish = love.graphics.newParticleSystem(spriteAtlas, 20)
FX_PFish:setEmitterLifetime(-1)
FX_PFish:setParticleLifetime(0.15, 0.2)
FX_PFish:setSizes(0.5, 2)
FX_PFish:setQuads(love.graphics.newQuad(300, 250, 50, 50, 500, 500))

return FX_PFish

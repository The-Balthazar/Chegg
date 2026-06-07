local soundfiles = {
    book_grab = {
        love.audio.newSource('/sounds/book-grab-01.ogg', 'static'),
        love.audio.newSource('/sounds/book-grab-02.ogg', 'static'),
        love.audio.newSource('/sounds/book-grab-03.ogg', 'static'),
        love.audio.newSource('/sounds/book-grab-04.ogg', 'static'),
        love.audio.newSource('/sounds/book-grab-05.ogg', 'static'),
        volume = 0.75,
    },
    bug_hit = {
        love.audio.newSource('/sounds/crab-impact-01.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-02.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-03.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-04.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-05.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-06.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-07.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-08.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-09.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-10.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-11.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-12.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-13.ogg', 'static'),
        love.audio.newSource('/sounds/crab-impact-14.ogg', 'static'),
        volume = 0.1,
    },
    slime_death = {
        love.audio.newSource('/sounds/slime-death-01.ogg', 'static'),
        love.audio.newSource('/sounds/slime-death-02.ogg', 'static'),
        misophonia = 'slime',
    },
    slime_squelch = {
        love.audio.newSource('/sounds/slime-squelch-01.ogg', 'static'),
        love.audio.newSource('/sounds/slime-squelch-02.ogg', 'static'),
        love.audio.newSource('/sounds/slime-squelch-03.ogg', 'static'),
        love.audio.newSource('/sounds/slime-squelch-04.ogg', 'static'),
        misophonia = 'slime',
    },
    slime_light_squelch = {
        love.audio.newSource('/sounds/slime-soft-squelch-01.ogg', 'static'),
        love.audio.newSource('/sounds/slime-soft-squelch-02.ogg', 'static'),
        misophonia = 'slime',
    },
    skeleton_hurt = {
        love.audio.newSource('/sounds/bones-hit-01.ogg', 'static'),
        love.audio.newSource('/sounds/bones-hit-02.ogg', 'static'),
        love.audio.newSource('/sounds/bones-hit-03.ogg', 'static'),
    },
    skeleton_death = {
        love.audio.newSource('/sounds/bones-breaking-01.ogg', 'static'),
        love.audio.newSource('/sounds/bones-breaking-02.ogg', 'static'),
        love.audio.newSource('/sounds/bones-breaking-03.ogg', 'static'),
        love.audio.newSource('/sounds/bones-breaking-04.ogg', 'static'),
    },
    fireball = {
        love.audio.newSource('/sounds/fireball-01.ogg', 'static'),
        love.audio.newSource('/sounds/fireball-02.ogg', 'static'),
        volume = 0.5,
    },
    fire_ignite = {
        love.audio.newSource('/sounds/fire-ignite-01.ogg', 'static'),
        volume = 0.5,
    },
    paper_grab = {
        love.audio.newSource('/sounds/paper-grab-01.ogg', 'static'),
        love.audio.newSource('/sounds/paper-grab-02.ogg', 'static'),
        love.audio.newSource('/sounds/paper-grab-03.ogg', 'static'),
        love.audio.newSource('/sounds/paper-grab-04.ogg', 'static'),
        love.audio.newSource('/sounds/paper-grab-05.ogg', 'static'),
        volume = 0.66,
    },
    paper_drop = {
        love.audio.newSource('/sounds/paper-drop-01.ogg', 'static'),
        love.audio.newSource('/sounds/paper-drop-02.ogg', 'static'),
        love.audio.newSource('/sounds/paper-drop-03.ogg', 'static'),
        love.audio.newSource('/sounds/paper-drop-04.ogg', 'static'),
        love.audio.newSource('/sounds/paper-drop-05.ogg', 'static'),
        volume = 0.66,
    },
    wood_footstep_medium = {
        love.audio.newSource('/sounds/wood-footstep-medium-01.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-medium-02.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-medium-03.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-medium-04.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-medium-05.ogg', 'static'),
        volume = 0.1,
    },
    wood_footstep_heavy = {
        love.audio.newSource('/sounds/wood-footstep-heavy-01.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-heavy-02.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-heavy-03.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-heavy-04.ogg', 'static'),
        love.audio.newSource('/sounds/wood-footstep-heavy-05.ogg', 'static'),
        volume = 0.2,
    },
    woosh = {
        love.audio.newSource('/sounds/magic-woosh-01.ogg', 'static'),
        love.audio.newSource('/sounds/magic-woosh-02.ogg', 'static'),
        love.audio.newSource('/sounds/magic-woosh-03.ogg', 'static'),
        love.audio.newSource('/sounds/magic-woosh-04.ogg', 'static'),
        love.audio.newSource('/sounds/magic-woosh-05.ogg', 'static'),
        volume = 0.65,
    },
    shwing = {
        love.audio.newSource('/sounds/shwing-01.ogg', 'static'),
        volume = 0.35,
    },
    metal_hit_reverb = {
        love.audio.newSource('/sounds/metal-reverb-hit-01.ogg', 'static'),
        volume = 0.35,
    },
}

sounds = {}

function sounds.play(name, volume, pitch)
    local soundData = soundfiles[name]
    if not soundData then return end
    if soundData then
        local toplay = soundData[soundData.cycle or love.math.random(1, #soundData)]
        toplay:stop()
        toplay:setPitch(pitch or 1)
        toplay:setVolume((volume or 1) * (soundData.volume or 1))
        toplay:play()
        if soundData.cycle then
            soundData.cycle = math.mod(soundData.cycle+1, #soundData)
        end
    end
end

local Constants = require("src.constants")

local Sound = {
    muted = false,
    sfxVolume = 0.85,
    musicVolume = 0.65,
    sources = {},
    currentMusic = nil,
    currentMusicKey = nil
}

local function safeLoadSource(path, sourceType)
    if not love.audio or not love.filesystem then return nil end
    local info = love.filesystem.getInfo(path)
    if info and info.size > 0 then
        local success, src = pcall(love.audio.newSource, path, sourceType or "static")
        if success and src then
            return src
        end
    end
    return nil
end

local function generateSyntheticSound(generatorFunc, duration, rate)
    if not love.sound or not love.audio then return nil end
    rate = rate or 22050
    local samples = math.floor(duration * rate)
    local ok, soundData = pcall(love.sound.newSoundData, samples, rate, 16, 1)
    if not ok or not soundData then return nil end
    
    for i = 0, samples - 1 do
        local t = i / rate
        local sample = generatorFunc(t, duration)
        if sample > 1 then sample = 1 elseif sample < -1 then sample = -1 end
        soundData:setSample(i, sample)
    end
    
    local ok2, source = pcall(love.audio.newSource, soundData, "static")
    if ok2 and source then
        return source
    end
    return nil
end

function Sound.init()
    if not love.audio then return end

    -- Attempt to load file SFX, otherwise create synthetic fallbacks
    Sound.sources.button_pressed = safeLoadSource(Constants.SFX_FILES.BUTTON_PRESSED, "static") or generateSyntheticSound(function(t, d)
        local freq = 600 + (t / d) * 400
        local env = math.max(0, 1 - t / d)
        return math.sin(2 * math.pi * freq * t) * env * 0.4
    end, 0.08)

    Sound.sources.bounce = safeLoadSource(Constants.SFX_FILES.BOUNCE, "static") or generateSyntheticSound(function(t, d)
        local freq = 200 + math.sin(t / d * math.pi) * 450
        local env = math.exp(-t * 9)
        return (math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(4 * math.pi * freq * t)) * env * 0.5
    end, 0.28)

    Sound.sources.tagged = safeLoadSource(Constants.SFX_FILES.TAGGED, "static") or generateSyntheticSound(function(t, d)
        local freq = 750 - (t / d) * 450
        local vib = math.sin(t * 40) * 40
        local saw = (2 * ((t * (freq + vib)) % 1)) - 1
        local env = math.max(0, 1 - t / d)
        return (saw * 0.4 + math.sin(2 * math.pi * 120 * t) * 0.4) * env * 0.55
    end, 0.38)

    Sound.sources.teleport = safeLoadSource(Constants.SFX_FILES.TELEPORT, "static") or generateSyntheticSound(function(t, d)
        local freq = 280 + ((t / d) ^ 1.5) * 850
        local phaser = math.sin(t * 35) * 0.5
        local env = math.sin((t / d) * math.pi)
        return (math.sin(2 * math.pi * (freq + phaser * 50) * t) * 0.5 + (math.random() * 2 - 1) * 0.08) * env * 0.45
    end, 0.45)

    Sound.sources.game_over = safeLoadSource(Constants.SFX_FILES.GAME_OVER, "static") or generateSyntheticSound(function(t, d)
        local note = math.floor(t * 5)
        local freqs = {261.63, 329.63, 392.00, 523.25, 659.25}
        local f = freqs[math.min(#freqs, note + 1)] or 523.25
        local env = math.max(0, 1 - (t % 0.2) / 0.2) * (1 - t / d * 0.5)
        return math.sin(2 * math.pi * f * t) * env * 0.4
    end, 0.85)

    Sound.sources.shield_break = generateSyntheticSound(function(t, d)
        local noise = (math.random() * 2 - 1) * math.exp(-t * 22)
        local tone = math.sin(2 * math.pi * 1400 * t) * math.exp(-t * 12)
        return (noise * 0.4 + tone * 0.3)
    end, 0.25)

    Sound.sources.buff_collect = generateSyntheticSound(function(t, d)
        local note = math.floor(t * 12)
        local freqs = {523.25, 659.25, 783.99, 1046.50}
        local f = freqs[math.min(#freqs, note + 1)] or 1046.50
        local env = math.max(0, 1 - (t % 0.08) / 0.08)
        return (math.sin(2 * math.pi * f * t) + 0.2 * math.sin(4 * math.pi * f * t)) * env * 0.4
    end, 0.32)

    Sound.sources.tick = generateSyntheticSound(function(t, d)
        local env = math.exp(-t * 80)
        return (math.sin(2 * math.pi * 1200 * t) + (math.random() * 2 - 1) * 0.3) * env * 0.4
    end, 0.06)

    -- Try loading background music files
    Sound.musicFiles = {
        classic = Constants.SFX_FILES.CLASSIC_MUSIC,
        snow = Constants.SFX_FILES.SNOW_MUSIC,
        desert = Constants.SFX_FILES.DESERT_MUSIC
    }
end

function Sound.play(name, volumeScale)
    if Sound.muted or not love.audio then return end
    local src = Sound.sources[name]
    if src then
        local ok, cloned = pcall(function() return src:clone() end)
        local toPlay = (ok and cloned) or src
        if toPlay then
            toPlay:setVolume(Sound.sfxVolume * (volumeScale or 1.0))
            pcall(function() toPlay:play() end)
        end
    end
end

function Sound.playMusic(mapType)
    if not love.audio then return end
    if Sound.currentMusicKey == mapType and Sound.currentMusic and Sound.currentMusic:isPlaying() then
        return
    end

    Sound.stopMusic()
    Sound.currentMusicKey = mapType

    local filePath = Sound.musicFiles and Sound.musicFiles[mapType]
    if filePath then
        local src = safeLoadSource(filePath, "stream")
        if src then
            src:setLooping(true)
            src:setVolume(Sound.muted and 0 or Sound.musicVolume)
            pcall(function() src:play() end)
            Sound.currentMusic = src
        end
    end
end

function Sound.stopMusic()
    if Sound.currentMusic and love.audio then
        pcall(function() Sound.currentMusic:stop() end)
        Sound.currentMusic = nil
        Sound.currentMusicKey = nil
    end
end

function Sound.toggleMute()
    Sound.muted = not Sound.muted
    if Sound.currentMusic and love.audio then
        Sound.currentMusic:setVolume(Sound.muted and 0 or Sound.musicVolume)
    end
    return Sound.muted
end

return Sound

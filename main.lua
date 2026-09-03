-- TAG: A LOVE2D Game
-- Web-compatible with love.js

local Constants = require("src.constants")
local Utils = require("src.utils")
local Sound = require("src.sound")
local Particles = require("src.particles")
local Player = require("src.player")
local Map = require("src.map")
local TeleporterSystem = require("src.teleporter")
local Buffs = require("src.buffs")
local UI = require("src.ui")
local Camera = require("src.camera")

local Game = {
    state = Constants.STATES.TITLE,
    playerCount = 2,
    selectedMap = Constants.MAPS.CLASSIC,
    currentMap = nil,
    players = {},
    titlePlayers = {},
    titleMap = nil,
    
    settings = {
        buffsEnabled = true,
        gameDuration = 120
    },
    showSettings = false,
    
    matchTimer = 120,
    lastTickSecond = 10,
    
    -- Virtual screen scaling
    scale = 1,
    offsetX = 0,
    offsetY = 0,
    
    -- Interactive UI elements for current frame
    activeButtons = {}
}

local function updateScale()
    local winW, winH = love.graphics.getDimensions()
    local scaleX = winW / Constants.VIRTUAL_WIDTH
    local scaleY = winH / Constants.VIRTUAL_HEIGHT
    Game.scale = math.min(scaleX, scaleY)
    Game.offsetX = math.floor((winW - Constants.VIRTUAL_WIDTH * Game.scale) * 0.5)
    Game.offsetY = math.floor((winH - Constants.VIRTUAL_HEIGHT * Game.scale) * 0.5)
end

local function toVirtual(mx, my)
    local vx = (mx - Game.offsetX) / Game.scale
    local vy = (my - Game.offsetY) / Game.scale
    return vx, vy
end

function love.load()
    love.graphics.setDefaultFilter("linear", "linear")
    updateScale()
    
    Sound.init()
    Particles.init()
    UI.init()
    TeleporterSystem.init()
    
    -- Init title screen background demo
    Game.titleMap = Map.load(Constants.MAPS.CLASSIC)
    Game.titlePlayers = {
        Player.new(2, 330, 600), -- Red on box
        Player.new(3, 230, 480), -- Yellow jumping
        Player.new(1, 840, 600), -- Blue running
        Player.new(4, 1100, 520) -- Green right
    }
    Game.titlePlayers[3].vy = -200
    Game.titlePlayers[4].vy = -150
end

function love.resize(w, h)
    updateScale()
end

local function startMatch()
    Game.currentMap = Map.load(Game.selectedMap)
    Game.players = {}
    
    -- Create players
    for i = 1, Game.playerCount do
        local sp = Game.currentMap.spawnPoints[i] or {x = 100 + i * 200, y = 500}
        local p = Player.new(i, sp.x, sp.y)
        table.insert(Game.players, p)
    end
    
    -- Randomly assign "IT" to one player
    local itIndex = math.random(1, Game.playerCount)
    for i, p in ipairs(Game.players) do
        p:setIt(i == itIndex, true)
    end
    
    -- Reset match systems
    Game.matchTimer = Game.settings.gameDuration
    Game.lastTickSecond = 10
    Particles.reset()
    TeleporterSystem.reset(Game.currentMap)
    Buffs.reset(Game.settings)
    Camera.reset()
    
    Game.state = Constants.STATES.PLAYING
    Sound.playMusic(Game.selectedMap)
end

function love.update(dt)
    -- Cap delta time to prevent physics tunneling on lag spikes
    dt = math.min(dt, 0.05)
    
    Particles.update(dt)
    
    if Game.state == Constants.STATES.TITLE then
        -- Update title preview characters
        if Game.titleMap then
            Game.titleMap:update(dt, Game.titlePlayers)
            for _, p in ipairs(Game.titlePlayers) do
                p:update(dt, Game.titleMap)
                -- Auto bounce / patrol on title
                if p.x <= 40 then p.vx = 140 p.facing = 1 end
                if p.x >= Constants.VIRTUAL_WIDTH - 80 then p.vx = -140 p.facing = -1 end
                if p.onGround and math.random() < 0.015 then
                    p.vy = p.jumpForce
                    p.onGround = false
                end
            end
        end
        
    elseif Game.state == Constants.STATES.PLAYING then
        Game.matchTimer = Game.matchTimer - dt
        
        -- Camera dynamic zoom & pan update
        Camera.update(dt, Game.players)
        
        -- Last 10 seconds tick sound
        local secInt = math.floor(Game.matchTimer)
        if secInt <= 10 and secInt > 0 and secInt < Game.lastTickSecond then
            Game.lastTickSecond = secInt
            Sound.play("tick")
        end
        
        -- Game Over check
        if Game.matchTimer <= 0 then
            Game.matchTimer = 0
            Game.state = Constants.STATES.GAME_OVER
            Sound.stopMusic()
            Sound.play("game_over")
            -- Trigger confetti shower
            for i = 1, 60 do
                Particles.addConfettiPiece()
            end
            return
        end
        
        -- Update Map (bounce pads)
        if Game.currentMap then
            Game.currentMap:update(dt, Game.players)
        end
        
        -- Update Teleporters
        TeleporterSystem.update(dt, Game.players, Game.currentMap)
        
        -- Update Buffs
        Buffs.update(dt, Game.players, Game.currentMap)
        
        -- Update Players
        for _, p in ipairs(Game.players) do
            p:update(dt, Game.currentMap)
        end
        
        -- Tag collision check between players
        for i = 1, #Game.players do
            for j = i + 1, #Game.players do
                local p1 = Game.players[i]
                local p2 = Game.players[j]
                
                if (p1.isIt or p2.isIt) and not (p1.isIt and p2.isIt) then
                    local itPlayer = p1.isIt and p1 or p2
                    local otherPlayer = p1.isIt and p2 or p1
                    
                    if not itPlayer.teleporting.active and not otherPlayer.teleporting.active then
                        if itPlayer.tagGraceTimer <= 0 and Utils.checkAABB(itPlayer, otherPlayer) then
                            -- Check if other player is protected by shield
                            if otherPlayer.buffs.shield then
                                otherPlayer.buffs.shield = false
                                Particles.addShieldBreak(otherPlayer.x + otherPlayer.w/2, otherPlayer.y + otherPlayer.h/2)
                                Sound.play("shield_break")
                                -- Repel IT slightly
                                local pushDir = Utils.sign(itPlayer.x - otherPlayer.x)
                                if pushDir == 0 then pushDir = 1 end
                                itPlayer.vx = pushDir * 350
                                itPlayer.vy = -200
                                otherPlayer.vx = -pushDir * 250
                            else
                                -- Successful Tag!
                                itPlayer:setIt(false, false)
                                otherPlayer:setIt(true, true)
                                itPlayer.tagsMade = itPlayer.tagsMade + 1
                                
                                Sound.play("tagged")
                                Particles.addTagBurst(otherPlayer.x + otherPlayer.w/2, otherPlayer.y + otherPlayer.h/2, otherPlayer.config.color)
                            end
                        end
                    end
                end
            end
        end
        
    elseif Game.state == Constants.STATES.GAME_OVER then
        -- Confetti rain
        if math.random() < 0.25 then
            Particles.addConfettiPiece()
        end
    end
end

function love.draw()
    -- Virtual resolution scaling
    love.graphics.push()
    love.graphics.translate(Game.offsetX, Game.offsetY)
    love.graphics.scale(Game.scale, Game.scale)
    love.graphics.setScissor(Game.offsetX, Game.offsetY, Constants.VIRTUAL_WIDTH * Game.scale, Constants.VIRTUAL_HEIGHT * Game.scale)
    
    local mx, my = love.mouse.getPosition()
    local vx, vy = toVirtual(mx, my)
    
    Game.activeButtons = {}
    
    if Game.state == Constants.STATES.TITLE then
        if Game.titleMap then Game.titleMap:draw() end
        for _, p in ipairs(Game.titlePlayers) do p:draw() end
        Particles.draw()
        Game.activeButtons = UI.drawTitleScreen(vx, vy)
        
    elseif Game.state == Constants.STATES.MAP_SELECT then
        Game.activeButtons = UI.drawMapSelectScreen(vx, vy)
        if Game.showSettings then
            local modalBtns = UI.drawSettingsModal(Game.settings, vx, vy)
            Game.activeButtons = modalBtns
        end
        
    elseif Game.state == Constants.STATES.CONTROLS then
        Game.activeButtons = UI.drawControlsScreen(Game.playerCount, vx, vy)
        
    elseif Game.state == Constants.STATES.PLAYING then
        Camera.attach()
        if Game.currentMap then Game.currentMap:draw() end
        TeleporterSystem.draw()
        Buffs.draw()
        for _, p in ipairs(Game.players) do p:draw() end
        Particles.draw()
        Camera.detach()
        
        Game.activeButtons = UI.drawHUD(Game.matchTimer, false, vx, vy)
        
    elseif Game.state == Constants.STATES.PAUSED then
        Camera.attach()
        if Game.currentMap then Game.currentMap:draw() end
        TeleporterSystem.draw()
        Buffs.draw()
        for _, p in ipairs(Game.players) do p:draw() end
        Particles.draw()
        Camera.detach()
        
        local pauseBtns = UI.drawPauseScreen(vx, vy)
        Game.activeButtons = pauseBtns
        
    elseif Game.state == Constants.STATES.GAME_OVER then
        Camera.attach()
        if Game.currentMap then Game.currentMap:draw() end
        for _, p in ipairs(Game.players) do p:draw() end
        Particles.draw()
        Camera.detach()
        
        Game.activeButtons = UI.drawGameOverScreen(Game.players, vx, vy)
    end
    
    love.graphics.setScissor()
    love.graphics.pop()
end

function love.keypressed(key)
    if Game.state == Constants.STATES.PLAYING then
        if key == "escape" or key == "p" then
            Game.state = Constants.STATES.PAUSED
            Sound.play("button_pressed")
            return
        end
        for _, p in ipairs(Game.players) do
            p:keypressed(key)
        end
    elseif Game.state == Constants.STATES.PAUSED then
        if key == "escape" or key == "p" then
            Game.state = Constants.STATES.PLAYING
            Sound.play("button_pressed")
            return
        end
    elseif Game.state == Constants.STATES.TITLE then
        if key == "2" then
            Game.playerCount = 2
            Game.state = Constants.STATES.MAP_SELECT
            Sound.play("button_pressed")
        elseif key == "3" then
            Game.playerCount = 3
            Game.state = Constants.STATES.MAP_SELECT
            Sound.play("button_pressed")
        elseif key == "4" then
            Game.playerCount = 4
            Game.state = Constants.STATES.MAP_SELECT
            Sound.play("button_pressed")
        end
    end
end

function love.mousepressed(mx, my, button)
    if button ~= 1 then return end
    local vx, vy = toVirtual(mx, my)
    
    if Game.activeButtons then
        for _, btn in ipairs(Game.activeButtons) do
            if Utils.pointInRect(vx, vy, btn.x, btn.y, btn.w, btn.h) then
                Sound.play("button_pressed")
                
                -- Title Screen actions
                if btn.id == "2_players" then
                    Game.playerCount = 2
                    Game.state = Constants.STATES.MAP_SELECT
                elseif btn.id == "3_players" then
                    Game.playerCount = 3
                    Game.state = Constants.STATES.MAP_SELECT
                elseif btn.id == "4_players" then
                    Game.playerCount = 4
                    Game.state = Constants.STATES.MAP_SELECT
                elseif btn.id == "sound_toggle" then
                    Sound.toggleMute()
                    
                -- Map Select actions
                elseif btn.id == Constants.MAPS.CLASSIC then
                    Game.selectedMap = Constants.MAPS.CLASSIC
                    Game.state = Constants.STATES.CONTROLS
                elseif btn.id == Constants.MAPS.SNOW then
                    Game.selectedMap = Constants.MAPS.SNOW
                    Game.state = Constants.STATES.CONTROLS
                elseif btn.id == Constants.MAPS.DESERT then
                    Game.selectedMap = Constants.MAPS.DESERT
                    Game.state = Constants.STATES.CONTROLS
                elseif btn.id == "back_to_title" then
                    Game.state = Constants.STATES.TITLE
                elseif btn.id == "open_settings" then
                    Game.showSettings = true
                    
                -- Settings Modal actions
                elseif btn.id == "buffs_on" then
                    Game.settings.buffsEnabled = true
                elseif btn.id == "buffs_off" then
                    Game.settings.buffsEnabled = false
                elseif btn.timeVal then
                    Game.settings.gameDuration = btn.timeVal
                elseif btn.id == "close_settings" then
                    Game.showSettings = false
                    
                -- Controls Screen actions
                elseif btn.id == "back_to_map" then
                    Game.state = Constants.STATES.MAP_SELECT
                elseif btn.id == "start_game" then
                    startMatch()
                    
                -- HUD actions
                elseif btn.id == "pause_game" then
                    Game.state = Constants.STATES.PAUSED
                    
                -- Pause Screen actions
                elseif btn.id == "resume_game" then
                    Game.state = Constants.STATES.PLAYING
                elseif btn.id == "exit_to_menu" then
                    Sound.stopMusic()
                    Game.state = Constants.STATES.MAP_SELECT
                    
                -- Game Over actions
                elseif btn.id == "play_again" then
                    startMatch()
                elseif btn.id == "choose_map" then
                    Game.state = Constants.STATES.MAP_SELECT
                elseif btn.id == "main_menu" then
                    Game.state = Constants.STATES.TITLE
                end
                
                return
            end
        end
    end
end

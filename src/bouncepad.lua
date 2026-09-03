local Utils = require("src.utils")
local Sound = require("src.sound")
local Particles = require("src.particles")

local BouncePad = {}
BouncePad.__index = BouncePad

local imgBouncePad = nil

local function getBouncePadImage()
    if not imgBouncePad then
        local path = "assets/bounce_pad.png"
        if love.filesystem.getInfo(path) then
            imgBouncePad = love.graphics.newImage(path)
        end
    end
    return imgBouncePad
end

function BouncePad.new(x, y, w, h)
    local self = setmetatable({}, BouncePad)
    self.w = w or 58
    self.h = h or 24
    self.x = x
    self.y = y
    self.scaleX = 1.0
    self.scaleY = 1.0
    self.velX = 0
    self.velY = 0
    self.cooldown = 0
    self.image = getBouncePadImage()
    return self
end

function BouncePad:update(dt, players)
    if self.cooldown > 0 then
        self.cooldown = self.cooldown - dt
    end
    
    -- Spring animation physics
    local springForceY = (1.0 - self.scaleY) * 140
    self.velY = (self.velY + springForceY * dt) * 0.82
    self.scaleY = self.scaleY + self.velY * dt
    
    local springForceX = (1.0 - self.scaleX) * 140
    self.velX = (self.velX + springForceX * dt) * 0.82
    self.scaleX = self.scaleX + self.velX * dt
    
    -- Check collision with players
    if players and self.cooldown <= 0 then
        local padBox = {x = self.x, y = self.y - 10, w = self.w, h = self.h + 10}
        for _, player in ipairs(players) do
            if not player.teleporting.active and Utils.checkAABB(player, padBox) then
                if player.vy >= -50 and player.y + player.h <= self.y + 24 then
                    -- Trigger super high bounce! (4x normal jump height)
                    self.scaleY = 0.22
                    self.scaleX = 1.65
                    self.velY = 10.0
                    self.velX = -10.0
                    self.cooldown = 0.2
                    
                    player.vy = player.jumpForce * 2.0
                    player.onGround = false
                    player.isBouncing = true
                    player.scaleY = 1.6
                    player.scaleX = 0.65
                    
                    Sound.play("bounce")
                    Particles.addBouncePuff(self.x + self.w/2, self.y + 4)
                end
            end
        end
    end
end

function BouncePad:draw()
    local cx = self.x + self.w * 0.5
    local cy = self.y + self.h
    local img = self.image or getBouncePadImage()
    
    if img then
        local iw, ih = img:getDimensions()
        local baseScale = (self.w / iw) * 1.15
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.push()
        love.graphics.translate(cx, cy)
        love.graphics.scale(self.scaleX * baseScale, self.scaleY * baseScale)
        love.graphics.draw(img, 0, 0, 0, 1, 1, iw / 2, ih)
        love.graphics.pop()
    else
        -- Procedural vector fallback
        love.graphics.setColor(0.58, 0.35, 0.88, 1)
        love.graphics.push()
        love.graphics.translate(cx, cy)
        love.graphics.scale(self.scaleX, self.scaleY)
        love.graphics.arc("fill", "open", 0, 0, self.w/2, math.pi, math.pi * 2)
        love.graphics.setColor(0.3, 0.35, 0.85, 1)
        love.graphics.rectangle("fill", -self.w/2 - 4, -8, self.w + 8, 8, 4, 4)
        love.graphics.pop()
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return BouncePad

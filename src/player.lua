local Utils = require("src.utils")
local Constants = require("src.constants")
local Sound = require("src.sound")
local Particles = require("src.particles")

local Player = {}
Player.__index = Player

-- Cache images across player instances
local sharedImages = {}

local function getImage(path)
    if not path then return nil end
    if not sharedImages[path] then
        if love.filesystem.getInfo(path) then
            sharedImages[path] = love.graphics.newImage(path)
        end
    end
    return sharedImages[path]
end

function Player.new(id, x, y)
    local self = setmetatable({}, Player)
    self.id = id
    self.config = Constants.PLAYERS[id] or Constants.PLAYERS[1]

    self.w = 44
    self.h = 44
    self.x = x or 200
    self.y = y or 300
    self.vx = 0
    self.vy = 0

    self.baseSpeed = 320
    self.jumpForce = -760
    self.gravity = 1450

    self.onGround = false
    self.onSlope = false
    self.isBouncing = false
    self.facing = (id % 2 == 1) and 1 or -1

    self.isIt = false
    self.tagGraceTimer = 0
    self.timeAsIt = 0
    self.tagsMade = 0

    -- Animation state
    self.walkPhase = 0
    self.scaleX = 1.0
    self.scaleY = 1.0
    self.headbandAngle = 0
    self.headbandVel = 0
    self.coyoteTimer = 0
    self.jumpBufferTimer = 0
    self.dustTimer = 0
    self.blinkTimer = math.random(2, 6)
    self.isBlinking = false

    -- Teleportation animation
    self.teleporting = {
        active = false,
        timer = 0,
        duration = 0.45,
        startX = 0,
        startY = 0,
        targetX = 0,
        targetY = 0
    }

    -- Buffs
    self.buffs = {
        shield = false,
        bubble = 0,
        speed = 0
    }

    -- Load assets
    self.imgBody = getImage(self.config.bodyAsset)
    self.imgHeadband = getImage(self.config.headbandAsset)
    self.imgLeg = getImage("assets/leg.png")

    return self
end

function Player:reset(x, y)
    self.x = x or 200
    self.y = y or 300
    self.vx = 0
    self.vy = 0
    self.onGround = false
    self.onSlope = false
    self.isIt = false
    self.tagGraceTimer = 0
    self.timeAsIt = 0
    self.tagsMade = 0
    self.scaleX = 1.0
    self.scaleY = 1.0
    self.headbandAngle = 0
    self.headbandVel = 0
    self.coyoteTimer = 0
    self.jumpBufferTimer = 0
    self.teleporting.active = false
    self.buffs.shield = false
    self.buffs.bubble = 0
    self.buffs.speed = 0
end

function Player:setIt(isIt, giveGrace)
    self.isIt = isIt
    if isIt and giveGrace then
        self.tagGraceTimer = 1.5 -- 1.5s immunity grace period so players can scatter
    end
end

function Player:applyBuff(buffType, duration)
    duration = duration or 10
    if buffType == Constants.BUFF_TYPES.SHIELD then
        self.buffs.shield = true
    elseif buffType == Constants.BUFF_TYPES.BUBBLE then
        self.buffs.bubble = duration
    elseif buffType == Constants.BUFF_TYPES.SPEED then
        self.buffs.speed = duration
    end
    Particles.addBuffCollect(self.x + self.w/2, self.y + self.h/2, buffType)
    Sound.play("buff_collect")
end

function Player:teleportTo(destX, destY)
    if self.teleporting.active then return end
    self.teleporting.active = true
    self.teleporting.timer = 0
    self.teleporting.duration = 0.45
    self.teleporting.startX = self.x
    self.teleporting.startY = self.y
    self.teleporting.targetX = destX - self.w/2
    self.teleporting.targetY = destY - self.h

    self.vx = 0
    self.vy = 0

    Particles.addTeleportSparkles(self.x + self.w/2, self.y + self.h/2, 20, self.config.color)
    Sound.play("teleport")
end

function Player:handleInput(dt)
    if self.teleporting.active then return end

    local keys = self.config.keys
    local moveLeft = love.keyboard.isDown(keys.left)
    local moveRight = love.keyboard.isDown(keys.right)
    local jumpPressed = false

    -- Speed calculation
    local maxSpd = self.baseSpeed
    if self.buffs.speed > 0 then
        maxSpd = self.baseSpeed * 1.65
    end

    local accel = self.onGround and 2600 or 1700
    local decel = self.onGround and 2200 or 1200

    if moveLeft and not moveRight then
        self.vx = self.vx - accel * dt
        if self.vx < -maxSpd then self.vx = -maxSpd end
        self.facing = -1
    elseif moveRight and not moveLeft then
        self.vx = self.vx + accel * dt
        if self.vx > maxSpd then self.vx = maxSpd end
        self.facing = 1
    else
        if self.vx > 0 then
            self.vx = math.max(0, self.vx - decel * dt)
        elseif self.vx < 0 then
            self.vx = math.min(0, self.vx + decel * dt)
        end
    end

    -- Jump buffering check
    if self.jumpBufferTimer > 0 then
        self.jumpBufferTimer = self.jumpBufferTimer - dt
    end

    -- Perform jump if allowed
    if self.jumpBufferTimer > 0 and (self.onGround or self.coyoteTimer > 0) then
        self.vy = self.jumpForce
        self.onGround = false
        self.coyoteTimer = 0
        self.jumpBufferTimer = 0
        self.scaleY = 1.3
        self.scaleX = 0.75
        Particles.addJumpPuff(self.x + self.w/2, self.y + self.h)
    end

    -- Variable jump height: release jump key early to cut ascent
    if not self.isBouncing and not love.keyboard.isDown(keys.jump) and self.vy < -150 and self.buffs.bubble <= 0 then
        self.vy = self.vy * 0.75
    end
end

function Player:keypressed(key)
    if self.teleporting.active then return end
    if key == self.config.keys.jump then
        self.jumpBufferTimer = 0.15
        if self.onGround or self.coyoteTimer > 0 then
            self.vy = self.jumpForce
            self.onGround = false
            self.coyoteTimer = 0
            self.jumpBufferTimer = 0
            self.scaleY = 1.3
            self.scaleX = 0.75
            Particles.addJumpPuff(self.x + self.w/2, self.y + self.h)
        end
    end
end

function Player:update(dt, map)
    -- Accumulate stats
    if self.isIt then
        self.timeAsIt = self.timeAsIt + dt
    end
    if self.tagGraceTimer > 0 then
        self.tagGraceTimer = self.tagGraceTimer - dt
    end

    -- Buff timers
    if self.buffs.bubble > 0 then
        self.buffs.bubble = self.buffs.bubble - dt
    end
    if self.buffs.speed > 0 then
        self.buffs.speed = self.buffs.speed - dt
        -- Emit speed ghost trail
        if math.abs(self.vx) > 100 then
            Particles.addSpeedGhost(self.x, self.y, self.w, self.h, self)
        end
    end

    -- Teleport animation
    if self.teleporting.active then
        self.teleporting.timer = self.teleporting.timer + dt
        local prog = self.teleporting.timer / self.teleporting.duration
        Particles.addTeleportBeam(
            self.teleporting.startX + self.w/2,
            self.teleporting.startY + self.h/2,
            self.teleporting.targetX + self.w/2,
            self.teleporting.targetY + self.h/2,
            prog,
            self.config.color
        )
        if self.teleporting.timer >= self.teleporting.duration then
            self.teleporting.active = false
            self.x = self.teleporting.targetX
            self.y = self.teleporting.targetY
            self.vx = 0
            self.vy = -120
            self.scaleY = 1.25
            self.scaleX = 0.8
            Particles.addTeleportSparkles(self.x + self.w/2, self.y + self.h/2, 22, self.config.color)
        end
        return
    end

    -- Input handling
    self:handleInput(dt)

    -- Gravity & Float mechanics
    local grav = self.gravity
    if self.buffs.bubble > 0 then
        grav = -220 -- Gentle upward buoyant float
        if self.vy < -160 then self.vy = -160 end
    end
    self.vy = self.vy + grav * dt
    if self.vy > 900 then self.vy = 900 end

    if self.vy >= 0 or self.onGround then
        self.isBouncing = false
    end

    -- Coyote timer
    if self.onGround then
        self.coyoteTimer = 0.12
    else
        self.coyoteTimer = math.max(0, self.coyoteTimer - dt)
    end

    -- Movement integration & Collision resolution
    local prevX = self.x
    local prevY = self.y
    local prevOnGround = self.onGround

    -- Horizontal movement
    self.x = self.x + self.vx * dt

    -- Arena side boundaries
    local minX = 25
    local maxX = Constants.VIRTUAL_WIDTH - 25 - self.w
    if self.x < minX then
        self.x = minX
        self.vx = 0
    elseif self.x > maxX then
        self.x = maxX
        self.vx = 0
    end

    -- Horizontal platform collisions (walls)
    if map and map.platforms then
        for _, plat in ipairs(map.platforms) do
            if not plat.oneWay and Utils.checkAABB(self, plat) then
                if prevX + self.w <= plat.x then
                    self.x = plat.x - self.w
                    self.vx = 0
                elseif prevX >= plat.x + plat.w then
                    self.x = plat.x + plat.w
                    self.vx = 0
                end
            end
        end
    end

    -- Vertical movement
    self.y = self.y + self.vy * dt
    self.onGround = false
    self.onSlope = false

    -- Arena top boundary
    if self.y < 10 then
        self.y = 10
        if self.vy < 0 then self.vy = 0 end
    end

    -- Slopes / Ramps collision
    if map and map.slopes then
        local footX = self.x + self.w * 0.5
        local footY = self.y + self.h
        local prevFootY = prevY + self.h

        for _, slope in ipairs(map.slopes) do
            local sy = Utils.getSlopeY(slope, footX)
            if sy then
                -- Check if landing on or walking along the slope
                local tolerance = (self.onSlope or prevOnGround) and 24 or 14
                if footY >= sy - 2 and prevFootY <= sy + tolerance and self.vy >= -50 then
                    self.y = sy - self.h
                    self.vy = 0
                    self.onGround = true
                    self.onSlope = true
                    break
                end
            end
        end
    end

    -- Platform vertical collision
    if not self.onSlope and map and map.platforms then
        for _, plat in ipairs(map.platforms) do
            if Utils.checkAABB(self, plat) then
                if plat.oneWay then
                    -- One-way platform: only land when falling through from above
                    if prevY + self.h <= plat.y + 12 and self.vy >= 0 then
                        self.y = plat.y - self.h
                        self.vy = 0
                        self.onGround = true
                        break
                    end
                else
                    -- Solid platform
                    if prevY + self.h <= plat.y + 12 and self.vy >= 0 then
                        self.y = plat.y - self.h
                        self.vy = 0
                        self.onGround = true
                        break
                    elseif prevY >= plat.y + plat.h - 12 and self.vy < 0 then
                        self.y = plat.y + plat.h
                        self.vy = 0
                        break
                    end
                end
            end
        end
    end

    -- Land impact animation
    if self.onGround and not prevOnGround and prevY < self.y then
        self.scaleY = 0.72
        self.scaleX = 1.3
        Particles.addLandPuff(self.x + self.w/2, self.y + self.h)
    end

    -- Spring squash & stretch back to 1.0
    self.scaleX = Utils.lerp(self.scaleX, 1.0, dt * 14)
    self.scaleY = Utils.lerp(self.scaleY, 1.0, dt * 14)

    -- Headband wiggle physics
    local targetAngle = -self.vx * 0.0012 - self.vy * 0.0004
    if self.onGround and math.abs(self.vx) > 20 then
        targetAngle = targetAngle + math.sin(love.timer.getTime() * 18) * 0.32
    else
        targetAngle = targetAngle + math.sin(love.timer.getTime() * 8) * 0.12
    end

    local springForce = (targetAngle - self.headbandAngle) * 90
    self.headbandVel = (self.headbandVel + springForce * dt) * 0.82
    self.headbandAngle = self.headbandAngle + self.headbandVel * dt

    -- Walking leg cycle & dust
    if self.onGround and math.abs(self.vx) > 15 then
        self.walkPhase = self.walkPhase + dt * math.abs(self.vx) * 0.045
        self.dustTimer = self.dustTimer + dt
        if self.dustTimer >= 0.09 then
            self.dustTimer = 0
            Particles.addRunDust(self.x + self.w/2, self.y + self.h, self.facing)
        end
    else
        self.walkPhase = Utils.lerp(self.walkPhase, 0, dt * 8)
    end

    -- Eye blinking
    self.blinkTimer = self.blinkTimer - dt
    if self.blinkTimer <= 0 then
        if not self.isBlinking then
            self.isBlinking = true
            self.blinkTimer = 0.14
        else
            self.isBlinking = false
            self.blinkTimer = math.random(2, 6)
        end
    end
end

function Player:draw()
    if self.teleporting.active then return end

    local cx = self.x + self.w * 0.5
    local cy = self.y + self.h * 0.5
    local bottomY = self.y + self.h
    local time = love.timer.getTime()

    -- Grace period flashing
    if self.tagGraceTimer > 0 and math.floor(self.tagGraceTimer * 16) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.4)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Draw "IT" aura
    if self.isIt then
        local pulse = 1.0 + math.sin(time * 10) * 0.15
        love.graphics.setColor(1.0, 0.3, 0.3, 0.35)
        love.graphics.circle("fill", cx, cy, (self.w * 0.7) * pulse)
        love.graphics.setColor(1.0, 0.8, 0.2, 0.8)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", cx, cy, (self.w * 0.72) * pulse)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Draw Speed buff aura
    if self.buffs.speed > 0 then
        local spdPulse = 1.0 + math.sin(time * 16) * 0.12
        love.graphics.setColor(1.0, 0.6, 0.1, 0.3)
        love.graphics.circle("fill", cx, cy, (self.w * 0.65) * spdPulse)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Draw Legs
    local legWalkAngle = (self.onGround and math.abs(self.vx) > 15) and math.sin(self.walkPhase) * 0.45 or 0
    local legScale = 0.052
    local legW = 186 * legScale
    local legH = 248 * legScale

    local leftLegX = cx - 11
    local rightLegX = cx + 11
    local legBaseY = bottomY - 6

    if self.imgLeg then
        love.graphics.setColor(1, 1, 1, 1)
        -- Left Leg
        love.graphics.push()
        love.graphics.translate(leftLegX, legBaseY)
        love.graphics.rotate(legWalkAngle)
        love.graphics.draw(self.imgLeg, 0, 0, 0, legScale, legScale, 186/2, 10)
        love.graphics.pop()

        -- Right Leg
        love.graphics.push()
        love.graphics.translate(rightLegX, legBaseY)
        love.graphics.rotate(-legWalkAngle)
        love.graphics.draw(self.imgLeg, 0, 0, 0, legScale, legScale, 186/2, 10)
        love.graphics.pop()
    else
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", leftLegX - 3, legBaseY, 6, 8, 2, 2)
        love.graphics.rectangle("fill", rightLegX - 3, legBaseY, 6, 8, 2, 2)
    end

    -- Draw Headband tail (behind head)
    if self.imgHeadband then
        love.graphics.setColor(1, 1, 1, 1)
        local tailScale = 0.058
        local tailX = cx - (self.facing * (self.w * 0.38))
        local tailY = cy - 2
        local angle = self.headbandAngle * -self.facing

        love.graphics.push()
        love.graphics.translate(tailX, tailY)
        love.graphics.rotate(angle)
        love.graphics.scale(-self.facing * tailScale, tailScale)
        love.graphics.draw(self.imgHeadband, 0, 0, 0, 1, 1, 186 * 0.1, 249 * 0.1)
        love.graphics.pop()
    end

    -- Draw Main Body
    if self.imgBody then
        love.graphics.setColor(1, 1, 1, 1)
        local bodyScale = 0.058
        love.graphics.push()
        love.graphics.translate(cx, bottomY)
        love.graphics.scale(-self.facing * self.scaleX * bodyScale, self.scaleY * bodyScale)
        love.graphics.draw(self.imgBody, 0, 0, 0, 1, 1, 801/2, 803 - 20)
        love.graphics.pop()
    else
        love.graphics.setColor(self.config.color)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 10, 10)
    end

    -- Draw Shield Buff
    if self.buffs.shield then
        local shieldPulse = 1.0 + math.sin(time * 8) * 0.08
        local shieldR = (self.w * 0.72) * shieldPulse
        love.graphics.setColor(0.2, 0.85, 1.0, 0.35)
        love.graphics.circle("fill", cx, cy, shieldR)
        love.graphics.setColor(0.4, 0.95, 1.0, 0.85)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", cx, cy, shieldR)
        -- Shield rotating energy rings
        local rotAngle = time * 3
        local ox = math.cos(rotAngle) * (shieldR - 3)
        local oy = math.sin(rotAngle) * (shieldR - 3)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.circle("fill", cx + ox, cy + oy, 4)
        love.graphics.circle("fill", cx - ox, cy - oy, 4)
        love.graphics.setLineWidth(1)
    end

    -- Draw Bubble Buff
    if self.buffs.bubble > 0 then
        local bubbleR = self.w * 0.78
        love.graphics.setColor(0.5, 0.9, 1.0, 0.28)
        love.graphics.circle("fill", cx, cy, bubbleR)
        love.graphics.setColor(0.7, 0.95, 1.0, 0.8)
        love.graphics.setLineWidth(2.5)
        love.graphics.circle("line", cx, cy, bubbleR)
        -- Bubble shine
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.arc("line", "open", cx - 4, cy - 4, bubbleR * 0.65, -math.pi * 0.8, -math.pi * 0.3)
        love.graphics.setLineWidth(1)
    end

    -- Draw "IT" Arrow Indicator
    if self.isIt then
        local arrowBob = math.sin(time * 10) * 6
        local arrowX = cx
        local arrowY = self.y - 24 + arrowBob

        -- Downward triangular arrow matching reference
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.polygon("fill",
            arrowX - 12 + 2, arrowY - 14 + 2,
            arrowX + 12 + 2, arrowY - 14 + 2,
            arrowX + 2, arrowY + 2
        )

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.polygon("fill",
            arrowX - 12, arrowY - 14,
            arrowX + 12, arrowY - 14,
            arrowX, arrowY
        )
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.setLineWidth(2.5)
        love.graphics.polygon("line",
            arrowX - 12, arrowY - 14,
            arrowX + 12, arrowY - 14,
            arrowX, arrowY
        )
        love.graphics.setLineWidth(1)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Player

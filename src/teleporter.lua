local Utils = require("src.utils")
local Particles = require("src.particles")

local TeleporterSystem = {
    active = true,
    cooldownTimer = 0,
    respawnDuration = 12.0,
    appearTimer = 0,
    portalA = {x = 140, y = 450, w = 40, h = 40},
    portalB = {x = 975, y = 270, w = 40, h = 40},
    rotAngle = 0,
    img = nil
}

function TeleporterSystem.init()
    local path = "assets/teleporter.png"
    if love.filesystem.getInfo(path) then
        TeleporterSystem.img = love.graphics.newImage(path)
    end
end

function TeleporterSystem.reset(map)
    TeleporterSystem.active = true
    TeleporterSystem.cooldownTimer = 0
    TeleporterSystem.appearTimer = 0.5
    TeleporterSystem.respawnAtSpots(map)
end

function TeleporterSystem.respawnAtSpots(map)
    if not map or not map.teleportSpots or #map.teleportSpots < 2 then
        -- Default fallback positions
        TeleporterSystem.portalA.x = 160
        TeleporterSystem.portalA.y = 480
        TeleporterSystem.portalB.x = 980
        TeleporterSystem.portalB.y = 300
        return
    end
    
    local spots = {}
    for _, s in ipairs(map.teleportSpots) do
        table.insert(spots, s)
    end
    
    -- Pick first spot randomly
    local idxA = math.random(1, #spots)
    local spotA = table.remove(spots, idxA)
    
    -- Pick second spot that is at least 350px away
    local bestSpot = spots[1]
    local maxDist = 0
    for _, s in ipairs(spots) do
        local d = Utils.distance(spotA.x, spotA.y, s.x, s.y)
        if d > 350 then
            bestSpot = s
            break
        elseif d > maxDist then
            maxDist = d
            bestSpot = s
        end
    end
    
    TeleporterSystem.portalA.x = spotA.x - 20
    TeleporterSystem.portalA.y = spotA.y - 20
    TeleporterSystem.portalB.x = (bestSpot and bestSpot.x or 950) - 20
    TeleporterSystem.portalB.y = (bestSpot and bestSpot.y or 300) - 20
    
    TeleporterSystem.active = true
    TeleporterSystem.appearTimer = 0.5
    
    Particles.addTeleportSparkles(TeleporterSystem.portalA.x + 20, TeleporterSystem.portalA.y + 20, 20, {0.95, 0.4, 0.9})
    Particles.addTeleportSparkles(TeleporterSystem.portalB.x + 20, TeleporterSystem.portalB.y + 20, 20, {0.95, 0.4, 0.9})
end

function TeleporterSystem.update(dt, players, map)
    TeleporterSystem.rotAngle = (TeleporterSystem.rotAngle + dt * 2.5) % (math.pi * 2)
    
    if not TeleporterSystem.active then
        TeleporterSystem.cooldownTimer = TeleporterSystem.cooldownTimer - dt
        if TeleporterSystem.cooldownTimer <= 0 then
            TeleporterSystem.respawnAtSpots(map)
        end
        return
    end
    
    if TeleporterSystem.appearTimer > 0 then
        TeleporterSystem.appearTimer = TeleporterSystem.appearTimer - dt
    end
    
    -- Ambient sparkles around active portals
    if math.random() < 0.35 then
        local pA = TeleporterSystem.portalA
        local pB = TeleporterSystem.portalB
        Particles.addTeleportSparkles(pA.x + 20, pA.y + 20, 1, {0.95, 0.35, 0.85})
        Particles.addTeleportSparkles(pB.x + 20, pB.y + 20, 1, {0.95, 0.35, 0.85})
    end
    
    -- Check if any player enters portals
    if players and TeleporterSystem.active and TeleporterSystem.appearTimer <= 0 then
        for _, player in ipairs(players) do
            if not player.teleporting.active then
                local pA = TeleporterSystem.portalA
                local pB = TeleporterSystem.portalB
                
                -- Check Portal A
                if Utils.checkAABB(player, pA) then
                    player:teleportTo(pB.x + 20, pB.y + 40)
                    TeleporterSystem.triggerDisappear()
                    break
                -- Check Portal B
                elseif Utils.checkAABB(player, pB) then
                    player:teleportTo(pA.x + 20, pA.y + 40)
                    TeleporterSystem.triggerDisappear()
                    break
                end
            end
        end
    end
end

function TeleporterSystem.triggerDisappear()
    TeleporterSystem.active = false
    TeleporterSystem.cooldownTimer = TeleporterSystem.respawnDuration
    
    local pA = TeleporterSystem.portalA
    local pB = TeleporterSystem.portalB
    Particles.addTeleportSparkles(pA.x + 20, pA.y + 20, 24, {0.9, 0.3, 0.85})
    Particles.addTeleportSparkles(pB.x + 20, pB.y + 20, 24, {0.9, 0.3, 0.85})
end

local function drawPortal(portal, rotAngle, img, appearTimer)
    local cx = portal.x + 20
    local cy = portal.y + 20
    local scale = 1.0
    if appearTimer > 0 then
        scale = Utils.easeOutBack(1.0 - (appearTimer / 0.5))
    end
    
    local time = love.timer.getTime()
    local pulse = 1.0 + math.sin(time * 6) * 0.1
    
    -- Outer glow ring
    love.graphics.setColor(0.9, 0.3, 0.85, 0.35)
    love.graphics.circle("fill", cx, cy, 26 * pulse * scale)
    
    if img then
        local iw, ih = img:getDimensions()
        local s = (44 / iw) * scale * pulse
        love.graphics.setColor(1, 1, 1, 0.95)
        love.graphics.draw(img, cx, cy, rotAngle, s, s, iw / 2, ih / 2)
    else
        -- Procedural portal
        love.graphics.setColor(0.9, 0.25, 0.7, 0.9)
        love.graphics.circle("fill", cx, cy, 18 * scale)
        love.graphics.setColor(0.2, 0.8, 1.0, 0.9)
        love.graphics.circle("fill", cx, cy, 10 * scale)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function TeleporterSystem.draw()
    if not TeleporterSystem.active then return end
    
    local img = TeleporterSystem.img
    if not img and love.filesystem.getInfo("assets/teleporter.png") then
        TeleporterSystem.img = love.graphics.newImage("assets/teleporter.png")
        img = TeleporterSystem.img
    end
    
    drawPortal(TeleporterSystem.portalA, TeleporterSystem.rotAngle, img, TeleporterSystem.appearTimer)
    drawPortal(TeleporterSystem.portalB, -TeleporterSystem.rotAngle, img, TeleporterSystem.appearTimer)
end

return TeleporterSystem

local Utils = require("src.utils")

local Particles = {
    particles = {},
    ghosts = {},
    images = {}
}

function Particles.init()
    -- Load particle images safely
    local p1 = "assets/particle1.png"
    local p2 = "assets/particle2.png"
    local p3 = "assets/particle3.png"

    if love.filesystem.getInfo(p1) then Particles.images[1] = love.graphics.newImage(p1) end
    if love.filesystem.getInfo(p2) then Particles.images[2] = love.graphics.newImage(p2) end
    if love.filesystem.getInfo(p3) then Particles.images[3] = love.graphics.newImage(p3) end
end

function Particles.reset()
    Particles.particles = {}
    Particles.ghosts = {}
end

function Particles.add(p)
    table.insert(Particles.particles, {
        x = p.x or 0,
        y = p.y or 0,
        vx = p.vx or 0,
        vy = p.vy or 0,
        ax = p.ax or 0,
        ay = p.ay or 0,
        size = p.size or 10,
        sizeEnd = p.sizeEnd or 0,
        currentSize = p.size or 10,
        life = p.life or 0.5,
        maxLife = p.life or 0.5,
        color = p.color or {1, 1, 1, 1},
        colorEnd = p.colorEnd,
        rotation = p.rotation or 0,
        vrot = p.vrot or 0,
        shape = p.shape or "circle", -- "circle", "image", "star", "confetti", "ring"
        imageIdx = p.imageIdx or math.random(1, 3),
        fade = p.fade ~= false
    })
end

function Particles.addRunDust(x, y, facing)
    local imgIdx = math.random(1, 3)
    Particles.add({
        x = x - (facing or 1) * 8 + (math.random() * 6 - 3),
        y = y + (math.random() * 4 - 2),
        vx = -(facing or 1) * (math.random(30, 80)) + (math.random() * 20 - 10),
        vy = -math.random(10, 40),
        ay = 50,
        size = math.random(8, 14),
        sizeEnd = 2,
        life = math.random(25, 40) / 100,
        color = {0.9, 0.9, 0.95, 0.65},
        shape = Particles.images[imgIdx] and "image" or "circle",
        imageIdx = imgIdx,
        rotation = math.random() * math.pi * 2,
        vrot = (math.random() * 4 - 2)
    })
end

function Particles.addJumpPuff(x, y)
    for i = 1, 6 do
        local dir = (i % 2 == 0) and 1 or -1
        local imgIdx = math.random(1, 3)
        Particles.add({
            x = x + (math.random() * 16 - 8),
            y = y + (math.random() * 4 - 2),
            vx = dir * math.random(50, 140) + (math.random() * 30 - 15),
            vy = -math.random(15, 60),
            ay = 60,
            size = math.random(10, 18),
            sizeEnd = 2,
            life = math.random(30, 50) / 100,
            color = {0.92, 0.92, 0.98, 0.75},
            shape = Particles.images[imgIdx] and "image" or "circle",
            imageIdx = imgIdx,
            rotation = math.random() * math.pi * 2,
            vrot = (math.random() * 5 - 2.5)
        })
    end
end

function Particles.addLandPuff(x, y)
    for i = 1, 8 do
        local dir = (i % 2 == 0) and 1 or -1
        local imgIdx = math.random(1, 3)
        Particles.add({
            x = x + (math.random() * 20 - 10),
            y = y,
            vx = dir * math.random(60, 180),
            vy = -math.random(20, 70),
            ay = 80,
            size = math.random(10, 20),
            sizeEnd = 1,
            life = math.random(30, 55) / 100,
            color = {0.88, 0.88, 0.92, 0.75},
            shape = Particles.images[imgIdx] and "image" or "circle",
            imageIdx = imgIdx,
            rotation = math.random() * math.pi * 2,
            vrot = (math.random() * 4 - 2)
        })
    end
end

function Particles.addBouncePuff(x, y)
    -- Ring expansion
    Particles.add({
        x = x,
        y = y,
        size = 12,
        sizeEnd = 55,
        life = 0.4,
        color = {0.75, 0.4, 0.95, 0.8},
        shape = "ring"
    })
    -- Upward sparkle burst
    for i = 1, 12 do
        local angle = -math.pi * 0.5 + (math.random() * 1.2 - 0.6)
        local speed = math.random(120, 280)
        Particles.add({
            x = x + (math.random() * 30 - 15),
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            ay = 200,
            size = math.random(5, 10),
            sizeEnd = 1,
            life = math.random(40, 70) / 100,
            color = {0.85, 0.55, 1.0, 0.9},
            shape = "star"
        })
    end
end

function Particles.addTagBurst(x, y, color)
    color = color or {1, 0.3, 0.3}
    -- Shockwave ring
    Particles.add({
        x = x,
        y = y,
        size = 10,
        sizeEnd = 90,
        life = 0.45,
        color = {color[1], color[2], color[3], 0.9},
        shape = "ring"
    })
    -- Radiant particles
    for i = 1, 24 do
        local angle = (i / 24) * math.pi * 2 + (math.random() * 0.2 - 0.1)
        local speed = math.random(140, 340)
        Particles.add({
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            ay = 50,
            size = math.random(8, 16),
            sizeEnd = 0,
            life = math.random(45, 80) / 100,
            color = {color[1], color[2], color[3], 1},
            shape = "star",
            rotation = math.random() * math.pi * 2,
            vrot = (math.random() * 8 - 4)
        })
    end
end

function Particles.addShieldBreak(x, y)
    for i = 1, 20 do
        local angle = (i / 20) * math.pi * 2 + math.random() * 0.3
        local speed = math.random(100, 300)
        Particles.add({
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            ay = 180,
            size = math.random(6, 14),
            sizeEnd = 0,
            life = math.random(40, 75) / 100,
            color = {0.2, 0.85, 1.0, 0.95},
            shape = "star"
        })
    end
end

function Particles.addBuffCollect(x, y, buffType)
    local col = {1, 0.85, 0.2}
    if buffType == "SHIELD" then col = {0.2, 0.8, 1.0}
    elseif buffType == "BUBBLE" then col = {0.4, 0.9, 0.95}
    elseif buffType == "SPEED" then col = {1.0, 0.5, 0.1} end

    Particles.add({
        x = x,
        y = y,
        size = 8,
        sizeEnd = 65,
        life = 0.4,
        color = {col[1], col[2], col[3], 0.85},
        shape = "ring"
    })
    for i = 1, 16 do
        local angle = (i / 16) * math.pi * 2
        local speed = math.random(80, 220)
        Particles.add({
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            ay = 40,
            size = math.random(6, 12),
            sizeEnd = 1,
            life = math.random(35, 65) / 100,
            color = {col[1], col[2], col[3], 0.95},
            shape = "star"
        })
    end
end

function Particles.addTeleportSparkles(x, y, count, color)
    count = count or 8
    color = color or {0.95, 0.3, 0.9}
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local dist = math.random(10, 36)
        Particles.add({
            x = x + math.cos(angle) * dist,
            y = y + math.sin(angle) * dist,
            vx = math.cos(angle + math.pi/2) * math.random(40, 100),
            vy = math.sin(angle + math.pi/2) * math.random(40, 100) - 20,
            size = math.random(4, 9),
            sizeEnd = 0,
            life = math.random(30, 60) / 100,
            color = {color[1], color[2], color[3], 0.85},
            shape = "star"
        })
    end
end

function Particles.addTeleportBeam(x1, y1, x2, y2, progress, color)
    color = color or {0.95, 0.4, 0.85}
    local t = Utils.clamp(progress, 0, 1)
    -- Compute bezier curve control point arching upwards
    local midX = (x1 + x2) * 0.5
    local midY = math.min(y1, y2) - 100
    
    local px = (1 - t)^2 * x1 + 2 * (1 - t) * t * midX + t^2 * x2
    local py = (1 - t)^2 * y1 + 2 * (1 - t) * t * midY + t^2 * y2
    
    for i = 1, 4 do
        Particles.add({
            x = px + (math.random() * 16 - 8),
            y = py + (math.random() * 16 - 8),
            vx = (math.random() * 40 - 20),
            vy = (math.random() * 40 - 20),
            size = math.random(6, 12),
            sizeEnd = 1,
            life = 0.3,
            color = {color[1], color[2], color[3], 0.9},
            shape = "star"
        })
    end
end

function Particles.addSpeedGhost(x, y, w, h, player)
    table.insert(Particles.ghosts, {
        x = x,
        y = y,
        w = w,
        h = h,
        facing = player.facing or 1,
        color = player.config.color,
        life = 0.25,
        maxLife = 0.25,
        scaleX = player.scaleX or 1,
        scaleY = player.scaleY or 1,
        bodyAsset = player.config.bodyAsset
    })
end

function Particles.addConfettiPiece(x, y)
    local colors = {
        {1.0, 0.3, 0.3},
        {0.3, 0.6, 1.0},
        {1.0, 0.85, 0.1},
        {0.25, 0.9, 0.35},
        {0.9, 0.35, 0.9},
        {0.2, 0.9, 0.85}
    }
    local col = colors[math.random(1, #colors)]
    Particles.add({
        x = x or math.random(50, 1230),
        y = y or -20,
        vx = math.random(-60, 60),
        vy = math.random(80, 220),
        ay = 40,
        size = math.random(6, 12),
        sizeEnd = math.random(6, 12),
        life = math.random(250, 450) / 100,
        color = {col[1], col[2], col[3], 1.0},
        shape = "confetti",
        rotation = math.random() * math.pi * 2,
        vrot = (math.random() * 6 - 3)
    })
end

function Particles.update(dt)
    -- Update particles
    for i = #Particles.particles, 1, -1 do
        local p = Particles.particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(Particles.particles, i)
        else
            p.vx = p.vx + p.ax * dt
            p.vy = p.vy + p.ay * dt
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.rotation = p.rotation + p.vrot * dt
            
            local progress = 1 - (p.life / p.maxLife)
            p.currentSize = Utils.lerp(p.size, p.sizeEnd, progress)
        end
    end

    -- Update ghosts
    for i = #Particles.ghosts, 1, -1 do
        local g = Particles.ghosts[i]
        g.life = g.life - dt
        if g.life <= 0 then
            table.remove(Particles.ghosts, i)
        end
    end
end

function Particles.draw()
    -- Draw ghosts
    for _, g in ipairs(Particles.ghosts) do
        local alpha = (g.life / g.maxLife) * 0.4
        love.graphics.setColor(g.color[1], g.color[2], g.color[3], alpha)
        love.graphics.rectangle("fill", g.x, g.y, g.w, g.h, 8, 8)
    end

    -- Draw particles
    for _, p in ipairs(Particles.particles) do
        local alpha = p.color[4] or 1
        if p.fade then
            alpha = alpha * (p.life / p.maxLife)
        end
        
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        
        if p.shape == "image" and Particles.images[p.imageIdx] then
            local img = Particles.images[p.imageIdx]
            local iw, ih = img:getDimensions()
            local s = (p.currentSize * 2) / iw
            love.graphics.draw(img, p.x, p.y, p.rotation, s, s, iw / 2, ih / 2)
        elseif p.shape == "circle" then
            love.graphics.circle("fill", p.x, p.y, math.max(1, p.currentSize))
        elseif p.shape == "ring" then
            love.graphics.setLineWidth(3)
            love.graphics.circle("line", p.x, p.y, math.max(1, p.currentSize))
            love.graphics.setLineWidth(1)
        elseif p.shape == "star" then
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(p.rotation)
            local s = p.currentSize
            love.graphics.polygon("fill", 
                0, -s, 
                s * 0.3, -s * 0.3, 
                s, 0, 
                s * 0.3, s * 0.3, 
                0, s, 
                -s * 0.3, s * 0.3, 
                -s, 0, 
                -s * 0.3, -s * 0.3
            )
            love.graphics.pop()
        elseif p.shape == "confetti" then
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(p.rotation)
            local s = p.currentSize
            love.graphics.rectangle("fill", -s/2, -s/4, s, s/2, 2, 2)
            love.graphics.pop()
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return Particles

local Utils = require("src.utils")
local Constants = require("src.constants")
local Particles = require("src.particles")
local Sound = require("src.sound")

local Buffs = {
    enabled = true,
    items = {},
    spawnTimer = 6.0,
    spawnInterval = 12.0,
    matchDuration = 120
}

function Buffs.reset(settings)
    Buffs.items = {}
    Buffs.spawnTimer = 4.0
    if settings then
        Buffs.enabled = settings.buffsEnabled ~= false
        Buffs.matchDuration = settings.gameDuration or 120
    end
end

function Buffs.getBuffDuration()
    if Buffs.matchDuration <= 60 then
        return 6.0
    elseif Buffs.matchDuration <= 120 then
        return 10.0
    else
        return 14.0
    end
end

function Buffs.spawnRandom(map)
    if not map or not map.buffSpots or #map.buffSpots == 0 then return end
    if #Buffs.items >= 2 then return end
    
    local types = {Constants.BUFF_TYPES.SHIELD, Constants.BUFF_TYPES.BUBBLE, Constants.BUFF_TYPES.SPEED}
    local chosenType = types[math.random(1, #types)]
    
    local spot = map.buffSpots[math.random(1, #map.buffSpots)]
    
    table.insert(Buffs.items, {
        type = chosenType,
        x = spot.x - 16,
        y = spot.y - 32,
        w = 32,
        h = 32,
        bobPhase = math.random() * math.pi * 2,
        life = 18.0,
        appearScale = 0.0
    })
    
    Particles.addBuffCollect(spot.x, spot.y - 16, chosenType)
end

function Buffs.update(dt, players, map)
    if not Buffs.enabled then return end
    
    Buffs.spawnTimer = Buffs.spawnTimer - dt
    if Buffs.spawnTimer <= 0 then
        Buffs.spawnTimer = Buffs.spawnInterval + math.random(-2, 3)
        Buffs.spawnRandom(map)
    end
    
    local duration = Buffs.getBuffDuration()
    
    for i = #Buffs.items, 1, -1 do
        local item = Buffs.items[i]
        item.life = item.life - dt
        item.appearScale = math.min(1.0, item.appearScale + dt * 4.0)
        
        if item.life <= 0 then
            table.remove(Buffs.items, i)
        else
            -- Check player collection
            local collected = false
            if players then
                local itemBox = {x = item.x, y = item.y, w = item.w, h = item.h}
                for _, player in ipairs(players) do
                    if not player.teleporting.active and Utils.checkAABB(player, itemBox) then
                        player:applyBuff(item.type, duration)
                        table.remove(Buffs.items, i)
                        collected = true
                        break
                    end
                end
            end
        end
    end
end

local function drawBuffIcon(item)
    local time = love.timer.getTime()
    local cx = item.x + item.w * 0.5
    local cy = item.y + item.h * 0.5 + math.sin(time * 4 + item.bobPhase) * 6
    local s = Utils.easeOutBack(item.appearScale)
    
    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.scale(s, s)
    
    local pulse = 1.0 + math.sin(time * 6 + item.bobPhase) * 0.08
    
    if item.type == Constants.BUFF_TYPES.SHIELD then
        -- Shield: Cyan orb with shield crest
        love.graphics.setColor(0.1, 0.8, 1.0, 0.35)
        love.graphics.circle("fill", 0, 0, 18 * pulse)
        love.graphics.setColor(0.2, 0.9, 1.0, 0.9)
        love.graphics.circle("fill", 0, 0, 14)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.polygon("fill", 
            0, -8, 
            7, -5, 
            6, 4, 
            0, 8, 
            -6, 4, 
            -7, -5
        )
    elseif item.type == Constants.BUFF_TYPES.BUBBLE then
        -- Bubble: Iridescent glowing bubble
        love.graphics.setColor(0.3, 0.85, 1.0, 0.4)
        love.graphics.circle("fill", 0, 0, 18 * pulse)
        love.graphics.setColor(0.5, 0.95, 1.0, 0.85)
        love.graphics.circle("fill", 0, 0, 14)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.circle("fill", -4, -4, 4)
    elseif item.type == Constants.BUFF_TYPES.SPEED then
        -- Speed: Golden lightning bolt orb
        love.graphics.setColor(1.0, 0.65, 0.1, 0.4)
        love.graphics.circle("fill", 0, 0, 18 * pulse)
        love.graphics.setColor(1.0, 0.75, 0.15, 0.9)
        love.graphics.circle("fill", 0, 0, 14)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.polygon("fill", 
            2, -9, 
            -6, 1, 
            0, 1, 
            -2, 9, 
            6, -1, 
            0, -1
        )
    end
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Buffs.draw()
    if not Buffs.enabled then return end
    for _, item in ipairs(Buffs.items) do
        drawBuffIcon(item)
    end
end

return Buffs

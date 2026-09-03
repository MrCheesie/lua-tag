local Constants = require("src.constants")
local Utils = require("src.utils")

local Camera = {
    x = Constants.VIRTUAL_WIDTH * 0.5,
    y = Constants.VIRTUAL_HEIGHT * 0.5,
    zoom = 1.0,
    
    targetX = Constants.VIRTUAL_WIDTH * 0.5,
    targetY = Constants.VIRTUAL_HEIGHT * 0.5,
    targetZoom = 1.0,
    
    minZoom = 1.0,
    maxZoom = 1.55,
    paddingX = 140,
    paddingY = 130,
    smoothSpeed = 6.0
}

function Camera.reset()
    Camera.x = Constants.VIRTUAL_WIDTH * 0.5
    Camera.y = Constants.VIRTUAL_HEIGHT * 0.5
    Camera.zoom = 1.0
    Camera.targetX = Camera.x
    Camera.targetY = Camera.y
    Camera.targetZoom = 1.0
end

function Camera.update(dt, players)
    if not players or #players == 0 then
        Camera.reset()
        return
    end
    
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local activeCount = 0
    
    for _, p in ipairs(players) do
        local px = p.x + p.w * 0.5
        local py = p.y + p.h * 0.5
        if px < minX then minX = px end
        if px > maxX then maxX = px end
        if py < minY then minY = py end
        if py > maxY then maxY = py end
        activeCount = activeCount + 1
    end
    
    if activeCount == 0 then return end
    
    -- Center of player bounding box
    local centerX = (minX + maxX) * 0.5
    local centerY = (minY + maxY) * 0.5
    
    -- Size of player bounding box plus padding
    local bboxW = (maxX - minX) + Camera.paddingX * 2
    local bboxH = (maxY - minY) + Camera.paddingY * 2
    
    -- Scale required to fit all players inside 1280x720 screen
    local zoomX = Constants.VIRTUAL_WIDTH / math.max(1, bboxW)
    local zoomY = Constants.VIRTUAL_HEIGHT / math.max(1, bboxH)
    local desiredZoom = math.min(zoomX, zoomY)
    
    -- Clamp zoom between 1.0 (full map) and maxZoom (1.55 close-up)
    Camera.targetZoom = Utils.clamp(desiredZoom, Camera.minZoom, Camera.maxZoom)
    
    -- Clamp camera center so camera view never extends outside map boundaries (0, 0, 1280, 720)
    local halfW = (Constants.VIRTUAL_WIDTH / Camera.targetZoom) * 0.5
    local halfH = (Constants.VIRTUAL_HEIGHT / Camera.targetZoom) * 0.5
    
    Camera.targetX = Utils.clamp(centerX, halfW, Constants.VIRTUAL_WIDTH - halfW)
    Camera.targetY = Utils.clamp(centerY, halfH, Constants.VIRTUAL_HEIGHT - halfH)
    
    -- Smooth lerp towards target
    local lerpFactor = math.min(1.0, dt * Camera.smoothSpeed)
    Camera.x = Utils.lerp(Camera.x, Camera.targetX, lerpFactor)
    Camera.y = Utils.lerp(Camera.y, Camera.targetY, lerpFactor)
    Camera.zoom = Utils.lerp(Camera.zoom, Camera.targetZoom, lerpFactor)
end

function Camera.attach()
    love.graphics.push()
    love.graphics.translate(Constants.VIRTUAL_WIDTH * 0.5, Constants.VIRTUAL_HEIGHT * 0.5)
    love.graphics.scale(Camera.zoom, Camera.zoom)
    love.graphics.translate(-Camera.x, -Camera.y)
end

function Camera.detach()
    love.graphics.pop()
end

return Camera

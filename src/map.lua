local Utils = require("src.utils")
local Constants = require("src.constants")
local BouncePad = require("src.bouncepad")

local Map = {}
Map.__index = Map

local bgImages = {}

local function getBgImage(mapType)
    local filenames = {
        classic = {"assets/classic_map_bg.png", "classic_map_bg.png"},
        snow = {"assets/snow_map_bg.png", "snow_map_bg.png"},
        desert = {"assets/desert_map_bg.png", "desert_map_bg.png"}
    }
    if not bgImages[mapType] then
        for _, path in ipairs(filenames[mapType] or {}) do
            if love.filesystem.getInfo(path) then
                bgImages[mapType] = love.graphics.newImage(path)
                break
            end
        end
    end
    return bgImages[mapType]
end

function Map.load(mapType)
    local self = setmetatable({}, Map)
    self.type = mapType or Constants.MAPS.CLASSIC
    self.platforms = {}
    self.slopes = {}
    self.bouncePads = {}
    self.teleportSpots = {}
    self.buffSpots = {}
    self.spawnPoints = {}
    self.decorations = {}
    
    self.bgImage = getBgImage(self.type)
    
    if self.type == Constants.MAPS.CLASSIC then
        self:initClassic()
    elseif self.type == Constants.MAPS.SNOW then
        self:initSnow()
    elseif self.type == Constants.MAPS.DESERT then
        self:initDesert()
    else
        self:initClassic()
    end
    
    return self
end

-- -------------------------------------------------------------
-- CLASSIC MAP DEFINITION
-- -------------------------------------------------------------
function Map:initClassic()
    self.theme = {
        skyTop = {0.22, 0.56, 0.92},
        skyBottom = {0.40, 0.75, 0.98},
        platBody = {0.91, 0.17, 0.47},
        platTop = {0.19, 0.87, 0.23},
        border = {0.95, 0.22, 0.52}
    }
    
    -- Bottom Floor
    table.insert(self.platforms, {x = 24, y = 650, w = 1232, h = 70, oneWay = false})
    
    -- Tier 1 Platforms (Lower tier - spacious)
    table.insert(self.platforms, {x = 60, y = 540, w = 240, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 420, y = 540, w = 280, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 820, y = 540, w = 260, h = 18, oneWay = true})
    
    -- Tier 2 Platforms (Mid tier)
    table.insert(self.platforms, {x = 180, y = 400, w = 260, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 680, y = 400, w = 300, h = 18, oneWay = true})
    
    -- Tier 3 Platforms (High tier)
    table.insert(self.platforms, {x = 80, y = 260, w = 240, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 460, y = 250, w = 340, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 940, y = 260, w = 240, h = 18, oneWay = true})
    
    -- Slopes
    table.insert(self.slopes, {x1 = 980, y1 = 400, x2 = 1120, y2 = 540})
    
    -- Bounce Pads (On floor, launching 4x high up to top tier)
    table.insert(self.bouncePads, BouncePad.new(1150, 642, 54, 20))
    table.insert(self.bouncePads, BouncePad.new(80, 642, 54, 20))
    
    -- Teleport spots
    self.teleportSpots = {
        {x = 180, y = 520},
        {x = 1060, y = 240},
        {x = 630, y = 230},
        {x = 900, y = 520},
        {x = 300, y = 380}
    }
    
    -- Buff spots
    self.buffSpots = {
        {x = 550, y = 230},
        {x = 300, y = 380},
        {x = 940, y = 520},
        {x = 200, y = 520},
        {x = 820, y = 380}
    }
    
    -- Spawn points
    self.spawnPoints = {
        {x = 140, y = 500},
        {x = 1080, y = 500},
        {x = 630, y = 210},
        {x = 300, y = 360}
    }
    
    -- Scenery decorations
    self.decorations = {
        {type = "tree_classic", x = 120, y = 650, size = 1.0},
        {type = "tree_classic", x = 200, y = 260, size = 0.8},
        {type = "tree_classic", x = 630, y = 250, size = 0.9},
        {type = "tree_classic", x = 1040, y = 260, size = 0.75},
        {type = "flower", x = 320, y = 650, color = {1, 0.85, 0.2}},
        {type = "flower", x = 860, y = 650, color = {1, 0.4, 0.7}},
        {type = "flower", x = 520, y = 540, color = {1, 0.4, 0.7}},
        {type = "crates", x = 860, y = 400}
    }
end

-- -------------------------------------------------------------
-- SNOW MAP DEFINITION
-- -------------------------------------------------------------
function Map:initSnow()
    self.theme = {
        skyTop = {0.58, 0.59, 0.93},
        skyBottom = {0.70, 0.71, 0.96},
        platBody = {0.65, 0.65, 0.95},
        platTop = {0.93, 0.93, 0.99},
        border = {0.75, 0.75, 0.98}
    }
    
    -- Bottom Floor
    table.insert(self.platforms, {x = 24, y = 650, w = 1232, h = 70, oneWay = false})
    
    -- Spacious Tier 1 (Lower)
    table.insert(self.platforms, {x = 240, y = 530, w = 280, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 680, y = 530, w = 280, h = 18, oneWay = true})
    
    -- Spacious Tier 2 (Mid)
    table.insert(self.platforms, {x = 80, y = 390, w = 240, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 480, y = 390, w = 320, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 920, y = 390, w = 240, h = 18, oneWay = true})
    
    -- Spacious Tier 3 (High)
    table.insert(self.platforms, {x = 220, y = 250, w = 280, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 720, y = 250, w = 300, h = 18, oneWay = true})
    
    -- Slopes
    table.insert(self.slopes, {x1 = 340, y1 = 390, x2 = 480, y2 = 530})
    table.insert(self.slopes, {x1 = 800, y1 = 390, x2 = 940, y2 = 250})
    
    -- Bounce Pads
    table.insert(self.bouncePads, BouncePad.new(105, 642, 54, 20))
    table.insert(self.bouncePads, BouncePad.new(1140, 642, 54, 20))
    
    -- Teleport spots
    self.teleportSpots = {
        {x = 360, y = 230},
        {x = 860, y = 230},
        {x = 640, y = 370},
        {x = 380, y = 510},
        {x = 820, y = 510}
    }
    
    -- Buff spots
    self.buffSpots = {
        {x = 360, y = 230},
        {x = 640, y = 370},
        {x = 860, y = 230},
        {x = 380, y = 510},
        {x = 820, y = 510}
    }
    
    -- Spawn points
    self.spawnPoints = {
        {x = 120, y = 600},
        {x = 1150, y = 600},
        {x = 360, y = 210},
        {x = 860, y = 210}
    }
    
    -- Scenery decorations
    self.decorations = {
        {type = "snowman", x = 360, y = 250},
        {type = "snowman", x = 1060, y = 650},
        {type = "candy_cane", x = 180, y = 390},
        {type = "candy_cane", x = 980, y = 390},
        {type = "pine_snow", x = 160, y = 650, size = 1.0},
        {type = "pine_snow", x = 560, y = 390, size = 0.8},
        {type = "pine_snow", x = 990, y = 650, size = 0.85}
    }
end

-- -------------------------------------------------------------
-- DESERT MAP DEFINITION
-- -------------------------------------------------------------
function Map:initDesert()
    self.theme = {
        skyTop = {0.25, 0.88, 0.65},
        skyBottom = {0.98, 0.63, 0.48},
        platBody = {0.92, 0.75, 0.40},
        platTop = {0.98, 0.85, 0.52},
        border = {0.95, 0.78, 0.45}
    }
    
    -- Bottom Floor
    table.insert(self.platforms, {x = 24, y = 650, w = 1232, h = 70, oneWay = false})
    
    -- Tier 1 (Lower)
    table.insert(self.platforms, {x = 80, y = 520, w = 280, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 900, y = 520, w = 280, h = 18, oneWay = true})
    
    -- Tier 2 (Mid)
    table.insert(self.platforms, {x = 140, y = 380, w = 240, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 480, y = 380, w = 300, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 880, y = 380, w = 240, h = 18, oneWay = true})
    
    -- Tier 3 (High)
    table.insert(self.platforms, {x = 60, y = 240, w = 220, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 520, y = 240, w = 220, h = 18, oneWay = true})
    table.insert(self.platforms, {x = 980, y = 240, w = 220, h = 18, oneWay = true})
    
    -- Slopes
    table.insert(self.slopes, {x1 = 280, y1 = 380, x2 = 420, y2 = 520})
    table.insert(self.slopes, {x1 = 820, y1 = 520, x2 = 960, y2 = 380})
    
    -- Bounce Pad
    table.insert(self.bouncePads, BouncePad.new(613, 642, 54, 20))
    table.insert(self.bouncePads, BouncePad.new(1150, 642, 54, 20))
    
    -- Teleport spots
    self.teleportSpots = {
        {x = 630, y = 220},
        {x = 220, y = 500},
        {x = 1040, y = 500},
        {x = 260, y = 360},
        {x = 1000, y = 360}
    }
    
    -- Buff spots
    self.buffSpots = {
        {x = 630, y = 220},
        {x = 630, y = 360},
        {x = 220, y = 500},
        {x = 1040, y = 500},
        {x = 170, y = 220}
    }
    
    -- Spawn points
    self.spawnPoints = {
        {x = 100, y = 600},
        {x = 1150, y = 600},
        {x = 630, y = 210},
        {x = 630, y = 350}
    }
    
    -- Scenery decorations
    self.decorations = {
        {type = "sphinx", x = 630, y = 240},
        {type = "pyramid", x = 820, y = 520, size = 1.0},
        {type = "pyramid", x = 100, y = 520, size = 0.5},
        {type = "cactus", x = 510, y = 380, size = 1.0},
        {type = "cactus", x = 910, y = 380, size = 0.9},
        {type = "palm", x = 150, y = 380, size = 0.9},
        {type = "palm", x = 1010, y = 240, size = 1.0},
        {type = "palm", x = 300, y = 650, size = 1.0},
        {type = "palm", x = 1090, y = 650, size = 1.0}
    }
end

function Map:update(dt, players)
    for _, pad in ipairs(self.bouncePads) do
        pad:update(dt, players)
    end
end

-- -------------------------------------------------------------
-- DRAW SCENERY DECORATIONS
-- -------------------------------------------------------------
local function drawClassicTree(x, y, s)
    s = s or 1
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(s, s)
    -- Magenta trunk with branches
    love.graphics.setColor(0.82, 0.12, 0.42, 1)
    love.graphics.rectangle("fill", -9, -70, 18, 70, 5, 5)
    love.graphics.polygon("fill", -7, -45, -25, -60, -22, -68, -4, -50)
    love.graphics.polygon("fill", 7, -35, 25, -48, 22, -56, 4, -40)
    -- Green canopy clumps
    love.graphics.setColor(0.18, 0.88, 0.28, 1)
    love.graphics.rectangle("fill", -32, -100, 64, 40, 12, 12)
    love.graphics.rectangle("fill", -42, -80, 24, 25, 8, 8)
    love.graphics.rectangle("fill", 18, -68, 24, 25, 8, 8)
    love.graphics.pop()
end

local function drawSnowman(x, y)
    love.graphics.push()
    love.graphics.translate(x, y)
    -- Body
    love.graphics.setColor(0.95, 0.95, 1, 1)
    love.graphics.circle("fill", 0, -12, 14)
    love.graphics.circle("fill", 0, -32, 10)
    -- Hat
    love.graphics.setColor(0.2, 0.2, 0.25, 1)
    love.graphics.rectangle("fill", -10, -42, 20, 4, 2, 2)
    love.graphics.rectangle("fill", -7, -54, 14, 12, 2, 2)
    -- Red Scarf
    love.graphics.setColor(0.9, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", -8, -25, 16, 5, 2, 2)
    love.graphics.polygon("fill", 3, -24, 7, -14, 11, -14, 8, -24)
    -- Orange carrot nose & eyes
    love.graphics.setColor(1.0, 0.5, 0.1, 1)
    love.graphics.polygon("fill", 0, -33, 7, -31, 0, -29)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.circle("fill", -3, -34, 1.5)
    love.graphics.circle("fill", 3, -34, 1.5)
    love.graphics.pop()
end

local function drawCandyCane(x, y)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.setColor(0.95, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", -4, -40, 8, 40, 3, 3)
    love.graphics.arc("fill", "open", 2, -40, 6, math.pi, math.pi * 2)
    -- White stripes
    love.graphics.setColor(1, 1, 1, 0.9)
    for i = 1, 4 do
        love.graphics.rectangle("fill", -4, -38 + i * 8, 8, 3)
    end
    love.graphics.pop()
end

local function drawCactus(x, y, s)
    s = s or 1
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(s, s)
    love.graphics.setColor(0.15, 0.72, 0.42, 1)
    -- Main trunk
    love.graphics.rectangle("fill", -6, -45, 12, 45, 5, 5)
    -- Left arm
    love.graphics.rectangle("fill", -18, -32, 14, 6, 3, 3)
    love.graphics.rectangle("fill", -18, -42, 6, 14, 3, 3)
    -- Right arm
    love.graphics.rectangle("fill", 4, -24, 14, 6, 3, 3)
    love.graphics.rectangle("fill", 12, -34, 6, 14, 3, 3)
    love.graphics.pop()
end

local function drawPalmTree(x, y, s)
    s = s or 1
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(s, s)
    -- Curved trunk
    love.graphics.setColor(0.72, 0.45, 0.25, 1)
    love.graphics.polygon("fill", -5, 0, 5, 0, 8, -55, 0, -55)
    -- Green fronds
    love.graphics.setColor(0.18, 0.75, 0.35, 1)
    love.graphics.ellipse("fill", -16, -58, 18, 6)
    love.graphics.ellipse("fill", 16, -58, 18, 6)
    love.graphics.ellipse("fill", -10, -66, 15, 5)
    love.graphics.ellipse("fill", 10, -66, 15, 5)
    love.graphics.ellipse("fill", 0, -68, 8, 14)
    love.graphics.pop()
end

local function drawSphinx(x, y)
    love.graphics.push()
    love.graphics.translate(x, y)
    -- Golden pillar
    love.graphics.setColor(0.92, 0.78, 0.42, 1)
    love.graphics.rectangle("fill", -10, 0, 20, 60, 4, 4)
    -- Sphinx body & head
    love.graphics.setColor(0.95, 0.75, 0.38, 1)
    love.graphics.rectangle("fill", -22, -28, 44, 28, 6, 6)
    love.graphics.setColor(0.9, 0.65, 0.3, 1)
    love.graphics.rectangle("fill", -12, -44, 24, 20, 5, 5)
    -- Striped headcloth
    love.graphics.setColor(0.85, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", -14, -46, 28, 6, 2, 2)
    love.graphics.pop()
end

local function drawPyramid(x, y, s)
    s = s or 1
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(s, s)
    love.graphics.setColor(0.92, 0.72, 0.35, 1)
    love.graphics.polygon("fill", -28, 0, 0, -35, 28, 0)
    love.graphics.setColor(0.85, 0.62, 0.25, 1)
    love.graphics.polygon("fill", 0, -35, 28, 0, 0, 0)
    love.graphics.pop()
end

-- -------------------------------------------------------------
-- DRAW BACKGROUND & MAP
-- -------------------------------------------------------------
function Map:drawBackground()
    -- Check if custom background image exists
    local bg = self.bgImage or getBgImage(self.type)
    if bg then
        love.graphics.setColor(1, 1, 1, 1)
        local bw, bh = bg:getDimensions()
        love.graphics.draw(bg, 0, 0, 0, Constants.VIRTUAL_WIDTH / bw, Constants.VIRTUAL_HEIGHT / bh)
        return
    end
    
    -- Procedural Background Art
    local theme = self.theme
    
    -- Sky gradient
    local numBands = 24
    local bandH = Constants.VIRTUAL_HEIGHT / numBands
    for i = 0, numBands - 1 do
        local t = i / (numBands - 1)
        local r = Utils.lerp(theme.skyTop[1], theme.skyBottom[1], t)
        local g = Utils.lerp(theme.skyTop[2], theme.skyBottom[2], t)
        local b = Utils.lerp(theme.skyTop[3], theme.skyBottom[3], t)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i * bandH, Constants.VIRTUAL_WIDTH, bandH + 1)
    end
    
    -- Scenery Backdrops per Map Type
    if self.type == Constants.MAPS.CLASSIC then
        -- Distant temple columns and mountain silhouettes
        love.graphics.setColor(0.32, 0.58, 0.88, 0.45)
        love.graphics.rectangle("fill", 280, 320, 140, 340, 16, 16)
        love.graphics.rectangle("fill", 650, 340, 150, 320, 16, 16)
        love.graphics.rectangle("fill", 1080, 360, 140, 300, 16, 16)
        love.graphics.circle("fill", 180, 520, 240)
        love.graphics.circle("fill", 850, 540, 280)
    elseif self.type == Constants.MAPS.SNOW then
        -- Distant snowy mountain peaks and cloud puffs
        love.graphics.setColor(0.72, 0.74, 0.95, 0.6)
        love.graphics.polygon("fill", 60, 650, 320, 350, 580, 650)
        love.graphics.polygon("fill", 480, 650, 750, 320, 1020, 650)
        love.graphics.circle("fill", 380, 480, 140)
        love.graphics.circle("fill", 950, 500, 160)
    elseif self.type == Constants.MAPS.DESERT then
        -- Rolling desert dunes
        love.graphics.setColor(0.35, 0.80, 0.62, 0.4)
        love.graphics.circle("fill", 250, 560, 260)
        love.graphics.circle("fill", 720, 570, 280)
        love.graphics.circle("fill", 1120, 580, 240)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Map:draw()
    self:drawBackground()
    
    local theme = self.theme
    
    -- Draw Scenery Background Decorations
    for _, d in ipairs(self.decorations) do
        if d.type == "tree_classic" then
            drawClassicTree(d.x, d.y, d.size)
        elseif d.type == "snowman" then
            drawSnowman(d.x, d.y)
        elseif d.type == "candy_cane" then
            drawCandyCane(d.x, d.y)
        elseif d.type == "cactus" then
            drawCactus(d.x, d.y, d.size)
        elseif d.type == "palm" then
            drawPalmTree(d.x, d.y, d.size)
        elseif d.type == "sphinx" then
            drawSphinx(d.x, d.y)
        elseif d.type == "pyramid" then
            drawPyramid(d.x, d.y, d.size)
        elseif d.type == "flower" then
            love.graphics.setColor(d.color)
            love.graphics.circle("fill", d.x, d.y - 12, 6)
            love.graphics.setColor(0.18, 0.8, 0.25, 1)
            love.graphics.rectangle("fill", d.x - 2, d.y - 8, 4, 8)
        elseif d.type == "crates" then
            love.graphics.setColor(0.92, 0.58, 0.2, 1)
            love.graphics.rectangle("fill", d.x, d.y - 36, 36, 36, 4, 4)
            love.graphics.rectangle("fill", d.x + 38, d.y - 36, 36, 36, 4, 4)
            love.graphics.setColor(0.78, 0.44, 0.12, 1)
            love.graphics.setLineWidth(2)
            love.graphics.line(d.x, d.y - 36, d.x + 36, d.y)
            love.graphics.line(d.x + 36, d.y - 36, d.x, d.y)
            love.graphics.line(d.x + 38, d.y - 36, d.x + 74, d.y)
            love.graphics.line(d.x + 74, d.y - 36, d.x + 38, d.y)
            love.graphics.setLineWidth(1)
        end
    end
    
    -- Draw Slopes
    for _, slope in ipairs(self.slopes) do
        local dx = slope.x2 - slope.x1
        local dy = slope.y2 - slope.y1
        local len = math.sqrt(dx * dx + dy * dy)
        local angle = Utils.atan2(dy, dx)
        local th = 16
        
        love.graphics.push()
        love.graphics.translate(slope.x1, slope.y1)
        love.graphics.rotate(angle)
        
        -- Slope base body
        love.graphics.setColor(theme.platBody)
        love.graphics.rectangle("fill", 0, 0, len, th, 4, 4)
        
        -- Slope top trim
        love.graphics.setColor(theme.platTop)
        love.graphics.rectangle("fill", 0, 0, len, 5, 3, 3)
        
        love.graphics.pop()
    end
    
    -- Draw Platforms
    for _, plat in ipairs(self.platforms) do
        -- Platform base
        love.graphics.setColor(theme.platBody)
        love.graphics.rectangle("fill", plat.x, plat.y, plat.w, plat.h, 6, 6)
        
        -- Platform top cap
        love.graphics.setColor(theme.platTop)
        love.graphics.rectangle("fill", plat.x, plat.y, plat.w, 6, 3, 3)
    end
    
    -- Draw Bounce Pads
    for _, pad in ipairs(self.bouncePads) do
        pad:draw()
    end
    
    -- Draw Left and Right Arena Side Borders
    love.graphics.setColor(theme.border)
    love.graphics.rectangle("fill", 0, 0, 24, Constants.VIRTUAL_HEIGHT)
    love.graphics.rectangle("fill", Constants.VIRTUAL_WIDTH - 24, 0, 24, Constants.VIRTUAL_HEIGHT)
    
    love.graphics.setColor(1, 1, 1, 1)
end

return Map

local Utils = require("src.utils")
local Constants = require("src.constants")
local Sound = require("src.sound")

local UI = {
    fonts = {},
    logoImg = nil,
    musicIconImg = nil
}

function UI.init()
    -- Create fonts with various sizes
    local sizes = {14, 18, 22, 28, 34, 44, 56, 72, 96}
    for _, s in ipairs(sizes) do
        local ok, f = pcall(love.graphics.newFont, s)
        if ok and f then
            UI.fonts[s] = f
        end
    end
    UI.fonts.default = love.graphics.getFont()
    
    local logoPath = "assets/this_says_tag.png"
    if love.filesystem.getInfo(logoPath) then
        UI.logoImg = love.graphics.newImage(logoPath)
    end
end

function UI.getFont(size)
    return UI.fonts[size] or UI.fonts.default
end

-- -------------------------------------------------------------
-- BUTTON COMPONENT
-- -------------------------------------------------------------
function UI.drawButton(btn, mouseX, mouseY)
    local isHover = Utils.pointInRect(mouseX, mouseY, btn.x, btn.y, btn.w, btn.h)
    local scale = isHover and 1.04 or 1.0
    local cx = btn.x + btn.w * 0.5
    local cy = btn.y + btn.h * 0.5
    
    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.scale(scale, scale)
    
    -- Drop shadow
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle("fill", -btn.w/2 + 3, -btn.h/2 + 4, btn.w, btn.h, btn.rx or 12, btn.rx or 12)
    
    -- Background
    local col = btn.color or {1, 1, 1, 1}
    if isHover and btn.hoverColor then
        col = btn.hoverColor
    end
    love.graphics.setColor(col)
    love.graphics.rectangle("fill", -btn.w/2, -btn.h/2, btn.w, btn.h, btn.rx or 12, btn.rx or 12)
    
    -- Border if specified
    if btn.borderWidth then
        love.graphics.setColor(btn.borderColor or {1, 1, 1, 1})
        love.graphics.setLineWidth(btn.borderWidth)
        love.graphics.rectangle("line", -btn.w/2, -btn.h/2, btn.w, btn.h, btn.rx or 12, btn.rx or 12)
        love.graphics.setLineWidth(1)
    end
    
    -- Text label
    if btn.text then
        local font = UI.getFont(btn.fontSize or 28)
        love.graphics.setFont(font)
        local textCol = btn.textColor or {1, 1, 1, 1}
        love.graphics.setColor(textCol)
        love.graphics.printf(btn.text, -btn.w/2, -font:getHeight()/2, btn.w, "center")
    end
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
    
    return isHover
end

-- -------------------------------------------------------------
-- TITLE SCREEN
-- -------------------------------------------------------------
function UI.drawTitleScreen(mouseX, mouseY, animTime)
    animTime = animTime or love.timer.getTime()
    
    -- Logo
    if UI.logoImg then
        local lw, lh = UI.logoImg:getDimensions()
        local scale = 0.38 + math.sin(animTime * 2.5) * 0.015
        local lx = Constants.VIRTUAL_WIDTH * 0.5
        local ly = 150 + math.sin(animTime * 2) * 8
        
        -- Logo drop shadow
        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.draw(UI.logoImg, lx + 4, ly + 6, 0, scale, scale, lw/2, lh/2)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(UI.logoImg, lx, ly, 0, scale, scale, lw/2, lh/2)
    else
        local font = UI.getFont(96)
        love.graphics.setFont(font)
        Utils.drawShadowedText("TAG", 0, 80, {1, 1, 1, 1}, {0, 0, 0, 0.4}, 4, 6, "center", Constants.VIRTUAL_WIDTH)
    end
    
    -- Center Purple Card
    local cardW = 380
    local cardH = 340
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) * 0.5
    local cardY = 270
    
    -- Purple card shadow
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle("fill", cardX + 4, cardY + 6, cardW, cardH, 24, 24)
    
    -- Purple card body
    love.graphics.setColor(0.60, 0.35, 0.65, 1)
    love.graphics.rectangle("fill", cardX, cardY, cardW, cardH, 24, 24)
    
    -- Player select buttons inside purple card
    local btnW = 310
    local btnH = 68
    local btnX = cardX + (cardW - btnW) * 0.5
    
    local btn2 = {
        id = "2_players",
        text = "2 PLAYERS",
        x = btnX, y = cardY + 36, w = btnW, h = btnH,
        color = {0.87, 0.23, 0.22, 1},
        hoverColor = {0.96, 0.32, 0.30, 1},
        textColor = {1, 1, 1, 1},
        fontSize = 32, rx = 14
    }
    local btn3 = {
        id = "3_players",
        text = "3 PLAYERS",
        x = btnX, y = cardY + 130, w = btnW, h = btnH,
        color = {0.93, 0.77, 0.08, 1},
        hoverColor = {1.0, 0.85, 0.18, 1},
        textColor = {1, 1, 1, 1},
        fontSize = 32, rx = 14
    }
    local btn4 = {
        id = "4_players",
        text = "4 PLAYERS",
        x = btnX, y = cardY + 224, w = btnW, h = btnH,
        color = {0.14, 0.71, 0.20, 1},
        hoverColor = {0.22, 0.82, 0.30, 1},
        textColor = {1, 1, 1, 1},
        fontSize = 32, rx = 14
    }
    
    UI.drawButton(btn2, mouseX, mouseY)
    UI.drawButton(btn3, mouseX, mouseY)
    UI.drawButton(btn4, mouseX, mouseY)
    
    -- Sound mute button at top right
    local sndBtn = {
        id = "sound_toggle",
        x = Constants.VIRTUAL_WIDTH - 80,
        y = 25,
        w = 52,
        h = 52,
        color = {0.15, 0.65, 0.95, 0.9},
        hoverColor = {0.25, 0.75, 1.0, 1.0},
        rx = 12
    }
    UI.drawButton(sndBtn, mouseX, mouseY)
    
    -- Music note icon
    love.graphics.setColor(1, 1, 1, 1)
    local mx = sndBtn.x + sndBtn.w * 0.5
    local my = sndBtn.y + sndBtn.h * 0.5
    if Sound.muted then
        -- Muted cross
        love.graphics.setLineWidth(3)
        love.graphics.line(mx - 12, my - 12, mx + 12, my + 12)
        love.graphics.setLineWidth(1)
    end
    -- Music note symbol
    love.graphics.circle("fill", mx - 6, my + 6, 4)
    love.graphics.circle("fill", mx + 6, my + 3, 4)
    love.graphics.rectangle("fill", mx - 4, my - 8, 3, 14)
    love.graphics.rectangle("fill", mx + 8, my - 11, 3, 14)
    love.graphics.rectangle("fill", mx - 4, my - 11, 15, 4)
    
    return {btn2, btn3, btn4, sndBtn}
end

-- -------------------------------------------------------------
-- MAP SELECTION SCREEN
-- -------------------------------------------------------------
function UI.drawMapSelectScreen(mouseX, mouseY)
    -- Background
    love.graphics.setColor(0.15, 0.48, 0.62, 1)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)
    
    -- Header Title
    local font = UI.getFont(56)
    love.graphics.setFont(font)
    Utils.drawShadowedText("CHOOSE MAP", 0, 70, {1, 1, 1, 1}, {0, 0, 0, 0.3}, 3, 4, "center", Constants.VIRTUAL_WIDTH)
    
    -- 3 Map Cards
    local cardW = 320
    local cardH = 260
    local spacing = 50
    local startX = (Constants.VIRTUAL_WIDTH - (cardW * 3 + spacing * 2)) * 0.5
    local cardY = 210
    
    local mapCards = {
        {id = Constants.MAPS.CLASSIC, name = "CLASSIC", x = startX, y = cardY, w = cardW, h = cardH},
        {id = Constants.MAPS.SNOW, name = "SNOW", x = startX + cardW + spacing, y = cardY, w = cardW, h = cardH},
        {id = Constants.MAPS.DESERT, name = "DESERT", x = startX + (cardW + spacing) * 2, y = cardY, w = cardW, h = cardH}
    }
    
    for _, card in ipairs(mapCards) do
        local isHover = Utils.pointInRect(mouseX, mouseY, card.x, card.y, card.w, card.h)
        local scale = isHover and 1.05 or 1.0
        local cx = card.x + card.w * 0.5
        local cy = card.y + card.h * 0.5
        
        love.graphics.push()
        love.graphics.translate(cx, cy)
        love.graphics.scale(scale, scale)
        
        -- Card shadow
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", -card.w/2 + 4, 0, card.w, 80, 16, 16)
        
        if card.id == Constants.MAPS.CLASSIC then
            -- Classic platform base
            love.graphics.setColor(0.91, 0.17, 0.47, 1)
            love.graphics.rectangle("fill", -card.w/2, -10, card.w, 90, 16, 16)
            love.graphics.setColor(0.19, 0.87, 0.23, 1)
            love.graphics.rectangle("fill", -card.w/2, -10, card.w, 14, 8, 8)
            -- Scenery elements
            love.graphics.setColor(0.82, 0.12, 0.42, 1)
            love.graphics.rectangle("fill", -70, -60, 14, 50, 4, 4)
            love.graphics.setColor(0.18, 0.88, 0.28, 1)
            love.graphics.rectangle("fill", -95, -95, 60, 40, 10, 10)
            love.graphics.rectangle("fill", 45, -75, 45, 35, 8, 8)
            love.graphics.setColor(0.82, 0.12, 0.42, 1)
            love.graphics.rectangle("fill", 60, -45, 12, 35, 3, 3)
        elseif card.id == Constants.MAPS.SNOW then
            -- Snow platform base
            love.graphics.setColor(0.65, 0.65, 0.95, 1)
            love.graphics.rectangle("fill", -card.w/2, -10, card.w, 90, 16, 16)
            love.graphics.setColor(0.93, 0.93, 0.99, 1)
            love.graphics.rectangle("fill", -card.w/2, -10, card.w, 14, 8, 8)
            -- Snowman & Candy Cane
            love.graphics.setColor(0.95, 0.95, 1, 1)
            love.graphics.circle("fill", -80, -26, 14)
            love.graphics.circle("fill", -80, -48, 10)
            love.graphics.setColor(0.2, 0.2, 0.25, 1)
            love.graphics.rectangle("fill", -86, -66, 12, 10, 2, 2)
            love.graphics.setColor(0.95, 0.2, 0.2, 1)
            love.graphics.rectangle("fill", -20, -55, 6, 45, 3, 3)
            -- Pine tree
            love.graphics.setColor(0.60, 0.60, 0.88, 1)
            love.graphics.rectangle("fill", 65, -80, 40, 70, 8, 8)
        elseif card.id == Constants.MAPS.DESERT then
            -- Desert platform base
            love.graphics.setColor(0.92, 0.75, 0.40, 1)
            love.graphics.rectangle("fill", -card.w/2, -10, card.w, 90, 16, 16)
            love.graphics.setColor(0.98, 0.85, 0.52, 1)
            love.graphics.rectangle("fill", -card.w/2, -10, card.w, 14, 8, 8)
            -- Sphinx & Cactus & Palm
            love.graphics.setColor(0.95, 0.75, 0.38, 1)
            love.graphics.rectangle("fill", -85, -60, 48, 50, 6, 6)
            love.graphics.setColor(0.15, 0.72, 0.42, 1)
            love.graphics.rectangle("fill", 10, -50, 8, 40, 3, 3)
            love.graphics.rectangle("fill", 2, -35, 10, 5, 2, 2)
            love.graphics.setColor(0.72, 0.45, 0.25, 1)
            love.graphics.polygon("fill", 70, -10, 78, -10, 80, -65, 74, -65)
            love.graphics.setColor(0.18, 0.75, 0.35, 1)
            love.graphics.circle("fill", 77, -65, 18)
        end
        
        -- Card Name Label
        local f = UI.getFont(24)
        love.graphics.setFont(f)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(card.name, -card.w/2, 40, card.w, "center")
        
        love.graphics.pop()
    end
    
    -- Bottom Buttons
    -- Back Button (left)
    local backBtn = {
        id = "back_to_title",
        x = 50, y = Constants.VIRTUAL_HEIGHT - 90, w = 64, h = 64,
        color = {0.15, 0.48, 0.62, 0.8},
        hoverColor = {0.20, 0.58, 0.74, 1.0},
        borderWidth = 3, borderColor = {1, 1, 1, 1},
        rx = 8
    }
    UI.drawButton(backBtn, mouseX, mouseY)
    -- Left arrow inside
    love.graphics.setColor(1, 1, 1, 1)
    local bx = backBtn.x + backBtn.w * 0.5
    local by = backBtn.y + backBtn.h * 0.5
    love.graphics.polygon("fill", bx - 14, by, bx + 10, by - 14, bx + 10, by + 14)
    
    -- Game Settings Button (center)
    local settingsBtn = {
        id = "open_settings",
        text = "GAME SETTINGS",
        x = (Constants.VIRTUAL_WIDTH - 280) * 0.5,
        y = Constants.VIRTUAL_HEIGHT - 90,
        w = 280, h = 60,
        color = {0.15, 0.48, 0.62, 0.8},
        hoverColor = {0.20, 0.58, 0.74, 1.0},
        borderWidth = 3, borderColor = {1, 1, 1, 1},
        fontSize = 24, rx = 6
    }
    UI.drawButton(settingsBtn, mouseX, mouseY)
    
    return {mapCards[1], mapCards[2], mapCards[3], backBtn, settingsBtn}
end

-- -------------------------------------------------------------
-- SETTINGS MODAL DIALOG
-- -------------------------------------------------------------
function UI.drawSettingsModal(settings, mouseX, mouseY)
    -- Dark overlay backdrop
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)
    
    -- Pink Modal Card
    local cardW = 540
    local cardH = 390
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) * 0.5
    local cardY = (Constants.VIRTUAL_HEIGHT - cardH) * 0.5
    
    -- Card shadow
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", cardX + 6, cardY + 8, cardW, cardH, 28, 28)
    
    -- Card body
    love.graphics.setColor(0.96, 0.56, 0.68, 1)
    love.graphics.rectangle("fill", cardX, cardY, cardW, cardH, 28, 28)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", cardX, cardY, cardW, cardH, 28, 28)
    love.graphics.setLineWidth(1)
    
    -- Modal Title
    local fontBig = UI.getFont(44)
    love.graphics.setFont(fontBig)
    Utils.drawShadowedText("SETTINGS", 0, cardY + 24, {1, 1, 1, 1}, {0, 0, 0, 0.25}, 2, 3, "center", Constants.VIRTUAL_WIDTH)
    
    local fontLabel = UI.getFont(28)
    love.graphics.setFont(fontLabel)
    
    -- ROW 1: BUFFS
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("BUFFS", cardX + 50, cardY + 105)
    
    local buffsOn = settings.buffsEnabled ~= false
    local btnBuffsOn = {
        id = "buffs_on",
        text = "ON",
        x = cardX + 220, y = cardY + 95, w = 90, h = 50,
        color = buffsOn and {1, 1, 1, 1} or {0.96, 0.56, 0.68, 1},
        textColor = buffsOn and {0.4, 0.4, 0.4, 1} or {1, 1, 1, 1},
        borderWidth = 3, borderColor = {1, 1, 1, 1},
        fontSize = 24, rx = 10
    }
    local btnBuffsOff = {
        id = "buffs_off",
        text = "OFF",
        x = cardX + 330, y = cardY + 95, w = 90, h = 50,
        color = (not buffsOn) and {1, 1, 1, 1} or {0.96, 0.56, 0.68, 1},
        textColor = (not buffsOn) and {0.4, 0.4, 0.4, 1} or {1, 1, 1, 1},
        borderWidth = 3, borderColor = {1, 1, 1, 1},
        fontSize = 24, rx = 10
    }
    UI.drawButton(btnBuffsOn, mouseX, mouseY)
    UI.drawButton(btnBuffsOff, mouseX, mouseY)
    
    -- ROW 2: TIME
    love.graphics.setFont(fontLabel)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("TIME", cardX + 50, cardY + 175)
    
    local curTime = settings.gameDuration or 120
    local times = {60, 120, 180}
    local timeButtons = {}
    for i, t in ipairs(times) do
        local isSelected = (curTime == t)
        local tb = {
            id = "time_" .. t,
            timeVal = t,
            text = tostring(t),
            x = cardX + 220 + (i - 1) * 90, y = cardY + 165, w = 78, h = 50,
            color = isSelected and {1, 1, 1, 1} or {0.96, 0.56, 0.68, 1},
            textColor = isSelected and {0.4, 0.4, 0.4, 1} or {1, 1, 1, 1},
            borderWidth = 3, borderColor = {1, 1, 1, 1},
            fontSize = 24, rx = 10
        }
        UI.drawButton(tb, mouseX, mouseY)
        table.insert(timeButtons, tb)
    end
    
    -- Subtitle
    local fontSmall = UI.getFont(16)
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.printf("THE SETTINGS ARE SAVED AUTOMATICALLY", cardX, cardY + 245, cardW, "center")
    
    -- Close Button
    local closeBtn = {
        id = "close_settings",
        text = "CLOSE",
        x = cardX + (cardW - 220) * 0.5, y = cardY + 290, w = 220, h = 56,
        color = {0.96, 0.56, 0.68, 1},
        hoverColor = {1, 0.7, 0.8, 1},
        borderWidth = 3, borderColor = {1, 1, 1, 1},
        fontSize = 28, rx = 8
    }
    UI.drawButton(closeBtn, mouseX, mouseY)
    
    local interactive = {btnBuffsOn, btnBuffsOff, closeBtn}
    for _, tb in ipairs(timeButtons) do table.insert(interactive, tb) end
    return interactive
end

-- -------------------------------------------------------------
-- CONTROLS SCREEN
-- -------------------------------------------------------------
function UI.drawControlsScreen(playerCount, mouseX, mouseY)
    -- Background
    love.graphics.setColor(0.15, 0.52, 0.55, 1)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)
    
    -- Title
    local font = UI.getFont(56)
    love.graphics.setFont(font)
    Utils.drawShadowedText("CONTROLS", 0, 50, {1, 1, 1, 1}, {0, 0, 0, 0.3}, 3, 4, "center", Constants.VIRTUAL_WIDTH)
    
    -- Subtitle
    local fontSub = UI.getFont(20)
    love.graphics.setFont(fontSub)
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.printf("MAKE SURE THAT THE KEYBOARD ONLY SUPPORTS KEYSTROKES", 0, 120, Constants.VIRTUAL_WIDTH, "center")
    
    -- 4 Player Cards
    local cardW = 200
    local cardH = 340
    local spacing = 35
    local startX = (Constants.VIRTUAL_WIDTH - (cardW * 4 + spacing * 3)) * 0.5
    local cardY = 175
    
    -- Display order matching reference: Red, Blue, Yellow, Green
    local displayPlayers = {2, 1, 3, 4}
    
    for i, pId in ipairs(displayPlayers) do
        local pConfig = Constants.PLAYERS[pId]
        local x = startX + (i - 1) * (cardW + spacing)
        local isActive = (pId <= playerCount)
        
        love.graphics.push()
        love.graphics.translate(x, cardY)
        
        -- Card shadow
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", 4, 6, cardW, cardH, 20, 20)
        
        -- Card main body
        local bodyCol = pConfig.darkColor or {0.2, 0.2, 0.2}
        if not isActive then
            bodyCol = {0.3, 0.3, 0.3, 0.5}
        end
        love.graphics.setColor(bodyCol)
        love.graphics.rectangle("fill", 0, 0, cardW, cardH, 20, 20)
        
        -- Top Banner
        local bannerCol = pConfig.color
        if not isActive then bannerCol = {0.45, 0.45, 0.45} end
        love.graphics.setColor(bannerCol)
        love.graphics.rectangle("fill", 0, 0, cardW, 46, 20, 20)
        love.graphics.rectangle("fill", 0, 26, cardW, 20)
        
        -- Banner Text
        local fontB = UI.getFont(22)
        love.graphics.setFont(fontB)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(pConfig.name, 0, 10, cardW, "center")
        
        -- Character Avatar
        local imgBody = love.filesystem.getInfo(pConfig.bodyAsset) and love.graphics.newImage(pConfig.bodyAsset)
        if imgBody then
            love.graphics.setColor(1, 1, 1, isActive and 1 or 0.4)
            local iw, ih = imgBody:getDimensions()
            local s = 80 / iw
            love.graphics.draw(imgBody, cardW * 0.5, 110, 0, s, s, iw/2, ih/2)
        end
        
        -- Horizontal divider line
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.line(15, 165, cardW - 15, 165)
        
        -- Key boxes
        local kw = 42
        local kh = 42
        local kx = (cardW - kw) * 0.5
        local ky = 180
        
        local fontKey = UI.getFont(24)
        love.graphics.setFont(fontKey)
        
        -- Up / Jump Key box
        love.graphics.setColor(bannerCol)
        love.graphics.rectangle("fill", kx, ky, kw, kh, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", kx, ky, kw, kh, 8, 8)
        love.graphics.printf(pConfig.keyLabels.jump, kx, ky + 8, kw, "center")
        
        -- Left Key box
        local klx = kx - kw - 10
        local kly = ky + kh + 8
        love.graphics.setColor(bannerCol)
        love.graphics.rectangle("fill", klx, kly, kw, kh, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", klx, kly, kw, kh, 8, 8)
        love.graphics.printf(pConfig.keyLabels.left, klx, kly + 8, kw, "center")
        
        -- Right Key box
        local krx = kx + kw + 10
        local kry = ky + kh + 8
        love.graphics.setColor(bannerCol)
        love.graphics.rectangle("fill", krx, kry, kw, kh, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", krx, kry, kw, kh, 8, 8)
        love.graphics.printf(pConfig.keyLabels.right, krx, kry + 8, kw, "center")
        
        -- Footer "CONTROL"
        local fontC = UI.getFont(16)
        love.graphics.setFont(fontC)
        love.graphics.setColor(bannerCol)
        love.graphics.printf("CONTROL", 0, cardH - 30, cardW, "center")
        
        love.graphics.pop()
    end
    
    -- Bottom Back Button
    local backBtn = {
        id = "back_to_map",
        x = 50, y = Constants.VIRTUAL_HEIGHT - 90, w = 64, h = 64,
        color = {0.15, 0.52, 0.55, 0.8},
        hoverColor = {0.20, 0.62, 0.65, 1.0},
        borderWidth = 3, borderColor = {1, 1, 1, 1},
        rx = 8
    }
    UI.drawButton(backBtn, mouseX, mouseY)
    love.graphics.setColor(1, 1, 1, 1)
    local bx = backBtn.x + backBtn.w * 0.5
    local by = backBtn.y + backBtn.h * 0.5
    love.graphics.polygon("fill", bx - 14, by, bx + 10, by - 14, bx + 10, by + 14)
    
    -- Bottom START Button
    local startBtn = {
        id = "start_game",
        text = "START",
        x = (Constants.VIRTUAL_WIDTH - 240) * 0.5,
        y = Constants.VIRTUAL_HEIGHT - 90,
        w = 240, h = 64,
        color = {0.15, 0.52, 0.55, 0.8},
        hoverColor = {0.22, 0.68, 0.72, 1.0},
        borderWidth = 3, borderColor = {1, 1, 1, 1},
        fontSize = 32, rx = 6
    }
    UI.drawButton(startBtn, mouseX, mouseY)
    
    return {backBtn, startBtn}
end

-- -------------------------------------------------------------
-- IN-GAME HUD
-- -------------------------------------------------------------
function UI.drawHUD(timeRemaining, isPaused, mouseX, mouseY)
    local timeInt = math.max(0, math.ceil(timeRemaining))
    
    -- Center Top Timer
    local fontTimer = UI.getFont(72)
    love.graphics.setFont(fontTimer)
    
    local timerCol = {1, 1, 1, 1}
    if timeRemaining <= 10 then
        -- Flashing red/yellow in last 10 seconds
        local pulse = 1.0 + (math.sin(love.timer.getTime() * 12) * 0.1)
        timerCol = {1.0, 0.25, 0.25, 1}
    end
    
    Utils.drawShadowedText(tostring(timeInt), 0, 24, timerCol, {0, 0, 0, 0.45}, 3, 5, "center", Constants.VIRTUAL_WIDTH)
    
    -- Pause button at bottom center
    local pauseBtn = {
        id = "pause_game",
        x = (Constants.VIRTUAL_WIDTH - 50) * 0.5,
        y = Constants.VIRTUAL_HEIGHT - 55,
        w = 50, h = 42,
        color = {1, 1, 1, 0.25},
        hoverColor = {1, 1, 1, 0.45},
        rx = 8
    }
    UI.drawButton(pauseBtn, mouseX, mouseY)
    
    -- Pause two vertical bars
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.rectangle("fill", pauseBtn.x + 15, pauseBtn.y + 10, 6, 22, 2, 2)
    love.graphics.rectangle("fill", pauseBtn.x + 29, pauseBtn.y + 10, 6, 22, 2, 2)
    
    return {pauseBtn}
end

-- -------------------------------------------------------------
-- PAUSE SCREEN
-- -------------------------------------------------------------
function UI.drawPauseScreen(mouseX, mouseY)
    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)
    
    -- PAUSE Title
    local font = UI.getFont(96)
    love.graphics.setFont(font)
    Utils.drawShadowedText("PAUSE", 0, 180, {1, 1, 1, 1}, {0, 0, 0, 0.4}, 4, 6, "center", Constants.VIRTUAL_WIDTH)
    
    -- RESUME & EXIT Buttons
    local btnW = 280
    local btnH = 68
    local btnX = (Constants.VIRTUAL_WIDTH - btnW) * 0.5
    
    local resumeBtn = {
        id = "resume_game",
        text = "RESUME",
        x = btnX, y = 340, w = btnW, h = btnH,
        color = {0.18, 0.72, 0.28, 0.95},
        hoverColor = {0.26, 0.84, 0.38, 1.0},
        fontSize = 32, rx = 14
    }
    local exitBtn = {
        id = "exit_to_menu",
        text = "EXIT",
        x = btnX, y = 430, w = btnW, h = btnH,
        color = {0.88, 0.25, 0.25, 0.95},
        hoverColor = {0.96, 0.35, 0.35, 1.0},
        fontSize = 32, rx = 14
    }
    
    UI.drawButton(resumeBtn, mouseX, mouseY)
    UI.drawButton(exitBtn, mouseX, mouseY)
    
    return {resumeBtn, exitBtn}
end

-- -------------------------------------------------------------
-- -------------------------------------------------------------
-- GAME OVER SCREEN
-- -------------------------------------------------------------
function UI.drawGameOverScreen(players, mouseX, mouseY)
    -- Find loser (who was IT at game over)
    local itPlayer = nil
    for _, p in ipairs(players) do
        if p.isIt then itPlayer = p break end
    end
    if not itPlayer then itPlayer = players[1] end
    
    local time = love.timer.getTime()
    
    -- Right side pink paper panel with jagged left edge
    local polyPink = {
        880, 0,
        Constants.VIRTUAL_WIDTH, 0,
        Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT,
        630, Constants.VIRTUAL_HEIGHT,
        650, 600,
        620, 480,
        660, 360,
        610, 240,
        650, 120
    }
    
    -- White drop shadow / border for paper edge
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.push()
    love.graphics.translate(-6, 0)
    love.graphics.polygon("fill", polyPink)
    love.graphics.pop()
    
    -- Pink panel body
    love.graphics.setColor(1.0, 0.60, 0.72, 1) -- #FF99B2 pink
    love.graphics.polygon("fill", polyPink)
    
    -- Left side UI: GAME OVER, RESTART, QUIT
    local fontTitle = UI.getFont(96)
    love.graphics.setFont(fontTitle)
    Utils.drawShadowedText("GAME OVER", 60, 50, {1, 1, 1, 1}, {0, 0, 0, 0.5}, 4, 6, "left", 600)
    
    -- RESTART button
    local fontBtn = UI.getFont(72)
    love.graphics.setFont(fontBtn)
    
    local playAgainBtn = {
        id = "play_again",
        x = 60, y = 260, w = 400, h = 90
    }
    local isHoverRestart = Utils.pointInRect(mouseX, mouseY, playAgainBtn.x, playAgainBtn.y, playAgainBtn.w, playAgainBtn.h)
    local restartScale = isHoverRestart and 1.06 or 1.0
    
    love.graphics.push()
    love.graphics.translate(playAgainBtn.x, playAgainBtn.y + 40)
    love.graphics.scale(restartScale, restartScale)
    Utils.drawShadowedText("RESTART", 0, -40, isHoverRestart and {1, 0.9, 0.3, 1} or {1, 1, 1, 1}, {0, 0, 0, 0.5}, 4, 5, "left", 400)
    love.graphics.pop()
    
    -- QUIT button
    local mainMenuBtn = {
        id = "main_menu",
        x = 60, y = 410, w = 260, h = 90
    }
    local isHoverQuit = Utils.pointInRect(mouseX, mouseY, mainMenuBtn.x, mainMenuBtn.y, mainMenuBtn.w, mainMenuBtn.h)
    local quitScale = isHoverQuit and 1.06 or 1.0
    
    love.graphics.push()
    love.graphics.translate(mainMenuBtn.x, mainMenuBtn.y + 40)
    love.graphics.scale(quitScale, quitScale)
    Utils.drawShadowedText("QUIT", 0, -40, isHoverQuit and {1, 0.9, 0.3, 1} or {1, 1, 1, 1}, {0, 0, 0, 0.5}, 4, 5, "left", 260)
    love.graphics.pop()
    
    -- Right side content inside Pink Panel
    -- "LOSE" text
    local fontLose = UI.getFont(72)
    love.graphics.setFont(fontLose)
    love.graphics.setColor(0.92, 0.22, 0.25, 1)
    love.graphics.printf("LOSE", 650, 110, Constants.VIRTUAL_WIDTH - 650, "center")
    
    -- Inverted Red Triangle
    local triX = 965
    local triY = 240 + math.sin(time * 6) * 6
    love.graphics.setColor(0.92, 0.22, 0.25, 1)
    love.graphics.polygon("fill", 
        triX - 32, triY - 40,
        triX + 32, triY - 40,
        triX, triY + 10
    )
    love.graphics.setColor(0.7, 0.1, 0.1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.polygon("line", 
        triX - 32, triY - 40,
        triX + 32, triY - 40,
        triX, triY + 10
    )
    love.graphics.setLineWidth(1)
    
    -- Large Ninja Character Art
    local charCenterX = 965
    local charBaseY = 700
    
    love.graphics.push()
    love.graphics.translate(charCenterX, charBaseY)
    
    -- Ninja Body (Dark Navy / Player Color)
    love.graphics.setColor(itPlayer.config.color or {0.10, 0.22, 0.32, 1})
    love.graphics.rectangle("fill", -140, -320, 280, 320, 60, 60)
    
    -- Red Headband
    love.graphics.setColor(0.90, 0.22, 0.22, 1)
    love.graphics.rectangle("fill", -145, -230, 290, 50, 16, 16)
    
    -- Headband tail dangling
    local tailWiggle = math.sin(time * 4) * 0.1
    love.graphics.push()
    love.graphics.translate(135, -205)
    love.graphics.rotate(0.3 + tailWiggle)
    love.graphics.rectangle("fill", 0, 0, 55, 30, 8, 8)
    love.graphics.rectangle("fill", 35, 15, 55, 26, 8, 8)
    love.graphics.pop()
    
    -- Big White Eyes
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.ellipse("fill", -60, -140, 48, 56)
    love.graphics.ellipse("fill", 60, -140, 48, 56)
    
    -- Black Pupils (Sad looking down)
    love.graphics.setColor(0.08, 0.08, 0.08, 1)
    love.graphics.circle("fill", -48, -130, 24)
    love.graphics.circle("fill", 72, -130, 24)
    
    -- Eye catchlight shines
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", -54, -140, 8)
    love.graphics.circle("fill", 66, -140, 8)
    
    -- Sad Frown Mouth
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(6)
    love.graphics.arc("line", "open", 0, -55, 30, math.pi * 1.1, math.pi * 1.9)
    love.graphics.setLineWidth(1)
    
    love.graphics.pop()
    
    love.graphics.setColor(1, 1, 1, 1)
    
    return {playAgainBtn, mainMenuBtn}
end

return UI

local Utils = {}

function Utils.atan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    elseif math.atan then
        return math.atan(y, x)
    end
    return 0
end

function Utils.clamp(val, minVal, maxVal)
    if val < minVal then return minVal end
    if val > maxVal then return maxVal end
    return val
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function Utils.sign(v)
    if v > 0 then return 1
    elseif v < 0 then return -1
    else return 0 end
end

function Utils.checkAABB(a, b)
    return a.x < b.x + b.w and
           a.x + a.w > b.x and
           a.y < b.y + b.h and
           a.y + a.h > b.y
end

function Utils.pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

function Utils.getSlopeY(slope, px)
    if px < math.min(slope.x1, slope.x2) or px > math.max(slope.x1, slope.x2) then
        return nil
    end
    local t = (px - slope.x1) / (slope.x2 - slope.x1)
    return slope.y1 + t * (slope.y2 - slope.y1)
end

function Utils.drawRoundedRect(mode, x, y, w, h, rx, ry)
    rx = rx or 12
    ry = ry or rx
    love.graphics.rectangle(mode, x, y, w, h, rx, ry)
end

function Utils.drawOutlinedText(text, x, y, textColor, outlineColor, outlineWidth, align, limit)
    outlineWidth = outlineWidth or 2
    textColor = textColor or {1, 1, 1, 1}
    outlineColor = outlineColor or {0, 0, 0, 1}
    
    love.graphics.setColor(outlineColor)
    for ox = -outlineWidth, outlineWidth, outlineWidth do
        for oy = -outlineWidth, outlineWidth, outlineWidth do
            if ox ~= 0 or oy ~= 0 then
                if align and limit then
                    love.graphics.printf(text, x + ox, y + oy, limit, align)
                else
                    love.graphics.print(text, x + ox, y + oy)
                end
            end
        end
    end
    
    love.graphics.setColor(textColor)
    if align and limit then
        love.graphics.printf(text, x, y, limit, align)
    else
        love.graphics.print(text, x, y)
    end
end

function Utils.drawShadowedText(text, x, y, textColor, shadowColor, offX, offY, align, limit)
    offX = offX or 3
    offY = offY or 3
    shadowColor = shadowColor or {0, 0, 0, 0.45}
    textColor = textColor or {1, 1, 1, 1}
    
    love.graphics.setColor(shadowColor)
    if align and limit then
        love.graphics.printf(text, x + offX, y + offY, limit, align)
    else
        love.graphics.print(text, x + offX, y + offY)
    end
    
    love.graphics.setColor(textColor)
    if align and limit then
        love.graphics.printf(text, x, y, limit, align)
    else
        love.graphics.print(text, x, y)
    end
end

function Utils.easeOutBack(x)
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3 * ((x - 1)^3) + c1 * ((x - 1)^2)
end

function Utils.easeOutQuad(x)
    return 1 - (1 - x) * (1 - x)
end

function Utils.easeInQuad(x)
    return x * x
end

function Utils.easeInOutQuad(x)
    return x < 0.5 and 2 * x * x or 1 - ((-2 * x + 2)^2) / 2
end

return Utils

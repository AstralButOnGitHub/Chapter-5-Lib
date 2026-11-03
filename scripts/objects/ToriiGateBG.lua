---@class ToriiGateBG : Sprite
---@overload fun(...) : ToriiGateBG
local ToriiGateBG, super = Class(Sprite)

function ToriiGateBG:init(sprite, x, y)
    super.init(self, sprite, x, y)
end

function ToriiGateBG:getSortPosition()
    return self:getRelativePos(0, 130)
end

function ToriiGateBG:draw()
    love.graphics.setColor(COLORS.green[1], COLORS.green[2], COLORS.green[3], 0.75)
    love.graphics.setLineWidth(2)
    love.graphics.line(
        29,
        184,
        47,
        125
    )
    super.draw(self)
end

return ToriiGateBG
---@class WaterableReeds : Event
---@overload fun(...) : WaterableReeds
local WaterableReeds, super = Class(Event)

function WaterableReeds:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self.reed_type = self.properties["reed_type"] or "1"
    self:setSprite("world/events/reeds/spr_dw_aquaplant_" .. self.reed_type)
    self.sprite.visible = false
    self.water_con = 0
    self.waterable = true
end

function WaterableReeds:canWater()
    return self.water_con == 0 and self.waterable
end

function WaterableReeds:update()
    super.update(self)
    if (self.water_con > 0 and self.water_con < 2) then
        self.water_con = self.water_con + 0.05;
        self.water_con = math.min(self.water_con, 2);
    end
end

function WaterableReeds:startBloom(sound)
    self.water_con = 0.05
    Game.world.timer:after(MathUtils.random(4, 24) / 30, function()
        Assets.playSound(TableUtils.pick({"pluey_1", "pluey_2", "pluey_3", "pluey_4", "pluey_5", "pluey_6", "pluey_7"}), MathUtils.random(0.3, 0.4), 1)
    end)
end

function WaterableReeds:draw()
    super.draw(self)

    local sprite = Assets.getTexture("world/events/reeds/spr_dw_aquaplant_" .. self.reed_type)
    local alpha = MathUtils.lerp(0, 1, self.water_con - 1)

    if alpha == 0 then
        return
    end

    local hh = sprite:getHeight()
    local h = MathUtils.lerp(0, hh, self.water_con - 1)

    love.graphics.setColor(1, 1, 1, alpha)
    Draw.drawPart(sprite, 0, (hh - h) * 2, 0, hh - h, sprite:getWidth(), h, 0, 2, 2)
end


return WaterableReeds
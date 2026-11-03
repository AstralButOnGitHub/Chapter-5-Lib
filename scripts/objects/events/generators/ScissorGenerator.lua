---@class ScissorGenerator : Event
---@overload fun(...) : ScissorGenerator
local ScissorGenerator, super = Class(Event)

function ScissorGenerator:init(data)
    super.init(self, data)
    self.properties = data.properties
    self.timer = tonumber(self.properties["time"]) or 0
end

function ScissorGenerator:update()
    super.update(self)
    self.timer = self.timer + (1/30 * DTMULT)
    if self.timer >= 4 then
        self.timer = 0
        local scissor = WanderingScissors({x = self.x, y = self.y, properties = self.properties})
        scissor.layer = WORLD_LAYERS["bullets"]
        Game.world:addChild(scissor)
        scissor.sprite.alpha = 0
        scissor.sprite:fadeTo(1, 1)
    end
end

return ScissorGenerator
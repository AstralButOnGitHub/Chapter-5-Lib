---@class PeachGenerator : Event
---@overload fun(...) : PeachGenerator
local PeachGenerator, super = Class(Event)

function PeachGenerator:init(data)
    super.init(self, data)
    self.properties = data.properties
    self.timer = 0
    self.speed = tonumber(self.properties["speed"]) or 1
    self.threshold = tonumber(self.properties["threshold"]) or 4
    self.spike_rate = tonumber(self.properties["spike_rate"]) or 4
    -- sustingus!
    self.spikery = 1
end

function PeachGenerator:update()
    super.update(self)
    self.timer = self.timer + self.speed / 30 * DTMULT
    if self.timer >= 4 then
        self.timer = 0
        local evil = false
        self.spikery = self.spikery + 1
        if self.spikery >= self.spike_rate then
            self.spikery = 1
            evil = true
        end
        local peach = FallingPeach(self.x, self.y, evil)
        peach.layer = WORLD_LAYERS["above_events"]
        Game.world:addChild(peach)
    end
end

return PeachGenerator
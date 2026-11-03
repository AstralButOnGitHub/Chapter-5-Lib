---@class PeachRemoveZone : Event
---@overload fun(...) : PeachRemoveZone
local PeachRemoveZone, super = Class(Event)

function PeachRemoveZone:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
end

function PeachRemoveZone:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self.collider:draw(1, 0, 0, 1)
    end
end

return PeachRemoveZone
---@class ScissorRemoveZone : Event
---@overload fun(...) : ScissorRemoveZone
local ScissorRemoveZone, super = Class(Event)

function ScissorRemoveZone:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
end

function ScissorRemoveZone:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self.collider:draw(1, 0, 0, 1)
    end
end

return ScissorRemoveZone
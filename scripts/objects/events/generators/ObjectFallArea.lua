---@class ObjectFallArea : Event
---@overload fun(...) : ObjectFallArea
local ObjectFallArea, super = Class(Event)

function ObjectFallArea:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
end

function ObjectFallArea:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self.collider:draw(0, 1, 0, 1)
    end
end

return ObjectFallArea
---@class TerracottaFallArea : Event
---@overload fun(...) : TerracottaFallArea
local TerracottaFallArea, super = Class(Event)

function TerracottaFallArea:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
end

function TerracottaFallArea:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self.collider:draw(0, 1, 0, 1)
    end
end

return TerracottaFallArea
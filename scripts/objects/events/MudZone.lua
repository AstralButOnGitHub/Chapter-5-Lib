---@class MudZone : Event
---@overload fun(...) : MudZone
local MudZone, super = Class(Event)

function MudZone:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
end

return MudZone
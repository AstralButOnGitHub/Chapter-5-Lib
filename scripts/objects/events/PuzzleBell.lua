---@class PuzzleBell : Event
---@overload fun(...) : PuzzleBell
local PuzzleBell, super = Class(Event)

function PuzzleBell:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self:setSprite("world/events/watering/bell")
    self:setHitbox(0, 40, 40, 40)
    self:setPosition(self.x - 20, self.y - 20)

    self.scissors = Game.world.map:getEvent(self.properties["scissors"])
    self.can_ring = true
end

function PuzzleBell:onLoad()
    super.onLoad(self)

    local x, y, marker = TiledUtils.parseMarkerProperty(self, self.properties.target, "target")
    self.marker = {["x"] = x, ["y"] = y, ["marker"] = marker}
end

function PuzzleBell:onInteract(player, dir)
    player.input_lock = true
    if self.can_ring then
        Assets.playSound("bell")
        self.can_ring = false
        self.sprite:play(0.25, false, function(sprite)
            self.can_ring = true
        end)
        if self.scissors ~= nil and not self.scissors.jumping then
            self.scissors:jumpTo(self.marker.x + 20, self.marker.y + 20, self.rotation or "right")
        end
        for _, flower in ipairs(Game.world:getEvents("WaterableFlower")) do
            flower.bloomtimer = 0
            flower.blooming = false
            flower.regrowing = false
            flower.bloom_state = flower.start_state
        end
        return true
    else
        return false
    end
end

return PuzzleBell
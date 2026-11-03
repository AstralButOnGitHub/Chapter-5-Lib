---@class LeafPile : Event
---@overload fun(...) : LeafPile
local LeafPile, super = Class(Event)

function LeafPile:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self:setSprite("world/events/leafpile")
    self:setPosition(self.x - (self.width / 2), self.y - self.height + 20)
    self:setHitbox(0, 40, 80, 40)
end

function LeafPile:onLoad()
    super.onLoad(self)
    if self:getFlag("destroyed", false) then
        self:remove()
    end
end

function LeafPile:onEnter(player)
    if player.state == "TORII_DASH" then
        self:setFlag("destroyed", true)
        self:remove()
        Assets.playSound("wing")

        for i = 1, 12, 1 do
            local marker = Sprite("effects/spin_petal_alt_"..math.random(1, 4), self.x + MathUtils.random(0, self.width), self.y + MathUtils.random(25))
            marker:setScale(2)
            Game.world:addChild(marker)
            marker.layer = WORLD_LAYERS["above_events"]
            marker.physics.speed_y = MathUtils.random(-24, 4)
            marker.physics.speed_x = MathUtils.random(32, 68) * (player.flip_x == true and -1 or 1)
            marker:fadeOutAndRemove(45/30)
            Game.world.timer:tween(1, marker.physics, { speed_y = marker.physics.speed_y * 0.2 }, "out-sine")
        end
    end
end

return LeafPile
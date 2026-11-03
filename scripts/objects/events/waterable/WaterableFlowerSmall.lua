---@class WaterableSmallFlower : Event
---@overload fun(...) : WaterableSmallFlower
local WaterableSmallFlower, super = Class(Event)

function WaterableSmallFlower:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    -- default is purple because seth my beloved
    self.flower_color = self.properties["color"] or "purple"
    self.bloom_state = self.properties["bloom_state"] or 1
    self:setHitbox(0, 0, 20, 20)
end

function WaterableSmallFlower:onLoad()
    super.onLoad(self)
    self.layer = self.layer - 0.1
end

function WaterableSmallFlower:canWater()
    for _, scissor in ipairs(self.world.map:getEvents("WanderingScissors")) do
        if scissor:meetsCollider(self.collider) then
            return false
        end
    end
    return self.bloom_state == 1
end

function WaterableSmallFlower:startBloom(sound)
    self.bloom_state = 2
    if sound ~= nil then
        if sound ~= "pombark" then
            Assets.stopAndPlaySound(sound, 0.6, 2)
        else
            Assets.playSound(sound, 0.6, 2)
        end
    end
    Game.world.timer:after(0.1, function ()
        self.bloom_state = 3
    end)
end

function WaterableSmallFlower:canCut()
    return self.bloom_state == 3
end

function WaterableSmallFlower:cut()
    self.bloom_state = 1
end

function WaterableSmallFlower:draw()
    super.draw(self)
    local spr = Assets.getTexture("world/events/watering/small_flower/waterable_smallflower_"..self.flower_color.."_"..self.bloom_state)
    love.graphics.draw(spr, 0, 0,0, 2, 2)
end

return WaterableSmallFlower
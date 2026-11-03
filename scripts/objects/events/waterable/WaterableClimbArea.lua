---@class WaterableClimbArea : Event
---@overload fun(...) : WaterableClimbArea
local WaterableClimbArea, super = Class(Event)

function WaterableClimbArea:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    -- default is purple because seth my beloved
    self.flower_color = self.properties["color"] or "purple"
    self.bloom_state = self.properties["bloom_state"] or 1
    self:setHitbox(0, 0, 40, 40)
    self.climbarea = Game.world:addChild(ClimbArea(self.x, self.y, {40, 40}))
    self.climbarea.isClimbable = function()
        return (self.bloom_state == 3 or (Game.world.player and Game.world.player.climb_watering))
    end
end

function WaterableClimbArea:onLoad()
    super.onLoad(self)
    self.layer = self.layer - 0.1
end

function WaterableClimbArea:canWater()
    for _, scissor in ipairs(self.world.map:getEvents("WanderingScissors")) do
        if scissor:meetsCollider(self.collider) then
            return false
        end
    end
    return self.bloom_state == 1
end

function WaterableClimbArea:startBloom(sound)
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

function WaterableClimbArea:canCut()
    return self.bloom_state == 3
end

function WaterableClimbArea:cut()
    local ang = MathUtils.random(33)
    for i = 1, 8 do
        local petal = Sprite("effects/cuttableflowerpetals_1")
        petal:setScale(2, 2)
        local dir = ((i / 8) * 360) + ang
        petal.layer = petal.layer + 1
        petal.physics.speed_x = 8 * math.cos(dir)
        petal.physics.speed_y = (8 * math.sin(dir)) * 0.95
        Game.world.timer:after(0.1, function ()
            petal:remove()
        end)
        self:addChild(petal)
    end
    self.bloom_state = 1
    if self.flower_color == "purple" then
        Game.world.timer:after(1, function ()
            self:startBloom()
        end)
    end
    if self.flower_color == "blue" then
        Game.world.timer:after(1.5, function ()
            self:startBloom()
        end)
    end
end

function WaterableClimbArea:draw()
    super.draw(self)
    local spr = Assets.getTexture("world/events/watering/flower/waterable_flower_"..self.flower_color.."_"..self.bloom_state)
    love.graphics.draw(spr, 0, 0,0, 2, 2)
end

return WaterableClimbArea
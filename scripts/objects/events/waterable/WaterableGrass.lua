---@class WaterableGrass : Event
---@overload fun(...) : WaterableGrass
local WaterableGrass, super = Class(Event)

function WaterableGrass:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self.grass_color = self.properties["color"] or "pink"
    self:setHitbox(0, 0, 40, 40)
end

function WaterableGrass:onLoad()
    super.onLoad(self)
    self:setFlag("bloom_state", self:getFlag("bloom_state", 1))
    self.solid = self:getFlag("bloom_state") == 1
    self.layer = self.layer - 0.1
end

function WaterableGrass:canWater()
    for _, scissor in ipairs(self.world.map:getEvents("WanderingScissors")) do
        if scissor:meetsCollider(self.collider) then
            return false
        end
    end
    return self:getFlag("bloom_state") == 1
end

function WaterableGrass:startBloom(sound)
    self:setFlag("bloom_state", 2)
    if sound ~= nil then
        if sound ~= "pombark" then
            Assets.stopAndPlaySound(sound, 0.6, 2)
        else
            Assets.playSound(sound, 0.6, 2)
        end
    end
    Game.world.timer:after(0.1, function ()
        self:setFlag("bloom_state", 3)
        self.solid = false
        Game.world.timer:after(0.1, function ()
            self:setFlag("bloom_state", 4)
            Game.world.timer:after(0.1, function ()
                self:setFlag("bloom_state", 5)
                Game.world.timer:after(0.1, function ()
                    self:setFlag("bloom_state", 6)
                end)
            end)
        end)
    end)
end

function WaterableGrass:canCut()
    return self:getFlag("bloom_state") == 6
end

function WaterableGrass:cut()
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
    self:setFlag("bloom_state", 1)
    self.solid = true
end

function WaterableGrass:draw()
    super.draw(self)
    local spr = Assets.getTexture("world/events/watering/growgrass/growgrass_"..self.grass_color.."_"..self:getFlag("bloom_state", 1))
    love.graphics.draw(spr, 0, 0,0, 2, 2)
end

return WaterableGrass
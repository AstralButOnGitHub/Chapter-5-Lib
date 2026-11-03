---@class WaterableFlower : Event
---@overload fun(...) : WaterableFlower
local WaterableFlower, super = Class(Event)

function WaterableFlower:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    -- default is purple because seth my beloved
    self.flower_color = self.properties["color"] or "purple"
    self.flower_color_RGB = self.properties["color_RGB"] or nil
    if self.flower_color_RGB == nil then
        if self.flower_color == "blue" then
            self.flower_color_RGB = {82/255, 134/255, 195/255}
        end
        if self.flower_color == "green" then
            self.flower_color_RGB = {82/255, 191/255, 94/255}
        end
        if self.flower_color == "purple" then
            -- sethsethsethsethsethseth
            self.flower_color_RGB = {158/255, 110/255, 255/255}
        end
        if self.flower_color == "yellow" then
            self.flower_color_RGB = {218/255, 203/255, 118/255}
        end
    end

    self.blooming = false
    self.regrowing = false
    self.bloomtimer = 0
    self.bloom_state = self.properties["bloom_state"] or 1
    self.start_state = self.bloom_state
    self:setHitbox(0, 0, 40, 40)
end

function WaterableFlower:onLoad()
    super.onLoad(self)
    self.layer = self.layer - 0.01
end

function WaterableFlower:canWater()
    for _, scissor in ipairs(self.world.map:getEvents("WanderingScissors")) do
        if scissor:meetsCollider(self.collider) then
            return false
        end
    end
    return self.bloom_state == 1
end

function WaterableFlower:startBloom(sound)
    self.bloom_state = 2
    if sound ~= nil then
        if sound ~= "pombark" then
            Assets.stopAndPlaySound(sound, 0.6, 2)
        else
            Assets.playSound(sound, 0.6, 2)
        end
    end
    self.blooming = true
    self.regrowing = false
end

function WaterableFlower:canCut()
    return self.bloom_state == 3 and not self.blooming
end

function WaterableFlower:cut()
    local ang = MathUtils.random(33)
    for i = 1, 8 do
        local petal = Sprite("effects/cuttableflowerpetals_1", 10, 10)
        petal:setScale(2, 2)
        local dir = ((i / 8) * 360) + ang
        petal.color = self.flower_color_RGB
        petal.layer = petal.layer + 1
        petal.physics.speed_x = 8 * math.cos(dir)
        petal.physics.speed_y = (8 * math.sin(dir)) * 0.95
        Game.world.timer:after(0.15, function ()
            petal:fadeOutAndRemove(0.01)
        end)
        self:addChild(petal)
    end
    self.bloom_state = 1
    if self.flower_color == "purple" or self.flower_color == "blue" then
        self.regrowing = true
        self.blooming = false
    end
end

function WaterableFlower:update()
    super.update(self)
    if self.blooming or self.regrowing then
        self.bloomtimer = self.bloomtimer + 1/30
    end

    if self.blooming and self.bloomtimer > 0.1 then
        self.blooming = false
        self.bloomtimer = 0
        self.bloom_state = 3
    end

    if self.regrowing then
        if self.flower_color == "purple" then
            if self.bloomtimer > 1 then
                self:startBloom()
            end
        elseif self.flower_color == "blue" then
            if self.bloomtimer > 1.5 then
                self:startBloom()
            end
        end
    end
end

function WaterableFlower:draw()
    super.draw(self)
    local spr = Assets.getTexture("world/events/watering/flower/waterable_flower_"..self.flower_color.."_"..self.bloom_state)
    love.graphics.draw(spr, 0, 0,0, 2, 2)
end

return WaterableFlower
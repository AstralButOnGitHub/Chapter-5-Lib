---@class PhysicsMushroom : Object
---@overload fun(...) : PhysicsMushroom
local PhysicsMushroom, super = Class(Object)

function PhysicsMushroom:init(x, y)
    super.init(self, x, y, 0, 0)

    self.fakegrav = 0.5
    self.fakeyspeed = 0
    self.rotation_speed = 0
    self.state = 0
    self.bounces = 0
    self.targeted = false
    self.destroy_on_overlap = false
    self.pushing = false

    self.dropshadow = Sprite("effects/dropshadow", 0, 0)
    self.dropshadow.alpha = 0.4
    self:addChild(self.dropshadow)

    self.sprite = Sprite("world/events/head_mushroom", 0, 0)
    self.sprite:setRotationOrigin(0.5, 0.5)
    self:addChild(self.sprite)
    self:setHitbox(0, 0, self.sprite.width, self.sprite.height)
end

function PhysicsMushroom:update()
    super.update(self)

    if (self.state == 0) then
        self.fakeyspeed = self.fakeyspeed + self.fakegrav
        self.fakeheight = self.fakeheight + self.fakeyspeed
        self.sprite.rotation = self.sprite.rotation + self.rotation_speed
        self.rotation_speed = self.rotation_speed * 0.99

        if (self.fakeheight >= 0) then
            self.bounces = self.bounces + 1
            self.physics.speed = self.physics.speed * 0.5
            self.rotation_speed = self.rotation_speed * TableUtils.pick({0.7, 1.3, -0.7, -1.3})
            self.fakeyspeed = self.fakeyspeed * -0.5
            self.fakeheight = 0
            self.physics.speed_y = 0
            self.physics.speed_x = 0
            self.physics.speed = 0
            self.state = 1
            self.sprite.rotation = MathUtils.round(self.sprite.rotation / math.rad(45)) * math.rad(45)
            if self.pushing == false then
                Assets.playSound("bombfall")
            end
        end
    else
        self.hspeed = 0
        self.vspeed = 0
        self.physics.speed = 0
        self.fakeheight = 0
        self.gravity = 0
    end

    self.dropshadow.y = -(self.fakeheight / 2)
    -- self.sprite.y = (self.fakeheight / 2)

    if self.state == 1 and Game.world.player and self:meetsObject(Game.world.player) then
        self.physics.speed_x = (Game.world.player.moving_x) * 1.1
        self.physics.speed_y = (Game.world.player.moving_y) * 1.1
        self.fakeyspeed = -2
        self.fakeheight = 0
        self.pushing = true
        self.state = 0
    end
end

function PhysicsMushroom:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self.collider:draw(0, 1, 1, 0.5)
        love.graphics.print(tostring(self.fakeheight))
    end
end

return PhysicsMushroom
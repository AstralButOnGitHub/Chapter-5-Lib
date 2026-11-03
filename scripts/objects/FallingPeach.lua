---@class FallingPeach : ClimbEnemy
---@overload fun(...) : FallingPeach
local FallingPeach, super = Class(ClimbEnemy)

function FallingPeach:init(x, y, bad)
    self.bad = bad or false
    super.init(self, x, y, self.bad == false and "world/events/peach/peach" or "world/events/peach/spiky_peach")

    self:setPosition(self.x + 20, self.y + 20)
    self.damage = 30
    self.bouncerange = 4
    self.bouncemin = -6
    self.consistent = false
    self.waitmin = 40
    self.waitmax = 60
    self.timer = 0
    -- con my beloved
    self.con = 0
    self.damagecon = 1
    self.cury = self.y + math.random(50) + 10
    self.xstart = self.x
    self.ystart = self.y
    self.physics.gravity = 0.5
    self.fading = false
    self.invincible = self.bad
end

function FallingPeach:moveX(arg0)
    local targx = math.random(8, 12) * 2
    if (self.x > self.xstart) then
        targx = -targx
    end
    self.wasx = self.x
    self.xtarg = self.x + targx
end

function FallingPeach:newWait()
    if (self.consistent or self.distance_activate) then
        return (self.waitmin + self.waitmax) / 2
    end
    return math.random(self.waitmin, self.waitmax)
end

function FallingPeach:update()
    super.update(self)

    if Game.world and self.fading == false then
        for _, zone in ipairs(Game.world.map:getEvents("PeachRemoveZone")) do
            if self:meetsObject(zone) then
                self.fading = true
                self.sprite:fadeTo(0, 1, function()
                    self:remove()
                end)
            end
        end
    end

    if (self.con == 0) then
        self.waittime = self:newWait()
        self:moveX(self.waittime)
        self.timer = 0
        self.cury = self.y
        self.con = 1
    end

    if (self.con == 1) then
        self.timer = self.timer + 1

        if (not self.caught) then
            self.x = MathUtils.lerp(self.wasx, self.xtarg, self.timer / self.waittime)
        end

        if (self.y > (self.cury + self.waittime)) then
            self.physics.speed_y = (self.bouncemin + MathUtils.random(self.bouncerange)) / 2

            if (self.consistent) then
                self.physics.speed_y = (self.bouncemin + (0.5 * self.bouncerange)) / 2
            end
            self.con = 0
        end
    end
end

function FallingPeach:onJumpAttack(player)
    if self.bad then
        Game.world:hurtParty(30)
        self.is_active = false
        return
    end
    self.is_active = false
    self.timer = 0

    self:spawnAttackEffects()
    self:playAttackSounds()

    self:shake(10, 0, 2, nil, true)

    self:hurt(1, player)
end

function FallingPeach:spawnAttackEffects()

end

function FallingPeach:spawnAttackEffects()

end

function FallingPeach:onDeath()
    self:playDeathSounds()

    if not self.bad then
        local slice_1 = Game.world:addChild(Sprite("world/events/peach/peach_slice_1", self.x, self.y))
        slice_1:setScale(2, 2)
        slice_1:setOrigin(0.5, 0.5)
        slice_1.layer = self.layer - 1
        slice_1.physics.gravity = 0.5
        slice_1.physics.direction = 135
        slice_1.physics.friction = 0.01
        slice_1.physics.speed = 5

        local slice_2 = Game.world:addChild(Sprite("world/events/peach/peach_slice_2", self.x, self.y))
        slice_2:setScale(2, 2)
        slice_2:setOrigin(0.5, 0.5)
        slice_2.layer = self.layer + 1
        slice_2.physics.gravity = 0.25
        slice_2.physics.direction = 315
        slice_2.physics.friction = 0.01
        slice_2.physics.speed = 2

        Game.world:addChild(FruitNinjaJuice(self.x, self.y))
    end
    self:remove()
end

function FallingPeach:draw()
    super.draw(self)
    if DEBUG_RENDER then
        love.graphics.print(tostring(self.physics.speed_y), 0, -10)
    end
end

return FallingPeach
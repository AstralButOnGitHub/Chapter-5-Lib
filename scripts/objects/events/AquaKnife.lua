---@class AquaKnife : Event
---@overload fun(...) : AquaKnife
local AquaKnife, super = Class(Event)

function AquaKnife:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
    self.bullet = Game.world:addChild(WorldBullet(0, 0, "world/events/aquaknife"))
    self.bullet.destroy_on_hit = false
    self.bullet.remove_offscreen = false
    self.bullet.battle_fade = false
    self.bullet.damage = 18
    self.bullet.layer = self.layer + .7
    self.timer = 0
    self.freq = 1
    self.amp = self.properties["amplitude"] or 80
    self.offset = self.properties["offset"] or 0
    self.xstart = self.x
end

function AquaKnife:remove()
    self.bullet:remove()
    super.remove(self)
end

function AquaKnife:update()
    super.update(self)
    self.bullet:setPosition(self.x, self.y)
    self.bullet.rotation = self.rotation

    self.timer = self.timer + DTMULT / 30

    local spinrate = math.cos((self.timer * self.freq) + math.rad(self.offset + 45))

    self.x = self.xstart + (math.sin((self.timer * self.freq) + self.offset) * self.amp)
    self.bullet.scale_y = MathUtils.sign(spinrate) * 2

    self.rotation = self.rotation + math.rad(-spinrate * (self.amp / 2))

    if math.floor(self.timer * 15) > math.floor((self.timer - (DTMULT / 30)) * 15) then
        local after_image = Sprite("world/events/aquaknife_afterimage")
        after_image.layer = self.layer - 0.1
        after_image.skip_fusuma = true
        after_image.alpha = 0.4
        after_image:fadeOutSpeedAndRemove(0.05)
        after_image:setOrigin(0.5)
        after_image:setScale(2)
        after_image:setPosition(self.x, self.y)
        after_image.rotation = self.rotation
        after_image.scale_y = MathUtils.sign(spinrate) * 2

        Game.world:addChild(after_image)
    end
end

return AquaKnife
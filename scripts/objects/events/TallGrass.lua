---@class TallGrass : Event
---@overload fun(...) : TallGrass
local TallGrass, super = Class(Event)

function TallGrass:init(x, y, shape, properties)
    super.init(self, x, y, shape)
    self.properties = properties or {}

    self.lit = self.properties["lit"] == true or false
    self.solid = false

    self.grasses = {}
end

function TallGrass:onLoad()
    super.onLoad(self)

    for j = 1, self.width / 40, 1 do
        for k = 1, self.height / 20, 1 do
            local sprite = Game.world:addChild(Sprite("world/events/tallgrass/"..TableUtils.pick(self.lit == false and {"nolight", "nolight2"} or {"lightbake", "lightbake2"})))
            sprite:setPosition(self.x + j * 40, self.y + k * 20)
            sprite:setPosition(sprite.x - 60, sprite.y - 80)
            sprite:setScale(2, 2)
            sprite:setLayer(self.layer)
            sprite:setFrame(1)

            local collider = Hitbox(self, (j * 40) - 40, (k * 20) - 80 + 60, 40, 20)
            table.insert(self.grasses, {["sprite"] = sprite, ["collider"] = collider, ["touching"] = false, ["wastouching"] = false, ["cut"] = false, ["target_frame"] = 0})
        end
    end
end

function TallGrass:update()
    super.update(self)

    local characters = Game.stage:getObjects(Character)

    Object.startCache()
    for _, grass in ipairs(self.grasses) do
        local shouldtouch = false
        local player = nil

        for _, chara in ipairs(characters) do
            if grass.collider:meetsObject(chara) then
                shouldtouch = true
                if chara:includes(Player) then
                    player = chara
                end
            end
        end

        if player ~= nil and shouldtouch and not grass.wastouching then
            if grass.cut == false then
                Assets.stopAndPlaySound("wing", 0.25, 0.9)
            end
            if player.state == "TORII_DASH" then
                self:cutDown(grass)
            end
        end

        grass.wastouching = grass.touching
        grass.touching = shouldtouch
        grass.target_frame = MathUtils.lerp(grass.target_frame, grass.touching and 2 or 1, 0.25)
        grass.sprite:setFrame(MathUtils.round(grass.target_frame))
    end
    Object.endCache()
end

function TallGrass:cutDownEffect(arg0, arg1)
    local _dir = 0
    local _len = MathUtils.random(5, 12)
    if (Game.world.player ~= nil) then
        _dir = -(Game.world.player.state_manager:getHandler(Game.world.player.state).runspeed * MathUtils.random(-1, 1.8))
    end
    local particle = Game.world:addChild(Sprite("effects/tallgrass_stalk"))

    local _lifetime = MathUtils.random(30, 90)
    local _image_alpha = MathUtils.random(1, 1.3)
    particle.layer = WORLD_LAYERS["above_bullets"]
    particle.x = arg0
    particle.y = arg1
    particle:setScale(MathUtils.random(1, 3), MathUtils.random(1, 3))
    particle.physics.speed_x = math.cos(math.rad(_dir)) * _len
    particle.physics.speed_y = (math.sin(math.rad(_dir)) * _len) - MathUtils.random(5, 12)
    particle.rotation = _dir
    particle:fadeOutAndRemove(_image_alpha)
end

function TallGrass:cutDown(grass)
    if (grass.cut) then
        return false
    end

    self:cutDownEffect(self.x + grass.collider.x + 20, self.y + grass.collider.y + MathUtils.random(-30, 30))

    grass.sprite:setSprite("world/events/tallgrass/cut")
    grass.cut = true

    return true
end

return TallGrass
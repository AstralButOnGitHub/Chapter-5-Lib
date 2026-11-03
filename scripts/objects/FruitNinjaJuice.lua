---@class FruitNinjaJuice : Object
---@overload fun(...) : FruitNinjaJuice
local FruitNinjaJuice, super = Class(Object)

function FruitNinjaJuice:init(x, y)
    super.init(self, x, y, 0, 0)

    self.layer = WORLD_LAYERS["below_ui"]
    self.physics.gravity = 0.7
    self.physics.speed_y = -4
    self.juice = {}
    local juicecount = math.random(24, 32)

    for i = 0, juicecount, 1 do
        local _j = {
            x = self.x,
            y = self.y,
            xprevious = self.x,
            yprevious = self.y,
            direction = ((i / juicecount) * 360) + MathUtils.random(-8, 8) + 6,
            speed = MathUtils.random(2, 6),
            friction = MathUtils.random(0.001, 0.02),
            scale = MathUtils.random(12, 30),
            col = ColorUtils.mergeColor(ColorUtils.hexToRGB("#FFA201"), ColorUtils.hexToRGB("#F199BC"), MathUtils.random(0, 0.25))
        }
        table.insert(self.juice, _j)
    end
end

function FruitNinjaJuice:update()
    super.update(self)
    for _, j in ipairs(self.juice) do
        j.scale = j.scale * 0.95
        j.xprevious = j.x
        j.yprevious = j.y
        j.speed = j.speed * (1 - j.friction)
        j.x = j.x + math.cos(math.rad(j.direction)) * j.speed
        j.y = j.y + math.sin(math.rad(j.direction)) * j.speed + (j.y - j.yprevious)
    end
end

function FruitNinjaJuice:draw()
    super.draw(self)
    local dokill = true
    local spritecount = 0
    local cy = Game.world.camera.y + (480 * 2)

    for _, j in ipairs(self.juice) do
        if j.scale > 0.00390625 then
            local count = math.max(2, MathUtils.round(MathUtils.dist(j.x, j.y, j.xprevious, j.yprevious)))

            for k = 0, count, 1 do
                local _x = MathUtils.lerp(j.xprevious, j.x, k / count)
                local _y = MathUtils.lerp(j.yprevious, j.y, k / count)
                local world_x, world_y = self:getRelativePos(_x, _y, Game.world)
                local x, y = Game.world:getRelativePos(world_x / 2, world_y / 2, self)

                if y < cy then
                    dokill = false
                end

                local _scale = MathUtils.clamp((j.scale * (k / count)) / 256, (2 * k) / count / 256, 1)
                love.graphics.setColor(j.col)
                love.graphics.draw(Assets.getTexture("effects/circle_256_aa"), x, y, 0, _scale, _scale)
                spritecount = spritecount + 1
            end
        end
    end

    if dokill then
        -- self:remove()
    end
end

return FruitNinjaJuice
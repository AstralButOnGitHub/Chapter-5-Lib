---@class HeadMushroom : Object
---@overload fun(...) : HeadMushroom
local HeadMushroom, super = Class(Object)

function HeadMushroom:init(x, y, width, height)
    super.init(self, x, y, width, height)

    self.shroomstack = {}
    self.player_movement_history = {}
    self.can_knock_off = true

    local wx, wy = self:getRelativePos(x, y, self.parent)
    self.xprevious = wx
    self.yprevious = wy
    self.xdist = {}
    self.ydist = {}
    self.size = {}
end

function HeadMushroom:addShrooms(amount)
    for i = 1, amount do
        if #self.shroomstack > 5 then
            break
        end
        local shroom = Sprite("world/events/head_mushroom", 0, 0)
        shroom.y = -shroom.height - (i * 14) - 9

        table.insert(self.shroomstack, shroom)
        table.insert(self.size, 1)
        table.insert(self.xdist, 0)
        table.insert(self.ydist, 0)
        self:addChild(shroom)
    end
    Assets.stopAndPlaySound("crowngrowth", 0.8, math.min(1.4 + (0.05 * #self.shroomstack), 2.7))
end

function HeadMushroom:update()
    super.update(self)

    local pvx = self.parent.moving_x
    local pvy = self.parent.moving_y

    local xdiff = MathUtils.clamp(pvx, -2, 2)
    local ydiff = MathUtils.clamp(pvy / 2, -6, 6)
    local stacksize = 14

    for i, shroom in ipairs(self.shroomstack) do
        self.size[i] = MathUtils.lerp(self.size[i], 1, 0.5)

        self.xdist[i] = MathUtils.lerp(self.xdist[i], xdiff * (0.8 * (i - 1)), 0.15)
        self.ydist[i] = MathUtils.lerp(self.ydist[i], ydiff * (0.5 * (i - 1)), 0.15)

        shroom.x = -self.xdist[i]
        shroom.y = -shroom.height - (i * stacksize) - self.ydist[i] + math.abs(self.xdist[i] / 5) - 9
    end
end

function HeadMushroom:draw()
    super.draw(self)
    if DEBUG_RENDER then
        love.graphics.print(tostring(#self.shroomstack), 0, -20)
        for index, shroom in ipairs(self.shroomstack) do
            love.graphics.rectangle("line", shroom.x, shroom.y, shroom.width, shroom.height)
        end
    end
end

return HeadMushroom
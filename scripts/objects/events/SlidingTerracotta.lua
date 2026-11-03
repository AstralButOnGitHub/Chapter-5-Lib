---@class SlidingTerracotta : Event
---@overload fun(...) : SlidingTerracotta
local SlidingTerracotta, super = Class(Event)

-- i coded this one basically from scratch all in 1 night so it's kinda shit
function SlidingTerracotta:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self:setSprite("world/events/terracotta_overworld")
    self:setHitbox(69, self.height - 107, 80, 18)
    self.movecollider = Hitbox(self, 69, self.height - 107, 80, 18)
    self.ittybittycollider = Hitbox(self, 104, self.height - 103, 10, 10)
    self:setOrigin(0.5, 0.5)
    self.solid = true

    self.con = 0
    self.timer = 0
    self.movedir = nil
    self.moving = false
    self.invalid_pushes = 0
    self.interactable = true
    self.fake_height = 0
end

function SlidingTerracotta:getSortPosition()
    return self:getRelativePos(0, self.height - 100)
end

function SlidingTerracotta:collisionCheck(x, y)
    x = x or 0
    y = y or 0
    if self.movedir == "up" then
        self.movecollider:setBounds(99 + x, (self.height - 134) + y, 20, 44)
    elseif self.movedir == "down" then
        self.movecollider:setBounds(99 + x, (self.height - 107) + y, 20, 44)
    elseif self.movedir == "left" then
        self.movecollider:setBounds(49 + x, (self.height - 107) + y, 60, 18)
    elseif self.movedir == "right" then
        self.movecollider:setBounds(89 + x, (self.height - 107) + y, 70, 18)
    end
    for _, value in ipairs(Game.world.map.block_collision) do
        if self.movecollider:meetsCollider(value) then
            return true
        end
    end
    for _, value in ipairs(Game.stage:getObjects(SlidingTerracotta)) do
        if value ~= self and self.movecollider:meetsCollider(value.collider) then
            return true
        end
    end
    return false
end

function SlidingTerracotta:update()
    super.update(self)

    local invalid_push = false
    local dist = 40

    for _, value in ipairs(Game.world:getEvents("ObjectFallArea")) do
        if self.ittybittycollider:meetsObject(value) then
            self:explode()
        end
    end

    if self.movedir ~= nil and not self.moving then
        local dists = {
            ["up"] = {0, -1},
            ["down"] = {0, 1},
            ["left"] = {-1, 0},
            ["right"] = {1, 0}
        }
        if self.movedir ~= nil then
            if not self:collisionCheck() and not Game.world:hasCutscene() then
                self.moving = true
                local target_x = self.x + (dists[self.movedir][1] * dist)
                local target_y = self.y + (dists[self.movedir][2] * dist)

                Assets.playSound("wing", 0.3, 1)
                Game.world:startCutscene(function (cutscene, ...)
                    cutscene:wait(10 / 30)
                end)
                Game.world.timer:tween(10 / 30, self, { x = target_x, y = target_y }, "out-sine", function()
                    self.movedir = nil
                    self.moving = false
                end)
            else
                invalid_push = self:collisionCheck(0, -dist) and self:collisionCheck(0, dist)
                self.movedir = nil
            end
        end

        if (invalid_push) then
            self.invalid_pushes = self.invalid_pushes + 1

            if (self.invalid_pushes > 2) then
                self.solid = false
                self.interactable = false

                self.con = -99999
                local effect = math.random(1, 3)

                if (effect == 1) then
                    self.y = self.y + (0.6 * self.height)
                    self.sprite.scale_y = 0.2
                    self.layer = self.layer - 1
                    Game.world.timer:after(20/30, function()
                        self:remove()
                    end)
                    Assets.playSound("splat")
                elseif (effect == 2) then
                    Assets.playSound("wing")
                    local sprite = Sprite("effects/poof", 40, 0)
                    sprite:setScale(2, 2)
                    sprite:play(0.0625, false, function(sprite)
                        self:remove()
                    end)
                    self:addChild(sprite)

                    Game.world.timer:after(8/30, function()
                        self.sprite:remove()
                    end)
                elseif (effect == 3) then
                    Assets.playSound("jump")
                    self.fake_height = 0
                    Game.world.timer:tween(40/30, self, { fake_height = (380 * 2) }, "in-out-circ")
                    Game.world.timer:after(40/30, function()
                        self:remove()
                    end)
                end
            else
                self:shake()
                Assets.playSound("noise")
            end
        else
            -- Assets.playSound("wing")
        end
    end
end

function SlidingTerracotta:onInteract(player, dir)
    super.onInteract(self, player, dir)

    if not self.moving and self.interactable then
        self.con = 3
        self.timer = 0
        self.movedir = dir
    end
end

function SlidingTerracotta:draw()
    local sc = math.abs(self.fake_height) / 4
    Draw.setColor(COLORS.black, 0.5)
    Draw.draw(Assets.getTexture("effects/dropshadow"), self.sprite.width / 2, self.sprite.height, 0, math.min(4, (self.scale_x or 1) * 2 * sc), math.min(4, (self.scale_y or 1) * sc), 0.5, 1)
    love.graphics.translate(0, -(self.fake_height * 4))
    super.draw(self)
    if DEBUG_RENDER then
        self.movecollider:draw(1, 1, 0, 1)
        self.ittybittycollider:draw(0, 1, 1, 1)
    end
end

return SlidingTerracotta
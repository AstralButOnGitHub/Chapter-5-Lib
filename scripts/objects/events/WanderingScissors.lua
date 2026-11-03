---@class WanderingScissors : Event
---@overload fun(...) : WanderingScissors
local WanderingScissors, super = Class(Event)

function WanderingScissors:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self:setSprite("world/events/watering/scissor_nodancer", 0.15)
    self.sprite:pause()

    self:setHitbox(10, 10, 20, 20)
    self:setOrigin(0.5, 0.5)
    self.x = self.x + 20
    self.y = self.y + 20

    self.can_rotate = self.properties["can_rotate"]
    if self.can_rotate == nil then
        self.can_rotate = true
    end
    self.always_move = self.properties["always_move"]
    if self.always_move == nil then
        self.always_move = false
    end
    self.moving_battlezone = self.properties["moving_battlezone"]
    if self.moving_battlezone == nil then
        self.moving_battlezone = false
    end

    self.facing = self.properties["direction"] or "right"

    self.rotation = self:getRotation(self.facing)

    self.moving = false
    self.turning = false
    self.target_rotation = self.rotation
    self.target_x = self.x
    self.target_y = self.y

    self.cut_zone = Hitbox(self, 58, 18, 4, 4)
    self.soundpitch = 1
    self.fading = false

    self.speed = self.properties["speed"] or 6.5
    self.cut_sound = self.properties["cut_sound"] or "board_lift"

    self.bullet = Game.world:addChild(WorldBullet(0, 0))
    self.bullet.collider = Hitbox(self, self.width/4, self.height/4, self.width/2, self.height/2)
    self.bullet.damage = 15
    self.jumping = false
    self.afterjumptimer = 0
end

function WanderingScissors:getRotation(rot)
    local dir_angles = {
        ["right"] = 0,
        ["down"] = 90,
        ["left"] = 180,
        ["up"] = 270
    }
    return math.rad(dir_angles[rot] or 0)
end

function WanderingScissors:remove()
    self.bullet:remove()
    super.remove(self)
end

function WanderingScissors:jumpTo(x, y, rot)
    if self.jumping then
        return
    end
    Assets.playSound("wing")
    self.jumptimer = 0
    self.moving = false
    self.jumping = true
    self.prex = self.x
    self.prey = self.y
    self.jumpx = x
    self.jumpy = y
    self.prerot = self.rotation % math.rad(360)
    self.jumprot = self:getRotation(rot)
end

function WanderingScissors:getSortPosition()
    return self.x + (self.bullet.collider.width / 2), self.y + (self.bullet.collider.height / 2)
end

function WanderingScissors:findFlower()
    for _, type in ipairs({"WaterableFlower", "WaterableFlowerSmall", "VineCuttable"}) do
        for _, flower in ipairs(self.world.map:getEvents(type)) do
            if flower:meetsCollider(self.cut_zone) and flower.canCut and flower:canCut() then
                self:goForward()
                self.flower = flower
                return true
            end
        end
    end

    if self.always_move then
        self:goForward()
    end

    return false
end

function WanderingScissors:update()
    super.update(self)
    if self.jumping then
        self.jumptimer = self.jumptimer + 1/24
        self.sprite.frame = 2
        self.x = MathUtils.lerp(self.prex, self.jumpx, self.jumptimer)
        self.y = MathUtils.lerp(self.prey, self.jumpy, self.jumptimer) + MathUtils.lerp(0, -75, 4 * self.jumptimer * (1 - self.jumptimer))
        self.rotation = MathUtils.lerp(self.prerot, self.jumprot, self.jumptimer)
        if self.jumptimer >= 1 then
            self.jumping = false
            self.x = self.jumpx
            self.y = self.jumpy
            self.rotation = self.jumprot
            self.target_rotation = self.rotation
            self.soundpitch = 1
            self:updateFacing()
            self.afterjumptimer = 1
        end
        return
    end
    if self.afterjumptimer > 0 then
        self.afterjumptimer = self.afterjumptimer - 1/15
        self.sprite.frame = 2
        return
    end
    if Game.world.menu ~= nil then
        self.sprite.frame = 1
        return
    end
    if self.fading == false then
        for _, zone in ipairs(self.world.map:getEvents("ScissorRemoveZone")) do
            if self:meetsObject(zone) then
                self.fading = true
                self.sprite:fadeTo(0, 1, function()
                    self:remove()
                end)
            end
        end
    end

    if not self.turning and not self.moving then
        if self:findFlower() == false then
            self:turn(90)
        end
    end

    if self.turning then
        self.rotation = MathUtils.approach(self.rotation, self.target_rotation, (10/30) * DTMULT)
        if math.abs(self.rotation - self.target_rotation) <= math.rad(1) then
            self.rotation = self.target_rotation
            self:updateFacing()
            self.turning = false
        end
    end
    if self.moving then
        self.x = MathUtils.approach(self.x, self.target_x, self.speed * DTMULT)
        self.y = MathUtils.approach(self.y, self.target_y, self.speed * DTMULT)
        if math.abs(self.x - self.target_x) <= 1 and math.abs(self.y - self.target_y) <= 1 then
            self:stopMoving()
        end
    end
end

local function scr_progress(arg0, arg1, arg2, arg3, arg4)
    return MathUtils.clamp(arg3 + (((arg0 - arg1) / (arg2 - arg1)) * (arg4 - arg3)), arg3, arg4)
end

function WanderingScissors:stopMoving(force)
    self.moving = false

    self.x = self.target_x
    self.y = self.target_y
    self:updateFacing()

    if self.flower then
        if Game.world.player ~= nil then
            local player = Game.world.player
            if player.state == "CLIMB" then
                local dist = MathUtils.dist(player.x, player.y, self.x, self.y)
                local vol = scr_progress(dist, 250, 10, 0, 1)

                if (vol > 0.1) then
                    local snd = Assets.playSound("ghostappear", vol, MathUtils.random(1.8, 2.4))
                    local fadevol = 6
                    Game.world.timer:during(6/30, function()
                        fadevol = fadevol - 1
                        snd:setVolume(vol * (fadevol / 6))
                    end)
                    -- snd_volume(snd, 0, 6)
                    Assets.playSound("noise", vol / 4, 1.2)
                end
            else
                local dist = MathUtils.dist(player.x, player.y, self.x, self.y)
                local volume = math.max(0, 1 - (dist / 300))
                local snd = Assets.playSound("board_lift", volume * self.sprite.alpha, 0.35 + self.soundpitch)
            end
            -- snd:setPosition(1, 0, 0)
        end
        self.soundpitch = self.soundpitch * 1.059
        self.flower:cut()
        self.flower = nil
    end

    if force == true then
        self.sprite:pause()
    else
        if self:findFlower() == false then
            if not self.always_move then
                self.sprite:pause()
            end
        end
    end
end

function WanderingScissors:updateFacing()
    local dirs = {
        [0] = "right",
        [90] = "down",
        [180] = "left",
        [270] = "up"
    }
    local angle_degrees = math.deg(self.rotation)
    local snapped_angle = math.floor((angle_degrees / 90) + 0.5) * 90

    self.facing = dirs[snapped_angle % 360]
end

function WanderingScissors:turn(amount)
    if self.can_rotate == false then
        return
    end
    if not self.turning and not self.moving then
        self.sprite:setFrame(1)
        self.turning = true
        self.soundpitch = 1
        self.target_rotation = self.rotation + math.rad(amount)
    end
end

function WanderingScissors:goForward()
    if not self.turning and not self.moving then
        self.moving = true
        self.sprite:resume()

        self:updateFacing()
        local dirs = {
            ["up"] = {0, -1},
            ["down"] = {0, 1},
            ["left"] = {-1, 0},
            ["right"] = {1, 0}
        }
        self.target_x = self.x + (dirs[self.facing][1] * 40)
        self.target_y = self.y + (dirs[self.facing][2] * 40)
    end
end

function WanderingScissors:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self.cut_zone:draw(1, 0, 0, 1)
        love.graphics.rotate(-self.rotation)
        love.graphics.print(tostring(self.facing), 0, -20)
        love.graphics.print("turning: "..tostring(self.turning), 0, -10)
        love.graphics.print("moving: "..tostring(self.moving), 0, 0)
    end
end

return WanderingScissors
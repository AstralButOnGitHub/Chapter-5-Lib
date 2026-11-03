local PlayerClimbState, super = HookSystem.hookScript(PlayerClimbState)

function PlayerClimbState:init(player)
    super.init(self, player)

    self.reticle_collider = Hitbox(self.player, 0, 0, 20, 20)
end

function PlayerClimbState:isOnWaterableFlower(x, y)
    if x ~= nil and y ~= nil then
        self.reticle_collider.x = x
        self.reticle_collider.y = y
    end
    for _, flower in ipairs(Game.world.map:getEvents("WaterableClimbArea")) do
        if flower:meetsCollider(self.reticle_collider) then
            return flower:canWater(), flower
        end
    end
    self.reticle_collider.x = 0
    self.reticle_collider.y = 0
    return false, nil
end

function PlayerClimbState:onEnter(old_state, settings)
    settings = settings or {}

    self:resetClimbState()

    self.player.sprite:setSprite("climb/climbing")

    self.player:setSize(20, 20)
    self.player:setOrigin(0.5, 0.5)
    self.player.collider = Hitbox(self.player, 0, 0, 20, 20)

    Game.world:detachFollowers()

    -- If we're entering the climb state, and the followers aren't already invisible, fade them out
    self.player:cancelFollowerTweens()
    if not self.player.climb_followers == true then
        for _, follower in ipairs(Game.world.followers) do
            if follower.alpha > 0 then
                table.insert(self.player.follower_tweens, Game.world.timer:tween(7 / 30, follower.color, { [1] = 0.5, [2] = 0.5, [3] = 0.5 }))
                table.insert(self.player.follower_tweens, Game.world.timer:tween(7 / 30, follower, { alpha = 0 }))
            end
        end
    end

    if settings.starting_direction ~= nil then
        self:setDirection(settings.starting_direction)
    end

    if self.player.climb_followers == true then
        for _, follower in ipairs(Game.world.followers) do
            follower:setSize(20, 20)
            follower.collider = Hitbox(follower, 0, 0, 20, 20)
        end
    end
end

-- -- fuck your @private.
-- ---@diagnostic disable-next-line: invisible
-- function PlayerClimbState:initClimbMove()
--     self.climbing_x_dir = 0
--     self.climbing_y_dir = 0

--     if self.direction == "up" then
--         self.climbing_y_dir = -40
--     elseif self.direction == "left" then
--         self.climbing_x_dir = -40
--     elseif self.direction == "right" then
--         self.climbing_x_dir = 40
--     else
--         self.climbing_y_dir = 40
--     end

--     local checkamount = 1

--     if self.jumping and self.charge_amount > 1 then
--         checkamount = self.charge_amount
--     end

--     for i = checkamount, 1, -1 do
--         local testxclimb = self.climbing_x_dir * i
--         local testyclimb = self.climbing_y_dir * i
--         local finalclimbx = self.player.x + testxclimb
--         local finalclimbx2 = (self.player.x + testxclimb) - self.climbing_x_dir

--         local found_exit, exit = self:isOverlappingObject(ClimbExit, finalclimbx2, (self.player.y + testyclimb) - self.climbing_y_dir)
--         if found_exit and exit:canExit() then
--             ---@cast exit ClimbExit

--             if self.direction == exit:getExitDirection() then
--                 self.climbing_x_dir = testxclimb
--                 self.climbing_y_dir = testyclimb
--                 Assets.playSound("wing", 0.6, 1.1 + MathUtils.random(0.1))
--                 self.player.sprite:setSprite("climb/climbing")

--                 if self.climb_frame == 1 then
--                     self.climb_frame = 3
--                 else
--                     self.climb_frame = 1
--                 end

--                 self.state = 2
--                 self.timer = 0
--             end
--         end

--         if self.state == 2 then
--             break
--         end

--         local on_flower, flower = self:isOnWaterableFlower()
--         if on_flower and self.player.climb_watering then
--             flower:startBloom("harp_strum")
--             self.state = 0
--             self.bump_state = 0
--             self.jumping = false
--             break
--         end

--         if self:isOverlappingClimbable(ClimbArea, finalclimbx, self.player.y + testyclimb) or NOCLIP then
--             self.climbing_x_dir = testxclimb
--             self.climbing_y_dir = testyclimb
--             Assets.playSound("wing", 0.6, 1.1 + MathUtils.random(0.1))
--             self.player.sprite:setSprite("climb/climbing")

--             if self.climb_frame == 1 then
--                 self.climb_frame = 3
--             else
--                 self.climb_frame = 1
--             end

--             self.state = 2
--             self.timer = 0

--             break
--         end
--     end

--     if self.state ~= 2 then
--         self.bump_timer = 8 + self.momentum * 4

--         if self.jumping then
--             self.bump_timer = 8 + self.charge_amount * 3
--         end

--         self.state = 0
--         self.bump_state = 1
--         self.jumping = false
--     end
-- end

function PlayerClimbState:drawReticle(found, alpha)
    if not self.player.climb_watering then
        if not self._draw_reticle then
            return
        end
    end
    if DEBUG_RENDER then
        self.reticle_collider:draw(1, 0, 1, 1)
    end
    if self.charge_state > 0 then
        if found > 0 then
            local px = (self.player.width / 2) - 10
            local py = (self.player.height / 2) - 10

            if self.direction == "down" then
                py = py + 20 * found
            elseif self.direction == "right" then
                px = px + 20 * found
            elseif self.direction == "up" then
                py = py - 20 * found
            elseif self.direction == "left" then
                px = px - 20 * found
            end

            local col = ColorUtils.mergeColor(COLORS.yellow, COLORS.white, 0.4 + (math.sin(self.charge_timer / 3) * 0.4))
            col[4] = col[4] * alpha

            if self.player.climb_watering and self:isOnWaterableFlower(px, py) then
                Draw.draw(Assets.getTexture("effects/climb_watering_reticle"), px, py, 0, 0.5, 0.5, 4, 4)
            else
                Draw.setColor(col)
                Draw.draw(Assets.getTexture("player/climb_reticle"), px, py, 0, 1, 1, 2, 2)
            end
        end
    end
end

return PlayerClimbState
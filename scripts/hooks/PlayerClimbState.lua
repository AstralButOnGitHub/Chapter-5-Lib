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
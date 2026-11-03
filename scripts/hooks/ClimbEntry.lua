local ClimbEntry, super = HookSystem.hookScript(ClimbEntry)

function ClimbEntry:onInteract(player, dir)
    if self.data.properties.followers == true then
        local x, y = self.target:getRelativeJumpTarget()
        local world_x, world_y = self.target:getRelativePos(x, y, Game.world)

        local target_x, target_y = Game.world:getRelativePos(world_x, world_y, player.parent)

        local exit_direction = self.target:getExitDirection()
        local facing_direction = nil

        if exit_direction == "up" then
            facing_direction = "down"
        elseif exit_direction == "down" then
            facing_direction = "up"
        elseif exit_direction == "left" then
            facing_direction = "right"
        elseif exit_direction == "right" then
            facing_direction = "left"
        end

        player:setState("CLIMB_MOUNT", {
            target_x = target_x,
            target_y = target_y,
            facing_direction = facing_direction,
            followers = true
        })

        return true
    else
        super.onInteract(self, player, dir)
    end
end

return ClimbEntry
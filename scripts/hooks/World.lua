local World, super = HookSystem.hookScript(World)

function World:update()
    super.update(self)

    if self.player and self.player.held_object ~= nil and self.player.held_object:includes(WateringCan) then
        self.battle_alpha = 0
        for _, battle_border in ipairs(self.map.battle_borders) do
            battle_border.alpha = 0
        end
    end
end

function World:shouldBulletsHurt()
    if self.player and self.player:isClimbing() then
        return true
    end

    if self:getEvent("WanderingScissors") ~= nil then
        return self:inBattle() and self.menu == nil
    end

    return self:inBattle()
end

function World:canOpenMenu()
    if self:hasCutscene() then
        return false
    end

    if self:inBattle() and self:getEvent("WanderingScissors") == nil then
        return false
    end

    if self.player and self.player:isClimbing() then
        return false
    end

    if not self.can_open_menu then
        return false
    end

    return true
end

return World
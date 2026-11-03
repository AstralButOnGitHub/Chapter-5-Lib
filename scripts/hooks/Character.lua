local Character, super = HookSystem.hookScript(Character)

function Character:init(actor, x, y)
    self.draw_fusuma_shadow = true
    super.init(self, actor, x, y)
    self.steps = 1
end

function Character:onFootstep(num)
    super.onFootstep(self, num)
    if Game.world then
        for _, sand in ipairs(Game.world:getEvents("ZenSand")) do
            if self:meetsObject(sand) then
                local _foot = self.actor.zen_footprints[self.facing];
                sand:createPrint(self.x, self.y - 20, _foot, 1, self.facing, true);
                self.steps = self.steps + 1
            end
        end
    end
end

return Character
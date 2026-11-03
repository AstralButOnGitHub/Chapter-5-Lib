local Follower, super = HookSystem.hookScript(Follower)

function Follower:init(chara, x, y, target)
    super.init(self, chara, x, y, target)
    self.blooming = false
    self.bloom_timer = 0
    self.followmode = 1
end

function Follower:update()
    super.update(self)
    local can_bloom = self.actor.can_bloom

    if can_bloom and self.bloom_timer >= 5 then
        if not self.blooming then
            self:setFacing("down")
            self.flower_sprite = Sprite("party/flower_only", 0, -6)
            self.flower_sprite:play(3/30, false)
            Assets.playSound("harp_strum", 1, 1.1)
            self:addChild(self.flower_sprite)
        end
        self.blooming = true
    end

    -- local _dir = dir
    -- obj_climb_susie
    if Game.world.player and Game.world.player.climb_followers == true then
        if (self.followmode == 1) then
            if (Game.world.player.y < self.y) then
                self.climb_direction = "down"
            else
                self.climb_direction = "up"
            end
        end
    end
end

function Follower:move(x, y, speed, keep_facing)
    super.move(self, x, y, speed, keep_facing)
    self.blooming = false
    if self.flower_sprite ~= nil then
        self.flower_sprite:remove()
        self.flower_sprite = nil
    end
    self.bloom_timer = 0
end

return Follower
---@class Player : Character, StateManagedClass
local Player, super = HookSystem.hookScript(Player)

function Player:init(chara, x, y)
    super.init(self, chara, x, y)

    self.torii_dash_state = ToriiDashState(self)
    self.state_manager:addState("TORII_DASH", self.torii_dash_state)

    self.watering_can_type = nil
    self.held_object = nil
    self.watering = false
    self.watering_face = "left"
    self.has_reset_watering_walk_sprite = false
    self.input_lock = false
    self.prev_held_object = nil
    self.bark_timer = 0
    self.shook_screen = false
    self.item_outline_alpha = 0
    self.climb_followers = false
end

function Player:beginClimbMount(last_state, settings)
    settings = settings or {}
    if settings.followers == true then
        Game.lock_movement = true

        Game.world:detachFollowers()

        self.climb_mount_target_x = settings.target_x or self.x
        self.climb_mount_target_y = settings.target_y or self.y

        self.climb_facing_direction = settings.facing_direction

        if self.climb_facing_direction == nil then
            -- If a facing direction isn't supplied, let's try to guess one...
            self.climb_facing_direction = Utils.facingFromAngle(MathUtils.angle(self.x, self.y, self.climb_mount_target_x, self.climb_mount_target_y))
        end

        self:jumpTo(self.climb_mount_target_x, self.climb_mount_target_y + self:getScaledHeight() / 2, 8, 8 / 30, "jump_ball_slow")

        self:cancelFollowerTweens()

        for i, follower in ipairs(Game.world.followers) do
            follower.alpha = 1
            follower.visible = true
            follower:jumpTo(self.climb_mount_target_x - (i == 1 and -40 or 40), self.climb_mount_target_y, 8, 8 / 30, "jump_ball_slow")
            Game.world.timer:after(9 / 30,function ()
                follower:setOrigin(0.5, 0.5)
                follower:setSprite("climb/climbing")
                follower:setOrigin(0.5, 0.5)
            end)
        end
        self.climb_followers = true

        self.climb_mount_callback = settings.post_jump
    else
        super.beginClimbMount(self, last_state, settings)
    end
end

function Player:canWater()
    return self.input_lock == false and
        self.held_object ~= nil and
        self.held_object:includes(WateringCan) and
        not Game.world:hasCutscene() and
        Game.world:canInteract() and
        Game.world.menu == nil and
        self.state ~= "TORII_DASH" and
        self.state ~= "CLIMB_MOUNT" and
        self.state ~= "CLIMB_DISMOUNT"
end

function Player:update()
    super.update(self)

    if not Input.down("confirm") then
        self.input_lock = false
    end

    local near_scissors = false
    for _, scissors in ipairs(Game.world.map:getEvents("WanderingScissors")) do
        if MathUtils.dist(self.x, self.y, scissors.x, scissors.y) < 120 and scissors.moving_battlezone then
            near_scissors = true
            break
        end
    end
    Game.world:setBattle(near_scissors and self.state ~= "CLIMB")

    local can_held = self.held_object ~= nil and self.held_object:includes(WateringCan)
    local netskie_held = self.held_object ~= nil and self.held_object:includes(NetskieObject)
    local mushroom_held = self.held_object ~= nil and self.held_object:includes(HeadMushroom)

    if Input.down("confirm") then
        if can_held and not self:canWater() then
            self.input_lock = true
        elseif can_held and self.prev_held_object == nil then
            self.input_lock = true
        end
    end
    self.prev_held_object = self.held_object

    if netskie_held and not Game.world:hasCutscene() and Game.world:canInteract() and Game.world.menu == nil and Input.pressed("confirm") then
        self.held_object:onPress(self, self.facing)
    end

    self.watering = Input.down("confirm") and self:canWater()
    self.climb_watering = (self.state == "CLIMB" or self.state == "CLIMB_MOUNT" or self.state == "CLIMB_DISMOUNT") and self.held_object ~= nil

    if Input.down("confirm") and not self.watering and can_held then
        self.input_lock = true
    end

    if self.watering and not can_held then
        self.watering = false
    end

    if can_held and not self.watering and self.facing ~= "up" and self.facing ~= "down" then
        self.watering_face = self.facing
    end

    if self.watering and can_held then
        if self.watering_can_type == "medium" and self.shook_screen == false then
            Game.world:shakeCamera(10, 10)
            Assets.playSound("whip_crack_only")
            self.shook_screen = true
        end
        self.has_reset_watering_walk_sprite = false
        if not self.climb_watering then
            if self.held_object.water_sound == "pombark" then
                self.bark_timer = self.bark_timer - DTMULT
                if self.bark_timer <= 0 then
                    Assets.stopAndPlaySound("pombark", MathUtils.random(0.8, 0.9), MathUtils.random(0.2, 0.4))
                    self.bark_timer = 6
                end
            else
                if self.water_sound == nil then
                    self.water_sound = Assets.playSound(self.held_object.water_sound)
                    self.water_sound:setLooping(true)
                end
            end
        else
            if self.water_sound then
                self.water_sound:stop()
                self.water_sound = nil
            end
            self.bark_timer = 0
        end

        if not self.climb_watering and not self.sprite.walk_override then
            self.sprite:setWalkSprite(self.watering_can_type.."/"..self.watering_face)
        end
    else
        self.shook_screen = false
        self.bark_timer = 0
        if self.water_sound then
            self.water_sound:stop()
            self.water_sound = nil
        end
        if self.has_reset_watering_walk_sprite == false and not self.climb_watering then
            self.has_reset_watering_walk_sprite = true
            self:resetSprite()
        end

        if self.held_object ~= nil then
            if can_held then
                local facingleft = self.watering_face == "left"

                local canheadx, canheady = self.held_object:getHeadPosition()
                local canclmbheadx, canclmbheady = self.held_object:getClimbingHeadPosition()
                if not self.climb_watering then
                    self.held_object.x = (facingleft and self.held_object.width - 3 or 0) + canheadx
                    self.held_object.y = (-self.held_object.height) + 2 + canheady
                else
                    facingleft = self.climb_state.direction == "left"
                    self.held_object.x = (facingleft and self.held_object.width - 3 or 0) + canclmbheadx
                    self.held_object.y = (-self.held_object.height) + 2 + canclmbheady
                end
                self.held_object.scale_x = (facingleft and -1 or 1)
            elseif mushroom_held then
                self.held_object.x = 4
                self.held_object.y = (-self.held_object.height) + 15 + (self.sprite.frame % 2 == 1 and 0 or 1)
            end
        end
    end

    if self.held_object and self.held_object:includes(WateringCan) then
        self.held_object:updateWatering(self)
        local outlinefx = self.outlinefx --[[@as BattleOutlineFX]]
        self.item_outline_alpha = self.battle_alpha
        outlinefx:setAlpha(0)
    end
end

function Player:draw()
    super.draw(self)

    if self.held_object ~= nil and self.held_object:includes(WateringCan) then
        local sprite_path = ""
        if self.watering and self.watering_face ~= nil then
            sprite_path = self.sprite.path.."/"..self.watering_can_type.."/"..self.watering_face.."_heart_"..self.sprite.frame
        else
            sprite_path = self.sprite.path.."/walk/"..self.facing.."_heart_"..self.sprite.frame
        end
        love.graphics.setColor(1, 1, 1, self.item_outline_alpha)
        local offset = self.sprite:getOffset()
        local sprite = Assets.getTexture(sprite_path)
        if sprite ~= nil then
            love.graphics.draw(sprite, offset[1]-1, offset[2]-1)
        end
        love.graphics.setColor(1, 1, 1, 1)

        self.held_object:drawWaterStream(self)
    end

    if DEBUG_RENDER then
        if self.state == "TORII_DASH" then
            if self.slopecollider then
            self.slopecollider:draw()
            end
            if self.flip_x == true then
                love.graphics.scale(-1, 1)
            end
            local manager = self.state_manager:getHandler(self.state)
            love.graphics.print("substate: "..tostring(manager.substate), 0, -10, 0, 1)
            love.graphics.print("targetyspeed: "..tostring(manager.targetyspeed), 0, 0, 0, 1)
            love.graphics.print("dash_dir: "..tostring(manager.dash_dir), 0, 10, 0, 1)
        end
    end
end

return Player
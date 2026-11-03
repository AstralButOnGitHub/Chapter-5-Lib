---@class ToriiDashState : StateClass
---
---@field player Player
---
---@overload fun(player: Player) : ToriiDashState
local ToriiDashState, super = Class(StateClass)

-- it took me like 40 minutes of trial and error to find out I had to put this in *hooks*
function ToriiDashState:init(player)
    self.player = player

    self.dash_x_accel = 1
    self.dash_y_accel = 3
    self.runspeed = 15
    self.runspeed_max = self.runspeed

    self.slode = false
    self.dash_dir = "right"
    self.targetxspeed = 0
    self.targetyspeed = 0
    self.splash_counter = 0
    self.in_mud = false
end

function ToriiDashState:registerEvents()
    self:registerEvent("update", self.onUpdate)
end

function ToriiDashState:handleMovement()
    self.player.x = self.player.x + 2
end

function ToriiDashState:onUpdate()
    if self.substate == "TORII_DASH" then
        self.player.physics.speed_x = self.runspeed
        -- self.player.physics.
        local vinput = ((Input.down("down") and 1 or 0) - (Input.down("up") and 1 or 0))
        self.slopecollider = self.player.collider:clone()
        self.slopecollider.x = self.slopecollider.x + (self.slopecollider.width - math.abs(vinput * 2))
        self.slopecollider.y = self.slopecollider.y + (vinput * 2.5)

        for _, collider in ipairs(Game.world.map.collision) do
            if self.slopecollider:meetsCollider(collider) and collider:includes("PolygonCollider") then
                vinput = 0
            end
        end

        self.targetyspeed = vinput * 8
        self.targetxspeed = (self.runspeed * MathUtils.sign(self.player.width))

        self.player.physics.speed_y = Mod:scr_clamp_gradual(self.player.physics.speed_y, self.targetyspeed, self.targetyspeed, 3)
        for _, mudzone in ipairs(Game.world.map:getEvents("MudZone")) do
            if self.player:meetsObject(mudzone) then
                if self.in_mud == false then
                    self.in_mud = true
                    self.spalsh = Sprite("effects/dash_splash_dark", -4, self.player.height -12)
                    self.spalsh:setSprite("effects/dash_splash_dark")
                    self.spalsh:play(1/30, true)
                    self.player:addChild(self.spalsh)
                end

                if self.splash_counter == 3 then
                    self.splash_counter = 0
                    -- scr_make_ripple(x, y + 30, 120, 4600106, 400, 20, 16, 1999000, hspeed * 0.5, 0, 0, 0, 3);
                    Assets.playSound("splash", 0.15, MathUtils.random(1.6, 1.8))
                    local spalsh = Sprite("effects/dash_ripple_dark_1", self.player.x, self.player.y)
                    spalsh:setSprite("effects/dash_ripple_dark")
                    spalsh:play(0.1, false, function(sprite)
                        spalsh:remove()
                    end)
                    Game.world:addChild(spalsh)
                else
                    self.splash_counter = self.splash_counter + 1
                end
            else
                if self.in_mud == true then
                    self.in_mud = false
                    self.spalsh:remove()
                    self.spalsh = nil
                end
            end
        end
    elseif self.substate == "TORII_DASH_START" then
        if not self.slode then
            Game.world.can_open_menu = false
            self.runspeed = self.toriigate.runspeed
            self.runspeed_max = self.runspeed

            if self.dash_dir == "left" then
                self.player.flip_x = true
            end
            self.player:setFacing(self.dash_dir)
            self.runspeed = math.abs(self.runspeed) * (self.dash_dir == "left" and -1 or 1)

            self.slode = true
            self.player:setSprite("plat_land_2")
            Assets.stopAndPlaySound("wing", 1, 1, true)
            local koffx = 24 * 2
            local koffy = 38 * 2
            local roffx = 24 * 2
            local roffy = 30 * 2
            local soffx = 24 * 2
            local soffy = 48 * 2
            self.player:slideTo(self.toriigate.x + koffx, self.toriigate.y + self.toriigate.height - koffy, 0.2, "linear", function()
                self:dashAfterImageThingy(self.player.sprite.texture, self.player.x, self.player.y, self.player.width, self.player.height)
                self:dashAfterImageThingy(self.toriigate.sprite.texture, self.toriigate.x, self.toriigate.y, self.toriigate.width, self.toriigate.height, {1, 160/255, 70/255, 1}, true)
                Game.world.timer:after(0.3, function()
                    Assets.stopAndPlaySound("weaponpull_fast", 1, 1, true)
                    self.player:setSprite("plat_run")
                    self:start_running(self.player, (self.dash_dir == "left" and -1 or 1), COLORS.white, true)
                    self:start_running(self.player, (self.dash_dir == "left" and -1 or 1), COLORS.fuchsia, false)
                    self:start_running(self.player, (self.dash_dir == "left" and -1 or 1), COLORS.lime, false)
                    self.player:play(3/30, true)
                end)
            end)
            for _, chara in pairs(Game.world.followers) do
                local charaxoff = koffx
                local charayoff = koffy
                chara.predash_follow_delay = chara.follow_delay
                chara.follow_delay = 0.1
                if chara.actor.name == "Ralsei" then
                    charaxoff = roffx
                    charayoff = roffy
                elseif chara.actor.name == "Susie" then
                    charaxoff = soffx
                    charayoff = soffy
                end
                if self.dash_dir == "left" then
                    chara.flip_x = true
                end
                chara:setSprite("plat_land_1")
                local target_x = self.toriigate.x + charaxoff
                local target_y = self.toriigate.y + self.toriigate.height - charayoff

                chara:slideTo(target_x, target_y, 0.2, "linear", function()
                    chara:setPosition(target_x, target_y)
                    self:dashAfterImageThingy(chara.sprite.texture, chara.x, chara.y, chara.width, chara.height)
                    Game.world.timer:after(0.3, function()
                        chara:setSprite("plat_run")
                        chara:play(3/30, true)
                        self.substate = "TORII_DASH"
                    end)
                end)
            end
        end

    elseif self.substate == "TORII_DASH_END" then
        self.slode = false
        Game.world.can_open_menu = true
        self.player.physics.speed_y = 0
        self.player.physics.speed_x = 0
        self.player:setSprite("plat_halt")
        Assets.stopAndPlaySound("wing", 1, 1, true)
        self.player:slideTo(self.toriigate.x + (self.dash_dir == "left" and -80 or 160), self.player.y, 0.5, "linear", function()
            self.player.toriigate = nil
            self.player:setFacing(self.dash_dir)
            self.player.flip_x = false
            self.player:resetSprite()
        end)
        for i, chara in pairs(Game.world.followers) do
            chara:setSprite("plat_halt")
            chara:slideTo(self.toriigate.x + (self.dash_dir == "left" and -80 or 160), chara.y, 0.5, "linear", function()
                chara.follow_delay = chara.predash_follow_delay
                chara:setFacing(self.dash_dir)
                chara.flip_x = false
                chara:resetSprite()
                chara.history = {}
            end)
        end
        self.player:setState("WALK")
    end
end

function ToriiDashState:start_running(chara, dashdir, color, spawnleaves)
    if (chara == -4) then
        return
    end

    local xx = chara.x;
    local yy = chara.y;

    local dashsprite = Sprite(Assets.getTexture("effects/vfx_directional_hit"), xx - 20, yy - 45)
    dashsprite:setOrigin(0.5, 0.5)
    dashsprite.scale_x = dashsprite.scale_x * (2 * dashdir)
    dashsprite.scale_y = dashsprite.scale_y * 2
    dashsprite:setSprite("effects/vfx_directional_hit")
    dashsprite:play(6/30, false, function(sprite)
        dashsprite:remove()
    end)
    dashsprite.layer = chara.layer + 1000
    dashsprite.color = ColorUtils.mergeColor(color, COLORS.white, 0.8)
    Game.world:addChild(dashsprite)

    if (spawnleaves) then
        for i = 0, 20, 1 do
            -- with (instance_create(xx, yy, obj_marker_fancy))
            -- {
            --     if (i_ex(obj_sunshadows)) then
            --         depth = obj_sunshadows.depth - 100;
            --     end
            --     sprite_index = spr_spin_petal;
                
            --     draw_func = function(
            --         with (obj_parallax_cliffs)
            --             other.image_blend = merge_color(c_gray, c_white, suny);
                    
            --         draw_self();
            --     end)
                
            --     scr_darksize();
            --     image_speed = 0.5 - random(0.25);
            --     image_index = random(5);
            --     hspeed = dashdir * (-8 - random(16));
            --     vspeed = random_range(-8, 8);
            --     friction = 0.5;
            --     scr_doom(id, 50);
            -- end
        end
    end
end

function ToriiDashState:dashAfterImageThingy(texture, x, y, width, height, color, is_gate)
    color = color or COLORS.white
    local spawn_x = is_gate and x or (x - width)
    local spawn_y = is_gate and y or (y - (height * 2))

    local after_image = Sprite(texture, spawn_x, spawn_y)
    after_image:addFX(ColorMaskFX(color, 1), tostring(texture))

    if Game.world.player.dash_dir == "left" and not is_gate then
        after_image.flip_x = true
    end

    after_image:setScale(2, 2)
    after_image.color = {1, 1, 1}

    if is_gate and Game.world.player.toriigate then
        after_image.layer = Game.world.player.toriigate.layer + 1000
    else
        after_image.layer = after_image.layer + 0.5
    end

    after_image:fadeOutSpeedAndRemove(0.06)

    if not is_gate then
        local target_x = (after_image.x + (after_image.flip_x and (after_image.width * after_image.scale_x) or -(after_image.width * after_image.scale_x)))
        local target_y = (after_image.y - (after_image.height * after_image.scale_y))

        Game.world.timer:tween(0.08 * 30, after_image, {
            scale_x = after_image.scale_x * 2,
            scale_y = after_image.scale_y * 2,
            x = target_x,
            y = target_y
        })
    end

    Game.world:addChild(after_image)
end

return ToriiDashState
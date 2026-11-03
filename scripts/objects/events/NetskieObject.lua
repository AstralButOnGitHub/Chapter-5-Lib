---@class NetskieObject : Event
---@overload fun(...) : NetskieObject
local NetskieObject, super = Class(Event)

-- based on obj_dw_garden_secretfox
function NetskieObject:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
    self.style = self.properties["style"] or "rock"
    self.canshowtail = self.properties["can_show_tail"]
    if self.canshowtail == nil then
        self.canshowtail = false
    end
    self.show_tail = self.properties["show_tail"]
    if self.show_tail == nil then
        self.show_tail = true
    end
    self.shouldbesolid = self.properties["solid"]
    if self.shouldbesolid == nil then
        self.shouldbesolid = false
    end
    self.solid = self.shouldbesolid

    self:setSprite("world/events/netskie/"..self.style)

    self.can_interact = false
    self.con = 0
    self.timer = 0
    self.startx = self.x
    self.starty = self.y
    self.anchor_x = self.startx
    self.anchor_y = self.starty
    self.offsetx = 0
    self.offsety = 0
    self.yoffset = -10
    self.eatspeed = 1 / 30
    self.watering_cans = false
    self.pickup_cooldown = 0
    self.target_object = nil
    self.fromtile = nil
    self.tile_layer = nil
    self.fromasset = nil

    self.x_lerp = nil
    self.y_lerp = nil
    self.had_manual_check = -1

    self.shroom = nil

    self.poofframe = -1
    self.lastx = self.x
    self.lasty = self.y

    self.held = false
    self.mushroom_detection_range = 9999
    self.manual_check = true
    self.bromide_muted = false
    self.revealed = false

    self.text = TiledUtils.parsePropertyMultiList("text", self.properties)
    self.cutscene = self.properties["cutscene"] or nil
end

function NetskieObject:onLoad()
    super.onLoad(self)
    self.xstart = self.x
    self.ystart = self.y
end

function NetskieObject:update()
    super.update(self)

    self.solid = self.shouldbesolid and not self.revealed

    self.timer = self.timer + MathUtils.round(DTMULT)
    self.pickup_cooldown = self.pickup_cooldown - (1)

    if self.held then
        return
    end
    if (self.con == 0) then
        if (self.manual_check and (self.timer % 10) == 0) then
            self:appear()
        end
    elseif (self.con ~= 1 or self.timer >= 16) then
        -- scr_depth()
    end

    if (self.con == 1) then
        if (self.timer == 16) then
            self:setSprite("world/events/netskie/idle", 0.25)
            self.revealed = true
            local sprite = Sprite("effects/poof", -80, -60)
            sprite.layer = self.layer + 1
            sprite:setScale(2, 2)
            sprite:play(0.0625, false, function(sprite)
                sprite:remove()
            end)
            self:addChild(sprite)

            if (not self.bromide_muted) then
                Assets.stopAndPlaySound("wing")
            end
        end

        if (self.timer == 20) then
            self.x = self.x + self.offsetx
            self.y = self.y + self.offsety
            self.anchor_x = self.x
            self.anchor_y = self.y
        end

        if (self.timer == 22) then
            self.visible = true

            if self.target_object ~= nil then
                self.target_object.x = -999
            end
        end

        if (self.timer == 32) then
            if (self.canshowtail) then
                self.showtail = true
            end

            if self.shroom ~= nil then
                self.con = 2
            else
                self.con = 100
            end

            self.timer = 1
        end
    end

    if (self.con == 2) then
        if (self.timer == 1) then
            self.startx = self.x
            self.starty = self.y
            self:setSprite("world/events/netskie/run", 0.5 / 6)
            self.revealed = true
            local scale = MathUtils.sign(self.shroom.x - self.x)
            local whackoffset = 0
            if (scale ~= 0) then
                self.scale_x = scale
            end
            if scale == -1 then
                whackoffset = self.width
            end
            self:slideTo(self.shroom.x+whackoffset, self.shroom.y-(self.height/2),  15 / 30, "linear")
        end

        if self.shroom == nil then
            self.con = 2.5
            self.timer = 0
            self:setSprite("world/events/netskie/idle")
            self.revealed = true
            return
        end

        if (self.timer >= 20) then
            self.con = 3
            self.timer = 0

            if (not self.bromide_muted) then
                Assets.stopAndPlaySound("chomp", 0.7, 1.5)
            end

            self:setSprite("world/events/netskie/eat", 1/3)
            self.revealed = true
            local scale = MathUtils.sign(self.shroom.x - self.x) * 2

            if (scale ~= 0) then
                self.width = scale
            end
        end
    end

    if (self.con == 2.5) then
        if (self.timer == 30) then
            self:find_new_shroom()
        end
    end

    if (self.con == 3) then
        if self.shroom ~= nil then
            local shrinkspeed = 0.15 * self.eatspeed
            self.shroom.width = self.shroom.width - shrinkspeed
            self.shroom.height = self.shroom.height - shrinkspeed
            self.shroom.physics.speed_x = 0
            self.shroom.physics.speed_y = 0
            self.shroom.state = 1
            self.shroom.fakeheight = 0

            if (self.shroom.width < 0) then
                self.shroom:remove()

                -- if (watering_cans) then
                --     global.flag[1368] = -1
                --     global.flag[1363] = 1
                -- }

                self.con = 4
                self.timer = 0
            end
        else
            self.con = 4
            self.timer = 0
        end
    end

    if (self.con == 4) then
        if (self.timer == 10) then
            self:find_new_shroom()
        end
    end

    if (self.con == 100) then
        if (self.timer == 1) then
            self:slideTo(self.anchor_x, self.anchor_y,  15 / 30, "linear")

            self:setSprite("world/events/netskie/run", 0.5 / 6)
            local scale = MathUtils.sign(self.anchor_x - self.x)

            if (scale ~= 0) then
                self.scale_x = scale
            end
        end

        if (self.timer == 18) then
            self.pickup_cooldown = 20
        end

        if (self.timer == 19) then
            local sprite = Sprite("effects/poof", -80, -60)
            sprite:setScale(2, 2)
            sprite.layer = self.layer + 1
            sprite:play(0.0625, false, function(sprite)
                sprite:remove()
            end)
            self:addChild(sprite)
        end

        if (self.timer >= 23) then
            while Game.world.player and Game.world.player:meetsObject(self) do
                return
            end
            self.con = 0
            self.shroom = nil
            self.revealed = false
            self:setSprite("world/events/netskie/"..self.style)

            -- if (instance_exists(target_object)) then
            --     target_object.x = x - offsetx
            --     target_object.y = y - offsety

            --     with (target_object)
            --         scr_depth()
            -- end

            Assets.stopAndPlaySound("wing")
        end
    end
end

function NetskieObject:find_new_shroom()
    local nearest_shroom = nil
    local nearest_dist = self.mushroom_detection_range

    for _, target in ipairs(Game.stage:getObjects(PhysicsMushroom)) do
        if (not target.targeted) then
            local dist = MathUtils.dist(self.x, self.y, target.x, target.y)

            if (dist < nearest_dist) then
                nearest_shroom = target
                nearest_dist = dist
            end
        end
    end

    if (nearest_shroom) then
        if (self.con >= 2 and self.con <= 4) then
            self.con = 2
            self.timer = 0
        end

        self.anchor_x = self.xstart + self.offsetx
        self.anchor_y = self.ystart + self.offsety
        nearest_shroom.targeted = true
        self.shroom = nearest_shroom
    else
        self.anchor_x = self.xstart + self.offsetx
        self.anchor_y = self.ystart + self.offsety

        if (self.con >= 2 and self.con <= 4) then
            self.con = 100
            self.timer = 0
        end
    end
end

function NetskieObject:assign_target(arg0)
    self.target_object = arg0
    self.offsetx = 0.5 * (self.target_object.width - self.target_object.x)
    self.offsety = 0.5 * (self.target_object.height - self.target_object.y)
    self.anchor_x = self.xstart + self.offsetx
    self.anchor_y = self.ystart + self.offsety
end

function NetskieObject:appear(arg0)
    if (self.con ~= 0) then
        return
    end

    local nearest_shroom = nil
    local nearest_dist = self.mushroom_detection_range

    -- if (self.x < -200) then
    --     self.x = self.x + 10000
    -- end

    for _, target in ipairs(Game.stage:getObjects(PhysicsMushroom)) do
        if (not target.targeted) then
            local dist = MathUtils.dist(self.x, self.y, target.x, target.y)

            if (dist < nearest_dist) then
                nearest_shroom = target
                nearest_dist = dist
            end
        end
    end

    -- if (self.x >= -200) then
    --     self.x = self.x - 10000
    -- end

    if (nearest_shroom) then
        Chapter5Lib.logger:info("nearest shroom exists")
        self.con = 1
        self.timer = 0

        if (arg0) then
            self.timer = 15
        end
        self.anchor_x = self.xstart + self.offsetx
        self.anchor_y = self.ystart + self.offsety

        if (nearest_shroom.targeted) then
            self:find_new_shroom()
        end

        nearest_shroom.targeted = self
        self.shroom = nearest_shroom
    elseif (self.anchor_x ~= (self.xstart + self.offsetx) or self.anchor_y ~= (self.ystart + self.offsety)) then
        self.anchor_x = self.xstart + self.offsetx
        self.anchor_y = self.ystart + self.offsety
        self.con = 1
        self.timer = 0

        if (arg0) then
            self.timer = 15
        end
    elseif (arg0) then
        self.con = 1
        self.timer = 15
    end
end

function NetskieObject:onInteract(player, dir)
    super.onInteract(self, player, dir)

    if not self.revealed == true then
        if #self.text > 0 then
            self.interact_count = (self.interact_count or 0) + 1
            Game.world:startCutscene(function(cutscene)
                local text = self.text
                local text_index = MathUtils.clamp(self.interact_count, 1, #text)
                if type(text[text_index]) == "table" then
                    text = text[text_index]
                end
                for _, line in ipairs(text) do
                    cutscene:text(line)
                end
            end)
        end

        if self.cutscene ~= nil then
            Game.world:startCutscene(self.cutscene, self)
        end
        return
    end

    if not self.revealed == true or self.pickup_cooldown > 0 or (player.held_object ~= nil and not player.held_object:includes(HeadMushroom)) then
        return
    end

    self.pickup_cooldown = 2

    Assets.playSound("item")
    if player.held_object ~= nil then
        player.held_object:remove()
    end
    player.held_object = self
    self.held = true
    self:setParent(player)
    self:setPosition(0, -(self.height / 2) + 4)
    self:setScale(.5, .5)
    self.physics.move_path = nil
    self.physics.move_target = {}

    if self.shroom ~= nil then
        self.shroom.targeted = false
    end
end

function NetskieObject:onPress(player, dir)
    if self.held == false or self.pickup_cooldown > 0 or player.input_lock == true then
        return
    end

    -- debug text in MY deltarune??
    -- scr_debug_print(string(global.facing))

    -- if (dir == "left" and player:checkSolidCollisionAt() ~= nil) then
    --     return
    -- end

    -- if (dir == "right" and scr_trigcheck("no_throw_right")) then
    --     return
    -- end

    -- if (dir == "up" and scr_trigcheck("no_throw_up")) then
    --     return
    -- end

    -- if (dir == "down" and scr_trigcheck("no_throw_down")) then
    --     return
    -- end

    self.physics.move_path = nil
    self.physics.move_target = {}
    self.pickup_cooldown = 2
    -- event_user(1)

    self:setParent(Game.world)
    player.held_object = nil
    self.held = false
    self:setScale(1, 1)
    self:setPosition(player.x, player.y - 80)
    local targetx, targety = 0, 0
    if (dir == "right") then
        targetx = player.x + (player.width / 2) + 32
        targety = player.y + (player.height / 2) - 50
    end

    if (dir == "down") then
        targetx = player.x - player.width
        targety = player.y + (player.height / 2)
    end

    if (dir == "left") then
        targetx = player.x - (32 + self.width)
        targety = player.y + (player.height / 2) - 50
    end

    if (dir == "up") then
        targetx = player.x - player.width
        targety = player.y + (player.height / 2) - 80
    end

    self:slideTo(targetx, targety, 3 / 30, "linear")
    -- scr_jump_to_point(anchor_x, anchor_y, 12, 6)
    self.con = 100
    self.timer = 2
end

function NetskieObject:draw()
    super.draw(self)

    -- if (self.poofframe >= 0) then
    --     draw_sprite_ext(spr_poof_poofframe, (-8) + self.offsetx, (-10) + self.offsety, 0, 0.2, 0.2)
    -- end
end

return NetskieObject
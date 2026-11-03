---@class FusumaDoor : Event
---@overload fun(...) : FusumaDoor
local FusumaDoor, super = Class(Event)

function FusumaDoor:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self.initial = false
    self.destroyed = false
    self.can_open = self.properties["can_open"]
    if self.can_open == nil then
        self.can_open = true
    end
    self.locked_flag, self.locked_inverted, self.locked_flag_value = TiledUtils.parseFlagProperties("locked_flag", "locked_inverted", "locked_value", nil, self.properties)
    self.fox_flag = self.properties["fox_flag"]
    self.style = self.properties["style"]
    if self.style == nil then
        self.style = 1
    end
    self.door_x = 0.05
    self.lerper = 1
    self.last_doorx = 0.05
    self.state = 0
    self.con = 0
    self.far_background = false
    self.elevatorlerp = 0
    self.door_scale = 1
    self.fusuma_offset = 1
    self.left_door_offset = 5
    self.right_door_offset = 27
    self.left_door_pos = {0, 0}
    self.right_door_pos = {0, 0}

    self.text = TiledUtils.parsePropertyMultiList("text", self.properties)
    self.interact_count = 0
    self.arrow_dirrection = self.properties["arrow_dirrection"]

    self:setSprite("world/events/fusuma/fusuma_back_small_"..self.style)
    self:setHitbox(0, self.height - (3 * 2), self.width, (3 * 2))

    self.elevator = Hitbox(self, 20, 80, 80, 20)
    self.solid = true
end

function FusumaDoor:getSortPosition()
    return self:getRelativePos(0, self.height + 1)
end

function FusumaDoor:onLoad()
    super.onLoad(self)

    self.y = self.y - self.height
    self.target = Game.world.map:getEvent(self.properties["target"])

    self.fusuma_wall_left = Game.world:addChild(FusumaWall(self.left_door_pos[1], self.left_door_pos[2], {28*2, 58*2}, {door = "left"}))
    self.fusuma_wall_left.layer = self.layer
    self.fusuma_wall_left.getSortPosition = function(sign)
        return self:getRelativePos(0, self.height + 1)
    end

    self.fusuma_wall_right = Game.world:addChild(FusumaWall(self.right_door_pos[1], self.right_door_pos[2], {28*2, 58*2}, {door = "right"}))
    self.fusuma_wall_right.layer = self.layer
    self.fusuma_wall_right.getSortPosition = function(sign)
        return self:getRelativePos(0, self.height + 1)
    end

    if self.fox_flag ~= nil then
        if Game:getFlag(self.fox_flag) == nil then
            Game:setFlag(self.fox_flag, 0)
        end
        local sprite = Assets.getTexture("world/events/fusuma/foxsign_"..tostring(tonumber(Game:getFlag(self.fox_flag)) + 1))
        self.sign = Game.world:addChild(Sprite(sprite, self.x, self.y -sprite:getHeight() * 2))
        self.sign:setScale(2)
        self.sign.layer = self.layer
        self.sign.getSortPosition = function(sign)
            return self:getRelativePos(0, self.height + 1)
        end
    elseif self.arrow_dirrection ~= nil then
        -- yes I know up and down aren't in DR but fuck you I want up and down!
        local sprite = Assets.getTexture("world/events/fusuma/arrowsign_"..self.arrow_dirrection)
        self.sign = Game.world:addChild(Sprite(sprite, self.x, self.y -sprite:getHeight() * 2))
        self.sign:setScale(2)
        self.sign.layer = self.layer
        self.sign.getSortPosition = function(sign)
            return self:getRelativePos(0, self.height + 1)
        end
    end
    if (not self.can_open) then
        self.lockSprite = Game.world:addChild(Sprite("world/events/fusuma/door_lock", self.x, self.y))
        self.lockSprite:setScale(2)
        self.lockSprite.layer = self.layer
        self.lockSprite.getSortPosition = function(sign)
            return self:getRelativePos(0, self.height + 1)
        end
    end
end

function FusumaDoor:onInteract(player, dir)
    super.onInteract(self, player, dir)
    if (dir == "up" or dir == "down") then
        if not self.can_open or (self.fox_flag ~= nil and not Game:getFlag(self.fox_flag) == 5) then
            if self.text ~= nil then
                self.interact_count = self.interact_count + 1

                self.world:startCutscene(function(cutscene)
                    cutscene:setSpeaker(nil)
                    ---@type string|string[]
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
            return true
        else
            self:setOpenState(not self.state)
            return true
        end
    end
    return false
end

function FusumaDoor:setOpenState(statetobe)
    if (self.state ~= statetobe and (self.can_open or statetobe == 0)) then

        -- if (Game.world.cutscene ~= nil or !collision_rectangle(x1, y1, x2, y2, obj_mainchara, false, true)) then
        if (Game.world.player and not self:meetsObject(Game.world.player)) then
            self.state = (self.state + 1) % 2
            -- local ll = self.lerper
            self.lerper = 0
            self.last_doorx = self.door_x
            Assets.playSound("wing", 1, 1 + (0.1 * self.state))
            self.solid = self.state ~= 1

            if (statetobe == 1) then

                if (self.state ~= 0) then
                    self:setOpenState(0)
                    self.lerper = -1
                end

                if (self.state ~= 0) then
                    self:setOpenState(0)
                    self.lerper = -1
                end

                -- if (ll == 1 and self.lerper == 0) then
                    -- with (mask)
                    --     dirty = other.id
                -- end
            end

            -- if (self.state == 1) then
            --     self.on_open()
            -- else
            --     self.on_close()
            -- end
        end
    end
end

function FusumaDoor:update()
    super.update(self)
    self.lerper = MathUtils.approach(self.lerper, 1, 0.25)

    if self.fox_flag ~= nil then
        if Game:getFlag(self.fox_flag) == nil then
            Game:setFlag(self.fox_flag, 0)
        end
        self.can_open = Game:getFlag(self.fox_flag) == 5
        if Game:getFlag(self.fox_flag) ~= 5 and self.state ~= 0 then
            self:setOpenState(0)
        end
    end

    if self.target ~= nil and self.state == 1 and not Game.world:hasCutscene() and Game.world.player and self.elevator:meetsObject(Game.world.player) then
        local player = Game.world.player
        self.world:startCutscene(function (cutscene, event)
            Game.world:detachFollowers()
            cutscene:walkTo(player, player.x, player.y - 40, 15/30)
            for i, chara in ipairs(Game.world.followers) do
                chara.history = {}
                local time = 5 * (i + 1)
                cutscene:walkTo(chara, player.x, player.y, time / 30)
                Game.world.timer:after(time / 30, function()
                    cutscene:walkTo(chara, player.x, player.y - 30, 15 / 30)
                end)
            end
            cutscene:wait(20/30)
            self:setOpenState(0)
            cutscene:wait(10/30)
            cutscene:panTo(self.target.x + 40 + player.width, self.target.y + 40, 0.5, "inOutQuad", function()
                -- targetx/y are usually a marker but I'm hardcoding it.
                local targetx = self.target.x + 40 + player.width
                local targety = self.target.y + 60
                player:setPosition(targetx, targety)
                player:setFacing("down")
                cutscene:walkTo(player, targetx, targety + 120, 7/30)
                self.target:setOpenState(1)
                for i, chara in ipairs(Game.world.followers) do
                    chara:setFacing("down")
                    if i == 1 then
                        chara:setPosition(targetx - 18, targety - 20)
                        cutscene:walkTo(chara, targetx - 32, targety + 100, 7/30)
                    else
                        chara:setPosition(targetx + 10, targety - 30)
                        cutscene:walkTo(chara, targetx + 24, targety + 102, 7/30)
                    end
                end
                cutscene:wait(8/30)
                cutscene:wait(8/30)
                cutscene:attachCameraImmediate()

                for _, follower in ipairs(Game.world.followers) do
                    follower.history = {}
                    follower.following = true
                    follower.returning = true
                    follower:updateIndex()
                    follower:interpolateHistory()
                end

                Game.world:attachFollowersImmediate()
            end)
        end, self)
    end

    if (self.state == 0) then
        local lerpval = 1
        local dx = 0.05

        if (self.lerper < 1) then
            lerpval = Utils.ease(0, 1, self.lerper, "in-sine")
            dx = MathUtils.lerp(self.last_doorx, 0.05, lerpval)
        end

        self.door_x = dx

    else
        local lerpval = 1
        local dx = 0.5

        if (self.lerper < 1) then
            lerpval = Utils.ease(0, 1, MathUtils.clamp(self.lerper, 0, 1), "out-sine")
            dx = MathUtils.lerp(self.last_doorx, 0.5, lerpval)
        end

        self.door_x = dx
    end
    self.left_door_pos = {((self.left_door_offset * 2)) - (self.door_x * (self.width)), (self.fusuma_offset * 2 * self.door_scale)}
    self.right_door_pos = {(self.right_door_offset * 2) + (self.door_x * (self.width)), (self.fusuma_offset * 2 * self.door_scale)}

    self.fusuma_wall_left:setPosition(self.x + self.left_door_pos[1], self.y + self.left_door_pos[2])
    self.fusuma_wall_right:setPosition(self.x + self.right_door_pos[1], self.y + self.right_door_pos[2])
    if self.sign and self.fox_flag ~= nil then
        self.sign:setTexture("world/events/fusuma/foxsign_"..tostring(tonumber(Game:getFlag(self.fox_flag)) + 1))
    end

    if self.lockSprite then
        self.lockSprite.visible = self.door_x == 0.05
        self.lockSprite:setPosition((0.5 * self.width) - 6 + self.x, (0.5 * self.height) - 8 + self.y)
    end
end

function FusumaDoor:draw()
    super.draw(self)
    local spr_door = Assets.getTexture("world/events/fusuma/door_right_small_"..self.style)
    local spr_door_left = Assets.getTexture("world/events/fusuma/door_left_small_"..self.style)

    if (self.destroyed == false) then
        love.graphics.draw(spr_door_left, self.left_door_pos[1], self.left_door_pos[2], 0, 2, 2)
        love.graphics.draw(spr_door, self.right_door_pos[1], self.right_door_pos[2], 0, 2, 2)
        -- draw_sprite_ext(spr_door_left, image_index, (x + (left_door_offset * image_xscale)) - (door_x * sprite_width), y + (fusuma_offset * image_yscale * door_scale), image_xscale, image_yscale * door_scale, image_angle, image_blend, image_alpha)
        -- draw_sprite_ext(spr_door, image_index, x + (right_door_offset * image_xscale) + (door_x * sprite_width), y + (fusuma_offset * image_yscale * door_scale), image_xscale, image_yscale * door_scale, image_angle, image_blend, image_alpha)
    end

    if DEBUG_RENDER then
        love.graphics.print(tostring(self.door_x))
        if self.target ~= nil then
            self.elevator:draw(0, 0, 1, 0.5)
            local x, y = self.target:getPosition()
            local world_x, world_y = self.target:getRelativePos(x, y, Game.world)
            local target_x, target_y = Game.world:getRelativePos(world_x / 2, world_y / 2, self)

            love.graphics.setColor(1, 0, 1, 1)
            love.graphics.setLineWidth(2)
            Draw.drawArrow(40, 40, target_x + 40, target_y + 40, 12)
        end
    end
end

return FusumaDoor
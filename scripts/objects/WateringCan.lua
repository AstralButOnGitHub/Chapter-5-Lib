---@class WateringCan : Sprite
---@overload fun(...) : WateringCan
local WateringCan, super = Class(Sprite)

function WateringCan:init(can_type, watering_size, x, y)
    self.can_type = can_type or "small"

    self.can_knock_off = true
    self.water_sound = "water"
    self.bloom_sound = "harp_strum"
    self.slurp_sound = "slurp"
    if self.can_type == "small" then
        self.suffix = ""
        self.offset_x = 2
        self.offset_y = -16
        self.climb_head_x = 0
        self.climb_head_y = -10
    elseif self.can_type == "medium" then
        self.suffix = "_big"
        self.offset_x = -12
        self.offset_y = -30
        self.head_x = -5
    elseif self.can_type == "large" then
        self.suffix = "_huge"
        self.offset_x = -18
        self.offset_y = -88
    elseif self.can_type == "dog" then
        self.suffix = "_dog"
        self.offset_x = 2
        self.offset_y = -16
        self.water_sound = "pombark"
        self.bloom_sound = "pombark"
        self.slurp_sound = "pombark"
    end

    super.init(self, "world/events/watering/wateringcan" .. self.suffix, x, y)

    self.water_frame = 1
    self.water_position = "left"

    self.watering_reticle = Sprite("effects/watering_reticle")
    self.watering_reticle.visible = false
    self.watering_reticle.layer = 0.6
    self.watering_reticle.draw = function()
        self:drawReticle()
    end
    self.watering_size = watering_size or nil
    if self.watering_size == nil then
        if self.can_type == "medium" then
            self.watering_size = {4, 4}
        elseif self.can_type == "large" then
            self.watering_size = {4, 4}
        else
            self.watering_size = {1, 1}
        end
    end

    self.watering_offset = {0, 0, 0}
    if self.watering_size[1] == 2 and self.watering_size[2] == 2 then
        self.watering_offset = {0.4, 0.5, 0}
    elseif self.can_type == "medium" then
        self.watering_offset = {8, 1, 5}
    elseif self.can_type == "large" then
        self.watering_offset = {0, 0, 0}
    end

    self.reticle_bounds = {0, 0, self.watering_size[1] * 40, self.watering_size[2] * 40}
    Game.world:addChild(self.watering_reticle)

    self.startlayer = self.layer
    self.water_hitbox = Hitbox(Game.world, 0, 0, 40, 40)
end

function WateringCan:getPedestalOffset()
    return self.offset_x, self.offset_y
end

function WateringCan:getHeadPosition()
    return self.head_x or 0, self.head_y or 0
end

function WateringCan:getClimbingHeadPosition()
    return self.climb_head_x or 0, self.climb_head_y or 0
end

function WateringCan:update()
    super.update(self)
    if Game.world.player and Game.world.player == self.parent then
        self.layer = self.startlayer + (Game.world.player.state == "CLIMB" and 0.1 or -0.1)
    end
end

function WateringCan:drawReticle()
    -- draw_sprite_part(spr_watering_reticle, 0, 0, 0, 9, 9, reticle_bounds[0], reticle_bounds[1]);
    -- draw_sprite_part(spr_watering_reticle, 0, 31, 0, 9, 9, reticle_bounds[2] - 8, reticle_bounds[1]);
    -- draw_sprite_part(spr_watering_reticle, 0, 31, 31, 9, 9, reticle_bounds[2] - 8, reticle_bounds[3] - 8);
    -- draw_sprite_part(spr_watering_reticle, 0, 0, 31, 9, 9, reticle_bounds[0], reticle_bounds[3] - 8);

    if Game.world.player and Game.world.player.watering then
        local anim_frame = math.floor(self.water_frame)
        for gx = 1, self.watering_size[1] do
            for gy = 1, self.watering_size[2] do
                love.graphics.draw(Assets.getTexture("effects/wateringcanspray_ground_" .. anim_frame), (gx - 1) * 20, (gy - 1) * 20, 0, 1, 1)
            end
        end
    elseif Game.world.player and not Game.world.player.watering then
        local texture = self.watering_reticle.texture
        if not texture then return end
        local w, h = texture:getDimensions()

        local qw = math.min(9, math.floor(w / 2))
        local qh = math.min(9, math.floor(h / 2))

        local quad_top_left = love.graphics.newQuad(0, 0, qw, qh, w, h)
        local quad_top_right = love.graphics.newQuad(w - qw, 0, qw, qh, w, h)
        local quad_bottom_right = love.graphics.newQuad(w - qw, h - qh, qw, qh, w, h)
        local quad_bottom_left = love.graphics.newQuad(0, h - qh, qw, qh, w, h)

        local x1, y1, x2, y2 = unpack(self.reticle_bounds)

        love.graphics.draw(texture, quad_top_left, x1, y1)
        love.graphics.draw(texture, quad_top_right, x2 - qw, y1)
        love.graphics.draw(texture, quad_bottom_right, x2 - qw, y2 - qh)
        love.graphics.draw(texture, quad_bottom_left, x1, y2 - qh)
    else
        super.draw(self.watering_reticle)
    end
end

function WateringCan:updateWatering(player)
    self.water_frame = self.water_frame + (1 / 3)
    if self.water_frame >= 7 then
        self.water_frame = 1
    end

    self.water_position = (player.watering_face == "right") and "right" or "left"

    local wateroff
    if self.water_position == "left" then
        wateroff = -60 - (self.watering_offset[1] * 20)
    else
        local right_offset = (self.watering_offset[3] == 0 and 1 or self.watering_offset[3])
        wateroff = (player.width * 2) + (right_offset * 20)
    end

    local pregridx = player.x + wateroff
    local pregridy = player.y + (self.watering_offset[2] * 20)
    local waterlocationx = math.floor(pregridx / 40) * 40
    local waterlocationy = math.floor(pregridy / 40) * 40

    if self.watering_size[1] > 1 or self.watering_size[2] > 1 then
        local tile_offset_x = math.floor(self.watering_size[1] / 2) * 40
        local tile_offset_y = math.floor(self.watering_size[2] / 2) * 40

        if self.water_position == "left" then
            waterlocationx = (math.floor(pregridx / 40) * 40) - tile_offset_x
        else
            waterlocationx = (math.floor(pregridx / 40) * 40) + tile_offset_x - 40
        end
        waterlocationy = (math.floor(pregridy / 40) * 40) - tile_offset_y
    end
    self.reticle_bounds = {0, 0, self.watering_size[1] * 40, self.watering_size[2] * 40}
    self.watering_reticle:setPosition(waterlocationx, waterlocationy)

    self.visible = not player.watering
    if player.climb_watering then
        self.visible = true
    end
    if self.can_type == "medium" and not player.watering then
        self.watering_reticle:setSprite("effects/watering_reticle")
    else
        self.watering_reticle:setSprite(player.watering and "effects/wateringcanspray_ground_"..math.floor(self.water_frame) or "effects/watering_reticle")
    end
    self.watering_reticle:setScale((player.watering and 2 or 1), (player.watering and 2 or 1))

    self.water_hitbox:setBounds(waterlocationx, waterlocationy, self.watering_size[1] * 40, self.watering_size[2] * 40)
    self.watering_reticle.visible = (player.watering or (self.can_type == "medium")) and not (player.state == "CLIMB_MOUNT" or player.state == "CLIMB_DISMOUNT")

    for _, waterableevents in ipairs({"WaterableFlower", "WaterableFlowerSmall", "WaterableGrass", "WaterableReeds"}) do
        for _, waterable in ipairs(Game.world.map:getEvents(waterableevents)) do
            if waterable:meetsCollider(self.water_hitbox) then
                if waterable:canWater() then
                    if player.watering then
                        waterable:startBloom(waterableevents ~= "WaterableGrass" and self.bloom_sound or self.slurp_sound)
                    end
                    if waterableevents ~= "WaterableReeds" then
                        self.watering_reticle.visible = true
                    end
                end
            end
        end
    end
    for _, follower in ipairs(Game.world.followers) do
        if follower.actor.can_bloom and player.watering then
            if follower:meetsCollider(self.water_hitbox) then
                follower.bloom_timer = follower.bloom_timer + DT
            end
        end
    end
    for _, npc in ipairs(Game.stage:getObjects(NPC)) do
        if npc.outlinefx and npc.can_water and Game.world.player and Game.world.player:canWater() and npc:meetsCollider(self.water_hitbox) then
            if player.watering then
                npc:water()
            end
            npc.outlinefx:setColor(npc.outlinefx.color[1], npc.outlinefx.color[2], npc.outlinefx.color[3], 1)
            return
        end
        npc.outlinefx:setColor(npc.outlinefx.color[1], npc.outlinefx.color[2], npc.outlinefx.color[3], 0)
    end
end

function WateringCan:drawWaterStream(player)
    if player.watering then
        love.graphics.setColor(1, 1, 1, 1)
        local anim_frame = ((self.water_frame - 1) % 3) + 1
        if self.can_type == "medium" then
            local wtr = Assets.getTexture("effects/wateringcanspray_big_"..math.floor(anim_frame))
            if player.watering_face == "right" then
                love.graphics.draw(wtr, 38, -26)
            else
                love.graphics.draw(wtr, -19, -27, 0, -1, 1)
            end
        else
            local wtr = Assets.getTexture("effects/wateringcanspray_"..math.floor(anim_frame))
            if player.watering_face == "right" then
                love.graphics.draw(wtr, 34, -8)
            else
                love.graphics.draw(wtr, -14, -8, 0, -1, 1)
            end
        end
    end
end

function WateringCan:draw()
    super.draw(self)

    if self.can_type == "large" then

    end
end

function WateringCan:onRemove(parent)
    super.onRemove(self, parent)
    if self.watering_reticle then
        self.watering_reticle:remove()
    end
end

return WateringCan
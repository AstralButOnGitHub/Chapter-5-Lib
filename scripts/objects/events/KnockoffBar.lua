---@class KnockoffBar : Event
---@overload fun(...) : KnockoffBar
local KnockoffBar, super = Class(Event)

function KnockoffBar:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self:setSprite("world/events/talltree_with_bar")
    self:setHitbox(40, self.height - 12, self.width - 80, 8)
    self.foxcon = 0
    self.foxtimer = 0
end

function KnockoffBar:onLoad()
    super.onLoad(self)

    self.x = self.x - (self.width / 2)
    self.y = self.y - self.height
    self.marker = nil
    self.pedestal = Game.world.map:getEvent(self.properties["pedestal"])
    if self.pedestal == nil then
        local x, y, marker = Game.world.map:getMarker(self.properties["pedestal"])
        self.marker = {x, y, marker}
    end
end

function KnockoffBar:update()
    super.update(self)

    if self.foxcon == 1 then
        self.foxtimer = self.foxtimer + 1
        -- ????
        local manual_check = false
        if (self.foxtimer == 20) then
            for _, fox in ipairs(Game.stage:getObjects(NetskieObject)) do
                if (not manual_check) then
                    fox:appear()
                end
            end

            self.foxcon = 0
        end
    end

    local player = Game.world.player
    if player:meetsObject(self) then
        if player.held_object ~= nil and player.held_object.can_knock_off == true then
            if player.held_object:includes(WateringCan) then
                Assets.playSound("punchweak")
                Assets.playSound("fall")
                local impactspr = Sprite("effects/knockoff_impact", player.x - 30, player.y - 120)
                impactspr:setScale(2)
                impactspr.layer = impactspr.layer + 999999
                Game.world:addChild(impactspr)
                Game.world.timer:after(3/30, function()
                    impactspr:remove()
                end)

                local can_type = player.watering_can_type
                local watering_size = player.held_object.watering_size
                local can = WateringCan(can_type, watering_size)
                local px = player.x - player.width
                local py = player.y - (player.height * 2)

                local startx = px + player.held_object.x
                local starty = py + player.held_object.y - 20
                can:setPosition(startx, starty)
                can:setScale(2)
                can.layer = WORLD_LAYERS["above_events"]
                Game.world:addChild(can)

                player.held_object:remove()
                player.held_object = nil
                can:setRotationOrigin(1, 1)

                if self.marker == nil then
                    if self.pedestal.can_object ~= nil then
                        self.pedestal.can_object:fadeOutAndRemove(0.3)
                        self.pedestal.can_type = nil
                        self.pedestal.can_object = nil
                    end
                    self.pedestal.can_place = false
                    local time = 0
                    Game.world.timer:during(1, function()
                        time = time + (DTMULT / 30)
                        can.rotation = MathUtils.lerp(0, 2 * (2 * math.pi), time)
                        local jumpheight = 4 * -120 * time * (1 - time)
                        can.x = MathUtils.lerp(startx, self.pedestal.x + 4, time)
                        can.y = MathUtils.lerp(starty, (self.pedestal.y - 20) + jumpheight, time)
                    end, function()
                        can:remove()
                        self.pedestal:createWateringcan(can_type, watering_size)
                        self.pedestal.can_place = true
                    end)
                else
                    local time = 0
                    Game.world.timer:during(1, function()
                        time = time + (DTMULT / 30)
                        can.rotation = MathUtils.lerp(0, 2 * (2 * math.pi), time)
                        local jumpheight = 4 * -120 * time * (1 - time)
                        can.x = MathUtils.lerp(startx, self.marker[1] + 4, time)
                        can.y = MathUtils.lerp(starty, (self.marker[2] - 20) + jumpheight, time)
                    end)
                end

                player.watering_can_type = nil
            elseif player.held_object:includes(HeadMushroom) then
                local obj_mainchara = Game.world.player
                local headmushroom = player.held_object
                local stack = headmushroom.shroomstack

                local player_speedx_average = obj_mainchara.moving_x / 8
                local player_speedy_average = obj_mainchara.moving_y / 8

                local applied_speed = MathUtils.dist(0, 0, player_speedx_average, player_speedy_average)
                local applied_direction = MathUtils.angle(0, 0, player_speedx_average, player_speedy_average)

                local stacklength = #stack

                if (stacklength > 1) then
                    Assets.playSound("punchweak")
                    Assets.playSound("fall")
                    local impactspr = Sprite("effects/knockoff_impact", player.x - 30, player.y - 120)
                    impactspr:setScale(2)
                    impactspr.layer = impactspr.layer + 999999
                    Game.world:addChild(impactspr)
                    Game.world.timer:after(3/30, function()
                        impactspr:remove()
                    end)

                    self.foxcon = 1
                    self.foxtimer = 0
                    local order = {}

                    for i = 1, stacklength do
                        table.insert(order, i)
                    end

                    for i = 1, stacklength - 1 do
                        local throwidx = math.random(#order)
                        local throworder = order[throwidx]
                        table.remove(order, throwidx)

                        local xdiff = MathUtils.clamp(headmushroom.x - headmushroom.xprevious, -6, 6)
                        local ydiff = MathUtils.clamp((headmushroom.y - headmushroom.yprevious) / 2, -6, 6)

                        headmushroom.xprevious = headmushroom.x
                        headmushroom.yprevious = headmushroom.y
                        local stacksize = 14

                        headmushroom.xdist[i] = MathUtils.lerp(headmushroom.xdist[i], xdiff * (0.5 * i), 0.15)
                        headmushroom.ydist[i] = MathUtils.lerp(headmushroom.ydist[i], ydiff * (0.5 * i), 0.15)

                        -- WTF IS sprite_get_width????? HOW WOULD THIS APPLY TO A CONTROLLER WITH NO SPRITE!?!??!!?
                        -- local xloc = stack.x - (sprite_get_width(stack[i]) / 2) - stack.xdist[i]
                        -- local yloc = (stack.y - sprite_get_height(stack[i]) - (i * stacksize) - stack.ydist[i]) + math.abs(stack.xdist[i] / 5)
                        local xloc = headmushroom.x - (stack[i].width / 2) - headmushroom.xdist[i]
                        local yloc = (headmushroom.y - stack[i].height - (i * stacksize) - headmushroom.ydist[i]) + math.abs(headmushroom.xdist[i] / 5)

                        local shroom = PhysicsMushroom(xloc, yloc)
                        shroom.layer = 0.6
                        shroom.fakeheight = yloc - (obj_mainchara.height * 2)
                        shroom.destroy_on_overlap = true
                        shroom.x = obj_mainchara.x + stack[i].x - (shroom.sprite.width / 2)
                        shroom.y = obj_mainchara.y + stack[i].y - (obj_mainchara.sprite.height)

                        shroom.physics.direction = (applied_direction + math.rad(30)) - ((math.rad(60) * throworder) / (stacklength - 1))
                        shroom.physics.speed = MathUtils.random(4 + (applied_speed * 0.7), 4 + (applied_speed * 1)) * 2
                        shroom.rotation_speed = math.rad(MathUtils.random(-25, 25))
                        Game.world:addChild(shroom)
                    end

                    for i = #stack, 2, -1 do
                        stack[i]:remove()
                    end
                    headmushroom.shroomstack = {stack[1]}
                    -- break
                end
            end
        end
    end
end

function KnockoffBar:draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 60, 108, 240, 8)
    super.draw(self)
end

return KnockoffBar
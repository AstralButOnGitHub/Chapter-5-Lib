---@class BunnyPlant : Event
---@overload fun(...) : BunnyPlant
local BunnyPlant, super = Class(Event)

function BunnyPlant:init(data)
    super.init(self, data)
    self.properties = data.properties or {}
    self.bunny = self.properties["bunny"]
    if self.bunny == nil then
        self.bunny = false
    end
    self:setSprite(self.bunny == true and "world/events/bunnypop" or "world/events/bunnyharvest", 0, false)
    self.sprite:pause()
    self.sprite:setFrame(1)
    self.sprite:setPosition(6, -28)
    self:setHitbox(15, 15, 10, 10)
end

function BunnyPlant:getSortPosition()
    return self:getRelativePos(0, 28)
end

function BunnyPlant:onInteract(player, dir)
    super.onInteract(self, player, dir)
    if not self.bunny then return end

    if player.held_object == nil then
        if not Game.world:hasCutscene() then
            Assets.playSound("wing", 0.3, 1)
            Game.world:startCutscene(function (cutscene, ...)
                self.sprite:play(0.05, false, function(sprite)
                    -- self:slideTo(player.x, player.y - 80)
                    self:setParent(player)
                    self:setPosition(3, -22)
                    self:setScale(.5, .5)
                    player.held_object = self
                    self:setSprite("world/events/bunny", 0.15, true)
                end)
                Assets.playSound("noise")
                Game.world.timer:after(6/30, function()
                    Assets.playSound("wing", 1, 1.2)
                end)
                cutscene:wait(12 / 30)
            end)
        end

    end
end

function BunnyPlant:onPress(player, dir)
    ---@cast player Player
    Assets.playSound("wing", 1, 1.2)
    local snd = Assets.playSound("fall", 0.7, 0.8)
    local fadevol = 0.7
    Game.world.timer:during(12/30, function()
        fadevol = fadevol - (0.7 / 12)
        if fadevol < 0 then
            fadevol = 0
        end
        snd:setVolume(fadevol)
    end)

    self:setParent(Game.world)
    self:setPosition(player.x - 12, player.y - 120)
    self:setScale(1, 1)
    self:setRotationOrigin(0.5, 0.75)
    player.held_object = nil

    self.physics.speed_y = -4
    if (player.facing == "right") then
        self.physics.speed_x = 4 + ((Input.down("right") and 1 or 0) * 4)
    elseif (player.facing == "left") then
        self.physics.speed_x = -4 - ((Input.down("left") and 1 or 0) * 4)
    elseif (player.facing == "down") then
        self.physics.speed_y = -6
    end
    self.physics.gravity = 1
    self.layer = WORLD_LAYERS["above_events"]
    self.amdoom = false
    self.upwards = false
    self.ymax = 0

    if (player.facing == "up") then
        self.upwards = true;
        self.layer = 0.6
        self.ymax = player.y + player.height - 80
    end
end

function BunnyPlant:update()
    super.update(self)
    if (self.upwards) then
        if (self.y > (self.ymax - 4)) then
            if (not self.amdoom) then
                self.amdoom = true;
                self.y = self.ymax;
                self.physics.speed_x = 0;
                self.physics.speed_y = 0;
                self.physics.gravity = 0;
                Assets.playSound("wing")
                self:fadeOutAndRemove(15/30)
            end
        end
    end

    self.rotation = self.rotation - ((math.abs(self.physics.speed_y) + math.abs(self.physics.speed_x)) * MathUtils.sign(self.physics.speed_x) * 2) * (math.pi / 180);

    -- if (self.y > (cameray() + 480 + 60)) then
    --     instance_destroy();
    -- end
end

function BunnyPlant:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self.collider:draw(1, 1, 1, 1)
    end
end

return BunnyPlant
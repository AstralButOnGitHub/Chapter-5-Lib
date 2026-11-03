---@class WateringPedestal : Event
---@overload fun(...) : WateringPedestal
local WateringPedestal, super = Class(Event)

function WateringPedestal:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self.solid = true
    self.cutscene = self.properties["cutscene"] or nil
    self.wide = self.properties["wide"] == true or false
    if self.wide then
        self:setSprite("world/events/watering/wateringpedestal_wide")
    else
        self:setSprite("world/events/watering/wateringpedestal")
    end
    self.can_type = self.properties["can"] or nil
    self.watering_size = self.properties["watering_size"] or nil
    self.can_place = true

    self:setHitbox(0, self.height - 26, self.width, 26)
    self.x = self.x - (self.width / 2)
    self.y = self.y - self.height + 20
end

function WateringPedestal:createWateringcan(can_type, watering_size)
    self.can_type = can_type
    self.watering_size = watering_size
    if self.can_type ~= nil then
        local can = WateringCan(self.can_type, self.watering_size)
        local ox, oy = can:getPedestalOffset()
        can:setPosition(can.x + ox, can.y + oy)
        can:setScale(2)

        self.can_object = can
        self:addChild(self.can_object)
        self.can_object.pedestal = self
    end
end

function WateringPedestal:onLoad()
    super.onLoad(self)
    self:createWateringcan(self.can_type, self.watering_size)
end

function WateringPedestal:giveWateringCan(player)
    player.watering_can_type = self.can_type
    if player.held_object then
        player.held_object:remove()
    end

    local pedestal = self.can_object.pedestal
    self.can_object:remove()
    player.watering_pickup_lock = true
    player.held_object = WateringCan(self.can_type, self.watering_size)
    player:addChild(player.held_object)
    player.held_object:setPosition(0, (-player.held_object.height) + 2)
    player.held_object.scale_x = 1
    player.held_object.scale_y = 1
    player.held_object.pedestal = pedestal

    self.can_type = nil
    self.can_object = nil
    Assets.playSound("item")
end

function WateringPedestal:takeWateringCan(player)
    self:createWateringcan(player.watering_can_type, player.held_object.watering_size)

    if player.held_object then
        player.held_object:remove()
        player.held_object = nil
    end

    player.watering_can_type = nil
    Assets.playSound("item", 1, 0.5)
end

function WateringPedestal:onInteract(player, dir)
    super.onInteract(self, player, dir)
    if player.watering_can_type == nil and self.can_object ~= nil then
        if self.cutscene ~= nil and self:getFlag("played_cutscene", false) == false then
            Game.world:startCutscene(self.cutscene, self)
            self:setFlag("played_cutscene", true)
        else
            self:giveWateringCan(player)
        end
        return true
    elseif self.can_place and player.watering_can_type ~= nil and self.can_object == nil then
        self:takeWateringCan(player)
        return true
    end
    return false
end

return WateringPedestal
---@class ToriiGate : Event
---@overload fun(...) : ToriiGate
local ToriiGate, super = Class(Event)

function ToriiGate:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self.dark = self.properties["dark"] == true
    self.runspeed = self.properties["runspeed"] or 15
    self:setSprite("world/events/torii/torigate"..(self.dark and "_dark" or ""))
    self.x = self.x - (self.width / 2)
    self.y = self.y - self.height
    self:setHitbox(24 * 2, 123 * 2, 22 * 2, 68 * 2)
end

function ToriiGate:getSortPosition()
    return self:getRelativePos(0, 196*2)
end

function ToriiGate:onEnter(player)
    if not player or not player.setState or player.toriigate == self then
        return
    end
    if player.state ~= "TORII_DASH" then
        player:setState("TORII_DASH")
        local handler = player.state_manager:getHandler("TORII_DASH")
        handler.substate = "TORII_DASH_START"
        player.toriigate = self
        handler.toriigate = player.toriigate
        handler.dash_dir = player.x <= self.x + (self.width / 2) and "right" or "left"
        player:setFacing(handler.dash_dir)

        player.slode = false
    end
end

function ToriiGate:onExit(player)
    if not player or not player.setState or player.toriigate == self then
        return
    end
    if player.state == "TORII_DASH" then
        player:setState("TORII_DASH")
        local handler = player.state_manager:getHandler("TORII_DASH")
        handler.substate = "TORII_DASH_END"
        handler.toriigate = self
    end
end

function ToriiGate:onLoad()
    super.onLoad(self)
    local sprite = ToriiGateBG("world/events/torii/torigate" ..(self.dark and "_dark_back" or "_back"), self.x, self.y)
    sprite.scale_x = 2
    sprite.scale_y = 2
    sprite:setLayer(0.4)

    Game.world:addChild(sprite)
end

return ToriiGate
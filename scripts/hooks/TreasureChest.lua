local TreasureChest, super = HookSystem.hookScript(TreasureChest)

function TreasureChest:init(x, y, properties)
    super.init(self, x, y, properties)
    self.properties = properties

    self.pink_coins = properties["pink_coins"]
    self.flowery_dollars = properties["flowery_dollars"]

    if properties["pink_sprite"] ~= nil then
        self.sprite:setSprite("world/events/treasure_chest_pink")
    end
    if properties["chestery"] == true then
        self.sprite:setSprite("world/events/chestery")
    end
end

function TreasureChest:onInteract(player, dir)
    if self.pink_coins == nil and self.flowery_dollars == nil and self.properties["chestery"] == nil then
        return super.onInteract(self, player, dir)
    end

    if self:getFlag("opened") then
        self.world:showText("* (The "..(self.properties["chestery"] ~= true and "chest" or "Chestery").." is empty.)")
    else
        Assets.playSound("locker")
        self.sprite:setFrame(2)
        self:setFlag("opened", true)

        local name, success, sound
        if self.flowery_dollars then
            name = self.flowery_dollars..(self.flowery_dollars > 1 and " Flowery Dollars" or "Flowery Dollar")
            success = true
            sound = "[sound:flowery_coin_big]"
            Game.flowery_dollars = (Game.flowery_dollars or 0) + self.flowery_dollars
        elseif self.pink_coins then
            name = self.pink_coins..(self.pink_coins > 1 and " Pink Coins" or " Pink Coin")
            success = true
            sound = "[sound:pink_coin]"
            Game.pink_coins = (Game.pink_coins or 0) + self.pink_coins
        elseif self.item then
            local item = self.item
            if type(self.item) == "string" then
                item = Registry.createItem(self.item)
            end
            success, result_text = Game.inventory:tryGiveItem(item)
            name = item:getName()
        elseif self.money then
            name = self.money.." "..Game:getConfig("darkCurrency")
            success = true
            result_text = "* ([color:yellow]"..name.."[color:reset] was added to your [color:yellow]MONEY HOLE[color:reset].)"
            Game.money = Game.money + self.money
        end
        if self.properties["chestery"] then
            sound = "[sound:heuguys]"
        end

        if name then
            self.world:showText({
                "* (You opened the "..(self.properties["chestery"] ~= true and "treasure chest" or "Chestery")..".)[wait:5]",
                "* (Inside was [color:yellow]"..name.."[color:reset].)"..sound
            }, function()
                if not success then
                    self.sprite:setFrame(1)
                    self:setFlag("opened", false)
                end
            end)
        else
            self.world:showText("* (The "..(self.properties["chestery"] ~= true and "chest" or "Chestery").." is empty.)")
            success = true
        end

        if success and self.set_flag then
            Game:setFlag(self.set_flag, (self.set_value == nil and true) or self.set_value)
        end
    end

    return true
end

return TreasureChest
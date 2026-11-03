local DarkMenu, super = HookSystem.hookScript(DarkMenu)

function DarkMenu:draw()
    Draw.setColor(PALETTE["world_fill"])
    love.graphics.rectangle("fill", 0, 0, 640, 80)

    Draw.setColor(1, 1, 1, 1)
    if self.buttons[self.selected_submenu].desc_sprite then
        Draw.draw(self.buttons[self.selected_submenu].desc_sprite, 20, 24, 0, 2, 2)
    end

    for i = 1, #self.buttons do
        self:drawButton(i, 120 + ((i - 1) * self:getButtonSpacing()), 20)
    end
    Draw.setColor(1, 1, 1)

    local currencies = {}
    table.insert(currencies, {Game:getConfig("darkCurrencyShort"), Game.money})
    if Game.pink_coins ~= nil then
        table.insert(currencies, {"P$", Game.pink_coins})
    end
    if Game.flowery_dollars ~= nil then
        table.insert(currencies, {"F$", Game.flowery_dollars})
    end

    love.graphics.setFont(self.font)

    if (#currencies == 1) then
        love.graphics.print(currencies[1][1] .. " " .. currencies[1][2], 520, 20)
    end
    if (#currencies == 2) then
        for i, currency in ipairs(currencies) do
            if i == 1 then
                love.graphics.print(currency[1] .. " " .. currency[2], 520, 41)
            else
                love.graphics.print(currency[1] .. " " .. currency[2], 520, 13)
            end
        end
    end
    if (#currencies == 3) then
        Draw.setColor(PALETTE["world_fill"])
        love.graphics.rectangle("fill", 500, 80, 140, 30)
        Draw.setColor(1, 1, 1, 1)
        love.graphics.print(currencies[3][1] .. " " .. currencies[3][2], 520, 13)
        love.graphics.print(currencies[2][1] .. " " .. currencies[2][2], 520, 41)
        love.graphics.print(currencies[1][1] .. " " .. currencies[1][2], 520, 69)
    end

    super.super.draw(self)
end

return DarkMenu
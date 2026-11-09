local BattleUI, super = HookSystem.hookScript(BattleUI)

function BattleUI:draw()
    super.draw(self)
    if Game.battle.state == "MENUSELECT" and Game.battle.state_reason == "ACT" then
        local a = 0
        for _, evid in ipairs(Chapter5Lib.trial_evidence) do
            Draw.setColor(COLORS.gray)
            Draw.draw(Assets.getTexture("ui/battle/evidence/border_angled"), 16 + (60 * a), 96 + (math.sin((Kristal.getTime()) + a) * 2), 0)
            Draw.draw(Assets.getTexture("ui/battle/evidence/evidence_"..string.lower(evid.name)), 21 + (60 * a), 100 + (math.sin((Kristal.getTime()) + a) * 2), 0)
            a = a + 1
        end
        -- draw_sprite_ext(spr_yellow_evidence, 0, cam_mid + (85 * diff), cam_height + (sin((global.time * 0.1) + a) * 2) + offset, (diff == 0) ? 2 : 1.5, (diff == 0) ? 2 : 1.5, 45, (diff == 0) ? #D6FEFE : c_gray, 1)
        -- draw_sprite_ext(spr_yellow_evidence, array_get(ds_list_find_value(evidence_list, a), 3), cam_mid + (85 * diff), cam_height + (sin((global.time * 0.1) + a) * 2) + offset, 2, 2, 0, c_white, 1)
    end
    if Game.battle.state == "BATTLETEXT" and Game.battle.state_reason == "JUSTICEACCUSE" or Game.battle.state_reason == "JUSTICEEVIDENCE" then
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.push()
        love.graphics.translate(-self.x, -self.y)
        love.graphics.rectangle("fill", -40, -40, SCREEN_WIDTH + 80, SCREEN_HEIGHT + 80)
        love.graphics.pop()

        love.graphics.setFont(Assets.getFont("main"))
        love.graphics.setColor(COLORS.white)
        if Game.battle.state_reason == "JUSTICEACCUSE" then
            love.graphics.print(Chapter5Lib.case_desc, 30, 51)
            love.graphics.setColor(ColorUtils.hexToRGB("9a7ed3"))
            for a = 0, 8 do
                if ((a % 2) == 0) then
                    love.graphics.setLineWidth(4)
                    love.graphics.line(380, 51 + 10 * a, 380, 61 + 10 * a)
                end
            end
        elseif Game.battle.state_reason == "JUSTICEEVIDENCE" then
            love.graphics.print(Chapter5Lib.trial_evidence[1].description, 30, 51)
            love.graphics.setColor(ColorUtils.hexToRGB("9a7ed3"))
            for a = 0, 8 do
                if ((a % 2) == 0) then
                    love.graphics.setLineWidth(4)
                    love.graphics.line(380, 51 + 10 * a, 380, 61 + 10 * a)
                    love.graphics.print("EVIDENCE:\n"..Chapter5Lib.trial_evidence[1].name, 400, 51)
                end
            end
            love.graphics.setColor(COLORS.white)
            love.graphics.print(tostring(Chapter5Lib.selection), 300, -200)
            Draw.draw(Assets.getTexture("ui/battle/evidence/border"), 570, 85, 0, 2, 2)
            Draw.draw(Assets.getTexture("ui/battle/evidence/evidence_"..string.lower(Chapter5Lib.trial_evidence[1].name)), 570, 85, 0, 2, 2)
        end
    end
end

function BattleUI:update()
    super.update(self)
    if Game.battle.state == "BATTLETEXT" and Game.battle.state_reason == "JUSTICEACCUSE" or Game.battle.state_reason == "JUSTICEEVIDENCE" then
        local pre = Chapter5Lib.selection

        if (Input.keyPressed("left", true)) then
            pre = Chapter5Lib.selection - 1
        end
        if (Input.keyPressed("right", true)) then
            pre = Chapter5Lib.selection + 1
        end

        if pre < 1 then
            pre = Chapter5Lib.selection_max
        end
        if pre > Chapter5Lib.selection_max then
            pre = 1
        end
        Chapter5Lib.selection = pre
    end
end

return BattleUI

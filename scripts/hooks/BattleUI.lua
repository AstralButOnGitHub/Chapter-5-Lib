local BattleUI, super = HookSystem.hookScript(BattleUI)

function BattleUI:draw()
    super.draw(self)
    local trial = Chapter5Lib.trial_controller
    if trial ~= nil then
        if Game.battle.state == "MENUSELECT" and Game.battle.state_reason == "ACT" then
            local a = 0
            for _, evid in ipairs(trial.trial_evidence) do
                Draw.setColor(COLORS.gray)
                Draw.draw(Assets.getTexture("ui/battle/evidence/border_angled"), 16 + (60 * a), 96 + (math.sin((Kristal.getTime()) + a) * 2), 0)
                Draw.draw(Assets.getTexture("ui/battle/evidence/evidence_"..string.lower(evid.name)), 21 + (60 * a), 100 + (math.sin((Kristal.getTime()) + a) * 2), 0)
                a = a + 1
            end
            -- draw_sprite_ext(spr_yellow_evidence, 0, cam_mid + (85 * diff), cam_height + (sin((global.time * 0.1) + a) * 2) + offset, (diff == 0) ? 2 : 1.5, (diff == 0) ? 2 : 1.5, 45, (diff == 0) ? #D6FEFE : c_gray, 1)
            -- draw_sprite_ext(spr_yellow_evidence, array_get(ds_list_find_value(evidence_list, a), 3), cam_mid + (85 * diff), cam_height + (sin((global.time * 0.1) + a) * 2) + offset, 2, 2, 0, c_white, 1)
        end
        if Game.battle.state == "BATTLETEXT" and (Game.battle:getSubState() == "JUSTICEACCUSE" or Game.battle:getSubState() == "JUSTICEEVIDENCE") then
            love.graphics.setColor(0, 0, 0, 0.6)
            love.graphics.push()
            love.graphics.translate(-self.x, -self.y)
            love.graphics.rectangle("fill", -40, -40, SCREEN_WIDTH + 80, SCREEN_HEIGHT + 80)
            love.graphics.setColor(COLORS.white)
            local perp = trial.trial_perps[trial.selected_perp]
            local center_perp = trial.trial_perps[3]

            local tex = Assets.getTexture("ui/battle/evidence/trial_spotlight")
            Draw.draw(tex, perp.actor.x - tex:getWidth(), perp.anchor_y - 180, 0, 2, 2.5)

            if Game.battle:getSubState() == "JUSTICEACCUSE" then
                love.graphics.setColor(COLORS.white)
                love.graphics.setFont(Assets.getFont("main"))
                if Input.active_gamepad then
                    love.graphics.print("[Z] to accuse.", perp.actor.x, perp.anchor_y + 80)                
                else
                    love.graphics.print("[Z] to accuse.", perp.actor.x - (Assets.getFont("main"):getWidth("[Z] to accuse.") / 2), perp.anchor_y + 48)
                end
            elseif Game.battle:getSubState() == "JUSTICEEVIDENCE" then
                love.graphics.setColor(COLORS.white)
                love.graphics.setFont(Assets.getFont("main"))
                if Input.active_gamepad then
                    love.graphics.print("[Z] to accuse.", perp.actor.x, perp.anchor_y + 80)                
                else
                    love.graphics.print("[Z] Choose [X] Reconsider", center_perp.actor.x - (Assets.getFont("main"):getWidth("[Z] Choose [X] Reconsider") / 2), center_perp.anchor_y + 48)
                end
            end

            love.graphics.pop()

            love.graphics.setFont(Assets.getFont("main"))
            if Game.battle:getSubState() == "JUSTICEACCUSE" then
                love.graphics.print(trial.case_desc, 30, 51)
                love.graphics.setColor(ColorUtils.hexToRGB("9a7ed3"))
                for a = 0, 8 do
                    if ((a % 2) == 0) then
                        love.graphics.setLineWidth(4)
                        love.graphics.line(380, 51 + 10 * a, 380, 61 + 10 * a)
                    end
                end
            elseif Game.battle:getSubState() == "JUSTICEEVIDENCE" then
                love.graphics.print(trial.trial_evidence[trial.selected_evid].description, 30, 51)
            end
            love.graphics.setColor(ColorUtils.hexToRGB("9a7ed3"))
            for a = 0, 8 do
                if ((a % 2) == 0) then
                    love.graphics.setLineWidth(4)
                    love.graphics.line(380, 51 + 10 * a, 380, 61 + 10 * a)
                    love.graphics.print("EVIDENCE:\n"..trial.trial_evidence[trial.selected_evid].name, 400, 51)
                end
            end
            love.graphics.setColor(COLORS.white)
            Draw.draw(Assets.getTexture("ui/battle/evidence/border"), 570, 85, 0, 2, 2)
            Draw.draw(Assets.getTexture("ui/battle/evidence/evidence_"..string.lower(trial.trial_evidence[trial.selected_evid].name)), 570, 85, 0, 2, 2)
            -- love.graphics.print("still need to render heart and shi", 20, -300)
        end
    end
end

return BattleUI

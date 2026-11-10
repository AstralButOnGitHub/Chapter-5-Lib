---@class TrialController : Object
---@overload fun(...) : TrialController
local TrialController, super = Class(Object)

function TrialController:init(battler)
    super.init(self, 0, 0, 20, 20)

    self.battler = battler
    self.trial_count = 1
    self.podiums = {}
    self.trial_evidence = {}
    self.trial_perps = {}
    self.trials = {}
    Chapter5Lib.trial_controller = self
    self.choose_music = "mus_date_tense"
    self.reveal_music = "mus_date_fight"
    self.selected_perp = 1
    self.selected_evid = 1
    self.selected_perp_max = #self.trial_perps
    self.selected_evid_max = #self.trial_evidence
end

function TrialController:update()
    super.update(self)

    if Game.battle:getSubState() == "JUSTICEREVEAL" then
        for a, perp in ipairs(self.trial_perps) do
            if perp.actor ~= nil then
                perp.actor:setLayer(9000)
                perp.actor.y = self.selected_perp == a and perp.testimony_y or perp.anchor_y
            end
        end
    end
    if Game.battle.state == "BATTLETEXT" and (Game.battle:getSubState() == "JUSTICEACCUSE" or Game.battle:getSubState() == "JUSTICEEVIDENCE") then
        local preperp = self.selected_perp
        local preevid = self.selected_evid

        for a, perp in ipairs(self.trial_perps) do
            if perp.actor ~= nil then
                if self.selected_perp ~= a then
                    if perp.bubble ~= nil then
                        perp.bubble:remove()
                    end
                    perp.bubble = nil
                end
                if self.selected_perp == a and perp.bubble == nil and perp.hover_messages[self.trial_count] ~= "" then
                    perp.bubble = self:createBubble(perp.hover_messages[self.trial_count], perp.actor.x + (perp.actor.width / 2), perp.anchor_y - (perp.actor.height * 2.75), {direction = "down"}, nil, false)
                end

                if self.selected_perp == a then
                    perp.actor:setLayer(9000)
                    perp.actor.y = MathUtils.approach(perp.actor.y, perp.testimony_y, math.abs(perp.actor.y - perp.testimony_y) * 0.15)
                else
                    perp.actor:setLayer(50)
                    perp.actor.y = MathUtils.approach(perp.actor.y, perp.anchor_y, math.abs(perp.actor.y - perp.anchor_y) * 0.5)
                end
            end
        end

        if (Input.keyPressed("left", false)) then
            if Game.battle:getSubState() == "JUSTICEEVIDENCE" then
                preevid = self.selected_evid - 1
            else
                preperp = self.selected_perp - 1
            end
        end
        if (Input.keyPressed("right", false)) then
            if Game.battle:getSubState() == "JUSTICEEVIDENCE" then
                preevid = self.selected_evid + 1
            else
                preperp = self.selected_perp + 1
            end
        end
        if (Input.keyPressed("z", false)) then
            if Game.battle:getSubState() == "JUSTICEEVIDENCE" then
                self:startResponse()
            elseif Game.battle:getSubState() == "JUSTICEACCUSE" then
                Game.battle:setSubState("JUSTICEEVIDENCE")
            end
        end
        if (Input.keyPressed("x", false)) then
            if Game.battle:getSubState() == "JUSTICEEVIDENCE" then
                Game.battle:setSubState("JUSTICEACCUSE")
            end
        end

        if preevid < 1 then
            preevid = 1
        end
        if preevid > self.selected_evid_max then
            preevid = self.selected_evid_max
        end
        self.selected_evid = preevid

        if preperp < 1 then
            preperp = self.selected_perp_max
        end
        if preperp > self.selected_perp_max then
            preperp = 1
        end
        self.selected_perp = preperp
    end
end

function TrialController:remove()
    super.remove(self)
    Chapter5Lib.trial_controller = nil
end

function TrialController:start()
    self.selected_perp_max = #self.trial_perps
    self.selected_evid_max = #self.trial_evidence

    for _, p in ipairs(self.podiums) do
        p:remove()
    end
    for _, chara in ipairs(Game.battle.party) do
        chara:setActSprite("party/"..string.lower(chara.chara:getName()).."/dark/lawyer", 0, 0, 0, false)
        local y = 0
        if chara.chara:getName() == "Kris" then
            y = 17
        elseif chara.chara:getName() == "Susie" then
            y = 18
        elseif chara.chara:getName() == "Ralsei" then
            y = 23
        end
        -- (podium shouldn't have afterimage)
        local podium = Sprite("ui/battle/evidence/trial_podium_"..(chara.chara:getName() == "Ralsei" and 2 or 1), 16, y)
        chara:addChild(podium)
        table.insert(self.podiums, podium)
    end

    for _, perp in ipairs(self.trial_perps) do
        ---@type Actor
        local actor = perp.actor

        -- perp.original_sprite = actor.sprite
        -- perp.original_speed = actor:onSetSprite
    end

    -- this should only happen if it's successfull
end

function TrialController:finish()
    for _, p in ipairs(self.podiums) do
        p:remove()
    end
    Game.battle.music:play(self.pre_music)
    for _, value in ipairs(Game.battle.enemies) do
        value.alpha = 1
    end
    for _, perp in ipairs(self.trial_perps) do
        if perp.actor ~= nil then
            perp.actor:setPosition(-1000, -1000)
            if perp.bubble ~= nil then
                perp.bubble:remove()
            end
            perp.bubble = nil
        end
    end
    Game.battle:finishAction()
    Game.battle:setState("ENEMYDIALOGUE")
end

function TrialController:showPerps()
    for _, value in ipairs(Game.battle.enemies) do
        value.alpha = 0
    end
    Assets.playSound("boost")
    self.pre_music = Game.battle.music.current
    Game.battle.music:play(self.choose_music)

    local perp_amount = #self.trial_perps
    local cam_h = (SCREEN_WIDTH * 0.5)
    local cam_v = (SCREEN_HEIGHT * 0.5)
    local trial_gap = 80
    local trial_h = (cam_h - (perp_amount * (trial_gap * 0.5))) + 100
    for a, perp in ipairs(self.trial_perps) do
        if perp.actor ~= nil then
            perp.actor:setPosition(trial_h + (trial_gap * (a - 1)), cam_v)
            perp.testimony_y = perp.actor.y + 16
            perp.anchor_y = perp.actor.y
        end
    end
end

function TrialController:createBubble(text, x, y, options, fun, removable)
    local removable = removable
    if removable == nil then
        removable = true
    end
    local bubble = SpeechBubble(text, x, y, options, nil)
    Game.battle:addChild(bubble)
    self.bubble = bubble
    self.battler:onBubbleSpawn(bubble)
    if removable then
        bubble:setCallback(function()
            self.battler:onBubbleRemove(bubble)
            bubble:remove()
            self.bubble = nil
            if fun ~= nil then
                fun()
            end
        end)
    end
    return bubble
end

function TrialController:startChoosing()
    -- choosy choosy
    self.slected_perp = 1
    self.slected_evid = 1
    self:showPerps()
    Game.battle:setSubState("JUSTICEACCUSE")
end

function TrialController:startResponse()
    Game.battle:setSubState("JUSTICEREVEAL")
    for _, perp in ipairs(self.trial_perps) do
        if perp.bubble ~= nil then
            perp.bubble:remove()
        end
        perp.bubble = nil
    end
    local perp = self.trial_perps[self.selected_perp]

    self.battler:getResponse(perp, perp.actor.actor.name, (self.trials[self.trial_count] == perp.actor.actor.name), self.trial_evidence[self.selected_evid].name, function(success)
        if success then
            self.trial_count = self.trial_count + 1
            self:finish()
        else
            self:finish()
        end
    end)
end

return TrialController
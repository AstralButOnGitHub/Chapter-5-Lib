local NPC, super = HookSystem.hookScript(NPC)

function NPC:init(actor, x, y, properties)
    super.init(self, actor, x, y, properties)

    self.watered = false
    self.can_water = properties["can_water"]
    if self.can_water == nil then
        self.can_water = false
    end
    self.watered_text = TiledUtils.parsePropertyMultiList("watered_text", properties)
    self.flower_x = properties["flower_x"] or 0
    self.flower_y = properties["flower_y"] or 0

    local outlinefx = OutlineFX({COLORS.aqua[1], COLORS.aqua[2], COLORS.aqua[3], 0})
    self.outlinefx = self:addFX(outlinefx)
end

function NPC:water()
    if self.can_water and Input.down("confirm") and Game.world.player and Game.world.player:canWater() and not self.watered then
        self.watered = true
        self.can_water = false

        self.flower_sprite = Sprite("party/flower_only", self.flower_x, self.flower_y)
        self.flower_sprite:play(3/30, false)
        Assets.playSound("harp_strum", 1, 1.1)
        self:addChild(self.flower_sprite)
    end
end

function NPC:onInteract(player, dir)
    if self.can_water and player.held_object and player.held_object:includes(WateringCan) and self:meetsCollider(player.held_object.water_hitbox) then
        return
    end
    if self.watered and not self.can_water and self.watered_text ~= nil then
        if self.talk_sprite then
            self:setSprite(self.talk_sprite)
        end
        if self.turn then
            self:facePlayer()
        end
        self.interact_count = self.interact_count + 1

        if self.script then
            Registry.getEventScript(self.script)(self, player, dir)
        end
        if self.set_flag then
            Game:setFlag(self.set_flag, (self.set_value == nil and true) or self.set_value)
        end
        if self.cutscene then
            self.world:startCutscene(self.cutscene, self, player, dir):after(function()
                self:onTextEnd()
            end)
            return true
        elseif #self.watered_text > 0 then
            self.world:startCutscene(function(cutscene)
                cutscene:setSpeaker(self, self.talk)
                ---@type string|string[]
                local text = self.watered_text
                local text_index = MathUtils.clamp(self.interact_count, 1, #text)
                if type(text[text_index]) == "table" then
                    text = text[text_index]
                end
                for _, line in ipairs(text) do
                    cutscene:text(line)
                end
            end):after(function()
                self:onTextEnd()
            end)
            return true
        end
    end
    super.onInteract(self, player, dir)
end

return NPC
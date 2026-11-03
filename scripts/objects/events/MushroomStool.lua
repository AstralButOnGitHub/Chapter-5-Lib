---@class MushroomStool : Event
---@overload fun(...) : MushroomStool
local MushroomStool, super = Class(Event)

function MushroomStool:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self:setSprite("world/events/mushroom_stool")
    self.solid = true
    self:setHitbox(0, 20, 44, 26)
end

function MushroomStool:onInteract(player, dir)
    super.onInteract(self, player, dir)
    if player.held_object then
        -- yes this is how it works in dt, and yes this means watering cans are netskies.
        if player.held_object ~= nil and not player.held_object:includes(HeadMushroom) then
            if not player.held_object:includes(WateringCan) then
                Game.world:startCutscene(function(cutscene, event)
                    cutscene:text("* (Something else bit it first.)")
                end)
            end
            return
        end
    end
    if #Game.stage:getObjects(PhysicsMushroom) >= 50 then
        Game.world:startCutscene(function(cutscene, event)
            cutscene:text("* (There's too many mushroom for there to be much room.)")
        end)
        return
    end

    if not (Game:getFlag("has_interacted_three_times", 0) >= 3) then
        Game:setFlag("has_interacted_three_times", Game:getFlag("has_interacted_three_times", 0) + 1)
        Game.world:startCutscene(function(cutscene, event)
            if player.held_object and player.held_object:includes(HeadMushroom) then
                if #player.held_object.shroomstack >= 6 then
                    cutscene:text("* (You feel full.)\n* (Vertically.)")
                    return
                end
            end

            cutscene:text("* (It looks soft and delicious.[wait:5] Take a bite?)")
            local choice = cutscene:choicer({"Bite it", "Do not bite"})
            if choice == 1 then
                if not player.held_object or not player.held_object:includes(HeadMushroom) then
                    player.held_object = HeadMushroom()
                    player:addChild(player.held_object)
                    player.held_object.scale_x = .5
                    player.held_object.scale_y = .5
                end

                player.held_object:addShrooms(1)
            end
        end)
        return
    end

    Game.world:startCutscene(function(cutscene, event)
        if player.held_object and player.held_object:includes(HeadMushroom) then
            if #player.held_object.shroomstack >= 6 then
                cutscene:text("* (You feel full.)\n* (Vertically.)")
                return
            end
        end

        cutscene:text("* (Take a bite(s)?)")
        local choice = cutscene:choicer({"Bite 2x", "Bite 4x", "Bite 6x", "Don't bite"})
        if choice ~= 4 and (not player.held_object or not player.held_object:includes(HeadMushroom)) then
            player.held_object = HeadMushroom()
            player:addChild(player.held_object)
            player.held_object.scale_x = .5
            player.held_object.scale_y = .5
        end
        if choice == 1 then
            player.held_object:addShrooms(2)
        elseif choice == 2 then
            player.held_object:addShrooms(4)
        elseif choice == 3 then
            player.held_object:addShrooms(6)
        end
    end)
end

return MushroomStool
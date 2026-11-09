local Dummy, super = Class(EnemyBattler)

function Dummy:init()
    super.init(self)

    self.name = "Dummy"
    self:setActor("dummy")

    self.max_health = 450
    self.health = 450
    self.attack = 4
    self.defense = 0
    self.money = 100

    self.spare_points = 20

    self.dialogue = {
        "It's me, Yellow Deltarune!\nCan't you tell?"
    }

    self.check = "AT 4 DF 0\n* Cotton heart and button eye\n* Looks just like a fluffy guy."

    self.text = {
        "* The dummy gives you a soft\nsmile.",
        "* The power of fluffy boys is\nin the air.",
        "* Smells like cardboard.",
    }
    self.low_health_text = "* The dummy looks like it's\nabout to fall over."

    Chapter5Lib.trial_evidence = {
        {
            name = "PerpBook",
            description = "A purple book\nwith a decidedly\nfloral scent."
        },
        {
            name = "YellowShred",
            description = "A shred of yellow fabric\nwith a corn pattern. The\nhedge is black and smells."
        },
        {
            name = "RedSplatter",
            description = "A mysterious puddle\nof red criminal liquid."
        },
        {
            name = "BlueString",
            description = "String which could be used\nto bound something\nin care."
        },
        {
            name = "TrainPlan",
            description = "A blueprint which details\nhow to alter traintracks\ninto a smashing machine."
        },
        {
            name = "BootOil",
            description = "A black, opaque oil with no\ndistinctive odor. Used to\nunsqueaken Cowboy boots."
        },
        {
            name = "Scissors",
            description = "Obviously stolen scissors\nwhich could easily be used\nto cut up cloth."
        },
        -- {
        --     name = "Dog",
        --     description = "Dog."
        -- },
        {
            name = "Egg",
            description = "It's evidence. You'll know\nwhat it was evidence\nfor when it happens."
        }
    }
    Chapter5Lib.trial_perps = {
        {
            actor = Game.battle:addChild(Character("starwalker", -1000, -1000)),
            hover_messages = {
                "Hee hee!\nI did it!\nI did it!",
                "Hee hee!\nBurn, burn!",
                "It was me!! I killed\nthe handkerchiefs\nwith blood!!",
                "Hee hee, I couldn't\nfind them. Too bad."
            }
        },
        {
            actor = Game.battle:addChild(Character("noelle", -1000, -1000)),
            hover_messages = {
                "Me?![wait:2] I was just...[wait:2]\nreading a book! Ha!",
                "I was reading a\nbook by lamplight!",
                "Is there\nanyone besides\nSTARWALKER?",
                "Gee, I wonder\nwho it is."
            }
        },
        {
            name = "Green", hover_message = "Hee hee!\nI did it!\nI did it!"
        },
        {
            name = "Aqua", hover_message = "Hee hee!\nI did it!\nI did it!"
        },
        {
            name = "Blue", hover_message = "Hee hee!\nI did it!\nI did it!"
        },
    }
    Chapter5Lib.trial_count = 0
    self.podiums = {}

    self:registerAct("Justice", "Begin\nthe trial.", {"kris", "susie", "ralsei"}, 40)
end

function Dummy:startJustice()
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
    Chapter5Lib.trial_count = Chapter5Lib.trial_count + 1

    Game.battle:battleText("* You began the trial!", function()
        if Chapter5Lib.trial_count == 1 then
            local victum = Game.battle:addChild(Character("starwalker", self.x - 50, self.y + 50))
            self:createBubble("State yer case, victum!", self.x - 25, self.y - 50, "right", function()

                self:createBubble("I was crushed flat[wait:3]\nwithout permission.", self.x - 75, self.y + 25, "right", function()
                    self:createBubble("It's cool though.", self.x - 75, self.y + 25, "right", function()
                        self:createBubble("COOL AND ILLEGAL!!![wait:3]\nWhat criminells could\ndo such a crime!![wait:1]\nFind 'em!!", self.x - 25, self.y - 50, "right", function()
                            Chapter5Lib.case_desc = "Case 1: A Floradinn was\ncrushed flat!"
                            self:startChoosing()
                            victum:remove()
                        end)
                    end)
                end)
            end)
        elseif Chapter5Lib.trial_count == 2 then

        elseif Chapter5Lib.trial_count == 3 then

        end

        return true
    end)
end

function Dummy:createBubble(text, x, y, direction, fun)
    local bubble = SpeechBubble(text, x, y, {}, nil)
    Game.battle:addChild(bubble)
    self.bubble = bubble
    self:onBubbleSpawn(bubble)
    bubble:setCallback(function()
        self:onBubbleRemove(bubble)
        bubble:remove()
        self.bubble = nil
        if fun ~= nil then
            fun()
        end
    end)
    return bubble
end

function Dummy:startChoosing()
    -- choosy choosy
    Chapter5Lib.selection = 1
    Chapter5Lib.selection_max = #Chapter5Lib.trial_perps
    for _, p in ipairs(Chapter5Lib.trial_perps) do
        if p.actor ~= nil then
            p.actor:setPosition(-1000, -1000)
        end
    end
    Game.battle:setSubState("JUSTICEACCUSE")
end

function Dummy:getEnemyDialogue()
    for _, p in ipairs(self.podiums) do
        p:remove()
    end
    return super.getEnemyDialogue(self)
end

function Dummy:onAct(battler, name)
    if name == "Justice" then
        -- idk 
        self:startJustice()
    end

    return super.onAct(self, battler, name)
end

return Dummy
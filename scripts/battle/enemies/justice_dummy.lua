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

    self.trial = Game.battle:addChild(TrialController(self))

    self.trial.trial_evidence = {
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
    self.trial.trial_perps = {
        {
            actor = Game.battle:addChild(Character("aqua", -1000, -1000)),
            hover_messages = {
                "Hee hee!\nI did it!\nI did it!",
                "Hee hee!\nBurn, burn!",
                "It was me!! I killed\nthe handkerchiefs\nwith blood!!",
                "Hee hee, I couldn't\nfind them. Too bad."
            },
            testimony_y = 0
        },
        {
            actor = Game.battle:addChild(Character("seth", -1000, -1000)),
            hover_messages = {
                "Me?![wait:2] I was just...[wait:2]\nreading a book! Ha!",
                "I was reading a\nbook by lamplight!",
                "Is there\nanyone besides\nSTARWALKER?",
                "Gee, I wonder\nwho it is."
            },
            testimony_y = 0
        },
        {
            actor = Game.battle:addChild(Character("green", -1000, -1000)),
            hover_messages = {
                "",
                "",
                "",
                ""
            },
            testimony_y = 0
        },
        {
            actor = Game.battle:addChild(Character("yellow", -1000, -1000)),
            hover_messages = {
                "Ain't nothing under\nmy boot.",
                "Who's the liar!?",
                "Very dangerous.",
                "Admint it, you three!\nYou took them!!\nI know it!!"
            },
            testimony_y = 0
        },
        {
            actor = Game.battle:addChild(Character("blue", -1000, -1000)),
            hover_messages = {
                "Perhaps it was\nto preserve it?",
                "Was it on purpose?",
                "Was there another\nreason for it?",
                "..."
            },
            testimony_y = 0
        },
    }
    self.trial.trials = {
        "Seth", "Green", "Aqua", "Blue"
    }

    self:registerAct("Justice", "Begin\nthe trial.", {"kris", "susie", "ralsei"}, 40)
end

function Dummy:startJustice()
    self.trial:start()

    Game.battle:battleText("* You began the trial!", function()
        if self.trial.trial_count == 1 then
            local victum = Game.battle:addChild(Character("starwalker", self.x - 50, self.y + 50))
            self.trial:createBubble("State yer case, victum!", self.x - 25, self.y - 50, "piss", function()

                self.trial:createBubble("I was crushed flat[wait:3]\nwithout permission.", self.x - 75, self.y + 25, "right", function()
                    self.trial:createBubble("It's cool though.", self.x - 75, self.y + 25, "right", function()
                        self.trial:createBubble("COOL AND ILLEGAL!!![wait:3]\nWhat criminells could\ndo such a crime!![wait:1]\nFind 'em!!", self.x - 25, self.y - 50, "right", function()
                            self.trial.case_desc = "Case 1: A Floradinn was\ncrushed flat!"
                            self.trial:startChoosing()
                            victum:remove()
                        end)
                    end)
                end)
            end)
        elseif self.trial.trial_count == 2 then
            self.trial:startChoosing()
        elseif self.trial.trial_count == 3 then
            self.trial:startChoosing()
        elseif self.trial.trial_count == 4 then
            self.trial:startChoosing()
        end

        return true
    end)
end

function Dummy:getResponse(perpdata, perpname, guilty, evidence, fun)
    local cx, cy = perpdata.actor.x + (perpdata.actor.width / 2), perpdata.anchor_y - (perpdata.actor.height * 2.75)

    if perpname == "Aqua" then
        Chapter5Lib.logger:info("aqua")
        fun(false)
    elseif perpname == "Seth" then
        if guilty and evidence == "PerpBook" then

            Assets.playSound("damage")
            -- Game.fader:fadeOut(nil, {speed = 0.1/30, color = {1, 1, 1}})
            -- Game.fader:fadeIn(nil, {speed = 22.5/30})

            Game.battle.timer:after(45/30, function()
                self.trial:createBubble("Nnnrgh..[wait:1]. what's...\nwhat's your proof!?", cx, cy, {direction = "down"}, function()
                    self.trial:createBubble("Seth..[wait:2] may we see\nthe inside of\nyour book?", cx, cy, {direction = "down"}, function()
                        self.trial:createBubble("..[wait:1]. aren't there some\nflower petals pressed\ninside there?", cx, cy, {direction = "down"}, function()
                            self.trial:createBubble("..[wait:1]. I...", cx, cy, {direction = "down"}, function()
                                self.trial:createBubble("I admit it!!", cx, cy, {direction = "down"}, function()
                                    self.trial:createBubble("I wanted to try\npressing flowers!!\nI heard it was\nscientific!!", cx, cy, {direction = "down"}, function()
                                        self.trial:createBubble("Great work[wait:1], Blue!!", cx, cy, {direction = "down"}, function()
                                            self.trial:createBubble("Well[wait:1], you folks proved&one crime not yours.\nBut what about the rest!?", cx, cy, {direction = "down"}, function()
                                                fun(true)
                                            end)
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                end)
            end)

        elseif guilty and evidence == "TrainPlan" then
            self.trial:createBubble("A train!?\nYou think I used a TRAIN!?", cx, cy, {direction = "down"}, function()
                self.trial:createBubble("What kind of scientific\nknowledge could be\ngleaned from...", cx, cy, {direction = "down"}, function()
                    self.trial:createBubble("... I mean, uh,\nr-right to remain\nsilent!", cx, cy, {direction = "down"}, function()
                        fun(false)
                    end)
                end)
            end)
        elseif guilty and evidence ~= "PerpBook" then
            Chapter5Lib.logger:info("seth + other")
            fun(false)
        elseif not guilty then
            Chapter5Lib.logger:info("not seth + other")
            fun(false)
        else
            Chapter5Lib.logger:info("seth + other???")
            fun(false)
        end
    elseif perpname == "Green" then
        fun(false)
    elseif perpname == "Yellow" then
        fun(false)
    elseif perpname == "Blue" then
        fun(false)
    else
        fun(false)
    end
end

function Dummy:hoverPerpetrators()
    for _, perp in ipairs(self.trial.trial_perps) do
        if perp.actor.name == "Aqua" then

        elseif perp.actor.name == "Seth" then

        elseif perp.actor.name == "Green" then

        elseif perp.actor.name == "Yellow" then

        elseif perp.actor.name == "Blue" then

        end
    end
end

function Dummy:resetPerpetrators()
    for _, perp in ipairs(self.trial.trial_perps) do
        if perp.actor.name == "Aqua" then
            
        elseif perp.actor.name == "Seth" then

        elseif perp.actor.name == "Green" then

        elseif perp.actor.name == "Yellow" then

        elseif perp.actor.name == "Blue" then

        end
    end
end

function Dummy:onAct(battler, name)
    if name == "Justice" then
        self:startJustice()
    end

    return super.onAct(self, battler, name)
end

return Dummy
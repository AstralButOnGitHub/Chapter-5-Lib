local Dummy, super = Class(Encounter)

function Dummy:init()
    super.init(self)

    self.text = "* The justice is orange..."

    self.music = "battle"
    self.background = true

    self:addEnemy("justice_dummy")
end

return Dummy

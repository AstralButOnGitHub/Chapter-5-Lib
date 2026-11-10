local actor, super = Class(Actor, "aqua")

function actor:init()
    super.init(self)

    self.name = "Aqua"

    self.width = 20
    self.height = 36

    self.flip = nil

    self.path = "npcs/aqua/walk/down_1"
    self.default = ""

    self.voice = nil
    self.portrait_path = nil
    self.portrait_offset = nil

    self.can_blush = false

    self.talk_sprites = {}

    self.animations = {}

    self.offsets = {}
end

return actor

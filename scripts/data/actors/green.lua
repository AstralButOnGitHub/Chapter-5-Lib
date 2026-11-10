local actor, super = Class(Actor, "green")

function actor:init()
    super.init(self)

    self.name = "Green"

    self.width = 31
    self.height = 48

    self.flip = nil

    self.path = "npcs/green/walk/down_1"
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

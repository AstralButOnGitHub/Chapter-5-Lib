local actor, super = Class(Actor, "blue")

function actor:init()
    super.init(self)

    self.name = "Blue"

    self.width = 49
    self.height = 66

    self.flip = nil

    self.path = "npcs/blue/pose_3"
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

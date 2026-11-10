local actor, super = Class(Actor, "seth")

function actor:init()
    super.init(self)

    self.name = "Seth"

    self.width = 33
    self.height = 41

    self.flip = nil

    self.path = "npcs/seth/walk/down_1"
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

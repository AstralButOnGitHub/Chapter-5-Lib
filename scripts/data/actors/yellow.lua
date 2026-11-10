local actor, super = Class(Actor, "yellow")

function actor:init()
    super.init(self)

    self.name = "Yellow"

    self.width = 25
    self.height = 72

    self.flip = nil

    self.path = "npcs/yellow/walk/down_1"
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

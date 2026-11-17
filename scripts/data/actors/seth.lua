local actor, super = Class(Actor, "seth")

function actor:init()
    super.init(self)

    self.name = "Seth"

    self.width = 33
    self.height = 41

    self.flip = nil

    self.path = "npcs/seth"
    self.default = "walk/down_1"

    self.voice = nil
    self.portrait_path = nil
    self.portrait_offset = nil

    self.can_blush = false

    self.talk_sprites = {}

    self.animations = {
        ["nervous"] = { "nervous", 1/3, true },
    }

    self.offsets = {}
end

return actor

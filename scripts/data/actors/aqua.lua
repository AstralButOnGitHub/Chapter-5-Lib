local actor, super = Class(Actor, "aqua")

function actor:init()
    super.init(self)

    self.name = "Aqua"

    self.width = 20
    self.height = 36

    self.flip = nil

    self.path = "npcs/aqua"
    self.default = "walk/down_1"

    self.voice = nil
    self.portrait_path = nil
    self.portrait_offset = nil

    self.can_blush = false

    self.talk_sprites = {}

    self.animations = {
        ["sleevewave"] = { "sleevewave", 1/3, true },
    }

    self.offsets = {}
end

return actor

local actor, super = Class("susie", true)

function actor:init()
    super.init(self)

    self.zen_footprints = {
        ["up"] = "footprints/sus_u",
        ["down"] = "footprints/sus_d",
        ["left"] = "footprints/sus_l",
        ["right"] = "footprints/sus_r"
    }
end

return actor
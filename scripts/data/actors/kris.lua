local actor, super = Class("kris", true)

function actor:init()
    super.init(self)

    TableUtils.merge(self.offsets, {
        ["small/left"] = {-13, -9},
        ["small/right"] = {0, -9},
        ["medium/left"] = {-17, -14},
        ["medium/right"] = {0, -14},
        ["dog/left"] = {-13, -9},
        ["dog/right"] = {0, -9},
    }, false)

    self.zen_footprints = {
        ["up"] = "footprints/u",
        ["down"] = "footprints/d",
        ["left"] = "footprints/l",
        ["right"] = "footprints/r"
    }
end

return actor
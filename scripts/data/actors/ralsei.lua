local actor, super = Class("ralsei", true)

function actor:init()
    super.init(self)
    self.can_bloom = true
    self.offsets = TableUtils.merge(self.offsets, {
        ["plat_run"] = {0, -10},
    })

    self.zen_footprints = {
        ["up"] = "footprints/ral_u",
        ["down"] = "footprints/ral_d",
        ["left"] = "footprints/ral_l",
        ["right"] = "footprints/ral_r"
    }
end

return actor
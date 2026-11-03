local actor, super = Class("ralsei", true)

function actor:init()
    super.init(self)
    self.can_bloom = true
    self.offsets = TableUtils.merge(self.offsets, {
        ["plat_run"] = {0, -10},
    })
    self.offsets = TableUtils.merge(self.offsets, {
        ["climb/climbing"] = {-5, -15},
        ["climb/fall"] = {-3, -14},
        ["climb/charge"] = {-4, -12},
        ["climb/charge_right"] = {-4, -12},
        ["climb/charge_left"] = {-4, -12},
        ["climb/slip_right"] = {-3, -13},
        ["climb/slip_left"] = {-2, -13},
        ["climb/jump_up"] = {-4, -13},
        ["climb/land_right"] = {-4, -13},
        ["climb/land_left"] = {-4, -13}
    })
    self.zen_footprints = {
        ["up"] = "footprints/ral_u",
        ["down"] = "footprints/ral_d",
        ["left"] = "footprints/ral_l",
        ["right"] = "footprints/ral_r"
    }
end

return actor
local actor, super = Class("susie", true)

function actor:init()
    super.init(self)

    self.zen_footprints = {
        ["up"] = "footprints/sus_u",
        ["down"] = "footprints/sus_d",
        ["left"] = "footprints/sus_l",
        ["right"] = "footprints/sus_r"
    }
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
end

return actor
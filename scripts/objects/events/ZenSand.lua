---@class ZenSand : Event
---@overload fun(...) : ZenSand
local ZenSand, super = Class(Event)

function ZenSand:init(x, y, shape, properties)
    super.init(self, x, y, shape)

    self.properties = properties

    self.printcount = 0

    self.outline = ColorUtils.hexToRGB("#9CA9DA")
    self.printCol = {ColorUtils.hexToRGB("#8A95C5"), ColorUtils.hexToRGB("#828CB7")}
    self.dark = {ColorUtils.hexToRGB("#8691C0"), ColorUtils.hexToRGB("#8691C0")}
    self.tempCol = ColorUtils.hexToRGB("#717DAE")
end

function ZenSand:createPrint(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    arg4 = arg4 or 0
    arg5 = arg5 or false
    arg6 = arg6 or -1
    if ((arg0 + 5) < self.x or (arg1 + 5) < self.y or (arg0 - 5) > (self.x + self.width) or (arg1 - 5) > (self.y + self.width)) then
        return
    end

    self.printcount = self.printcount + 1
    local _temp = ColorUtils.mergeColor(ColorUtils.hexToRGB("#C09186"), COLORS.black, 0.5)
    local _xx = MathUtils.round((arg0 - self.x) / 2)
    local _yy = MathUtils.round((arg1 - self.y) / 2)

    if (arg6 < 0) then
        arg6 = math.random(1)
    end

    -- gpu_set_colorwriteenable(false, false, false, true)
    -- draw_sprite_ext(arg2, ((arg3 - 1) / 2) + 2, _xx, _yy, 1, 1, 0, outline, 1)
    -- gpu_set_colorwriteenable(true, true, true, true)
    -- draw_sprite_ext(arg2, (arg3 - 1) / 2, _xx, _yy - 1, 1, 1, 0, dark[arg6], 1)
    -- draw_sprite_ext(arg2, (arg3 - 1) / 2, _xx, _yy, 1, 1, 0, outline, 1)
    -- draw_sprite_ext(arg2, (arg3 - 1) / 2, _xx, _yy, 1, 1, 0, printCol[arg6], 0.5)

    if (arg5) then
        local sprite = Sprite("effects/"..arg2.."_"..((arg3 - 1) / 2) + 1, (_xx * 2) + self.x, (_yy * 2) + self.y)
        sprite:setScale(2, 2)
        sprite.layer = self.layer - 0.1
        Game.world:addChild(sprite)
        sprite:fadeOutAndRemove(20/30)
        sprite.color = _temp
        -- with (instance_create((_xx * 2) + x, (_yy * 2) + y, obj_footprint))
        -- {
        --     sprite_index = arg2
        --     image_index = (arg3 - 1) / 2
        --     image_speed = 0
        --     lifetime = 30
        --     image_blend = _temp
        --     image_alpha = 0.5
        --     fadetime = 20 / image_alpha
        --     image_xscale = 2
        --     image_yscale = 2
        --     depth = other.depth - 10
        -- }
    end

    for i = 1, math.random(3), 1 do
        local _particle = TableUtils.pick({self.printCol[1], self.printCol[2]})

        if (arg4 == 0) then
            _yy = _yy + 2
        elseif (arg4 == 1) then
            _xx = _xx + 4
        elseif (arg4 == 2) then
            _yy = _yy - 2
        else
            _xx = _xx - 4
        end
        -- draw_sprite_ext(spr_whitepixel, 0, _xx + irandom_range(-8, 8), _yy + irandom_range(-5, 5), 1, 1, 0, _particle, 1)
    end
end

return ZenSand
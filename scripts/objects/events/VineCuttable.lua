---@class VineCuttable : Event
---@overload fun(...) : VineCuttable
local VineCuttable, super = Class(Event)

function VineCuttable:init(data)
    super.init(self, data)
    self.properties = data.properties or {}

    self.bloom_state = self.properties["bloom_state"] or 3
    self:setHitbox(0, 0, 40, 40)
    self.climbarea = Game.world:addChild(ClimbArea(self.x, self.y, {40, 40}))
    self.climbarea.isClimbable = function()
        return self.image_index == self.image_index_start + 4
    end
    --#9D8772
    self.sprite_column = self.properties["sprite_column"] or 6
    self.sprite_index = "world/events/vines_cuttable/climb_vines_"
    self.image_index_start = 10 * self.sprite_column
    self.image_index = self.image_index_start + 4
    self.exact_frame = self.image_index
    self.image_index_target = self.image_index

    self.dark_blend = ColorUtils.mergeColor(COLORS.black, COLORS.green, 0.2);

    self.darkenShader = love.graphics.newShader[[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 texcolor = Texel(texture, texture_coords) * color;
            texcolor.rgb = texcolor.rgb + vec3(1.0 - texcolor.a);
            
            return texcolor;
        }
    ]]
end

function VineCuttable:onLoad()
    super.onLoad(self)
    self.layer = self.layer - 0.1

    --singular
        --waittime = 4
        -- sprite_column = 6

    --top
        -- waittime = 4

    --middle
        -- waittime = 4
        -- sprite_column = 1

    --bottom
        -- waittime = 4
        -- sprite_column = 5

    --short bottom
        --11
end

function VineCuttable:canCut()
    return self.image_index == self.image_index_start + 4
end

function VineCuttable:cut()
    self.bloom_state = 1
    self.exact_frame = self.image_index_start

    self.image_index = self.image_index_start
    self.image_index_target = self.image_index_start + 4
end

function VineCuttable:update()
    super.update(self)

    self.exact_frame = MathUtils.approach(self.exact_frame, self.image_index_target, (DTMULT / 30) * 8)
    self.image_index = math.floor(self.exact_frame)
end

function VineCuttable:draw()
    super.draw(self)

    if DEBUG_RENDER then
        if self:canCut() then
            Draw.setColor(0, 1, 0, 1)
        else
            Draw.setColor(1, 0, 0, 1)
        end
        love.graphics.circle("line", 20, 20, 20)
        Draw.setColor(1, 1, 1, 1)
    end
    local draw_top_end = false

    -- with (upper_vine)
    -- {
    --     if ((image_index % 10) == 0)
    --         draw_top_end = true
    -- }

    if self.image_index ~= (self.image_index_start + 5) then
        love.graphics.setShader(self.darkenShader)
        love.graphics.setColor(self.dark_blend)

        Draw.draw(Assets.getTexture(self.sprite_index..self.image_index_start + 9) or Assets.getTexture("world/events/watering/growgrass/growgrass_pink_6"), 0, 0, 0, 2, 2)

        love.graphics.setShader()
        love.graphics.setColor(COLORS.white)
    end

    -- if (draw_top_end)
    --     draw_sprite_ext(sprite_index, image_index, x, y - 40, 2, 2, 0, c_white, 1)

    Draw.draw(Assets.getTexture(self.sprite_index..self.image_index + 5) or Assets.getTexture("world/events/watering/growgrass/growgrass_pink_6"), 0, 0, 0, 2, 2)
end

return VineCuttable
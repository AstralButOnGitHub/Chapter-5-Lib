---@class FusumaWall : Event
---@overload fun(...) : FusumaWall
local FusumaWall, super = Class(Event)

-- based on `Silhouette`
function FusumaWall:init(x, y, shape, properties)
    super.init(self, x, y, shape)

    self.properties = properties

    self.solid = false

    self.yoffset = self.properties["yoffset"] or 0
    self.style = self.properties["style"] or "floral"
    self.borders = self.properties["borders"]
    if self.borders == nil then
        self.borders = true
    end
    self.hidden = self.properties["hidden"]
    if self.hidden == nil then
        self.hidden = false
    end
    self.door = self.properties["door"]
    self.color = TiledUtils.parseColorProperty(self.properties["color"]) or ColorUtils.hexToRGB("83503a")
    if self.style == "red" then
        self.color = TiledUtils.parseColorProperty(self.properties["color"]) or ColorUtils.hexToRGB("bf1919")
    end
    self.color = {self.color[1], self.color[2], self.color[3], 188/255}

    self.default_has_shadows = {
        Character,
        WorldBullet,
        TreasureChest,
        AquaKnife,
        NetskieObject,
        PhysicsMushroom,
        SlidingTerracotta
    }
end

function FusumaWall:getSortPosition()
    return self:getRelativePos(0, self.height - self.yoffset)
end

function FusumaWall:drawObject(object)
    love.graphics.push()
    object:preDraw()

    local draws = {}
    local function removeChildrenDraws(obj)
        if not obj.children then return end
        for _, child in ipairs(obj.children) do
            if child.skip_fusuma then
                draws[child] = child.draw
                child.draw = function() end
            end
            removeChildrenDraws(child)
        end
    end

    removeChildrenDraws(object)
    object:draw()

    for child, old_draw in pairs(draws) do
        child.draw = old_draw
    end

    object:postDraw()
    love.graphics.pop()
end

function FusumaWall:draw()
    super.draw(self)

    if self.hidden == false and self.door == nil then
        Draw.setColor(1, 1, 1, 1)
        local texture = Assets.getTexture("world/events/fusuma/flippainting_"..self.style)
        texture:setWrap("repeat")
        Draw.drawPart(texture, 0, 0, self.x / 2, self.y / 2, self.width / 2, self.height / 2, 0, 2, 2)
    end
    if DEBUG_RENDER then
        love.graphics.print(TableUtils.dump(self.properties))
    end

    local canvas = Draw.pushCanvas(self.width, self.height)
    love.graphics.clear()

    love.graphics.translate(-self.x, -self.y)

    love.graphics.setShader(Kristal.Shaders["White"])
    Kristal.Shaders["White"]:send("whiteAmount", 1)
    for _, object in ipairs(Game.world.children) do
        for _, value in ipairs(self.default_has_shadows) do
            if object.x - self.x <= self.width + 40 or object.x + self.width >= self.width + 40 then
                if object.skip_fusuma ~= true and (object:includes(value) or object.draw_fusuma_shadow == true) then
                    self:drawObject(object)
                    break
                end
            end
        end
    end
    love.graphics.setShader()

    Draw.popCanvas()

    Draw.setColor(self.color)
    Draw.draw(canvas)
    if self.hidden == false and self.door == nil then
        love.graphics.setLineWidth(4)
        love.graphics.setColor(.5, 0.3, 0, 0.2)
        love.graphics.rectangle("line", 6, 6, self.width - 8, self.height - 8)
        love.graphics.setColor(ColorUtils.hexToRGB("c12439"))
        love.graphics.rectangle("line", 2, 2, self.width - 4, self.height - 4)
    end
    Draw.setColor(1, 1, 1, 1)
    if self.door ~= nil then
        love.graphics.draw(Assets.getTexture("world/events/fusuma/door_"..self.door.."_overlay"), 0, 0, 0, 2, 2)
    end
end

return FusumaWall
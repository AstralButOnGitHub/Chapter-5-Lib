local TileButton, super = HookSystem.hookScript(TileButton)

function TileButton:update()
    if self.block_activated then

        Object.startCache()
        local collided = nil
        for _,netskie in ipairs(Game.stage:getObjects(NetskieObject)) do
            if netskie.style == "block" and not netskie.revealed and netskie:meetsObject(self) then
                collided = netskie
                break
            end
        end
        Object.endCache()

        self:setPressed(collided ~= nil)
    end

    super.update(self)
end

return TileButton
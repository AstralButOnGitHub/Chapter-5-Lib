---@class FallingPeach : Object
---@overload fun(...) : FallingPeach
local FallingPeach, super = Class(Object)

function FallingPeach:init(x, y, bad, width, height)
    super.init(self, x, y, width, height)
    self.bad = bad or false
    self.sprite = self:addChild(Sprite(self.bad == false and "world/events/peach/peach" or "world/events/peach/spiky_peach"))
    self.sprite:setScale(2)
    self.bullet = Game.world:addChild(WorldBullet(0, 0, self.sprite.texture))
    self.bullet.layer = self.layer + 1
    self.bullet.width = 20
    self.bullet.height = 20
    self.bullet.damage = 30
    self:setHitbox(0, 0, 40, 40)
    self.bouncerange = 4
    self.bouncemin = -6
    self.consistent = false
    self.waitmin = 40
    self.waitmax = 60
    self.timer = 0
    -- con my beloved
    self.con = 0
    self.damagecon = 0
    self.cury = self.y + math.random(50) + 10;
    self.xstart = self.x
    self.ystart = self.y
    self.physics.gravity = 0.5
    self.fading = false
end

function FallingPeach:remove()
    self.bullet:remove()
    super.remove(self)
end

function FallingPeach:moveX(arg0)
    local targx = math.random(8, 12) * 2
    if (self.x > self.xstart) then
        targx = -targx
    end
    self.wasx = self.x
    self.xtarg = self.x + targx
end

function FallingPeach:newWait()
    if (self.consistent or self.distance_activate) then
        return (self.waitmin + self.waitmax) / 2
    end
    return math.random(self.waitmin, self.waitmax)
end

function FallingPeach:update()
    super.update(self)
    self.bullet:setPosition(self.x + 20, self.y + 20)

    if Game.world and self.fading == false then
        for _, zone in ipairs(Game.world.map:getEvents("PeachRemoveZone")) do
            if self:meetsObject(zone) then
                self.fading = true
                self.sprite:fadeTo(0, 1, function()
                    self:remove()
                end)
            end
        end
    end
    if (self.con == 0) then
        self.waittime = self:newWait()
        self:moveX(self.waittime)
        self.timer = 0
        self.cury = self.y
        self.con = 1
    end

    if (self.con == 1) then
        self.timer = self.timer + 1

        if (not self.caught) then
            self.x = MathUtils.lerp(self.wasx, self.xtarg, self.timer / self.waittime)
        end

        if (self.y > (self.cury + self.waittime)) then
            self.physics.speed_y = (self.bouncemin + MathUtils.random(self.bouncerange)) / 2

            if (self.consistent) then
                self.physics.speed_y = (self.bouncemin + (0.5 * self.bouncerange)) / 2
            end
            self.con = 0
        end
    end

    if (self.damagecon == 1) then
        if (not self.bad) then
            self.physics.speed_y = 0;
            self.physics.gravity = 0;
            
            -- with (obj_lerpvar)
            -- {
            --     if (target == other.id) then
            --         instance_destroy();
            --     end
            -- }
            
            if (not self.invincible) then
                self.damagecon = 2;
                -- self.active = 0;
            else
                self.damagecon = 0;
            end
        else
            -- with (obj_climb_kris)
            --     didhit = other.id;
            
            self.damagecon = 20;
        end
    end

    -- if (damagecon == 2) then
    --     with (scr_marker_ext(x, y, 7524, 2, 2, 0, undefined, undefined, undefined, undefined, undefined, undefined, true))
    --     {
    --         timer = 0;
            
    --         step_func = function()
    --         {
    --             timer++;
                
    --             if (timer == 1)
    --             {
    --                 scr_shakeobj();
    --                 snd_play(snd_swing, 0.4, 1.2);
    --                 snd_play(snd_laz_c, 0.3, 1.2);
    --             }
                
    --             if (timer == 8)
    --             {
    --                 snd_play(snd_swing, 1, 0.7);
    --                 snd_play(snd_damage, 0.5, 0.7);
    --                 snd_play(snd_punchmed, 0.4, 1.4);
                    
    --                 with (scr_marker_ext(xstart, ystart, sprite_index, 2, 2, 0, 1, undefined, undefined, undefined, undefined, undefined, 1))
    --                 {
    --                     depth = 4999;
    --                     gravity = 0.5;
    --                     direction = 135;
    --                     friction = 0.01;
    --                     speed = 5;
    --                     timer = 0;
                        
    --                     step_func = function()
    --                     {
    --                         if (y > (cameray() + 560))
    --                             instance_destroy();
    --                     };
    --                 }
                    
    --                 with (scr_marker_ext(xstart, ystart, sprite_index, 2, 2, 0, 2, undefined, undefined, undefined, undefined, undefined, 1))
    --                 {
    --                     depth = 5001;
    --                     gravity = 0.25;
    --                     direction = 315;
    --                     friction = 0.01;
    --                     speed = 2;
    --                     timer = 0;
                        
    --                     step_func = function()
    --                     {
    --                         if (y > (cameray() + 560))
    --                             instance_destroy();
    --                     };
    --                 }
                    
    --                 with (instance_create(xstart, ystart, obj_marker_fancy))
    --                 {
    --                     depth = 5000;
    --                     gravity = 0.7;
    --                     vspeed = -4;
    --                     juice = [];
    --                     var juicecount = irandom_range(24, 32);
                        
    --                     for (var i = 0; i < juicecount; i++)
    --                     {
    --                         var _j = 
    --                         {
    --                             x: x,
    --                             y: y,
    --                             xprevious: x,
    --                             yprevious: y,
    --                             direction: ((i / juicecount) * 360) + random_range(-8, 8) + 6,
    --                             speed: random_range(2, 6),
    --                             friction: random_range(0.001, 0.02),
    --                             scale: random_range(12, 30),
    --                             col: merge_color(#FFA201, #F199BC, random_range(0, 0.25))
    --                         };
    --                         array_push(juice, _j);
    --                     }
                        
    --                     end_step_func = function()
    --                     {
    --                         for (var i = 0; i < array_length(juice); i++)
    --                         {
    --                             var j = juice[i];
    --                             j.scale = j.scale * 0.95;
    --                             j.xprevious = j.x;
    --                             j.yprevious = j.y;
    --                             j.speed = j.speed * (1 - j.friction);
    --                             j.x += lengthdir_x(j.speed, j.direction);
    --                             j.y += lengthdir_y(j.speed, j.direction) + (y - yprevious);
    --                         }
    --                     };
                        
    --                     draw_func = function()
    --                     {
    --                         var dokill = true;
    --                         var spritecount = 0;
    --                         var cy = cameray() + 480;
                            
    --                         for (var i = 0; i < array_length(juice); i++)
    --                         {
    --                             var j = juice[i];
                                
    --                             if (j.scale > 0.00390625)
    --                             {
    --                                 var count = max(2, round(point_distance(j.x, j.y, j.xprevious, j.yprevious)));
                                    
    --                                 for (var k = 0; k < count; k++)
    --                                 {
    --                                     var _x = lerp(j.xprevious, j.x, k / count);
    --                                     var _y = lerp(j.yprevious, j.y, k / count);
                                        
    --                                     if (_y < cy)
    --                                         dokill = false;
                                        
    --                                     var _scale = clamp((j.scale * (k / count)) / 256, (2 * k) / count / 256, 1);
    --                                     draw_sprite_ext(spr_circle_256_aa, 0, _x, _y, _scale, _scale, 0, j.col, 1);
    --                                     spritecount++;
    --                                 }
    --                             }
    --                         }
                            
    --                         if (dokill)
    --                             instance_destroy();
    --                     };
    --                 }
                    
    --                 instance_destroy();
    --             }
    --         };
    --     }
        
    --     instance_destroy();
    -- }
end

function FallingPeach:draw()
    super.draw(self)
    if DEBUG_RENDER then
        love.graphics.print(tostring(self.physics.speed_y), 0, -10)
    end
end

return FallingPeach
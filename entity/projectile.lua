local Class = require("lib.hump.class")
local Entity = require("entity.entity")
local Timer = require("lib.hump.timer")

local Projectile = Class{
    sprites = {
        -- State 1: Moving
        {
            love.graphics.newImage("/img/game/entity/shot/shot-1.png"),
            love.graphics.newImage("/img/game/entity/shot/shot-2.png"),
            love.graphics.newImage("/img/game/entity/shot/shot-3.png")
        },
        -- State 2: Hit
        {
            love.graphics.newImage("/img/game/entity/shot-hit/shot-hit-1.png"),
            love.graphics.newImage("/img/game/entity/shot-hit/shot-hit-2.png"),
            love.graphics.newImage("/img/game/entity/shot-hit/shot-hit-3.png")
        }
    }
}
Projectile:include(Entity)

function Projectile:init(x, y, v, a)
    self.x = x
    self.y = y - self.sprites[1][1]:getWidth() / 3
    self.x0 = self.x
    self.y0 = self.y
    self.a = math.rad(a)
    self.t = 0
    self.g = 9.8
    self.v = v
    self.vx = v * math.cos(self.a)
    self.vy0 = v * math.sin(self.a) - self.g * self.t
    self.vy = self.vy0
    self.state = 0
    self.iterator = 1
end

function Projectile:update(dt)
    if self.state == 0 then
        return
    end
    
    Timer.update(dt)
    
    self.iterator = self.iterator + dt * 10
    if math.floor(self.iterator) > #self.sprites[self.state] then
        if self.state == 2 then
            self.state = 0
        else
            self.iterator = 1
        end
    end
    
    if self.state == 2 then
        return
    end
    
    self.t = self.t + dt
    self.vy = self.v * math.sin(self.a) - self.g * self.t
    self.x = self.vx * self.t + self.x0
    self.y = 0.5 * self.g * self.t ^ 2  - self.vy0 * self.t + self.y0
    
    local windowFlags = select(3, love.window.getMode())
    local w = windowFlags.minwidth
    local h = windowFlags.minheight
    
    if self.x > w or self.y > h then
        self.state = 0
    end
end

function Projectile:draw()
    if self.state == 0 then
        return
    end

    love.graphics.draw(self.sprites[self.state][math.floor(self.iterator)], self.x, self.y, -self.a)
end

function Projectile:explode()
    self.iterator = 1
    self.state = 2
end

return Projectile

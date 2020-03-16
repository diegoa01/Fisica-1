local Class = require("lib.hump.class")
local Entity = require("entity.entity")

local Drone = Class{
    sprites = {
        -- State 1: Moving
        {
            love.graphics.newImage("/img/game/entity/drone/drone-1.png"),
            love.graphics.newImage("/img/game/entity/drone/drone-2.png"),
            love.graphics.newImage("/img/game/entity/drone/drone-3.png"),
            love.graphics.newImage("/img/game/entity/drone/drone-4.png"),
            love.graphics.newImage("/img/game/entity/drone/drone-3.png"),
            love.graphics.newImage("/img/game/entity/drone/drone-2.png")
        },
        -- State 2: Exploding
        {
            love.graphics.newImage("/img/game/entity/enemy-explosion/enemy-explosion-1.png"),
            love.graphics.newImage("/img/game/entity/enemy-explosion/enemy-explosion-2.png"),
            love.graphics.newImage("/img/game/entity/enemy-explosion/enemy-explosion-3.png"),
            love.graphics.newImage("/img/game/entity/enemy-explosion/enemy-explosion-4.png"),
            love.graphics.newImage("/img/game/entity/enemy-explosion/enemy-explosion-5.png"),
            love.graphics.newImage("/img/game/entity/enemy-explosion/enemy-explosion-6.png")
        }
    }
}
Drone:include(Entity)

function Drone:init(x, y)
    self.xmax = x
    self.ymax = y
    self.offset = 0
    self.offsetmax = 1
    self.offsetsign = 1
    self.state = 0
    self.iterator = 1
    
    self:respawn()
end

function Drone:update(dt)
    if self.state == 0 then
        return
    end
    
    if self.state == 2 then
        self.iterator = self.iterator + dt * 5
    else
        self.iterator = self.iterator + dt
    end
    
    if math.floor(self.iterator) > #self.sprites[self.state] then
        if self.state == 2 then
            self.state = 0
        else
            self.iterator = 1
        end
    end
    
    self.offset = self.offset + dt * self.offsetsign

    if self.offset > self.offsetmax or self.offset < -self.offsetmax then
        self.offset = self.offsetmax * self.offsetsign
        self.offsetsign = -self.offsetsign
    end
end

function Drone:draw()
    if self.state == 0 then
        return
    end
    
    love.graphics.draw(self.sprites[self.state][math.floor(self.iterator)], self.x, self.y + self.offset)
end

function Drone:respawn()
    local windowFlags = select(3, love.window.getMode())
    local w = windowFlags.minwidth
    local h = windowFlags.minheight
    
    self.x = math.random(w / 2, w - self.sprites[1][1]:getWidth())
    self.y = math.random(0, h - self.sprites[1][1]:getHeight())
    
    self.state = 1
end

function Drone:explode()
    self.iterator = 1
    self.state = 2
end

return Drone

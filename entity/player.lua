local Class = require("lib.hump.class")
local Entity = require("entity.entity")
local Timer = require("lib.hump.timer")
local Projectile = require("entity.projectile")

local Player = Class{
    SFX = {
        beam = love.audio.newSource("/audio/sounds/beam.ogg", "static")
    },
    sprites = {
        -- State 1: Idle
        {
            love.graphics.newImage("/img/game/entity/player/idle/idle-1.png"),
            love.graphics.newImage("/img/game/entity/player/idle/idle-2.png"),
            love.graphics.newImage("/img/game/entity/player/idle/idle-3.png"),
            love.graphics.newImage("/img/game/entity/player/idle/idle-4.png")
        },
        -- State 2: Run
        {
            love.graphics.newImage("/img/game/entity/player/run/run-1.png"),
            love.graphics.newImage("/img/game/entity/player/run/run-2.png"),
            love.graphics.newImage("/img/game/entity/player/run/run-3.png"),
            love.graphics.newImage("/img/game/entity/player/run/run-4.png"),
            love.graphics.newImage("/img/game/entity/player/run/run-5.png"),
            love.graphics.newImage("/img/game/entity/player/run/run-6.png"),
            love.graphics.newImage("/img/game/entity/player/run/run-7.png"),
            love.graphics.newImage("/img/game/entity/player/run/run-8.png")
        },
        -- State 3: Shoot
        {
            love.graphics.newImage("/img/game/entity/player/shoot/shoot.png")
        }
    }
}
Player:include(Entity)

function Player:init(x, y)
    self.x = x
    self.y = y
    self.angle = 0
    self.power = 1
    self.powerMult = 100
    self.state = 1
    self.iterator = 1
    self.arrowDraw = false
    self.arrowLength = 25
    self.recharging = false
    self.projectile = Projectile(0, 0, 0, 0)
end

function Player:keypressed(key)
    if key == "space" then
        if self.projectile.state == 0 then
            self.state = 3
        end
    end
end

function Player:keyreleased(key)
    if key == "space" then
        if self.projectile.state ~= 0 then
            self.power = 1
            return
        end
        
        if self.arrowTimer then
            Timer.cancel(self.arrowTimer)
            self:disableArrow()
        end
        
        self.projectile:init(self.x + 56, self.y + 25, self.power, self.angle)
        self.projectile.state = 1
        self.state = 1
        self.power = 1
        self.SFX.beam:setPitch(1)
        self.SFX.beam:play()
    elseif key == "up" or key == "down" then
        if self.arrowTimer then
            Timer.cancel(self.arrowTimer)
        end
        self.arrowTimer = Timer.after(5, function() self:disableArrow() end)
    end
end

function Player:update(dt)
    self:updateAngle(dt)
    self.projectile:update(dt)
    self.iterator = self.iterator + dt * 5 * self.state
    
    if math.floor(self.iterator) > #self.sprites[self.state] then
        self.iterator = 1
    end
end

function Player:updateAngle(dt)
    if self.state == 2 then
        return
    end
    
    if love.keyboard.isDown("space") then
        if self.power >= 100 or self.power <= 0 then
            self.powerMult = -self.powerMult
        end
        
        self.power = self.power + dt * self.powerMult
    end
    
    local mod = 25
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        mod = 50
    elseif love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
        mod = 1
    end
        
    if love.keyboard.isDown("up") then
        self.angle = self.angle + dt * mod
    elseif love.keyboard.isDown("down") then
        self.angle = self.angle - dt * mod
    else
        return
    end
    
    self.arrowDraw = true

    if self.angle < 0 then
        self.angle = 0
    elseif self.angle > 90 then
        self.angle = 90
    end

end

function Player:draw()
    love.graphics.draw(self.sprites[self.state][math.floor(self.iterator)], self.x, self.y)
    
    self.projectile:draw()
    
    if self.arrowDraw then
        self:drawArrow()
    end
    
    if love.keyboard.isDown("space") and self.state ~= 2 and self.projectile.state == 0 then
        love.graphics.setColor(0, 0.25, 1)
        love.graphics.rectangle("fill", self.x + 60, self.y + 55, 5, -25)
        love.graphics.setColor(0, 1, 1)
        love.graphics.rectangle("fill", self.x + 60, self.y + 55, 5, -25 * (self.power/100))
        love.graphics.setColor(1, 1, 1)
    end
end

function Player:drawArrow()
    local angle = math.rad(self.angle)
    local x1 = self.x + 56
    local y1 = self.y + 25
    local x2 = x1 + (math.cos(angle) * self.arrowLength)
    local y2 = y1 - (math.sin(angle) * self.arrowLength)
    
    local arrowHeadLength = 5
    local arrowHeadAngle = 120
    local a = math.atan2(y1 - y2, x1 - x2)
    
    love.graphics.setColor(1, 0, 0.6)
    love.graphics.line(x1, y1, x2, y2)
	love.graphics.line(x2, y2, x2 + arrowHeadLength * math.cos(a + arrowHeadAngle), y2 + arrowHeadLength * math.sin(a + arrowHeadAngle))
	love.graphics.line(x2, y2, x2 + arrowHeadLength * math.cos(a - arrowHeadAngle), y2 + arrowHeadLength * math.sin(a - arrowHeadAngle))
    love.graphics.setColor(1, 1, 1)
end

function Player:toggleArrow()
    self.arrowDraw = not self.arrowDraw
end

function Player:enableArrow()
    self.arrowDraw = true
end

function Player:disableArrow()
    self.arrowDraw = false
end

return Player

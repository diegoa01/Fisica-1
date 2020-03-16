local Camera = require("lib.hump.camera")
local Drone = require("entity.drone")
local GameState = require("lib.hump.gamestate")
local Suit = require("lib.suit")
local Timer = require("lib.hump.timer")
local Player = require("entity.player")

local Game = {
    explosionSFX = love.audio.newSource("/audio/sounds/explosion.ogg", "static"),
    
    bgFar = love.graphics.newImage("/img/game/background/skyline.png"),
    bgMiddle = love.graphics.newImage("/img/game/background/buildings-bg.png"),
    bgNear = love.graphics.newImage("/img/game/background/near-buildings-bg.png")
}

function Game:init()
    self.bgFarX1 = 0
    self.bgFarX2 = self.bgFar:getWidth()
    
    self.bgMiddleX1 = 0
    self.bgMiddleX2 = self.bgMiddle:getWidth()
    
    self.bgNearX1 = 0
    self.bgNearX2 = self.bgNear:getWidth()
    
    self.moving = false
    
    self.player = Player(0, 245)
    
    local windowFlags = select(3, love.window.getMode())
    
    self.drone = Drone(windowFlags.minwidth,  windowFlags.minheight)
    
    self.camera = Camera(0, 0)
    self:resize(love.graphics.getWidth(), love.graphics.getHeight(), true)
end

function Game:enter(previous, settings)
    self.gameStatePrevious = previous
    self.gameStateSettings = settings or self.gameStateSettings
    self:resize(love.graphics.getWidth(), love.graphics.getHeight(), true)
end

function Game:keypressed(key)
    if key == "escape" then
        GameState.push(self.gameStateSettings, self.gameStatePrevious)
    end
    
    if not self.moving then
        self.player:keypressed(key)
    end
end

function Game:keyreleased(key)
    if not self.moving then
        self.player:keyreleased(key)
    end
end

function Game:update(dt)
    Suit.updateMouse(self.camera:mousePosition())
    Timer.update(dt)
    self:updateBackgroundPos(dt)
    self.drone:update(dt)    
    self.player:update(dt)
    self:checkCollision(self.player.projectile, self.drone)
end

function Game:draw()
    self.camera:attach()
    self:drawBackgroundNoCam()
    self.drone:draw()
    self.player:draw()
    self.camera:detach()
    Suit.draw()
end

function Game:updateBackgroundPos(dt)
    if self.moving and (GameState.current() == self) then
        dt = dt * 2
        self.bgFarX1 = self.bgFarX1 - dt
        self.bgFarX2 = self.bgFarX2 - dt
        
        dt = dt * 3
        self.bgMiddleX1 = self.bgMiddleX1 - dt
        self.bgMiddleX2 = self.bgMiddleX2 - dt
        
        dt = dt * 6
        self.bgNearX1 = self.bgNearX1 - dt
        self.bgNearX2 = self.bgNearX2 - dt
        
        if self.drone.state == 2 then
            self.drone.x = self.drone.x - dt * 3
            self.drone.y = self.drone.y + dt / 2
        end
        
        local imgWidth = self.bgFar:getWidth() * -1
        if self.bgFarX1 <= imgWidth then
            self.bgFarX1 = self.bgFarX2 + self.bgFar:getWidth()
        elseif self.bgFarX2 <= imgWidth then
            self.bgFarX2 = self.bgFarX1 + self.bgFar:getWidth()
        end

        imgWidth = self.bgMiddle:getWidth() * -1
        if self.bgMiddleX1 <= imgWidth then
            self.bgMiddleX1 = self.bgMiddleX2 + self.bgMiddle:getWidth()
        elseif self.bgMiddleX2 <= imgWidth then
            self.bgMiddleX2 = self.bgMiddleX1 + self.bgMiddle:getWidth()
        end
        
        imgWidth = self.bgNear:getWidth() * -1
        if self.bgNearX1 <= imgWidth then
            self.bgNearX1 = self.bgNearX2 + self.bgNear:getWidth()
        elseif self.bgNearX2 <= imgWidth then
            self.bgNearX2 = self.bgNearX1 + self.bgNear:getWidth()
        end
    else
        self.bgFarX1 = self.bgFarX1 - dt
        self.bgFarX2 = self.bgFarX2 - dt
        
        local imgWidth = self.bgFar:getWidth() * -1
        if self.bgFarX1 <= imgWidth then
            self.bgFarX1 = self.bgFarX2 + self.bgFar:getWidth()
        elseif self.bgFarX2 <= imgWidth then
            self.bgFarX2 = self.bgFarX1 + self.bgFar:getWidth()
        end
    end
end

function Game:drawBackground()
    self.camera:attach()
    self:drawBackgroundNoCam()
    self.camera:detach()
end

function Game:drawBackgroundNoCam()
    love.graphics.draw(self.bgFar, self.bgFarX1)
    love.graphics.draw(self.bgFar, self.bgFarX2)
    
    love.graphics.draw(self.bgMiddle, self.bgMiddleX1)
    love.graphics.draw(self.bgMiddle, self.bgMiddleX2)
    
    love.graphics.draw(self.bgNear, self.bgNearX1)
    love.graphics.draw(self.bgNear, self.bgNearX2)
end

function Game:resize(w, h, ignoreResize)
    local windowFlags = select(3, love.window.getMode())
    
    local sf = h / windowFlags.minheight
    w = windowFlags.minwidth / windowFlags.minheight * h

    self.camera:lookAt(w / (2 * sf), h / (2 * sf))
    self.camera:zoomTo(sf)
    
    if not ignoreResize then
        love.window.setMode(w, h, windowFlags)
    end
end

function Game:checkCollision(projectile, drone)
    if projectile.state == 1 and drone.state == 1 then
        local projectileWidth = projectile.sprites[1][1]:getWidth()
        local projectileHeight = projectile.sprites[1][1]:getHeight()
        --local droneWidth = drone.sprites[1][1]:getWidth()
        local droneHeight = drone.sprites[1][1]:getHeight()
        
        local px1 = projectile.x - (projectileWidth / 2)
        local py1 = projectile.y + (projectileHeight / 2)
        local px2 = projectileWidth
        local py2 = projectileHeight / 2

        local dx1 = drone.x + 15 -- Sprite offset
        local dy1 = drone.y + 19 -- Sprite offset
        local dx2 = 22 -- Drone Hitbox Width
        local dy2 = 24 -- Drone Hitbox Height

        if (px1 < dx1 + dx2) and (dx1 < px1 + px2) and (py1 < dy1 + dy2) and (dy1 < py1 + py2) then
            self.player.projectile:explode()
            drone:explode()
            self.explosionSFX:play()
            local delay = math.random(1, 2)
            local delay2 = 1 + delay + math.random(3, 5)
            Timer.after(delay, function() self:moveToNextDrone() end)
            Timer.after(delay2, function() self:spawnNextDrone() end)
            return true
        end
    end
    
    return false
end

function Game:moveToNextDrone()
    self.moving = true
    self.player.state = 2
end

function Game:spawnNextDrone()
    self.moving = false
    self.player.state = 1
    self.drone:respawn()
    self.player.SFX.beam:setPitch(0.1)
    self.player.SFX.beam:play()
end

return Game

local Camera = require("lib.hump.camera")
local GameState = require("lib.hump.gamestate")
local Suit = require("lib.suit")

local Game = require("gamestate.game")

local MainMenu = {}

function MainMenu:init()
    self.bgFar = love.graphics.newImage("/img/mainmenu/far-buildings.png")
    self.bgMiddle = love.graphics.newImage("/img/mainmenu/back-buildings.png")
    self.bgNear = love.graphics.newImage("/img/mainmenu/foreground.png")
    self.title = love.graphics.newImage("/img/mainmenu/title.png")

    self.bgFarX1 = 0
    self.bgFarX2 = self.bgFar:getWidth()
    
    self.bgMiddleX1 = 0
    self.bgMiddleX2 = self.bgMiddle:getWidth()
    
    self.bgNearX1 = 0
    self.bgNearX2 = self.bgNear:getWidth()
    
    local winWidth = love.graphics.getWidth()
    local winHeight = love.graphics.getHeight()
    local windowFlags = select(3, love.window.getMode())
    local sf = winHeight / self.bgNear:getHeight()
    
    self.titleX = winWidth / sf / 2 - self.title:getWidth() / 2
    self.titleY = windowFlags.minheight * 0.025
    
    self.buttonW = 250
    self.buttonH = 50
    self.menuX = winWidth / 2 - self.buttonW / 2
    self.menuY = winHeight - winHeight / 3
    
    self.buttonNewGameText = "New Game"
    self.buttonSettingsText = "Settings"
    self.buttonSettingsExit = "Exit"
    
    local buttonFont = love.graphics.newFont("/font/Cyberjunkies.ttf", 30)
    
    self.camera = Camera(0, 0)
    --self:resize(love.graphics.getWidth(), love.graphics.getHeight(), true)
    
    self.buttonNewGameTheme = {
        color = {
            normal = { bg = { 0.4, 0, 0.8 }, fg = { 1, 1, 1 } },
            hovered = { bg = { 0.7, 0, 1 }, fg = { 1, 1, 1 } },
            active = { bg = { 1, 0, 0.7 }, fg = { 1, 1, 1 } }
        },
        font = buttonFont
    }
    self.buttonSettingsTheme = {
        color = {
            normal = { bg = { 0.4, 0, 0.8 }, fg = { 1, 1, 1 } },
            hovered = { bg = { 0.7, 0, 1 }, fg = { 1, 1, 1 } },
            active = { bg = { 1, 0, 0.7 }, fg = { 1, 1, 1 } }
        },
        font = buttonFont
    }
    self.buttonExitTheme = {
        color = {
            normal = { bg = { 0.4, 0, 0.8 }, fg = { 1, 1, 1 } },
            hovered = { bg = { 0.7, 0, 1 }, fg = { 1, 1, 1 } },
            active = { bg = { 1, 0, 0.7 }, fg = { 1, 1, 1 } }
        },
        font = buttonFont
    }
end

function MainMenu:enter(previous, settings)
    self.gameStatePrevious = previous
    self.gameStateSettings = settings or self.gameStateSettings
    self:resize(love.graphics.getWidth(), love.graphics.getHeight(), true)
end

function MainMenu:update(dt)
    Suit.layout:reset(self.menuX, self.menuY)
    Suit.layout:padding(20)
    
    if Suit.Button(self.buttonNewGameText, self.buttonNewGameTheme, Suit.layout:row(self.buttonW, self.buttonH)).hit then
        GameState.switch(Game, self.gameStateSettings)
    end
    if Suit.Button(self.buttonSettingsText, self.buttonSettingsTheme, Suit.layout:row()).hit then
        GameState.push(self.gameStateSettings)
    end
    if Suit.Button(self.buttonSettingsExit, self.buttonExitTheme, Suit.layout:row()).hit then
        love.event.quit()
    end
    
    self:updateBackgroundPos(dt)
end

function MainMenu:draw()
    self.camera:attach()
    self:drawBackgroundNoCam()
    love.graphics.draw(self.title, self.titleX, self.titleY)
    self.camera:detach()
    Suit.draw()
end

function MainMenu:updateBackgroundPos(dt)
    self.bgFarX1 = self.bgFarX1 - dt
    self.bgFarX2 = self.bgFarX2 - dt
    
    dt = dt * 3
    self.bgMiddleX1 = self.bgMiddleX1 - dt
    self.bgMiddleX2 = self.bgMiddleX2 - dt
    
    dt = dt * 3
    self.bgNearX1 = self.bgNearX1 - dt
    self.bgNearX2 = self.bgNearX2 - dt
    
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
end

function MainMenu:drawBackground()
    self.camera:attach()
    self:drawBackgroundNoCam()
    self.camera:detach()
end

function MainMenu:drawBackgroundNoCam()
    love.graphics.draw(self.bgFar, self.bgFarX1)
    love.graphics.draw(self.bgFar, self.bgFarX2)
    love.graphics.draw(self.bgMiddle, self.bgMiddleX1)
    love.graphics.draw(self.bgMiddle, self.bgMiddleX2)
    love.graphics.draw(self.bgNear, self.bgNearX1)
    love.graphics.draw(self.bgNear, self.bgNearX2)
end

function MainMenu:resize(w, h, ignoreResize)
    local windowFlags = select(3, love.window.getMode())
    
    local sf = h / self.bgNear:getHeight()
    w = windowFlags.minwidth / windowFlags.minheight * h

    self.camera:lookAt(w / (2 * sf), h / (2 * sf))
    self.camera:zoomTo(sf)
    
    self.menuX = w / 2 - self.buttonW / 2
    
    local height = h / 3
    local minHeight = self.buttonH * 3 + 60
    if (height < minHeight) then
        self.menuY = h - minHeight
    else
        self.menuY = h - height
    end
    
    if not ignoreResize then
        love.window.setMode(w, h, windowFlags)
    end
end

return MainMenu

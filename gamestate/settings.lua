local Camera = require("lib.hump.camera")
local GameState = require("lib.hump.gamestate")
local Suit = require("lib.suit")

local Settings = {}

function Settings:init()
    self.labelSettings = "Settings"
    self.labelMasterVolume = "Master Volume"
    self.labelSFXVolume = "SFX Volume"
    self.labelMusicVolume = "Music Volume"
    
    self.volumeMaster = { value = 0.5 }
    self.volumeSFX = { value = 0.5 }
    self.volumeMusic = { value = 0.5 }
    
    local winWidth = love.graphics.getWidth()
    local winHeight = love.graphics.getHeight()
    
    self.buttonW = 250
    self.buttonH = 50
    self.menuX = winWidth / 2 - self.buttonW / 2
    self.menuY = winHeight / 4
    self.minHeight = 500
    
    self.font = love.graphics.newFont("/font/Cyberjunkies.ttf", 30)
    
    self.labelSettingsOptions = { 
        font = self.font,
        color = {
            normal = {
                bg = { 1, 1, 1 },
                fg = { 1, 1, 1 } 
            } 
        } 
    }
    self.labelMasterVolumeOptions = { 
        font = self.font,
        color = {
            normal = {
                bg = { 1, 1, 1 },
                fg = { 1, 1, 1 } 
            } 
        } 
    }
    self.labelSFXVolumeOptions = { 
        font = self.font,
        color = {
            normal = {
                bg = { 1, 1, 1 },
                fg = { 1, 1, 1 } 
            } 
        } 
    }
    self.labelMusicVolumeOptions = { 
        font = self.font,
        color = {
            normal = {
                bg = { 1, 1, 1 },
                fg = { 1, 1, 1 } 
            } 
        } 
    }

    self.volumeMasterTheme = {
        color = {
            normal = { bg = { 0.5, 0.5, 0.5 }, fg = { 0.4, 0, 0.8 } },
            hovered = { bg = { 0.6, 0.6, 0.6 }, fg = { 0.7, 0, 1 } },
            active = { bg = { 0.7, 0.7, 0.7 }, fg = { 1, 0, 0.7 } }
        }
    }
    self.volumeSFXTheme = {
        color = {
            normal = { bg = { 0.5, 0.5, 0.5 }, fg = { 0.4, 0, 0.8 } },
            hovered = { bg = { 0.6, 0.6, 0.6 }, fg = { 0.7, 0, 1 } },
            active = { bg = { 0.7, 0.7, 0.7 }, fg = { 1, 0, 0.7 } }
        }
    }
    self.volumeMusicTheme = {
        color = {
            normal = { bg = { 0.5, 0.5, 0.5 }, fg = { 0.4, 0, 0.8 } },
            hovered = { bg = { 0.6, 0.6, 0.6 }, fg = { 0.7, 0, 1 } },
            active = { bg = { 0.7, 0.7, 0.7 }, fg = { 1, 0, 0.7 } }
        }
    }
    
    self.buttonThemeMainMenu = {
        color = {
            normal = { bg = { 0.4, 0, 0.8 }, fg = { 1, 1, 1 } },
            hovered = { bg = { 0.7, 0, 1 }, fg = { 1, 1, 1 } },
            active = { bg = { 1, 0, 0.7 }, fg = { 1, 1, 1 } }
        },
        font = self.font
    }
    self.buttonThemeClose = {
        color = {
            normal = { bg = { 0.4, 0, 0.8 }, fg = { 1, 1, 1 } },
            hovered = { bg = { 0.7, 0, 1 }, fg = { 1, 1, 1 } },
            active = { bg = { 1, 0, 0.7 }, fg = { 1, 1, 1 } }
        },
        font = self.font
    }
end

function Settings:enter(previous, mainMenu)
    self.gameStatePrevious = previous
    self.gameStateMainMenu = mainMenu or self.gameStateMainMenu
    self:resize(love.graphics.getWidth(), love.graphics.getHeight(), true)
end

function Settings:keypressed(key)
    if key == "escape" then
        GameState.pop()
    end
end

function Settings:update(dt)
    Suit.layout:reset(self.menuX, self.menuY)
    
    Suit.Label(self.labelSettings, self.labelSettingsOptions, Suit.layout:row(self.buttonW, self.buttonH))
    Suit.layout:padding(5)
    
    Suit.Label(self.labelMasterVolume, self.labelMasterVolumeOptions, Suit.layout:row())
    Suit.layout:padding(-3)
    
    if Suit.Slider(self.volumeMaster, self.volumeMasterTheme, Suit.layout:row()).changed then
        love.audio.setVolume(self.volumeMaster.value)
    end
    
    if self.gameStatePrevious.explosionSFX then
        Suit.Label(self.labelSFXVolume, self.labelSFXVolumeOptions, Suit.layout:row())
        if Suit.Slider(self.volumeSFX, self.volumeSFXTheme, Suit.layout:row()).changed then
            
            self.gameStatePrevious.player.SFX.beam:setVolume(self.volumeSFX.value)
            self.gameStatePrevious.explosionSFX:setVolume(self.volumeSFX.value)
            
        end
    end
    
    Suit.Label(self.labelMusicVolume, self.labelMusicVolumeOptions, Suit.layout:row())
    if Suit.Slider(self.volumeMusic, self.volumeMusicTheme, Suit.layout:row()).changed then
        self.musicBackground:setVolume(self.volumeMusic.value)
    end
    Suit.layout:padding(30)
    
    if self.gameStateMainMenu and Suit.Button("Main Menu", self.buttonThemeMainMenu, Suit.layout:row()).hit then
        GameState.pop()
        GameState.switch(self.gameStateMainMenu)
    end
    Suit.layout:padding(20)
    
    if Suit.Button("Close", self.buttonThemeClose, Suit.layout:row()).hit then
        GameState.pop()
    end
    
    self.gameStatePrevious:updateBackgroundPos(dt)
end

function Settings:draw()
    self.gameStatePrevious:drawBackground()
    Suit.draw()
end

function Settings:resize(w, h, ignoreResize)
    local windowFlags = select(3, love.window.getMode())
    
    local sf = h / windowFlags.minheight
    w = windowFlags.minwidth / windowFlags.minheight * h
    
    self.menuX = w / 2 - self.buttonW / 2
    
    self.menuY = (h - self.minHeight) / 2

    self.gameStatePrevious:resize(w, h, true)

    if not ignoreResize then
        love.window.setMode(w, h, windowFlags)
    end
end

return Settings

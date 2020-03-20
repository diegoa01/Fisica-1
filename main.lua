local GameState = require("lib.hump.gamestate")
local MainMenu = require("gamestate.mainmenu")
local Settings = require("gamestate.settings")

function love.load(arg)
    math.randomseed(os.time())
    
    love.window.setMode(1036, 648, { resizable = true, minwidth = 518, minheight = 324 })
    love.window.setIcon(love.image.newImageData("/img/icon.png"))
    love.window.setTitle("Fisica 1 - Proyecto")
    love.graphics.setDefaultFilter("nearest", "nearest")

    Settings.musicBackground = love.audio.newSource("/audio/music/sci_fi_platformer02.ogg", "stream")
    Settings.musicBackground:setLooping(true)
    love.audio.play(Settings.musicBackground)
    love.audio.setVolume(0.5)

    GameState.registerEvents()
    GameState.switch(MainMenu, Settings)
end

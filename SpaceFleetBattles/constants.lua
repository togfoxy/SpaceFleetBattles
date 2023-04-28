constants = {}

function constants.load()

    GAME_VERSION = "1.0"

    SCREEN_STACK = {}

    -- SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getDesktopDimensions(1)
    SCREEN_WIDTH, SCREEN_HEIGHT = res.getGame()

    -- camera
    ZOOMFACTOR = 0.7
    -- ZOOMFACTOR = 1
    TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels

    cam = nil       -- camera
    AUDIO = {}
    MUSIC_TOGGLE = true     --! will need to build these features later
    SOUND_TOGGLE = true

    IMAGE = {}
    FONT = {}

    -- set the folders based on fused or not fused
    savedir = love.filesystem.getSourceBaseDirectory()
    if love.filesystem.isFused() then
        savedir = savedir .. "\\savedata\\"
    else
        savedir = savedir .. "/FormulaSpeed/savedata/"
    end

    enums.load()
    -- add extra items below this line

    BOX2D_SCALE = 2
    PHYS_OBJECTS = {}       -- table of box2d
    OBJECTS = {}            -- table of items
    NUM_OF_OBJECTS = 10

end

return constants

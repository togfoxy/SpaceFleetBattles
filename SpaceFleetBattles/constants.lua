constants = {}

function constants.load()

    GAME_VERSION = "0.01"

    SCREEN_STACK = {}

    SCREEN_WIDTH, SCREEN_HEIGHT = res.getGame()

    -- camera
    ZOOMFACTOR = 1.3
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
        savedir = savedir .. "/SpaceFleetBattles/savedata/"
    end

    enums.load()
    -- add extra items below this line ======================================================

    NUM_OF_OBJECTS = 10
    FRIEND_START_X = 0      -- left side of screen
    FOE_START_X = SCREEN_WIDTH * 2
    PHYS_OBJECTS = {}       -- table of box2d
    OBJECTS = {}            -- table of items
    SOUNDS = {}             -- sound effects

    PLAYER_GUID = nil

    -- animate stuff. --! check if all are necessary
    QUADS = {}		-- quads for animations
    GRIDS = {}		-- grids are used to load quads for anim8
    FRAMES = {}		-- frames within the grid. Used by anim8
    ANIMATIONS = {}	-- holds all anim8 animations



end

return constants

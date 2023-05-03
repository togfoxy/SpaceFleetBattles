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

    FRIEND_START_X = 0      -- left side of screen
    FOE_START_X = SCREEN_WIDTH * 2

    FRIEND_SHIP_COUNT = 24
    FRIEND_PILOT_COUNT = 24
    SHIPS_PER_SQUADRON = 6

    OBJECTS = {}            -- table of items
    SQUADS = {}             -- a list of squad guids
    SQUAD_LIST = {}         -- a list of callsigns and their forf
    squadAI = {}
    SOUNDS = {}             -- sound effects
    SCORE = {}              -- track casulties in this table
    SCORE.friendsdead = 0       -- put here for documentation and to help me remember
    SCORE.enemiesdead = 0

    PLAYER_GUID = nil

    -- animate stuff. --! check if all are necessary
    QUADS = {}		-- quads for animations
    GRIDS = {}		-- grids are used to load quads for anim8
    FRAMES = {}		-- frames within the grid. Used by anim8
    ANIMATIONS = {}	-- holds all anim8 animations



end

return constants

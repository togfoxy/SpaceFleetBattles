constants = {}

function constants.load()

    GAME_VERSION = "0.01"

    SCREEN_STACK = {}

    SCREEN_WIDTH, SCREEN_HEIGHT = res.getGame()

    -- camera
    ZOOMFACTOR = 1.3
    TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels

    cam = nil       -- camera
    AUDIO = {}
    MUSIC_TOGGLE = true     -- will need to build these features later
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

    FRIEND_START_X = 0      			-- left side of screen
    FOE_START_X = SCREEN_WIDTH * 2		-- right side of screen

    FRIEND_FIGHTER_COUNT = 12 - 3		-- used to initalise the hanger. The -6 is to offset the homeworld +6
    FRIEND_PILOT_COUNT = 12 - 3		-- used to initialise the hanger. The -6 is to offset the homeworld +6

	FOE_FIGHTER_COUNT = 12			-- these aren't really constants
	FOE_PILOT_COUNT = 12			-- these aren't really constants

	FRIEND_SQUADRON_COUNT = 2		-- not a constant and changes for each battle. NOTE: the callsigns assume two squadrons.  --! need to fix
    FRIEND_SHIPS_PER_SQUADRON = 6							--
    FOE_SQUADRON_COUNT = FRIEND_SQUADRON_COUNT
    FOE_SHIPS_PER_SQUADRON = FRIEND_SHIPS_PER_SQUADRON

    RTB_TIMER = 0
    RTB_TIMER_LIMIT = 60 * 4        -- commander will RTB after this time limit
    BATTLE_TIMER = 0
    BATTLE_TIMER_LIMIT = RTB_TIMER_LIMIT + 45     -- game will assume a stalemate and end at this piont

    OBJECTS = {}            -- table of items
    SQUADS = {}             -- a list of squad guids
    SQUAD_LIST = {}         -- a list of callsigns and their forf
    commanderAI = {}
    squadAI = {}
    SOUNDS = {}             -- sound effects
    SCORE = {}              -- track casulties in this table
	ROSTER = {}
	HANGER = {}
	FLEET = {}					-- tracks the fleet on the planet map
    PLANETS = {}                -- planets on the planet map
    POD_QUEUE = {}              -- a list of pods waiting to spawn. Box2D work around
    FIRSTNAMES = {}
    LASTNAMES = {}
	DAMAGETEXT = {}				-- a list of text that needs to be displayed when components are damaged

    SCORE.friendsdead = 0       -- put here for documentation and to help me remember
	SCORE.friendsEjected = 0
    SCORE.enemiesdead = 0
	SCORE.enemiesEjected = 0
	SCORE.loser = 0				-- which AI index called a retreat first?

    PLAYER_GUID = nil
    PLAYER_FIGHTER_GUID = nil

    QUADS = {}		-- quads for animations
    GRIDS = {}		-- grids are used to load quads for anim8
    FRAMES = {}		-- frames within the grid. Used by anim8
    ANIMATIONS = {}	-- holds all anim8 animations

	battleRosterHasLoaded = false
	fightsceneHasLoaded = false
	endBattleHasLoaded = false


end

return constants

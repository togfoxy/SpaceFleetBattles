GAME_VERSION = "0.01o"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'
-- https://notabug.org/pgimeno/cam11

bitser = require 'lib.bitser'
-- https://github.com/gvx/bitser

nativefs = require 'lib.nativefs'
-- https://github.com/EngineerSmith/nativefs

lovelyToasts = require 'lib.lovelyToasts'
-- https://github.com/Loucee/Lovely-Toasts

anim8 = require 'lib.anim8'
-- https://github.com/kikito/anim8

-- these are core modules
require 'lib.buttons'
require 'enums'
require 'constants'
fun = require 'functions'
cf = require 'lib.commonfunctions'

require 'mainmenu'
require 'planetmap'
require 'battleroster'
require 'fight'
require 'endbattle'
require 'commanderai'
require 'squadai'
require 'unitai'
require 'fighter'

function love.resize(w, h)
	res.resize(w, h)
end

function beginContact(fixtureA, fixtureB, coll)
	-- a and be are fixtures


	local victim = {}			-- this will contain the fighter object that was hit
	local bullet = {}

	local catA = fixtureA:getCategory()
	local catB = fixtureB:getCategory()
	local guidA = fixtureA:getUserData()
	local guidB = fixtureB:getUserData()
	local objA = fun.getObject(guidA)		-- this is different to fixture:getBody( )
	local objB = fun.getObject(guidB)
	--
	-- local bodyA = fixtureA:getBody()
	-- local bodyB = fixtureB:getBody()

	-- print("guids in contact: " .. guidA, guidB)

	assert(guidA ~= nil)
	assert(guidB ~= nil)
	-- assert(objA ~= nil)
	-- assert(objB ~= nil)

	if objA == nil or objB == nil then
		-- not sure how or why. Going to assume a bullet has hit an object that was
		-- destroyed a nano-second earlier
		print(catA, catB)
		print(guidA, guidB)
		print(inspect(objA))
		print(inspect(objB))
		-- error()
	else
		if catA == enum.categoryEnemyBullet or catA == enum.categoryFriendlyBullet then
			-- destroy Obj1 because its a bullet
			victim = objB
			bullet = objA
			objA.lifetime = 0
		end
		if catB == enum.categoryEnemyBullet or catB == enum.categoryFriendlyBullet then
			-- destroy Obj2 because it's a bullet
			victim = objA
			bullet = objB
			objB.lifetime = 0
		end

		if catA == enum.categoryFriendlyFighter or catA == enum.categoryEnemyFighter or catB == enum.categoryFriendlyFighter or catB == enum.categoryEnemyFighter then
			fun.applyDamage(victim, bullet)		-- assumes bullet hit fighter. Send in bullet to check if bullet belongs to player
		end

		-- play sounds if player is hit
		if victim.guid == PLAYER_FIGHTER_GUID then
			cf.playAudio(enum.audioBulletPing, false, true)
		end
	end
end

function endContact(a, b, coll)
end

function love.keypressed( key, scancode, isrepeat )
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneMainMenu then
		mainmenu.keypressed( key, scancode, isrepeat )
	end
end

function love.keyreleased( key, scancode )
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.keyreleased(key, scancode)
	elseif currentscene == enum.sceneMainMenu then
		mainmenu.keyreleased(key, scancode)
	elseif currentscene == enum.scenePlanetMap then
		planetmap.keyreleased(key, scancode)
	end
end

function love.textinput(text)
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneMainMenu then
		mainmenu.textinput(text)
	end
end

function love.wheelmoved(x, y)
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.wheelmoved(x, y)
	elseif currentscene == enum.sceneBattleRoster then
		battleroster.wheelmoved(x, y)
	end
end

function love.mousemoved(x, y, dx, dy, istouch )
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.mousemoved(x, y, dx, dy)
	end
end

function love.mousereleased(x, y, button, isTouch)
	local rx, ry = res.toGame(x,y)
	local currentscene = cf.currentScreenName(SCREEN_STACK)

	if currentscene == enum.sceneFight then
		fight.mousereleased(rx, ry, x, y, button)		-- need to send through the res adjusted x/y and the 'real' x/y
	elseif currentscene == enum.scenePlanetMap then
		planetmap.mousereleased(rx, ry, x, y, button)
	elseif currentscene == enum.sceneBattleRoster then
		battleroster.mousereleased(rx, ry, x, y, button)
	elseif currentscene == enum.sceneMainMenu then
		mainmenu.mousereleased(rx, ry, x, y, button)
	elseif currentscene == enum.sceneEndBattle then
		endbattle.mousereleased(rx, ry, x, y, button)
	end
end

function love.load()

	_ = love.window.setFullscreen( true )
	res.init({width = 1920, height = 1080, mode = 2})

	local _, _, flags = love.window.getMode()
	local width, height = love.window.getDesktopDimensions(flags.display)
	-- local width, height = love.window.getDesktopDimensions(2)
	res.setMode(width, height, {resizable = true})

	constants.load()		-- also loads enums
	fun.loadFonts()
    fun.loadAudio()
	fun.loadImages()

	mainmenu.loadButtons()
	planetmap.loadButtons()
	battleroster.loadButtons()
	endbattle.loadButtons()

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	cam:setZoom(ZOOMFACTOR)
	cam:setPos(TRANSLATEX,	TRANSLATEY)

	love.window.setTitle("Space Fleet Battles " .. GAME_VERSION)

	love.keyboard.setKeyRepeat(true)

	cf.addScreen(enum.sceneMainMenu, SCREEN_STACK)
	-- cf.addScreen(enum.sceneFight, SCREEN_STACK)

	lovelyToasts.canvasSize = {SCREEN_WIDTH, SCREEN_HEIGHT}
	lovelyToasts.options.tapToDismiss = true
	lovelyToasts.options.queueEnabled = true

	---------------
	love.physics.setMeter(30)
	PHYSICSWORLD = love.physics.newWorld(0,0,false)
	PHYSICSWORLD:setCallbacks( beginContact, endContact, preSolve, postSolve )

	-- maybe move this to load image
	GRIDS[enum.gridExplosion] = anim8.newGrid(16, 16, IMAGE[enum.imageExplosion]:getWidth(), IMAGE[enum.imageExplosion]:getHeight())
	GRIDS[enum.gridBulletSmoke] = anim8.newGrid(32, 32, IMAGE[enum.imageBulletSmoke]:getWidth(), IMAGE[enum.imageBulletSmoke]:getHeight())

	FIRSTNAMES = fun.ImportNameFile("interfirstnamesshort.csv")
	LASTNAMES = fun.ImportNameFile("intersurnamesshort.csv")
end

function love.draw()
    res.start()
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.draw()
	elseif currentscene == enum.scenePlanetMap then
		planetmap.draw()
	elseif currentscene == enum.sceneBattleRoster then
		battleroster.draw()
	elseif currentscene == enum.sceneMainMenu then
		mainmenu.draw()
	elseif currentscene == enum.sceneEndBattle then
		endbattle.draw()
	else
		error()
	end
    res.stop()
end

function love.update(dt)
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
        fight.update(dt)
	elseif currentscene == enum.sceneBattleRoster then
		battleroster.update(dt)
	elseif currentscene == enum.sceneEndBattle then
		endbattle.update(dt)
	end

	fun.updateAnimations(dt)

end

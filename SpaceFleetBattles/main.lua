GAME_VERSION = "0.01"

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
	print("Contact category: " .. catA, catB)
	-- get the object that owns the fixture
	local guidA = fixtureA:getUserData()
	local guidB = fixtureB:getUserData()
	local objA = fun.getObject(guidA)		-- this is different Fixture:getBody( )
	local objB = fun.getObject(guidB)
	--
	-- local bodyA = fixtureA:getBody()
	-- local bodyB = fixtureB:getBody()

	print("guids in contact: " .. guidA, guidB)

	assert(guidA ~= nil)
	assert(guidB ~= nil)
	assert(objA ~= nil)
	assert(objB ~= nil)

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

	fun.applyDamage(victim, bullet)		-- assumes bullet hit fighter. Send in bullet to check if bullet belongs to player

	-- play sounds if player is hit  		--! what about explosion if dead?
	if victim.guid == PLAYER_GUID then
		cf.playAudio(enum.audioBulletPing, false, true)
	end
end

function endContact(a, b, coll)
end

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.removeScreen(SCREEN_STACK)
	end

	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.keyreleased(key, scancode)
	end
end

function love.wheelmoved(x, y)
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.wheelmoved(x, y)
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
	elseif currentscene == enum.sceneBattleRoster then
		battleroster.mousereleased(rx, ry, x, y, button)
	elseif currentscene == enum.sceneMainMenu then
		mainmenu.mousereleased(rx, ry, x, y, button)
	end
end

function love.load()

	res.init({width = 1920, height = 1080, mode = 2})

	local _, _, flags = love.window.getMode()
	local width, height = love.window.getDesktopDimensions(flags.display)
	-- local width, height = love.window.getDesktopDimensions(1)
	res.setMode(width, height, {resizable = true})

	constants.load()		-- also loads enums
	fun.loadFonts()
    fun.loadAudio()
	fun.loadImages()

	mainmenu.loadButtons()
	battleroster.loadButtons()
	endbattle.loadButtons()

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	cam:setZoom(ZOOMFACTOR)
	cam:setPos(TRANSLATEX,	TRANSLATEY)

	love.window.setTitle("Dogfight 2 " .. GAME_VERSION)

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

	GRIDS[enum.gridExplosion] = anim8.newGrid(16, 16, IMAGE[enum.imageExplosion]:getWidth(), IMAGE[enum.imageExplosion]:getHeight())
end

function love.draw()
    res.start()
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.draw()
	elseif currentscene == enum.sceneBattleRoster then
		battleroster.draw()
	elseif currentscene == enum.sceneMainMenu then
		mainmenu.draw()
	elseif currentscene == enum.sceneEndBattle then
		endbattle.draw()
	else
		error()
	end

	-- draw animations
	love.graphics.setColor(1,1,1,1)
	local scale = love.physics.getMeter( )
	for _, animation in pairs(ANIMATIONS) do
		local drawx, drawy = cam:toScreen(animation.drawx, animation.drawy)
		if animation.type == enum.animExplosion then
			animation:draw(IMAGE[enum.imageExplosion], drawx, drawy, animation.angle, 1, 1, 0, 0)
		elseif animation.type == enum.animSmoke then
			-- different offset
			animation:draw(IMAGE[enum.imageExplosion], drawx, drawy, animation.angle, 1, 1, 10, 0)
		end
	end

    res.stop()
end


function love.update(dt)
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
        fight.update(dt)
	end

	fun.updateAnimations(dt)

end

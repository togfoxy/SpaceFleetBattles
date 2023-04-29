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

require 'fight'
require 'commanderai'
require 'squadai'
require 'unitai'

function love.resize(w, h)
	res.resize(w, h)
end

function beginContact(a, b, coll)
	-- a and be are fixtures
	print("Contact")
	-- get the body that owns the fixture
	local object1index, object2index

	for i = 1, #OBJECTS do
		if OBJECTS[i].fixture == a then
			object1index = i
		end
		if OBJECTS[i].fixture == b then
			object2index = i
		end
	end
	if OBJECTS[object1index].body:isBullet() then
		-- destroy Obj2
		OBJECTS[object1index].lifetime = 0
		OBJECTS[object2index].lifetime = 0
		print("Obj 2 destroyed")
		unitai.clearTarget(object2index)
	end
	if OBJECTS[object2index].body:isBullet() then
		-- destroy Obj1
		print("Obj 1 destroyed")
		OBJECTS[object2index].lifetime = 0
		OBJECTS[object1index].lifetime = 0

		unitai.clearTarget(object1index)

		local grid = GRIDS[enum.gridExplosion]
		local frames = grid('1-4', '3-4')
		local anim = anim8.newAnimation(frames, 0.1)
		anim.drawx = OBJECTS[object1index].body:getX()
		anim.drawy = OBJECTS[object1index].body:getY()
		anim.angle = OBJECTS[object1index].body:getAngle()
		-- anim.duration = 0.9		-- seconds
		anim.duration = 0.9		-- seconds
		table.insert(ANIMATIONS, anim)
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

function love.load()

	res.init({width = 1920, height = 1080, mode = 2})

	local width, height = love.window.getDesktopDimensions( 1 )
	res.setMode(width, height, {resizable = true})

	constants.load()		-- also loads enums
	fun.loadFonts()
    fun.loadAudio()
	fun.loadImages()

	-- mainmenu.loadButtons()

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	cam:setZoom(ZOOMFACTOR)
	cam:setPos(TRANSLATEX,	TRANSLATEY)

	love.window.setTitle("Dogfight 2 " .. GAME_VERSION)

	love.keyboard.setKeyRepeat(true)

	-- cf.addScreen("MainMenu", SCREEN_STACK)
	cf.addScreen(enum.sceneFight, SCREEN_STACK)

	lovelyToasts.canvasSize = {SCREEN_WIDTH, SCREEN_HEIGHT}
	lovelyToasts.options.tapToDismiss = true
	lovelyToasts.options.queueEnabled = true

	---------------
	love.physics.setMeter(30)
	PHYSICSWORLD = love.physics.newWorld(0,0,false)
	PHYSICSWORLD:setCallbacks(beginContact,endContact,_,_)

	GRIDS[enum.gridExplosion] = anim8.newGrid(16, 16, IMAGE[enum.imageExplosion]:getWidth(), IMAGE[enum.imageExplosion]:getHeight())
end


function love.draw()
    res.start()
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
		fight.draw()
	end

	love.graphics.setColor(1,1,1,1)
	local scale = love.physics.getMeter( )
	for _, animation in pairs(ANIMATIONS) do
		local drawx, drawy = cam:toScreen(animation.drawx, animation.drawy)
		animation:draw(IMAGE[enum.imageExplosion], drawx, drawy, animation.angle, 1, 1, 0, 0)
	end

    res.stop()
end


function love.update(dt)
	local currentscene = cf.currentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneFight then
        fight.update(dt)
	end

	for i = #ANIMATIONS, 1, -1 do
		ANIMATIONS[i]:update(dt)

		ANIMATIONS[i].duration = ANIMATIONS[i].duration - dt
		if ANIMATIONS[i].duration <= 0 then
			table.remove(ANIMATIONS, i)
		end
	end

end

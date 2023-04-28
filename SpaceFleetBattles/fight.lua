fight = {}

local sceneHasLoaded = false
local pause = false
local commanderAI = {}
local squadAI = {}
local squadlist = {}

local function createFighter(forf, squadcallsign, squadid)
    -- forf = friend or foe.  See enums
    -- callsign is plain text eg "Rogue One"
    -- squadid is a number that is not seen by player

    local rndx, rndy
    if forf == enum.forfFriend then
        rndx = love.math.random(50, SCREEN_WIDTH /3)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    elseif forf == enum.forfEnemy then
        rndx = love.math.random(SCREEN_WIDTH * 0.66, SCREEN_WIDTH - 50)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    elseif forf == enum.forfNeutral then
        rndx = love.math.random(50, SCREEN_WIDTH - 50)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    else
        error()
    end

    rndx = rndx / BOX2D_SCALE
    rndy = rndy / BOX2D_SCALE

    local thisobject = {}
    thisobject.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy, "dynamic")
	thisobject.body:setLinearDamping(0)
	-- thisobject.body:setMass(100)
    if forf == enum.forfEnemy then
        thisobject.body:setAngle(math.pi)
    end

    thisobject.shape = love.physics.newPolygonShape( -5, -5, 5, 0, -5, 5, -7, 0)
	thisobject.fixture = love.physics.newFixture(thisobject.body, thisobject.shape, 1)		-- the 1 is the density
    thisobject.fixture:setDensity( 1 )
	thisobject.fixture:setRestitution(0.25)
	thisobject.fixture:setSensor(true)
    thisobject.fixture:setGroupIndex( 1 )
    local guid = cf.getGUID()
	thisobject.fixture:setUserData(guid)

    thisobject.forf = forf
    thisobject.squadCallsign = squadcallsign
    thisobject.squadid = squadid
    thisobject.taskCooldown = 0
    thisobject.maxForwardThrust = 100
    thisobject.currentForwardThrust = 0
    thisobject.maxAcceleration = 25
    table.insert(OBJECTS, thisobject)
end

local function createCapitalShip()
    local rndx = love.math.random(50, SCREEN_WIDTH / 3)
    local rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    local rndx = rndx / BOX2D_SCALE
    local rndy = rndy / BOX2D_SCALE
    local thisobject = {}
    thisobject.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy, "dynamic")
	thisobject.body:setLinearDamping(0)
	-- thisobject.body:setMass(1)
    thisobject.shape = love.physics.newPolygonShape( -50, -15, 50, -15, 50, 15, -50, 15)
	thisobject.fixture = love.physics.newFixture(thisobject.body, thisobject.shape, 1)		-- the 1 is the density
    thisobject.fixture:setDensity( 1 )
	thisobject.fixture:setRestitution(0.25)
	thisobject.fixture:setSensor(false)
    thisobject.fixture:setGroupIndex( 0 )
    local guid = cf.getGUID()
	thisobject.fixture:setUserData(guid)
    thisobject.forwardThrust = 10
    table.insert(OBJECTS, thisobject)
end

local function createSquadron(forf)
    -- create a wing of 6 units
    -- the squadron is a concept only and is created by giving x fighters the same squad id
    -- input: forf = friend or foe. example: enum.forfFriend

    -- get a random and empty callsign from the squadlist
    local squadcallsign = nil
    while squadcallsign == nil do
        local txt = string.char(love.math.random(65, 90))
        local txt = txt .. tostring(love.math.random(1,9))
        if squadlist[txt] == nil then
            squadcallsign = txt
            squadlist[txt] = forf       -- mark this squad as friend or enemy

            squadAI[txt] = {}
            squadAI[txt].orders = {}
        end
    end

    local squadid = love.math.random(100, 999)                 --! make this less random and more unique
    for i = 1, 6 do
        createFighter(forf, squadcallsign, squadid)
    end
end

local function initialiseSquadList()
    squadlist = {}
    for i = 65, 90 do
        for j = 1, 9 do
            local str = string.char(i) .. tostring(j)
            squadlist[str] = nil            -- setting to nil makes it available for selection
        end
    end
end

function fight.keyreleased(key, scancode)
    if key == "space" then
        pause = not pause
    end
end

function fight.wheelmoved(x, y)

	if y > 0 then
		-- wheel moved up. Zoom in
		ZOOMFACTOR = ZOOMFACTOR + 0.05
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if ZOOMFACTOR > 3 then ZOOMFACTOR = 3 end
	print("Zoom factor = " .. ZOOMFACTOR)
end

function fight.mousemoved(x, y, dx, dy)
    local camx, camy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

    if love.mouse.isDown(3) then
        TRANSLATEX = TRANSLATEX - dx
        TRANSLATEY = TRANSLATEY - dy
    end

end

function fight.draw()
    cam:attach()

    -- draw each object
    for k, Obj in pairs(OBJECTS) do
        local thisbody = Obj.body
        for k, fixture in pairs(thisbody:getFixtures()) do

            -- draw callsign first
            local objguid = Obj.fixture:getUserData()
            local str = Obj.squadCallsign .. "-" .. string.sub(objguid, -2)
            local objx = Obj.body:getX()
            local objy = Obj.body:getY()
            local drawx = objx * BOX2D_SCALE
            local drawy = objy * BOX2D_SCALE
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(str, drawx, drawy, 0, 1, 1, -15, 30)

            -- draw a cool line next
            local x2, y2 = drawx + 30, drawy - 14
            love.graphics.setColor(1,1,1,1)
            love.graphics.line(drawx, drawy, x2, y2)

            -- draw velocity
            local vx, vy = Obj.body:getLinearVelocity()
            local vel = cf.getDistance(0, 0, vx, vy)    -- get distance of velocity vector
            vel = "v: " .. cf.round(vel, 0)
            love.graphics.print(vel, drawx, drawy, 0, 1, 1, 30, 30)


            -- draw the physics object
            local shape = fixture:getShape()
			local points = {thisbody:getWorldPoints(shape:getPoints())}
            for i = 1, #points do
	            points[i] = points[i] * BOX2D_SCALE
            end
            if Obj.forf == enum.forfFriend then
                love.graphics.setColor(0,1,0,1)
            elseif Obj.forf == enum.forfEnemy then
                love.graphics.setColor(0,0,1,1)
            elseif Obj.forf == enum.forfNeutral then
                love.graphics.setColor(0.5,0.5,0.5,1)
            end
			love.graphics.polygon("fill", points)

            -- -- draw the velocity indicator
            -- local linx, liny = Obj.body:getLinearVelocity( )        --! a lot of duplicate code here. Can be cleand up
            -- linx = linx * 2
            -- liny = liny * 2
            --
            -- local objx, objy = Obj.body:getPosition( )
            -- local objxscaled = objx * BOX2D_SCALE
            -- local objyscaled = objy * BOX2D_SCALE
            -- local pointxscaled = (objx + linx) * BOX2D_SCALE
            -- local pointyscaled = (objy + liny) * BOX2D_SCALE
            --
            -- love.graphics.setColor(1,0,1,1)
            -- love.graphics.line(objxscaled, objyscaled, pointxscaled, pointyscaled)
		end
    end

    -- cf.printAllPhysicsObjects(PHYSICSWORLD, BOX2D_SCALE)
    cam:detach()
end

function fight.update(dt)
    if not sceneHasLoaded then
        sceneHasLoaded = true

        commanderAI[1] = {}
        commanderAI[1].forf = enum.forfFriend
        commanderAI[2] = {}
        commanderAI[2].forf = enum.forfEnemy
        --! neutral commander?

        -- initialise squad callsigns
        initialiseSquadList()

        -- create a squadron
        createSquadron(enum.forfFriend)
        createSquadron(enum.forfEnemy)
    end

    if not pause then
        commanderai.update(commanderAI, dt)
        squadai.update(commanderAI, squadAI, squadlist, dt)
        unitai.update(squadAI, dt)

        PHYSICSWORLD:update(dt) --this puts the world into motion
    end
    lovelyToasts.update(dt)

    cam:setZoom(ZOOMFACTOR)
    cam:setPos(TRANSLATEX,	TRANSLATEY)
end

return fight

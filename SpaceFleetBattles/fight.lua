fight = {}

local sceneHasLoaded = false
local pause = false
local snapcamera = true
local commanderAI = {}
local squadAI = {}
local squadlist = {}
local shipspersquadron = 12

local function createFighter(forf, squadcallsign, squadid)
    -- forf = friend or foe.  See enums
    -- callsign is plain text eg "Rogue One"
    -- squadid is a number that is not seen by player

    local rndx, rndy
    if forf == enum.forfFriend then
        -- rndx = love.math.random(50, SCREEN_WIDTH /3)
        rndx = FRIEND_START_X + love.math.random(-10, 10)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    elseif forf == enum.forfEnemy then
        -- rndx = love.math.random(SCREEN_WIDTH * 0.66, SCREEN_WIDTH - 50)
        rndx = FOE_START_X + love.math.random(-10, 10)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    elseif forf == enum.forfNeutral then
        rndx = love.math.random(50, SCREEN_WIDTH - 50)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    else
        error()
    end

    rndx = rndx
    rndy = rndy

    local thisobject = {}
    thisobject.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy, "dynamic")
	thisobject.body:setLinearDamping(0)
	-- thisobject.body:setMass(100)
    if forf == enum.forfEnemy then
        thisobject.body:setAngle(math.pi)
    end

    thisobject.shape = love.physics.newPolygonShape( -5, -5, 5, 0, -5, 5, -7, 0)
	thisobject.fixture = love.physics.newFixture(thisobject.body, thisobject.shape, 1)		-- the 1 is the density
	thisobject.fixture:setRestitution(0.25)
	thisobject.fixture:setSensor(false)

    if forf == enum.forfFriend then
        thisobject.fixture:setCategory(enum.categoryFriendlyFighter)
        thisobject.fixture:setMask(enum.categoryFriendlyFighter, enum.categoryFriendlyBullet, enum.categoryEnemyFighter)
    else
        thisobject.fixture:setCategory(enum.categoryEnemyFighter)
        thisobject.fixture:setMask(enum.categoryEnemyFighter, enum.categoryEnemyBullet, enum.categoryFriendlyFighter)   -- these are the things that will not trigger a collision
    end

    local guid = cf.getGUID()
	thisobject.fixture:setUserData(guid)
    thisobject.guid = guid

    thisobject.forf = forf
    thisobject.squadCallsign = squadcallsign
    thisobject.squadid = squadid
    thisobject.taskCooldown = 0
    thisobject.weaponcooldown = 0           --! might be more than one weapon in the future

    thisobject.currentMaxForwardThrust = 100    -- can be less than max if battle damaged
    thisobject.maxForwardThrust = 100
    thisobject.currentForwardThrust = 0
    thisobject.maxAcceleration = 25
    thisobject.maxDeacceleration = 25       -- set to 0 for bullets
    thisobject.currentMaxAcceleration = 25 -- this can be less than maxAcceleration if battle damaged
    thisobject.maxSideThrust = 1
    thisobject.currentSideThrust = 1

    thisobject.componentSize = {}
    thisobject.componentSize[enum.componentStructure] = 3
    thisobject.componentSize[enum.componentThruster] = 2
    thisobject.componentSize[enum.componentAccelerator] = 1
    thisobject.componentSize[enum.componentWeapon] = 1
    thisobject.componentSize[enum.componentSideThruster] = 1

    thisobject.componentHealth = {}
    thisobject.componentHealth[enum.componentStructure] = 100
    thisobject.componentHealth[enum.componentThruster] = 100
    thisobject.componentHealth[enum.componentAccelerator] = 100
    thisobject.componentHealth[enum.componentWeapon] = 100
    thisobject.componentHealth[enum.componentSideThruster] = 100

    thisobject.destx = nil
    thisobject.desty = nil

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
    for i = 1, shipspersquadron do
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

local function destroyObjects(dt)

    for i = #OBJECTS, 1, -1 do
        if OBJECTS[i].lifetime ~= nil then
            OBJECTS[i].lifetime = OBJECTS[i].lifetime - dt
            if OBJECTS[i].lifetime <= 0 then
                OBJECTS[i].body:destroy()
                table.remove(OBJECTS, i)
            end
        end
    end
end

function fight.keyreleased(key, scancode)
    if key == "space" then pause = not pause end
    if key == "c" then snapcamera = not snapcamera end
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
        snapcamera = false
        TRANSLATEX = TRANSLATEX - dx
        TRANSLATEY = TRANSLATEY - dy
    end

end

local function drawHUD()

    love.graphics.draw(IMAGE[enum.imageFightHUD], 0, 0)

    if OBJECTS[1].guid == PLAYER_GUID then

        local barlength = 100       -- unnecessary but a reminder that the barlength is a convenient 100 pixels
        local barheight = 10
        love.graphics.setColor(0,1,0,0.3)

        -- structure bar
        local drawlength = OBJECTS[1].componentHealth[enum.componentStructure]
        love.graphics.rectangle("fill", 145, 47, drawlength, 10)

        -- thrusters bar
        local drawlength = OBJECTS[1].componentHealth[enum.componentThruster]
        love.graphics.rectangle("fill", 145, 71, drawlength, 10)

        -- weapon bar
        local drawlength = OBJECTS[1].componentHealth[enum.componentWeapon]
        love.graphics.rectangle("fill", 145, 95, drawlength, 10)

        -- Steering bar (side thrusters)
        local drawlength = OBJECTS[1].componentHealth[enum.componentSideThruster]
        love.graphics.rectangle("fill", 145, 119, drawlength, 10)

        -- throttle bar (componentAccelerator)
        local drawlength = OBJECTS[1].componentHealth[enum.componentAccelerator]
        love.graphics.rectangle("fill", 145, 143, drawlength, 10)

    end
end

function fight.draw()

    drawHUD()       -- do this before the attach

    cam:attach()

    -- draw the boundary
    love.graphics.setColor(1,1,1,0.25)
    love.graphics.line(0,0, FRIEND_START_X, SCREEN_HEIGHT)
    love.graphics.line(FOE_START_X, 0, FOE_START_X, SCREEN_HEIGHT)

    -- draw each object
    for k, Obj in pairs(OBJECTS) do
        local objx = Obj.body:getX()
        local objy = Obj.body:getY()
        local drawx = objx
        local drawy = objy

        for _, fixture in pairs(Obj.body:getFixtures()) do

            -- draw callsign first
            local objguid = Obj.fixture:getUserData()
            if Obj.squadCallsign ~= nil then
                local str = "CS: " .. Obj.squadCallsign .. "-" .. string.sub(objguid, -2)

                love.graphics.setColor(1,1,1,1)
                love.graphics.print(str, drawx, drawy, 0, 1, 1, -15, 30)

                -- draw a cool line next
                local x2, y2 = drawx + 30, drawy - 14
                love.graphics.setColor(1,1,1,1)
                love.graphics.line(drawx, drawy, x2, y2)
            end

            -- draw velocity
            -- if not Obj.body:isBullet() then
            --     local vx, vy = Obj.body:getLinearVelocity()
            --     local vel = cf.getDistance(0, 0, vx, vy)    -- get distance of velocity vector
            --     vel = "v: " .. cf.round(vel, 0)             -- this is not the same as getLinearVelocity x/y because this is the distance between two points
            --     love.graphics.setColor(1,1,1,1)
            --     love.graphics.print(vel, drawx, drawy, 0, 1, 1, 30, 30)
            -- end

            -- draw the physics object
            local shape = fixture:getShape()
            if shape:typeOf("PolygonShape") then
    			local points = {Obj.body:getWorldPoints(shape:getPoints())}
                if Obj.forf == enum.forfFriend then
                    love.graphics.setColor(0,1,0,1)
                elseif Obj.forf == enum.forfEnemy then
                    love.graphics.setColor(0,0,1,1)
                elseif Obj.forf == enum.forfNeutral then
                    love.graphics.setColor(0.5,0.5,0.5,1)
                else
                    error()
                end

                if objguid == PLAYER_GUID then
                    love.graphics.setColor(1,1,0,1)
                end

    			love.graphics.polygon("fill", points)
            elseif shape:typeOf("CircleShape") then
				local drawx, drawy = Obj.body:getWorldPoints(shape:getPoint())
				drawx = drawx
				drawy = drawy
				local radius = shape:getRadius()
				radius = radius
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.circle("line", drawx, drawy, radius)
			else
                error()
            end






            -- draw the velocity indicator
            -- local linx, liny = Obj.body:getLinearVelocity( )        --! a lot of duplicate code here. Can be cleand up
            -- linx = linx * 2
            -- liny = liny * 2
            -- local objx, objy = Obj.body:getPosition( )
            -- local objxscaled = objx
            -- local objyscaled = objy
            -- local pointxscaled = (objx + linx)
            -- local pointyscaled = (objy + liny)
            -- love.graphics.setColor(1,0,1,1)
            -- love.graphics.line(objxscaled, objyscaled, pointxscaled, pointyscaled)
		end
    end

    -- draw target recticle for player 1
    if OBJECTS[1].guid == PLAYER_GUID then
        -- player still alive
        local targetid = OBJECTS[1].targetid        -- OBJECTS index
        if not OBJECTS[targetid].body:isDestroyed() then
            local drawx = OBJECTS[targetid].body:getX()
            local drawy = OBJECTS[targetid].body:getY()

            love.graphics.setColor(1,0,0,1)
            love.graphics.circle("line", drawx, drawy, 10)
        end
    end

    -- cf.printAllPhysicsObjects(PHYSICSWORLD, 1)
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
        -- createSquadron(enum.forfFriend)
        -- createSquadron(enum.forfEnemy)
        createSquadron(enum.forfEnemy)

        PLAYER_GUID = OBJECTS[1].fixture:getUserData()
    end

    if not pause then
        commanderai.update(commanderAI, dt)
        squadai.update(commanderAI, squadAI, squadlist, dt)
        unitai.update(squadAI, dt)

        destroyObjects(dt)

        PHYSICSWORLD:update(dt) --this puts the world into motion
    end
    lovelyToasts.update(dt)

    if snapcamera then
        TRANSLATEX = OBJECTS[1].body:getX()     -- if 1 == player then this works well
        TRANSLATEY = OBJECTS[1].body:getY()     -- if 1 ~= player then still works well
    end

    cam:setZoom(ZOOMFACTOR)
    cam:setPos(TRANSLATEX,	TRANSLATEY)
end

return fight

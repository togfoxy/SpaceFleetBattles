unitai = {}

function unitai.createFighter(forf, squadcallsign)
    -- forf = friend or foe.  See enums
    -- callsign is plain text eg "Rogue One". It is also the unique identifier for the squad

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
    thisobject.currentAction = nil              -- this will be influenced by squad orders + player choices
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

local function createEscapePod(Obj)
    -- Obj is the obj that is spawning/creating the pod. It assumed this Obj will soon be destroyed

    local podx, pody = Obj.body:getPosition()

    local thisobject = {}
    thisobject.body = love.physics.newBody(PHYSICSWORLD, podx, pody, "dynamic")
	thisobject.body:setLinearDamping(0)

    if forf == enum.forfFriend then
        thisobject.body:setAngle(math.pi)   -- towards base
    else
        thisobject.body:setAngle(0)
    end

    thisobject.shape = love.physics.newRectangleShape(4, 3)
	thisobject.fixture = love.physics.newFixture(thisobject.body, thisobject.shape, 1)		-- the 1 is the density
	thisobject.fixture:setRestitution(0.25)
	thisobject.fixture:setSensor(false)

    if Obj.forf == enum.forfFriend then
        thisobject.fixture:setCategory(enum.categoryFriendlyPod)
        thisobject.fixture:setMask(enum.categoryFriendlyFighter, enum.categoryFriendlyBullet, enum.categoryEnemyFighter, enum.categoryFriendlyPod)
        thisobject.body:applyLinearImpulse(-0.75, 0)
    elseif Obj.forf == enum.forfEnemy then
        thisobject.fixture:setCategory(enum.categoryEnemyPod)
        thisobject.fixture:setMask(enum.categoryEnemyFighter, enum.categoryEnemyBullet, enum.categoryFriendlyFighter, enum.categoryEnemyPod)   -- these are the things that will not trigger a collision
        thisobject.body:applyLinearImpulse(0.75, 0)
    end

    if Obj.guid == PLAYER_GUID then
        guid = PLAYER_GUID      -- POD inherits player guid
    else
        local guid = cf.getGUID()
    end
	thisobject.fixture:setUserData(guid)
    thisobject.guid = guid

    thisobject.forf = Obj.forf
    thisobject.squadCallsign = Obj.squadcallsign
    thisobject.currentAction = nil              -- this will be influenced by squad orders + player choices
    thisobject.taskCooldown = 0
    thisobject.weaponcooldown = 0           --! might be more than one weapon in the future

    thisobject.currentMaxForwardThrust = 50    -- can be less than max if battle damaged
    thisobject.maxForwardThrust = 50
    thisobject.currentForwardThrust = 0
    thisobject.maxAcceleration = 25
    thisobject.maxDeacceleration = 25       -- set to 0 for bullets
    thisobject.currentMaxAcceleration = 25 -- this can be less than maxAcceleration if battle damaged
    thisobject.maxSideThrust = 0
    thisobject.currentSideThrust = 0

    thisobject.componentSize = {}
    thisobject.componentSize[enum.componentStructure] = 3
    thisobject.componentSize[enum.componentThruster] = 0
    thisobject.componentSize[enum.componentAccelerator] = 0
    thisobject.componentSize[enum.componentWeapon] = 0
    thisobject.componentSize[enum.componentSideThruster] = 0

    thisobject.componentHealth = {}
    thisobject.componentHealth[enum.componentStructure] = 100
    thisobject.componentHealth[enum.componentThruster] = 0
    thisobject.componentHealth[enum.componentAccelerator] = 0
    thisobject.componentHealth[enum.componentWeapon] = 0
    thisobject.componentHealth[enum.componentSideThruster] = 0

    thisobject.destx = nil
    thisobject.desty = nil

    table.insert(OBJECTS, thisobject)
end

function unitai.clearTarget(deadtargetguid)
    -- move through all objects and clear target guid if target guid = input parameter
    -- use this to remove targets from other craft if a target is destroyed
    -- input: deadtargetguid = guid of the target that is dead
    for k, Obj in pairs(OBJECTS) do
        if Obj.targetguid == nil then
           -- do nothing
        else
            if Obj.targetguid == deadtargetguid then
                Obj.targetguid = nil
            end
        end
    end
end

local function getClosestFighter(thisObj, desiredforf)
    -- returns the guid of the closest object (or nil)

    local closestdist = 999999999       -- ridiculously large
    local closestid = nil
    local thisobjx, thisobjy = thisObj.body:getPosition()

    for k, Obj in pairs(OBJECTS) do
        -- get distance to this obj
        if Obj.forf == desiredforf and not Obj.body:isBullet() then
            if Obj.fixture:getCategory() == enum.categoryEnemyFighter or Obj.fixture:getCategory() == enum.categoryFriendlyFighter then
                local objx, objy = Obj.body:getPosition()
                local dist = cf.getDistance(thisobjx, thisobjy, objx, objy)
                if closestid == 0 or dist < closestdist then
                    -- got a new candidate
                    closestid = k
                    closestdist = dist
                end
            end
        end
    end
    if closestid == nil then
        return nil
    else
        return OBJECTS[closestid].guid
    end
end

local function setTaskRTB(Obj)
    Obj.targetguid = nil
    Obj.currentAction = enum.unitActionReturningToBase
    if Obj.destx == nil then
        if Obj.forf == enum.forfFriend then
            Obj.destx = FRIEND_START_X
        elseif Obj.forf == enum.forfEnemy then
            Obj.destx = FOE_START_X
        end
        Obj.desty = Obj.body:getY()
    end
end

local function setTaskDestination(Obj, x, y)
	-- set Obj's task to move to the given x/y location
    Obj.targetguid = nil
    Obj.currentAction = enum.unitActionMoveToDest
	Obj.destx = x
	Obj.desty = y

    -- use this code when the new action queue is introduced
	-- local thisaction = {}
	-- thisaction.cooldown = 5
	-- thisaction.action = enum.unitActionMoveToDest
	-- thisaction.targetguid = nil
	-- thisaction.destx = x
	-- thisaction.desty = y
	-- table.insert(Obj.actions, thisaction)
end

local function setTaskEject(Obj)
    Obj.lifetime = 0
    createEscapePod(Obj)
end

local function updateUnitTask(Obj, squadorder, dt)
    -- this adjusts targets or other goals based on the squad order

    Obj.taskCooldown = Obj.taskCooldown - dt
    -- print("Task cooldown:" .. cf.round(Obj.taskCooldown,1)
    if Obj.taskCooldown <= 0 then
        Obj.taskCooldown = 5

        -- do self-preservation checks firstly. Remember the ordering matters
        if (Obj.componentHealth[enum.componentStructure] <= 35 and fun.unitIsTargeted(Obj.guid))
            or (Obj.componentHealth[enum.componentStructure] <= 35 and Obj.componentHealth[enum.componentThruster] <= 0) then
            setTaskEject(Obj)
        elseif Obj.componentHealth[enum.componentWeapon] <= 0 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentThruster] <= 50 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentSideThruster] <= 25 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentAccelerator] <= 25 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentStructure] <= 50 then
            setTaskRTB(Obj)
        elseif not fun.unitIsTargeted(Obj.guid) and Obj.body:getY() < 0 then
			-- move back inside the battle map
			setTaskDestination(Obj, Obj.body:getX(), 100)		--! check that this 100 value is correct
		elseif not fun.unitIsTargeted(Obj.guid) and Obj.body:getY() > SCREEN_HEIGHT then
			-- move back inside the battle map
			setTaskDestination(Obj, Obj.body:getX(), SCREEN_HEIGHT - 100)		--! check that this 100 value is correct

		-- after the self-preservation bits, take direction from current squad orders
        elseif squadorder == enum.squadOrdersEngage then

            -- get closest target
            Obj.currentAction = enum.unitActionEngaging
            Obj.destx = nil         -- clear previous destinations if any
            Obj.desty = nil
            if Obj.forf == enum.forfFriend then
                Obj.targetguid = getClosestFighter(Obj, enum.forfEnemy)        -- this OBJECTS guid or nil
            end
            if Obj.forf == enum.forfEnemy then
                Obj.targetguid = getClosestFighter(Obj, enum.forfFriend)       -- this OBJECTS guid or nil
            end

            -- do an assert here
            if Obj.targetguid ~= nil then
                local targetobj = fun.getObject(Obj.targetguid)
                local targetcategory = targetobj.fixture:getCategory()
                assert(targetcategory == enum.categoryEnemyFighter or targetcategory == enum.categoryFriendlyFighter)
            end

            -- print("Unit task: setting target id")
        elseif squadorder == enum.squadOrdersReturnToBase then
                setTaskRTB(Obj)
            -- print("Unit task: RTB")
        else
            --! no squad order or unexpected squad order
            Obj.currentAction = nil
            print("No squad order available for this unit")
        end
    end
end

local function isFighter(Obj)

    local category = Obj.fixture:getCategory()
    if category == enum.categoryEnemyFighter or category == enum.categoryFriendlyFighter then
        return true
    else
        return false
    end
end

local function turnToObjective(Obj, destx, desty, dt)
    -- turn the object towards the destx/desty

    local force = 1
    local currentangle = Obj.body:getAngle()            -- rads

    assert(currentangle <= math.pi * 2)
    assert(currentangle >= math.pi * -2)

    local bearing = cf.getBearingRad(Obj.body:getX(), Obj.body:getY(), destx, desty)        -- this is absolute bearing in radians, starting from north

    local bearingdelta = bearing - currentangle

    if bearingdelta < -0.05 or bearingdelta > 0.05 then         -- rads
        if bearingdelta > 0 then
            -- turn right
            force = 1
        else
            force = -1
        end
    else
        Obj.body:setAngularVelocity(0)
    end
    force = force * Obj.currentSideThrust * dt
    Obj.body:applyAngularImpulse( force  )
end

local function adjustAngle(Obj, dt)
    -- turn to face the current target
    -- if there is a nominated target then find the preferred angle and turn towards it

    assert(Obj.body:isBullet() == false)
    local action = Obj.currentAction

    while Obj.body:getAngle() > (math.pi * 1) do
        Obj.body:setAngle(Obj.body:getAngle() - (math.pi * 2))
    end
    while Obj.body:getAngle() < (math.pi * -1) do
        Obj.body:setAngle(Obj.body:getAngle() + (math.pi * 2))
    end

    local bearingrad
    if action == enum.unitActionReturningToBase then        --! should probably check for RTB or something like that and not a nil targetguid
        if Obj.destx ~= nil then
            -- move to destination
            local objx, objy = Obj.body:getPosition()
            local destx, desty = Obj.destx, Obj.desty
            local disttodest = cf.getDistance(objx, objy, destx, desty)
            if disttodest < 10 then     -- not sure why this code is here in this function
                -- arrived at destination
                Obj.lifetime = 0                        -- destroy the object
            else
                turnToObjective(Obj, destx, desty, dt)
            end
        else
            --! should throw error or set a new destination?
        end

    elseif action == enum.unitActionEngaging then
        local x1, y1 = Obj.body:getPosition()           --! can refactor this code
        local enemyobject = fun.getObject(Obj.targetguid)
        if enemyobject ~= nil and not enemyobject.body:isDestroyed() then        -- check if target is dead
            local x2, y2 = enemyobject.body:getPosition()
            turnToObjective(Obj, x2, y2, dt)
        else
            --! is this an error?
        end
    else
        --! nothing. Is this an error? Maybe not
    end
end

local function adjustThrust(Obj, dt)
    -- move forward
    -- this shouldn't be called for bullets
    assert(Obj.squadCallsign ~= nil)        -- bullets should not be sent to this function
    assert(Obj.body:isBullet() == false)
    local destx = Obj.destx
    local desty = Obj.desty

    local currentangle = Obj.body:getAngle( )
    if Obj.currentAction == enum.unitActionEngaging then
        -- print("zulu")
        -- don't overtake target
        local objx, objy = Obj.body:getPosition()
        local objfacing = Obj.body:getAngle()
        local targetObj = fun.getObject(Obj.targetguid)
        if targetObj ~= nil and isFighter(targetObj) then
            -- print("alpha")
            local targetx, targety = targetObj.body:getPosition()

            if cf.isInFront(objx, objy, objfacing, targetx, targety) then
                -- print("beta")
                if targetObj.currentForwardThrust < Obj.currentForwardThrust then
                    -- print("charlie")
                    local dist = cf.getDistance(objx, objy, targetx, targety)
                    if dist <= 125 then
                        -- print("delta")
                        -- try to match speed if unit is behind target
						local minheading = objfacing - 0.7853			-- 0.7 rads = 45 deg		-- should probably make these constants
						local maxheading = objfacing + 0.7853
						local targetfacing = targetObj.body:getAngle()

						if targetfacing >= minheading and targetfacing <= maxheading then		--! check that the min/max thing converts to radians properly
							-- unit is behind the target. Try to match speed
							Obj.currentForwardThrust = Obj.currentForwardThrust - (Obj.maxDeacceleration * dt)
							if Obj.currentForwardThrust < targetObj.currentForwardThrust then
								-- print("echo")
								Obj.currentForwardThrust = targetObj.currentForwardThrust
							end
						else
							-- unit is not behind target so max thrust
							Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
						end
                    else
                        -- print("foxtrot")
                        -- max thrust needed
                        Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
                    end
                else
                    -- print("golf")
                    -- max throttle
                    Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
                end
            else
                -- target is not in front or target is not a fighter. Assume full thrust is needed
                Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
            end
        else
            print("Engaging but no target. ??")
        end
    elseif destx ~= nil then
		local objx, objy = Obj.body:getPosition()
		local disttodest = cf.getDistance(objx, objy, destx, desty)
		if disttodest > 10 then
			Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
		else
			Obj.taskCooldown = 0		-- effectively delete the current task
		end
    else
        -- no orders. Slow down and stop
        print("No task for this unit. Will slow and stop")
        Obj.currentForwardThrust = Obj.currentForwardThrust - (Obj.maxDeacceleration * dt)  -- might be zero for bullets
    end

    if Obj.currentForwardThrust > Obj.currentMaxForwardThrust then Obj.currentForwardThrust = Obj.currentMaxForwardThrust end
    if Obj.currentForwardThrust < 0 then Obj.currentForwardThrust = 0 end

    Obj.body:setLinearVelocity(math.cos(currentangle) * Obj.currentForwardThrust, math.sin(currentangle) * Obj.currentForwardThrust)
    -- print("Velocity for " .. Obj.fixture:getUserData() .. " is now " .. Obj.body:getLinearVelocity() .. " and thrust is " .. Obj.currentForwardThrust)
end

local function createNewBullet(Obj, bullet)
    -- input: bullet = true if bullet

    assert(bullet ~= nil)       -- ensure parameter is not nil

    local x, y = Obj.body:getPosition()
    local currentangle = Obj.body:getAngle()
    local currentangledeg = math.deg(currentangle + 1.5707) -- 90 deg

    -- spawn the bullet in front of the object that is creating it
    local newx, newy = cf.addVectorToPoint(x,y,currentangledeg,10)

    local thisobject = {}
    thisobject.body = love.physics.newBody(PHYSICSWORLD, newx, newy, "dynamic")
    thisobject.body:setLinearDamping(0)
    thisobject.body:setMass(0)
    thisobject.body:setBullet(bullet)

    thisobject.shape = love.physics.newCircleShape(1)
    thisobject.fixture = love.physics.newFixture(thisobject.body, thisobject.shape, 1)		-- the 1 is the density
    thisobject.fixture:setRestitution(0)                    -- amount of bounce after a collision
    thisobject.fixture:setSensor(false)
    if Obj.forf == enum.forfFriend then
        thisobject.fixture:setCategory(enum.categoryFriendlyBullet)
        thisobject.fixture:setMask(enum.categoryFriendlyBullet, enum.categoryEnemyBullet, enum.categoryFriendlyFighter)
    else
        thisobject.fixture:setCategory(enum.categoryEnemyBullet)
        thisobject.fixture:setMask(enum.categoryFriendlyBullet, enum.categoryEnemyBullet, enum.categoryEnemyFighter)
    end
    local guid = cf.getGUID()
    thisobject.fixture:setUserData(guid)

    thisobject.squadCallsign = nil
    thisobject.lifetime = 10            -- seconds
    thisobject.ownerObjectguid = Obj.guid

    thisobject.body:setAngle(currentangle)
    local velx, vely = Obj.body:getLinearVelocity()
    thisobject.body:setLinearVelocity(math.cos(currentangle) * 300, math.sin(currentangle) * 300)

    table.insert(OBJECTS, thisobject)
end

local function fireWeapons(Obj, dt)
    -- fire weapons for this single Obj (if available)

    Obj.weaponcooldown = Obj.weaponcooldown - dt
    if Obj.weaponcooldown <= 0 then
        Obj.weaponcooldown = 0

        if Obj.componentHealth[enum.componentWeapon] > 0 then
            if Obj.targetguid ~= nil then
                local enemyobject = fun.getObject(Obj.targetguid)
                if enemyobject ~= nil and not enemyobject.body:isDestroyed() then        -- check if target is dead
                    local objx = Obj.body:getX()
                    local objy = Obj.body:getY()
                    local targetx = enemyobject.body:getX()
                    local targety = enemyobject.body:getY()

                    local currentangle = Obj.body:getAngle()
                    local bearingtotarget = cf.getBearingRad(objx,objy,targetx,targety)
                    local angletotarget = bearingtotarget - currentangle
                    -- print(currentangle, bearingtotarget, angletotarget)

                    if angletotarget > -0.08 and angletotarget < 0.08 then
                        Obj.weaponcooldown = 4
                        createNewBullet(Obj, true)       -- includes missiles and bombs. Use TRUE for fast moving bullets
                    end
                end
            end
        end
    end
end

local function updatePod(Pod)
    -- Pod is an object. Check if it reaches safetly
    if Pod.forf == enum.forfFriend then
        if Pod.body:getX() <= FRIEND_START_X then
            -- safe
            Pod.lifetime = 0
        end

    elseif Pod.forf == enum.forfEnemy then
        if Pod.body:getX() >= FOE_START_X then
            -- safe
            Pod.lifetime = 0
        end
    else
        error()
    end

end

function unitai.update(squadAI, dt)
    -- update all units in OBJECTS based on the AI above them
    -- update the unit based on orders broadcasted in squadAI

    local squadorder
    for k = #OBJECTS, 1, -1 do
        Obj = OBJECTS[k]
        local callsign = Obj.squadCallsign
        local objcategory = Obj.fixture:getCategory()

        if objcategory == enum.categoryEnemyFighter or objcategory == enum.categoryFriendlyFighter then
            assert(Obj.body:isBullet() == false)
            if #squadAI[callsign].orders == 0 then
                squadorder = nil
                print("Unit detecting squad has no order")
            else
                squadorder = squadAI[callsign].orders[1].order
            end
            updateUnitTask(Obj, squadorder, dt)     -- choose targets etc based on the current squad order
            adjustAngle(Obj, dt)         -- send the object and the order for its squad
            adjustThrust(Obj, dt)
            fireWeapons(Obj, dt)
        elseif objcategory == enum.categoryEnemyPod or objcategory == enum.categoryFriendlyPod then
                updatePod(Obj)
        else
            -- must be a bullet. Do nothing
        end
    end
end

return unitai

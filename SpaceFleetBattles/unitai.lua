unitai = {}

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

local function getClosestObject(thisObj, desiredforf)
    -- returns the guid of the closest object (or nil)

    local closestdist = 999999999       -- ridiculously large
    local closestid = nil
    local thisobjx, thisobjy = thisObj.body:getPosition()

    for k, Obj in pairs(OBJECTS) do
        -- get distance to this obj
        if Obj.forf == desiredforf then
            local objx, objy = Obj.body:getPosition()
            local dist = cf.getDistance(thisobjx, thisobjy, objx, objy)
            if closestid == 0 or dist < closestdist then
                -- got a new candidate
                closestid = k
                closestdist = dist
            end
        end
    end
    return OBJECTS[closestid].guid
end

local function setTaskRTB(Obj)
    Obj.targetguid = nil
    if Obj.destx == nil then
        if Obj.forf == enum.forfFriend then
            Obj.destx = FRIEND_START_X
        elseif Obj.forf == enum.forfEnemy then
            Obj.destx = FOE_START_X
        end
        Obj.desty = Obj.body:getY()
    end
end

local function updateUnitTask(Obj, squadorder, dt)
    -- this adjusts targets or other goals based on the squad order

    Obj.taskCooldown = Obj.taskCooldown - dt
    -- print("Task cooldown:" .. cf.round(Obj.taskCooldown,1)
    if Obj.taskCooldown <= 0 then
        Obj.taskCooldown = 5

        -- do self-preservation checks firstly. Remember the ordering matters
        if Obj.componentHealth[enum.componentWeapon] <= 0 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentThruster] <= 50 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentSideThruster] <= 25 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentAccelerator] <= 25 then
            setTaskRTB(Obj)
        elseif Obj.componentHealth[enum.componentStructure] <= 50 then
            setTaskRTB(Obj)

        -- task has cooled. Get a new task
        elseif squadorder == enum.squadOrdersEngage then

            -- get closest target
            Obj.destx = nil         -- clear previous destinations if any
            Obj.desty = nil
            if Obj.forf == enum.forfFriend then
                Obj.targetguid = getClosestObject(Obj, enum.forfEnemy)        -- this OBJECTS guid
            end
            if Obj.forf == enum.forfEnemy then
                Obj.targetguid = getClosestObject(Obj, enum.forfFriend)       -- this OBJECTS guid
            end

            -- print("Unit task: setting target id")
        elseif squadorder == enum.squadOrdersReturnToBase then
                setTaskRTB(Obj)
            -- print("Unit task: RTB")
        else
            --! no squad order or unexpected squad order
            print("No squad order available")
        end
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

    while Obj.body:getAngle() > (math.pi * 1) do
        Obj.body:setAngle(Obj.body:getAngle() - (math.pi * 2))
    end
    while Obj.body:getAngle() < (math.pi * -1) do
        Obj.body:setAngle(Obj.body:getAngle() + (math.pi * 2))
    end

    local bearingrad
    if Obj.targetguid == nil or Obj.targetguid == 0 then
        if Obj.destx ~= nil then
            -- move to destination
            local objx, objy = Obj.body:getPosition()
            local destx, desty = Obj.destx, Obj.desty
            local disttodest = cf.getDistance(objx, objy, destx, desty)
            if disttodest < 10 then
                -- print("Arrived at destination")      --! need to remove the fighter from play
                Obj.currentForwardThrust = 0                --! this is for testing only
            else
                turnToObjective(Obj, destx, desty, dt)
            end
        end

    elseif Obj.targetguid ~= nil then
        local x1, y1 = Obj.body:getPosition()
        local enemyobject = fun.getObject(Obj.targetguid)
        if not enemyobject.body:isDestroyed() then        -- check if target is dead
            local x2, y2 = enemyobject.body:getPosition()
            turnToObjective(Obj, x2, y2, dt)
        end
    else
        -- nothing. Is this an error?
    end
end

local function adjustThrust(Obj, dt)
    -- move forward
    -- this shouldn't be called for bullets
    assert(Obj.squadCallsign ~= nil)        -- bullets should not be sent to this function
    assert(Obj.body:isBullet() == false)

    local currentangle = Obj.body:getAngle( )
    if Obj.targetguid ~= nil then
        Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
        if Obj.currentForwardThrust > Obj.currentMaxForwardThrust then Obj.currentForwardThrust = Obj.currentMaxForwardThrust end
    elseif Obj.destx ~= nil then
        Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
        if Obj.currentForwardThrust > Obj.currentMaxForwardThrust then Obj.currentForwardThrust = Obj.currentMaxForwardThrust end
    else
        -- no target. Slow down and stop
        Obj.currentForwardThrust = Obj.currentForwardThrust - (Obj.maxDeacceleration * dt)  -- might be zero for bullets
        if Obj.currentForwardThrust < 0 then Obj.currentForwardThrust = 0 end
    end

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
                if not enemyobject.body:isDestroyed() then        -- check if target is dead
                    local objx = Obj.body:getX()
                    local objy = Obj.body:getY()
                    local targetx = enemyobject.body:getX()
                    local targety = enemyobject.body:getY()

                    local currentangle = Obj.body:getAngle()
                    local bearingtotarget = cf.getBearingRad(objx,objy,targetx,targety)
                    local angletotarget = bearingtotarget - currentangle
                    -- print(currentangle, bearingtotarget, angletotarget)

                    if angletotarget > -0.10 and angletotarget < 0.10 then
                        Obj.weaponcooldown = 4
                        createNewBullet(Obj, true)       -- includes missiles and bombs. Use TRUE for fast moving bullets
                    end
                end
            end
        end
    end
end

function unitai.update(squadAI, dt)
    -- update all units in OBJECTS based on the AI above them
    -- update the unit based on orders broadcasted in squadAI

    local squadorder
    for k = #OBJECTS, 1, -1 do
        Obj = OBJECTS[k]
        local callsign = Obj.squadCallsign

        -- print(callsign)
        -- print(inspect(squadAI[callsign]))
        -- print(inspect(squadAI[callsign].orders))

        if callsign ~= nil then                     -- bullets won't have a callsign
            assert(Obj.body:isBullet() == false)
            if #squadAI[callsign].orders == 0 then
                squadorder = nil
            else
                squadorder = squadAI[callsign].orders[1].order
            end

            updateUnitTask(Obj, squadorder, dt)     -- choose targets etc based on the current squad order
            adjustAngle(Obj, dt)         -- send the object and the order for its squad
            adjustThrust(Obj, dt)
            fireWeapons(Obj, dt)
        else
            local guid = Obj.fixture:getUserData()
            local x, y = Obj.body:getLinearVelocity()
            -- print("This is a bullet: " .. guid, x, y )
        end
    end
end

return unitai

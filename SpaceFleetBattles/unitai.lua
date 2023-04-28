unitai = {}

local function getClosestObject(thisObj, desiredforf)
    -- returns zero if none found
    local closestdist = 999999999       -- ridiculously large
    local closestid = 0
    local thisobjx, thisobjy = thisObj.body:getPosition()       -- BOX2D_SCALE

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
    return closestid
end

local function updateUnitTask(Obj, squadorder, dt)
    -- this adjusts targets or other goals based on the squad order

    Obj.taskCooldown = Obj.taskCooldown - dt
    -- print("Task cooldown:" .. cf.round(Obj.taskCooldown,1)
    if Obj.taskCooldown <= 0 then
        Obj.taskCooldown = 5

        --! get a new task
        if squadorder == enum.squadOrdersEngage then
            -- get closest target
            local targetid
            if Obj.forf == enum.forfFriend then
                targetid = getClosestObject(Obj, enum.forfEnemy)
            end
            if Obj.forf == enum.forfEnemy then
                targetid = getClosestObject(Obj, enum.forfFriend)
            end
            if targetid > 0 then
                Obj.targetid = targetid         -- this is same as OBJECTS[targetid]
            end
        else
            --! no squad order or unexpected squad order
        end
    end
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
    if Obj.targetid == nil or Obj.targetid  == 0 then
        -- nothing
    else
        local x1, y1 = Obj.body:getPosition()       -- BOX2D_SCALE
        if OBJECTS[Obj.targetid] ~= nil then
            local x2, y2 = OBJECTS[Obj.targetid].body:getPosition()

            local force = 1
            local currentangle = Obj.body:getAngle()            -- rads

            assert(currentangle <= math.pi * 2)
            assert(currentangle >= math.pi * -2)

            local bearing = cf.getBearingRad(x1, y1, x2, y2)        -- this is absolute bearing in radians, starting from north

            local bearingdelta = bearing - currentangle

            -- print(currentangle, bearing, bearingdelta)

            if bearingdelta < -0.1 or bearingdelta > 0.1 then         -- rads
                if bearingdelta > 0 then
                    -- turn right
                    force = 1
                    -- print(str .. " right", angledelta)
                else
                    -- turn left
                    force = -1
                    -- print(str .. " left", angledelta)
                end
            else
                Obj.body:setAngularVelocity(0)
            end
            force = force * 5
            Obj.body:applyAngularImpulse( force  )
        end
    end
end

local function adjustThrust(Obj, dt)
    -- move forward
    -- this shouldn't be called for bullets
    assert(Obj.squadCallsign ~= nil)        -- bullets should not be sent to this function
    assert(Obj.body:isBullet() == false)

    local currentangle = Obj.body:getAngle( )
    if Obj.targetid ~= nil then
        if Obj.currentForwardThrust < Obj.maxForwardThrust then
            Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.maxAcceleration * dt)
            if Obj.currentForwardThrust > Obj.maxForwardThrust then Obj.currentForwardThrust = Obj.maxForwardThrust end
        end
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

    -- thisobject.body:setLinearVelocity(math.cos(currentangle) * 1000, math.sin(currentangle) * 1000)
    thisobject.body:setLinearVelocity(velx * 3, vely * 3)

    table.insert(OBJECTS, thisobject)

    local x, y = thisobject.body:getLinearVelocity()
    print("Velocity for " .. guid .. " is now " .. x, y)
end

local function fireWeapons(Obj, dt)
    -- fire weapons for this single Obj (if available)

    Obj.weaponcooldown = Obj.weaponcooldown - dt
    if Obj.weaponcooldown <= 0 then
        Obj.weaponcooldown = 0

        if Obj.targetid ~= nil then
            if OBJECTS[Obj.targetid] ~= nil then
                local objx = Obj.body:getX()
                local objy = Obj.body:getY()
                local targetx = OBJECTS[Obj.targetid].body:getX()
                local targety = OBJECTS[Obj.targetid].body:getY()


                local currentangle = Obj.body:getAngle()
                local bearingtotarget = cf.getBearingRad(objx,objy,targetx,targety)
                local angletotarget = bearingtotarget - currentangle
                -- print(currentangle, bearingtotarget, angletotarget)

                if angletotarget > -0.13 and angletotarget < 0.13 then
                    Obj.weaponcooldown = 4
                    createNewBullet(Obj, true)       -- includes missiles and bombs. Use TRUE for fast moving bullets
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

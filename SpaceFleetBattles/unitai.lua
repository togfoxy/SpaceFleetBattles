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
            local targetid = getClosestObject(Obj, enum.forfEnemy)
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

    local bearingrad
    if Obj.targetid == nil or Obj.targetid  == 0 then
        -- nothing
    else
        local x1, y1 = Obj.body:getPosition()       -- BOX2D_SCALE
        local x2, y2 = OBJECTS[Obj.targetid].body:getPosition()
        local bearing = cf.getBearing(x1,y1,x2,y2)         -- in degrees from north
        local adjustedbearing = bearing - 90
        bearingrad = math.rad(adjustedbearing)      -- rads
        Obj.preferredAngle = bearingrad     -- rads

        local currentangle = Obj.body:getAngle()            -- rads
        local angledelta = bearingrad - currentangle        -- a neg value means 'left' of east facing

        while angledelta > (2*math.pi) do
            angledelta = angledelta - (2*math.pi)
        end
        while angledelta < (-2*math.pi) do
            angledelta = angledelta - (-2*math.pi)
        end

        local force = 0

        local objguid = Obj.fixture:getUserData()
        local str = Obj.squadCallsign .. "-" .. string.sub(objguid, -2)

        str = str .. " target: " .. string.sub( OBJECTS[Obj.targetid].fixture:getUserData() , -2)

        if math.abs(angledelta) > 0.0349 then
            -- turn towards target
            if angledelta < math.pi and angledelta > 0 then
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

local function adjustThrust(Obj, dt)
    -- -- move forward
    if Obj.targetid ~= nil then
        Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.maxAcceleration * dt)
        if Obj.currentForwardThrust > Obj.maxForwardThrust then Obj.currentForwardThrust = Obj.maxForwardThrust end
    else
        Obj.currentForwardThrust = Obj.currentForwardThrust - (Obj.maxAcceleration * dt)
        if Obj.currentForwardThrust < 0 then Obj.currentForwardThrust = 0 end
    end

    local currentangle = Obj.body:getAngle( )
    Obj.body:setLinearVelocity(math.cos(currentangle) * Obj.currentForwardThrust, math.sin(currentangle) * Obj.currentForwardThrust)
end

function unitai.update(squadAI, dt)
    -- update all units in OBJECTS based on the AI above them
    -- update the unit based on orders broadcasted in squadAI

    local squadorder
    for k, Obj in pairs(OBJECTS) do
        local callsign = Obj.squadCallsign

        if #squadAI[callsign].orders == 0 then
            squadorder = nil

        else
            squadorder = squadAI[callsign].orders[1].order
        end

        updateUnitTask(Obj, squadorder, dt)     -- choose targets etc based on the current squad order
        adjustAngle(Obj, dt)         -- send the object and the order for its squad
        adjustThrust(Obj, dt)
    end
end

return unitai

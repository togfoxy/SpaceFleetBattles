unitai = {}

function unitai.clearTarget(deadtargetguid)
    -- move through all objects and clear target guid if target guid = input parameter
    -- use this to remove targets from other craft if a target is destroyed
    -- input: deadtargetguid = guid of the target that is dead
    for k, Obj in pairs(OBJECTS) do
        if Obj.actions ~= nil then
            for j, action in pairs(Obj.actions) do
                if action.targetguid == deadtargetguid then
                    action.cooldown = 0
                end
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
    local thisaction = {}
	thisaction.cooldown = 10
	thisaction.action = enum.unitActionReturningToBase
	thisaction.targetguid = nil
    if Obj.forf == enum.forfFriend then
        thisaction.destx = FRIEND_START_X
    elseif Obj.forf == enum.forfEnemy then
        thisaction.destx = FOE_START_X
    end

    -- set a y value that is insider the boundary
    local y = Obj.body:getY()
    if y < 0 then
        y = 100
    elseif y > SCREEN_HEIGHT then
        y = SCREEN_HEIGHT - 100
    end
    thisaction.desty = y
	table.insert(Obj.actions, thisaction)
    print("Setting action to RTB")
end

local function setTaskDestination(Obj, x, y)
	-- set Obj's task to move to the given x/y location

	local thisaction = {}
	thisaction.cooldown = 5
	thisaction.action = enum.unitActionMoveToDest
	thisaction.targetguid = nil
	thisaction.destx = x
	thisaction.desty = y
	table.insert(Obj.actions, thisaction)
    print("Setting action to provided destination")
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

    local txt = ""
    -- get current facing in radians relative to east, round to 2 dec places
    local currentangle = Obj.body:getAngle()            -- rads
    adjcurrentangle = currentangle
    if currentangle < 0 then adjcurrentangle = (math.pi * 2) + currentangle end
    adjcurrentangle = cf.round(adjcurrentangle,2)

    -- get the desired facing in radians realtive to east, round to 2 dec places
    local bearing = cf.getBearingRad(Obj.body:getX(), Obj.body:getY(), destx, desty)        -- this is absolute bearing in radians, starting from east
    local adjbearing = bearing
    if bearing < 0 then adjbearing = (math.pi * 2) + bearing end
    adjbearing = cf.round(adjbearing,2)

    -- if desired facing > current facing then turn right
    local force = 0
    if adjbearing > adjcurrentangle and (adjbearing - adjcurrentangle < (math.pi)) then
        txt = ("Adjcurrentangle is " .. adjcurrentangle .. " and adjbearing is " .. adjbearing .. " so turning right")
        force = love.math.random(9,11) / 10         -- force a small wiggle
    elseif adjbearing > adjcurrentangle and (adjbearing - adjcurrentangle >= (math.pi)) then
        txt = ("Angle is " .. adjcurrentangle .. " and adjbearing is " .. adjbearing .. " so turning left")
        force = (love.math.random(9,11) / 10) * -1         -- force a small wiggle
    elseif adjbearing < adjcurrentangle and (adjcurrentangle - adjbearing < math.pi) then
        txt = ("Angle is " .. adjcurrentangle .. " and adjbearing is " .. adjbearing .. " so turning left")
        force = (love.math.random(9,11) / 10) * -1         -- force a small wiggle
    elseif adjbearing < adjcurrentangle and (adjcurrentangle - adjbearing >= math.pi) then
        txt = ("Adjcurrentangle is " .. adjcurrentangle .. " and adjbearing is " .. adjbearing .. " so turning right")
        force = love.math.random(9,11) / 10         -- force a small wiggle
    elseif adjcurrentangle == adjbearing then
        -- txt = "Angle is perfect. Not turning"
        force = 0
        -- apply a small random number to force wiggle and no ship ever goes truely straight
        force = love.math.random(0, 5) / 100
    else
        txt = "Unknown code flow. current/desired angle: " .. adjcurrentangle .. " / " .. adjbearing
        print(txt)
        error()
    end
    force = 80 * force * Obj.currentSideThrust * dt         -- the constant is an arbitrary value to make turning cool

    Obj.body:setAngularVelocity(force)

    if Obj.guid == PLAYER_GUID and txt ~= "" then
        -- print("Message: " .. txt)
    end
end

local function adjustAngle(Obj, dt)

    assert(Obj.body:isBullet() == false)

    while Obj.body:getAngle() > (math.pi * 2) do
        -- print("Angle was: " .. Obj.body:getAngle())
        Obj.body:setAngle(Obj.body:getAngle() - (math.pi * 2))
        -- print("Angle now: " .. Obj.body:getAngle())
    end
    while Obj.body:getAngle() < (math.pi * - 2) do
        -- print("Angle was: " .. Obj.body:getAngle())
        Obj.body:setAngle(Obj.body:getAngle() + (math.pi * 2))
        -- print("Angle now: " .. Obj.body:getAngle())
    end

    local bearingrad

    -- turn to destination if one exists
    if Obj.actions[1] ~= nil and Obj.actions[1].destx ~= nil then
        -- move to destination
        local objx, objy = Obj.body:getPosition()
        local destx = Obj.actions[1].destx
        local desty = Obj.actions[1].desty
        local disttodest = cf.getDistance(objx, objy, destx, desty)
        if disttodest < 20 then
            -- arrived at destination. Remove the top action
			Obj.actions[1] = nil
        else
            turnToObjective(Obj, destx, desty, dt)
        end

    -- turn to target if one exists
    elseif Obj.actions[1] ~= nil and Obj.actions[1].targetguid ~= nil then
        local x1, y1 = Obj.body:getPosition()           --! can refactor this code
        local enemyobject = fun.getObject(Obj.actions[1].targetguid)
        if enemyobject == nil or enemyobject.body:isDestroyed() then
            -- somehow, the target is no longer legitimate
            Obj.actions[1].cooldown = 0
        else
            local x2, y2 = enemyobject.body:getPosition()
            turnToObjective(Obj, x2, y2, dt)
        end
    else
        -- this can happen when the object is a pod.
        -- print("Unit has no action therefore no angle")
    end
end


local function adjustThrustEngaging2(Obj, dt)

	local targetObj = fun.getObject(Obj.actions[1].targetguid)
	if targetObj == nil or not isFighter(targetObj) then
		-- abort
	else
		local objfacing = Obj.body:getAngle()
		local minheading = objfacing - 0.7853			-- 0.7 rads = 45 deg		-- should probably make these constants
		local maxheading = objfacing + 0.7853
		local targetfacing = targetObj.body:getAngle()
		
		local objx, objy = Obj.body:getPosition()
		local targetx, targety = targetObj.body:getPosition()
		
		local dist = cf.getDistance(objx, objy, targetx, targety)
		if (targetfacing >= minheading and targetfacing <= maxheading) and
			targetObj.currentForwardThrust < Obj.currentForwardThrust and
			dist <= 125 then
			
			-- set pilot thrust to target thrust
			Obj.currentForwardThrust = Obj.currentForwardThrust - (Obj.maxDeacceleration * dt)
			if Obj.currentForwardThrust < targetObj.currentForwardThrust then
				Obj.currentForwardThrust = targetObj.currentForwardThrust
			end
		else
			-- move to full speed
			Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)      
		end
	end
	
	-- ensuring thrust is not above max is checked in the parent function
end
			
-- local function adjustThrustEngaging(Obj, dt)

    -- local objx, objy = Obj.body:getPosition()
    -- local objfacing = Obj.body:getAngle()
    -- local targetObj = fun.getObject(Obj.actions[1].targetguid)
    -- if targetObj ~= nil and isFighter(targetObj) then
        -- -- print("alpha")
        -- local targetx, targety = targetObj.body:getPosition()

        -- if cf.isInFront(objx, objy, objfacing, targetx, targety) then
            -- -- print("beta")
            -- if targetObj.currentForwardThrust < Obj.currentForwardThrust then		-- is target moving slower than pilot?
                -- -- print("charlie")
                -- local dist = cf.getDistance(objx, objy, targetx, targety)
                -- if dist <= 125 then
                    -- -- print("delta")
                    -- -- try to match speed if unit is behind target
                    -- local minheading = objfacing - 0.7853			-- 0.7 rads = 45 deg		-- should probably make these constants
                    -- local maxheading = objfacing + 0.7853
                    -- local targetfacing = targetObj.body:getAngle()

                    -- if targetfacing >= minheading and targetfacing <= maxheading then		--! check that the min/max thing converts to radians properly
                        -- -- unit is behind the target. Try to match speed
                        -- Obj.currentForwardThrust = Obj.currentForwardThrust - (Obj.maxDeacceleration * dt)
                        -- if Obj.currentForwardThrust < targetObj.currentForwardThrust then
                            -- -- print("echo")
                            -- Obj.currentForwardThrust = targetObj.currentForwardThrust * (love.math.random(7,9) / 10)
                        -- end
                    -- else
                        -- -- unit is not behind target so max thrust
                        -- Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)      
						-- --! should refactor all this
                    -- end
                -- else
                    -- -- print("foxtrot")
                    -- -- max thrust needed
                    -- Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
                -- end
            -- else
                -- -- print("golf")
                -- -- max throttle
                -- Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
            -- end
        -- else
            -- -- target is not in front or target is not a fighter. Assume full thrust is needed
            -- -- print("Target is not in front so using full thrust.", objx, objy, objfacing, targetx, targety)
            -- Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
        -- end
    -- else
        -- print("Engaging but no target. Killing current action")
        -- Obj.actions[1].cooldown = 0
    -- end
-- end

local function adjustThrust(Obj, dt)
    -- move forward
    -- this shouldn't be called for bullets
    assert(Obj.squadCallsign ~= nil)        -- bullets should not be sent to this function
    assert(Obj.body:isBullet() == false)

    local currentangle = Obj.body:getAngle()
    if Obj.actions[1] ~= nil then
        local destx = Obj.actions[1].destx
        local desty = Obj.actions[1].desty

        if Obj.actions[1].action == enum.unitActionEngaging then
            adjustThrustEngaging2(Obj, dt)
        elseif destx ~= nil then
    		local objx, objy = Obj.body:getPosition()
    		local disttodest = cf.getDistance(objx, objy, destx, desty)
    		if disttodest > 10 then
    			Obj.currentForwardThrust = Obj.currentForwardThrust + (Obj.currentMaxAcceleration * dt)
    		else
                Obj.actions[1].cooldown = 0
    		end
        else
            print(inspect(Obj))
            error("Seems to have no orders. Might be okay.")
        end
    else
        -- no orders. Slow down and stop
        -- print("No task for this unit. Will slow and stop")
        Obj.currentForwardThrust = Obj.currentForwardThrust - (Obj.maxDeacceleration * dt)  -- might be zero for bullets
    end

    if Obj.currentForwardThrust > Obj.currentMaxForwardThrust then Obj.currentForwardThrust = Obj.currentMaxForwardThrust end
    if Obj.currentForwardThrust < 0 then Obj.currentForwardThrust = 0 end

    Obj.body:setLinearVelocity(math.cos(currentangle) * Obj.currentForwardThrust, math.sin(currentangle) * Obj.currentForwardThrust)
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
    thisobject.forf = Obj.forf
    if Obj.forf == enum.forfFriend then
        thisobject.fixture:setCategory(enum.categoryFriendlyBullet)
        thisobject.fixture:setMask(enum.categoryFriendlyBullet, enum.categoryEnemyBullet, enum.categoryFriendlyFighter)
    else
        thisobject.fixture:setCategory(enum.categoryEnemyBullet)
        thisobject.fixture:setMask(enum.categoryFriendlyBullet, enum.categoryEnemyBullet, enum.categoryEnemyFighter)
    end
    local guid = cf.getGUID()
    thisobject.fixture:setUserData(guid)
    thisobject.guid = guid

    thisobject.squadCallsign = nil
    thisobject.lifetime = 10            -- seconds
    thisobject.ownerObjectguid = Obj.guid

    thisobject.body:setAngle(currentangle)
    thisobject.body:setLinearVelocity(math.cos(currentangle) * 300, math.sin(currentangle) * 300)

    -- print("Adding bullet to OBJECTS: " .. thisobject.guid)
    table.insert(OBJECTS, thisobject)
end

local function fireWeapons(Obj, dt)
    -- check if unit should fire weapons and then create bullet object if so
    Obj.weaponcooldown = Obj.weaponcooldown - dt
    if Obj.weaponcooldown <= 0 then
        Obj.weaponcooldown = 0

        if Obj.componentHealth[enum.componentWeapon] > 0 then
            if Obj.actions ~= nil and Obj.actions[1] ~= nil and Obj.actions[1].targetguid ~= nil then
                local enemyobject = fun.getObject(Obj.actions[1].targetguid)
                if enemyobject ~= nil and not enemyobject.body:isDestroyed() then        -- check if target is dead
                    local objx = Obj.body:getX()
                    local objy = Obj.body:getY()
                    local targetx = enemyobject.body:getX()
                    local targety = enemyobject.body:getY()

                    local currentangle = (Obj.body:getAngle())
                    if currentangle < 0 then currentangle = currentangle + (math.pi * 2) end
                    local bearingtotarget = (cf.getBearingRad(objx,objy,targetx,targety))
                    if bearingtotarget < 0 then bearingtotarget = bearingtotarget + (math.pi * 2) end

                    local angletotarget = bearingtotarget - currentangle
                    if angletotarget < (math.pi * -2) then angletotarget = angletotarget + (math.pi * 2) end

                    if angletotarget > -0.07 and angletotarget < 0.07 then
                        Obj.weaponcooldown = 4
                        createNewBullet(Obj, true)       -- includes missiles and bombs. Use TRUE for fast moving bullets
                    else
                        -- print(currentangle, bearingtotarget, angletotarget)
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

local function checkForRTB(Obj)
    local topaction = fun.getTopAction(Obj)
    if topaction ~= nil and topaction.action == enum.unitActionReturningToBase then
        if Obj.forf == enum.forfFriend then
            if Obj.body:getX() <= FRIEND_START_X then
                -- rtb success
                print("RTB succeed. Destroying object")
                Obj.lifetime = 0                        -- destroy the object
            end
        elseif Obj.forf == enum.forfEnemy then
            if Obj.body:getX() >= FOE_START_X then
                print("RTB succeed. Destroying object")
                Obj.lifetime = 0                        -- destroy the object
            end
        else
            error()
        end
    end
end

local function updateUnitTask(Obj, squadorder, dt)
    -- this adjusts targets or other goals based on the squad order

    assert(Obj ~= nil)
	
    if Obj.actions[1] ~= nil then
        Obj.actions[1].cooldown = Obj.actions[1].cooldown - dt
        if Obj.actions[1].cooldown <= 0 then
            table.remove(Obj.actions, 1)
        end
    end

    -- if #Obj.actions <= 0 then
	if Obj.actions[1] == nil then
        -- try to find a new action

        local unitIsTargeted = fun.unitIsTargeted(Obj.guid)
        local toporder = fun.getTopAction(Obj)
        local targetguid
        if toporder ~= nil then
            targetguid = toporder.targetguid
        end

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
        end

        if #Obj.actions <= 0 then
    		-- after the self-preservation bits, take direction from current squad orders
            if squadorder == enum.squadOrdersEngage then
                local targetguid
                if Obj.forf == enum.forfFriend then
                    targetguid = getClosestFighter(Obj, enum.forfEnemy)        -- this OBJECTS guid or nil
                end
                if Obj.forf == enum.forfEnemy then
                    targetguid = getClosestFighter(Obj, enum.forfFriend)       -- this OBJECTS guid or nil
                end
                if targetguid ~= nil then
                    local thisorder = {}
                    thisorder.action = enum.unitActionEngaging
                    thisorder.cooldown = 5
                    thisorder.destx = nil
                    thisorder.desty = nil
                    thisorder.targetguid = targetguid
                    table.insert(Obj.actions, thisorder)
                    -- print("Setting action = engage")
                else
                    -- trying to engage but no target found.
                    if not unitIsTargeted and Obj.body:getY() < 0 and targetguid == nil then
                        -- move back inside the battle map
                        setTaskDestination(Obj, Obj.body:getX(), 100)
                    elseif not unitIsTargeted and Obj.body:getY() > SCREEN_HEIGHT and targetguid == nil then
                        -- move back inside the battle map
                        setTaskDestination(Obj, Obj.body:getX(), SCREEN_HEIGHT - 100)
                    else
                        -- no target found and still inside map. Allow code to fall through to RTB
                    end
                    print("Stacking orders: return to battle and RTB")
                    setTaskRTB(Obj)     -- this is an instance of stacking orders
                end
            elseif squadorder == enum.squadOrdersReturnToBase then
                    setTaskRTB(Obj)
                -- print("Unit task: RTB")
            else
                --! no squad order or unexpected squad order
                Obj.actions[1] = nil
                print("No squad order available for this unit")
            end
        end
    end
end

function unitai.update(dt)
    -- update all units in OBJECTS based on the AI above them
    -- update the unit based on orders broadcasted in squadAI

    local squadorder
    for k = #OBJECTS, 1, -1 do          --! this backwards thing is unnecessary
        Obj = OBJECTS[k]
        local callsign = Obj.squadCallsign
        local objcategory = Obj.fixture:getCategory()

        -- is this object a fighter?
        if objcategory == enum.categoryEnemyFighter or objcategory == enum.categoryFriendlyFighter then
            assert(Obj.body:isBullet() == false)
            if squadAI[callsign] == nil or #squadAI[callsign].orders == 0 then
                squadorder = nil
                print("Unit detecting squad has no order")
            else
                squadorder = squadAI[callsign].orders[1].order
            end
            updateUnitTask(Obj, squadorder, dt)     -- choose targets etc based on the current squad order
            adjustAngle(Obj, dt)         -- send the object and the order for its squad
            adjustThrust(Obj, dt)
            fireWeapons(Obj, dt)
            checkForRTB(Obj)
        elseif objcategory == enum.categoryEnemyPod or objcategory == enum.categoryFriendlyPod then
            updatePod(Obj)
            checkForRTB(Obj)
        else
            -- must be a bullet. Do nothing
        end
    end
    --! debugging only
    -- if OBJECTS[1].actions ~= nil then
    --     if OBJECTS[1].actions[1].targetguid ~= nil then
    --         local targetguid = OBJECTS[1].actions[1].targetguid
    --         local targetObj = fun.getObject(targetguid)
    --         if targetObj == nil then
    --             OBJECTS[1].actions[1].cooldown = 0
    --         else
    --             local cat = targetObj.fixture:getCategory()
    --             -- print("Object 1 target type = " .. cat)
    --         end
    --     end
    -- end
end

return unitai
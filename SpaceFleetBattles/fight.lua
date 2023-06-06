fight = {}

local pause = false
local snapcamera = true
local showmenu = false
local showcallsigns = false
local cameraindex = nil				-- which fighter has the cameras' focus
local timefactor = 1


local function createEscapePod(Obj)
    -- Obj is the obj that is spawning/creating the pod. It assumed this Obj will soon be destroyed

    local thisobject = {}
    thisobject.body = love.physics.newBody(PHYSICSWORLD, Obj.podx, Obj.pody, "dynamic")
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

    local guid
    if Obj.guid == PLAYER_FIGHTER_GUID then
        guid = PLAYER_FIGHTER_GUID      -- POD inherits player fighter guid
    else
        guid = cf.getGUID()             -- assigning a new guid effectively destroys the fighter from objects
    end
	thisobject.fixture:setUserData(guid)
    thisobject.guid = guid
    assert(thisobject.guid ~= nil)

    thisobject.forf = Obj.forf
    thisobject.squadCallsign = Obj.squadcallsign

    thisobject.weaponcooldown = 0           -- might be more than one weapon in the future

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

    thisobject.actions = {}         -- this will be influenced by squad orders + player choices
    thisobject.actions[1] = {}
    thisobject.actions[1].action = enum.unitActionReturningToBase
    thisobject.actions[1].targetguid = nil

    if thisobject.forf == enum.forfFriend then
        thisobject.actions[1].destx = FRIEND_START_X
    elseif thisobject.forf == enum.forfEnemy then
        thisobject.actions[1].destx = FOE_START_X
    end
    thisobject.actions[1].desty = Obj.pody

    -- print("Adding pod to OBJECTS: " .. thisobject.guid)
    table.insert(OBJECTS, thisobject)
    print("Pod guid created: " .. guid)
end

local function destroyObjects(dt)

    for i = #OBJECTS, 1, -1 do
        if OBJECTS[i].lifetime ~= nil then
            OBJECTS[i].lifetime = OBJECTS[i].lifetime - dt
            if OBJECTS[i].lifetime <= 0 then

                if OBJECTS[i].body:isDestroyed() then
                    -- do nothing
                else
                    if OBJECTS[i].fixture:getCategory() == enum.categoryEnemyBullet or OBJECTS[i].fixture:getCategory() == enum.categoryFriendlyBullet then
                        fun.createAnimation(OBJECTS[i], enum.animBulletSmoke)
                    end
                    OBJECTS[i].fixture:destroy()
                    OBJECTS[i].body:destroy()
                end
                table.remove(OBJECTS, i)
            end
        end
    end
end

local function isPlayerFighterOnBattlefield()
    -- scans OBJECT table for player guid
    for i = 1, #OBJECTS do
        if OBJECTS[i].guid == PLAYER_FIGHTER_GUID then
            return true
        end
    end
    return false
end

local function isPlayerFighterAlive()
    -- this returns true if the players fighter is in the hanger

    for i = 1, #HANGER do
        if HANGER[i].guid == PLAYER_FIGHTER_GUID then
            return true
        end
    end
    return false
end

local function battleOver()
    local isFriends = false
    local isFoes = false

    if BATTLE_TIMER <= 8 then
        return false
    end

    for i = 1, #OBJECTS do
        if OBJECTS[i].forf == enum.forfFriend then
            isFriends = true
        end
        if OBJECTS[i].forf == enum.forfEnemy then
            isFoes = true
        end
    end
    if isFriends == false or isFoes == false then
        -- one side is depleted
        return true
    else
        return false
    end
end

local function updateDamageText(dt)
	for i = #DAMAGETEXT, 1, -1 do
		DAMAGETEXT[i].timeleft = DAMAGETEXT[i].timeleft - dt
		if DAMAGETEXT[i].timeleft <= 0 then table.remove(DAMAGETEXT, i) end
	end
end

local function spawnPods()
    for i = #POD_QUEUE, 1, -1 do
        createEscapePod(POD_QUEUE[i])       -- send the object into this function so it can spawn a pod
        table.remove(POD_QUEUE, i)
    end
end

local function getImpactedComponent(Obj)

    local totalsize = 0
    for i = 1, #Obj.componentSize do
        totalsize = totalsize + Obj.componentSize[i]
    end
    local rndnum = love.math.random(1, totalsize)
    local tempvalue = totalsize
    for k, v in pairs(Obj.componentSize) do
        -- print(k, v)
        rndnum = rndnum - v
        if rndnum <= 0 then return k end
    end
    error()     -- should not reach this point
end

local function giveKillCredit(bullet)
    -- give kill credit to the pilot
    local vesselguid = bullet.ownerObjectguid           -- this is the vessel that shot the bullet
    local vesselobj = fun.getObject(vesselguid)
    local pilotguid = vesselobj.pilotguid

    local shooter = fun.getPilot(pilotguid)
    if shooter ~= nil then
        shooter.kills = shooter.kills + 1
    else
        -- shooter = nil for some reason. Print debug if bullet is friendly
        if bullet.forf == enum.forfFriend then
            print("********************")
            print(inspect(ROSTER))
            print(inspect(bullet))
            print(shooterguid)
            print(inspect(shooter))
            error()
        end
    end
end

local function destroyVictim(victim, bullet)

	fun.createAnimation(victim, enum.animExplosion)
	if victim.forf == enum.forfFriend then
		SCORE.friendsdead = SCORE.friendsdead + 1
		FOE_FIGHTER_COUNT = FOE_FIGHTER_COUNT - 1
		FOE_PILOT_COUNT = FOE_PILOT_COUNT - 1
	elseif victim.forf == enum.forfEnemy then
		SCORE.enemiesdead = SCORE.enemiesdead + 1
	end
	victim.lifetime = 0
	unitai.clearTarget(victim.guid)		-- remove this guid from everyone's target
	print("Unit exploded")

	--! play explosion sound here

	-- give kill credit
	giveKillCredit(bullet)

	-- remove friendly pilots from roster by marking isDead
	local pilotguid = victim.pilotguid                         --! is sometimes nil. Not sure how. Foe escape pod?
	local pilotobj = fun.getPilot(pilotguid)
	if pilotobj ~= nil then pilotobj.isDead = true end

    if PLAYER_GUID ~= nil and PLAYER_GUID == pilotguid then     --! not sure how PLAYER_GUID can ever be nil.
        pilotobj.isPlayer = false       --! check for unintended consequences
    end

	-- remove fighter from hanger
	for i = #HANGER, 1, -1 do
		if HANGER[i].guid == victim.guid then
			table.remove(HANGER, i)
		end
	end
end

local function checkForTrauma(victim)
	if victim.componentHealth[enum.componentWeapon] <= 0 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentThruster] <= 50 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentSideThruster] <= 50 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentAccelerator] <= 25 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentStructure] <= 33 then
		victim.actions = {}         -- significant trauma. get a new task
	end
end

local function addEvadeAction(victim)
	-- insert an action at the TOP of the queue

	local thisaction = {}
	if victim.forf == enum.forfFriend then
		-- set a destination random degrees from current location
		local objx, objy = victim.body:getPosition()
		local rndangle = love.math.random(-45, 45)
		local destx, desty = cf.addVectorToPoint(objx,objy,(270 + rndangle),300)

		thisaction.cooldown = 3
		thisaction.action = enum.unitActionMoveToDest
		thisaction.targetguid = nil							--! maybe not clear target when evading
		thisaction.destx = destx
		thisaction.desty = desty
	elseif victim.forf == enum.forfEnemy then
		local destx = FOE_START_X
		local desty = love.math.random(0, SCREEN_HEIGHT)

		thisaction.cooldown = 3
		thisaction.action = enum.unitActionMoveToDest
		thisaction.targetguid = nil							--! maybe not clear target when evading
		thisaction.destx = destx
		thisaction.desty = desty
	end

	table.insert(victim.actions, 1, thisaction)
	-- print("Evasive force applied")
end

local function createDamageText(componenthit, victim)
	local txt = ""
	if componenthit == enum.componentAccelerator then
		txt = "Throttle"
	elseif componenthit == enum.componentSideThruster then
		txt = "Steering"
	elseif componenthit == enum.componentStructure then
		txt = "Structure"
	elseif componenthit == enum.componentThruster then
		txt = "Thrusters"
	elseif componenthit == enum.componentWeapon then
		txt = "Weapon"
	else
		error()
	end

	local thistext = {}
	thistext.text = txt
	thistext.object = victim
	thistext.timeleft = 4			-- how many seconds to display
	table.insert(DAMAGETEXT, thistext)
    -- print(inspect(DAMAGETEXT))
    -- print("*******************")
end

function fight.applyDamage(victim, bullet)

    local componenthit = getImpactedComponent(victim)
    victim.componentHealth[componenthit] = victim.componentHealth[componenthit] - love.math.random(15, 35)
    if victim.componentHealth[componenthit] < 0 then victim.componentHealth[componenthit] = 0 end

	if victim.componentHealth[enum.componentStructure] <= 0 then
		-- boom. Victim is dead
		destroyVictim(victim, bullet)
    else
        -- victim not dead so attach a smoke animation to the object
        fun.createAnimation(victim, enum.animSmoke)

        -- play audio
        if isPlayerFighterAlive() and bullet.ownerObjectguid == PLAYER_FIGHTER_GUID then
            -- this bullet is the players bullet. Make an audible
            cf.playAudio(enum.audioBulletHit, false, true)
        else
            -- print(bullet.ownerObjectguid, PLAYER_FIGHTER_GUID)
        end

		-- see if ejects
		local rndnum = love.math.random(1, 35)	-- ejection is a dice roll
		if victim.componentHealth[enum.componentStructure] <= 35 and rndnum > victim.componentHealth[enum.componentStructure] then
            if rndnum > victim.componentHealth[enum.componentStructure] then       -- more damage = more chance of eject
                fun.setTaskEject(victim)
                -- give kill credit
                giveKillCredit(bullet)

				if victim.forf == enum.forfFriend then
					SCORE.friendsEjected = SCORE.friendsEjected + 1
				elseif victim.forf == enum.forfEnemy then
					SCORE.enemiesEjected = SCORE.enemiesEjected + 1
				end
			end
		else	-- not dead and not ejecting
			-- prep component hit if victim = player or victim = player target
			if victim.guid == PLAYER_FIGHTER_GUID or bullet.ownerObjectguid == PLAYER_FIGHTER_GUID then
				createDamageText(componenthit, victim)
			end

			-- apply a small evasion wobble if trying to RTB
			local action = fun.getTopAction(victim)

			if action ~= nil and action.action == enum.unitActionReturningToBase then
				-- been hit while RTB. Try to evade.
				-- insert an action at the TOP of the queue
				addEvadeAction(victim)
			else
				-- not dead and not ejecting and not RTB
				-- Unit is still in the fight. Clear action queue if traumatic damage taken
				checkForTrauma(victim)
			end
		end

		-- adjust object performance after receiving battle damage
		victim.currentMaxForwardThrust = victim.maxForwardThrust * (victim.componentHealth[enum.componentThruster] / 100)
		victim.currentMaxAcceleration = victim.maxAcceleration * (victim.componentHealth[enum.componentAccelerator] / 100)
		victim.currentSideThrust = victim.maxSideThrust * (victim.componentHealth[enum.componentSideThruster] / 100)
	end
end

function fight.keyreleased(key, scancode)
    if key == "space" then pause = not pause end
    if key == "c" then snapcamera = not snapcamera end
	if key == "." then cameraindex = cameraindex + 1 end			-- this is > key
	if key == "," then cameraindex = cameraindex - 1 end			-- this is < key
	if key == "-" then timefactor = timefactor - 0.5 end			-- this is the '-' minus key
	if key == "=" then timefactor = timefactor + 0.5 end			-- this is the '+' plus key

	if key == "lctrl" or key == "rctrl" then
		showcallsigns = not showcallsigns
		snapcamera = true
	end

	if key == "escape" then
        if showmenu then
            showmenu = false
            pause = false
        else
            -- love.event.quit()
        end
    end

	if key == "c" then
		for i = 1, #OBJECTS do
			if OBJECTS[i].guid == PLAYER_FIGHTER_GUID then
				cameraindex = i
				snapcamera = true
				break
			end
		end
	end

	if cameraindex < 1 then cameraindex = #OBJECTS end
	if cameraindex > #OBJECTS then cameraindex = 1 end

	if timefactor < 1 then timefactor = 1 end
	if timefactor > 2 then timefactor = 2 end

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
	-- print("Zoom factor = " .. ZOOMFACTOR)
end

function fight.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(2) or love.mouse.isDown(3) then
        snapcamera = false
        TRANSLATEX = TRANSLATEX - dx
        TRANSLATEY = TRANSLATEY - dy
	else
		-- check for mouse over the player then display menu
		-- if isPlayerFighterAlive() then
        if isPlayerFighterOnBattlefield() then
            -- see if player unit is clicked
			local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
			local objcategory = Obj.fixture:getCategory()				-- need to check if this is a fighter or pod
            local objscreenx, objscreeny = cam:toScreen(Obj.body:getX(), Obj.body:getY()) -- need to convert physical to screen
            local dist = cf.getDistance(x, y, objscreenx, objscreeny)

            if dist <= 30 and objcategory == enum.categoryFriendlyFighter then
                -- player unit is moused over
                showmenu = true
                pause = true
            end
		else		-- player is dead. Hide menu
			showmenu = false
			pause = false
        end
    end
end

function fight.mousereleased(rx, ry, x, y, button)
    if button == 1 then
		-- menu appears during mouse over. This is to check if menu is clicked
		-- if isPlayerFighterAlive() then
        if isPlayerFighterOnBattlefield() then
            -- see if player unit is clicked

            -- I reckon all of this can be simplified
            local Obj = fun.getObject(PLAYER_FIGHTER_GUID)              -- get the hanger object with physics body
			-- local objcategory = Obj.fixture:getCategory()				-- need to check if this is a fighter or pod
            local objx, objy = Obj.body:getPosition()                   -- get the physics x/y
            local robjx, robjy = res.toGame(objx, objy)                 -- scale that to the current resolution
            local crobjx, crobjy = cam:toScreen(robjx, robjy)           -- convert that to the screen
            local xadj = (rx - crobjx) / ZOOMFACTOR                     -- do a diff and apply the zoom
            local yadj = (ry - crobjy) / ZOOMFACTOR

            local dist = cf.getDistance(rx, ry, crobjx, crobjy) / ZOOMFACTOR
            -- local dist = cf.getDistance(rx, ry, objx, objy) / ZOOMFACTOR     --! pretty sure this line can replace the one above it

            if dist > 250 then
                -- player unit is moused over
                showmenu = false
                pause = false
            end

            if xadj >= -5 and xadj <= 205 and yadj >= 40 and yadj <= 60 then
				-- engage has been clicked
				print("Engage!")
				Obj.actions = {}
				unitai.setTaskEngage(Obj, 15)			-- parameters = Obj and cooldown (defaults to 5 seconds if nil)
                showmenu = false
                pause = false
			elseif xadj >= -5 and xadj <= 205 and yadj >= 60 and yadj <= 80 then
				print("RTB")
				Obj.actions = {}
				unitai.setTaskRTB(Obj)
                showmenu = false
                pause = false
			elseif xadj >= -5 and xadj <= 205 and yadj >= 80 and yadj <= 100 then
				print("Eject!")
				Obj.actions = {}
				fun.setTaskEject(Obj)
                showmenu = false
                pause = false
			end
		end
    end
end

local function drawHUD()

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(IMAGE[enum.imageFightHUD], 0, 0)

    -- if isPlayerFighterAlive() then
    if isPlayerFighterOnBattlefield() then
        local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
        if Obj ~= nil then      -- this is a safety check
            local barlength = 100       -- unnecessary but a reminder that the barlength is a convenient 100 pixels
            local barheight = 10
            love.graphics.setColor(0,1,0,0.3)

            -- structure bar
            local drawlength = Obj.componentHealth[enum.componentStructure]
            love.graphics.rectangle("fill", 145, 47, drawlength, 10)

            -- thrusters bar
            local drawlength = Obj.componentHealth[enum.componentThruster]
            love.graphics.rectangle("fill", 145, 71, drawlength, 10)

            -- weapon bar
            local drawlength = Obj.componentHealth[enum.componentWeapon]
            love.graphics.rectangle("fill", 145, 95, drawlength, 10)

            -- Steering bar (side thrusters)
            local drawlength = Obj.componentHealth[enum.componentSideThruster]
            love.graphics.rectangle("fill", 145, 119, drawlength, 10)

            -- throttle bar (componentAccelerator)
            local drawlength = Obj.componentHealth[enum.componentAccelerator]
            love.graphics.rectangle("fill", 145, 143, drawlength, 10)
        end
    else
        -- print("Player not alive")
    end

    -- draw the battle timer
    local drawx = SCREEN_WIDTH - 150
    local drawy = 25
    local timeleft = cf.round(RTB_TIMER_LIMIT - RTB_TIMER)
    if timeleft > 30 then love.graphics.setColor(1,1,1,1) end
    if timeleft <= 30 and timeleft > 0 then love.graphics.setColor(1,1,0,1) end
    if timeleft <= 0 then love.graphics.setColor(1,0,0,1) end
    love.graphics.setFont(FONT[enum.fontalienEncounters48])
    love.graphics.print(timeleft, drawx, drawy)
    love.graphics.setFont(FONT[enum.fontDefault])
end

local function drawMenu()

	local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
    local drawx, drawy = Obj.body:getX(), Obj.body:getY()

	-- fill the menu box
	local menuwidth = 200
    local menuheight = 100
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.rectangle("fill", drawx, drawy, menuwidth, menuheight, 10, 10)

	-- draw an outline
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("line", drawx, drawy, menuwidth, menuheight, 10, 10)

	-- draw squad orders an a line
	local squadcallsign = Obj.squadCallsign
    local orderenum     -- might remain nil
    if squadAI[squadcallsign].orders ~= nil and squadAI[squadcallsign].orders[1] ~= nil then
        orderenum = squadAI[squadcallsign].orders[1].order
    end
	if orderenum == enum.squadOrdersEngage then
		txt = "Squad: engage"
	elseif orderenum == enum.squadOrdersReturnToBase then
		txt = "Squad: return to base"
	end
	love.graphics.setColor(0,0,0,1)
	love.graphics.print(txt, drawx + 5, drawy)
	love.graphics.setColor(1,1,1,1)
	love.graphics.line(drawx, drawy + 15, drawx + menuwidth, drawy + 15)

	-- draw current action and a line			--! this might be drawing a blank. Needs to be tested
	local actionenum = functions.getTopAction(Obj)

    -- print("indigo")
    -- print(inspect(actionenum))
    txt = ""
    if actionenum ~= nil then
    	if actionenum.action == enum.unitActionEngaging then
    		txt = "Currently: engaging"
    	elseif actionenum.action == enum.unitActionReturningToBase then
    		txt = "Currently: returning to base"
    	elseif actionenum.action == enum.unitActionEject then
    		txt = "Currently: ejecting!"
    	elseif actionenum.action == enum.unitActionReturningToBase then
    		txt = "Currently: moving to destination"
    	end
    	if txt ~= "" then
    		love.graphics.setColor(0,0,0,1)
    		love.graphics.print(txt, drawx + 5, drawy + 18)
    		love.graphics.setColor(1,1,1,1)
    		love.graphics.line(drawx, drawy + 36, drawx + menuwidth, drawy + 36)
    	end
    end

	-- draw the list of actions the player can issue
	love.graphics.setColor(0,0,0,1)
	txt = "New action: engage"
	love.graphics.print(txt, drawx + 5, drawy + 40)
	txt = "New action: return to base"
	love.graphics.print(txt, drawx + 5, drawy + 60)
	txt = "New action: eject!"
	love.graphics.print(txt, drawx + 5, drawy + 80)

    -- debugging menu
    -- love.graphics.setColor(1,0,0,1)
    -- local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
    -- local objx, objy = res.toGame(Obj.body:getX(), Obj.body:getY())
    -- love.graphics.rectangle("line", objx, objy + 36, 200, 20)
    -- love.graphics.rectangle("line", objx, objy + 56, 200, 20)
    -- love.graphics.rectangle("line", objx, objy + 76, 200, 20)
end

local function drawPhysicsObject(Obj)
	for _, fixture in pairs(Obj.body:getFixtures()) do

		local drawx = Obj.body:getX()
        local drawy = Obj.body:getY()

		local objtype = fixture:getCategory()           -- an enum
		if objtype == enum.categoryFriendlyPod or objtype == enum.categoryEnemyPod then
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(IMAGE[enum.imageEscapePod], drawx, drawy, 1.5707, 0.35, 0.35)      -- 1.57 radians = 90 degrees
		elseif objtype == enum.categoryFriendlyFighter then
			love.graphics.setColor(1,1,1,1)
			local angle = Obj.body:getAngle()           -- radians
			love.graphics.draw(IMAGE[enum.imageFighterFriend], drawx, drawy, angle, 0.15, 0.15, 76, 47)

			if Obj.guid == PLAYER_FIGHTER_GUID then
				-- draw recticle that shows player vessel
				love.graphics.draw(IMAGE[enum.imageCrosshairPlayer], drawx, drawy, 0, 0.75, 0.75, 35, 30)
			end
		elseif objtype == enum.categoryEnemyFighter then
			love.graphics.setColor(1,1,1,1)
			local angle = Obj.body:getAngle()           -- radians
			love.graphics.draw(IMAGE[enum.imageFighterFoe], drawx, drawy, angle, 0.10, 0.15, 115, 70)
		else
			local shape = fixture:getShape()
			if shape:typeOf("PolygonShape") then
				--
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

				if Obj.guid == PLAYER_FIGHTER_GUID then
					love.graphics.setColor(1,1,0,1)
				end

				love.graphics.polygon("fill", points)

			elseif shape:typeOf("CircleShape") then
				--
				local bodyx, bodyy = Obj.body:getWorldPoints(shape:getPoint())
				local radius = shape:getRadius()
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.circle("line", bodyx, bodyy, radius)
			else
				error()
			end
		end
	end
end

local function drawCallsign(Obj)
	if showcallsigns then
		local drawx = Obj.body:getX()
        local drawy = Obj.body:getY()
		if Obj.squadCallsign ~= nil then
            local str = ""
			-- local str = "CS: " .. Obj.squadCallsign .. "-" .. string.sub(Obj.guid, - 4)		-- this is squad callsign + guid
            -- str = str .. "\n"
			if Obj.forf == enum.forfFriend then
				-- get the pilots last name and add that to the callsign
				local pilotguid = Obj.pilotguid
				local pilot = fun.getPilot(pilotguid)
                str = str .. pilot.lastname
            else
                -- str = "CS: " .. Obj.squadCallsign .. "-" .. string.sub(Obj.guid, - 4)		-- this is squad callsign + guid
                str = str .. string.sub(Obj.guid, - 4)		-- this is squad callsign + guid
			end

			love.graphics.setColor(1,1,1,1)
			love.graphics.print(str, drawx, drawy, 0, 1, 1, -15, 30)

			-- draw a cool line next
			local x2, y2 = drawx + 30, drawy - 14
			love.graphics.setColor(1,1,1,1)
			love.graphics.line(drawx, drawy, x2, y2)
		else
            local category = Obj.fixture:getCategory()
            if category == enum.categoryEnemyFighter or category == enum.categoryFriendlyFighter then
                print("Category:" .. category)
                error()
            end
		end
	end
end

local function drawDamageText()

	love.graphics.setColor(1,1,1,1)
	for i = 1, #DAMAGETEXT do
        if DAMAGETEXT[i].object.body:isDestroyed() then
            -- nothing
        else
            local drawx = DAMAGETEXT[i].object.body:getX()
    		local drawy = DAMAGETEXT[i].object.body:getY()
    		drawy = drawy - (DAMAGETEXT[i].timeleft * -11) - 90		-- this creates a floating effect

    		love.graphics.print(DAMAGETEXT[i].text, drawx, drawy)
        end
	end
end

local function drawAnimations()
	-- draw animations
	love.graphics.setColor(1,1,1,1)
	for _, animation in pairs(ANIMATIONS) do
		local drawx, drawy = animation.drawx, animation.drawy

		if animation.type == enum.animExplosion then
			animation:draw(IMAGE[enum.imageExplosion], drawx, drawy, animation.angle, 1, 1, 0, 0)
		elseif animation.type == enum.animSmoke then
			-- different offset
			animation:draw(IMAGE[enum.imageExplosion], drawx, drawy, animation.angle, 1, 1, 10, 8)
		elseif animation.type == enum.animBulletSmoke then
			-- different offset
			animation:draw(IMAGE[enum.imageBulletSmoke], drawx, drawy, animation.angle, 0.5, 0.5, 10, 10)
		elseif animation.type == enum.animDebugging then
			animation:draw(IMAGE[enum.imageExplosion], drawx, drawy, animation.angle, 1, 1, 10, 8)
		end
	end
end

function fight.draw()

    drawHUD()       -- do this before the attach

    cam:attach()

	local playerfighter = fun.getObject(PLAYER_FIGHTER_GUID)

    -- draw BG
    love.graphics.setColor(1,1,1,0.25)
    love.graphics.draw(IMAGE[enum.imageFightBG], 0, 0, 0, 2.4, 0.90)

    -- draw the two start lines
    love.graphics.setColor(1,1,1,0.25)
    love.graphics.line(0,0, FRIEND_START_X, SCREEN_HEIGHT)
    love.graphics.line(FOE_START_X, 0, FOE_START_X, SCREEN_HEIGHT)

    -- draw each object
    for k, Obj in pairs(OBJECTS) do
        local objx = Obj.body:getX()
        local objy = Obj.body:getY()
        local drawx = objx
        local drawy = objy

        -- draw callsign first
		drawCallsign(Obj)

        -- draw the physics object
		drawPhysicsObject(Obj)

        -- print current action
        -- debug only
        if DEV_MODE then
            currentaction = fun.getTopAction(Obj)     -- receives an object
            if currentaction ~= nil then
                txt = currentaction.action
            else
                txt = "None"
            end
            local drawx, drawy = objx, objy
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(txt, drawx - 20, drawy + 10)
        end

        if false then       -- doing this so I can collapse this code
            -- draw velocity as text
            -- if not Obj.body:isBullet() then
            --     local vx, vy = Obj.body:getLinearVelocity()
            --     local vel = cf.getDistance(0, 0, vx, vy)    -- get distance of velocity vector
            --     vel = "v: " .. cf.round(vel, 0)             -- this is not the same as getLinearVelocity x/y because this is the 		distance between two points
            --     love.graphics.setColor(1,1,1,1)
            --     love.graphics.print(vel, drawx, drawy, 0, 1, 1, 30, 30)
            -- end

            -- draw the velocity indicator (purple line)
            -- local linx, liny = Obj.body:getLinearVelocity( )
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
    -- if isPlayerFighterAlive() then
    if isPlayerFighterOnBattlefield() then
        -- player still alive
        if playerfighter.actions ~= nil and playerfighter.actions[1] ~= nil then
            if playerfighter.actions[1].targetguid ~= nil then
                local targetguid = playerfighter.actions[1].targetguid
                local enemy = fun.getObject(targetguid)
                if enemy ~= nil and not enemy.body:isDestroyed() then
                    local drawx = enemy.body:getX()
                    local drawy = enemy.body:getY()

                    love.graphics.setColor(1,0,0,0.75)
                    -- love.graphics.circle("line", drawx, drawy, 10)
                    love.graphics.draw(IMAGE[enum.imageCrosshairsHasTarget], drawx, drawy, 0, 0.75, 0.75, 30, 30)
                end
            end
        end
    end

    -- draw yellow recticle if player is targeted
    local playeristargeted = fun.unitIsTargeted(PLAYER_FIGHTER_GUID)
    if playeristargeted then
        -- draw yellow recticle on player craft
        if playerfighter ~= nil and playerfighter.fixture:getCategory() ~= enum.categoryFriendlyPod then
            local objx = playerfighter.body:getX()
            local objy = playerfighter.body:getY()
            love.graphics.setColor(1, 0.5, 0, 0.75)
            love.graphics.draw(IMAGE[enum.imageCrosshairsIsTarget], objx, objy, 0, 0.75, 0.75, 35, 30)
        end
    end

    -- draw the menu if menu is open
    if showmenu and isPlayerFighterOnBattlefield() then
		drawMenu()
    end

    -- draw damage text
    drawDamageText()

    drawAnimations()

    -- animations are drawn in love.draw()
    cam:detach()
end



function fight.update(dt)
    if not fightsceneHasLoaded then
        fightsceneHasLoaded = true

        commanderAI = {}                                        -- squadAI is initialised in battle roster
    	commanderAI[1] = {}
    	commanderAI[2] = {}
        commanderAI[1].forf = enum.forfFriend
    	commanderAI[1].orders = {}
        commanderAI[2].forf = enum.forfEnemy
    	commanderAI[2].orders = {}
    	thisorder = {}
    	thisorder.cooldown = 15
    	thisorder.active = true         						-- set to false if you want to queue it but not activate it
    	thisorder.order = enum.commanderOrdersEngage
    	table.insert(commanderAI[1].orders, thisorder)			-- should make this more robust in the future
    	table.insert(commanderAI[2].orders, thisorder)

        -- neutral commander things go here

		local playerfighter = fun.getPlayerPilot()

        SCORE = {}
        SCORE.friendsdead = 0
		SCORE.friendsEjected = 0
        SCORE.enemiesdead = 0
		SCORE.enemiesEjected = 0
		SCORE.loser = 0

		DAMAGETEXT = {}

        RTB_TIMER = 0
        BATTLE_TIMER = 0
		timefactor = 1

		pause = false
		showmenu = false
		showcallsigns = false

		-- set camera to player
		for i = 1, #OBJECTS do
			if OBJECTS[i].guid == PLAYER_FIGHTER_GUID then
				cameraindex = i
				snapcamera = true
                -- fun.createAnimation(OBJECTS[i], enum.animDebugging)          -- debugging only
                break
			end
		end
    end

    if not pause then
		local newdt = dt * timefactor
        RTB_TIMER = RTB_TIMER + newdt
        BATTLE_TIMER = BATTLE_TIMER + newdt
        commanderai.update(newdt)
        squadai.update(newdt)
        unitai.update(newdt)

        destroyObjects(newdt)
        spawnPods()
		updateDamageText(newdt)

        PHYSICSWORLD:update(newdt) --this puts the world into motion
    end

    if snapcamera and OBJECTS[cameraindex] ~= nil then
		TRANSLATEX = OBJECTS[cameraindex].body:getX()
		TRANSLATEY = OBJECTS[cameraindex].body:getY()
    end

    if battleOver() or BATTLE_TIMER > BATTLE_TIMER_LIMIT then
        -- fleet movement points is added/subtracted in the commanderai file

        -- load up the SCORE table for later user
        if isPlayerFighterAlive() then
            SCORE.playerfighteralive = true
        else
            SCORE.playerfighteralive = false
        end

        local playerpilot = fun.getPlayerPilot()
        if playerpilot == nil then
            SCORE.playeralive = false
        else
            SCORE.playeralive = true
        end

		fightsceneHasLoaded = false
        cf.swapScreen(enum.sceneEndBattle, SCREEN_STACK)
    end

	lovelyToasts.update(dt)

    cam:setZoom(ZOOMFACTOR)
    cam:setPos(TRANSLATEX,	TRANSLATEY)
end

return fight

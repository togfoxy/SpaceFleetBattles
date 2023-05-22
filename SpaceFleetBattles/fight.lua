fight = {}

local pause = false
local snapcamera = true
local showmenu = false
local showcallsigns = false
local cameraindex = nil				-- which fighter has the cameras' focus
local timefactor = 1

local function destroyObjects(dt)

    for i = #OBJECTS, 1, -1 do
        if OBJECTS[i].lifetime ~= nil then
            OBJECTS[i].lifetime = OBJECTS[i].lifetime - dt
            if OBJECTS[i].lifetime <= 0 then

                if OBJECTS[i].fixture:getCategory() == enum.categoryEnemyBullet or OBJECTS[i].fixture:getCategory() == enum.categoryFriendlyBullet then
                    fun.createAnimation(OBJECTS[i], enum.animBulletSmoke)
                end

                OBJECTS[i].fixture:destroy()
                OBJECTS[i].body:destroy()
                table.remove(OBJECTS, i)
            end
        end
    end
end

local function battleOver()
    local isFriends = false
    local isFoes = false

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
            love.event.quit()
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
		if fun.isPlayerAlive() then
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
		if fun.isPlayerAlive() then
            -- see if player unit is clicked
            local Obj = fun.getObject(PLAYER_FIGHTER_GUID)              -- get the hanger object with physics body
			-- local objcategory = Obj.fixture:getCategory()				-- need to check if this is a fighter or pod
            local objx, objy = Obj.body:getPosition()                   -- get the physics x/y
            local robjx, robjy = res.toGame(objx, objy)                 -- scale that to the current resolution
            local crobjx, crobjy = cam:toScreen(robjx, robjy)           -- convert that to the screen
            local xadj = (rx - crobjx) / ZOOMFACTOR                     -- do a diff and apply the zoom
            local yadj = (ry - crobjy) / ZOOMFACTOR
            -- print(cf.getDistance(x, y, crobjx, crobjy) / ZOOMFACTOR)
            -- print(cf.getDistance(rx, ry, crobjx, crobjy) / ZOOMFACTOR)       -- going to use this one for now
            -- print((rx - crobjx) / ZOOMFACTOR, (ry - crobjy) / ZOOMFACTOR)
            -- print(xadj, yadj)

            local dist = cf.getDistance(rx, ry, crobjx, crobjy) / ZOOMFACTOR
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

    if fun.isPlayerAlive() then
        local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
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
	local drawx, drawy = res.toGame(Obj.body:getX(), Obj.body:getY()) -- need to convert physical to screen

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

	-- draw current action and a line
	local actionenum = functions.getTopAction(Obj)
    txt = ""
    if actionenum ~= nil then
    	if actionenum == enum.unitActionEngaging then
    		txt = "Currently: engaging"
    	elseif actionenum == enum.unitActionReturningToBase then
    		txt = "Currently: returning to base"
    	elseif actionenum == enum.unitActionEject then
    		txt = "Currently: ejecting!"
    	elseif actionenum == enum.unitActionReturningToBase then
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
			love.graphics.draw(IMAGE[enum.imageFighterFriend], drawx, drawy, angle, 0.15, 0.15, 75, 50)

			if Obj.guid == PLAYER_FIGHTER_GUID then
				-- draw recticle that shows player vessel
				love.graphics.draw(IMAGE[enum.imageCrosshairPlayer], drawx, drawy, 0, 0.75, 0.75, 35, 30)
			end
		elseif objtype == enum.categoryEnemyFighter then
			love.graphics.setColor(1,1,1,1)
			local angle = Obj.body:getAngle()           -- radians
			love.graphics.draw(IMAGE[enum.imageFighterFoe], drawx, drawy, angle, 0.10, 0.15, 130, 70)
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
			local str = "CS: " .. Obj.squadCallsign .. "-" .. string.sub(Obj.guid, - 4)		-- this is squad callsign + guid
			if Obj.forf == enum.forfFriend then
				-- get the pilots last name and add that to the callsign
				local pilotguid = Obj.pilotguid
				local pilot = fun.getPilot(guid)
				str = str .. "\n" .. pilot.lastname
			end
		
			love.graphics.setColor(1,1,1,1)
			love.graphics.print(str, drawx, drawy, 0, 1, 1, -15, 30)
		
			-- draw a cool line next
			local x2, y2 = drawx + 30, drawy - 14
			love.graphics.setColor(1,1,1,1)
			love.graphics.line(drawx, drawy, x2, y2)
		else
			error()
		end
	end
end

local function drawDamageText()

	love.graphics.setColor(1,1,1,1)
	for i = 1, #DAMAGETEXT do
		local drawx = DAMAGETEXT.object.body.getX()
		local drawy = DAMAGETEXT.object.body.getY()
		drawy = drawy - (DAMAGETEXT.timeleft * -1)		-- this creates a floating effect
		
		love.graphics.print(DAMAGETEXT[i].text, drawx, drawy)
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

        -- print current action
        -- debug only
        currentaction = fun.getTopAction(Obj)     -- receives an object
        if currentaction ~= nil then
            txt = currentaction.action
        else
            txt = "None"
        end
        local drawx, drawy = res.toGame(objx, objy) -- need to convert physical to screen
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(txt, drawx - 20, drawy + 10)
    end

    -- draw target recticle for player 1
    if fun.isPlayerAlive() then
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
            -- local linelength = 12
            -- love.graphics.setColor(1, 0.5, 0, 1)
            -- love.graphics.line(objx, objy - linelength, objx + linelength, objy + linelength, objx - linelength, objy + linelength, objx, objy - linelength)

            love.graphics.setColor(1, 0.5, 0, 0.75)
            love.graphics.draw(IMAGE[enum.imageCrosshairsIsTarget], objx, objy, 0, 0.75, 0.75, 35, 30)
        end
    end

    -- draw the menu if menu is open
    if showmenu and fun.isPlayerAlive() then
		drawMenu()
    end

    -- animations are drawn in love.draw()
    cam:detach()
end

function fight.update(dt)
    if not fightsceneHasLoaded then
        fightsceneHasLoaded = true

        commanderAI[1] = {}
        commanderAI[1].forf = enum.forfFriend
        commanderAI[2] = {}
        commanderAI[2].forf = enum.forfEnemy
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

    if snapcamera then
		TRANSLATEX = OBJECTS[cameraindex].body:getX()
		TRANSLATEY = OBJECTS[cameraindex].body:getY()
    end
	
    if battleOver() or BATTLE_TIMER > BATTLE_TIMER_LIMIT then
        -- fleet movement points is added/subtracted in the commanderai file
		fightsceneHasLoaded = false
        cf.swapScreen(enum.sceneEndBattle, SCREEN_STACK)
    end

	lovelyToasts.update(dt)

    cam:setZoom(ZOOMFACTOR)
    cam:setPos(TRANSLATEX,	TRANSLATEY)
end

return fight

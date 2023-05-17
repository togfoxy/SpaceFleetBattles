fight = {}


local pause = false
local snapcamera = true
local showmenu = false


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
            local objscreenx, objscreeny = cam:toScreen(Obj.body:getX(), Obj.body:getY()) -- need to convert physical to screen
            local dist = cf.getDistance(x, y, objscreenx, objscreeny)

            if dist <= 30 then
                -- player unit is moused over
                showmenu = true
                pause = true
            end
        end
    end
end

function fight.mousereleased(rx, ry, x, y, button)
    if button == 1 then
		-- menu appears during mouse over. This is to check if menu is clicked
		if fun.isPlayerAlive() then
            -- see if player unit is clicked
            local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
            local objscreenx, objscreeny = cam:toScreen(Obj.body:getX(), Obj.body:getY()) -- need to convert physical to screen

            local dist = cf.getDistance(x, y, objscreenx, objscreeny)

            if dist > 150 then
                -- player unit is moused over
                showmenu = false
                pause = false
            end

            if x >= objscreenx and x <= objscreenx + 200 and y >= objscreeny + 36 and y <= objscreeny + 55 then
				-- engage has been clicked
				print("Engage!")
			elseif x >= objscreenx and x <= objscreenx + 200 and y >= objscreeny + 56 and y <= objscreeny + 75 then
				print("RTB")
			elseif x >= objscreenx and x <= objscreenx + 200 and y >= objscreeny + 76 and y <= objscreeny + 96 then
				print("Eject!")
			end

            print(x, y, objscreenx, objscreeny)
            -- love.graphics.rectangle("line", objx, objy + 36, 200, 20)
            -- love.graphics.rectangle("line", objx, objy + 56, 200, 20)
            -- love.graphics.rectangle("line", objx, objy + 76, 200, 20)
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
	local orderenum = squadAI[squadcallsign].orders[1].order
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
	actionenum = functions.getTopAction(Obj)
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
    	if txt ~= nil then
    		love.graphics.setColor(0,0,0,1)
    		love.graphics.print(txt, drawx + 5, drawy + 18)
    		love.graphics.setColor(1,1,1,1)
    		love.graphics.line(drawx, drawy + 36, drawx + menuwidth, drawy + 36)
    	end
    end

	-- draw the list of actions the player can issue
	--! check the x and y's draw correctly
	love.graphics.setColor(0,0,0,1)
	txt = "New action: engage"
	love.graphics.print(txt, drawx + 5, drawy + 40)
	txt = "New action: return to base"
	love.graphics.print(txt, drawx + 5, drawy + 60)
	txt = "New action: eject!"
	love.graphics.print(txt, drawx + 5, drawy + 80)

    -- debugging menu
    love.graphics.setColor(1,0,0,1)
    local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
    local objx, objy = res.toGame(Obj.body:getX(), Obj.body:getY())

    love.graphics.rectangle("line", objx, objy + 36, 200, 20)
    love.graphics.rectangle("line", objx, objy + 56, 200, 20)
    love.graphics.rectangle("line", objx, objy + 76, 200, 20)

end

function fight.draw()

    drawHUD()       -- do this before the attach

    cam:attach()

	local playerfighter = fun.getObject(PLAYER_FIGHTER_GUID)

    -- draw BG
    love.graphics.setColor(1,1,1,0.25)
    love.graphics.draw(IMAGE[enum.imageFightBG], 0, 0, 0, 2.4, 0.90)

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

        -- draw callsign first
        -- if Obj.squadCallsign ~= nil then
        --     local str = "CS: " .. Obj.squadCallsign .. "-" .. string.sub(Obj.guid, -2)
        --
        --     love.graphics.setColor(1,1,1,1)
        --     love.graphics.print(str, drawx, drawy, 0, 1, 1, -15, 30)
        --
        --     -- draw a cool line next
        --     local x2, y2 = drawx + 30, drawy - 14
        --     love.graphics.setColor(1,1,1,1)
        --     love.graphics.line(drawx, drawy, x2, y2)
        -- end

        -- draw the physics object
        for _, fixture in pairs(Obj.body:getFixtures()) do
            local objtype = fixture:getCategory()           -- an enum
            if objtype == enum.categoryFriendlyPod or objtype == enum.categoryEnemyPod then
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(IMAGE[enum.imageEscapePod], drawx, drawy, 1.5707, 0.35, 0.35)      -- 1.57 radians = 90 degrees
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

        -- draw velocity as text
        -- if not Obj.body:isBullet() then
        --     local vx, vy = Obj.body:getLinearVelocity()
        --     local vel = cf.getDistance(0, 0, vx, vy)    -- get distance of velocity vector
        --     vel = "v: " .. cf.round(vel, 0)             -- this is not the same as getLinearVelocity x/y because this is the distance between two points
        --     love.graphics.setColor(1,1,1,1)
        --     love.graphics.print(vel, drawx, drawy, 0, 1, 1, 30, 30)
        -- end

        -- draw the velocity indicator (purple line)
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

    -- draw current action
    local txt
    -- if fun.isPlayerAlive() then
        currentaction = fun.getTopAction(playerfighter)
        if currentaction ~= nil then
            txt = currentaction.action
        else
            txt = "None"
        end
        local drawx, drawy = res.toGame(playerfighter.body:getX(), playerfighter.body:getY()) -- need to convert physical to screen
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(txt, drawx - 20, drawy + 10)
    -- end

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

        RTB_TIMER = 0
        BATTLE_TIMER = 0

		snapcamera = true
		pause = false
		showmenu = false
    end

    if not pause then
        RTB_TIMER = RTB_TIMER + dt
        BATTLE_TIMER = BATTLE_TIMER + dt
        commanderai.update(dt)
        squadai.update(dt)
        unitai.update(dt)

        destroyObjects(dt)
        fun.spawnPods()

        PHYSICSWORLD:update(dt) --this puts the world into motion
    end

    if snapcamera then
        local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
        if Obj ~= nil then
            TRANSLATEX = Obj.body:getX()
            TRANSLATEY = Obj.body:getY()
        end
    end

    if battleOver() or BATTLE_TIMER > BATTLE_TIMER_LIMIT then
        --! add fleet movement points based on win (+1) or loss (-1)
		fightsceneHasLoaded = false
        cf.swapScreen(enum.sceneEndBattle, SCREEN_STACK)
    end

	lovelyToasts.update(dt)

    cam:setZoom(ZOOMFACTOR)
    cam:setPos(TRANSLATEX,	TRANSLATEY)
end

return fight

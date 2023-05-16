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

                --! debugging
                -- if OBJECTS[i].fixture:getCategory() == enum.categoryEnemyFighter or OBJECTS[i].fixture:getCategory() == enum.categoryFriendlyFighter then
                --     print("Fighter object destroyed")
                --     -- print(inspect(OBJECTS[1]))
                -- end
                -- print("guid and object destroyed: " .. OBJECTS[i].guid)
                OBJECTS[i].fixture:destroy()                --! check if mass changes
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
    end
end

function fight.mousereleased(rx, ry, x, y, button)
    if button == 1 then
        if fun.isPlayerAlive() then
            -- see if player unit is clicked
            local objscreenx, objscreeny = cam:toScreen(OBJECTS[1].body:getX(), OBJECTS[1].body:getY()) -- need to convert physical to screen
            local dist = cf.getDistance(rx, ry, objscreenx, objscreeny)
            if dist <= 20 then
                -- player unit is clicked
                showmenu = not showmenu
                if showmenu then
                    pause = true
                else
                    pause = false
                end
            else
                -- if clicking off the menu then turn off menu
                if showmenu then
                    showmenu = false
                    pause = false
                end
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

function fight.draw()

    drawHUD()       -- do this before the attach

    cam:attach()

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
        local cat = Obj.fixture:getCategory()               --! probably not used

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
        local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
        -- player still alive
        if Obj.actions ~= nil and Obj.actions[1] ~= nil then
            if Obj.actions[1].targetguid ~= nil then
                local guid = Obj.actions[1].targetguid
                local enemy = fun.getObject(guid)
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
        local Obj = fun.getObject(PLAYER_FIGHTER_GUID)              --! should probably move this line to top of function
        if Obj ~= nil and Obj.fixture:getCategory() ~= enum.categoryFriendlyPod then
            local objx = Obj.body:getX()
            local objy = Obj.body:getY()
            -- local linelength = 12
            -- love.graphics.setColor(1, 0.5, 0, 1)
            -- love.graphics.line(objx, objy - linelength, objx + linelength, objy + linelength, objx - linelength, objy + linelength, objx, objy - linelength)

            love.graphics.setColor(1, 0.5, 0, 0.75)
            love.graphics.draw(IMAGE[enum.imageCrosshairsIsTarget], objx, objy, 0, 0.75, 0.75, 35, 30)
        end
    end

    -- draw the menu if menu is open
    if showmenu and fun.isPlayerAlive() then
        local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
        local drawx, drawy = res.toGame(Obj.body:getX(), Obj.body:getY()) -- need to convert physical to screen

        -- fill the menu box
        local menuwidth = 150
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.rectangle("fill", drawx, drawy, menuwidth, 75, 10, 10)

        -- draw an outline
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle("line", drawx, drawy, menuwidth, 75, 10, 10)

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
        actionenum = Obj.actions[1].action
        if actionenum == enum.unitActionEngaging then
            txt = "Engaging"
        elseif actionenum == enum.unitActionReturningToBase then
            txt = "Returning to base"
        end
        if txt ~= nil then
            love.graphics.setColor(0,0,0,1)
            love.graphics.print(txt, drawx + 5, drawy + 18)
            love.graphics.setColor(1,1,1,1)
            love.graphics.line(drawx, drawy + 36, drawx + menuwidth, drawy + 36)
        end
    end

    -- draw current action
    local txt
    if fun.isPlayerAlive() then
        local Obj = fun.getObject(PLAYER_FIGHTER_GUID)
        currentaction = fun.getTopAction(Obj)
        if currentaction ~= nil then
            txt = currentaction.action
        else
            txt = "None"
        end
        local drawx, drawy = res.toGame(Obj.body:getX(), Obj.body:getY()) -- need to convert physical to screen
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(txt, drawx - 20, drawy + 10)
    end

    -- animations are drawn in love.draw()
    -- cf.printAllPhysicsObjects(PHYSICSWORLD, 1)
    cam:detach()
end

function fight.update(dt)
    if not fightsceneHasLoaded then
        fightsceneHasLoaded = true

        commanderAI[1] = {}
        commanderAI[1].forf = enum.forfFriend
        commanderAI[2] = {}
        commanderAI[2].forf = enum.forfEnemy
        --! neutral commander?

		local playerfighter = fun.getPlayerPilot()

        SCORE = {}
        SCORE.friendsdead = 0
		SCORE.friendsEjected = 0
        SCORE.enemiesdead = 0
		SCORE.enemiesEjected = 0

        RTB_TIMER = 0
        BATTLE_TIMER = 0
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

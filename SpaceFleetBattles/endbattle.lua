endbattle = {}
-- NOTE: Squad list is initialised in the battle roster
endBattleHasLoaded = false

function endbattle.mousereleased(rx, ry, x, y, button)
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonEndBattleNewGame then
        cf.swapScreen(enum.scenePlanetMap, SCREEN_STACK)
    elseif clickedButtonID == enum.buttonEndBattleExitGame then
        cf.removeScreen(SCREEN_STACK)
    end
end

local function drawPilotStats(drawx, drawy)
    local playerpilot = fun.getPlayerPilot()        -- scans ROSTER

    love.graphics.print("Your pilot stats:", drawx, drawy)
    drawy = drawy + 50
    love.graphics.print("                              Health  # Missions    # Kills     # Fighters lost", drawx, drawy)		--! make this correct x/y values
    drawy = drawy + 50

    local txt = playerpilot.firstname .. " " .. playerpilot.lastname .. "                  "
    txt = txt .. playerpilot.health .. "                 " .. playerpilot.missions .. "                  " .. playerpilot.kills .. "                        " .. playerpilot.ejections

    if playerpilot.isDead then
        love.graphics.setColor(1,1,1,0.5)
    else
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.print(txt, drawx, drawy)
    drawy = drawy + 50
end

local function drawLoserInfo()
	-- access global variables (only)
    love.graphics.setColor(1,1,1,1)
	if SCORE.loser == enum.forfFriend then
		love.graphics.print("Your forces retreated from battle in the face of overwhelming forces.", 800, 250)
	elseif SCORE.loser == enum.forfEnemy then
		love.graphics.print("Your forces defeated the opposing fleet.", 800, 250)
	else
        -- a draw as the timer ran out
        love.graphics.print("Your forces did not win nor lose. The battle ended with a stalemate.", 800, 250)
	end
end

local function drawKillCount()
	-- access global variables (only)
    local drawx = 800
    local drawy = 280
	love.graphics.print("Pilots lost: " .. SCORE.friendsdead, drawx, drawy)
	love.graphics.print("Fighters lost: " .. SCORE.friendsdead + SCORE.friendsEjected, drawx, drawy + 25)

	love.graphics.print("Enemy pilots lost: " .. SCORE.enemiesdead, drawx, drawy + 60)
	love.graphics.print("Enemy fighters destroyed: " .. SCORE.enemiesdead + SCORE.enemiesEjected, drawx, drawy + 85)
end

function endbattle.draw()

    love.graphics.setFont(FONT[enum.fontCorporate])

    love.graphics.setColor(1,1,1,0.25)
    love.graphics.draw(IMAGE[enum.imageEndBattle],0,0,0, 0.75,0.75)

    local drawx = 100
    local drawy = 100
    love.graphics.setColor(1,1,1,1)

    if not SCORE.playeralive then
        love.graphics.print("Your pilot died honourably in battle. You will be able to roleplay a new pilot.", drawx, drawy)
        drawy = drawy + 50
    elseif not SCORE.playerfighteralive then
        love.graphics.print("Your fighter was destroyed in combat but your pilot lived to fight another day.", drawx, drawy)
        drawy = drawy + 50
    else
        love.graphics.print("You bravely confronted the enemy and brought your fighter home." , drawx, drawy)
        drawy = drawy + 50
    end

    -- pilot stats here
	drawPilotStats(drawx, drawy)           -- calls getPlayerPilot()

    -- display kill count
	drawKillCount()

	-- display who retreated first
	drawLoserInfo()

    love.graphics.setFont(FONT[enum.fontDefault])
    buttons.drawButtons()
end

function endbattle.update(dt)

    if not endBattleHasLoaded then
        endBattleHasLoaded = true

        print("Score:")
        print(inspect(SCORE))

		-- take pilots out of fighters
		for k, pilot in pairs(ROSTER) do
			pilot.vesselguid = nil
		end

        cf.saveTableToFile("roster.dat", ROSTER)

        -- cycle through surviving objects and reset them for next combat before saving to file
        for k, Obj in pairs(HANGER) do
            Obj.body = nil
            Obj.fixture = nil
            Obj.shape = nil
            Obj.isLaunched = false
            Obj.lifetime = nil
            Obj.pilotguid = nil
            Obj.squadCallsign = nil
            Obj.actions = {}
        end

        cf.saveTableToFile("hanger.dat", HANGER)

    	print(inspect(HANGER))

    end
end

function endbattle.loadButtons()
    -- call this from love.load()
    -- ensure buttons.drawButtons() is added to the scene.draw() function
    -- ensure scene.mousereleased() function is added

    -- local numofbuttons = 2      -- how many buttons on this form, assuming a single column
    -- local numofsectors = numofbuttons + 1
    -- local buttonsequence = 1            -- sequence on the screen

    -- button for new game
    local mybutton = {}
    mybutton.x = (SCREEN_WIDTH / 2) - 75
    mybutton.y = SCREEN_HEIGHT / 2 +100
    mybutton.width = 175
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Next battle"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3
    mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 40

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneEndBattle             -- change and add to enum
    mybutton.identifier = enum.buttonEndBattleNewGame     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table

    -- button for exit game
    local mybutton = {}
    mybutton.x = (SCREEN_WIDTH / 2) - 75
    mybutton.y = SCREEN_HEIGHT / 2 + 200
    mybutton.width = 175
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Main menu"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3
    mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 40

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneEndBattle             -- change and add to enum
    mybutton.identifier = enum.buttonEndBattleExitGame     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table
end

return endbattle

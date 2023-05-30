planetmap = {}

local function getPlanetClicked(x, y)
	-- determine which planet is clicked, if any.

	local closestdist = 9999999
	local closetindex = nil
	for i = 1, #PLANETS do
		local dist = cf.getDistance(x, y, PLANETS[i].x, PLANETS[i].y)
		if dist < closestdist then
			closestdist = dist
			closetindex = i
		end
	end
	if closestdist <= 40 then
		return closetindex
	else
		return nil
	end
end

local function createPilotFighter(numpilots, numfighters, forf)
	-- a helper function to cut down on lines of code
	-- input: number of pilots to add to roster
	-- input: number of fighters to add to roster
	-- input: forf value
	for i = 1, numpilots do
		local thispilot = fun.createNewPilot()
		table.insert(ROSTER, thispilot)
		print("Added a fresh pilot to roster")
	end
	for i = 1, numfighters do
		local fighter = fighter.createHangerFighter(forf)
		fighter.isLaunched = false
		table.insert(HANGER, fighter)
		print("Added a fresh fighter to hanger")
	end
end

local function repairFleet(sector)
	-- cycle through the fleet and repair vessels

	-- print(inspect(FLEET))
	-- print("**")
	-- print(inspect(PLANETS))

	-- repair the friendly ships in the hanger first
	FLEET.friendlyFighterPoints = FLEET.friendlyFighterPoints + PLANETS[sector].friendlyfighters
	FLEET.foeFighterPoints = FLEET.foeFighterPoints + PLANETS[sector].foefighters

	for i = 1, #HANGER do
		for k, componenthealth in pairs(HANGER[i].componentHealth) do
			if componenthealth < 100 then
				local damagesuffered = 100 - componenthealth
				if HANGER[i].forf == enum.forfFriend then
					local damagerepaired = math.min(damagesuffered, FLEET.friendlyFighterPoints)
					componenthealth = componenthealth + damagerepaired
					FLEET.friendlyFighterPoints = FLEET.friendlyFighterPoints - damagerepaired
					print("Adding " .. damagerepaired .. " repair points to friendly fleet.")
				else
					local damagerepaired = math.min(damagesuffered, FLEET.foeFighterPoints)
					componenthealth = componenthealth + damagerepaired
					FLEET.foeFighterPoints = FLEET.foeFighterPoints - damagerepaired
					print("Adding " .. damagerepaired .. " repair points to foe fleet.")
				end
			end
		end
	end

	--! what about pilot points stored in PLANETS and FLEET?
	-- PLANETS[1].friendlypilots = 3
	-- PLANETS[1].foepilots = 0
end

local function adjustResourceLevels()
	-- remember that resource levels only adjust the global supply. It doesn't change how many fighters are in the battle
	-- unless your supply goes below the maximum for the battle
	-- fighter points are allocated during the repair routine so don't add them here

	local currentsector = FLEET.sector
	repairFleet(currentsector)		-- operates on FLEET table

	local newfriendlypilots = PLANETS[currentsector].friendlypilots
	local newfoepilots = PLANETS[currentsector].foepilots

	if newfriendlypilots == nil then newfriendlypilots = 0 end
	if newfoepilots == nil then newfoepilots = 0 end

	-- add the correct number of pilots to roster and fighters to hanger
	local newfriendlyfighters = math.floor(FLEET.friendlyFighterPoints / 100)
	createPilotFighter(newfriendlypilots, newfriendlyfighters, enum.forfFriend)
	FLEET.friendlyFighterPoints = FLEET.friendlyFighterPoints - (newfriendlyfighters * 100)
end

local function drawPlanets()
	--! this needs refactoring
	-- this sub has multiple fonts

    -- draw bg
    love.graphics.draw(IMAGE[enum.imagePlanetBG], 0, 0, 0, 2, 2)

    -- draw planets
	love.graphics.setFont(FONT[enum.fontMedium])
    for i = 1, #PLANETS do
		-- draw the planet image
		love.graphics.setColor(1,1,1,1)
        love.graphics.draw(PLANETS[i].image, PLANETS[i].x, PLANETS[i].y, 0, PLANETS[i].scale, PLANETS[i].scale, 150, 150)

		-- draw the resources text
		love.graphics.print(PLANETS[i].tooltip, PLANETS[i].x, PLANETS[i].y - 75)

		-- add a dot in the centre of the planet for debugging purposes
		love.graphics.setColor(1,0,0,1)
		love.graphics.circle("fill", PLANETS[i].x, PLANETS[i].y, 5)
    end
	love.graphics.setFont(FONT[enum.fontDefault])

    -- draw players fleet
	local sector
	if FLEET.newSector == nil then
		sector = FLEET.sector
	else
		sector = FLEET.newSector
	end

    local drawx = PLANETS[sector].x         -- this is top left corner of the planet
    local drawy = PLANETS[sector].y
    local scale = PLANETS[sector].scale			-- scale = the size of the planet. Different scales used for asthetic reasons
    love.graphics.setColor(1,0,0,1)

	love.graphics.draw(IMAGE[enum.imageCrosshairPlanet], drawx, drawy, 0, 5, 5, 33, 33)

	-- draw the roster and hanger counts
	local rostersize = #ROSTER
	local hangersize = fun.getActiveFighterCount(enum.forfFriend)
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(FONT[enum.fontCorporate])
	love.graphics.print("Available pilots: " .. rostersize, 600, 50)
	love.graphics.print("Available fighters: " .. hangersize, 1100, 50)
	love.graphics.setFont(FONT[enum.fontDefault])

	-- add a dot in the centre of the fleet for debugging purposes
	love.graphics.setColor(0,1,0,1)
	love.graphics.circle("fill", drawx, drawy, 5)


end

function planetmap.keyreleased(key, scancode)
	if scancode == "escape" then
		cf.removeScreen(SCREEN_STACK)
	end
end

function planetmap.mousereleased(rx, ry, x, y, button)
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonPlanetMapBattleStations then
		if FLEET.newSector ~= nil then
			FLEET.sector = FLEET.newSector
		end
		adjustResourceLevels()

		-- ensure the player has a pilot to fly
		local playerpilot = fun.getPlayerPilot()
		if playerpilot.isDead then
			-- find a new pilot for the player
			for i = 1, #ROSTER do
				if ROSTER[i].missions == 0 then
					-- this is the new player
					ROSTER[i].firstname = ""
					ROSTER[i].lastname = playername
					ROSTER[i].isPlayer = true
					PLAYER_GUID = ROSTER[i].guid
				end
			end
		end
		local playerpilot = fun.getPlayerPilot()
		if playerpilot.isDead then print("Player does not have a pilot to role play for this round") end

		FLEET.movesLeft = 0
        cf.swapScreen(enum.sceneBattleRoster, SCREEN_STACK)
	else
		local planetclicked = getPlanetClicked(rx, ry)
		if planetclicked ~= nil then
			local currentsector = FLEET.sector
			local requestedmoves = PLANETS[planetclicked].column - PLANETS[currentsector].column
			if requestedmoves <= FLEET.movesLeft and requestedmoves >= -1 then
				-- move to new sector
				FLEET.newSector = planetclicked
			else
				cf.playAudio(enum.audioMouseClick, false, true)		-- stream, static
			end
		end
    end
end

function planetmap.draw()

    drawPlanets()

    buttons.drawButtons()

end

function planetmap.loadButtons()
                                                -- ensure loadButtons() is called in love.load()
    -- button for continue game
    local mybutton = {}
    mybutton.label = "Battle stations!"
	mybutton.x = 125
    mybutton.y = SCREEN_HEIGHT - 200
    mybutton.width = 175
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
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
    mybutton.scene = enum.scenePlanetMap               -- change and add to enum
    mybutton.identifier = enum.buttonPlanetMapBattleStations     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table

end



return planetmap

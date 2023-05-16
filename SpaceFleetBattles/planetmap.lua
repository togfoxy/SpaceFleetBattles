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

local function adjustResourceLevels()

	local currentsector = FLEET.sector

end

local function drawPlanets()

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

		-- add a dot for debugging purposes
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
    local scale = PLANETS[sector].scale
    love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle("line", drawx - 75, drawy - 75, 250 * scale, 250 * scale)

end

function planetmap.mousereleased(rx, ry, x, y, button)
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonPlanetMapBattleStations then
		if FLEET.newSector ~= nil then
			FLEET.sector = FLEET.newSector
		end
		adjustResourceLevels()
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

battleroster = {}

local battlerosterhasloaded = false
local rosterdrawy = 100			-- this tracks where the roster starts to draw. It emulates scrolling.

local function initialiseSquadList()
	-- the squad list is the master list of call signs made available to each battle
	SQUAD_LIST = {}				-- the master list of callsigns
    local index = 1
    for i = 65, 90 do
        for j = 1, 9 do
            local str = string.char(i) .. tostring(j)
            SQUAD_LIST[index] = str            -- setting to nil makes it available for selection
            index = index + 1
        end
    end
end

local function getUniqueCallsign()
    -- get a random and empty callsign from the squadlist
    -- the squad callsign is a two character code. the squadlist ensures it is unique
    local rndnum = love.math.random(1, #SQUAD_LIST)
    local result = SQUAD_LIST[rndnum]
    table.remove(SQUAD_LIST, rndnum)        -- removing the callsign stops it being used twice
    return result
end

local function getUnassignedPilot()
	-- this function only works when called during battle roster
	-- this function will throw an error if called during battle because the player pilot might be dead or RTB
	-- assign the player pilot first
	local playerpilot = fun.getPlayerPilot()			-- returns the pilot object that is the player
	if playerpilot == nil then
		error()
	else
		if (playerpilot.vesselguid == nil and playerpilot.isDead == false) then
            print("Player not assigned a vessel. Returning the pilot that is the player")
			return playerpilot
		end
	end

	-- code reaching this point means the playerpilot has been previously assigned. From here on, assign other based on health
	table.sort(ROSTER, function(a, b)
		return a.health > b.health
	end)

	for i = 1, #ROSTER do
		if ROSTER[i].vesselguid == nil and (ROSTER[i].isDead == false or ROSTER[i].isDead == nil) then
			return ROSTER[i]
		end
	end
	print("No combat-ready pilot found")
	return nil
end

local function getEmptyVessel()
	-- returns an object or nil
	-- this doesn't respect the players sort order
	-- sort table according to structure health and thruster damage

	table.sort(HANGER, function(a, b)
		return a.componentHealth[enum.componentStructure] > b.componentHealth[enum.componentStructure]
	end)

	for i = 1, #HANGER do
		if HANGER[i].pilotguid == nil then
			return HANGER[i]
		end
	end
    print("No combat-ready vessel found")
	return nil
end

local function addPilotandFighterToBattle(thispilot, thisfighter, thiscallsign)
	-- put the pilot and fighter together and add to battle (OBJECTS)
	-- NOTE: for friendly pilots only

	thisfighter.pilotguid = thispilot.guid
	thisfighter.squadCallsign = thiscallsign
	thisfighter.isLaunched = true                   -- puts it into the batlespace
	fighter.createFighterBody(thisfighter)          -- creates a physical body
	local x, y = fun.getLaunchXY(enum.forfFriend)
	thisfighter.body:setPosition(x, y)

	assert(thisfighter.guid ~= nil)

	thispilot.vesselguid = thisfighter.guid
	thispilot.missions = thispilot.missions + 1

	-- load fighter into objects
	table.insert(OBJECTS, thisfighter)		-- pilots go into fighters but they don't go into OBJECTS

	if thispilot.isPlayer then
		PLAYER_FIGHTER_GUID = thisfighter.guid
		print("Players fighter guid:" .. PLAYER_FIGHTER_GUID )
	end
end

local function loadBattleObjects()
	-- this assigns pilots to fighters and loads up all the objects needed for battle
	--! need to break this down into smaller subs

	OBJECTS = {}				-- these are the objects that go to battle
	initialiseSquadList()		-- load all the callsigns
    commanderAI = {}
    squadAI = {}

	-- do friendly fleet first
	local livingroster = fun.getActivePilotCount()
	local numfriendlyfighters = math.min(livingroster, #HANGER)
	if numfriendlyfighters > 1 then numfriendlyfighters = 1 end		--! where does FRIEND_FIGHTER_COUNT come into this?
	--!!
	-- establish the correct amount of friendly squads
	local callsign = {}
	for i = 1, FRIEND_SQUADRON_COUNT do
		local thiscallsign = getUniqueCallsign()
        squadAI[thiscallsign] = {}
        squadAI[thiscallsign].forf = enum.forfFriend
        squadAI[thiscallsign].orders = {}
		table.insert(callsign, thiscallsign)
	end

	local callsignindex = 1		-- flip flops between 1 and 2 to shuffle assignments between two squads
	for i = 1, numfriendlyfighters do

		-- get an unassigned pilot from roster (starting with player) or nil
		local pilot = getUnassignedPilot()		-- preferences player pilot. Returns nil if failed to find any pilot

		-- get an unassigned fighter from hanger, in sequence, or nil
		local thisfighter = getEmptyVessel()

		-- check if pilot has a fighter
		if pilot ~= nil and thisfighter ~= nil then
			-- assign pilot to fighter and assign fighter to pilot
			addPilotandFighterToBattle(pilot, thisfighter, callsign[callsignindex])

			-- toggle the callsignindex to ensure fighters are allocated to squads evenly
			if callsignindex == 1 then callsignindex = 2
			elseif callsignindex == 2 then callsignindex = 1
			else error()
			end
		else
			-- run out of pilots and/or fighters. Break the loop and go to battle with whatever you have
			print("Can't find combat ready pilots and/or fighters")
			break
		end
	end

	local numenemyfighters = math.min(FOE_FIGHTER_COUNT, FOE_PILOT_COUNT)
	if numenemyfighters > 1 then numenemyfighters = 1 end
	--!!

	-- establish the correct amount of enemy squads
	local callsign = {}
	for i = 1, FOE_SQUADRON_COUNT do
		local thiscallsign = getUniqueCallsign()
        squadAI[thiscallsign] = {}
        squadAI[thiscallsign].forf = enum.forfFriend
        squadAI[thiscallsign].orders = {}
		table.insert(callsign, thiscallsign)
	end

	callsignindex = 1		-- flip flops between 1 and 2 to shuffle assignments between two squads
	for i = 1, numenemyfighters do
		local thisfighter = fighter.createFighter(enum.forfEnemy)
		thisfighter.squadCallsign = callsign[callsignindex]
		assert(thisfighter.guid ~= nil)
		table.insert(OBJECTS, thisfighter)					-- enemy fighters have no crew

		-- toggle the callsignindex to ensure fighters are allocated to squads evenly
		if callsignindex == 1 then callsignindex = 2
		elseif callsignindex == 2 then callsignindex = 1
		else error()
		end
	end
end

function battleroster.wheelmoved(x, y)
	rosterdrawy = rosterdrawy + y
end

function battleroster.mousereleased(rx, ry, x, y, button)

    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonBattleRosterLaunch then
		loadBattleObjects()
		battlerosterhasloaded = false
		cf.saveTableToFile("fleet.dat", FLEET)							-- do this here only when starting the next battle
        cf.swapScreen(enum.sceneFight, SCREEN_STACK)
    end
end

local function drawRoster()
	-- font is set in main draw()
	local drawx = 100
    local drawy = rosterdrawy

	love.graphics.setColor(1,1,1,1)

	love.graphics.print("Pilot", drawx, drawy)
	love.graphics.print("Health", drawx + 200, drawy)
	love.graphics.print("# Missions", drawx + 285, drawy)
	love.graphics.print("# Kills", drawx + 425, drawy)
	love.graphics.print("# Fighters lost", drawx + 510, drawy)
	drawy = drawy + 30

    for i = 1, #ROSTER do
        if ROSTER[i].isDead then
            love.graphics.setColor(1,1,1,0.5)
        else
            love.graphics.setColor(1,1,1,1)
        end

		if ROSTER[i].firstname == nil then
			print(inspect(ROSTER))
		end

		local txt = ROSTER[i].firstname .. " " .. ROSTER[i].lastname
		love.graphics.print(txt, drawx, drawy)

		love.graphics.print(ROSTER[i].health, drawx + 250, drawy)
		love.graphics.print(ROSTER[i].missions, drawx + 380, drawy)
		love.graphics.print(ROSTER[i].kills, drawx + 485, drawy)
		love.graphics.print(ROSTER[i].ejections, drawx + 620, drawy)
		drawy = drawy + 30
    end

end

local function drawHanger()
	-- font is set in main draw()
	local drawx = 1100
    local drawy = 100

	love.graphics.setColor(1,1,1,1)
	love.graphics.print("Fighter ID", drawx, drawy)
	love.graphics.print("Structure", drawx + 125, drawy)
	drawy = drawy + 30

    for i = 1, #HANGER do
		love.graphics.print(string.sub(HANGER[i].guid, -4), drawx + 25, drawy)
		love.graphics.print(HANGER[i].componentHealth[enum.componentStructure], drawx + 150, drawy)
        drawy = drawy + 30
    end
end

function battleroster.draw()

    love.graphics.setColor(1,1,1,0.5)
    love.graphics.draw(IMAGE[enum.imageBattleRoster],0,0,0, 1,1)

	love.graphics.setFont(FONT[enum.fontCorporate])
	-- draw roster
	drawRoster()

	-- draw fighters in hanger
	drawHanger()

	-- provide some way to specify how many squadrons to launch
	-- how many fighters per squadron
	-- find some way to re-order fighters launched
	-- fighters that are not launched will be slowly repaired

	love.graphics.setFont(FONT[enum.fontDefault])
	buttons.drawButtons()
end

function battleroster.update(dt)

	if not battlerosterhasloaded then
		battlerosterhasloaded = true
		rosterdrawy = 100						-- reset the scrolly thing
	end


end

function battleroster.loadButtons()

    -- button for continue game
    local mybutton = {}
    mybutton.label = "Launch fighters"
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
    mybutton.scene = enum.sceneBattleRoster               -- change and add to enum
    mybutton.identifier = enum.buttonBattleRosterLaunch     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table


end

return battleroster

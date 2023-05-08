battleroster = {}

local function initialiseSquadList()
	-- the squad list is the master list of call signs made available to each battle
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

	-- assign the player pilot first
	local playerpilot = fun.getPlayerPilot()			-- returns the pilot object that is the player
	if playerpilot == nil then
		error()
	else
		if playerpilot.vesselguid == nil then
			return playerpilot
		end
	end

	-- code reaching this point means the playerpilot has been previously assigned. From here on, assign other pilots randomly
	--! maybe this needs to sort by pilot health in the future
	local rndnum
	local loopcounter = 0

	repeat
		rndnum = love.math.random(1, #ROSTER)
		loopcounter = loopcounter + 1
	until ROSTER[rndnum].vesselguid == nil or loopcounter > 999

	if loopcounter < 1000 then
		return ROSTER[rndnum]		-- return the object
	else
		return nil
	end
end

local function getEmptyVessel(vesseltype)
	-- returns an object of the type vesseltype or nil
	-- input: vesseltype = the fixture category (enum.category...)
	--! this doesn't respect the players sort order
	--! maybe for now, sort table according to structure and thruster damage
	for _, vessel in pairs(HANGER) do
		if vessel.fixture:getCategory() == vesseltype then
			if vessel.pilotguid == nil then
				return vessel
			end
		end
	end
	return nil
end

local function loadBattleObjects()
	-- this assigns pilots to fighters and loads up all the objects needed for battle

	OBJECTS = {}				-- these are the objects that go to battle
	SQUAD_LIST = {}				-- the master list of callsigns
	initialiseSquadList()		-- load all the callsigns
    commanderAI = {}
    squadAI = {}

	-- do friendly fleet first
	for i = 1, FRIEND_SQUADRON_COUNT do
		local thiscallsign = getUniqueCallsign()			--! make sure to cleart he squad_list at the end of each battle
        squadAI[thiscallsign] = {}
        squadAI[thiscallsign].forf = enum.forfFriend
        squadAI[thiscallsign].orders = {}
		for j = 1, FRIEND_SHIPS_PER_SQUADRON do
			-- get an unassigned pilot from roster (starting with player) or nil
			local pilot = getUnassignedPilot()		-- preferences player pilot. Returns nil if failed to find any pilot

			-- get an unassigned fighter from hanger, in sequence, or nil
			local thisfighter = getEmptyVessel(enum.categoryFriendlyFighter)

			if pilot ~= nil and thisfighter ~= nil then
				-- assign pilot to fighter and assign fighter to pilot
				thisfighter.pilotguid = pilot.guid
				thisfighter.squadCallsign = thiscallsign
                thisfighter.isLaunched = true                   -- puts it into the batlespace
                local x, y = functions.getLaunchXY(enum.forfFriend)
                thisfighter.body:setPosition(x, y)

                assert(thisfighter.guid ~= nil)

				pilot.vesselguid = thisfighter.guid

				-- load fighter into objects
                -- print("Adding friendly fighter to OBJECTS: " .. thisfighter.guid)
				table.insert(OBJECTS, thisfighter)		-- pilots go into fighters but they don't go into OBJECTS

                if pilot.isPlayer then
                    PLAYER_GUID = thisfighter.guid      --! can probably do this better
                end
			else
				-- run out of pilots and/or fighters. Break the loop and go to battle with whatever you have
				break
			end
		end
	end

	-- now load enemy squadrons
    for i = 1, FOE_SQUADRON_COUNT do
		local thiscallsign = getUniqueCallsign()
        squadAI[thiscallsign] = {}
        squadAI[thiscallsign].forf = enum.forfEnemy
        squadAI[thiscallsign].orders = {}

        for j = 1, FOE_SHIPS_PER_SQUADRON do
			local thisfighter = fighter.createFighter(enum.forfEnemy)
			thisfighter.squadCallsign = thiscallsign
            assert(thisfighter.guid ~= nil)
            -- print("Adding enemy fighter to OBJECTS: " .. thisfighter.guid)
			table.insert(OBJECTS, thisfighter)					-- enemy fighters have no crew
		end
	end
end

function battleroster.mousereleased(rx, ry, x, y, button)

    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonBattleRosterLaunch then
		loadBattleObjects()
        cf.swapScreen(enum.sceneFight, SCREEN_STACK)
	-- elseif clickedButtonID == enum.buttonMainMenuContinueGame then

    -- elseif clickedButtonID == enum.buttonMainMenuExitGame then
        -- love.event.quit()
    end
end

function battleroster.draw()

    love.graphics.setColor(1,1,1,0.5)
    love.graphics.draw(IMAGE[enum.imageBattleRoster],0,0,0, 1,1)

	-- draw roster
    local drawx = 100
    local drawy = 100
    for i = 1, #ROSTER do
        if ROSTER[1].isDead then
            love.graphics.setColor(1,1,1,0.5)
        else
            love.graphics.setColor(1,1,1,1)
        end
        local txt = i .. ") " .. ROSTER[i].firstname .. " " .. ROSTER[i].lastname .. " " .. ROSTER[i].health .. " " .. ROSTER[i].missions .. " " .. ROSTER[i].kills .. " " .. ROSTER[i].ejections
        love.graphics.print(txt, drawx, drawy)
        drawy = drawy + 30
    end

	-- draw fighters in hanger
    local drawx = 900
    local drawy = 100
    love.graphics.setColor(1,1,1,1)
    for i = 1, #HANGER do
        local txt = i .. ") " .. string.sub(HANGER[i].guid, -2)
        txt = txt .. " " .. HANGER[i].componentHealth[enum.componentStructure]
        love.graphics.print(txt, drawx, drawy)
        drawy = drawy + 30
    end

	--! provide some way to specify how many squadrons to launch
	--! how many fighters per squadron
	--! find some way to re-order fightes launched
	--! fighters that are not launched will be slowly repaired

	buttons.drawButtons()
end

function battleroster.loadButtons()

    -- button for continue game
    local mybutton = {}
    mybutton.label = "Launch fighters"
	mybutton.x = SCREEN_WIDTH * 0.85
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

mainmenu = {}

local playername = ""
local newgame = false       -- set to true if clicking new game and prompting for player name


local function initialiseRoster()
	ROSTER = {}
	for i = 1, FRIEND_PILOT_COUNT do
		local thispilot = fun.createNewPilot()
		table.insert(ROSTER, thispilot)
	end
	ROSTER[1].isPlayer = true
    ROSTER[1].firstname = ""
    ROSTER[1].lastname = playername
    PLAYER_GUID = ROSTER[1].guid
end

local function initialiseHanger()
	-- creates fighters and 'stores' them in the hanger table. Friendly only
    -- NOTE: this puts the object in HANGER but not in OBJECTS
	-- NOTE: this does not create a physical object. That happens right before the battle is started
	for i = 1, FRIEND_FIGHTER_COUNT do
		-- local fighter = fighter.createFighter(enum.forfFriend)
        local fighter = fighter.createHangerFighter(enum.forfFriend)
        fighter.isLaunched = false
		table.insert(HANGER, fighter)
	end
end

local function initialiseFleet()
	FLEET = {}
	FLEET.sector = 1
	FLEET.newSector = nil			-- use this as a way to capture original and final sector
    FLEET.movesLeft = 0

    cf.saveTableToFile("fleet.dat", FLEET)
end

local function loadImagesIntoPlanets()

    PLANETS[1].image = IMAGE[enum.imagePlanet1]

    PLANETS[2].image = IMAGE[enum.imagePlanet2]
    PLANETS[3].image = IMAGE[enum.imagePlanet3]

    PLANETS[4].image = IMAGE[enum.imagePlanet4]
    PLANETS[5].image = IMAGE[enum.imagePlanet5]
    PLANETS[6].image = IMAGE[enum.imagePlanet6]

    PLANETS[7].image = IMAGE[enum.imagePlanet7]
    PLANETS[8].image = IMAGE[enum.imagePlanet8]

    PLANETS[9].image = IMAGE[enum.imagePlanet9]
    PLANETS[10].image = IMAGE[enum.imagePlanet10]
    PLANETS[11].image = IMAGE[enum.imagePlanet11]

    PLANETS[12].image = IMAGE[enum.imagePlanet12]
    PLANETS[13].image = IMAGE[enum.imagePlanet13]

    PLANETS[14].image = IMAGE[enum.imagePlanet14]
end

local function initialsePlanets()
    PLANETS = {}

    -- set a random scale into the planets table
    for i = 1, 14 do
        PLANETS[i] = {}
        PLANETS[i].scale = love.math.random(4,6) / 10
        PLANETS[i].tooltip = ""
    end

    local startx = 425
    local starty = 525

    PLANETS[1].x = startx       -- this is an easy way to shift and move the whole galaxy
    PLANETS[1].y = starty
    PLANETS[1].column = 1
    PLANETS[1].tooltip = "+3 pilot / +3 fighter"

    PLANETS[2].x = startx + 200
    PLANETS[2].y = starty - 150
	PLANETS[2].column = 2
    PLANETS[2].tooltip = "+2 pilot"
    PLANETS[3].x = startx + 200
    PLANETS[3].y = starty + 150
	PLANETS[3].column = 2
    PLANETS[3].tooltip = "+2 fighter"

    PLANETS[4].x = startx + 400
    PLANETS[4].y = starty - 300
	PLANETS[4].column = 3
    PLANETS[4].tooltip = "+1 fighter"
    PLANETS[5].x = startx + 400
    PLANETS[5].y = starty - 0
	PLANETS[5].column = 3
    PLANETS[5].tooltip = "+1 pilot"
    PLANETS[6].x = startx + 400
    PLANETS[6].y = starty + 300
	PLANETS[6].column = 3
    PLANETS[6].tooltip = "+1 fighter"

    PLANETS[7].x = startx + 600
    PLANETS[7].y = starty - 150
	PLANETS[7].column = 4
    -- PLANETS[7].tooltip = "+1 pilot"
    PLANETS[8].x = startx + 600
    PLANETS[8].y = starty + 150
	PLANETS[8].column = 4
    -- PLANETS[8].tooltip = "+1 fighter"

    PLANETS[9].x = startx + 800
    PLANETS[9].y = starty - 300
 	PLANETS[9].column = 5
    PLANETS[9].tooltip = "-1 fighter"
    PLANETS[10].x = startx + 800
    PLANETS[10].y = starty - 0
	PLANETS[10].column = 5
    PLANETS[10].tooltip = "-1 pilot"
    PLANETS[11].x = startx + 800
    PLANETS[11].y = starty + 300
	PLANETS[11].column = 5
    PLANETS[11].tooltip = "-1 fighter"

    PLANETS[12].x = startx + 1000
    PLANETS[12].y = starty - 150
 	PLANETS[12].column = 6
    PLANETS[12].tooltip = "-2 pilot"
    PLANETS[13].x = startx + 1000
    PLANETS[13].y = starty + 150
	PLANETS[13].column = 6
    PLANETS[13].tooltip = "-2 fighter"

    PLANETS[14].x = startx + 1200
    PLANETS[14].y = starty
	PLANETS[14].column = 7
    PLANETS[14].tooltip = "-3 pilot / -3 fighter"

    cf.saveTableToFile("planets.dat", PLANETS)          -- planets are unique each game so store that here
    loadImagesIntoPlanets()         -- loads images into the PLANETS table
end

local function startNewGame()

	initialiseRoster()
	initialiseHanger()
	initialiseFleet()
	initialsePlanets()      -- also saves to file

	cf.saveTableToFile("fleet.dat", FLEET)
	cf.saveTableToFile("roster.dat", ROSTER)
	cf.saveTableToFile("hanger.dat", HANGER)
	-- planets is saved after creation but before images are loaded

	cf.addScreen(enum.scenePlanetMap, SCREEN_STACK)
end

function mainmenu.keypressed( key, scancode, isrepeat )
    if key == "backspace" then
        playername = playername:sub(1, -2)
    elseif key == "space" then
        playername = playername .. " "
    end
end

function mainmenu.textinput(key)
    local ascii = string.byte(key)
    if (ascii >= 97 and ascii <= 122) or (ascii >= 65 and ascii <= 90) then
        if string.len(playername) <= 20 then
            playername = playername .. key
        else
            --! player error sound
        end
	elseif key == "backspace" then
        playername = playername:sub(1, -2)
	else
		--! player error sound
    end
end

function mainmenu.keyreleased(key, scancode)
    if key == "escape" then
		cf.removeScreen(SCREEN_STACK)
	elseif scancode == "return" or scancode == "kpenter" then
		if string.len(playername) > 0 then		-- maybe check for at least 3 chars
			startNewGame()
		end
	else
		--! player error sound
    end
end

function mainmenu.mousereleased(rx, ry, x, y, button)

    local clickedButtonID = buttons.getButtonID(rx, ry)

    if clickedButtonID == enum.buttonMainMenuNewGame then
        if newgame == false then
            -- can't start a new game unless a player name is provided
            newgame = true
        else
            if playername ~= "" then
        		-- initialise game
				startNewGame()
            else
                --! probably need an error sound here
            end
        end
	elseif clickedButtonID == enum.buttonMainMenuContinueGame then
		-- load game
        ROSTER = cf.loadTableFromFile("roster.dat")         --! test what happens when file doesn't exist.
        HANGER = cf.loadTableFromFile("hanger.dat")
        PLANETS = cf.loadTableFromFile("planets.dat")       -- planets change size so store that here
        FLEET = cf.loadTableFromFile("fleet.dat")

        loadImagesIntoPlanets()         -- loads images into the PLANETS table

		-- swap to fight scene
        cf.addScreen(enum.scenePlanetMap, SCREEN_STACK)

    elseif clickedButtonID == enum.buttonMainMenuExitGame then
        love.event.quit()
    end
end

function mainmenu.draw()

    love.graphics.draw(IMAGE[enum.imageMainMenu], 0, 0)
    love.graphics.draw(IMAGE[enum.imageMainMenuBanner], 250, 25, 0, 1.5, 1.5)

    -- draw player name
    if newgame then

        love.graphics.setFont(FONT[enum.fontCorporate])
        love.graphics.setColor(1,1,1,1)

        -- print label
        love.graphics.print("Enter your pilots first and name:", 485, 350)		--! need to split this into two boxes one day

        -- draw black rectangle
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle("fill", 480, 385, 270, 40)

        love.graphics.setColor(1,1,1,1)
        love.graphics.print(playername, 485, 390)
        love.graphics.setFont(FONT[enum.fontDefault])
    end


    buttons.drawButtons()
end

function mainmenu.loadButtons()
    -- call this from love.load()
    -- ensure buttons.drawButtons() is added to the scene.draw() function
    -- ensure scene.mousereleased() function is added

    -- local numofbuttons = 2      -- how many buttons on this form, assuming a single column
    -- local numofsectors = numofbuttons + 1
    -- local buttonsequence = 1            -- sequence on the screen

    -- button for new game
    local mybutton = {}
    mybutton.x = (SCREEN_WIDTH / 7)
    mybutton.y = SCREEN_HEIGHT / 2 - 150
    mybutton.width = 175
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "New game"
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
    mybutton.scene = enum.sceneMainMenu               -- change and add to enum
    mybutton.identifier = enum.buttonMainMenuNewGame     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table

    -- button for continue game
    local mybutton = {}
    mybutton.x = (SCREEN_WIDTH / 7)
    mybutton.y = SCREEN_HEIGHT / 2 -50
    mybutton.width = 175
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Continue game"
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
    mybutton.scene = enum.sceneMainMenu               -- change and add to enum
    mybutton.identifier = enum.buttonMainMenuContinueGame     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table

    -- button for exit game
    local mybutton = {}
    mybutton.x = (SCREEN_WIDTH / 7)
    mybutton.y = SCREEN_HEIGHT / 2 + 0
    mybutton.width = 175
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Exit game"
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
    mybutton.scene = enum.sceneMainMenu               -- change and add to enum
    mybutton.identifier = enum.buttonMainMenuExitGame     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table
end

return mainmenu

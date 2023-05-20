mainmenu = {}

local playername = ""
local newgame = false       -- set to true if clicking new game and prompting for player name

function mainmenu.keypressed( key, scancode, isrepeat )
    if key == "backspace" then
        playername = playername:sub(1, -2)
    elseif key == "space" then
        playername = playername .. " "
    end
end

function mainmenu.textinput(key)
    local ascii = string.byte(key)
    print(ascii)
    if (ascii >= 97 and ascii <= 122) or (ascii >= 65 and ascii <= 90) then
        if string.len(playername) <= 20 then
            playername = playername .. key
        else
            --! player error sound
        end
    end
    if key == "backspace" then
        playername = playername:sub(1, -2)
    else
    end
end

function mainmenu.keyreleased(key, scancode)
    if key == "escape" then
		cf.removeScreen(SCREEN_STACK)
    else

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
        		fun.initialiseRoster()
        		fun.initialiseHanger()
        		fun.initialiseFleet()
                fun.initialsePlanets()      -- also saves to file

                ROSTER[1].firstname = playername
                ROSTER[1].lastname = ""

                cf.saveTableToFile("fleet.dat", FLEET)
                cf.saveTableToFile("roster.dat", ROSTER)
                cf.saveTableToFile("hanger.dat", HANGER)
                -- planets is saved after creation but before images are loaded

        		cf.addScreen(enum.scenePlanetMap, SCREEN_STACK)
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

        fun.loadImagesIntoPlanets()         -- loads images into the PLANETS table

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
        love.graphics.print("Enter your pilots name:", 485, 350)

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

mainmenu = {}

local playername = ""
local field = InputField("Initial text.")
local fieldX = 480
local fieldY = 385

function mainmenu.keyreleased(key, scancode)
    if key == "escape" then
		cf.removeScreen(SCREEN_STACK)
	end
end

function mainmenu.keypressed(key, scancode, isRepeat)
	field:keypressed(key, isRepeat)
end

function mainmenu.textinput(text)
    field:textinput(text)
end

function mainmenu.mousepressed(rx, ry, x, y, button, isTouch)
    field:mousepressed(rx - fieldX, ry - fieldY, button, isTouch)         -- not sure if the isTouch works as intended
end

function mainmenu.mousemoved(x, y, dx, dy)
    field:mousemoved(x-fieldX, y-fieldY)        --! needs to be rx/ry?
end

function mainmenu.mousereleased(rx, ry, x, y, button)

    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonMainMenuNewGame then
        if playername == "" then

        else
    		-- initialise game
    		fun.initialiseRoster()
    		fun.initialiseHanger()
    		fun.initialiseFleet()
            fun.initialsePlanets()      -- also saves to file

            cf.saveTableToFile("fleet.dat", FLEET)
            cf.saveTableToFile("roster.dat", ROSTER)
            cf.saveTableToFile("hanger.dat", HANGER)
            -- planets is saved after creation but before images are loaded

    		cf.addScreen(enum.scenePlanetMap, SCREEN_STACK)
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

    field:mousereleased(rx - fieldX, ry - fieldY, button)

end

function mainmenu.wheelmoved(x,y)
    field:wheelmoved(x, y)
end

function mainmenu.draw()

    love.graphics.draw(IMAGE[enum.imageMainMenu], 0, 0)
    love.graphics.draw(IMAGE[enum.imageMainMenuBanner], 250, 25, 0, 1.5, 1.5)

    -- draw text field
    love.graphics.setFont(FONT[enum.fontCorporate])
    -- draw black box
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", fieldX - 5, fieldY - 5, 150, 40)

    love.graphics.setColor(0, 0, 1)
	for _, x, y, w, h in field:eachSelection() do
		love.graphics.rectangle("fill", fieldX+x, fieldY+y, w, h)
	end

	love.graphics.setColor(1, 1, 1)
	for _, text, x, y in field:eachVisibleLine() do
		love.graphics.print(text, fieldX+x, fieldY+y)
	end

	local x, y, h = field:getCursorLayout()
    love.graphics.rectangle("fill", fieldX + x, fieldY + y, 1, h)
    love.graphics.setFont(FONT[enum.fontDefault])

    buttons.drawButtons()

    -- print(field:getText( ))
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

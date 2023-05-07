mainmenu = {}

function mainmenu.mousereleased(rx, ry, x, y, button)

    local clickedButtonID = buttons.getButtonID(rx, ry)

    if clickedButtonID == enum.buttonMainMenuNewGame then
		--! initialise game
		fun.initialiseRoster()
		fun.initialiseHanger()
		fun.initialiseSector()
        cf.swapScreen(enum.sceneBattleRoster, SCREEN_STACK)
	elseif clickedButtonID == enum.buttonMainMenuContinueGame then
		--! load game
		--! swap to fight scene
    elseif clickedButtonID == enum.buttonMainMenuExitGame then
        love.event.quit()
    end
end

function mainmenu.draw()

    love.graphics.draw(IMAGE[enum.imageMainMenu], 0, 0)
    love.graphics.draw(IMAGE[enum.imageMainMenuBanner], 250, 25, 0, 1.5, 1.5)


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

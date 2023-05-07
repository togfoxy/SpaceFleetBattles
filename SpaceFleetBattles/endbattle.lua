endbattle = {}

--! be sure to clear the squad_list and OBJECTS at the end of eacy battle
--! be sure to take pilots out of fighters
--!fightsceneHasLoaded = false

function endbattle.draw()

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
        local txt = ROSTER[i].firstname .. " " .. ROSTER[i].lastname .. " " .. ROSTER[i].health .. " " .. ROSTER[i].missions .. " " .. ROSTER[i].kills .. " " .. ROSTER[i].ejections
        love.graphics.print(txt, drawx, drawy)
        drawy = drawy + 30
    end

	-- draw fighters in hanger
    local drawx = 900
    local drawy = 100
    love.graphics.setColor(1,1,1,1)
    for i = 1, #HANGER do
        local txt = string.sub(HANGER[i].guid, -2)
        txt = txt .. " " .. HANGER[i].componentHealth[enum.componentStructure]
        love.graphics.print(txt, drawx, drawy)
        drawy = drawy + 30
    end



    -- love.graphics.setColor(1,1,1,1)
    -- local txt = "Friendly ships lost: " .. SCORE.friendsdead
    -- love.graphics.print(txt, 100, 100)
    -- local txt = "Enemy ships destroyed: " .. SCORE.enemiesdead
    -- love.graphics.print(txt, 100, 150)
    --
    -- if fun.isPlayerAlive() then
    --     txt = "Player survived"
    -- else
    --     txt = "Player was lost in battle"
    -- end
    -- love.graphics.print(txt, 100, 200)
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
    mybutton.y = SCREEN_HEIGHT / 2 - 100
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
    mybutton.scene = enum.sceneEndBattle             -- change and add to enum
    mybutton.identifier = enum.buttonEndBattleNewGame     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table

    -- button for exit game
    local mybutton = {}
    mybutton.x = (SCREEN_WIDTH / 2) - 75
    mybutton.y = SCREEN_HEIGHT / 2 + 150
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
    mybutton.scene = enum.sceneEndBattle             -- change and add to enum
    mybutton.identifier = enum.buttonEndBattleExitGame     -- change and add to enum
    table.insert(GUI_BUTTONS, mybutton) -- this adds the button to the global table
end

return endbattle

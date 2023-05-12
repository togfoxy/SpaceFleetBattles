planetmap = {}

function planetmap.mousereleased(rx, ry, x, y, button)

    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonPlanetMapBattleStations then
        cf.swapScreen(enum.sceneBattleRoster, SCREEN_STACK)
    end
end

local function drawPlanets()

    love.graphics.draw(IMAGE[enum.imagePlanetBG], 0, 0, 0, 2, 2)

    love.graphics.draw(IMAGE[enum.imagePlanet1], 200, 400, 0, 0.5, 0.5)

    love.graphics.draw(IMAGE[enum.imagePlanet2], 400, 250, 0, 0.5, 0.5)
    love.graphics.draw(IMAGE[enum.imagePlanet3], 400, 550, 0, 0.5, 0.5)

    love.graphics.draw(IMAGE[enum.imagePlanet4], 600, 100, 0, 0.5, 0.5)
    love.graphics.draw(IMAGE[enum.imagePlanet5], 600, 400, 0, 0.5, 0.5)
    love.graphics.draw(IMAGE[enum.imagePlanet6], 600, 700, 0, 0.5, 0.5)

    love.graphics.draw(IMAGE[enum.imagePlanet7], 800, 250, 0, 0.5, 0.5)
    love.graphics.draw(IMAGE[enum.imagePlanet8], 800, 550, 0, 0.5, 0.5)

    love.graphics.draw(IMAGE[enum.imagePlanet9], 1000, 100, 0, 0.5, 0.5)
    love.graphics.draw(IMAGE[enum.imagePlanet10], 1000, 400, 0, 0.5, 0.5)
    love.graphics.draw(IMAGE[enum.imagePlanet11], 1000, 700, 0, 0.5, 0.5)

    love.graphics.draw(IMAGE[enum.imagePlanet12], 1200, 250, 0, 0.5, 0.5)
    love.graphics.draw(IMAGE[enum.imagePlanet13], 1200, 550, 0, 0.5, 0.5)

    love.graphics.draw(IMAGE[enum.imagePlanet14], 1400, 400, 0, 0.5, 0.5)


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

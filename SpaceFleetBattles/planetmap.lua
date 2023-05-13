planetmap = {}

function planetmap.mousereleased(rx, ry, x, y, button)

    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonPlanetMapBattleStations then
        cf.swapScreen(enum.sceneBattleRoster, SCREEN_STACK)
    end
end

local function drawPlanets()

    -- draw bg
    love.graphics.draw(IMAGE[enum.imagePlanetBG], 0, 0, 0, 2, 2)

    -- draw planets
    for i = 1, #PLANETS do
        love.graphics.draw(PLANETS[i].image, PLANETS[i].x, PLANETS[i].y, 0, PLANETS[i].scale, PLANETS[i].scale)

    end

    -- draw players fleet
    local sector = FLEET.sector
    local drawx = PLANETS[sector].x         -- this is top left corner of the planet
    local drawy = PLANETS[sector].y
    local scale = PLANETS[sector].scale
    love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle("line", drawx+12, drawy + 12, 250 * scale, 250 * scale)



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

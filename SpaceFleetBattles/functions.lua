functions = {}

function functions.loadImages()
    IMAGE[enum.imageExplosion] = love.graphics.newImage("assets/images/SmokeFireQuads.png")
end

function functions.loadFonts()
    FONT[enum.fontDefault] = love.graphics.newFont("assets/fonts/Vera.ttf", 12)
    FONT[enum.fontMedium] = love.graphics.newFont("assets/fonts/Vera.ttf", 14)
    FONT[enum.fontLarge] = love.graphics.newFont("assets/fonts/Vera.ttf", 18)
    FONT[enum.fontCorporate] = love.graphics.newFont("assets/fonts/CorporateGothicNbpRegular-YJJ2.ttf", 36)
    FONT[enum.fontalienEncounters48] = love.graphics.newFont("assets/fonts/aliee13.ttf", 48)

    love.graphics.setFont(FONT[enum.fontDefault])
end

function functions.loadAudio()
    -- AUDIO[enum.audioMainMenu] = love.audio.newSource("assets/audio/XXX.mp3", "stream")
end

function functions.createAnimation(objx, objy, objangle, animtype)
    -- obj: the x, y and angle of the object displaying the animation
    -- input: animtype == enum for displaying different types of animations

    if animtype == enum.animExplosion then
        local grid = GRIDS[enum.gridExplosion]
        local frames = grid('1-4', '3-4')
        local anim = anim8.newAnimation(frames, 0.15)
        anim.drawx = objx
        anim.drawy = objy
        anim.angle = objangle

        anim.duration = 0.9 	-- seconds
        table.insert(ANIMATIONS, anim)
    end
end

function functions.updateAnimations(dt)
	for i = #ANIMATIONS, 1, -1 do
		ANIMATIONS[i]:update(dt)

		ANIMATIONS[i].duration = ANIMATIONS[i].duration - dt
		if ANIMATIONS[i].duration <= 0 then
			table.remove(ANIMATIONS, i)
		end
	end
end

function functions.getImpactedComponent(Obj)

    local totalsize = 0
    for i = 1, #Obj.componentSize do
        totalsize = totalsize + Obj.componentSize[i]
    end
    local rndnum = love.math.random(1, totalsize)
    local tempvalue = totalsize
    for k, v in pairs(Obj.componentSize) do
        -- print(k, v)
        rndnum = rndnum - v
        if rndnum <= 0 then return k end
    end
    error()     -- should not reach this point
end


return functions

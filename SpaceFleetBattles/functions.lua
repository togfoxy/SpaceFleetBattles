functions = {}

function functions.loadImages()
    IMAGE[enum.imageExplosion] = love.graphics.newImage("assets/images/SmokeFireQuads.png")
    IMAGE[enum.imageBulletSmoke] = love.graphics.newImage("assets/images/spr_smoke_strip24.png")
    IMAGE[enum.imageFightHUD] = love.graphics.newImage("assets/images/fighthud.png")
    IMAGE[enum.imageFightBG] = love.graphics.newImage("assets/images/background1.png")
    IMAGE[enum.imageEscapePod] = love.graphics.newImage("assets/images/pod.png")
    IMAGE[enum.imageMainMenu] = love.graphics.newImage("assets/images/1172814.jpg")
    IMAGE[enum.imageMainMenuBanner] = love.graphics.newImage("assets/images/mainmenutitle.png")
    IMAGE[enum.imageBattleRoster] = love.graphics.newImage("assets/images/207634_1920_1217.png")
    IMAGE[enum.imageEndBattle] = love.graphics.newImage("assets/images/982225.jpg")

    IMAGE[enum.imageCrosshairsHasTarget] = love.graphics.newImage("assets/images/image0017.png")
    IMAGE[enum.imageCrosshairsIsTarget] = love.graphics.newImage("assets/images/image0018.png")
    IMAGE[enum.imageCrosshairPlayer] = love.graphics.newImage("assets/images/crosshair_me.png")
	IMAGE[enum.imageCrosshairPlanet] = love.graphics.newImage("assets/images/image0010.png")

    IMAGE[enum.imagePlanet1] = love.graphics.newImage("assets/images/planet1.png")
    IMAGE[enum.imagePlanet2] = love.graphics.newImage("assets/images/planet2.png")
    IMAGE[enum.imagePlanet3] = love.graphics.newImage("assets/images/planet3.png")
    IMAGE[enum.imagePlanet4] = love.graphics.newImage("assets/images/planet4.png")
    IMAGE[enum.imagePlanet5] = love.graphics.newImage("assets/images/planet5.png")
    IMAGE[enum.imagePlanet6] = love.graphics.newImage("assets/images/planet6.png")
    IMAGE[enum.imagePlanet7] = love.graphics.newImage("assets/images/planet7.png")
    IMAGE[enum.imagePlanet8] = love.graphics.newImage("assets/images/planet8.png")
    IMAGE[enum.imagePlanet9] = love.graphics.newImage("assets/images/planet9.png")
    IMAGE[enum.imagePlanet10] = love.graphics.newImage("assets/images/planet10.png")
    IMAGE[enum.imagePlanet11] = love.graphics.newImage("assets/images/planet11.png")
    IMAGE[enum.imagePlanet12] = love.graphics.newImage("assets/images/planet12.png")
    IMAGE[enum.imagePlanet13] = love.graphics.newImage("assets/images/planet13.png")
    IMAGE[enum.imagePlanet14] = love.graphics.newImage("assets/images/planet14.png")

    IMAGE[enum.imagePlanetBG] = love.graphics.newImage("assets/images/bd_space_seamless_fl1.png")

    IMAGE[enum.imageFighterFriend] = love.graphics.newImage("assets/images/blueships1_128x94.png")
    IMAGE[enum.imageFighterFoe] = love.graphics.newImage("assets/images/spshipsprite.png")

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
    AUDIO[enum.audioBulletHit] = love.audio.newSource("assets/audio/cannon_fire.ogg", "static")
    AUDIO[enum.audioBulletPing] = love.audio.newSource("assets/audio/ricochet_1.mp3", "static")
    AUDIO[enum.audioMouseClick] = love.audio.newSource("assets/audio/click.wav", "static")
end

function functions.createAnimation(Obj, animtype)
    -- obj: the x, y and angle of the object displaying the animation
    -- input: animtype == enum for displaying different types of animations

    local objx = Obj.body:getX()
    local objy = Obj.body:getY()
    local objangle = Obj.body:getAngle()
    if animtype == enum.animExplosion then
        local grid = GRIDS[enum.gridExplosion]
        local frames = grid('1-4', '3-4')
        local anim = anim8.newAnimation(frames, 0.15)
        anim.drawx = objx
        anim.drawy = objy
        anim.angle = objangle
        anim.attachtoobject = nil
        anim.duration = 0.9 	-- seconds
        anim.type = animtype
        table.insert(ANIMATIONS, anim)
    elseif animtype == enum.animSmoke then
        local grid = GRIDS[enum.gridExplosion]
        local frames = grid('1-4', '1-2')           -- cols then row
        local anim = anim8.newAnimation(frames, 0.15)
        anim.drawx = objx
        anim.drawy = objy
        anim.angle = objangle
        anim.attachtoobject = Obj       -- put the actual object here to make the animation move with this object
        anim.duration = 0.9 	-- seconds
        anim.type = animtype
        table.insert(ANIMATIONS, anim)
    elseif animtype == enum.animBulletSmoke then
        local grid = GRIDS[enum.gridBulletSmoke]
        local frames = grid('12-24', 1)                   -- cols then rows
        local anim = anim8.newAnimation(frames, 0.03)          -- frames, duration
        anim.drawx = objx
        anim.drawy = objy
        anim.angle = objangle
        anim.attachtoobject = nil       -- put the actual object here to make the animation move with this object
        anim.duration = 0.36 	-- seconds
        anim.type = animtype
        table.insert(ANIMATIONS, anim)
    elseif animtype == enum.animDebugging then
        local grid = GRIDS[enum.gridExplosion]
        local frames = grid('1-4', '3-4')
        local anim = anim8.newAnimation(frames, 10)
        anim.drawx = objx
        anim.drawy = objy
        anim.angle = objangle
        anim.attachtoobject = Obj
        anim.duration = 10 	-- seconds
        anim.type = animtype
        table.insert(ANIMATIONS, anim)
    end
end

function functions.updateAnimations(dt)
	for i = #ANIMATIONS, 1, -1 do
        if ANIMATIONS[i].attachtoobject ~= nil then
            -- update the x/y of this animation
            if not ANIMATIONS[i].attachtoobject.body:isDestroyed() then
                ANIMATIONS[i].drawx = ANIMATIONS[i].attachtoobject.body:getX()
                ANIMATIONS[i].drawy = ANIMATIONS[i].attachtoobject.body:getY()
                ANIMATIONS[i].angle = ANIMATIONS[i].attachtoobject.body:getAngle()
            end
        end
        ANIMATIONS[i].duration = ANIMATIONS[i].duration - dt
        ANIMATIONS[i]:update(dt)
        if ANIMATIONS[i].duration <= 0 then
			table.remove(ANIMATIONS, i)
		end
	end
end

function functions.setTaskEject(Obj)

    print("Setting action to eject")
    -- update pilot stats
    local pilot = fun.getPilot(Obj.pilotguid)
    if pilot ~= nil then pilot.ejections = pilot.ejections + 1 end

    local thisObj = {}
    thisObj.podx, thisObj.pody = Obj.body:getPosition()
    thisObj.forf = Obj.forf
    thisObj.guid = Obj.guid
    thisObj.squadCallsign = Obj.squadcallsign
    table.insert(POD_QUEUE, thisObj)        -- Box2D won't let an object to be created inside contact event so queue it here

    Obj.lifetime = 0
    Obj.actions = {}

    -- remove fighter from hanger
    for i = #HANGER, 1, -1 do
        if HANGER[i].guid == Obj.guid then
            table.remove(HANGER, i)
            print("Removed fighter guid from hanger: " .. Obj.guid)
        end
    end
end

function functions.getObject(guid)
    -- cycle through OBJECTS until found GUID
    -- returns that object or nil
    for i = 1, #OBJECTS do
        if OBJECTS[i].guid == guid then
            return OBJECTS[i]
        end
    end
    return nil
end

function functions.unitIsTargeted(guid)
    -- return true if any object has this guid as a target
    for _, Obj in pairs(OBJECTS) do
        if Obj.actions ~= nil then
            if Obj.actions[1] ~= nil then
                if Obj.actions[1].targetguid == guid then
                    return true
                end
            end
        end
    end
    return false
end

function functions.createNewPilot()
    -- retun a pilot object
    -- get random name
    local firstnameindex = love.math.random(1, #FIRSTNAMES)
    local lastnameindex = love.math.random(1, #LASTNAMES)

    local thispilot = {}
    thispilot.guid = cf.getGUID()
    thispilot.firstname = FIRSTNAMES[firstnameindex]
    thispilot.lastname = LASTNAMES[lastnameindex]
    thispilot.health = 100
    thispilot.vesselguid = nil
    thispilot.kills = 0
    thispilot.missions = 0
    thispilot.ejections = 0
    thispilot.isDead = false
    return thispilot
end

function functions.getPilot(guid)
    -- scans the ROSTER for the provided guid. Returns nil if not found or foe guid provided
    -- NOTE: this is different to getPlayerPilot
    for i = 1, #ROSTER do
        if ROSTER[i].guid == guid then return ROSTER[i] end
    end
    return nil
end

function functions.getPlayerPilot()
	-- scans ROSTER and returns the pilot object that is the player object or returns nil
    -- NOTE: this is different to getPilot
	for i = 1, #ROSTER do
		if ROSTER[i].isPlayer then
			return ROSTER[i]
		end
	end
	return nil
end

function functions.getLaunchXY(forf)
    -- returns an x and y depending on forf
    -- is called from multiple places
    local rndx, rndy
    if forf == enum.forfFriend then
        -- rndx = love.math.random(50, SCREEN_WIDTH /3)
        rndx = FRIEND_START_X + love.math.random(-10, 10)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    elseif forf == enum.forfEnemy then
        -- rndx = love.math.random(SCREEN_WIDTH * 0.66, SCREEN_WIDTH - 50)
        rndx = FOE_START_X + love.math.random(-10, 10)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    elseif forf == enum.forfNeutral then
        rndx = love.math.random(50, SCREEN_WIDTH - 50)
        rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    else
        error()
    end
    return rndx, rndy
end

function functions.getTopAction(Obj)
    -- return the top most action table that includes the action type and cooldown etc
    -- else returns nil
    assert(Obj ~= nil)

    if Obj.actions ~= nil and #Obj.actions > 0 then
        if Obj.actions[1] ~= nil then
            if Obj.actions[1].action ~= nil then
                return Obj.actions[1]
            elseif Obj.actions[1].action ~= nil then
                return Obj.actions[2]
            end
        end
    end
    return nil
end

function functions.getActivePilotCount()
	-- scans the roster and counts the number of pilots not dead
	local result = 0
	for i = 1, #ROSTER do
		if not ROSTER[i].isDead then
			result = result + 1
		end
	end
	return result
end

function functions.getActiveFighterCount(forf)
    local result = 0
    for i = 1, #HANGER do
        if HANGER[i].forf == forf then result = result + 1 end
    end
    return result
end

function functions.ImportNameFile(filename)

    local thistable = {}
    local savefile = savedir .. filename
    for line in io.lines(savefile) do
        table.insert(thistable, line)
    end
    return thistable
end

return functions

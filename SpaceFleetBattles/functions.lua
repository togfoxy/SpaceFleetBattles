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
        anim.drawy = objy + 5
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
        anim.drawy = objy + 5
        anim.angle = objangle
        anim.attachtoobject = nil       -- put the actual object here to make the animation move with this object
        anim.duration = 0.36 	-- seconds
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

local function getImpactedComponent(Obj)

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

function functions.setTaskEject(Obj)
    Obj.lifetime = 0
    Obj.actions = {}
    print("Setting action to eject")

    local thisObj = {}
    thisObj.podx, thisObj.pody = Obj.body:getPosition()
    thisObj.forf = Obj.forf
    thisObj.guid = Obj.guid
    thisObj.squadCallsign = Obj.squadcallsign
    table.insert(POD_QUEUE, thisObj)        -- Box2D won't let an object to be created inside contact event so queue it here

    -- update pilot stats
    local pilot = fun.getPilot(Obj.pilotguid)
    if pilot ~= nil then pilot.ejections = pilot.ejections + 1 end

    -- remove fighter from hanger, noting foe fighers don't have a hanger
    for i = #HANGER, 1, -1 do
        if HANGER[i].guid == Obj.guid then
            table.remove(HANGER, i)
            print("Removed fighter guid from hanger: " .. Obj.guid)
        end
    end
end

local function giveKillCredit(bullet)
    -- give kill credit to the pilot
    local vesselguid = bullet.ownerObjectguid           -- this is the vessel that shot the bullet
    local vesselobj = fun.getObject(vesselguid)
    local pilotguid = vesselobj.pilotguid

    local shooter = fun.getPilot(pilotguid)
    if shooter ~= nil then
        shooter.kills = shooter.kills + 1
    else
        -- shooter = nil for some reason. Print debug if bullet is friendly
        if bullet.forf == enum.forfFriend then
            print("********************")
            print(inspect(ROSTER))
            print(inspect(bullet))
            print(shooterguid)
            print(inspect(shooter))
            error()
        end
    end
end

local function destroyVictim(victim, bullet)

	fun.createAnimation(victim, enum.animExplosion)
	if victim.forf == enum.forfFriend then
		SCORE.friendsdead = SCORE.friendsdead + 1
		FOE_FIGHTER_COUNT = FOE_FIGHTER_COUNT - 1
		FOE_PILOT_COUNT = FOE_PILOT_COUNT - 1
	elseif victim.forf == enum.forfEnemy then
		SCORE.enemiesdead = SCORE.enemiesdead + 1
	end
	victim.lifetime = 0
	unitai.clearTarget(victim.guid)		-- remove this guid from everyone's target
	print("Unit exploded")

	--! play explosion sound here

	-- give kill credit
	giveKillCredit(bullet)

	-- remove friendly pilots from roster by marking isDead
	local pilotguid = victim.pilotguid
	local pilotobj = fun.getPilot(pilotguid)
	if pilotobj ~= nil then pilotobj.isDead = true end
    if pilotguid == PLAYER_GUID then pilotobj.isPlayer = false end      --! check to see if this has unintended consequences

	-- remove fighter from hanger
	for i = #HANGER, 1, -1 do
		if HANGER[i].guid == victim.guid then
			table.remove(HANGER, i)
		end
	end
end

local function createDamageText(componenthit, victim)
	local txt = ""
	if componenthit == enum.componentAccelerator then
		txt = "Throttle"
	elseif componenthit == enum.componentSideThruster then
		txt = "Steering"
	elseif componenthit == enum.componentStructure then
		txt = "Structure"
	elseif componenthit == enum.componentThruster then
		txt = "Thrusters"
	elseif componenthit == enum.componentWeapon then
		txt = "Weapon"
	else
		error()
	end

	local thistext = {}
	thistext.text = txt
	thistext.object = victim
	thistext.timeleft = 4			-- how many seconds to display
	table.insert(DAMAGETEXT, thistext)
    -- print(inspect(DAMAGETEXT))
    -- print("*******************")
end

local function addEvadeAction(victim)
	-- insert an action at the TOP of the queue

	local thisaction = {}
	if victim.forf == enum.forfFriend then
		-- set a destination random degrees from current location
		local objx, objy = victim.body:getPosition()
		local rndangle = love.math.random(-45, 45)
		local destx, desty = cf.addVectorToPoint(objx,objy,(270 + rndangle),300)

		thisaction.cooldown = 3
		thisaction.action = enum.unitActionMoveToDest
		thisaction.targetguid = nil							--! maybe not clear target when evading
		thisaction.destx = destx
		thisaction.desty = desty
	elseif victim.forf == enum.forfEnemy then
		local destx = FOE_START_X
		local desty = love.math.random(0, SCREEN_HEIGHT)

		thisaction.cooldown = 3
		thisaction.action = enum.unitActionMoveToDest
		thisaction.targetguid = nil							--! maybe not clear target when evading
		thisaction.destx = destx
		thisaction.desty = desty
	end

	table.insert(victim.actions, 1, thisaction)
	-- print("Evasive force applied")
end

local function checkForTrauma(victim)
	if victim.componentHealth[enum.componentWeapon] <= 0 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentThruster] <= 50 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentSideThruster] <= 50 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentAccelerator] <= 25 then
		victim.actions = {}         -- significant trauma. get a new task
	end
	if victim.componentHealth[enum.componentStructure] <= 33 then
		victim.actions = {}         -- significant trauma. get a new task
	end
end

function functions.applyDamage(victim, bullet)

    local componenthit = getImpactedComponent(victim)
    victim.componentHealth[componenthit] = victim.componentHealth[componenthit] - love.math.random(15, 35)
    if victim.componentHealth[componenthit] < 0 then victim.componentHealth[componenthit] = 0 end

	if victim.componentHealth[enum.componentStructure] <= 0 then
		-- boom. Victim is dead
		destroyVictim(victim, bullet)
    else
        -- victim not dead so attach a smoke animation to the object
        fun.createAnimation(victim, enum.animSmoke)

        -- play audio
        print("Hello")
        if fun.isPlayerAlive() and bullet.ownerObjectguid == PLAYER_FIGHTER_GUID then
            -- this bullet is the players bullet. Make an audible
            print("Playing HIT audio")
            cf.playAudio(enum.audioBulletHit, false, true)
        else
            print("alpha")
            print(bullet.ownerObjectguid, PLAYER_FIGHTER_GUID)
        end

		-- see if ejects
		local rndnum = love.math.random(1, 35)	-- ejection is a dice roll
		if victim.componentHealth[enum.componentStructure] <= 35 and rndnum > victim.componentHealth[enum.componentStructure] then
            if rndnum > victim.componentHealth[enum.componentStructure] then       -- more damage = more chance of eject
                fun.setTaskEject(victim)
                -- give kill credit
                giveKillCredit(bullet)

				if victim.forf == enum.forfFriend then
					SCORE.friendsEjected = SCORE.friendsEjected + 1
				elseif victim.forf == enum.forfEnemy then
					SCORE.enemiesEjected = SCORE.enemiesEjected + 1
				end
			end
		else	-- not dead and not ejecting
			-- prep component hit if victim = player or victim = player target
			if victim.guid == PLAYER_FIGHTER_GUID or bullet.ownerObjectguid == PLAYER_FIGHTER_GUID then
				createDamageText(componenthit, victim)
			end

			-- apply a small evasion wobble if trying to RTB
			local action = fun.getTopAction(victim)

			if action ~= nil and action.action == enum.unitActionReturningToBase then
				-- been hit while RTB. Try to evade.
				-- insert an action at the TOP of the queue
				addEvadeAction(victim)
			else
				-- not dead and not ejecting and not RTB
				-- Unit is still in the fight. Clear action queue if traumatic damage taken
				checkForTrauma(victim)
			end
		end

		-- adjust object performance after receiving battle damage
		victim.currentMaxForwardThrust = victim.maxForwardThrust * (victim.componentHealth[enum.componentThruster] / 100)
		victim.currentMaxAcceleration = victim.maxAcceleration * (victim.componentHealth[enum.componentAccelerator] / 100)
		victim.currentSideThrust = victim.maxSideThrust * (victim.componentHealth[enum.componentSideThruster] / 100)
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

function functions.isPlayerAlive()
    -- only works on fight screen. --! I should move it there and make it local
    -- this returns true if the players fighter is alive
    for i = 1, #OBJECTS do
        if OBJECTS[i].guid == PLAYER_FIGHTER_GUID then
            return true
        end
    end
    return false
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
    assert(Obj ~= nil)

    if Obj.actions ~= nil and #Obj.actions > 0 then
        if Obj.actions[1] ~= nil then
            if Obj.actions[1].action ~= nil then
                return Obj.actions[1]
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

function functions.ImportNameFile(filename)

    local thistable = {}
    local savefile = savedir .. filename
    for line in io.lines(savefile) do
        table.insert(thistable, line)
    end
    return thistable
end

return functions

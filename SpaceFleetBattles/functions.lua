functions = {}

function functions.loadImages()
    IMAGE[enum.imageExplosion] = love.graphics.newImage("assets/images/SmokeFireQuads.png")
    IMAGE[enum.imageFightHUD] = love.graphics.newImage("assets/images/fighthud.png")
    IMAGE[enum.imageFightBG] = love.graphics.newImage("assets/images/background1.png")
    IMAGE[enum.imageEscapePod] = love.graphics.newImage("assets/images/pod.png")
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
        local frames = grid('1-4', '1-2')
        local anim = anim8.newAnimation(frames, 0.15)
        anim.drawx = objx
        anim.drawy = objy
        anim.angle = objangle
        anim.attachtoobject = Obj       -- put the actual object here to make the animation move with this object
        anim.duration = 0.9 	-- seconds
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

function functions.applyDamage(victim, bullet)

    local componenthit = fun.getImpactedComponent(victim)
    victim.componentHealth[componenthit] = victim.componentHealth[componenthit] - love.math.random(15, 35)
    if victim.componentHealth[componenthit] < 0 then victim.componentHealth[componenthit] = 0 end

	--! debugging
	if victim.guid == PLAYER_GUID then
		-- print(inspect(victim.componentHealth))
	end

    print(victim.componentHealth[enum.componentStructure])
	if victim.componentHealth[enum.componentStructure] <= 0 then
		-- boom. Victim is dead
		fun.createAnimation(victim, enum.animExplosion)
        if victim.forf == enum.forfFriend then
            SCORE.friendsdead = SCORE.friendsdead + 1
        elseif victim.forf == enum.forfEnemy then
            SCORE.enemiesdead = SCORE.enemiesdead + 1
        end
        victim.lifetime = 0
        unitai.clearTarget(victim.guid)		-- remove this guid from everyone's target
        print("Unit exploded")
    else
        -- victim not dead so attach a smoke animation to the object
        fun.createAnimation(victim, enum.animSmoke)
        if fun.isPlayerAlive() and bullet.ownerObjectguid == PLAYER_GUID then
            -- this bullet is the players bullet. Make an audible
            cf.playAudio(enum.audioBulletHit, false, true)
        end
	end

    -- adjust object performance after receiving battle damage
    victim.currentMaxForwardThrust = victim.maxForwardThrust * (victim.componentHealth[enum.componentThruster] / 100)
    victim.currentMaxAcceleration = victim.maxAcceleration * (victim.componentHealth[enum.componentAccelerator] / 100)
    victim.currentSideThrust = victim.maxSideThrust * (victim.componentHealth[enum.componentSideThruster] / 100)

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

    for i = 1, #OBJECTS do
        if OBJECTS[i].guid == PLAYER_GUID then
            return true
        end
    end
    return false
end

function functions.unitIsTargeted(guid)
    -- return true if any object has this guid as a target
    for i = 1, #OBJECTS do
        if OBJECTS[i].targetguid == guid then
            return true
        end
    end
    return false
end

return functions

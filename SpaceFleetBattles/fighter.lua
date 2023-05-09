fighter = {}

function fighter.createFighter(forf)
    -- forf = friend or foe.  See enums
    -- returns an object that is a fighter

    assert(forf ~= nil)

    local rndx, rndy = fun.getLaunchXY(forf)

    local thisobject = {}
    thisobject.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy, "dynamic")
	thisobject.body:setLinearDamping(0)
	-- thisobject.body:setMass(100)
    if forf == enum.forfEnemy then
        thisobject.body:setAngle(math.pi)
    end

    thisobject.shape = love.physics.newPolygonShape( -5, -5, 5, 0, -5, 5, -7, 0)
	thisobject.fixture = love.physics.newFixture(thisobject.body, thisobject.shape, 1)		-- the 1 is the density
	thisobject.fixture:setRestitution(0.25)
	thisobject.fixture:setSensor(false)

    if forf == enum.forfFriend then
        thisobject.fixture:setCategory(enum.categoryFriendlyFighter)
        thisobject.fixture:setMask(enum.categoryFriendlyFighter, enum.categoryFriendlyBullet, enum.categoryEnemyFighter)
    else
        thisobject.fixture:setCategory(enum.categoryEnemyFighter)
        thisobject.fixture:setMask(enum.categoryEnemyFighter, enum.categoryEnemyBullet, enum.categoryFriendlyFighter)   -- these are the things that will not trigger a collision
    end

    local guid = cf.getGUID()
	thisobject.fixture:setUserData(guid)
    thisobject.guid = guid
	thisobject.pilotguid = nil

    thisobject.forf = forf
    thisobject.squadCallsign = nil
    thisobject.actions = {}
    thisobject.weaponcooldown = 0           --! might be more than one weapon in the future

    thisobject.currentMaxForwardThrust = 100    -- can be less than max if battle damaged
    thisobject.maxForwardThrust = 100
    thisobject.currentForwardThrust = 0
    thisobject.maxAcceleration = 25
    thisobject.maxDeacceleration = 25       -- set to 0 for bullets
    thisobject.currentMaxAcceleration = 25 -- this can be less than maxAcceleration if battle damaged
    thisobject.maxSideThrust = 1
    thisobject.currentSideThrust = 1

    thisobject.componentSize = {}
    thisobject.componentSize[enum.componentStructure] = 3
    thisobject.componentSize[enum.componentThruster] = 2
    thisobject.componentSize[enum.componentAccelerator] = 1
    thisobject.componentSize[enum.componentWeapon] = 1
    thisobject.componentSize[enum.componentSideThruster] = 1

    thisobject.componentHealth = {}
    thisobject.componentHealth[enum.componentStructure] = 100
    thisobject.componentHealth[enum.componentThruster] = 100
    thisobject.componentHealth[enum.componentAccelerator] = 100
    thisobject.componentHealth[enum.componentWeapon] = 100
    thisobject.componentHealth[enum.componentSideThruster] = 100

	return thisobject
end

function fighter.createFighterBody(hangerobject)
    -- receives a hanger object and creates a physical body for it.
    -- Operates on the hanger object and returns nothing
    assert(hangerobject ~= nil)

    local rndx, rndy = fun.getLaunchXY(hangerobject.forf)

    hangerobject.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy, "dynamic")
	hangerobject.body:setLinearDamping(0)
	-- hangerobject.body:setMass(100)
    if hangerobject.forf == enum.forfEnemy then
        hangerobject.body:setAngle(math.pi)
    end

    hangerobject.shape = love.physics.newPolygonShape( -5, -5, 5, 0, -5, 5, -7, 0)
	hangerobject.fixture = love.physics.newFixture(hangerobject.body, hangerobject.shape, 1)		-- the 1 is the density
	hangerobject.fixture:setRestitution(0.25)
	hangerobject.fixture:setSensor(false)

    if hangerobject.forf == enum.forfFriend then
        hangerobject.fixture:setCategory(enum.categoryFriendlyFighter)
        hangerobject.fixture:setMask(enum.categoryFriendlyFighter, enum.categoryFriendlyBullet, enum.categoryEnemyFighter)
    else
        hangerobject.fixture:setCategory(enum.categoryEnemyFighter)
        hangerobject.fixture:setMask(enum.categoryEnemyFighter, enum.categoryEnemyBullet, enum.categoryFriendlyFighter)   -- these are the things that will not trigger a collision
    end
	hangerobject.fixture:setUserData(hangerobject.guid)
end

function fighter.createHangerFighter(forf)
    -- creates a fighter for the hanger meaning there is no physics object
    -- returns a fighter object with no physics body

    assert(forf ~= nil)

    local rndx, rndy = fun.getLaunchXY(forf)

    local thisobject = {}
    local guid = cf.getGUID()
    thisobject.guid = guid
    thisobject.pilotguid = nil

    thisobject.forf = forf
    thisobject.squadCallsign = nil
    thisobject.actions = {}
    thisobject.weaponcooldown = 0           --! might be more than one weapon in the future

    thisobject.currentMaxForwardThrust = 100    -- can be less than max if battle damaged
    thisobject.maxForwardThrust = 100
    thisobject.currentForwardThrust = 0
    thisobject.maxAcceleration = 25
    thisobject.maxDeacceleration = 25       -- set to 0 for bullets
    thisobject.currentMaxAcceleration = 25 -- this can be less than maxAcceleration if battle damaged
    thisobject.maxSideThrust = 1
    thisobject.currentSideThrust = 1

    thisobject.componentSize = {}
    thisobject.componentSize[enum.componentStructure] = 3
    thisobject.componentSize[enum.componentThruster] = 2
    thisobject.componentSize[enum.componentAccelerator] = 1
    thisobject.componentSize[enum.componentWeapon] = 1
    thisobject.componentSize[enum.componentSideThruster] = 1

    thisobject.componentHealth = {}
    thisobject.componentHealth[enum.componentStructure] = 100
    thisobject.componentHealth[enum.componentThruster] = 100
    thisobject.componentHealth[enum.componentAccelerator] = 100
    thisobject.componentHealth[enum.componentWeapon] = 100
    thisobject.componentHealth[enum.componentSideThruster] = 100

    return thisobject
end

return fighter

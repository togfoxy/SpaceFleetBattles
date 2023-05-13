enums = {}

function enums.load()
    enum = {}

    enum.sceneMainMenu = 1
    enum.sceneCredits = 2
    enum.sceneFight = 3
    enum.sceneEndBattle = 4
	enum.sceneBattleRoster = 5
    enum.scenePlanetMap = 6

    enum.buttonMainMenuNewGame = 1
    enum.buttonMainMenuContinueGame = 2
	enum.buttonMainMenuExitGame = 3
    enum.buttonEndBattleNewGame = 4
    enum.buttonEndBattleExitGame = 5
	enum.buttonBattleRosterLaunch = 6
    enum.buttonPlanetMapBattleStations = 7

    enum.fontDefault = 1
    enum.fontMedium = 2
    enum.fontLarge = 3
    enum.fontCorporate = 4
    enum.fontalienEncounters48 = 5

    enum.audioMainMenu = 1
    enum.audioBulletPing = 2
    enum.audioBulletHit = 3

    -- add extra items below this line =================================

    enum.forfFriend = 1
    enum.forfEnemy = 2
    enum.forfNeutral = 3

    enum.categoryFriendlyFighter = 1
    enum.categoryEnemyFighter = 2
    enum.categoryFriendlyBullet = 3             -- includes missiles and bombs
    enum.categoryEnemyBullet = 4                -- includes missiles and bombs
    enum.categoryFriendlyPod = 5
    enum.categoryEnemyPod = 6

    enum.commanderOrdersEngage = 1
    enum.commanderOrdersReturnToBase = 2

    enum.squadOrdersEngage = 1
    enum.squadOrdersReturnToBase = 2

    enum.unitActionEngaging = 1
    enum.unitActionReturningToBase = 2
    enum.unitActionEject = 3
    enum.unitActionMoveToDest = 4

    enum.imageExplosion = 1
    enum.imageFightHUD = 2
    enum.imageFightBG = 3
    enum.imageEscapePod = 4
    enum.imageMainMenu = 5
    enum.imageMainMenuBanner = 6
    enum.imageBattleRoster = 7
    enum.imagePlanet1 = 20
    enum.imagePlanet2 = 21
    enum.imagePlanet3= 22
    enum.imagePlanet4 = 23
    enum.imagePlanet5 = 24
    enum.imagePlanet6 = 25
    enum.imagePlanet7 = 26
    enum.imagePlanet8 = 27
    enum.imagePlanet9 = 28
    enum.imagePlanet10 = 29
    enum.imagePlanet11 = 30
    enum.imagePlanet12 = 31
    enum.imagePlanet13 = 32
    enum.imagePlanet14 = 33
    enum.imagePlanet15 = 34
    enum.imagePlanet16 = 35
    enum.imagePlanet17 = 36

    enum.imagePlanetBG = 40
    enum.imageSmoke = 41


    enum.gridExplosion = 1
    enum.gridBulletSmoke = 2

    enum.animExplosion = 1
    enum.animSmoke = 2
    enum.animBulletSmoke = 3

    enum.componentStructure = 1
    enum.componentThruster = 2
    enum.componentAccelerator = 3
    enum.componentWeapon = 4
    enum.componentSideThruster = 5

end

return enums

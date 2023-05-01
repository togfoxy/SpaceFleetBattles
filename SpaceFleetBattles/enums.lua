enums = {}

function enums.load()
    enum = {}

    enum.sceneMainMenu = 1
    enum.sceneCredits = 2
    enum.sceneFight = 3

    enum.buttonMainMenuExitGame = 1
    enum.buttonMainMenuContinue = 2

    enum.fontDefault = 1
    enum.fontMedium = 2
    enum.fontLarge = 3
    enum.fontCorporate = 4
    enum.fontalienEncounters48 = 5

    enum.audioMainMenu = 1
    -- add extra items below this line

    enum.forfFriend = 1
    enum.forfEnemy = 2
    enum.forfNeutral = 3

    enum.categoryFriendlyFighter = 1
    enum.categoryEnemyFighter = 2
    enum.categoryFriendlyBullet = 3             -- includes missiles and bombs
    enum.categoryEnemyBullet = 4                -- includes missiles and bombs

    enum.commanderOrdersEngage = 1
    enum.commanderOrdersReturnToBase = 2

    enum.squadOrdersEngage = 1
    enum.squadOrdersReturnToBase = 2

    enum.imageExplosion = 1
    enum.imageFightHUD = 2

    enum.gridExplosion = 1

    enum.animExplosion = 1
    enum.animSmoke = 2

    enum.componentStructure = 1
    enum.componentThruster = 2
    enum.componentAccelerator = 3
    enum.componentWeapon = 4
    enum.componentSideThruster = 5

    enum.audioBulletPing = 1

end

return enums

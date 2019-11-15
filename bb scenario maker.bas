WIDTH 100, 20
PRINT "Do not include _scenario in the scenario name."
INPUT "Input Scenario FILE Name (THIS IS NOT THE DISPLAY NAME): ", scenario$
scenario$ = LTRIM$(RTRIM$(scenario$))

file$ = scenario$ + "_scenario.nut"

OPEN file$ FOR OUTPUT AS #1

quote$ = CHR$(34) 'Quotation Mark store
PRINT #1, "this." + scenario$ + "_scenario <- this.inherit(" + quote$ + "scripts/scenarios/world/starting_scenario" + quote$ + ", {"
PRINT #1, " m = {},"

'-----------------------------------------------------------
PRINT #1, "function create()"
PRINT #1, "{"
PRINT #1, "    this.m.ID = " + quote$ + "scenario." + scenario$ + quote$ + ";"

INPUT "Input Scenario's Display Name: ", dispName$
dispName$ = RTRIM$(LTRIM$(dispName$))

PRINT #1, "    this.m.Name = " + quote$ + dispName$ + quote$ + ";"

PRINT #1, "    this.m.Description = " + quote$ + "[p=c][img]gfx/ui/events/event_142.png[/img][/p] \n Placeholder Description. Change in function create()." + quote$ + ";"
PRINT #1, "    this.m.Difficulty = 2;"
INPUT "Input order number (anything after 20 is probably fine, try not to overlap): ", order%
PRINT #1, "    this.m.Order = " + STR$(order%) + ";"
PRINT #1, "    this.m.IsFixedLook = true;"
PRINT #1, "}"
'-----------------------------------------------------------

PRINT #1, "function isValid() { return this.Const.DLC.Wildmen; }"

'-----------------------------------------------------------
PRINT #1, "function onSpawnAssets()"
PRINT #1, "{"
PRINT #1, "local roster = this.World.getPlayerRoster()"
PRINT #1, ""

newBro$ = "Y"
hasPC% = 0
broNum% = 0
pcNum% = 0
WHILE (newBro$ = "Y")
    INPUT "Input New Bro's Background (e.g. legend_nun, or tailor, etc, DON'T INCLUDE _background): ", newBackground$
    newBackground$ = RTRIM$(LTRIM$(newBackground$))
    newBackground$ = newBackground$ + "_background"
    INPUT "Input Bro's Level: ", newLevel%
    newLevelUp% = newLevel% - 1
    PCCHECK:
    PRINT "Is current char a player character/avatar? y/n"
    playerChar$ = INPUT$(1)
    playerChar$ = UCASE$(playerChar$)
    IF playerChar$ = "Y" THEN
        pcNum% = pcNum% + 1
    ELSEIF playerChar$ <> "N" THEN
        GOTO PCCHECK:
    END IF

    'Assuming no free perks because I'm lazy.

    cBro$ = "bro" + LTRIM$(RTRIM$(STR$(broNum%)))
    PRINT #1, "local " + cBro$ + ";"
    PRINT #1, cBro$ + " = roster.create(" + quote$ + "scripts/entity/tactical/player" + quote$ + ");"
    PRINT #1, cBro$ + ".m.HireTime = this.Time.getVirtualTimeF();"
    PRINT #1, cBro$ + ".setStartValuesEx(["
    PRINT #1, quote$ + newBackground$ + quote$
    PRINT #1, "]);"
    PRINT #1, cBro$ + ".m.PerkPoints = " + STR$(newLevelUp%) + ";"
    PRINT #1, cBro$ + ".m.LevelUps = " + STR$(newLevelUp%) + ";"
    PRINT #1, cBro$ + ".m.Level = " + STR$(newLevel%) + ";"
    IF playerChar$ = "Y" THEN
        PRINT #1, cBro$ + ".setVeteranPerks(2);"
        PRINT #1, cBro$ + ".getTags().set(" + quote$ + "IsPlayerCharacter" + quote$ + ", true);"
        hasPC% = hasPC% + 1
    ELSE
        PRINT #1, cBro$ + ".setVeteranPerks(5);"
    END IF

    PERKQ:
    PRINT "Add perks to current brother? (e.g. nimble) (y/n)? THESE MAY NOT SHOW UP IN THE PERK TREE IF NOT GENERATED BUT WILL STILL BE THERE."
    PRINT "Include here all universal perks too (e.g. how seer gives everyone student, include here the perk_student)"
    PRINT "Later will have an onHire() perk addition, but this will not affect starting brothers!! Add starters perks here!!"
    perkYN$ = INPUT$(1)
    perkYN$ = UCASE$(perkYN$)
    IF perkYN$ = "Y" THEN
        PRINT "Perk name to add? Please DO write the full name (e.g. perk_nimble)! "
        PRINT "Some perks start with perk_legend, legend, and perk, so you must write the FULL name."
        PRINT "DON'T INCLUDE .NUT OR .CNUT"
        WHILE (perkYN$ = "Y")
            INPUT "new perk: type quit to stop adding perks: ", perk$
            perk$ = LCASE$(perk$)
            IF perk$ = "quit" THEN GOTO PERKBREAK
            PRINT #1, cBro$ + ".getSkills().add(this.new(" + quote$ + "scripts/skills/perks/" + perk$ + quote$ + "));"
        WEND
    ELSEIF UCASE$(perkYN$) = "N" THEN
        GOTO PERKBREAK
    ELSE GOTO PERKQ
    END IF
    PERKBREAK:

    TRAITQ:
    PRINT "Add traits to current brother? (e.g. dastard) (y/n)? "
    traitYN$ = INPUT$(1)
    traitYN$ = UCASE$(traitYN$)
    IF traitYN$ = "Y" THEN
        PRINT "Trait name to add? DON'T write the _trait at the end! "
        PRINT "Some but very few traits start with `legend_`"
        PRINT "DON'T INCLUDE .NUT OR .CNUT"
        WHILE (traitYN$ = "Y")
            INPUT "new trait: type quit to stop adding perks: ", trait$
            trait$ = LCASE$(trait$)
            IF trait$ = "quit" THEN GOTO TRAITBREAK
            PRINT #1, cBro$ + ".getSkills().add(this.new(" + quote$ + "scripts/skills/traits/" + trait$ + "_trait" + quote$ + "));"
        WEND
    ELSEIF UCASE$(traitYN$) = "N" THEN
        GOTO TRAITBREAK
    ELSE GOTO TRAITQ
    END IF
    TRAITBREAK:


    NBC:
    PRINT "Input new bro? y/n?: "
    newBro$ = INPUT$(1)
    newBro$ = UCASE$(newBro$)
    IF newBro$ <> "Y" AND newBro$ <> "N" THEN GOTO NBC
    IF newBro$ = "Y" THEN broNum% = broNum% + 1
    IF broNum% > 27 THEN newBro$ = "N"

WEND

PRINT #1, "this.World.Assets.getStash().add(this.new(" + quote$ + "scripts/items/supplies/bread_item" + quote$ + "));"
PRINT #1, "this.World.Assets.getStash().add(this.new(" + quote$ + "scripts/items/supplies/bread_item" + quote$ + "));"

PRINT "Include any SUPPLY items (bread, mead, wine, anything in scripts/items/supplies) ? You start with 2 bread automatically. These do not include armors (y/n)"
itemYN$ = INPUT$(1)
itemYN$ = UCASE$(itemYN$)
WHILE (itemYN$ = "Y")
    INPUT "Item name (DO NOT include _item). Type quit to stop adding items: ", item$
    item$ = LCASE$(LTRIM$(RTRIM$(item$)))
    IF item$ = "quit" GOTO ITEMBREAK
    PRINT #1, "this.World.Assets.getStash().add(this.new(" + quote$ + "scripts/items/supplies/" + item$ + "_item" + quote$ + "));"
WEND
ITEMBREAK:


PRINT "Include any TRADE items (salt, dies, anything in scripts/items/trade) ? You start with 2 bread automatically. These do not include armors (y/n)"
itemYN$ = INPUT$(1)
itemYN$ = UCASE$(itemYN$)
WHILE (itemYN$ = "Y")
    INPUT "Item name (DO NOT include _item). Type quit to stop adding items: ", item$
    item$ = LCASE$(LTRIM$(RTRIM$(item$)))
    IF item$ = "quit" GOTO TRADEBREAK
    PRINT #1, "this.World.Assets.getStash().add(this.new(" + quote$ + "scripts/items/trade/" + item$ + "_item" + quote$ + "));"
WEND
TRADEBREAK:



PRINT #1, "this.World.Assets.m.Money = this.World.Assets.m.Money / 2;"
PRINT #1, "this.World.Assets.m.Ammo = this.World.Assets.m.Ammo / 2;"
PRINT #1, "} //Ends player creation function here"

'-----------------------------------------------------------

PRINT #1, "function onSpawnPlayer()"
PRINT #1, " {"
PRINT #1, "     local randomVillage;"
PRINT #1, ""
PRINT #1, "     for( local i = 0; i != this.World.EntityManager.getSettlements().len(); i = ++i )"
PRINT #1, "     {"
PRINT #1, "         randomVillage = this.World.EntityManager.getSettlements()[i];"
PRINT #1, ""
PRINT #1, "         if (randomVillage.isMilitary() && !randomVillage.isIsolatedFromRoads() && randomVillage.getSize() >= 3)"
PRINT #1, "         {"
PRINT #1, "             break;"
PRINT #1, "         }"
PRINT #1, "     }"
PRINT #1, ""
PRINT #1, "     local randomVillageTile = randomVillage.getTile();"
PRINT #1, ""
PRINT #1, "     do"
PRINT #1, "     {"
PRINT #1, "         local x = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.X - 1), this.Math.min(this.Const.World.Settings.SizeX - 2, randomVillageTile.SquareCoords.X + 1));"
PRINT #1, "         local y = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.Y - 1), this.Math.min(this.Const.World.Settings.SizeY - 2, randomVillageTile.SquareCoords.Y + 1));"
PRINT #1, ""
PRINT #1, "         if (!this.World.isValidTileSquare(x, y))"
PRINT #1, "         {"
PRINT #1, "         }"
PRINT #1, "         else"
PRINT #1, "         {"
PRINT #1, "             local tile = this.World.getTileSquare(x, y);"
PRINT #1, ""
PRINT #1, "             if (tile.Type == this.Const.World.TerrainType.Ocean || tile.Type == this.Const.World.TerrainType.Shore)"
PRINT #1, "             {"
PRINT #1, "             }"
PRINT #1, "             else if (tile.getDistanceTo(randomVillageTile) == 0)"
PRINT #1, "             {"
PRINT #1, "             }"
PRINT #1, "             else if (!tile.HasRoad)"
PRINT #1, "             {"
PRINT #1, "             }"
PRINT #1, "             else"
PRINT #1, "             {"
PRINT #1, "                 randomVillageTile = tile;"
PRINT #1, "                 break;"
PRINT #1, "             }"
PRINT #1, "         }"
PRINT #1, "     }"
PRINT #1, "     while (1);"
PRINT #1, ""
PRINT #1, "     this.World.State.m.Player = this.World.spawnEntity(" + quote$ + "scripts/entity/world/player_party" + quote$ + ", randomVillageTile.Coords.X, randomVillageTile.Coords.Y);"
PRINT #1, "     this.World.getCamera().setPos(this.World.State.m.Player.getPos());"
PRINT #1, "     this.Time.scheduleEvent(this.TimeUnit.Real, 1000, function ( _tag )"
PRINT #1, "     {"
PRINT #1, "         this.Music.setTrackList(["
PRINT #1, quote$ + "music/civilians_01.ogg" + quote$
PRINT #1, "         ], this.Const.Music.CrossFadeTime);"
PRINT #1, "         this.World.Events.fire(" + quote$ + "event.legend_random_party_scenario_intro" + quote$ + ");"
PRINT #1, "     }, null);"
PRINT #1, " }"

IF (hasPC% > 0) THEN
    PRINT #1, " function onCombatFinished()"
    PRINT #1, " {"
    PRINT #1, "     local roster = this.World.getPlayerRoster().getAll();"
    PRINT #1, ""
    PRINT #1, "     foreach( bro in roster )"
    PRINT #1, "     {"
    PRINT #1, "         if (bro.getTags().get(" + quote$ + "IsPlayerCharacter" + quote$ + "))"
    PRINT #1, "         {"
    PRINT #1, "             return true;"
    PRINT #1, "         }"
    PRINT #1, "     }"
    PRINT #1, ""
    PRINT #1, "     return false;"
    PRINT #1, " }"
    PRINT #1, ""
END IF

PERKTREEQ:
PRINT "Include extra perks to every hired person? (e.g. how seer gives everyone student)? (y/n)"
pTree$ = INPUT$(1)
pTree$ = LCASE$(pTree$)
IF pTree$ = "y" THEN

    PRINT #1, "function onHiredByScenario( bro )"
    PRINT #1, " {"
    PRINT "Input the perk name: e.g. perk_nimble, or perk_student"
    WHILE (pTree$ = "y")
        INPUT "Perk Name? 'quit' to quit: ", pdef$
        IF LCASE$(pdef$) = "quit" THEN PRINT #1, "}": GOTO PERKTREEBREAK
        PRINT #1, "bro.getSkills().add(this.new(" + quote$ + "scripts/skills/perks/" + pdef$ + quote$ + "));"
    WEND

ELSEIF pTree$ = "n" THEN GOTO PERKTREEBREAK
ELSE GOTO PERKTREEQ
END IF

PERKTREEBREAK:
PRINT #1, "});" 'End of file

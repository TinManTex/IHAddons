-- DOBUILD: 1
-- InfGameEvent.lua
-- system relies on preventing saved ivar values from restoring (search inf_event) and using it's own profile settings with level seed to ensure randomisation is the same
local this={}

local Ivars=Ivars
local InfMain=InfMain

this.inf_enabledEvents={}

local eventMissions={
  [30010]=true,
  [30020]=true,
  [30050]=true,
}
function this.DisableEvent()
  if vars.missionCode==30050 and Ivars.inf_event:Is"WARGAME" then
    Ivars.inf_event:Set(0)
    this.inf_enabledEvents={}
  end
  if (vars.missionCode==30010 or vars.missionCode==30020) and Ivars.inf_event:Is"ROAM" then
    Ivars.inf_event:Set(0)
    this.inf_enabledEvents={}
  end
end

function this.OnMissionCanStart()
  if not svars.ply_isUsedPlayerInitialAction then
    if this.inf_enabledEvents.CRASHLAND then
      TppHero.SetAndAnnounceHeroicOgrePoint({heroicPoint=-1,ogrePoint=-1},"destroyed_support_heli")
      local stances={
        PlayerStance.STAND,
        PlayerStance.SQUAT,
        PlayerStance.CRAWL,
      }
      Player.RequestToSetTargetStance(stances[math.random(#stances)])
      Player.SetForceInjury{type=math.random(1,3)}

      local rndHours=math.random(0,23)
      local rndMinutes=math.random(0,60)
      local rndSeconds=0--math.random(0,60)
      local startTime=string.format("%02d:%02d:%02d",rndHours,rndMinutes,rndSeconds)
      --InfMenu.DebugPrint("crashland startTime="..startTime)--DEBUG
      gvars.missionStartClock=TppClock.ParseTimeString(startTime,"number")
      vars.clock=gvars.missionStartClock
    end
  end
end

this.forceEvent=false
function this.GenerateEvent(missionCode)
  --InfMenu.DebugPrint("GenerateEvent missionCode:"..missionCode)--DEBUG
  if not Ivars.EnabledForMission("gameEventChance",missionCode) then
  --CULL if not eventMissions[missionCode] then
    return
  end

  InfMain.RandomSetToLevelSeed()
  local randomTriggered=math.random(100)<Ivars.gameEventChanceFREE:Get()
  if missionCode==30050 then
    randomTriggered=math.random(100)<Ivars.gameEventChanceMB:Get()
  end

  if this.forceEvent or randomTriggered or Ivars.inf_event:Is()>0 then
    --    InfMenu.DebugPrint("GenerateEvent actual "..missionCode)--DEBUG
    --    InfMenu.DebugPrint("inf_levelSeed:"..tostring(gvars.inf_levelSeed))--DEBUG
    this.forceEvent=false

    if missionCode==30050 then
      this.GenerateWarGameEvent(missionCode)
    elseif missionCode==30010 or missionCode==30020 then
      this.GenerateRoamEvent(missionCode)
    end
  end
  InfMain.RandomResetToOsTime()
end

--TUNE
local roamEventProfiles={
  HUNTED={
    phaseUpdate=1,
    minPhase="PHASE_ALERT",
    maxPhase="PHASE_ALERT",
    keepPhase=1,
    phaseUpdateRate=30,
    phaseUpdateRange=30,
    blockInMissionSubsistenceIvars=1,
    abortMenuItemControl=1,--TODO not what we want, probably don't want to force it upon user anyway
  },
  CRASHLAND={
    clearItems={0,1},
    clearSupportItems={0,1},
    ospWeaponProfile="CUSTOM",
    primaryWeaponOsp={0,1},
    secondaryWeaponOsp={0,1},
    tertiaryWeaponOsp={0,1},
    startOnFootFREE="ALL",
  },
  LOST_COMS={
    disableMenuDrop=1,
    disableMenuBuddy=1,
    disableMenuAttack=1,
    disableMenuHeliAttack=1,
    disableSupportMenu=1,
    disableSpySearch=1,
    disableLzs="REGULAR",
  },
}

local roamEventNames={
  "HUNTED",
  "CRASHLAND",
  "LOST_COMS",
}

local disableLzsFromStartDistance=1900--tex TUNE
disableLzsFromStartDistance=disableLzsFromStartDistance*disableLzsFromStartDistance
--tex called from InfMain.OnMissionCanStartBottom
function this.DisableLzs()
  local missionCode=vars.missionCode
  if this.inf_enabledEvents.HUNTED then
    local startPos={gvars.ply_missionStartPos[0],gvars.ply_missionStartPos[1],gvars.ply_missionStartPos[2]}
    local locationName=InfMain.GetLocationName()
    InfLZ.DisableLzsWithinDist(TppLandingZone.assaultLzs[locationName],startPos,disableLzsFromStartDistance,missionCode)
    InfLZ.DisableLzsWithinDist(TppLandingZone.missionLzs[locationName],startPos,disableLzsFromStartDistance,missionCode)
  end
end

function this.GenerateRoamEvent(missionCode)
  --InfInspect.TryFunc(function(missionCode)--DEBUG
  local Ivar=Ivars
  Ivars.inf_event:Set"ROAM"--tex see ivar declaration for notes

  this.inf_enabledEvents={}
  local numEvents=0
  for i=1,#roamEventNames do
    if math.random(100)<100/#roamEventNames then--TUNE
      local eventName=roamEventNames[i]
      this.inf_enabledEvents[eventName]=true
      numEvents=numEvents+1
    end
  end
  if numEvents==0 then
    local eventName=roamEventNames[math.random(#roamEventNames)]
    this.inf_enabledEvents[eventName]=true
  end

  --DEBUG
  --  this.inf_enabledEvents={
  --    HUNTED=true,
  --  --CRASHLAND=true,
  --  --LOST_COMS=true,
  --  }
  --

  for eventId,enabled in pairs(this.inf_enabledEvents)do
    InfMenu.PrintFormatLangId("event_announce",eventId)-- TODO ADDLANG to event ids
    Ivars.ApplyProfile(roamEventProfiles[eventId],true)
  end

  local missionCodeLocation={
    [30010]="afgh",
    [30020]="mafr",
  }

  if this.inf_enabledEvents.CRASHLAND then
    --      local rndHours=math.random(0,23)
    --      local rndMinutes=math.random(0,60)
    --      local rndSeconds=math.random(0,60)
    --      gvars.missionStartClock=rndHours*60*60*rndMinutes*60*rndSeconds
    --      vars.clock=gvars.missionStartClock

    --tex random start location
    local locationName=missionCodeLocation[missionCode]
    local lzTable=TppLandingZone.missionLzs[locationName]
    local lzDrpNames={}
    for drpName,aprName in pairs(lzTable)do
      lzDrpNames[#lzDrpNames+1]=drpName
    end
    mvars.heli_missionStartRoute=lzDrpNames[math.random(#lzDrpNames)]
    --InfMenu.DebugPrint("mvars.heli_missionStartRoute:"..mvars.heli_missionStartRoute)--DEBUG
  end
  --end,missionCode)
end

local warGamesBase={
  TRAINING={
    mbDDEquipNonLethal=1,
    mbHostileSoldiers=1,
    mbEnableLethalActions=0,
    mbNonStaff=0,
    mbEnableFultonAddStaff=0,
    mbZombies=0,
    mbEnemyHeli=0,
  },
  INVASION={
    mbDDEquipNonLethal=0,
    mbHostileSoldiers=1,
    mbEnableLethalActions=1,
    mbNonStaff=1,
    mbEnableFultonAddStaff=1,
    mbZombies=0,
    mbEnemyHeli=1,
  },
  ZOMBIE_DD={
    mbDDEquipNonLethal=0,
    mbHostileSoldiers=1,
    mbEnableLethalActions=0,
    mbNonStaff=0,
    mbEnableFultonAddStaff=0,
    mbZombies=1,
    mbEnemyHeli=0,
  },
  ZOMBIE_OBLITERATION={
    mbDDEquipNonLethal=0,
    mbHostileSoldiers=1,
    mbEnableLethalActions=1,
    mbNonStaff=1,
    mbEnableFultonAddStaff=0,
    mbZombies=1,
    mbEnemyHeli=0,
  },
}

local warGames={
  "TRAINING",
  "SOVIET_INVASION",
  "COYOTE_INVASION",
  "XOF_INVASION",
  "ZOMBIE_DD",
  "ZOMBIE_OBLITERATION",
}
local warGamesEnum=Tpp.Enum(warGames)

local warGamesBaseTypes={
  TRAINING="TRAINING",
  SOVIET_INVASION="INVASION",
  COYOTE_INVASION="INVASION",
  XOF_INVASION="INVASION",
  ZOMBIE_DD="ZOMBIE_DD",
  ZOMBIE_OBLITERATION="ZOMBIE_OBLITERATION",
}

local warGameSettings={
  TRAINING={
    enableWalkerGearsMB=0,
    mbNpcRouteChange={0,1},
  },
  SOVIET_INVASION={
    mbDDHeadGear=0,
    mbDDSuit="SOVIET_B",
    enableDDEquipMB=0,
    mbWargameFemales=0,
    enableWalkerGearsMB=1,
    mbWalkerGearsColor="SOVIET",
    mbEnemyHeliColor="DEFAULT",
    revengeModeMB="DEFAULT",--tex TODO generate custom
    mbNpcRouteChange=0,
  },
  COYOTE_INVASION={
    mbDDHeadGear=0,
    mbDDSuit="PF_C",
    mbDDSuitFemale="BATTLE_DRESS",
    enableDDEquipMB=1,
    mbSoldierEquipGrade_MIN=4,
    mbSoldierEquipGrade_MAX=6,
    mbWargameFemales=1,
    enableWalkerGearsMB=1,
    mbWalkerGearsColor="ROGUE_COYOTE",
    mbEnemyHeliColor="RANDOM_EACH",
    revengeModeMB="DEFAULT",--tex TODO generate custom
    mbNpcRouteChange={0,1},
  },
  XOF_INVASION={
    mbDDHeadGear=1,
    mbDDSuit="XOF",
    enableDDEquipMB=1,
    mbSoldierEquipGrade_MIN=15,
    mbSoldierEquipGrade_MAX=15,
    mbWargameFemales=0,
    enableWalkerGearsMB=1,
    mbWalkerGearsColor="DDOGS",--tex or soviet?
    mbEnemyHeliColor="RED",
    revengeModeMB="DEFAULT",--tex TODO generate custom
    mbNpcRouteChange=1,
  },
  ZOMBIE_DD={
    enableWalkerGearsMB=0,
  },
  ZOMBIE_OBLITERATION={
    enableWalkerGearsMB=0,
  },
}

function this.GenerateWarGameEvent()
  --InfInspect.TryFunc(function()--DEBUG
    local Ivars=Ivars
    Ivars.inf_event:Set"WARGAME"--tex see ivar declaration for notes

    local warGame=warGames[math.random(#warGames)]
    --local warGame="TRAINING"--DEBUG
    local wargameBaseType=warGamesBaseTypes[warGame]

    local warGameNames=InfMenu.GetLangTable"events_mb"
    --tex ugh, TODO better
    local warGameIndex=warGamesEnum[warGame]
    local warGameName=warGameNames[warGameIndex]
    InfMenu.PrintFormatLangId("event_announce",warGameName)--tex TODO ADDLANG to event ids

    if wargameBaseType=="INVASION" then
      Ivars.mbWarGamesProfile.setting=Ivars.mbWarGamesProfile.enum.INVASION--KLUDGE just setting without saving or triggering other profile sub ivars
      Ivars.mbEnablePuppy:Set(0,true,true)--tex TODO will kill the puppy quest (aww) till user toggles the option again
    end

    Ivars.ApplyProfile(warGamesBase[wargameBaseType],true)
    Ivars.ApplyProfile(warGameSettings[warGame],true)

    --custom config TODO: make generated config a seperate feature?
    --all the rest, for now just use enemy prep levels
    --Ivars.revengeModeMB:Set("CUSTOM",true,true)
    --tex for now just useing enemy prep levels (set via warGames table)
  --end)--
end

function this.ForceEvent()
  InfMenu.PrintLangId"event_forced"
  this.forceEvent=true
end

return this
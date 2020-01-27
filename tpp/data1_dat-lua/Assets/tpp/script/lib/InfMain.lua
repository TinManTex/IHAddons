-- DOBUILD: 1
--InfMain.lua
local this={}

this.modVersion="187"
this.modName="Infinite Heaven"

--LOCALOPT:
local InfMain=this
local IvarProc=IvarProc
local InfButton=InfButton
local TppMission=TppMission
local IsFunc=Tpp.IsTypeFunc
local IsTable=Tpp.IsTypeTable
local IsString=Tpp.IsTypeString
local NULL_ID=GameObject.NULL_ID
local GetGameObjectId=GameObject.GetGameObjectId
local GetTypeIndex=GameObject.GetTypeIndex
local SendCommand=GameObject.SendCommand
local Enum=TppDefine.Enum
local StrCode32=Fox.StrCode32


this.modulesOK=false
this.doneStartup=false
this.appliedProfiles=false

function this.IsTableEmpty(checkTable)--tex TODO: shove in a utility module
  local next=next
  if next(checkTable)==nil then
    return true
  end
  return false
end

function this.RandomSeedRegen()
  this.RandomResetToOsTime()
  Ivars.inf_levelSeed:Set(math.random(0,2147483647))
  --InfLog.DebugPrint("new seed "..tostring(gvars.inf_levelSeed))--DEBUG
end

function this.RandomSetToLevelSeed()
  math.randomseed(gvars.inf_levelSeed)
  math.random()
  math.random()
  math.random()
end

function this.RandomResetToOsTime()
  math.randomseed(os.time())
  math.random()
  math.random()
  math.random()
end

local allowHeavyArmorStr="allowHeavyArmor"
function this.ForceArmor(missionCode)
  if IvarProc.EnabledForMission(allowHeavyArmorStr,missionCode) then
    return true
  end
  --TODO either I got rid of this functionality at some point or I never implemented it (I could have sworn I did though), search in past versions
  --  if Ivars.allowLrrpArmorInFree:Is(1) and TppMission.IsFreeMission(missionCode) then
  --    return true
  --  end

  return false
end

this.SETTING_FORCE_ENEMY_TYPE=Enum{
  "DEFAULT",
  "TYPE_DD",
  "TYPE_SOVIET",
  "TYPE_PF",
  "TYPE_SKULL",
  "TYPE_CHILD",
  "MAX",
}

this.enemySubTypes={
  "Default",
  "DD_A",
  "DD_PW",
  "DD_FOB",
  "SKULL_CYPR",
  "SKULL_AFGH",
  "SOVIET_A",
  "SOVIET_B",
  "PF_A",
  "PF_B",
  "PF_C",
  "CHILD_A",
}

this.soldierSubTypesForTypeName={
  TYPE_DD={
    "DD_A",
    "DD_PW",
    "DD_FOB",
  },
  TYPE_SKULL={
    "SKULL_CYPR",
    "SKULL_AFGH",
  },
  TYPE_SOVIET={
    "SOVIET_A",
    "SOVIET_B",
  },
  TYPE_PF={
    "PF_A",
    "PF_B",
    "PF_C",
  },
  TYPE_CHILD={
    "CHILD_A",
  },
}
this.soldierTypeForSubtypes={
  DD_A=EnemyType.TYPE_DD,
  DD_PW=EnemyType.TYPE_DD,
  DD_FOB=EnemyType.TYPE_DD,
  SKULL_CYPR=EnemyType.TYPE_SKULL,
  SKULL_AFGH=EnemyType.TYPE_SKULL,
  SOVIET_A=EnemyType.TYPE_SOVIET,
  SOVIET_B=EnemyType.TYPE_SOVIET,
  PF_A=EnemyType.TYPE_PF,
  PF_B=EnemyType.TYPE_PF,
  PF_C=EnemyType.TYPE_PF,
  CHILD_A=EnemyType.TYPE_CHILD,
}
--tex maybe I'm missing something but not having luck indexing by EnemyType
function this.SoldierTypeNameForType(soldierType)
  if soldierType == nil then
    return nil
  end

  if soldierType==EnemyType.TYPE_DD then
    return "TYPE_DD"
  elseif soldierType==EnemyType.TYPE_SKULL then
    return "TYPE_SKULL"
  elseif soldierType==EnemyType.TYPE_SOVIET then
    return "TYPE_SOVIET"
  elseif soldierType==EnemyType.TYPE_PF then
    return "TYPE_PF"
  elseif soldierType==EnemyType.TYPE_CHILD then
    return "TYPE_CHILD"
  end
  return nil
end

function this.IsSubTypeCorrectForType(soldierType,subType)--returns true on nil soldiertype because fsk that
  local soldierTypeName=this.SoldierTypeNameForType(soldierType)
  if soldierTypeName ~= nil then
    local subTypes=this.soldierSubTypesForTypeName[soldierTypeName]
    if subTypes ~= nil then
      for n, _subType in pairs()do
        if subType == _subType then
          return true
        end
      end
      return false
    end
  end
  return true
end

function this.IsForceSoldierSubType()
  return Ivars.forceSoldierSubType:Is()>0 and TppMission.IsFreeMission(vars.missionCode)
end

-- mb dd equip
--tex TODO: don't like how this is still tied up both with weapon table and .GetMbs ranks
local enableDDEquipStr="enableDDEquip"
function this.IsDDEquip(missionId)
  local missionCode=missionId or vars.missionCode
  if missionCode~=50050 and missionCode >5 then--tex IsFreeMission hangs on startup? TODO retest
    return IvarProc.EnabledForMission(enableDDEquipStr)
  end
  return false
end

function this.IsDDBodyEquip(missionId)
  local missionCode=missionId or vars.missionCode
  if missionCode==30050 or missionCode==30250 then
    return Ivars.mbDDSuit:Is()>0
  end
  return false
end

function this.MinMaxIvarRandom(ivarName)
  local ivarMin=Ivars[ivarName.."_MIN"]
  local ivarMax=Ivars[ivarName.."_MAX"]
  return math.random(ivarMin:Get(),ivarMax:Get())
end

function this.GetMbsClusterSecuritySoldierEquipGrade(missionId)--SYNC: soldierEquipGrade
  local missionCode=missionId or vars.missionCode
  local grade = TppMotherBaseManagement.GetMbsClusterSecuritySoldierEquipGrade{}
  if this.IsDDEquip(missionCode) then
    InfMain.RandomSetToLevelSeed()
    grade=this.MinMaxIvarRandom"soldierEquipGrade"
    InfMain.RandomResetToOsTime()
  end
  --TppUiCommand.AnnounceLogView("GetEquipGrade: gvar:".. Ivars.soldierEquipGrade:Get() .." grade: ".. grade)--DEBUG
  --TppUiCommand.AnnounceLogView("Caller: ".. tostring(debug.getinfo(2).name) .." ".. tostring(debug.getinfo(2).source))--DEBUG
  return grade
end

function this.GetMbsClusterSecuritySoldierEquipRange(missionId)
  local missionCode=missionId or vars.missionCode
  if this.IsDDEquip(missionCode) then
    if Ivars.mbSoldierEquipRange:Is"RANDOM" then
      return math.random(0,2)--REF:{ "FOB_ShortRange", "FOB_MiddleRange", "FOB_LongRange", }, but range index from 0
    else
      return Ivars.mbSoldierEquipRange:Get()
    end
  end
  return TppMotherBaseManagement.GetMbsClusterSecuritySoldierEquipRange()
end

function this.GetMbsClusterSecurityIsNoKillMode(missionId)
  local missionCode=missionId or vars.missionCode
  if this.IsDDEquip(missionCode) then
    return Ivars.mbDDEquipNonLethal:Is(1)
  end
  return TppMotherBaseManagement.GetMbsClusterSecurityIsNoKillMode()
end

function this.DisplayFox32(foxString)
  local str32 = Fox.StrCode32(foxString)
  TppUiCommand.AnnounceLogView("string :"..foxString .. "="..str32)
end

function this.ResetCpTableToDefault()
  local subTypeOfCp=TppEnemy.subTypeOfCp
  local subTypeOfCpDefault=TppEnemy.subTypeOfCpDefault
  for cp, subType in pairs(subTypeOfCp)do
    subTypeOfCp[cp]=subTypeOfCpDefault[cp]
  end
end

local cpSubTypes={
  afgh={
    "SOVIET_A",
    "SOVIET_B",
  },
  mafr={
    "PF_A",
    "PF_B",
    "PF_C",
  },
}

local changeCpSubTypeStr="changeCpSubType"
function this.RandomizeCpSubTypeTable()
  if not IvarProc.EnabledForMission(changeCpSubTypeStr) then
    this.ResetCpTableToDefault()
    return
  end

  local locationName=this.locationNames[vars.locationCode]
  local locationSubTypes=cpSubTypes[locationName]
  if locationSubTypes==nil then
    InfLog.DebugPrint("RandomizeCpSubTypeTable: locationSubTypes==nil for location "..tostring(locationName))
    return
  end

  InfMain.RandomSetToLevelSeed()--tex set to a math.random on OnMissionClearOrAbort so a good base for a seed to make this constand on mission loads. Soldiers dont care since their subtype is saved but other functions read subTypeOfCp
  local subTypeOfCp=TppEnemy.subTypeOfCp
  for cp, subType in pairs(subTypeOfCp)do
    local subType=subTypeOfCp[cp]

    local rnd=math.random(1,#locationSubTypes)
    subTypeOfCp[cp]=locationSubTypes[rnd]
  end
  this.RandomResetToOsTime()
end

function this.ChangePhase(cpName,phase)
  local gameId=GetGameObjectId("TppCommandPost2",cpName)
  if gameId==NULL_ID then
    InfLog.DebugPrint("Could not find cp "..cpName)
    return
  end
  local command={id="SetPhase",phase=phase}
  SendCommand(gameId,command)
end

function this.SetKeepAlert(cpName,enable)
  local gameId=GetGameObjectId("TppCommandPost2",cpName)
  if gameId==NULL_ID then
    InfLog.DebugPrint("Could not find cp "..cpName)
    return
  end
  local command={id="SetKeepAlert",enable=enable}
  GameObject.SendCommand(gameId,command)
end

--TUNE
function this.SetZombie(gameObjectId)
  local command= {
    id="SetZombie",
    enabled=true,
    isMsf=math.random()>0.7,
    isZombieSkin=false,--math.random()>0.5,
    isHagure=math.random()>0.7,--tex donn't even know
    isHalf=math.random()>0.7,--tex donn't even know
  }
  if not command.isMsf then
    command.isZombieSkin=true
  end
  SendCommand(gameObjectId,command )
  if command.isMsf then
    local command={id="SetMsfCombatLevel",level=math.random(9)}
    SendCommand(gameObjectId,command)
  end

  if math.random()>0.8 then
    SendCommand(gameObjectId,{id="SetEnableHotThroat",enabled=true})
  end
end

function this.SetUpMBZombie()
  for cpName,soldierNameList in pairs(mvars.ene_soldierDefine) do
    for i,soldierName in pairs(soldierNameList) do
      local gameObjectId=GetGameObjectId("TppSoldier2",soldierName)
      if gameObjectId~=NULL_ID then
        this.SetZombie(gameObjectId)
      end
    end
  end
end

this.SetFriendlyCp = function()
  local gameObjectId = { type="TppCommandPost2", index=0 }
  local command = { id="SetFriendlyCp" }
  GameObject.SendCommand( gameObjectId, command )
end

this.SetFriendlyEnemy = function()
  local gameObjectId = { type="TppSoldier2" }
  local command = { id="SetFriendly", enabled=true }
  GameObject.SendCommand( gameObjectId, command )
end

--tex TODO:
this.cpPositions={
  afgh={
    afgh_citadelSouth_ob={-1682.557,536.637,-2409.226},
    afgh_sovietSouth_ob={-1558.834,414.159,-1159.438},
    afgh_plantWest_ob={-1173.101,458.269,-1392.586},
    afgh_waterwayEast_ob={-1358.766,398.534,-742.015},
    afgh_tentNorth_ob={-1758.428,336.844,211.112},
    afgh_enemyNorth_ob={-182.129,411.550,-454.07},
    afgh_cliffWest_ob={302.273,415.153,-860.780},
    afgh_tentEast_ob={-1169.6,302.742,938.917},
    afgh_enemyEast_ob={-361.562,356.97,114.79},
    afgh_cliffEast_ob={1259.04,479.846,-1345.574},
    afgh_slopedWest_ob={99.113,334.220,89.654},
    afgh_remnantsNorth_ob={-1065.079,291.448,1467.447},
    afgh_cliffSouth_ob={1040.302,379.051,-505.49},
    afgh_fortWest_ob={1825.444,465.684,-1252.843},
    afgh_villageWest_ob={-258.249,298.451,927.591},
    afgh_slopedEast_ob={977.664,318.965,-169.445},
    afgh_fortSouth_ob={2194.072,429.323,-1271},
    afgh_villageNorth_ob={504.530,329.411,702.308},
    afgh_commWest_ob={983.531,347.594,665.96},
    afgh_bridgeWest_ob={1584.864,347.409,48.656},
    afgh_bridgeNorth_ob={2394.559,369.135,-517.208},
    afgh_fieldWest_ob={8.862,274.866,1992.816},
    afgh_villageEast_ob={939.176,318.845,1259.34},
    afgh_ruinsNorth_ob={1623.511,323.038,1062.995},
    afgh_fieldEast_ob={1101.482,318.458,1828.101},
    
    --afgh_plantSouth_ob--Only references in generic setups",-- no actual missions
    --afgh_waterway_cp--Only references in generic setups",-- no actual missions
    
    afgh_cliffTown_cp={787,466,-994},
    afgh_tent_cp={-1761.73,317.69,806.51},
    afgh_powerPlant_cp={-685,533,-1487},
    afgh_sovietBase_cp={-2197,443,-1474},
    afgh_remnants_cp={-905.605,288.846,1922.272},
    afgh_field_cp={425.95,270.16,2198.39},
    afgh_citadel_cp={-1251.708,595.181,-2936.821},
    afgh_fort_cp={2106.16,463.64,-1747.21},
    afgh_village_cp={508,319,1171},
    afgh_bridge_cp={1920,322,-475},
    afgh_commFacility_cp={1488.730,357.429,459.287},
    afgh_slopedTown_cp={514.191,331.173,43.403},
    afgh_enemyBase_cp={-596.89,353.02,497.40},
  },
  mafr={
    mafr_swampWest_ob={-561.458,1.203,-189.687},--Guard Post 01, NW Kiziba Camp
    mafr_diamondNorth_ob={1326.073,152.667,-1899.799},--Guard Post 02, NE Kungenga Mine
    mafr_bananaEast_ob={570.117,79.988,-1071.741},--Guard Post 03, SE Bampeve Plantation
    mafr_bananaSouth_ob={232.093,3.048,-653.531},--Guard Post 04, SW Bampeve Plantation
    mafr_savannahNorth_ob={707.557,34.091,-913.209},--Guard Post 05, NE Ditadi Abandoned Village
    mafr_outlandNorth_ob={-806.758,1.056,690.615},--Guard Post 06, North Masa Village
    mafr_diamondWest_ob={1047.941,121.694,-1170.218},--Guard Post 07, West Kungenga Mine
    mafr_labWest_ob={2146.880,192.241,-2177.558},--Guard Post 08, NW Lufwa Valley
    mafr_savannahWest_ob={713.843,3.120,-547.492},--Guard Post 09, North Ditadi Abandoned Village
    mafr_swampEast_ob={344.727,-5.164,-7.508},--Guard Post 10, SE Kiziba Camp
    mafr_outlandEast_ob={-275.585,-7.796,767.962},--Guard Post 11, East Masa Village
    mafr_swampSouth_ob={316.517,-5.944,369.979},--Guard Post 12, South Kiziba Camp
    mafr_diamondSouth_ob={1439.533,99.656,-720.559},--Guard Post 13, SW Kungenga Mine
    mafr_pfCampNorth_ob={928.184,-4.859,372.320},--Guard Post 14, NE Nova Braga Airport
    mafr_savannahEast_ob={1197.290,8.719,78.842},--Guard Post 15, South Ditadi Abandoned Village
    mafr_hillNorth_ob={1915.400,60.799,-230.770},--Guard Post 16, NE Munoko ya Nioka Station
    mafr_factoryWest_ob={2515.327,71.937,-814.150},--Guard Post 17, West Ngumba Industrial Zone
    mafr_pfCampEast_ob={1196.617,-4.470,567.516},--Guard Post 18, East Nova Braga Airport
    mafr_hillWest_ob={1673.172,24.406,137.511},--Guard Post 19, NW Munoko ya Nioka Station
    mafr_factorySouth_ob={2349.303,68.733,-113.923},--Guard Post 20, SW Ngumba Industrial Zone
    mafr_hillWestNear_ob={1799.202,-4.737,711.536},--Guard Post 21, West Munoko ya Nioka Station
    mafr_chicoVilWest_ob={1549.457,-10.819,1776.419},--Guard Post 22, South Nova Braga Airport
    mafr_hillSouth_ob={2012.754,-10.564,1376.297},--Guard Post 23, SW Munoko ya Nioka Station
    --mafr_swampWestNear_ob--Only references in generic setups, no actual missions
    
    mafr_flowStation_cp={-1001.38,-7.20,-199.16},--Mfinda Oilfield
    mafr_banana_cp={277.078,42.670,-1160.725},--Bampeve Plantation
    mafr_diamond_cp={1243.253,139.279,-1524.267},--Kungenga Mine
    mafr_lab_cp={2707.704,174.806,-2423.353},--Lufwa Valley
    mafr_swamp_cp={-55.823,-3.758,55.400},--Kiziba Camp
    mafr_outland_cp={-596.105,-16.714,1094.863},--Masa Village
    mafr_savannah_cp={979.923,26.267,-201.705},--Ditadi Abandoned Village
    mafr_pfCamp_cp={846.46,-4.97,1148.62},--Nova Braga Airport
    mafr_hill_cp={2154.83,63.09,366.70},--Munoko ya Nioka Station --redo

  --mafr_factory_cp={},--Ngumba Industrial Zone - no soldiers  NOTE in interrog
  --mafr_swampWestNear_ob={},--Only references in generic setups, no actual missions

  --mafr_chicoVil_cp={},--??
  },
  mbqf={
    mbqf_mtbs_cp={-158.183,0.801,-2076.006},
  },
  mtbs={
    mbqf_mtbs_cp={-158.183,0.801,-2076.006},--tex mbqf free (f30250) (loc 55) actually comes up as location 50/mtbs
  }
}

function this.GetClosestCp(position)
  local playerPos={vars.playerPosX,vars.playerPosY,vars.playerPosZ}
  position=position or playerPos

  local locationName=InfMain.GetLocationName()
  local cpPositions=this.cpPositions[locationName]
  if cpPositions==nil then
    InfLog.DebugPrint("WARNING: GetClosestCp no cpPositions for locationName "..locationName)
    return nil,nil,nil
  end

  local closestCp=nil
  local closestDist=9999999999999999
  local closestPosition=nil
  for cpName,cpPosition in pairs(cpPositions)do
    if cpPosition==nil then
      InfLog.DebugPrint("cpPosition==nil for "..tostring(cpName))
      return
    elseif #cpPosition~=3 then
      InfLog.DebugPrint("#cpPosition~=3 for "..tostring(cpName))
      return
    end

    local distSqr=TppMath.FindDistance(position,cpPosition)
    --InfLog.DebugPrint(cpName.." dist:"..math.sqrt(distSqr))--DEBUG
    if distSqr<closestDist then
      closestDist=distSqr
      closestCp=cpName
      closestPosition=cpPosition
    end
  end
  --InfLog.DebugPrint("Closest cp "..InfMenu.CpNameString(closestCp,locationName)..":"..closestCp.." ="..math.sqrt(closestDist))--DEBUG
  local cpId=GetGameObjectId(closestCp)
  if cpId and cpId~=NULL_ID then
    return closestCp,closestDist,closestPosition
  else
    return
  end
end

function this.GetClosestLz(position)
  local closestRoute=nil
  local closestDist=9999999999999999
  local closestPosition=nil

  local locationName=InfMain.GetLocationName()

  if not TppLandingZone.assaultLzs[locationName] then
    InfLog.DebugPrint"WARNING: GetClosestLz TppLandingZone.assaultLzs[locationName]==nil"--DEBUG
  end
  local lzTables={
    TppLandingZone.assaultLzs[locationName],
    TppLandingZone.missionLzs[locationName]
  }
  for i,lzTable in ipairs(lzTables)do
    for dropLzName,aprLzName in pairs(lzTable)do
      local coords=InfLZ.GetGroundStartPosition(StrCode32(dropLzName))
      if coords then
        local cpPos=coords.pos
        if cpPos==nil then
          InfLog.DebugPrint("coords.pos==nil for "..dropLzName)
          return
        elseif #cpPos~=3 then
          InfLog.DebugPrint("#coords.pos~=3 for "..dropLzName)
          return
        end

        local distSqr=TppMath.FindDistance(position,cpPos)
        if distSqr<closestDist then
          closestDist=distSqr
          closestRoute=dropLzName
          closestPosition=cpPos
        end
      end
    end
  end

  return closestRoute,closestDist,closestPosition
end

--<cp stuff
--quest/sideops stuff
--tex a few demo files force their own snake heads which naturally goes badly if DD female and use current soldier in cutscenes
this.noSkipIsSnakeOnly={--tex>
  Demo_Funeral=true,--PATCHUP: shining lights end cinematic forces snake head with ash
  --volgin recovery quest, demo forces snake head with bandages
  Demo_RecoverVolgin=true,
  p31_080100_000_final=true,
}

--block quests>
local blockQuests={
  "tent_q99040", -- 144 - recover volgin, player is left stuck in geometry at end of quanranteed plat demo
  "sovietBase_q99020",-- 82, make contact with emmeric
}

function this.BlockQuest(questName)
  --tex TODO: doesn't work for the quest area you start in (need to clear before in actual mission)
  if vars.missionCode==30050 and Ivars.mbWarGamesProfile:Is()>0 then
    --InfLog.DebugPrint("actually BlockQuest "..tostring(questName).." "..tostring(vars.missionCode))--DEBUG CULL
    return true
  end
  --tex quest system in respect to this a bit too twisty for me to figure out now, so will just block here
  if Ivars.mbEnablePuppy:Is()>0 and Ivars.mbWarGamesProfile:Is(0) then
    if questName=="mtbs_q42010" then
      return true
    end
  end

  for n,name in ipairs(blockQuests)do
    if name==questName then
      if TppQuest.IsCleard(questName) then
        return true
      end
    end
  end
  --tex block heli quests to allow super reinforce
  if Ivars.enableHeliReinforce:Is(1) then
    --if TppMission.GetMissionID()==30010 or TppMission.GetMissionID()==30020 then
    for n,name in ipairs(TppDefine.QUEST_HELI_DEFINE)do
      if name==questName then
        return true
      end
    end
    --end
  end

  return false
end


--<quest/sideops stuff
function this.SetSubsistenceSettings()
  --tex no go, see OnMissionCanStartBottom for alt solution
  --  if TppMission.IsFOBMission(vars.missionCode) then
  --    if vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]==TppEquip.EQP_None then
  --      --InfLog.Add("TppDefine.WEAPONSLOT.PRIMARY_HIP]==TppEquip.EQP_None")--DEBUG
  --      TppPlayer.SetInitWeapons({{primaryHip="EQP_WP_30001"}},true)
  --    end
  --    if vars.weapons[TppDefine.WEAPONSLOT.SECONDARY]==TppEquip.EQP_None then
  --      --InfLog.Add("TppDefine.WEAPONSLOT.SECONDARY]==TppEquip.EQP_None")--DEBUG
  --      TppPlayer.SetInitWeapons({{secondary="EQP_WP_10101"}},true)
  --    end
  --    return
  --  end


  --TppPlayer.SetInitWeapons(initSetting,true)

  if TppMission.IsFOBMission(vars.missionCode) then
    return
  end

  if TppMission.IsHelicopterSpace(vars.missionCode) then
    return
  end

  if vars.missionCode<=TppDefine.SYS_MISSION_ID.TITLE then
    return
  end

  local Ivars=Ivars

  if Ivars.disableFulton:Is(1) then
    vars.playerDisableActionFlag=vars.playerDisableActionFlag+PlayerDisableAction.FULTON--tex RETRY:, may have to replace instances with a SetPlayerDisableActionFlag if this doesn't stick
  end

  local handLevelIvars={
    Ivars.handLevelSonar,
    Ivars.handLevelPhysical,
    Ivars.handLevelPrecision,
    Ivars.handLevelMedical,
  }
  for i,itemIvar in ipairs(handLevelIvars) do
    if itemIvar:Is()>0 then
      --TODO: check against developed
      --local currentLevel=Player.GetItemLevel(equip)
      --InfLog.DebugPrint(itemIvar.name..":"..itemIvar.setting)--DEBUG
      --tex levels = grades in dev menu, so 1=off since there's no grade 1 for these
      Player.SetItemLevel(itemIvar.equipId,itemIvar:Get())
    end
  end

  if Ivars.itemLevelFulton:Is()>0 then
    --TODO: check against developed
    --REF local currentLevel=Player.GetItemLevel(equip)
    Player.SetItemLevel(Ivars.itemLevelFulton.equipId,Ivars.itemLevelFulton:Get())
  end

  if Ivars.itemLevelWormhole:Is()>0 then
    --TODO: check against developed
    --REF local currentLevel=Player.GetItemLevel(equip)
    --tex levels = 0 off, 1 on, but since ivar uses 0 as default, shift by 1.
    Player.SetItemLevel(Ivars.itemLevelWormhole.equipId,Ivars.itemLevelWormhole:Get()-1)
  end

  if TppMission.IsSubsistenceMission()then
    return
  end

  if Ivars.setSubsistenceSuit:Is(1) then
    local playerSettings={partsType=PlayerPartsType.NORMAL,camoType=PlayerCamoType.OLIVEDRAB,handEquip=TppEquip.EQP_HAND_NORMAL,faceEquipId=0}
    TppPlayer.RegisterTemporaryPlayerType(playerSettings)
  end
  if Ivars.setDefaultHand:Is(1) then
    mvars.ply_isExistTempPlayerType=true
    mvars.ply_tempPlayerHandEquip={handEquip=TppEquip.EQP_HAND_NORMAL}
  end

  --tex bail on free<>mission to preserver your equip
  --tex not MB
  local free={
    [30010]=true,
    [30020]=true,
  }
  if not Ivars.prevMissionCode then
    return
  end

  if Ivars.dontOverrideFreeLoadout:Is(1) then
    if (free[Ivars.prevMissionCode] and TppMission.IsStoryMission(vars.missionCode))
      or (free[vars.missionCode] and TppMission.IsStoryMission(Ivars.prevMissionCode)) then
      return
    end
  end

  local ospIvars={
    Ivars.primaryWeaponOsp,
    Ivars.secondaryWeaponOsp,
    Ivars.tertiaryWeaponOsp,
    Ivars.clearSupportItems,
    Ivars.clearItems,
  }

  for i,ivar in ipairs(ospIvars) do
    if Ivars.inf_event:Is(0) then
      IvarProc.UpdateSettingFromGvar(ivar)
    end

    local initSetting=ivar:GetTableSetting()
    if initSetting then
      if ivar==Ivars.clearItems then
        TppPlayer.SetInitItems(initSetting,true)
      else
        TppPlayer.SetInitWeapons(initSetting,true)
      end
    end
  end
end

--
this.menuDisableActions=PlayerDisableAction.OPEN_EQUIP_MENU--+PlayerDisableAction.OPEN_CALL_MENU

function this.RestoreActionFlag()
  --local activeControlMode=this.GetActiveControlMode()
  -- WIP
  --  if activeControlMode then
  --    if bit.band(vars.playerDisableActionFlag,menuDisableActions)==menuDisableActions then
  --    else
  --      this.EnableAction(menuDisableActions)
  --    end
  --  else
  this.EnableAction(this.menuDisableActions)
  --  end
end

function this.DisableAction(actionFlag)
  if not this.ActionIsDisabled(actionFlag) then
    vars.playerDisableActionFlag=vars.playerDisableActionFlag+actionFlag
  end
end
function this.EnableAction(actionFlag)
  if this.ActionIsDisabled(actionFlag) then
    vars.playerDisableActionFlag=vars.playerDisableActionFlag-actionFlag
  end
end

function this.ActionIsDisabled(actionFlag)
  if bit.band(vars.playerDisableActionFlag,actionFlag)==actionFlag then
    return true
  end
  return false
end

--
this.allButCamPadMask={
  settingName="allButCam",
  except=true,
  --buttons=PlayerPad.STANCE,
  sticks=PlayerPad.STICK_R,
}
--CULL REF
--local commonControlPadMask={
--  settingName="controlMode",
--  except=false,
--  buttons=PlayerPad.ALL,
--  sticks=PlayerPad.STICK_L,--+PlayerPad.STICK_R,
--  triggers=PlayerPad.TRIGGER_L+PlayerPad.TRIGGER_R,
--}

--
local function UpdateRangeToMinMax(updateRate,updateRange)
  local min=updateRate-updateRange*0.5
  local max=updateRate+updateRange*0.5
  if min<0 then
    min=0
  end
  return min,max
end


function this.OnAllocate(missionTable)
  if TppMission.IsFOBMission(vars.missionCode)then
    TppSoldier2.ReloadSoldier2ParameterTables(InfSoldierParams.soldierParameters)
    return
  end

  --WIP
  if missionTable.enemy then
    InfEquip.LoadEquipTable()
  end
end

function this.PreMissionLoad(missionCode,currentMissionCode)
end

function this.MissionPrepare()
  if TppMission.IsStoryMission(vars.missionCode) then
    if Ivars.gameOverOnDiscovery:Is(1) then
      TppMission.RegistDiscoveryGameOver()
    end
  end
end

function this.Messages()
  return Tpp.StrCode32Table{
    GameObject={
      {msg="Damage",func=this.OnDamage},
      {msg="Dead",func=this.OnDead},
      {msg="ChangePhase",func=this.OnPhaseChange},
      --WIP OFF, lua off
      --      {msg="RequestLoadReinforce",func=InfReinforce.OnRequestLoadReinforce},
      --      {msg="RequestAppearReinforce",func=InfReinforce.OnRequestAppearReinforce},
      --      {msg="CancelReinforce",func=InfReinforce.OnCancelReinforce},
      --      {msg="LostControl",func=InfReinforce.OnHeliLostControlReinforce},--DOC: Helicopter shiz.txt
      --      {msg="VehicleBroken",func=InfReinforce.OnVehicleBrokenReinforce},
      {msg="Returned", --[[sender = "EnemyHeli",--]]
        func = function(gameObjectId)
        --InfLog.DebugPrint("GameObject msg: Returned")--DEBUG
        end
      },
      {msg="RequestedHeliTaxi",func=function(gameObjectId,currentLandingZoneName,nextLandingZoneName)
        --InfLog.DebugPrint("RequestedHeliTaxi currentLZ:"..currentLandingZoneName.. " nextLZ:"..nextLandingZoneName)--DEBUG
        end},
      {msg="StartedPullingOut",func=function()
        --InfLog.DebugPrint("StartedPullingOut")--DEBUG
        if TppMission.IsMbFreeMissions(vars.missionCode) then
        --this.heliSelectClusterId=nil
        end
      end},
    --      {
    --        msg = "RoutePoint2",--DEBUG
    --        func = function( gameObjectId, routeId, routeNodeIndex, messageId )
    --          InfLog.PCall(function()
    --            InfLog.DebugPrint("gameObjectId:"..tostring(gameObjectId).." routeId:".. tostring(routeId).." routeNodeIndex:".. tostring(routeNodeIndex).." messageId:".. tostring(messageId))--DEBUG
    --          end)
    --        end
    --      },
    },
    MotherBaseStage = {
    --      {
    --        msg="MotherBaseCurrentClusterLoadStart",
    --        func=function(clusterId)
    --          InfLog.DebugPrint"InfMain MotherBaseCurrentClusterLoadStart"--DEBUG
    --        end,
    --      },
    --OFF CULL unused{msg= "MotherBaseCurrentClusterActivated",func=this.CheckClusterMorale},
    },
    Player={
      {msg="FinishOpeningDemoOnHeli",func=this.ClearMarkers},--tex xray effect off doesn't stick if done on an endfadein, and cant seen any ofther diable between the points suggesting there's an in-engine set between those points of execution(unless I'm missing something) VERIFY
    --      {
    --        msg="OnPickUpWeapon",
    --        func=function(playerGameObjectId,equipId,number)
    --          InfLog.DebugPrint("OnPickUpWeapon equipId:"..equipId.." number:"..number)--DEBUG
    --        end
    --      },
    --      {msg="RideHelicopter",func=function()
    --        InfLog.DebugPrint"RideHelicopter"
    --      end},
    },
    UI={
      --      {msg="EndFadeIn",func=this.FadeIn()},--tex for all fadeins
      {msg="EndFadeIn",sender="FadeInOnGameStart",func=function()--fires on: most mission starts, on-foot free and story missions, not mb on-foot, but does mb heli start
        --InfLog.Add("FadeInOnGameStart",true)--DEBUG
        this.FadeInOnGameStart()
      end},
      --this.FadeInOnGameStart},
      {msg="EndFadeIn",sender="FadeInOnStartMissionGame",func=function()--fires on: returning to heli from mission
        --  TppUiStatusManager.ClearStatus"AnnounceLog"
        --InfMenu.ModWelcome()
        --InfLog.DebugPrint"FadeInOnStartMissionGame"--DEBUG
        --this.FadeInOnGameStart()
        end},
      {msg="EndFadeIn",sender="OnEndGameStartFadeIn",func=function()--fires on: on-foot mother base, both initial and continue
        --InfLog.DebugPrint"OnEndGameStartFadeIn"--DEBUG
        this.FadeInOnGameStart()
      end},
      --tex Heli mission-prep ui
      {msg="MissionPrep_EndSlotSelect",func=function()
        --InfLog.DebugPrint"MissionPrep_EndSlotSelect"--DEBUG
        InfFova.CheckModelChange()
      end},
    --      {msg="MissionPrep_ExitWeaponChangeMenu",func=function()
    --        InfLog.DebugPrint"MissionPrep_ExitWeaponChangeMenu"--DEBUG
    --      end},
    --      {msg="MissionPrep_EndItemSelect",func=function()
    --        InfLog.DebugPrint"MissionPrep_EndItemSelect"--DEBUG
    --      end},
    --      {msg="MissionPrep_EndEdit",func=function()
    --        InfLog.DebugPrint"MissionPrep_EndEdit"--DEBUG
    --      end},


    --elseif(messageId=="Dead"or messageId=="VehicleBroken")or messageId=="LostControl"then
    },
    Timer={
    --WIP OFF lua off {msg="Finish",sender="Timer_FinishReinforce",func=InfReinforce.OnTimer_FinishReinforce,nil},
    },
    Terminal={
      {msg="MbDvcActSelectLandPoint",func=function(nextMissionId,routeName,layoutCode,clusterId)
        --InfLog.DebugPrint("MbDvcActSelectLandPoint:"..tostring(InfLZ.str32LzToLz[routeName]).. " "..tostring(clusterId))--DEBUG
        this.heliSelectClusterId=clusterId
      end},
      {msg="MbDvcActSelectLandPointTaxi",func=function(nextMissionId,routeName,layoutCode,clusterId)
        --InfLog.DebugPrint("MbDvcActSelectLandPointTaxi:"..tostring(routeName).. " "..tostring(clusterId))--DEBUG
        this.heliSelectClusterId=clusterId
      end},
      {msg="MbDvcActHeliLandStartPos",func=function(set,x,y,z)
        --InfLog.DebugPrint("HeliLandStartPos:"..x..","..y..","..z)--DEBUG
        end},
      {msg="MbDvcActCallRescueHeli",func=function(param1,param2)
        --InfLog.DebugPrint("MbDvcActCallRescueHeli: "..tostring(param1).." ".. tostring(param2))--DEBUG
        end},
    },
    Block={
      {msg="StageBlockCurrentSmallBlockIndexUpdated",func=function(blockIndexX,blockIndexY,clusterIndex)
        if Ivars.printOnBlockChange:Is(1) then
          InfLog.DebugPrint("OnSmallBlockIndex - x:"..blockIndexX..", y:"..blockIndexY.." clusterIndex:"..tostring(clusterIndex))
        end
      end},
      {msg="OnChangeLargeBlockState",func=function(blockNameStr32,blockStatus)
        if Ivars.printOnBlockChange:Is(1) then
          InfLog.DebugPrint("OnChangeLargeBlockState - blockNameStr32:"..blockNameStr32.." blockStatus:"..blockStatus)
        end
      end},
      {msg="OnChangeSmallBlockState",func=function(blockNameStr32,blockStatus)

        end},
    },
  }
end
function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
  Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end

function this.OnDead(gameId,attackerId,playerPhase,deadMessageFlag)
  --InfLog.DebugPrint("InfMain.OnDead")--DEBUG

  if true then return end
  --  local heliId=GetGameObjectId(TppReinforceBlock.REINFORCE_HELI_NAME)--CULL not for heli I guess
  --  if heliId~=NULL_ID then
  --    if heliId==gameId then
  --    --InfLog.DebugPrint("InfMain.OnDead is heli")
  --    end
  --  end

  if GetTypeIndex(gameId)~=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2 then
    return
  end

  --local killerIsPlayer=(killerId==GameObject.GetGameObjectIdByIndex("TppPlayer2",PlayerInfo.GetLocalPlayerIndex()))
end


--TODO: VERIFY, add vehicle machineguns
local AttackIsVehicle=function(attackId)--RETAILBUG: seems like attackid must be a typo and f
  if(((((((((((((
    attackId==TppDamage.ATK_VehicleHit
    or attackId==TppDamage.ATK_Tankgun_20mmAutoCannon)
    or attackId==TppDamage.ATK_Tankgun_30mmAutoCannon)
    or attackId==TppDamage.ATK_Tankgun_105mmRifledBoreGun)
    or attackId==TppDamage.ATK_Tankgun_120mmSmoothBoreGun)
    or attackId==TppDamage.ATK_Tankgun_125mmSmoothBoreGun)
    or attackId==TppDamage.ATK_Tankgun_82mmRocketPoweredProjectile)
    or attackId==TppDamage.ATK_Tankgun_30mmAutoCannon)
    or attackId==TppDamage.ATK_Wav1)
    or attackId==TppDamage.ATK_WavCannon)
    or attackId==TppDamage.ATK_TankCannon)
    or attackId==TppDamage.ATK_WavRocket)
    or attackId==TppDamage.ATK_HeliMiniGun)
    or attackId==TppDamage.ATK_HeliChainGun)
--or attackId==TppDamage.ATK_WalkerGear_BodyAttack
then
  return true
end
return false
end
function this.OnDamage(gameId,attackId,attackerId)
  if typeIndex~=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2 then--and typeIndex~=TppGameObject.GAME_OBJECT_TYPE_HELI2 then
    return
  end

  if Tpp.IsPlayer(attackerId) then
    --InfLog.DebugPrint"OnDamage attacked by player"
    local soldierAlertOnHeavyVehicleDamage=Ivars.soldierAlertOnHeavyVehicleDamage:Get()
    if soldierAlertOnHeavyVehicleDamage>0 then
      if AttackIsVehicle(attackId) then
        --InfLog.DebugPrint"OnDamage AttackIsVehicle"
        for cpId,soldierIds in pairs(mvars.ene_soldierIDList)do--tex TODO:find or build a better soldierid>cpid lookup
          if soldierIds[gameId]~=nil then
            if TppEnemy.GetPhaseByCPID(cpId)<soldierAlertOnHeavyVehicleDamage then
              --InfLog.DebugPrint"OnDamage found soldier in idlist"
              local command={id="SetPhase",phase=soldierAlertOnHeavyVehicleDamage}
              SendCommand(cpId,command)
              break
            end
        end--if cp not phase
        end--for soldieridlist
      end--attackisvehicle
    end--gvar
  end--player is attacker
end

function this.OnFultonVehicle(vehicleId)
--WIP
--tex not actually that useful, need to alert nearby cps instead
--  local cpAlertOnVehicleFulton=Ivars.cpAlertOnVehicleFulton:Get()
--  if cpAlertOnVehicleFulton>0 then--tex
--    InfLog.DebugPrint"cpAlertOnVehicleFulton>0"--DEBUG
--    local riderIdArray=SendCommand(vehicleId,{id="GetRiderId"})
--    for seatIndex,riderId in ipairs(riderIdArray) do
--      if seatIndex==1 then
--        if riderId~=NULL_ID then
--          InfLog.DebugPrint"vehicle has driver"--DEBUG
--          for cpId,soldierIds in pairs(mvars.ene_soldierIDList)do
--            if soldierIds[riderId]~=nil then
--              InfLog.DebugPrint"found rider cp"--DEBUG
--              if TppEnemy.GetPhaseByCPID(cpId)<cpAlertOnVehicleFulton then
--                local command={id="SetPhase",phase=cpAlertOnVehicleFulton}
--                SendCommand(cpId,command)
--                break
--              end
--            end
--          end
--        end
--      end
--    end
--  end--<
end

local function PhaseName(index)
  return Ivars.phaseSettings[index+1]
end
function this.OnPhaseChange(gameObjectId,phase,oldPhase)
  if Ivars.printPhaseChanges:Is(1) and Ivars.phaseUpdate:Is(0) then
    --tex TODO: cpId>cpName
    InfMenu.Print("cpId:"..gameObjectId.." Phase change from:"..PhaseName(oldPhase).." to:"..PhaseName(phase))--InfMenu.LangString("phase_changed"..":"..PhaseName(phase)))--ADDLANG
  end
end

--CALLER: TppUiFadeIn
--tex calling from function rather than msg since it triggers on start, possibly splash or loading screen, which fova naturally doesnt like because it doesn't exist then
function this.OnFadeInDirect()
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  InfFova.OnFadeIn()
end

--msg called fadeins
function this.FadeInOnGameStart()
  this.WeaponVarsSanityCheck()

  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  this.ClearMarkers()

  this.ChangeMaxLife()

  --  if Ivars.disableQuietHumming:Is(1) then --tex no go
  --    this.SetQuietHumming(false)
  --  end

  --TppUiStatusManager.ClearStatus"AnnounceLog"
  --InfMenu.ModWelcome()
end


function this.OnEnterACC()
  if not this.modulesOK then
    this.ModuleErrorMessage()
  else
    InfMenu.ModWelcome()

    --tex dummy/EQUIP_NONE hangun/assault
    local developIds={
      900,
      901,
    }
    for i,developId in ipairs(developIds) do
      if not TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=developId} then
        InfLog.Add("SetEquipDeveloped "..developId)
        TppMotherBaseManagement.SetEquipDeveloped{equipDevelopID=developId}
      end
    end

    --tex only want this on enter ACC because changing vars on a mission is not a good idea
    if not this.appliedProfiles then
      this.appliedProfiles=true
      --InfLog.DebugPrint"SetupInfProfiles"--DEBUG
      local profileNames=IvarProc.SetupInfProfiles()
      IvarProc.ApplyInfProfiles(profileNames)
    end
  end
end

function this.ClearMarkers()
  if Ivars.disableHeadMarkers:Is(1) then
    TppUiStatusManager.SetStatus("HeadMarker","INVALID")
  end
  if Ivars.disableWorldMarkers:Is(1) then
    TppUiStatusManager.SetStatus("WorldMarker","INVALID")
  end
  if Ivars.disableXrayMarkers:Is(1) then
    --TppSoldier2.DisableMarkerModelEffect()
    TppSoldier2.SetDisableMarkerModelEffect{enabled=true}
  end
end

function this.ChangeMaxLife(setOn1)
  --tex player life values for difficulty. Difficult to track down the best place for this, player.changelifemax hangs anywhere but pretty much in game and ready to move, Anything before the ui ending fade in in fact, why.
  --which i don't like, my shitty code should be run in the shadows, not while player is getting viewable frames lol, this is at least just before that
  --RETRY: push back up again, you may just have fucked something up lol, the actual one use case is in sequence.OnEndMissionPrepareSequence which is the middle of tppmain.onallocate

  --default player life is defined as 6000 in *player(s)_game_obj.fox2/TppPlayer2Parameter/lifeMax
  --however this is only the value during the early game
  --after mission 2 it bumps up to 6600 (6000*1.1?)
  --with medical hand grade 2 or higher (as snake or avatar), or with a DD soldier with the tough guy skill this increases to
  --7801, which is a bit over 6000*1.3, which is strange.

  --vars.playerLifeMax is uint16 (ta NasaNhak) so just capping max at 50k (*1.3=65k) to avoid the overflow
  --Ivar max (6.5 scale) is actually a bit over 50k, but I'll cap here for sanity

  -- see wiki for more info http://wiki.tesnexus.com/index.php/Life
  local healthScale=Ivars.playerHealthScale:Get()/100
  if healthScale~=1 or setOn1 then
    Player.ResetLifeMaxValue()
    local newMax=vars.playerLifeMax
    newMax=newMax*healthScale
    newMax=math.max(10,newMax)
    --newMax=math.min(2^16-1,newMax)--unint16 max
    newMax=math.min(50000,newMax)
    Player.ChangeLifeMaxValue(newMax)
  end
end

--tex called at very start of TppMain.OnInitialize, use mostly for hijacking missionTable scripts
function this.OnInitializeTop(missionTable)
  --InfLog.PCall(function(missionTable)--DEBUG
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  this.RandomizeCpSubTypeTable()

  if missionTable.enemy then
    local enemyTable=missionTable.enemy
    this.numReserveSoldiers=this.reserveSoldierCounts[vars.missionCode] or 0
    this.reserveSoldierNames=this.BuildReserveSoldierNames(this.numReserveSoldiers,this.reserveSoldierNames)
    this.soldierPool=this.ResetObjectPool("TppSoldier2",this.reserveSoldierNames)
    --InfLog.DebugPrint("Init #this.soldierPool:"..#this.soldierPool)--DEBUG

    if IsTable(enemyTable.soldierDefine) then
      if IsTable(enemyTable.VEHICLE_SPAWN_LIST)then
        InfVehicle.ModifyVehiclePatrol(enemyTable.VEHICLE_SPAWN_LIST,enemyTable.soldierDefine,enemyTable.travelPlans)
      end

      enemyTable.soldierTypes=enemyTable.soldierTypes or {}
      enemyTable.soldierSubTypes=enemyTable.soldierSubTypes or {}
      enemyTable.soldierPowerSettings=enemyTable.soldierPowerSettings or {}
      enemyTable.soldierPersonalAbilitySettings=enemyTable.soldierPersonalAbilitySettings or {}

      this.ModifyVehiclePatrolSoldiers(enemyTable.soldierDefine)
      this.AddLrrps(enemyTable.soldierDefine,enemyTable.travelPlans)
      this.AddWildCards(enemyTable.soldierDefine,enemyTable.soldierTypes,enemyTable.soldierSubTypes,enemyTable.soldierPowerSettings,enemyTable.soldierPersonalAbilitySettings)

      --DEBUG
      --      for cpName,cpDefine in pairs(enemyTable.soldierDefine)do
      --        cpDefine.lrrpVehicle=nil
      --      end
    end
  end




  --TODO
  --  if Ivars.mbEnablePuppy:Is(1) then--and Ivars.inf_event:Is(0) then--tex mb event may turn off puppy, won't come back on by itself after event, so force it
  --    local puppyQuestIndex=TppDefine.QUEST_INDEX.Mtbs_child_dog
  --    gvars.qst_questRepopFlag[puppyQuestIndex]=true
  --    gvars.qst_questOpenFlag[puppyQuestIndex]=true
  --
  --    TppQuest.UpdateRepopFlagImpl(TppQuestList.questList[17])--MtbsCommand
  --    TppQuest.UpdateActiveQuest()
  --  end

  --end,missionTable)--DEBUG
end
function this.OnInitializeBottom(missionTable)
  ---InfLog.PCall(function(missionTable)--DEBUG
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  --tex TODO: pull into InfInterrogation
  if Ivars.enableInfInterrogation:Is(1) and(vars.missionCode~=30010 or vars.missionCode~=30020) then
    if missionTable.enemy then
      local interrogationTable=missionTable.enemy.interrogation
      if IsTable(interrogationTable)then
        for cpName,layerTable in pairs(interrogationTable)do
          local cpId=GetGameObjectId("TppCommandPost2",cpName)
          if cpId==NULL_ID then
            InfLog.DebugPrint"enableInfInterrogation interrogationTable cpId==NULL_ID"--DEBUG
          else
            --tex TODO KLUDGE, cant actually see how it's reset normally,
            --but it doesn't seem to trigger unless I do
            --also there seems to be only one actual .normal interrogation used in one mission, unless the generic interrogation uses the .normal layer
            --and doing it this way actually resets the save vars
            TppInterrogation.ResetFlagNormal(cpId)
          end
        end
      end
    end
  end

  InfVehicle.SetupConvoy()
  --end,missionTable)--DEBUG
end

function this.OnAllocateTop(missionTable)
  --if not Ivars.resourceAmountScale:IsDefault() then
  this.ScaleResourceTables()
  --end
end
--tex called via TppSequence Seq_Mission_Prepare.OnUpdate > TppMain.OnMissionCanStart
function this.OnMissionCanStartBottom()
  --InfLog.PCall(function()--DEBUG
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  local currentChecks=this.UpdateExecChecks(this.execChecks)
  for i,module in ipairs(InfModules) do
    if IsFunc(module.OnMissionCanStart) then
      module.OnMissionCanStart(currentChecks)
    end
  end

  --tex WORKAROUND invasion mode extract from mb weirdness, just disable for now
  --  if Ivars.mbWarGamesProfile:Is"INVASION" and vars.missionCode==30050 then
  --    Player.SetItemLevel(TppEquip.EQP_IT_Fulton_WormHole,0)
  --  end

  local locationName=InfMain.GetLocationName()
  if Ivars.disableLzs:Is"ASSAULT" then
    InfLZ.DisableLzs(TppLandingZone.assaultLzs[locationName])
  elseif Ivars.disableLzs:Is"REGULAR" then
    InfLZ.DisableLzs(TppLandingZone.missionLzs[locationName])
  end
  if Ivars.inf_event:Is"ROAM" then
    InfGameEvent.DisableLzs()

    InfGameEvent.OnMissionCanStart()
  end

  if Ivars.repopulateRadioTapes:Is(1) then
    Gimmick.ForceResetOfRadioCassetteWithCassette()
  end

  InfEquip.PutEquipOnTrucks()
  --end)--DEBUG
end

--tex called about halfway through TppMain.OnInitialize
function this.Init(missionTable)
  --InfLog.PCall(function(missionTable)--DEBUG
  this.abortToAcc=false

  if TppMission.IsFOBMission(vars.missionCode) then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

  if (vars.missionCode==30050 --[[WIP or vars.missionCode==30250--]]) and Ivars.mbEnableFultonAddStaff:Is(1) then
    mvars.trm_isAlwaysDirectAddStaff=false
  end

  this.UpdateHeliVars()
  --end,missionTable)--DEBUG

  local currentChecks=this.UpdateExecChecks(this.execChecks)
  for i,module in ipairs(InfModules)do
    if module.Init then
      module.Init(missionTable,currentChecks)
    end
  end
end

function this.OnReload(missionTable)
  if TppMission.IsFOBMission(vars.missionCode) then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

  for i,module in ipairs(InfModules)do
    if module.OnReload then
      module.OnReload(missionTable)
    end
  end
end

--tex called from TppMission.OnMissionGameEndFadeOutFinish2nd
function this.OnMissionGameEndTop()
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  for i,module in ipairs(InfModules) do
    if IsFunc(module.OnMissionGameEnd) then
      module.OnMissionGameEnd()
    end
  end
end

function this.AbortMissionTop(abortInfo)
  if TppMission.IsFOBMission(abortInfo.nextMissionId)then
    return
  end

  --InfLog.DebugPrint("AbortMissionTop "..vars.missionCode)--DEBUG
  InfMain.RegenSeed(vars.missionCode,abortInfo.nextMissionId)

  InfGameEvent.DisableEvent()
end

function this.ExecuteMissionFinalizeTop()
  if TppMission.IsFOBMission(gvars.mis_nextMissionCodeForMissionClear)then
    return
  end

  InfMain.RegenSeed(vars.missionCode,gvars.mis_nextMissionCodeForMissionClear)
  InfGameEvent.DisableEvent()
  InfGameEvent.GenerateEvent(gvars.mis_nextMissionCodeForMissionClear)
end

function this.RegenSeed(currentMission,nextMission)
  --tex hard to find a line to draw in the sand between one mission and the next, so i'm just going for if you've gone to acc then that you're new levelseed set
  -- this does mean that free roam<>mission wont get a change though, but that may be useful in some circumstances
  if TppMission.IsHelicopterSpace(nextMission) and currentMission>5 then
    InfMain.RandomSeedRegen()
  end
end
--missionFinalize={
--  currentMissionCode,
--  currentLocationCode,
--  isHeliSpace,
--  nextIsHeliSpace,
--  isFreeMission,
--  nextIsFreeMission,
--  isMotherBase,
--  isZoo,
--}
--GOTCHA only currently on freemission in a specfic spot
function this.ExecuteMissionFinalize(missionFinalize)
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  --tex repop count decrement for plants
  if Ivars.mbCollectionRepop:Is(1) then
    if missionFinalize.isZoo then
      TppGimmick.DecrementCollectionRepopCount()
    elseif missionFinalize.isMotherBase then
      --tex dont want it too OP
      Ivars.mbRepopDiamondCountdown:Set(Ivars.mbRepopDiamondCountdown:Get()-1)
      if Ivars.mbRepopDiamondCountdown:Is(0) then
        Ivars.mbRepopDiamondCountdown:Reset()
        TppGimmick.DecrementCollectionRepopCount()
      end
    end
  end
end

function this.ClearOnAbort()
  Ivars.inf_event:Set(0)
  Ivars.inf_parasiteEvent:Set(0)
end

this.execChecks={
  inGame=false,--tex actually loaded game, ie at least 'continued' from title screen
  inHeliSpace=false,
  inMission=false,
  initialAction=false,--tex mission actually started/reached ground, triggers on checkpoint save so might not be valid for some uses
  inGroundVehicle=false,
  inSupportHeli=false,
  onBuddy=false,--tex sexy
  inBox=false,
  inMenu=false,
}

this.currentTime=0

this.abortToAcc=false--tex

--tex NOTE: doesn't actually return a new table/reuses input
function this.UpdateExecChecks(currentChecks)
  for k,v in pairs(this.execChecks) do
    this.execChecks[k]=false
  end

  currentChecks.inGame=not mvars.mis_missionStateIsNotInGame
  currentChecks.inHeliSpace=vars.missionCode and TppMission.IsHelicopterSpace(vars.missionCode)
  currentChecks.inMission=currentChecks.inGame and not currentChecks.inHeliSpace

  if currentChecks.inGame then
    local playerVehicleId=vars.playerVehicleGameObjectId
    if not currentChecks.inHeliSpace then
      currentChecks.initialAction=svars.ply_isUsedPlayerInitialAction--VERIFY that start on ground catches this (it's triggered on checkpoint save DOESNT catch motherbase ground start
      --if not initialAction then--DEBUG
      --InfLog.DebugPrint"not initialAction"
      --end
      currentChecks.inSupportHeli=Tpp.IsHelicopter(playerVehicleId)--tex VERIFY
      currentChecks.inGroundVehicle=Tpp.IsVehicle(playerVehicleId)-- or Tpp.IsEnemyWalkerGear(playerVehicleId)?? VERIFY
      currentChecks.onBuddy=Tpp.IsHorse(playerVehicleId) or Tpp.IsPlayerWalkerGear(playerVehicleId)
      currentChecks.inBox=Player.IsVarsCurrentItemCBox()
    end
  end

  return currentChecks
end

function this.Update()
  InfLog.PCallDebug(function()--DEBUG
    local InfMenu=InfMenu
    if TppMission.IsFOBMission(vars.missionCode) then
      return
    end

    local currentChecks=this.UpdateExecChecks(this.execChecks)
    this.currentTime=Time.GetRawElapsedTimeSinceStartUp()

    InfButton.UpdateHeld()
    InfButton.UpdateRepeatReset()

    this.DoControlSet(currentChecks)

    ---Update shiz
    if not this.modulesOK then
      if InfButton.OnButtonHoldTime(InfMenu.toggleMenuButton) then
        this.ModuleErrorMessage()
      end
    else
      InfMenu.Update(currentChecks)
      currentChecks.inMenu=InfMenu.menuOn

      for i,module in ipairs(InfModules) do
        if module.Update then
          --tex <module>.active is either number or ivar
          local active=this.ValueOrIvarValue(module.active)
          if active>0 then
            local updateRate=this.ValueOrIvarValue(module.updateRate)
            local updateRange=this.ValueOrIvarValue(module.updateRange)

            this.ExecUpdate(currentChecks,this.currentTime,module.execCheckTable,module.execState,updateRate,updateRange,module.Update)
          end
        end
      end
    end
    ---
    InfButton.UpdatePressed()--tex GOTCHA: should be after all key reads, sets current keys to prev keys for onbutton checks
  end)--DEBUG
end

function this.ExecUpdate(currentChecks,currentTime,execChecks,execState,updateRate,updateRange,ExecUpdateFunc)
  if execState.nextUpdate > currentTime then
    return
  end

  if execChecks==nil then
    InfLog.DebugPrint"update module has no execChecks var, aborting"
    return
  end
  for check,ivarCheck in pairs(execChecks) do
    if currentChecks[check]~=ivarCheck then
      return
    end
  end

  if not IsFunc(ExecUpdateFunc) then
    InfLog.DebugPrint"ExecUpdateFunc is not a function"
    return
  end

  ExecUpdateFunc(currentChecks,currentTime,execChecks,execState)

  --tex CULL, module Update func handling setting its next update time for now
  --tex set up next update time GOTCHA: wont reflect changes to rate and range till next update
  --  if updateRange then
  --    local updateMin=updateRate-updateRange*0.5
  --    local updateMax=updateRate+updateRange*0.5
  --    if updateMin<0 then
  --      updateMin=0
  --    end
  --
  --    updateRate=math.random(updateMin,updateMax)
  --  end
  --  execState.nextUpdate=currentTime+updateRate

  --DEBUG
  --if currentChecks.inGame then
  -- InfLog.DebugPrint("currentTime: "..tostring(currentTime).." updateRate:"..tostring(updateRate) .." nextUpdate:"..tostring(execState.nextUpdate))
  --end
end

function this.DoControlSet(currentChecks)
  local abortButton=InfButton.ESCAPE
  InfButton.buttonStates[abortButton].holdTime=2

  if InfButton.OnButtonHoldTime(abortButton) then
    if gvars.ini_isTitleMode then
      local splash=SplashScreen.Create("abortsplash","/Assets/tpp/ui/ModelAsset/sys_logo/Pictures/common_kjp_logo_clp_nmp.ftex",640,640)
      SplashScreen.Show(splash,0,0.3,0)
      this.abortToAcc=true
      InfMain.ClearOnAbort()
    else--elseif currentChecks.inGame then--WIP
    --this.ClearStatus()
    end
  end


  if currentChecks.inGame then
    local combo={
      InfButton.HOLD,
      InfButton.DASH,
      InfButton.ACTION,
      InfButton.SUBJECT,
    }
    local comboActive=true
    for i,button in ipairs(combo)do
      if not InfButton.ButtonHeld(button) then
        comboActive=false
        break
      end
    end

    if comboActive then
      for i,button in ipairs(combo)do
        InfButton.buttonStates[button].heldStart=0
      end
      InfLog.DebugPrint("LoadExternalModules")
      this.LoadExternalModules()
      if not this.modulesOK then
        this.ModuleErrorMessage()
      end
    end
  end
end

--warp mode,camadjust
--config
this.moveRightButton=InfButton.RIGHT
this.moveLeftButton=InfButton.LEFT
this.moveForwardButton=InfButton.UP
this.moveBackButton=InfButton.DOWN
this.moveUpButton=InfButton.DASH
this.moveDownButton=InfButton.ZOOM_CHANGE
--cam buttons
this.resetModeButton=InfButton.SUBJECT
this.verticalModeButton=InfButton.ACTION
this.zoomModeButton=InfButton.FIRE
this.apertureModeButton=InfButton.RELOAD
this.focusDistanceModeButton=InfButton.STANCE
this.distanceModeButton=InfButton.HOLD
this.speedModeButton=InfButton.ACTION

this.nextEditCamButton=InfButton.RIGHT
this.prevEditCamButton=InfButton.LEFT

--heli, called from TppMain.Onitiialize, so should only be 'enable/change from default', VERIFY it's in the right spot to override each setting
function this.UpdateHeliVars()
  if TppMission.IsFOBMission(vars.missionCode) then
    return
  end

  local heliId=GetGameObjectId("TppHeli2","SupportHeli")
  if heliId==nil or heliId==NULL_ID then
    return
  end

  if Ivars.disableHeliAttack:Is(1) then--tex disable heli be fightan
    SendCommand(heliId,{id="SetCombatEnabled",enabled=false})
  end
  if Ivars.setInvincibleHeli:Is(1) then
    SendCommand(heliId,{id="SetInvincible",enabled=true})
  end
  if not Ivars.setTakeOffWaitTime:IsDefault() then
    SendCommand(heliId,{id="SetTakeOffWaitTime",time=Ivars.setTakeOffWaitTime:Get()})
  end
  if Ivars.disablePullOutHeli:Is(1) then
    --if not TppLocation.IsMotherBase() and not TppLocation.IsMBQF() then--tex aparently disablepullout overrides the mother base taxi service TODO: not sure if I want to turn this off to save user confusion, or keep consistant behaviour
    SendCommand(heliId,{id="DisablePullOut"})
    --end
  end
  if not Ivars.setLandingZoneWaitHeightTop:IsDefault() then
    SendCommand(heliId,{id="SetLandingZoneWaitHeightTop",height=Ivars.setLandingZoneWaitHeightTop:Get()})
  end
  if Ivars.disableDescentToLandingZone:Is(1) then
    SendCommand(heliId,{id="DisableDescentToLandingZone"})
  end
  if Ivars.setSearchLightForcedHeli:Is"ON" then
    SendCommand(heliId,{id="SetSearchLightForcedType",type="On"})
  elseif Ivars.setSearchLightForcedHeli:Is"OFF" then
    SendCommand(heliId,{id="SetSearchLightForcedType",type="Off"})
  end

  --if TppMission.IsMbFreeMissions(vars.missionCode) then--TEST no aparent result on initial testing, in-engine pullout check must be overriding
  --  TppUiStatusManager.UnsetStatus( "MbMap", "BLOCK_TAXI_CHANGE_LOCATION" )
  --end
end

function this.OnMenuOpen()

end
function this.OnMenuClose()
  -- OFF WIP
  --  TppSave.VarSaveConfig()
  --  TppSave.SaveConfigData()

  local activeControlMode=this.GetActiveControlMode()
  if activeControlMode then
    if IsFunc(activeControlMode.OnActivate) then
      activeControlMode.OnActivate()
    end
  end
end


function this.GetActiveControlMode()
  local controlModes={
    Ivars.warpPlayerUpdate,
    Ivars.adjustCameraUpdate,
  }
  for i,ivar in ipairs(controlModes)do
    if ivar:Is(1) then
      return ivar
    end
  end
  return nil
end
--

function this.HeliOrderRecieved()
  if this.execChecks.inGame and not this.execChecks.inHeliSpace then
    InfMenu.PrintLangId"order_recieved"
  end
end

--tex has no effect sadly, only boss quiet gameobject i guess
function this.SetQuietHumming(hummingFlag)
  local command = {id="SetHumming", flag=hummingFlag}
  local gameObjectId = GameObject.GetGameObjectIdByIndex("TppBuddyQuiet2", 0)

  if gameObjectId ~= NULL_ID then
    --InfLog.DebugPrint("sethumming:"..tostring(hummingFlag))--DEBUG
    SendCommand(gameObjectId, command)
  else
  --InfLog.DebugPrint"no TppBuddyQuiet2 found"--DEBUG
  end
end

--lrrp plus
this.baseNames={
  afgh={
    --TODO HANG "afgh_citadelSouth_ob",--Guard Post 01, East Afghanistan Central Base Camp
    "afgh_sovietSouth_ob",--Guard Post 02, South Afghanistan Central Base Camp
    "afgh_plantWest_ob",--Guard Post 03, NW Serak Power Plant
    "afgh_waterwayEast_ob",--Guard Post 04, East Aabe Shifap Ruins
    "afgh_tentNorth_ob",--Guard Post 05, NE Yakho Oboo Supply Outpost--note: not in 30010 interrogate
    "afgh_enemyNorth_ob",--Guard Post 06, NE Wakh Sind Barracks
    "afgh_cliffWest_ob",--Guard Post 07, NW Sakhra Ee Village
    "afgh_tentEast_ob",--Guard Post 08, SE Yakho Oboo Supply Outpost
    "afgh_enemyEast_ob",--Guard Post 09, East Wakh Sind Barracks
    "afgh_cliffEast_ob",--Guard Post 10, East Sakhra Ee Village
    "afgh_slopedWest_ob",--Guard Post 11, NW Ghwandai Town
    "afgh_remnantsNorth_ob",--Guard Post 12, North Lamar Khaate Palace
    "afgh_cliffSouth_ob",--Guard Post 13, South Sakhra Ee Village
    "afgh_fortWest_ob",--Guard Post 14, West Smasei Fort
    "afgh_villageWest_ob",--Guard Post 15, NW Wialo Village
    "afgh_slopedEast_ob",--Guard Post 16, SE Da Ghwandai Khar
    "afgh_fortSouth_ob",--Guard Post 17, SW Smasei Fort
    "afgh_villageNorth_ob",--Guard Post 18, NE Wailo Village
    "afgh_commWest_ob",--Guard Post 19, West Eastern Communications Post
    "afgh_bridgeWest_ob",--Guard Post 20, West Mountain Relay Base
    "afgh_bridgeNorth_ob",--Guard Post 21, SE Mountain Relay Base
    "afgh_fieldWest_ob",--Guard Post 22, North Shago Village
    "afgh_villageEast_ob",--Guard Post 23, SE Wailo Village
    "afgh_ruinsNorth_ob",--Guard Post 24, East Spugmay Keep
    "afgh_fieldEast_ob",--Guard Post 25, East Shago Village

    --"afgh_plantSouth_ob",--Only references in generic setups, no actual missions
    --"afgh_waterway_cp",--Only references in generic setups, no actual missions

    "afgh_cliffTown_cp",--Qarya Sakhra Ee
    "afgh_tent_cp",--Yakho Oboo Supply Outpost
    "afgh_powerPlant_cp",--Serak Power Plant
    "afgh_sovietBase_cp",--Afghanistan Central Base Camp
    "afgh_remnants_cp",--Lamar Khaate Palace
    "afgh_field_cp",--Da Shago Kallai
    "afgh_citadel_cp",--OKB Zero
    "afgh_fort_cp",--Da Smasei Laman
    "afgh_village_cp",--Da Wialo Kallai
    "afgh_bridge_cp",--Mountain Relay Base
    "afgh_commFacility_cp",--Eastern Communications Post
    "afgh_slopedTown_cp",--Da Ghwandai Khar
    "afgh_enemyBase_cp",--Wakh Sind Barracks
  },--#39

  mafr={
    "mafr_swampWest_ob",--Guard Post 01, NW Kiziba Camp
    "mafr_diamondNorth_ob",--Guard Post 02, NE Kungenga Mine
    "mafr_bananaEast_ob",--Guard Post 03, SE Bampeve Plantation
    "mafr_bananaSouth_ob",--Guard Post 04, SW Bampeve Plantation
    "mafr_savannahNorth_ob",--Guard Post 05, NE Ditadi Abandoned Village
    "mafr_outlandNorth_ob",--Guard Post 06, North Masa Village
    "mafr_diamondWest_ob",--Guard Post 07, West Kungenga Mine
    "mafr_labWest_ob",--Guard Post 08, NW Lufwa Valley
    "mafr_savannahWest_ob",--Guard Post 09, North Ditadi Abandoned Village
    "mafr_swampEast_ob",--Guard Post 10, SE Kiziba Camp
    "mafr_outlandEast_ob",--Guard Post 11, East Masa Village
    "mafr_swampSouth_ob",--Guard Post 12, South Kiziba Camp
    "mafr_diamondSouth_ob",--Guard Post 13, SW Kungenga Mine
    "mafr_pfCampNorth_ob",--Guard Post 14, NE Nova Braga Airport
    "mafr_savannahEast_ob",--Guard Post 15, South Ditadi Abandoned Village
    "mafr_hillNorth_ob",--Guard Post 16, NE Munoko ya Nioka Station
    --TODO HANG addlrrp  "mafr_factoryWest_ob",--Guard Post 17, West Ngumba Industrial Zone
    "mafr_pfCampEast_ob",--Guard Post 18, East Nova Braga Airport
    "mafr_hillWest_ob",--Guard Post 19, NW Munoko ya Nioka Station
    "mafr_factorySouth_ob",--Guard Post 20, SW Ngumba Industrial Zone
    "mafr_hillWestNear_ob",--Guard Post 21, West Munoko ya Nioka Station
    "mafr_chicoVilWest_ob",--Guard Post 22, South Nova Braga Airport
    "mafr_hillSouth_ob",--Guard Post 23, SW Munoko ya Nioka Station
    --"mafr_swampWestNear_ob",--Only references in generic setups, no actual missions
    "mafr_flowStation_cp",--Mfinda Oilfield
    "mafr_banana_cp",--Bampeve Plantation
    "mafr_diamond_cp",--Kungenga Mine
    "mafr_lab_cp",--Lufwa Valley
    "mafr_swamp_cp",--Kiziba Camp
    "mafr_outland_cp",--Masa Village
    "mafr_savannah_cp",--Ditadi Abandoned Village
    "mafr_pfCamp_cp",--Nova Braga Airport
    "mafr_hill_cp",--Munoko ya Nioka Station

  --"mafr_factory_cp",--Ngumba Industrial Zone - no soldiers  NOTE in interrog
  --"mafr_chicoVil_cp",--??
  },--#34
}

--reserve vehiclepool
this.reserveVehicleNames={}
--local vehPrefix="veh_ih_"
--this.numReserveVehicles=12--tex SYNC number of soldier locators i added to fox2s
--for i=0,this.numReserveVehicles-1 do
--  local name=string.format("%s%04d",vehPrefix,i)
--  table.insert(this.reserveVehicleNames,name)
--end

this.mbVehicleNames={
  "veh_cl01_cl00_0000",
  "veh_cl02_cl00_0000",
  "veh_cl03_cl00_0000",
  "veh_cl04_cl00_0000",
  "veh_cl05_cl00_0000",
  "veh_cl06_cl00_0000",
  "veh_cl00_cl04_0000",
  "veh_cl00_cl02_0000",
  "veh_cl00_cl03_0000",
  "veh_cl00_cl01_0000",
  "veh_cl00_cl05_0000",
  "veh_cl00_cl06_0000",
}

--reserve soldierpool
this.reserveSoldierCounts={
  [30010]=40,
  [30020]=60,
  [30050]=140,
}

this.reserveSoldierNames={}
local solPrefix="sol_ih_"
this.numReserveSoldiers=40--tex SYNC number of soldier locators i added to fox2s

function this.BuildReserveSoldierNames(numReserveSoldiers,reserveSoldierNames)
  --this.ClearTable(reserveSoldierNames)
  reserveSoldierNames={}

  for i=0,numReserveSoldiers-1 do
    local name=string.format("%s%04d",solPrefix,i)
    reserveSoldierNames[#reserveSoldierNames+1]=name
  end
  return reserveSoldierNames
end

--this.reserveSoldierNames=this.BuildReserveSoldierNames(this.numReserveSoldiers,this.reserveSoldierNames)

function this.ResetObjectPool(objectType,objectNames)
  local pool={}
  for i=1,#objectNames do
    local objectName=objectNames[i]
    local gameId=GetGameObjectId(objectType,objectName)
    if gameId==NULL_ID then
    --InfLog.DebugPrint(objectName.."==NULL_ID")--DEBUG
    else
      pool[#pool+1]=objectName
    end
  end
  return pool
end

local function FillList(fillCount,sourceList,fillList)
  local addedSoldiers={}
  while fillCount>0 and #sourceList>0 do
    local soldierName=sourceList[#sourceList]
    if soldierName then
      sourceList[#sourceList]=nil--pop
      fillList[#fillList+1]=soldierName
      addedSoldiers[#addedSoldiers+1]=soldierName
      fillCount=fillCount-1
    end
  end
  return addedSoldiers
end

function this.ResetPool(objectNames)
  local namePool={}
  for i=1,#objectNames do
    namePool[i]=objectNames[i]
  end
  return namePool
end

function this.GetRandomPool(pool)
  local rndIndex=math.random(#pool)
  local name=pool[rndIndex]
  table.remove(pool,rndIndex)
  return name
end

local lrrpInd="_lrrp"
function this.BuildCpPool(soldierDefine)
  local cpPool={}

  for cpName,cpDefine in pairs(soldierDefine)do
    local cpId=GetGameObjectId("TppCommandPost2",cpName)
    if cpId==NULL_ID then
      InfLog.DebugPrint("AddLrrps soldierDefine "..cpName.."==NULL_ID")--DEBUG
    else
      --if #cpDefine==0 then --OFF wont be empty on restart from checkpoint
      --tex cp is labeled _lrrp
      if string.find(cpName,lrrpInd) then
        if not cpDefine.lrrpVehicle then
          cpPool[#cpPool+1]=cpName
        end
      end
    end
  end
  --InfLog.DebugPrint("lrrp #cpPool:"..#cpPool)--DEBUG
  return cpPool
end

function this.ModifyVehiclePatrolSoldiers(soldierDefine)
  if not Ivars.vehiclePatrolProfile:EnabledForMission() then
    return
  end

  InfMain.RandomSetToLevelSeed()

  local initPoolSize=#this.soldierPool
  for cpName,cpDefine in pairs(soldierDefine)do
    local numCpSoldiers=0
    for n=1,#cpDefine do
      if cpDefine[n] then
        numCpSoldiers=numCpSoldiers+1
      end
    end

    if cpDefine.lrrpVehicle then
      local numSeats=2
      if mvars.inf_patrolVehicleInfo then
        local vehicleInfo=mvars.inf_patrolVehicleInfo[cpDefine.lrrpVehicle]
        if vehicleInfo then
          local baseTypeInfo=InfVehicle.vehicleBaseTypes[vehicleInfo.baseType]
          if baseTypeInfo then
            numSeats=math.random(math.min(numSeats,baseTypeInfo.seats),baseTypeInfo.seats)
            --InfLog.DebugPrint(cpDefine.lrrpVehicle .. " numVehSeats "..numSeats)--DEBUG
          end
        end
      end
      --
      local seatDelta=numSeats-numCpSoldiers
      --DEBUG
      --      local isConvoy=false
      --      for travelPlan,convoyVehicles in pairs(mvars.inf_patrolVehicleConvoyInfo) do
      --        for i,vehicleName in ipairs(convoyVehicles)do
      --          if cpDefine.lrrpVehicle==vehicleName then
      --            InfLog.DebugPrint(vehicleName .." seatDelta "..seatDelta .. " #soldierPool "..#this.soldierPool)
      --            isConvoy=true
      --            break
      --          end
      --        end
      --      end
      --<DEBUG
      if seatDelta<0 then--tex over filled
        FillList(-seatDelta,cpDefine,this.soldierPool)
      elseif seatDelta>0 then
        local soldiersAdded=FillList(seatDelta,this.soldierPool,cpDefine)
        --        if isConvoy then--DEBUG
        --          InfLog.PrintInspect(soldiersAdded)
        --        end--
      end
      --if lrrpVehicle<
    end
    --for soldierdefine<
  end
  --    local poolChange=#this.soldierPool-initPoolSize--DEBUG
  --    InfLog.DebugPrint("pool change:"..poolChange)--DEBUG

  InfMain.RandomResetToOsTime()
end

--IN/OUT,SIDE reserveSoldierPool
function this.AddLrrps(soldierDefine,travelPlans)
  if not Ivars.enableLrrpFreeRoam:EnabledForMission() then
    return
  end

  InfMain.RandomSetToLevelSeed()

  this.lrrpDefines={}

  --tex find empty cps to use for lrrps
  local cpPool=this.BuildCpPool(soldierDefine)

  local planStr="travelIH_"

  local reserved=0--6
  --tex OFF
  --  local minSize=Ivars.lrrpSizeFreeRoam_MIN:Get()
  --  local maxSize=Ivars.lrrpSizeFreeRoam_MAX:Get()
  --  if maxSize>#this.soldierPool then
  --    maxSize=#this.soldierPool
  --  end
  local numLrrps=0--DEBUG

  local baseNameBag=InfMain.ShuffleBag:New()
  local locationName=InfMain.GetLocationName()
  local baseNames=InfMain.baseNames[locationName]
  for n,cpName in pairs(baseNames)do
    local cpDefine=soldierDefine[cpName]
    if cpDefine==nil then
    --InfLog.DebugPrint(tostring(cpName).." cpDefine==nil")--DEBUG
    else
      local cpId=GetGameObjectId("TppCommandPost2",cpName)
      if cpId==NULL_ID then
        InfLog.DebugPrint("baseNames "..tostring(cpName).." cpId==NULL_ID")--DEBUG
      else
        baseNameBag:Add(cpName)
      end
    end
  end

  --InfLog.DebugPrint("#baseNameBag:"..baseNameBag:Count())--DEBUG

  --tex one lrrp per two bases (start at one, head to next) is a nice target for num of lrrps, but lrrp cps or soldiercount may run out first
  while #this.soldierPool-reserved>0 do
    --tex the main limiter, available empty cps to use for lrrps
    if #cpPool==0 then
      --InfLog.DebugPrint"#cpPool==0"--DEBUG
      break
    end
    if #this.soldierPool==0 then
      --InfLog.DebugPrint"#soldierPool==0"--DEBUG
      break
    end

    local lrrpSize=2 --TUNE WIP custom lrrp size OFF to give coverage till I can come up with something better math.random(minSize,maxSize)
    --tex TODO: stop it from eating reserved
    --InfLog.DebugPrint("lrrpSize "..lrrpSize)--DEBUG

    local cpName=cpPool[#cpPool]
    cpPool[#cpPool]=nil

    --InfLog.DebugPrint("cpName:"..tostring(cpName))--DEBUG

    local cpDefine={}
    soldierDefine[cpName]=cpDefine--tex GOTCHA clearing the cp here, wheres in AddWildCards we are modding existing

    FillList(lrrpSize,this.soldierPool,cpDefine)

    local planName=planStr..cpName
    cpDefine.lrrpTravelPlan=planName
    local base1=baseNameBag:Next()
    local base2=baseNameBag:Next()
    travelPlans[planName]={
      {base=base1},
      {base=base2},
    }
    --tex info for interrog
    local lrrpDefine={
      cpDefine=cpDefine,
      base1=base1,
      base2=base2,
    }
    this.lrrpDefines[#this.lrrpDefines+1]=lrrpDefine

    numLrrps=numLrrps+1
  end
  --  InfLog.DebugPrint("num lrrps"..numLrrps)--DEBUG
  --  InfLog.DebugPrint("#soldierPool:"..#this.soldierPool)--DEBUG
  --  InfLog.DebugPrint("#cpPool:"..#cpPool)--DEBUG

  --Fill rest. can just do straight cpDefine order since they're build randomly anyway
  --GOTACHA: doesn't honor reserve, not that I'm using it anyway
  if #this.soldierPool>0 then
    for cpName,cpDefine in pairs(soldierDefine)do
      local cpId=GetGameObjectId("TppCommandPost2",cpName)
      if cpId==NULL_ID then
      else
        if cpDefine.lrrpTravelPlan and not cpDefine.lrrpVehicle then
          FillList(1,this.soldierPool,cpDefine)
        end
      end
    end
  end

  InfMain.RandomResetToOsTime()
end

local function FaceIsFemale(faceId)
  local isFemale=TppSoldierFace.CheckFemale{face={faceId}}
  return isFemale and isFemale[1]==1
end

this.MAX_WILDCARD_FACES=16
--TUNE:
--afgh has ~39 cps, mafr ~33
this.numWildCards=10
this.numWildCardFemales=5
--ASSUMPTION, ordered after vehicle cpdefines have been modified
function this.AddWildCards(soldierDefine,soldierTypes,soldierSubTypes,soldierPowerSettings,soldierPersonalAbilitySettings)
  --InfLog.PCall(function(soldierDefine,soldierTypes,soldierSubTypes,soldierPowerSettings,soldierPersonalAbilitySettings)--DEBUG

  if not Ivars.enableWildCardFreeRoam:EnabledForMission() then
    return
  end

  local InfEneFova=InfEneFova
  if not InfEneFova.inf_wildCardFemaleFaceList or #InfEneFova.inf_wildCardFemaleFaceList==0  then
    InfLog.DebugPrint"AddWildCards InfEneFova.inf_wildCardFemaleFaceList not set up, aborting"
    return
  end
  if not InfEneFova.inf_wildCardMaleFaceList or #InfEneFova.inf_wildCardMaleFaceList==0  then
    InfLog.DebugPrint"AddWildCards InfEneFova.inf_wildCardMaleFaceList not set up, aborting"
    return
  end

  InfMain.RandomSetToLevelSeed()

  local reserved=0

  local numLrrps=0

  local baseNamePool={}

  for cpName,cpDefine in pairs(soldierDefine)do
    if #cpDefine>0 then
      local cpId=GetGameObjectId("TppCommandPost2",cpName)
      if cpId==NULL_ID then
        InfLog.DebugPrint"AddWildCards soldierDefine cpId==NULL"--DEBUG
      else
        --tex TODO: allow quest_cp, but regenerate soldier on quest load
        if cpName=="quest_cp" then
        --tex TODO: consider if you want to  have wilcards in lrrps
        elseif cpDefine.lrrpVehicle==nil and cpDefine.lrrpTravelPlan~=nil then
        elseif cpDefine.lrrpVehicle~=nil then
          if #cpDefine>1 then--ASSUMPTION only armored vehicles have 1 occupant
            baseNamePool[#baseNamePool+1]=cpName
          end
        else
          baseNamePool[#baseNamePool+1]=cpName
        end
      end
    end
  end

  local locationName=InfMain.GetLocationName()

  local wildCardSubTypes={
    afgh="SOVIET_WILDCARD",
    mafr="PF_WILDCARD",
  }
  local wildCardSubType=wildCardSubTypes[locationName]or "SOVIET_WILDCARD"

  local gearPowers={
    "HELMET",
    "SOFT_ARMOR",
    "GUN_LIGHT",
    "NVG",
  --"GAS_MASK",
  }
  local weaponPowers={
    "ASSAULT",
    "SMG",
    "SHOTGUN",
    "MG",
    "SNIPER",
  --"MISSILE",
  }

  local weaponPowersBag=InfMain.ShuffleBag:New(weaponPowers)

  local abilityLevel="sp"
  local personalAbilitySettings={
    notice=abilityLevel,
    cure=abilityLevel,
    reflex=abilityLevel,
    shot=abilityLevel,
    grenade=abilityLevel,
    reload=abilityLevel,
    hp=abilityLevel,
    speed=abilityLevel,
    fulton=abilityLevel,
    holdup=abilityLevel
  }

  --TUNE:
  --tex GOTCHA LIMIT TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT=16
  --InfLog.DebugPrint("#baseNamePool:"..#baseNamePool)--DEBUG
  --this.numWildCards=math.max(1,math.ceil(#baseNamePool/4))--SYNC: MAX_WILDCARD_FACES
  this.numWildCards=math.min(TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT,this.numWildCards)
  --tex shifted outside of function-- this.numWildCardFemales=math.max(1,math.ceil(numWildCards/2))--SYNC: MAX_WILDCARD_FACES
  --InfLog.DebugPrint("numwildcards: "..numWildCards .. " numFemale:"..this.numWildCardFemales)--DEBUG

  --  InfLog.DebugPrint"ene_wildCardFaceList"--DEBUG >
  --  InfLog.PrintInspect(InfEneFova.inf_wildCardFaceList)--<

  this.ene_wildCardSoldiers={}
  this.ene_femaleWildCardSoldiers={}
  this.ene_wildCardCps={}

  local numFemales=0
  local maleFaceIdPool=this.ResetPool(InfEneFova.inf_wildCardMaleFaceList)
  local femaleFaceIdPool=this.ResetPool(InfEneFova.inf_wildCardFemaleFaceList)
  --InfLog.DebugPrint("#maleFaceIdPool:"..#maleFaceIdPool.." #femaleFaceIdPool:"..#femaleFaceIdPool)--DEBUG

  for i=1,this.numWildCards do
    if #baseNamePool==0 then
      InfLog.DebugPrint"#baseNamePool==0"--DEBUG
      break
    end

    local cpName=this.GetRandomPool(baseNamePool)
    --InfLog.DebugPrint("cpName:"..tostring(cpName))--DEBUG

    local cpDefine=soldierDefine[cpName]
    --local wildCardsPerCp=1
    --FillLrrp(wildCardsPerCp,this.soldierPool,cpDefine)
    if #cpDefine>0 then
      --WIP add soldier to cover
      --tex adding soldiers will mess things up because of soldiername random #cpdefine
      --alternative would be to save off wildcard soldiers and read that
      --      if #this.soldierPool>0 then
      --        local soldierName=this.soldierPool[#this.soldierPool]
      --        if soldierName then
      --      --          InfLog.DebugPrint("addwild pool "..soldierName)--DEBUG
      --          table.insert(cpDefine,soldierName)
      --          table.remove(this.soldierPool)--pop
      --        end
      --      end


      local soldierName=cpDefine[math.random(#cpDefine)]
      table.insert(this.ene_wildCardSoldiers,soldierName)
      table.insert(this.ene_wildCardCps,cpName)

      local isFemale=false
      if numFemales<this.numWildCardFemales then
        isFemale=true
        numFemales=numFemales+1
        table.insert(this.ene_femaleWildCardSoldiers,soldierName)
      end

      local faceIdPool
      if isFemale then
        faceIdPool=femaleFaceIdPool
      else
        faceIdPool=maleFaceIdPool
      end

      if #faceIdPool==0 then
        InfLog.DebugPrint"#faceIdPool too small, aborting"--DEBUG
        break
      end

      local faceId=this.GetRandomPool(faceIdPool)
      local bodyId=EnemyFova.INVALID_FOVA_VALUE
      if isFemale then
        local bodyInfo=InfEneFova.GetFemaleWildCardBodyInfo()
        if not bodyInfo or not bodyInfo.bodyId then
          InfLog.DebugPrint("WARNING no bodyinfo for wildcard")--DEBUG
        else
          bodyId=bodyInfo.bodyId
          if bodyId and type(bodyId)=="table"then
            bodyId=bodyId[math.random(#bodyId)]
          end
        end
      else
        local bodyTable=InfEneFova.wildCardBodyTable[locationName]
        bodyId=bodyTable[math.random(1,#bodyTable)]
      end
      --tex GOTCHA LIMIT TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT
      local hasSetting=false
      local uniqueSettings=TppEneFova.GetUniqueSettings()
      for i=1,#uniqueSettings do
        if uniqueSettings[i].name==soldierName then
          hasSetting=true
          if isFemale and not FaceIsFemale(uniqueSettings[i].faceId) then
            InfLog.DebugPrint("WARNING: AddWildCards "..soldierName.." marked as female and uniqueSetting face not female")--DEBUG
          end
        end
      end
      if not hasSetting then
        TppEneFova.RegisterUniqueSetting("enemy",soldierName,faceId,bodyId)
      end

      local gameObjectId = GetGameObjectId( "TppSoldier2", soldierName )
      if gameObjectId==NULL_ID then
        InfLog.DebugPrint"AddWildCards gameObjectId==NULL_ID"--DEBUG
      else
        local command={id="UseExtendParts",enabled=isFemale}
        SendCommand(gameObjectId,command)
      end

      soldierSubTypes[wildCardSubType]=soldierSubTypes[wildCardSubType] or {}
      table.insert(soldierSubTypes[wildCardSubType],soldierName)

      local soldierPowers={}
      for n,power in pairs(gearPowers) do
        soldierPowers[#soldierPowers+1]=power
      end
      soldierPowers[#soldierPowers+1]=weaponPowersBag:Next()

      soldierPowerSettings[soldierName]=soldierPowers

      soldierPersonalAbilitySettings[soldierName]=personalAbilitySettings
      --end

      numLrrps=numLrrps+1
    end
  end

  --InfLog.DebugPrint("numadded females:"..tostring(numFemales))--DEBUG

  --  --DEBUG
  --  for n,soldierName in pairs(this.ene_wildCardSoldiers)do
  --    InfLog.DebugPrint(soldierName)
  --    InfLog.PrintInspect(soldierPowerSettings[soldierName])
  -- end

  --InfLog.DebugPrint("num wildCards"..numLrrps)--DEBUG
  InfMain.RandomResetToOsTime()
  --end,soldierDefine,soldierTypes,soldierSubTypes,soldierPowerSettings,soldierPersonalAbilitySettings)--DEBUG
end

---
function this.MarkObject(gameId)
  if gameId==NULL_ID then
    return
  end

  local radiusLevel=0--0-9
  local goalType="none"--TppMarker.GoalTypes
  local viewType="all"--TppMarker.ViewTypes
  local randomLevel=0--0-9 randoms to radiuslevel I guess
  local setImportant=true
  local setNew=false
  TppMarker.Enable(gameId,0,"moving","all",0,setImportant,setNew)
end
---

local TppGameObject=TppGameObject

local gameObjectTypes={}
local gameObjectTypeLiteralStr="GAME_OBJECT_TYPE_"

--tex from exe, don't know if anythings missing (as it commonly seems)
this.gameObjectStringToType={
  GAME_OBJECT_TYPE_PLAYER2=TppGameObject.GAME_OBJECT_TYPE_PLAYER2,
  GAME_OBJECT_TYPE_COMMAND_POST2=TppGameObject.GAME_OBJECT_TYPE_COMMAND_POST2,
  GAME_OBJECT_TYPE_SOLDIER2=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2,
  GAME_OBJECT_TYPE_HOSTAGE2=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE2,
  GAME_OBJECT_TYPE_HOSTAGE_UNIQUE=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE_UNIQUE,
  GAME_OBJECT_TYPE_HOSTAGE_UNIQUE2=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE_UNIQUE2,
  GAME_OBJECT_TYPE_HOSTAGE_KAZ=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE_KAZ,
  GAME_OBJECT_TYPE_OCELOT2=TppGameObject.GAME_OBJECT_TYPE_OCELOT2,
  GAME_OBJECT_TYPE_HUEY2=TppGameObject.GAME_OBJECT_TYPE_HUEY2,
  GAME_OBJECT_TYPE_CODE_TALKER2=TppGameObject.GAME_OBJECT_TYPE_CODE_TALKER2,
  GAME_OBJECT_TYPE_SKULL_FACE2=TppGameObject.GAME_OBJECT_TYPE_SKULL_FACE2,
  GAME_OBJECT_TYPE_MANTIS2=TppGameObject.GAME_OBJECT_TYPE_MANTIS2,
  GAME_OBJECT_TYPE_BIRD2=TppGameObject.GAME_OBJECT_TYPE_BIRD2,
  GAME_OBJECT_TYPE_HORSE2=TppGameObject.GAME_OBJECT_TYPE_HORSE2,
  GAME_OBJECT_TYPE_HELI2=TppGameObject.GAME_OBJECT_TYPE_HELI2,
  GAME_OBJECT_TYPE_ENEMY_HELI=TppGameObject.GAME_OBJECT_TYPE_ENEMY_HELI,
  GAME_OBJECT_TYPE_OTHER_HELI=TppGameObject.GAME_OBJECT_TYPE_OTHER_HELI,
  GAME_OBJECT_TYPE_OTHER_HELI2=TppGameObject.GAME_OBJECT_TYPE_OTHER_HELI2,
  GAME_OBJECT_TYPE_BUDDYQUIET2=TppGameObject.GAME_OBJECT_TYPE_BUDDYQUIET2,
  GAME_OBJECT_TYPE_BUDDYDOG2=TppGameObject.GAME_OBJECT_TYPE_BUDDYDOG2,
  GAME_OBJECT_TYPE_BUDDYPUPPY=TppGameObject.GAME_OBJECT_TYPE_BUDDYPUPPY,
  GAME_OBJECT_TYPE_SAHELAN2=TppGameObject.GAME_OBJECT_TYPE_SAHELAN2,
  GAME_OBJECT_TYPE_PARASITE2=TppGameObject.GAME_OBJECT_TYPE_PARASITE2,
  GAME_OBJECT_TYPE_LIQUID2=TppGameObject.GAME_OBJECT_TYPE_LIQUID2,
  GAME_OBJECT_TYPE_VOLGIN2=TppGameObject.GAME_OBJECT_TYPE_VOLGIN2,
  GAME_OBJECT_TYPE_BOSSQUIET2=TppGameObject.GAME_OBJECT_TYPE_BOSSQUIET2,
  GAME_OBJECT_TYPE_UAV=TppGameObject.GAME_OBJECT_TYPE_UAV,
  GAME_OBJECT_TYPE_SECURITYCAMERA2=TppGameObject.GAME_OBJECT_TYPE_SECURITYCAMERA2,
  GAME_OBJECT_TYPE_GOAT=TppGameObject.GAME_OBJECT_TYPE_GOAT,
  GAME_OBJECT_TYPE_NUBIAN=TppGameObject.GAME_OBJECT_TYPE_NUBIAN,
  GAME_OBJECT_TYPE_CRITTER_BIRD=TppGameObject.GAME_OBJECT_TYPE_CRITTER_BIRD,
  GAME_OBJECT_TYPE_STORK=TppGameObject.GAME_OBJECT_TYPE_STORK,
  GAME_OBJECT_TYPE_EAGLE=TppGameObject.GAME_OBJECT_TYPE_EAGLE,
  GAME_OBJECT_TYPE_RAT=TppGameObject.GAME_OBJECT_TYPE_RAT,
  GAME_OBJECT_TYPE_ZEBRA=TppGameObject.GAME_OBJECT_TYPE_ZEBRA,
  GAME_OBJECT_TYPE_WOLF=TppGameObject.GAME_OBJECT_TYPE_WOLF,
  GAME_OBJECT_TYPE_JACKAL=TppGameObject.GAME_OBJECT_TYPE_JACKAL,
  GAME_OBJECT_TYPE_BEAR=TppGameObject.GAME_OBJECT_TYPE_BEAR,
  GAME_OBJECT_TYPE_CORPSE=TppGameObject.GAME_OBJECT_TYPE_CORPSE,
  GAME_OBJECT_TYPE_MBQUIET=TppGameObject.GAME_OBJECT_TYPE_MBQUIET,
  GAME_OBJECT_TYPE_COMMON_HORSE2=TppGameObject.GAME_OBJECT_TYPE_COMMON_HORSE2,
  GAME_OBJECT_TYPE_HORSE2_FOR_VR=TppGameObject.GAME_OBJECT_TYPE_HORSE2_FOR_VR,
  GAME_OBJECT_TYPE_PLAYER_HORSE2_FOR_VR=TppGameObject.GAME_OBJECT_TYPE_PLAYER_HORSE2_FOR_VR,
  GAME_OBJECT_TYPE_VOLGIN2_FOR_VR=TppGameObject.GAME_OBJECT_TYPE_VOLGIN2_FOR_VR,
  GAME_OBJECT_TYPE_WALKERGEAR2=TppGameObject.GAME_OBJECT_TYPE_WALKERGEAR2,
  GAME_OBJECT_TYPE_COMMON_WALKERGEAR2=TppGameObject.GAME_OBJECT_TYPE_COMMON_WALKERGEAR2,
  GAME_OBJECT_TYPE_BATTLEGEAR=TppGameObject.GAME_OBJECT_TYPE_BATTLEGEAR,
  GAME_OBJECT_TYPE_EXAMPLE=TppGameObject.GAME_OBJECT_TYPE_EXAMPLE,
  GAME_OBJECT_TYPE_SAMPLE_GAME_OBJECT=TppGameObject.GAME_OBJECT_TYPE_SAMPLE_GAME_OBJECT,
  GAME_OBJECT_TYPE_NOTICE_OBJECT=TppGameObject.GAME_OBJECT_TYPE_NOTICE_OBJECT,
  GAME_OBJECT_TYPE_VEHICLE=TppGameObject.GAME_OBJECT_TYPE_VEHICLE,
  GAME_OBJECT_TYPE_MOTHER_BASE_CONTAINER=TppGameObject.GAME_OBJECT_TYPE_MOTHER_BASE_CONTAINER,
  GAME_OBJECT_TYPE_EQUIP_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_EQUIP_SYSTEM,
  GAME_OBJECT_TYPE_PICKABLE_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_PICKABLE_SYSTEM,
  GAME_OBJECT_TYPE_COLLECTION_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_COLLECTION_SYSTEM,
  GAME_OBJECT_TYPE_THROWING_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_THROWING_SYSTEM,
  GAME_OBJECT_TYPE_PLACED_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_PLACED_SYSTEM,
  GAME_OBJECT_TYPE_SHELL_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_SHELL_SYSTEM,
  GAME_OBJECT_TYPE_BULLET_SYSTEM3=TppGameObject.GAME_OBJECT_TYPE_BULLET_SYSTEM3,
  GAME_OBJECT_TYPE_CASING_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_CASING_SYSTEM,
  GAME_OBJECT_TYPE_FULTON=TppGameObject.GAME_OBJECT_TYPE_FULTON,
  GAME_OBJECT_TYPE_BALLOON_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_BALLOON_SYSTEM,
  GAME_OBJECT_TYPE_PARACHUTE_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_PARACHUTE_SYSTEM,
  GAME_OBJECT_TYPE_SUPPLY_CBOX=TppGameObject.GAME_OBJECT_TYPE_SUPPLY_CBOX,
  GAME_OBJECT_TYPE_SUPPORT_ATTACK=TppGameObject.GAME_OBJECT_TYPE_SUPPORT_ATTACK,
  GAME_OBJECT_TYPE_RANGE_ATTACK=TppGameObject.GAME_OBJECT_TYPE_RANGE_ATTACK,
  GAME_OBJECT_TYPE_CBOX=TppGameObject.GAME_OBJECT_TYPE_CBOX,
  GAME_OBJECT_TYPE_OBSTRUCTION_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_OBSTRUCTION_SYSTEM,
  GAME_OBJECT_TYPE_DECOY_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_DECOY_SYSTEM,
  GAME_OBJECT_TYPE_CAPTURECAGE_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_CAPTURECAGE_SYSTEM,
  GAME_OBJECT_TYPE_DUNG_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_DUNG_SYSTEM,
  GAME_OBJECT_TYPE_MARKER2_LOCATOR=TppGameObject.GAME_OBJECT_TYPE_MARKER2_LOCATOR,
  GAME_OBJECT_TYPE_ESPIONAGE_RADIO=TppGameObject.GAME_OBJECT_TYPE_ESPIONAGE_RADIO,
  GAME_OBJECT_TYPE_MGO_ACTOR=TppGameObject.GAME_OBJECT_TYPE_MGO_ACTOR,
  GAME_OBJECT_TYPE_FOB_GAME_DAEMON=TppGameObject.GAME_OBJECT_TYPE_FOB_GAME_DAEMON,
  GAME_OBJECT_TYPE_SYSTEM_RECEIVER=TppGameObject.GAME_OBJECT_TYPE_SYSTEM_RECEIVER,
  GAME_OBJECT_TYPE_SEARCHLIGHT=TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT,
  GAME_OBJECT_TYPE_FULTONABLE_CONTAINER=TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER,
  GAME_OBJECT_TYPE_GARBAGEBOX=TppGameObject.GAME_OBJECT_TYPE_GARBAGEBOX,
  GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE=TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE,
  GAME_OBJECT_TYPE_GATLINGGUN=TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN,
  GAME_OBJECT_TYPE_MORTAR=TppGameObject.GAME_OBJECT_TYPE_MORTAR,
  GAME_OBJECT_TYPE_MACHINEGUN=TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN,
  GAME_OBJECT_TYPE_DOOR=TppGameObject.GAME_OBJECT_TYPE_DOOR,
  GAME_OBJECT_TYPE_WATCH_TOWER=TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER,
  GAME_OBJECT_TYPE_TOILET=TppGameObject.GAME_OBJECT_TYPE_TOILET,
  GAME_OBJECT_TYPE_ESPIONAGEBOX=TppGameObject.GAME_OBJECT_TYPE_ESPIONAGEBOX,
  GAME_OBJECT_TYPE_IR_SENSOR=TppGameObject.GAME_OBJECT_TYPE_IR_SENSOR,
  GAME_OBJECT_TYPE_EVENT_ANIMATION=TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION,
  GAME_OBJECT_TYPE_BRIDGE=TppGameObject.GAME_OBJECT_TYPE_BRIDGE,
  GAME_OBJECT_TYPE_WATER_TOWER=TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER,
  GAME_OBJECT_TYPE_RADIO_CASSETTE=TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE,
  GAME_OBJECT_TYPE_POI_SYSTEM=TppGameObject.GAME_OBJECT_TYPE_POI_SYSTEM,
  GAME_OBJECT_TYPE_SAMPLE_MANAGER=TppGameObject.GAME_OBJECT_TYPE_SAMPLE_MANAGER,
}
this.gameObjectTypeToString={}
for k,v in pairs(this.gameObjectStringToType)do
  this.gameObjectTypeToString[v]=k
end

--
function this.GenerateNameList(prefix,num,list)
  local list=list or {}
  for i=0,num-1 do
    local name=string.format("%s%04d",prefix,i)
    table.insert(list,name)
  end
  return list
end

this.jeepNames=this.GenerateNameList("veh_lv_",20)
this.truckNames=this.GenerateNameList("veh_trc_",10)

--tex there's no real lookup for this I've found
--there's probably faster tables (look in DefineSoldiers()) that have the cpId>soldierId, but this is nice for the soldiername,cpname
function this.ObjectNameForGameIdList(findId,list,objectType)
  for n,name in ipairs(list)do
    local gameId=NULL_ID
    if objectType then
      gameId=GetGameObjectId(objectType,name)
    else
      gameId=GetGameObjectId(name)
    end
    if gameId~=NULL_ID then
      if gameId==findId then
        return name
      end
    end
  end
end

function this.ObjectNameForGameId(findId)
  local tppSoldier2Str="TppSoldier2"

  for cpName,soldierNames in pairs(mvars.ene_soldierDefine)do
    local gameId=this.ObjectNameForGameIdList(findId,soldierNames,tppSoldier2Str)
    if gameId then
      return gameId,cpName
    end
  end

  local nameLists={
    {TppReinforceBlock.REINFORCE_SOLDIER_NAMES,tppSoldier2Str},
    InfNPCHeli.heliNames.UTH,
    InfNPCHeli.heliNames.HP48,
    this.jeepNames,
    this.truckNames,
  }
  for i,list in ipairs(nameLists)do
    local gameId
    if type(list[1])=="table" then
      gameId=this.ObjectNameForGameIdList(findId,list[1],list[2])
    else
      gameId=this.ObjectNameForGameIdList(findId,list)
    end
    if gameId then
      return gameId
    end
  end

  local enemyHeli="EnemyHeli"
  local gameId=GetGameObjectId(enemyHeli)
  if gameId~=NULL_ID then
    if gameId==findId then
      return enemyHeli
    end
  end

  return "object name not found"
end


function this.ClearStatus()
  InfLog.PCall(function()
    local splash=SplashScreen.Create("abortsplash","/Assets/tpp/ui/ModelAsset/sys_logo/Pictures/common_kjp_logo_clp_nmp.ftex",640,640)
    SplashScreen.Show(splash,0,0.3,0)

    vars.playerDisableActionFlag=PlayerDisableAction.NONE
    Player.SetPadMask{settingName="AllClear"}
    Tpp.SetGameStatus{target="all",enable=true,scriptName="InfMain.lua"}
    InfLog.DebugPrint"Cleared status"
  end)
end

this.heliColors={
  [TppDefine.ENEMY_HELI_COLORING_TYPE.DEFAULT]={pack="",fova=""},
  [TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK]={pack="/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_blk.fpk",fova="/Assets/tpp/fova/mecha/sbh/sbh_ene_blk.fv2"},
  [TppDefine.ENEMY_HELI_COLORING_TYPE.RED]={pack="/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_red.fpk",fova="/Assets/tpp/fova/mecha/sbh/sbh_ene_red.fv2"}
}
this.heliColorNames={
  "DEFAULT",
  "BLACK",
  "RED",
}

local startOnFootStr="startOnFoot"
function this.IsStartOnFoot(missionCode,isAssaultLz)
  local missionCode=missionCode or vars.missionCode
  local enabled=IvarProc.EnabledForMission(startOnFootStr,missionCode)

  local assault=IvarProc.IsForMission(startOnFootStr,"NOT_ASSAULT",missionCode)
  if isAssaultLz and assault then
    return false
  else
    return enabled
  end
end

function this.GetAverageRevengeLevel()
  local stealthLevel=TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)
  local combatLevel=TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)

  return math.ceil((stealthLevel+combatLevel)/2)
end

this.locationIdForName={
  afgh=10,
  mafr=20,
  cypr=30,
  mtbs=50,
  mbqf=55,
}

--tex doesn't seem to work, either I'm doing something wrong or the buddy system doesnt use it for mb
function this.OverwriteBuddyPosForMb()
  if TppMission.IsMbFreeMissions(vars.missionCode) and Ivars.mbEnableBuddies:Is(1)then
    if gvars.heli_missionStartRoute~=0 then
      local groundStartPosition=InfLZ.GetGroundStartPosition(gvars.heli_missionStartRoute)
      if groundStartPosition then
        local mbBuddyEntrySettings={}
        local pos=Vector3(groundStartPosition.pos[1],groundStartPosition.pos[2],groundStartPosition.pos[3])
        local entryEntry={}
        entryEntry[EntryBuddyType.BUDDY]={pos,0}
        --entryEntry[EntryBuddyType.VEHICLE]={pos,0}
        mbBuddyEntrySettings[gvars.heli_missionStartRoute]=entryEntry
        TppEnemy.NPCEntryPointSetting(mbBuddyEntrySettings)
      end
    end
  end
end


--caller: mtbs_enemy.OnLoad
--TUNE
-- CULL local additionalSoldiersPerPlat=5
local maxSoldiersOnPlat=9

function this.ModifyEnemyAssetTable()
  --InfLog.PCall(function()--DEBUG
  if vars.missionCode~=30050 then
    return
  end

  if Ivars.mbAdditionalSoldiers:Is(0) then
    return
  end

  this.numReserveSoldiers=this.reserveSoldierCounts[vars.missionCode] or 0
  this.reserveSoldierNames=this.BuildReserveSoldierNames(this.numReserveSoldiers,this.reserveSoldierNames)
  this.soldierPool=this.ResetPool(this.reserveSoldierNames)

  local GetMBEnemyAssetTable=TppEnemy.GetMBEnemyAssetTable or mvars.mbSoldier_funcGetAssetTable

  local plntPrefix="plnt"
  for clusterId=1,#TppDefine.CLUSTER_NAME do
    --local clusterName=TppDefine.CLUSTER_NAME[clusterId]
    local totalPlatsRouteCount=0--DEBUG
    local soldierCountFinal=0

    local grade=TppLocation.GetMbStageClusterGrade(clusterId)
    if grade>0 then
      for i=1,grade do
        local clusterAssetTable=GetMBEnemyAssetTable(clusterId)
        local platName=plntPrefix..(i-1)

        local platInfo=clusterAssetTable[platName]

        local soldierList=platInfo.soldierList
        --        if clusterId==mtbs_cluster.GetCurrentClusterId() then--DEBUG>
        --        InfLog.DebugPrint("cluster "..clusterId.. " "..platName.." #soldierListpre "..#soldierList)--DEBUG
        --        end--<

        local sneakRoutes=platInfo.soldierRouteList.Sneak[1].inPlnt
        local nightRoutes=platInfo.soldierRouteList.Night[1].inPlnt

        local addedRoutes=false
        for i=1,#sneakRoutes do
          if sneakRoutes[i]==nightRoutes[1] then
            addedRoutes=true
            break
          end
        end
        if not addedRoutes then
          for i=1,#nightRoutes do
            sneakRoutes[#sneakRoutes+1]=nightRoutes[i]
          end
          for i=1,#sneakRoutes do
            nightRoutes[#nightRoutes+1]=sneakRoutes[i]
          end
        end

        local minRouteCount=math.min(#sneakRoutes,#nightRoutes)
        --OFF totalPlatsRouteCount=totalPlatsRouteCount+minRouteCount --DEBUG

        --CULL local numToAdd=math.min((minRouteCount-3)-#soldierList,additionalSoldiersPerPlat)--tex MAGIC this only really affects main plats which only have 12(-6soldiers) routes (with combined sneak/night). Rest have 15+
        local numToAdd=maxSoldiersOnPlat-#soldierList
        if numToAdd>0 then
          FillList(numToAdd,this.soldierPool,soldierList)
        end
        soldierCountFinal=soldierCountFinal+#soldierList
        --        if clusterId==mtbs_cluster.GetCurrentClusterId() then--DEBUG>
        --          local totalRouteCount=#sneakRoutes+#nightRoutes
        --          InfLog.DebugPrint("cluster "..clusterId.. " "..platName.. " minRouteCount "..minRouteCount.." totalRouteCount "..totalRouteCount.." numToAdd "..numToAdd.." #soldierList "..#soldierList)--DEBUG
        --          --InfLog.PrintInspect(soldierList)--DEBUG
        --        end--<
      end
    end

    --InfLog.DebugPrint(string.format("cluster:%d routeCount:%d soldierCountFinal:%d",clusterId,routeCount,soldierCountFinal))--DEBUG
  end
  --InfLog.DebugPrint("#this.soldierPool:"..#this.soldierPool)--DEBUG
  --end)--
end

local mineFieldMineTypes={
  {TppEquip.EQP_SWP_DMine,3},--tex bias toward original minefield intentsion/anti personal mines
  TppEquip.EQP_SWP_SleepingGusMine,
  TppEquip.EQP_SWP_AntitankMine,
  TppEquip.EQP_SWP_ElectromagneticNetMine,
}

--CALLER: TppMain.OnInitialize, just after loc_locationCommonTable.OnInitialize()
function this.ModifyMinesAndDecoys()
  if Ivars.randomizeMineTypes:Is(0) then
    return
  end

  local mineTypeBag=InfMain.ShuffleBag:New(mineFieldMineTypes)
  if mvars.rev_revengeMineList then
    InfMain.RandomSetToLevelSeed()
    for cpName,mineFields in pairs(mvars.rev_revengeMineList)do
      for i,mineField in ipairs(mineFields)do
        if mineField.mineLocatorList then
          for i,locatorName in ipairs(mineField.mineLocatorList)do
            TppPlaced.ChangeEquipIdByLocatorName(locatorName,mineTypeBag:Next())
          end
        end
        --tex WIP no go
        --          if mineField.decoyLocatorList then
        --            for i,locatorName in ipairs(mineField.decoyLocatorList)do
        --              TppPlaced.ChangeEquipIdByLocatorName(locatorName,TppEquip.EQP_SWP_SleepingGusMine)
        --            end
        --          end
      end
    end
    InfMain.RandomResetToOsTime()
  end
end
--
function this.ScaleResourceTables()
  --tex TODO migrate RESOURCE_INFORMATION_TABLE here (or shift this stuff to own module) once I can be bothered faffing about with table copying and cull the scaling in TppPlayer OnPickUpCollection and TppTerminal AddPickedUpResourceToTempBuffer
  local resourceScale=Ivars.resourceAmountScale:Get()/100
  TppMotherBaseManagement.SetSmallDiamondGmp{gmp=TppDefine.SMALL_DIAMOND_GMP*resourceScale}
  TppMotherBaseManagement.SetLargeDiamondGmp{gmp=TppDefine.LARGE_DIAMOND_GMP*resourceScale}
  --tex defaults, from MbmCommonSetting20BaseRecSec.lua
  --tex GOTCHA I think values might be capped at 10k
  local containerParams={
    commonMetalCounts={white=750,red=7500,yellow=1500},
    fuelResourceCounts={white=750,red=7500,yellow=1500},
    bioticResourceCounts={white=750,red=7500,yellow=1500},
    minorMetalCounts={white=400,red=4000,yellow=800},
    preciousMetalCounts={white=50,red=500,yellow=100},
    usableResourceContainerRate=50,
    redContainerCountRate=40,
    yellowContainerCountRate=40
  }
  for k,v in pairs(containerParams) do
    if IsTable(v) then
      for containerType,resourceCount in pairs(v) do
        v[containerType]=resourceCount*resourceScale
      end
    end
  end
  TppMotherBaseManagement.RegisterContainerParam(containerParams)
end
--
function this.ReadSaveVar(name,category)
  local category=category or TppScriptVars.CATEGORY_GAME_GLOBAL
  local globalSlotForSaving={TppDefine.SAVE_SLOT.SAVING,TppDefine.SAVE_FILE_INFO[category].slot}
  return TppScriptVars.GetVarValueInSlot(globalSlotForSaving,"gvars",name,0)
end

--UTIL TODO shift all util functions somewhere
this.locationNames={
  [10]="afgh",
  [20]="mafr",
  [30]="cypr",
  [50]="mtbs",
  [55]="mbqf",
}
function this.GetLocationName()
  return this.locationNames[vars.locationCode]
end
--tex the default sort anyway
local SortAscendFunc=function(a,b)
  if a<b then
    return true
  end
  return false
end
function this.SortAscend(sortTable)
  table.sort(sortTable)
end

function this.ClearTable(_table)
  for i=0, #_table do
    _table[i]=nil
  end
end

this.ShuffleBag={
  currentItem=nil,
  currentPosition=-1,
  data={},
  New=function(self,table)
    local newBag={}
    newBag.currentItem=nil
    newBag.currentPosition=-1
    newBag.data={}

    setmetatable(newBag,self)
    self.__index=self

    if table then
      newBag:Fill(table)
    end

    return newBag
  end,
  Fill=function(self,table,amount)
    local tableTypeStr="table"
    for i=1,#table do
      local item=table[i]
      if type(item)==tableTypeStr then
        self:Add(item[1],item[2])
      else
        self:Add(item,amount)
      end
    end
  end,
  Add=function(self,item,amount)
    local amount=amount or 1
    for i=1,amount do
      self.data[#self.data+1]=item

      self.currentPosition=#self.data
    end
  end,
  Next=function(self)
    --run out, start again
    if self.currentPosition<2 then
      self.currentPosition=#self.data
      self.currentItem=self.data[1]
      return self.currentItem
    end
    --picks between start of array and currentposition, which decreases from end of array
    local pos=math.random(self.currentPosition)

    self.currentItem=self.data[pos]
    self.data[pos]=self.data[self.currentPosition]
    self.data[self.currentPosition]=self.currentItem
    self.currentPosition=self.currentPosition-1

    return self.currentItem
  end,
  Count=function(self)
    return #self.data
  end,
}

function this.IsMBDemoStage()
  if vars.missionCode~=30050 then
    return false
  end

  return (not TppPackList.IsMissionPackLabel"default") or TppDemo.IsBattleHangerDemo(TppDemo.GetMBDemoName())
end


function this.PlayerVarsSanityCheck()
  local faceEquipInfo=InfFova.playerFaceEquipIdInfo[vars.playerFaceEquipId+1]
  if faceEquipInfo and faceEquipInfo.playerTypes and not faceEquipInfo.playerTypes[vars.playerType] then
    vars.playerFaceEquipId=0
  end

  if TppMission.IsFOBMission(vars.missionCode)then
    if vars.playerFaceId > Soldier2FaceAndBodyData.highestVanillaFaceId then
      if vars.playerType==PlayerType.DD_MALE then
        vars.playerFaceId=0
      elseif vars.playerType==PlayerType.DD_FEMALE then
        vars.playerFaceId=InfEneFova.DEFAULT_FACEID_FEMALE
      end
    end
  end
end

function this.WeaponVarsSanityCheck()
  --tex throw on some default weapons if using dummy/equip none so to not run afoul of CheckPlayerEquipmentServerItemCorrect
  --see SetSubsistenceSettings for alt attempt that doesn't seem to work.
  --TODO: currently the weapons arent added via RequestLoadToEquipMissionBlock so weapons wont be usable, but then user is going into fob with equip_none so whatev
  if TppMission.IsFOBMission(vars.missionCode) then
    local changedWeapon=vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]==TppEquip.EQP_None or vars.weapons[TppDefine.WEAPONSLOT.SECONDARY]==TppEquip.EQP_None
    if changedWeapon then
      InfMenu.PrintLangId"fob_weapon_change"
    end
    if vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]==TppEquip.EQP_None then
      --SVG-76 grade 1
      Player.ChangeEquip{
        equipId=TppEquip.EQP_WP_East_ar_010,
        stock=31,
        stockSub=0,
        ammo=180,
        ammoSub=0,
        dropPrevEquip = false,
      }
    end
    if vars.weapons[TppDefine.WEAPONSLOT.SECONDARY]==TppEquip.EQP_None then
      --Wu S grade 1
      Player.ChangeEquip{
        equipId=TppEquip.EQP_WP_West_thg_010,
        stock=8,
        stockSub=0,
        ammo=14,
        ammoSub=0,
        suppressorLife=100,
        isSuppressorOn=true,
        isLightOn=false,
        dropPrevEquip=false,
      }
    end
  end
end

function this.ValueOrIvarValue(value)
  local value=value or 0
  if IsTable(value) then
    value=value:Get()
  end
  return value
end

--tex just from Tpp.IsGameObjectType, don't want to change it from local
function this.IsGameObjectType(gameObject,checkType)
  if gameObject==nil then
    return
  end
  if gameObject==NULL_ID then
    return
  end
  local typeIndex=GetTypeIndex(gameObject)
  if typeIndex==checkType then
    return true
  else
    return false
  end
end

function this.LoadExternalModule(moduleName)
  local module=_G[moduleName]
  if module and module.PreModuleReload then
    module.PreModuleReload()
  end

  --tex clear so require reloads file, kind of defeats purpose of using require, but requires path search is more useful
  package.loaded[moduleName]=nil
  local sucess,module=pcall(require,moduleName)
  if not sucess then
    InfLog.Add(module)
    --tex suppress on startup so it doesnt crowd out ModuleErrorMessage for user.
    if this.doneStartup then
      InfLog.DebugPrint("Could not load module "..moduleName)
    end
  else
    _G[moduleName]=module
  end
  return module
end

--SIDE: modules,this.modulesOK
function this.LoadExternalModules()
  this.modulesOK=true
  for i,moduleName in ipairs(InfModules.moduleNames) do
    this.LoadExternalModule(moduleName)
    local module=_G[moduleName]
    if module then
      module.name=moduleName
      table.insert(InfModules,module)
    else
      this.modulesOK=false
    end
  end
end

function this.ModuleErrorMessage()
  --tex TODO: if InfLang then printlangid else -v-
  InfLog.DebugPrint"Infinite Heaven: Could not load modules from MGSV_TPP\\mod\\. See Installation.txt"
end

--EXEC
ivars={}--tex GLOBAL

_G.InfMain=this--WORKAROUND allowing external modules access to this before it's actually returned --KLUDGE using _G since I'm already definining InfMain as local

this.LoadExternalModule"InfModules"
if not InfModules then
  this.ModuleErrorMessage()
else
  this.LoadExternalModules()
  if not this.modulesOK then
    this.ModuleErrorMessage()
  end
  this.doneStartup=true
end

return this

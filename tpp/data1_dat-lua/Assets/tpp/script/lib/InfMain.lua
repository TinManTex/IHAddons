-- DOBUILD: 1 --
local this={}

this.DEBUGMODE=false
this.modVersion = "r87"
this.modName = "Infinite Heaven"

--LOCALOPT:
local IsFunc=Tpp.IsTypeFunc
local IsString=Tpp.IsTypeString
local NULL_ID=GameObject.NULL_ID
local GetGameObjectId=GameObject.GetGameObjectId
local SendCommand=GameObject.SendCommand
local Enum=TppDefine.Enum

this.debugSplash=SplashScreen.Create("debugEagle","/Assets/tpp/ui/texture/Emblem/front/ui_emb_front_5005_l_alp.ftex",640,640)

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

--[[REF:
EnemyType.TYPE_SOVIET
EnemyType.TYPE_PF
EnemyType.TYPE_DD
EnemyType.TYPE_SKULL
EnemyType.TYPE_CHILD
--]]
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
function this.SoldierTypeNameForType(soldierType)--tex maybe I'm missing something but not having luck indexing by EnemyType
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

function this.IsMbWarGames(missionId)
  missionId=missionId or vars.missionCode
  return gvars.mbWarGames>0 and missionId==30050
end
function this.IsMbPlayTime(missionId)
  missionId=missionId or vars.missionCode
  if missionId==30050 then
    return gvars.mbPlayTime>0 or gvars.mbSoldierEquipGrade>0
  end
  return false
end
function this.IsForceSoldierSubType()
  return gvars.forceSoldierSubType>0 and TppMission.IsFreeMission(vars.missionCode)
end

function this.GetMbsClusterSecuritySoldierEquipGrade(missionId)--SYNC: mbSoldierEquipGrade
  local grade = TppMotherBaseManagement.GetMbsClusterSecuritySoldierEquipGrade{}
  if this.IsMbPlayTime(missionId) and gvars.mbSoldierEquipGrade>Ivars.mbSoldierEquipGrade.enum.MBDEVEL then
    --TppUiCommand.AnnounceLogView("GetEquipGrade ismbplay, grade > devel")--DEBUG
    if gvars.mbSoldierEquipGrade==Ivars.mbSoldierEquipGrade.enum.RANDOM then
      grade = math.random(1,10)
    else
      grade = gvars.mbSoldierEquipGrade-Ivars.mbSoldierEquipGrade.enum.RANDOM
    end
  end
  --TppUiCommand.AnnounceLogView("GetEquipGrade: gvar:".. gvars.mbSoldierEquipGrade .." grade: ".. grade)--DEBUG
  --TppUiCommand.AnnounceLogView("Caller: ".. tostring(debug.getinfo(2).name) .." ".. tostring(debug.getinfo(2).source))--DEBUG
  return grade
end

function this.GetMbsClusterSecuritySoldierEquipRange(missionId)
  if InfMain.IsMbPlayTime(missionId) then
    if gvars.mbSoldierEquipRange==Ivars.mbSoldierEquipRange.enum.RANDOM then
      return math.random(0,2)--REF:{ "FOB_ShortRange", "FOB_MiddleRange", "FOB_LongRange", }, but range index from 0
    elseif gvars.mbSoldierEquipRange>0 then
      return gvars.mbSoldierEquipRange-1
    end
  end
  return TppMotherBaseManagement.GetMbsClusterSecuritySoldierEquipRange()
end

function this.GetMbsClusterSecurityIsNoKillMode(missionId)
  if this.IsMbPlayTime(missionId) then--tex PrepareDDParameter mbwargames, mbsoldierequipgrade
    return gvars.mbWarGames==Ivars.mbWarGames.enum.NONLETHAL
  end
  return TppMotherBaseManagement.GetMbsClusterSecurityIsNoKillMode()
end

function this.DisplayFox32(foxString)
  local str32 = Fox.StrCode32(foxString)
  TppUiCommand.AnnounceLogView("string :"..foxString .. "="..str32)
end

--[[
function this.soldierFovBodyTableAfghan(missionId)
  local bodyTable={
    {0,MAX_REALIZED_COUNT},
    {1,MAX_REALIZED_COUNT},
    {2,MAX_REALIZED_COUNT},
    {5,MAX_REALIZED_COUNT},
    {6,MAX_REALIZED_COUNT},
    {7,MAX_REALIZED_COUNT},
    {10,MAX_REALIZED_COUNT},
    {11,MAX_REALIZED_COUNT},
    {20,MAX_REALIZED_COUNT},
    {21,MAX_REALIZED_COUNT},
    {22,MAX_REALIZED_COUNT},
    {25,MAX_REALIZED_COUNT},
    {26,MAX_REALIZED_COUNT},
    {27,MAX_REALIZED_COUNT},
    {30,MAX_REALIZED_COUNT},
    {31,MAX_REALIZED_COUNT},
    {TppEnemyBodyId.prs2_main0_v00,MAX_REALIZED_COUNT}
  }
  if not this.IsNotRequiredArmorSoldier(missionId)then
    local e={TppEnemyBodyId.sva0_v00_a,MAX_REALIZED_COUNT}
    table.insert(bodyTable,e)
  end
  return bodyTable
end
function this.soldierFovBodyTableAfrica(missionId)
  local bodyTable={
    {50,MAX_REALIZED_COUNT},
    {51,MAX_REALIZED_COUNT},
    {55,MAX_REALIZED_COUNT},
    {60,MAX_REALIZED_COUNT},
    {61,MAX_REALIZED_COUNT},
    {70,MAX_REALIZED_COUNT},
    {71,MAX_REALIZED_COUNT},
    {75,MAX_REALIZED_COUNT},
    {80,MAX_REALIZED_COUNT},
    {81,MAX_REALIZED_COUNT},
    {90,MAX_REALIZED_COUNT},
    {91,MAX_REALIZED_COUNT},
    {95,MAX_REALIZED_COUNT},
    {100,MAX_REALIZED_COUNT},
    {101,MAX_REALIZED_COUNT},
    {TppEnemyBodyId.prs5_main0_v00,MAX_REALIZED_COUNT}
  }
  local armorTypeTable=this.GetArmorTypeTable(missionId)
  if armorTypeTable~=nil then
    local numArmorTypes=#armorTypeTable
    if numArmorTypes>0 then
      for t,armorType in ipairs(armorTypeTable)do
        if armorType==TppDefine.AFR_ARMOR.TYPE_ZRS then
          table.insert(bodyTable,{TppEnemyBodyId.pfa0_v00_a,MAX_REALIZED_COUNT})
        elseif armorType==TppDefine.AFR_ARMOR.TYPE_CFA then
          table.insert(bodyTable,{TppEnemyBodyId.pfa0_v00_b,MAX_REALIZED_COUNT})
        elseif armorType==TppDefine.AFR_ARMOR.TYPE_RC then
          table.insert(bodyTable,{TppEnemyBodyId.pfa0_v00_c,MAX_REALIZED_COUNT})
        else
          table.insert(bodyTable,{TppEnemyBodyId.pfa0_v00_a,MAX_REALIZED_COUNT})
        end
      end
    end
  end
end
--]]

function this.ResetCpTableToDefault()
  local subTypeOfCp=TppEnemy.subTypeOfCp
  local subTypeOfCpDefault=TppEnemy.subTypeOfCpDefault
  for cp, subType in pairs(subTypeOfCp)do
    subTypeOfCp[cp]=subTypeOfCpDefault[cp]
  end
end

--[[function this.GetGameId(gameId,type)
  if IsString(gameId) then
    gameId=GetGameObjectId(gameId) 
    local soldierId=GetGameObjectId("TppSoldier2",soldierName)
      if soldierId~=NULL_ID then
  end
  if gameId==nil or gameId==NULL_ID then
    return nil
  end
end--]]

function this.ChangePhase(cpName,phase)
  local gameId=GetGameObjectId("TppCommandPost2",cpName)
  if gameId==NULL_ID then
    InfMenu.DebugPrint("Could not find cp "..cpName)
    return
  end
  local command={id="SetPhase",phase=phase}
  SendCommand(gameId,command)
end

function this.SetKeepAlert(cpName,enable)
  local gameId=GetGameObjectId("TppCommandPost2",cpName)
  if gameId==NULL_ID then
    InfMenu.DebugPrint("Could not find cp "..cpName)
    return
  end
  local command={id="SetKeepAlert",enable=enable}
  GameObject.SendCommand(gameId,command)
end

--

this.SetFriendlyCp = function()
  local gameObjectId = { type="TppCommandPost2", index=0 }
  local command = { id = "SetFriendlyCp" }
  GameObject.SendCommand( gameObjectId, command )
end

this.SetFriendlyEnemy = function()
  local gameObjectId = { type="TppSoldier2" }
  local command = { id="SetFriendly", enabled=true }
  GameObject.SendCommand( gameObjectId, command )
end

--

local emblemTypes={
  base={"base",{01,50}},
  front1={"front",{01,85}},
  front2={"front",{5001,5027}},
  front3={"front",{7008,7063}},
}

local function RandomSplash()
  local group=emblemTypes[math.random(#emblemTypes)]
  local emblemType=group[1]
  local emblemNumber=tostring(math.random(group[2][1],group[2][2]))
  local lowOrHi="h"
  local name=emblemType..emblemNumber

  local path="/Assets/tpp/ui/texture/Emblem/"..emblemType.."/ui_emb_"..emblemType.."_"..emblemNumber.."_"..lowOrHi.."_alp.ftex"
  local randomSplash=SplashScreen.Create(name,path,640,640)
  SplashScreen.Show(randomSplash,.2,0.5,.2)
  return name
end

--

function this.Init(missionTable)
  this.InitWarpPlayerMode()
end

function this.EndFadeIn()
  if gvars.disableHeadMarkers==1 then
    TppUiStatusManager.SetStatus("HeadMarker","INVALID")
  end
  if gvars.disableXrayMarkers==1 then
    --TppSoldier2.DisableMarkerModelEffect()
    TppSoldier2.SetDisableMarkerModelEffect{enabled=true}
  end  
  --tex player life values for difficulty. Difficult to track down the best place for this, player.changelifemax hangs anywhere but pretty much in game and ready to move, Anything before the ui ending fade in in fact, why.
  --which i don't like, my shitty code should be run in the shadows, not while player is getting viewable frames lol, this is at least just before that
  --RETRY: push back up again, you may just have fucked something up lol
  
  local healthScale=gvars.playerHealthScale
  if healthScale~=1 then
    Player.ResetLifeMaxValue()
    local newMax=vars.playerLifeMax
    newMax=newMax*healthScale
    if newMax < 10 then
      newMax = 10
    end
    Player.ChangeLifeMaxValue(newMax)
  end
end
function this.FinishOpeningDemoOnHeli()
  if gvars.disableHeadMarkers==1 then
    TppUiStatusManager.SetStatus("HeadMarker","INVALID")
  end
  if gvars.disableXrayMarkers==1 then
    --TppSoldier2.DisableMarkerModelEffect()
    TppSoldier2.SetDisableMarkerModelEffect{enabled=true}
  end
end
function this.OnAllocateFob()
  InfMenu.ResetSettings()--tex TODO: would like a nosave reset, but would need to change to reading ivar.setting instead of gvars, then would need to VERFY that .setting is restored on gvar restore
  TppSoldier2.ReloadSoldier2ParameterTables(InfSoldierParams.soldierParameters)
end


this.prevDisableActionFlag=nil
function this.DisableActionFlagEquipMenu()
  if this.prevDisableActionFlag==nil then
    this.prevDisableActionFlag=vars.playerDisableActionFlag
    vars.playerDisableActionFlag=vars.playerDisableActionFlag+PlayerDisableAction.OPEN_EQUIP_MENU
  end
end
function this.RestoreActionFlag()
  if this.prevDisableActionFlag~=nil then
    vars.playerDisableActionFlag=this.prevDisableActionFlag
    this.prevDisableActionFlag=nil
  end
end


local inGame=false--tex actually loaded game, ie at least 'continued' from title screen
local inHeliSpace=false
local inMission=false
local inMissionOnGround=false--mission actually started/reached ground, triggers on checkpoint save so might not be valid for some uses
local inGroundVehicle=false
local inSupportHeli=false
local onBuddy=false--tex sexy
local inMenu=false

local playerVehicleId=0
this.currentTime=0

function this.Update()
  -- InfMenu.DebugPrint("InfMain.Update")
  -- SplashScreen.Show(SplashScreen.Create("debugSplash","/Assets/tpp/ui/texture/Emblem/front/ui_emb_front_5020_l_alp.ftex",1280,640),0,0.3,0)--tex dog--tex ghetto as 'does it run?' indicator
  if TppMission.IsFOBMission(vars.missionCode) then
    return
  end
    
  playerVehicleId=NULL_ID 
  inGame=false
  inHeliSpace=false
  inMission=false
  inMissionOnGround=false
  inGroundVehicle=false
  inSupportHeli=false
  onBuddy=false
  
  inGame=not mvars.mis_missionStateIsNotInGame


  if inGame then
    inHeliSpace=TppMission.IsHelicopterSpace(vars.missionCode)
    inMission=inGame and not inHeliSpace
    --SplashScreen.Show(this.debugSplash,0,0.3,0)--tex
    playerVehicleId=vars.playerVehicleGameObjectId

    if not inHeliSpace then
      inMissionOnGround=svars.ply_isUsedPlayerInitialAction--VERIFY that start on ground catches this (it's triggered on checkpoint save DOESNT catch motherbase ground start
    --[[   if not inMissionOnGround then
        InfMenu.DebugPrint"not inMissionOnGround"--DEBUGNOW
      end --]]

      inSupportHeli=Tpp.IsHelicopter(playerVehicleId)--tex VERIFY
      inGroundVehicle=Tpp.IsVehicle(playerVehicleId) and not inSupportHeli-- or Tpp.IsEnemyWalkerGear(playerVehicleId)?? VERIFY
      onBuddy=Tpp.IsHorse(playerVehicleId) or Tpp.IsPlayerWalkerGear(playerVehicleId)
    end
  end
  
  this.currentTime=Time.GetRawElapsedTimeSinceStartUp()
  
  InfButton.UpdateHeld()
  InfButton.UpdateRepeatReset()
  ---Update shiz
  InfMenu.Update({inGame=inGame,inHeliSpace=inHeliSpace,inGroundVehicle=inGroundVehicle})
  inMenu=InfMenu.menuOn
  
  local execCheck ={inGame=inGame,inHeliSpace=inHeliSpace,inMenu=inMenu}
  this.UpdatePhaseMod(execCheck)
  this.UpdateWarpPlayerMode(execCheck)
  ---
  InfButton.UpdatePressed()--tex GOTCHA: should be after all key reads, sets current keys to prev keys for onbutton checks
end

--Phase/Alert updates
this.nextPhaseUpdate=0
this.lastPhase=0
this.alertBump=false
local PHASE_ALERT=TppGameObject.PHASE_ALERT

local function PhaseName(index)
  return Ivars.phaseSettings[index+1]
end

function this.UpdatePhaseMod(execCheck)
  --Phase/Alert updates DOC: Phases-Alerts.txt
  --TODO RETRY, see if you can get when player comes into cp range better, playerPhase doesnt change till then
  --RESEARCH music also starts up
  --then can shift to game msg="ChangePhase" subscription
  if not execCheck.inGame or execCheck.inHeliSpace or execCheck.inMenu then
    return
  end

  if TppLocation.IsMotherBase() or TppLocation.IsMBQF() then
    return
  end

  local currentPhase=vars.playerPhase
  local minPhase=gvars.minPhase
  local maxPhase=gvars.maxPhase


  if currentPhase~=this.lastPhase then
    if gvars.printPhaseChanges==1 then
      InfMenu.Print(InfMenu.LangString("phase_changed"..":"..PhaseName(currentPhase)))
    end
  end

  if gvars.enablePhaseMod==1 and this.nextPhaseUpdate < this.currentTime then
    --InfMenu.DebugPrint("InfMain.Update phase mod")
    --local minPhase=gvars.minPhase
    --local maxPhase=gvars.maxPhase

    --local debugMessage=nil--DEBUG
    for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
      if currentPhase<minPhase then
        --debugMessage="phase<min setting to "..PhaseName(gvars.minPhase)
        this.ChangePhase(cpName,minPhase)--gvars.minPhase)
      end
      if currentPhase>maxPhase then
        --debugMessage="phase>max setting to "..PhaseName(gvars.maxPhase)
        InfMain.ChangePhase(cpName,maxPhase)
      end

      if gvars.keepPhase==1 then
        InfMain.SetKeepAlert(cpName,true)
      else
      --InfMain.SetKeepAlert(cpName,false)--tex this would trash any vanilla setting, but updating this to off would only be important if ivar was updated at mission time
      end

      --tex keep forcing ALERT so that last know pos updates, otherwise it would take till the alert>evasion cooldown
      --doesnt really work well, > alert is set last know pos, take cover and suppress last know pos
      --evasion is - is no last pos, downgrade to caution, else group advance on last know pos
      --ideally would be able to set last know pos independant of phase
      --[[if minPhase==PHASE_ALERT then
        --debugMessage="phase<min setting to "..PhaseName(gvars.minPhase)
        if currentPhase==PHASE_ALERT and this.lastPhase==PHASE_ALERT then
          this.ChangePhase(cpName,minPhase-1)--gvars.minPhase)
        end
      end--]]
      if minPhase==TppGameObject.PHASE_EVASION then
        if this.alertBump then
          this.alertBump=false
          InfMain.ChangePhase(cpName,TppGameObject.PHASE_EVASION)
        end
      end
      if currentPhase<minPhase then
        if minPhase==TppGameObject.PHASE_EVASION then
          InfMain.ChangePhase(cpName,PHASE_ALERT)
          this.alertBump=true
        end
      end

    end

    --[[ if debugMessage then--DEBUG--tex not a good idea to keep on cause playerphase only updates in certain radius of a cp
    InfMenu.DebugPrint(debugMessage)
    end--]]
  end
  if gvars.enablePhaseMod==1 and this.nextPhaseUpdate < this.currentTime then
    local phaseUpdateRate=gvars.phaseUpdateRate

    if phaseUpdateRate == 0 then
      this.nextPhaseUpdate = this.currentTime--GOTCHA: wont reflect changes to rate and range till next update
    else
      local phaseUpdateRange=gvars.phaseUpdateRange
      local phaseUpdateRangeHalf=phaseUpdateRange*0.5
      local phaseUpdateMin=phaseUpdateRate-phaseUpdateRangeHalf
      local phaseUpdateMax=phaseUpdateRate+phaseUpdateRangeHalf
      if phaseUpdateMin<0 then
        phaseUpdateMin=0
      end

      local randomRange=math.random(phaseUpdateMin,phaseUpdateMax)
      this.nextPhaseUpdate = this.currentTime + randomRange--GOTCHA: wont reflect changes to rate and range till next update
    end
  end
  this.lastPhase=currentPhase
end


this.moveRightButton=InfButton.RIGHT
this.moveLeftButton=InfButton.LEFT
this.moveForwardButton=InfButton.UP
this.moveBackButton=InfButton.DOWN
this.moveUpButton=InfButton.STANCE
this.moveDownButton=InfButton.CALL

this.warpModeButtons={
  this.moveRightButton,
  this.moveLeftButton,
  this.moveForwardButton,
  this.moveBackButton,
  this.moveUpButton,
  this.moveDownButton,
}

function this.InitWarpPlayerMode()
  InfButton.buttonStates[this.moveRightButton].decrement=0.1
  InfButton.buttonStates[this.moveLeftButton].decrement=0.1
  InfButton.buttonStates[this.moveForwardButton].decrement=0.1
  InfButton.buttonStates[this.moveBackButton].decrement=0.1
  InfButton.buttonStates[this.moveUpButton].decrement=0.1
  InfButton.buttonStates[this.moveDownButton].decrement=0.1
end

function this.UpdateWarpPlayerMode(execCheck)
  if execCheck.inMenu then
    return
  end
  
  if not execCheck.inGame or execCheck.inHeliSpace then
    if Ivars.warpPlayerMode.setting==1 then
      Ivars.warpPlayerMode:Set(0)
    end
    return
  end

  if Ivars.warpPlayerMode.setting==0 then
    return
  end
  
  --TODO: refactor, in InfMenu.Update too
  local repeatRate=0.06
  local repeatRateUp=0.04
  InfButton.buttonStates[this.moveRightButton].repeatRate=repeatRate
  InfButton.buttonStates[this.moveLeftButton].repeatRate=repeatRate
  InfButton.buttonStates[this.moveForwardButton].repeatRate=repeatRate
  InfButton.buttonStates[this.moveBackButton].repeatRate=repeatRate
  InfButton.buttonStates[this.moveUpButton].repeatRate=repeatRateUp
  InfButton.buttonStates[this.moveDownButton].repeatRate=repeatRate

  local warpAmount=1
  local warpUpAmount=1

  local moveDir={}
  moveDir[1]=0
  moveDir[2]=0
  moveDir[3]=0

  local didMove=false

  if InfButton.OnButtonDown(this.moveForwardButton)
    or InfButton.OnButtonRepeat(this.moveForwardButton) then
    moveDir[3]=warpAmount
    didMove=true
  end

  if InfButton.OnButtonDown(this.moveBackButton)
    or InfButton.OnButtonRepeat(this.moveBackButton) then
    moveDir[3]=-warpAmount
    didMove=true
  end

  if InfButton.OnButtonDown(this.moveRightButton)
    or InfButton.OnButtonRepeat(this.moveRightButton) then
    moveDir[1]=-warpAmount
    didMove=true
  end

  if InfButton.OnButtonDown(this.moveLeftButton)
    or InfButton.OnButtonRepeat(this.moveLeftButton) then
    moveDir[1]=warpAmount
    didMove=true
  end

  if InfButton.OnButtonDown(this.moveUpButton)
    or InfButton.OnButtonRepeat(this.moveUpButton) then
    moveDir[2]=warpUpAmount
    didMove=true
  end

  if InfButton.OnButtonDown(this.moveDownButton)
    or InfButton.OnButtonRepeat(this.moveDownButton) then
    moveDir[2]=-warpAmount
    didMove=true
  end

  if didMove then
    local currentPos = Vector3(vars.playerPosX, vars.playerPosY, vars.playerPosZ)
    local vMoveDir=Vector3(moveDir[1],moveDir[2],moveDir[3])
    local rotYQuat=Quat.RotationY(TppMath.DegreeToRadian(vars.playerRotY))
    local playerMoveDir=rotYQuat:Rotate(vMoveDir)
    local warpPos=currentPos+playerMoveDir
    TppPlayer.Warp{pos={warpPos:GetX(),warpPos:GetY(),warpPos:GetZ()},rotY=vars.playerCameraRotation[1]}
  end
end


return this

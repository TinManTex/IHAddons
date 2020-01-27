-- DOBUILD: 1
--InfMain.lua
InfCore.LogFlow"Load InfMain.lua"
local this={}

--LOCALOPT:
local InfMain=this
local InfCore=InfCore
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
local StrCode32=InfCore.StrCode32

this.modulesOK=false
this.appliedProfiles=false

--STATE
--tex gvars.isContinueFromTitle is cleared in OnAllocate while it could have still been useful,
--this is valid from OnAllocateTop to OnInitializeBottom, till not helispace
this.isContinueFromTitle=false

this.soldierPool={}
this.emptyCpPool={}

this.lrrpDefines={}--tex from AddLrrps

this.reserveSoldierNames={}

--TUNE
this.smokedTimeOut=60--seconds

this.packages={
  [30010]={
    "/Assets/tpp/pack/mission2/ih/ih_soldier_loc_free.fpk"--DEPENDANCY mission fox2 Soldier2GameObject totalCount
  },
  [30020]={
    "/Assets/tpp/pack/mission2/ih/ih_soldier_loc_free.fpk"--DEPENDANCY mission fox2 Soldier2GameObject totalCount
  },
}

function this.OnLoadEvars()
  --InfQuest.DEBUG_PrintQuestClearedFlags()--DEBUG
  local enable=Ivars.debugMode:Is(1)
  this.DebugModeEnable(enable)
end

--CALLER: TppVarInit.StartTitle, game save actually first loaded
--not super accurate execution timing wise
function this.OnStartTitle()
  InfCore.LogFlow"InfMain.OnStartTitle"
  InfCore.gameSaveFirstLoad=true

  InfQuest.SetupInstalledQuestsState()
end

--tex from InfHooks hook on TppSave.DoSave
function this.OnSave()
  IvarProc.OnSave()
end

--Tpp module hooks/calls>

--tex from TppMission.Load
function this.OnLoad(nextMissionCode,currentMissionCode)
  if TppMission.IsFOBMission(nextMissionCode)then
    return
  end

  for i,module in ipairs(InfModules) do
    if IsFunc(module.OnLoad) then
      InfCore.PCallDebug(module.OnLoad,nextMissionCode,currentMissionCode)
    end
  end
end

--CALLER: TppEneFova.PreMissionLoad
function this.PreMissionLoad(missionId,currentMissionId)
  InfCore.LogFlow"InfMain.PreMissionLoad"

  for i,module in ipairs(InfModules) do
    if IsFunc(module.PreMissionLoad) then
      InfCore.PCallDebug(module.PreMissionLoad,missionId,currentMissionId)
    end
  end
end

function this.OnAllocateTop(missionTable)
  if gvars.isContinueFromTitle then
    this.isContinueFromTitle=true
  end
end
function this.OnAllocate(missionTable)
  if TppMission.IsFOBMission(vars.missionCode)then
    TppSoldier2.ReloadSoldier2ParameterTables(InfSoldierParams.soldierParametersDefaults)
    InfResources.DefaultResourceTables()
    return
  end

  if gvars then
    InfCore.Log("inf_levelSeed "..tostring(gvars.inf_levelSeed))--DEBUG
  end

  InfSoldierParams.SoldierParametersMod()

  for i,module in ipairs(InfModules) do
    if IsFunc(module.OnAllocate) then
      InfCore.PCallDebug(module.OnAllocate,missionTable)
    end
  end
end
--tex in OnAllocate, just after sequence.MissionPrepare
function this.MissionPrepare()
  if TppMission.IsStoryMission(vars.missionCode) then
    if Ivars.gameOverOnDiscovery:Is(1) then
      TppMission.RegistDiscoveryGameOver()
    end
  end
end

--tex called at very start of TppMain.OnInitialize, use mostly for hijacking missionTable scripts
function this.OnInitializeTop(missionTable)
  InfCore.PCallDebug(function(missionTable)--DEBUG
    if TppMission.IsFOBMission(vars.missionCode)then
      return
  end

  this.RandomizeCpSubTypeTable()

  --tex modify missionTable before it's acted on
  if missionTable.enemy then
    local enemyTable=missionTable.enemy
    if IsTable(enemyTable.soldierDefine) then
      if not this.IsContinue() then
        local numReserveSoldiers=this.reserveSoldierCounts[vars.missionCode] or 0
        this.reserveSoldierNames=InfLookup.GenerateNameList("sol_ih_%04d",numReserveSoldiers)
        this.soldierPool=InfUtil.ResetObjectPool("TppSoldier2",this.reserveSoldierNames)
        this.emptyCpPool=InfMain.BuildEmptyCpPool(enemyTable.soldierDefine)

        this.lrrpDefines={}

        InfWalkerGear.walkerPool=InfUtil.ResetObjectPool("TppCommonWalkerGear2",InfWalkerGear.walkerNames)
        InfWalkerGear.mvar_walkerInfo={}
      end
      InfCore.PCallDebug(InfNPC.ModMissionTableTop,missionTable,this.emptyCpPool)--DEBUG

      InfCore.PCallDebug(InfVehicle.ModifyVehiclePatrol,enemyTable.VEHICLE_SPAWN_LIST,enemyTable.soldierDefine,enemyTable.travelPlans,this.emptyCpPool)

      enemyTable.soldierTypes=enemyTable.soldierTypes or {}
      enemyTable.soldierSubTypes=enemyTable.soldierSubTypes or {}
      enemyTable.soldierPowerSettings=enemyTable.soldierPowerSettings or {}
      enemyTable.soldierPersonalAbilitySettings=enemyTable.soldierPersonalAbilitySettings or {}

      InfCore.PCallDebug(InfNPC.AddLrrps,enemyTable.soldierDefine,enemyTable.travelPlans,this.lrrpDefines,this.emptyCpPool)
      InfCore.PCallDebug(InfWalkerGear.AddLrrpWalkers,this.lrrpDefines,InfWalkerGear.walkerPool)
      InfCore.PCallDebug(InfNPC.ModifyLrrpSoldiers,enemyTable.soldierDefine,this.soldierPool)

      InfCore.PCallDebug(InfNPC.AddWildCards,enemyTable.soldierDefine,enemyTable.soldierSubTypes,enemyTable.soldierPowerSettings,enemyTable.soldierPersonalAbilitySettings)

      InfCore.PCallDebug(InfNPC.ModMissionTableBottom,missionTable,this.emptyCpPool)--DEBUG

      --tex DEBUG unassign soldiers from vehicle lrrp so you dont have to chase driving vehicles
      local ejectVehiclesSoldiers=false
      if ejectVehiclesSoldiers then
        for cpName,cpDefine in pairs(enemyTable.soldierDefine)do
          cpDefine.lrrpVehicle=nil
        end
      end
    end
  end
  end,missionTable)--DEBUG
end

--tex called about halfway through TppMain.OnInitialize (on all require libs)
function this.Init(missionTable)
  InfCore.PCallDebug(function(missionTable)--DEBUG
    this.abortToAcc=false

    if TppMission.IsFOBMission(vars.missionCode) then
      return
    end

    this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

    InfMain.ModifyMinesAndDecoys()

    if (vars.missionCode==30050 --[[WIP or vars.missionCode==30250--]]) and Ivars.mbEnableFultonAddStaff:Is(1) then
      mvars.trm_isAlwaysDirectAddStaff=false
    end

    --tex TODO: pull this out of surrounding PCall if it intereferes with module pcall info
    local currentChecks=this.UpdateExecChecks(this.execChecks)
    for i,module in ipairs(InfModules)do
      if module.Init then
        InfCore.PCallDebug(module.Init,missionTable,currentChecks)
      end
    end

    --tex initializing TppDbgStr32s strcode32 to string tables (cribbed from TppDebug.DEBUG_OnReload)
    --TODO: split out more static ones to DebugModeEnable (InfLookup,TppDbgStr32), would require DEBUG_RegisterStrcode32invert to append to strCode32ToString instead of overwrite
    if Ivars.debugMode:Is(1) then
      local strCode32List={}

      local InfStrCode=InfCore.LoadExternalModule("InfStrCode",true,true)--tex module wont assign to global issue again
      if InfStrCode then
        Tpp.ApendArray(strCode32List,InfStrCode.DEBUG_strCode32List)
      end

      Tpp.ApendArray(strCode32List,TppDbgStr32.DEBUG_strCode32List)
      for name,module in pairs(missionTable)do
        if module.DEBUG_strCode32List then
          Tpp.ApendArray(strCode32List,module.DEBUG_strCode32List)
        end
      end
      TppDbgStr32.DEBUG_RegisterStrcode32invert(strCode32List)
    end
  end,missionTable)--
end

--tex just after mission script_enemy.SetUpEnemy
function this.SetUpEnemy(missionTable)
  InfCore.LogFlow("InfMain.SetUpEnemy "..vars.missionCode)
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end
  for i,module in ipairs(InfModules) do
    if IsFunc(module.SetUpEnemy) then
      InfCore.PCallDebug(module.SetUpEnemy,missionTable)
    end
  end
end

function this.OnInitializeBottom(missionTable)
  ---InfCore.PCall(function(missionTable)--DEBUG
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
            InfCore.DebugPrint"enableInfInterrogation interrogationTable cpId==NULL_ID"--DEBUG
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

  if vars.missionCode>TppDefine.SYS_MISSION_ID.TITLE and not TppMission.IsHelicopterSpace(vars.missionCode) then
    this.isContinueFromTitle=false
  end
  --end,missionTable)--DEBUG
end

--IN/OUT packPath
function this.AddMissionPacks(missionCode,packPaths)
  InfCore.LogFlow("InfMain.AddMissionPacks "..missionCode)
  if TppMission.IsFOBMission(missionCode)then
    return
  end

  local packages=this.packages[missionCode]
  if packages then
    for i,packPath in ipairs(packages) do
      packPaths[#packPaths+1]=packPath
    end
  end

  for i,module in ipairs(InfModules) do
    if IsFunc(module.AddMissionPacks) then
      InfCore.PCallDebug(module.AddMissionPacks,missionCode,packPaths)
    end
  end

  InfCore.PrintInspect(packPaths)--DEBUG
end

--tex called via TppSequence Seq_Mission_Prepare.OnUpdate > TppMain.OnMissionCanStart
function this.OnMissionCanStartBottom()
  --InfCore.PCall(function()--DEBUG
  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  local currentChecks=this.UpdateExecChecks(this.execChecks)
  for i,module in ipairs(InfModules) do
    if IsFunc(module.OnMissionCanStart) then
      InfCore.PCallDebug(module.OnMissionCanStart,currentChecks)
    end
  end

  --tex WORKAROUND invasion mode extract from mb weirdness, just disable for now
  --  if Ivars.mbWarGamesProfile:Is"INVASION" and vars.missionCode==30050 then
  --    Player.SetItemLevel(TppEquip.EQP_IT_Fulton_WormHole,0)
  --  end

  local locationName=InfUtil.GetLocationName()
  if Ivars.disableLzs:Is"ASSAULT" then
    InfLZ.DisableLzs(TppLandingZone.assaultLzs[locationName])
  elseif Ivars.disableLzs:Is"REGULAR" then
    InfLZ.DisableLzs(TppLandingZone.missionLzs[locationName])
  end

  if Ivars.repopulateRadioTapes:Is(1) then
    Gimmick.ForceResetOfRadioCassetteWithCassette()
  end

  --end)--DEBUG
end

--tex called from TppMain.OnReload (TODO: caller of that?) on all require libs
function this.OnReload(missionTable)
  if TppMission.IsFOBMission(vars.missionCode) then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

  for i,module in ipairs(InfModules)do
    if module.OnReload then
      InfCore.PCallDebug(module.OnReload,missionTable)
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
      InfCore.PCallDebug(module.OnMissionGameEnd)
    end
  end
end
--tex called from TppMission.AbortMission (TODO: caller of that?)
function this.AbortMissionTop(abortInfo)
  if TppMission.IsFOBMission(abortInfo.nextMissionId)then
    return
  end

  --InfCore.DebugPrint("AbortMissionTop "..vars.missionCode)--DEBUG
  InfMain.RegenSeed(vars.missionCode,abortInfo.nextMissionId)

  InfGameEvent.DisableEvent()
end

--CALLERS TppMission.MissionFinalize/OnEndMissionReward < called from in sequence when decided mission is ended
function this.ExecuteMissionFinalizeTop()
  if TppMission.IsFOBMission(gvars.mis_nextMissionCodeForMissionClear)then
    return
  end

  this.RegenSeed(vars.missionCode,gvars.mis_nextMissionCodeForMissionClear)
  InfGameEvent.DisableEvent()
  InfCore.PCall(InfGameEvent.GenerateEvent,gvars.mis_nextMissionCodeForMissionClear)
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
--GOTCHA only currently on freemission in a specfic spot in TppMission.MissionFinalize
function this.ExecuteMissionFinalizeFree(missionFinalize)
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

function this.Messages()
  return Tpp.StrCode32Table{
    GameObject={
      {msg="Damage",func=this.OnDamage},
      --{msg="Dead",func=this.OnDead},
      {msg="ChangePhase",func=this.OnPhaseChange},
    --WIP OFF, lua off
    --      {msg="RequestLoadReinforce",func=InfReinforce.OnRequestLoadReinforce},
    --      {msg="RequestAppearReinforce",func=InfReinforce.OnRequestAppearReinforce},
    --      {msg="CancelReinforce",func=InfReinforce.OnCancelReinforce},
    --      {msg="LostControl",func=InfReinforce.OnHeliLostControlReinforce},--DOC: Helicopter shiz.txt
    --      {msg="VehicleBroken",func=InfReinforce.OnVehicleBrokenReinforce},
    --      {msg="Returned", --[[sender = "EnemyHeli",--]]
    --        func = function(gameObjectId)
    --        --InfCore.DebugPrint("GameObject msg: Returned")--DEBUG
    --        end
    --      },
    --      {msg="RequestedHeliTaxi",func=function(gameObjectId,currentLandingZoneName,nextLandingZoneName)
    --        --InfCore.DebugPrint("RequestedHeliTaxi currentLZ:"..currentLandingZoneName.. " nextLZ:"..nextLandingZoneName)--DEBUG
    --        end},
    --      {msg="StartedPullingOut",func=function()
    --        --InfCore.DebugPrint("StartedPullingOut")--DEBUG
    --      end},
    --      {
    --        msg = "RoutePoint2",--DEBUG
    --        func = function( gameObjectId, routeId, routeNodeIndex, messageId )
    --          InfCore.PCall(function()
    --            InfCore.DebugPrint("gameObjectId:"..tostring(gameObjectId).." routeId:".. tostring(routeId).." routeNodeIndex:".. tostring(routeNodeIndex).." messageId:".. tostring(messageId))--DEBUG
    --          end)
    --        end
    --      },
    },
    --MotherBaseStage = {
    --      {
    --        msg="MotherBaseCurrentClusterLoadStart",
    --        func=function(clusterId)
    --          InfCore.DebugPrint"InfMain MotherBaseCurrentClusterLoadStart"--DEBUG
    --        end,
    --      },
    --OFF CULL unused{msg= "MotherBaseCurrentClusterActivated",func=this.CheckClusterMorale},
    --},
    Player={
      {msg="FinishOpeningDemoOnHeli",func=this.ClearMarkers},--tex xray effect off doesn't stick if done on an endfadein, and cant seen any ofther diable between the points suggesting there's an in-engine set between those points of execution(unless I'm missing something) VERIFY
    --      {
    --        msg="OnPickUpWeapon",
    --        func=function(playerGameObjectId,equipId,number)
    --          InfCore.DebugPrint("OnPickUpWeapon equipId:"..equipId.." number:"..number)--DEBUG
    --        end
    --      },
    --      {msg="RideHelicopter",func=function()
    --        InfCore.DebugPrint"RideHelicopter"
    --      end},
    },
    UI={
      --      {msg="EndFadeIn",func=this.FadeIn()},--tex for all fadeins
      {msg="EndFadeIn",sender="FadeInOnGameStart",func=function()--fires on: most mission starts, on-foot free and story missions, not mb on-foot, but does mb heli start
        --InfCore.Log("FadeInOnGameStart",true)--DEBUG
        this.FadeInOnGameStart()
      end},
      --this.FadeInOnGameStart},
      {msg="EndFadeIn",sender="FadeInOnStartMissionGame",func=function()--fires on: returning to heli from mission
        --  TppUiStatusManager.ClearStatus"AnnounceLog"
        --InfMenu.ModWelcome()
        --InfCore.DebugPrint"FadeInOnStartMissionGame"--DEBUG
        --this.FadeInOnGameStart()
        end},
      {msg="EndFadeIn",sender="OnEndGameStartFadeIn",func=function()--fires on: on-foot mother base, both initial and continue
        --InfCore.DebugPrint"OnEndGameStartFadeIn"--DEBUG
        this.FadeInOnGameStart()
      end},
      --tex Heli mission-prep ui
      {msg="MissionPrep_EndSlotSelect",func=function()
        --InfCore.DebugPrint"MissionPrep_EndSlotSelect"--DEBUG
        InfFova.CheckModelChange()
      end},
    --      {msg="MissionPrep_ExitWeaponChangeMenu",func=function()
    --        InfCore.DebugPrint"MissionPrep_ExitWeaponChangeMenu"--DEBUG
    --      end},
    --      {msg="MissionPrep_EndItemSelect",func=function()
    --        InfCore.DebugPrint"MissionPrep_EndItemSelect"--DEBUG
    --      end},
    --      {msg="MissionPrep_EndEdit",func=function()
    --        InfCore.DebugPrint"MissionPrep_EndEdit"--DEBUG
    --      end},
    --elseif(messageId=="Dead"or messageId=="VehicleBroken")or messageId=="LostControl"then
    },
    Timer={
      {msg="Finish",sender="Timer_WaitStartingGame",func=this.OnGameStart},
    --WIP OFF lua off {msg="Finish",sender="Timer_FinishReinforce",func=InfReinforce.OnTimer_FinishReinforce,nil},
    },
    --    Terminal={
    --      {msg="MbDvcActSelectLandPoint",func=function(nextMissionId,routeName,layoutCode,clusterId)
    --        --InfCore.DebugPrint("MbDvcActSelectLandPoint:"..tostring(InfLZ.str32LzToLz[routeName]).. " "..tostring(clusterId))--DEBUG
    --      end},
    --      {msg="MbDvcActSelectLandPointTaxi",func=function(nextMissionId,routeName,layoutCode,clusterId)
    --        --InfCore.DebugPrint("MbDvcActSelectLandPointTaxi:"..tostring(routeName).. " "..tostring(clusterId))--DEBUG
    --      end},
    --      {msg="MbDvcActHeliLandStartPos",func=function(set,x,y,z)
    --        --InfCore.DebugPrint("HeliLandStartPos:"..x..","..y..","..z)--DEBUG
    --        end},
    --      {msg="MbDvcActCallRescueHeli",func=function(param1,param2)
    --        --InfCore.DebugPrint("MbDvcActCallRescueHeli: "..tostring(param1).." ".. tostring(param2))--DEBUG
    --        end},
    --    },
    Block={
      {msg="StageBlockCurrentSmallBlockIndexUpdated",func=function(blockIndexX,blockIndexY,clusterIndex)
        if Ivars.printOnBlockChange:Is(1) then
          InfCore.DebugPrint("OnSmallBlockIndex - x:"..blockIndexX..", y:"..blockIndexY.." clusterIndex:"..tostring(clusterIndex))
        end
      end},
      {msg="OnChangeLargeBlockState",func=function(blockNameStr32,blockStatus)
        if Ivars.printOnBlockChange:Is(1) then
          InfCore.DebugPrint("OnChangeLargeBlockState - blockNameStr32:"..blockNameStr32.." blockStatus:"..blockStatus)
        end
      end},
    --      {msg="OnChangeSmallBlockState",func=function(blockNameStr32,blockStatus)
    --
    --        end},
    },
  }
end
function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
  Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end

--TODO: VERIFY, add vehicle machineguns
local vehicleAttacks={
  [TppDamage.ATK_VehicleHit]=true,
  [TppDamage.ATK_Tankgun_20mmAutoCannon]=true,
  [TppDamage.ATK_Tankgun_30mmAutoCannon]=true,
  [TppDamage.ATK_Tankgun_105mmRifledBoreGun]=true,
  [TppDamage.ATK_Tankgun_120mmSmoothBoreGun]=true,
  [TppDamage.ATK_Tankgun_125mmSmoothBoreGun]=true,
  [TppDamage.ATK_Tankgun_82mmRocketPoweredProjectile]=true,
  [TppDamage.ATK_Tankgun_30mmAutoCannon]=true,
  [TppDamage.ATK_Wav1]=true,
  [TppDamage.ATK_WavCannon]=true,
  [TppDamage.ATK_TankCannon]=true,
  [TppDamage.ATK_WavRocket]=true,
  [TppDamage.ATK_HeliMiniGun]=true,
  [TppDamage.ATK_HeliChainGun]=true,
}
function this.OnDamage(gameId,attackId,attackerId)
  local typeIndex=GetTypeIndex(gameId)
  if typeIndex~=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2 then--and typeIndex~=TppGameObject.GAME_OBJECT_TYPE_HELI2 then
    return
  end

  if Tpp.IsPlayer(attackerId) then
    --InfCore.DebugPrint"OnDamage attacked by player"
    local soldierAlertOnHeavyVehicleDamage=Ivars.soldierAlertOnHeavyVehicleDamage:Get()
    if soldierAlertOnHeavyVehicleDamage>0 then
      if vehicleAttacks[attackId] then
        --InfCore.DebugPrint"OnDamage AttackIsVehicle"
        for cpId,soldierIds in pairs(mvars.ene_soldierIDList)do--tex TODO:find or build a better soldierid>cpid lookup
          if soldierIds[gameId]~=nil then
            if TppEnemy.GetPhaseByCPID(cpId)<soldierAlertOnHeavyVehicleDamage then
              --InfCore.DebugPrint"OnDamage found soldier in idlist"
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
--    InfCore.DebugPrint"cpAlertOnVehicleFulton>0"--DEBUG
--    local riderIdArray=SendCommand(vehicleId,{id="GetRiderId"})
--    for seatIndex,riderId in ipairs(riderIdArray) do
--      if seatIndex==1 then
--        if riderId~=NULL_ID then
--          InfCore.DebugPrint"vehicle has driver"--DEBUG
--          for cpId,soldierIds in pairs(mvars.ene_soldierIDList)do
--            if soldierIds[riderId]~=nil then
--              InfCore.DebugPrint"found rider cp"--DEBUG
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

function this.OnGameStart()
  --tex WORKAROUND, vars.mbLayout (also TppMotherBaseManagement.GetMbsClusterGrade) isn't updated on a command cluster plat built till after TppMain.ReservePlayerLoadingPosition
  if vars.missionCode==30050 then
    if gvars.ply_initialPlayerState==TppDefine.INITIAL_PLAYER_STATE.ON_FOOT then
      --InfCore.Log("playerposfailsafe ON_FOOT playerY="..vars.playerPosY)--DEBUG
      if vars.playerPosY<-9 then
        InfCore.Log("PlayerPos Failsafe")
        --tex TODO could store vars.mbLayout during load and compare to see if it's changed?
        if gvars.heli_missionStartRoute then
          local groundStartPosition=InfLZ.GetGroundStartPosition(gvars.heli_missionStartRoute)
          --InfCore.PrintInspect(groundStartPosition)--DEBUG
          TppPlayer.Warp{pos=groundStartPosition.pos,rotY=vars.playerRotY}
        end
      end
    end
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
  InfCore.LogFlow"InfMain.FadeInOnGameStart"
  this.WeaponVarsSanityCheck()

  if TppMission.IsFOBMission(vars.missionCode)then
    return
  end

  this.ClearMarkers()

  this.ChangeMaxLife()

  --TppUiStatusManager.ClearStatus"AnnounceLog"
  --InfMenu.ModWelcome()
end

function this.OnMenuOpen()

end
function this.OnMenuClose()
  local activeControlMode=this.GetActiveControlMode()
  if activeControlMode then
    if IsFunc(activeControlMode.OnActivate) then
      activeControlMode.OnActivate()
    end
  end

  InfCore.PCallDebug(IvarProc.SaveEvars)
end

--Caller heli_common_sequence.Seq_Game_MainGame.OnEnter
function this.OnEnterACC()
  if not this.modulesOK then
    this.ModuleErrorMessage()
  else
    InfMenu.ModWelcome()

    --tex dummy/EQUIP_NONE hangun/assault CULL
    --    local developIds={
    --      900,
    --      901,
    --    }
    --    for i,developId in ipairs(developIds) do
    --      if not TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=developId} then
    --        InfCore.Log("SetEquipDeveloped "..developId)
    --        TppMotherBaseManagement.SetEquipDeveloped{equipDevelopID=developId}
    --      end
    --    end

    --tex only want this on enter ACC because changing vars on a mission is not a good idea
    if not this.appliedProfiles then
      this.appliedProfiles=true
      IvarProc.ApplyInfProfiles(Ivars.profileNames)
    end
  end
end
--tex on holding esc at title
function this.ClearOnAbortToACC()
  Ivars.inf_event:Set(0)
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
      --InfCore.DebugPrint"not initialAction"
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
  InfCore.PCallDebug(function()--DEBUG
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
            this.ExecUpdate(currentChecks,this.currentTime,module.execCheckTable,module.execState,updateRate,module.Update)
          end
        end
      end
    end
    ---
    InfButton.UpdatePressed()--tex GOTCHA: should be after all key reads, sets current keys to prev keys for onbutton checks
  end)--DEBUG
end

function this.ExecUpdate(currentChecks,currentTime,execChecks,execState,updateRate,ExecUpdateFunc)
  --tex modules may set their own update rate
  if execState.nextUpdate>currentTime then
    return
  end

  if execChecks==nil then
    InfCore.DebugPrint"update module has no execChecks var, aborting"
    return
  end
  for check,ivarCheck in pairs(execChecks) do
    if currentChecks[check]~=ivarCheck then
      return
    end
  end

  if not IsFunc(ExecUpdateFunc) then
    InfCore.DebugPrint"ExecUpdateFunc is not a function"
    return
  end

  InfCore.PCallDebug(ExecUpdateFunc,currentChecks,currentTime,execChecks,execState)

  if updateRate>0 then
    execState.nextUpdate=currentTime+updateRate
  end

  --DEBUG
  --if currentChecks.inGame then
  -- InfCore.DebugPrint("currentTime: "..tostring(currentTime).." updateRate:"..tostring(updateRate) .." nextUpdate:"..tostring(execState.nextUpdate))
  --end
end

function this.DoControlSet(currentChecks)
  local abortButton=InfButton.ESCAPE
  InfButton.buttonStates[abortButton].holdTime=1.6

  if InfButton.OnButtonHoldTime(abortButton) then
    if gvars.ini_isTitleMode then
      local splash=SplashScreen.Create("abortsplash","/Assets/tpp/ui/ModelAsset/sys_logo/Pictures/common_kjp_logo_clp_nmp.ftex",640,640)
      SplashScreen.Show(splash,0,0.3,0)
      this.abortToAcc=true
      this.ClearOnAbortToACC()
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
      InfCore.DebugPrint("LoadExternalModules")
      this.LoadExternalModules(true)
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

function this.RegenSeed(currentMission,nextMission)
  --tex hard to find a line to draw in the sand between one mission and the next, so i'm just going for if you've gone to acc then that you're new levelseed set
  -- this does mean that free roam<>mission wont get a change though, but that may be useful in some circumstances
  if TppMission.IsHelicopterSpace(nextMission) and currentMission>5 then
    this.RandomResetToOsTime()
    Ivars.inf_levelSeed:Set(math.random(0,2147483647))
    InfCore.Log("InfMain.RegenSeed new seed "..tostring(gvars.inf_levelSeed))--DEBUG
  end
end

function this.RandomSetToLevelSeed()
  --  InfCore.Log("RandomSetToLevelSeed:"..tostring(gvars.inf_levelSeed))--DEBUG
  --  InfCore.Log("caller:"..InfCore.DEBUG_Where(2))--DEBUG
  math.randomseed(gvars.inf_levelSeed)
  math.random()
  math.random()
  math.random()
end

function this.RandomResetToOsTime()
  --  InfCore.Log"RandomResetToOsTime"--DEBUG
  --  InfCore.Log("caller:"..InfCore.DEBUG_Where(2))--DEBUG
  math.randomseed(os.time())
  math.random()
  math.random()
  math.random()
end

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

  local locationName=InfUtil.locationNames[vars.locationCode]
  local locationSubTypes=cpSubTypes[locationName]
  if locationSubTypes==nil then
    InfCore.DebugPrint("RandomizeCpSubTypeTable: locationSubTypes==nil for location "..tostring(locationName))
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
    mafr_lab_cp={2707.418,174.801,-2428.483},--Lufwa Valley
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
    ["ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|mtbs_command_cp"]={9.430,0.800,-24.179},
    ["ly003_cl01_npc0000|cl01pl0_uq_0010_npc2|mtbs_combat_cp"]={1141.248,8.800,-604.406},
    ["ly003_cl02_npc0000|cl02pl0_uq_0020_npc2|mtbs_develop_cp"]={1189.571,20.798,314.824},
    ["ly003_cl03_npc0000|cl03pl0_uq_0030_npc2|mtbs_support_cp"]={372.656,0.800,860.953},
    ["ly003_cl04_npc0000|cl04pl0_uq_0040_npc2|mtbs_medic_cp"]={-137.282,0.800,-964.455},
    ["ly003_cl05_npc0000|cl05pl0_uq_0050_npc2|mtbs_intel_cp"]={-668.973,4.925,524.886},
    ["ly003_cl06_npc0000|cl06pl0_uq_0060_npc2|mtbs_basedev_cp"]={-744.900,8.800,-360.478},
  }
}

function this.GetClosestCp(position)
  local playerPos={vars.playerPosX,vars.playerPosY,vars.playerPosZ}
  position=position or playerPos

  local locationName=InfUtil.GetLocationName()
  local cpPositions=this.cpPositions[locationName]
  if cpPositions==nil then
    InfCore.DebugPrint("WARNING: GetClosestCp no cpPositions for locationName "..locationName)
    return nil,nil,nil
  end

  local closestCp=nil
  local closestDist=9999999999999999
  local closestPosition=nil
  for cpName,cpPosition in pairs(cpPositions)do
    if cpPosition==nil then
      InfCore.DebugPrint("cpPosition==nil for "..tostring(cpName))
      return
    elseif #cpPosition~=3 then
      InfCore.DebugPrint("#cpPosition~=3 for "..tostring(cpName))
      return
    end

    local distSqr=TppMath.FindDistance(position,cpPosition)
    --InfCore.DebugPrint(cpName.." dist:"..math.sqrt(distSqr))--DEBUG
    if distSqr<closestDist then
      closestDist=distSqr
      closestCp=cpName
      closestPosition=cpPosition
    end
  end
  --InfCore.DebugPrint("Closest cp "..InfMenu.CpNameString(closestCp,locationName)..":"..closestCp.." ="..math.sqrt(closestDist))--DEBUG
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

  local locationName=InfUtil.GetLocationName()

  if not TppLandingZone.assaultLzs[locationName] then
    InfCore.DebugPrint"WARNING: GetClosestLz TppLandingZone.assaultLzs[locationName]==nil"--DEBUG
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
          InfCore.DebugPrint("coords.pos==nil for "..dropLzName)
          return
        elseif #cpPos~=3 then
          InfCore.DebugPrint("#coords.pos~=3 for "..dropLzName)
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

--tex a few demo files force their own snake heads which naturally goes badly if DD female and use current soldier in cutscenes
this.noSkipIsSnakeOnly={--tex>
  Demo_Funeral=true,--PATCHUP: shining lights end cinematic forces snake head with ash
  --volgin recovery quest, demo forces snake head with bandages
  Demo_RecoverVolgin=true,
  p31_080100_000_final=true,
}

function this.SetSubsistenceSettings()
  --tex no go, see OnMissionCanStartBottom for alt solution
  --  if TppMission.IsFOBMission(vars.missionCode) then
  --    if vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]==TppEquip.EQP_None then
  --      --InfCore.Log("TppDefine.WEAPONSLOT.PRIMARY_HIP]==TppEquip.EQP_None")--DEBUG
  --      TppPlayer.SetInitWeapons({{primaryHip="EQP_WP_30001"}},true)
  --    end
  --    if vars.weapons[TppDefine.WEAPONSLOT.SECONDARY]==TppEquip.EQP_None then
  --      --InfCore.Log("TppDefine.WEAPONSLOT.SECONDARY]==TppEquip.EQP_None")--DEBUG
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
      --InfCore.DebugPrint(itemIvar.name..":"..itemIvar.setting)--DEBUG
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

--actionflags
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

--reserve soldierpool
--tex number of soldier locators in fox2s
this.reserveSoldierCounts={
  [30010]=40,
  [30020]=40,
  [30050]=140,
}



--tex in the mission soldierDefine tables there's a bunch of empty _lrrp cps that I'm repurposing
local lrrpInd="_lrrp"
function this.BuildEmptyCpPool(soldierDefine)
  local cpPool={}
  for cpName,cpDefine in pairs(soldierDefine)do
    local cpId=GetGameObjectId("TppCommandPost2",cpName)
    if cpId==NULL_ID then
      InfCore.DebugPrint("BuildEmptyCpPool: soldierDefine "..cpName.."==NULL_ID")--DEBUG
    else
      if #cpDefine==0 then
        --tex cp is labeled _lrrp
        if string.find(cpName,lrrpInd) then
          if not cpDefine.lrrpVehicle and not cpDefine.travelPlan then
            cpPool[#cpPool+1]=cpName
          end
        end
      end
    end
  end
  --  InfCore.Log"cpPool"--DEBUG
  --  InfCore.PrintInspect(cpPool)--DEBUG
  return cpPool
end

function this.BuildBaseCpPool(soldierDefine)
  local cpPool={}
  for cpName,cpDefine in pairs(soldierDefine)do
    local cpId=GetGameObjectId("TppCommandPost2",cpName)
    if cpId==NULL_ID then
      InfCore.DebugPrint("BuildCpPool: soldierDefine "..cpName.."==NULL_ID")--DEBUG
    else
      if #cpDefine>0 then
        if not cpDefine.lrrpVehicle and not cpDefine.travelPlan then
          cpPool[#cpPool+1]=cpName
        end
      end
    end
  end
  --  InfCore.Log"cpPool"--DEBUG
  --  InfCore.PrintInspect(cpPool)--DEBUG
  return cpPool
end

--IN-SIDE: InfVehicle.inf_patrolVehicleConvoyInfo
function this.BuildCpPoolWildCard(soldierDefine)
  local baseNamePool={}
  for cpName,cpDefine in pairs(soldierDefine)do
    if #cpDefine>0 then
      local cpId=GetGameObjectId("TppCommandPost2",cpName)
      if cpId==NULL_ID then
        InfCore.Log("BuildCpPoolWildCard: soldierDefine cpId==NULL",true)--DEBUG
      else
        --tex TODO: allow quest_cp, but regenerate soldier on quest load
        if cpName=="quest_cp" then
        --tex TODO: consider if you want to  have wilcards in lrrps
        elseif cpDefine.lrrpVehicle==nil and cpDefine.lrrpTravelPlan~=nil then
        elseif cpDefine.lrrpVehicle~=nil then
          if #cpDefine>1 then--ASSUMPTION only armored vehicles have 1 occupant
            --WORKAROUND the ordering of convoy setup/filling previously empty cpDefines on checkpoint restart
            local isConvoy=InfVehicle.inf_patrolVehicleConvoyInfo[cpDefine.lrrpTravelPlan]
            if isConvoy==false then
              baseNamePool[#baseNamePool+1]=cpName
            end
          end
        else
          baseNamePool[#baseNamePool+1]=cpName
        end
      end
    end
  end
  return baseNamePool
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

function this.ClearStatus()
  InfCore.PCall(function()
    local splash=SplashScreen.Create("abortsplash","/Assets/tpp/ui/ModelAsset/sys_logo/Pictures/common_kjp_logo_clp_nmp.ftex",640,640)
    SplashScreen.Show(splash,0,0.3,0)

    vars.playerDisableActionFlag=PlayerDisableAction.NONE
    Player.SetPadMask{settingName="AllClear"}
    Tpp.SetGameStatus{target="all",enable=true,scriptName="InfMain.lua"}
    InfCore.DebugPrint"Cleared status"
  end)
end

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

  local mineTypeBag=InfUtil.ShuffleBag:New(mineFieldMineTypes)
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

--ORPHAN
function this.ReadSaveVar(name,category)
  local category=category or TppScriptVars.CATEGORY_GAME_GLOBAL
  local globalSlotForSaving={TppDefine.SAVE_SLOT.SAVING,TppDefine.SAVE_FILE_INFO[category].slot}
  return TppScriptVars.GetVarValueInSlot(globalSlotForSaving,"gvars",name,0)
end

function this.IsContinue()
  return gvars.sav_varRestoreForContinue and not this.isContinueFromTitle
end

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
  --TODO: currently the weapons arent added via RequestLoadToEquipMissionBlock so weapons wont be usable, but since the user would have had decided to go into fob with equip_none instead of changing to a proper loadout whatev
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

function this.DisplayFox32(foxString)
  local str32 = StrCode32(foxString)
  TppUiCommand.AnnounceLogView("string :"..foxString .. "="..str32)
end

function this.DebugModeEnable(enable)
  InfCore.Log("DebugModeEnable:"..tostring(enable),false,true)
  local prevMode=InfCore.debugMode

  if enable then
    if InfHooks then
      InfCore.PCall(InfHooks.SetupDebugHooks)
    end
    --InfCore.Log"InfHooks:"--DEBUG
    --InfCore.PrintInspect(InfHooks)
    if InfMenu then
      InfMenu.AddDevMenus()
    end
  else
    InfCore.Log("Further logging disabled")
  end
  InfCore.debugMode=enable
end

--modules
--SIDE: modules,this.modulesOK
--SIDE: InfCore.files
--SIDE: this.moduleNames
--isReload = user initiated
function this.LoadExternalModules(isReload)
  InfCore.LogFlow"InfMain.LoadExternalModules"

  this.modulesOK=true

  if isReload then
    InfCore.files=InfCore.PCallDebug(InfCore.RefreshFileList)
  end

  --tex clear InfModules
  InfModules.moduleNames={}
  for i,moduleName in ipairs(InfModules)do
    InfModules[i]=nil
  end
 
  for i,moduleName in ipairs(InfModules.coreModules)do
    table.insert(InfModules.moduleNames,moduleName)
  end
  
  --tex get other external modules
  local moduleFiles=InfCore.GetFileList(InfCore.files.modules,".lua",true)
  for i,moduleName in ipairs(moduleFiles)do
    if not InfModules.isCoreModule[moduleName] then
      table.insert(InfModules.moduleNames,moduleName)
    end
  end
  InfCore.PrintInspect(InfModules.moduleNames)--DEBUG

  for i,moduleName in ipairs(InfModules.moduleNames) do
    InfCore.LoadExternalModule(moduleName,isReload)
    local module=_G[moduleName]
    if module then
      --InfCore.Log("Loaded "..moduleName)--DEBUG
      module.name=moduleName
      table.insert(InfModules,module)
    else
      this.modulesOK=false
    end
  end

  InfCore.LogFlow("PostAllModulesLoad")--DEBUG
  InfCore.PCallDebug(this.PostAllModulesLoad)
  --NOTE: On first load only InfMain has been loaded at this point, so can't reference other IH lib modules.
  for i,moduleName in ipairs(InfModules.moduleNames) do
    local module=_G[moduleName]
    if module then
      if IsFunc(module.PostAllModulesLoad) then
        InfCore.PCallDebug(module.PostAllModulesLoad)
      end
    end
  end

  --tex profiles
  local ret=InfCore.PCall(IvarProc.SetupInfProfiles)
  --WORKAROUND PCall
  if ret then
  Ivars.profileNames=ret[1]
  Ivars.profiles=ret[2]
  end
  --DEBUG
  --  InfCore.Log"--------------"
  --  InfCore.PrintInspect(Ivars.profileNames)
  --  InfCore.PrintInspect(Ivars.profiles)
end

function this.ModuleErrorMessage()
  --tex TODO: if InfLang then printlangid else -v-
  InfCore.DebugPrint"Infinite Heaven: Could not load modules from MGS_TPP\\mod\\. See Installation.txt"
  InfCore.Log("Infinite Heaven: Could not load modules from MGS_TPP\\mod\\. See Installation.txt",false,true)
end

function this.PostAllModulesLoad()
  local enable=Ivars.debugMode:Is(1)
  this.DebugModeEnable(enable)
end

--CALLER end of start2nd.lua
function this.LoadLibraries()
  InfCore.LogFlow"InfMain.LoadLibraries"
  this.LoadModelInfoModules()
  if InfQuest then
    InfQuest.LoadQuestDefs()
  end
end

function this.LoadModelInfoModules()
  local plpartsPacks={--tex SYNC: InfFova
    "plparts_avatar_man",
    "plparts_battledress",
    "plparts_ddf_battledress",
    "plparts_ddf_parasite",
    "plparts_ddf_venom",
    "plparts_ddm_battledress",
    "plparts_ddm_parasite",
    "plparts_ddm_venom",
    "plparts_dd_female",
    "plparts_dd_male",
    "plparts_gold",
    "plparts_gz_suit",
    "plparts_hospital",
    "plparts_leather",
    "plparts_mgs1",
    "plparts_naked",
    "plparts_ninja",
    "plparts_normal",
    "plparts_normal_scarf",
    "plparts_parasite",
    "plparts_raiden",
    "plparts_silver",
    "plparts_sneaking_suit",
    "plparts_venom",
    "plparts_ddm_swimwear",
    "plparts_ddf_swimwear",
  }

  local path="/Assets/tpp/pack/player/parts/"
  local suffix="_modelInfo"
  local extension=".lua"
  local sucess, err = pcall(function()
    for n,packName in ipairs(plpartsPacks) do
      Script.LoadLibrary(path..packName..suffix..extension)
    end
  end)
end

--EXEC
_G.InfMain=this--WORKAROUND allowing external modules access to this before it's actually returned --KLUDGE using _G since I'm already definining InfMain as local

if Mock==nil then
  InfCore.LogFlow"InfMain Exec"
  this.LoadExternalModules()
  if not this.modulesOK then
    this.ModuleErrorMessage()
  end
  InfCore.doneStartup=true
end

InfCore.LogFlow"InfMain.lua done"

return this

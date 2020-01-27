-- InfSoldier.lua
-- tex implements soldier additions/modificationa and route changes on MB
-- Ivars: vehiclePatrolProfile, enableLrrpFreeRoam, enableWildCardFreeRoam, mbAdditionalSoldiers, mbNpcRouteChange
local this={}

--LOCALOPT
local InfCore=InfCore
local InfMain=InfMain
local StrCode32=InfCore.StrCode32
local NULL_ID=GameObject.NULL_ID
local GetGameObjectId=GameObject.GetGameObjectId
local GetTypeIndex=GameObject.GetTypeIndex
local SendCommand=GameObject.SendCommand
local Random=math.random

local GetCurrentCluster=MotherBaseStage.GetCurrentCluster
local GetMbStageClusterGrade=TppLocation.GetMbStageClusterGrade

this.debugModule=false

--updateState
this.active=Ivars.mbNpcRouteChange
this.execCheckTable={inGame=true,inHeliSpace=false}
this.execState={
  nextUpdate=0,
}
--tex seconds
local updateMin=30
local updateMax=80

this.enableIvars={
  Ivars.mbNpcRouteChange,
  Ivars.mbAdditionalSoldiers,
}

-- command plat salutation routes
--TODO: add to routeForPlat,platForRoute if currentcluster is 1/command.
--
--        {
--          "ly003_cl00_route0000|cl00pl0_mb_fndt_plnt_free|rt_free_h_0000",
--          "ly003_cl00_route0000|cl00pl0_mb_fndt_plnt_free|rt_free_h_0001",
--          "ly003_cl00_route0000|cl00pl0_mb_fndt_plnt_free|rt_free_h_0002",
--          "ly003_cl00_route0000|cl00pl0_mb_fndt_plnt_free|rt_free_h_0003",
--        },
--
--        {
--          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_h_0000",
--          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_h_0001",
--        },

--STATE
local npcList={}
local npcPlats={}
local npcRoutes={}

local routesForPlat={}
local platForRoute={}

local numSoldiersOnRoute={}
local numSoldiersOnPlat={}

local mbDemoWasPlayed=false

--TUNE
local maxSoldiersOnSameRoute=2
local maxSoldiersPerPlat=12--SYNC with plat counts, and keep in mind max instace count

local plntPrefix="plnt"

--
this.numLrrpSoldiers=2

--
--STATE
this.ene_wildCardNames={}
this.ene_wildCardInfo={}

this.packages={
  mbAdditionalSoldiers="/Assets/tpp/pack/mission2/ih/ih_soldier_loc_mb.fpk"--tex still relies on totalCount in f30050_npc.fox2
}

function this.PostModuleReload(prevModule)
  this.ene_wildCardNames=prevModule.ene_wildCardNames
  this.ene_wildCardInfo=prevModule.ene_wildCardInfo
end

function this.AddMissionPacks(missionCode,packPaths)
  if Ivars.mbAdditionalSoldiers:EnabledForMission() then
    packPaths[#packPaths+1]=this.packages.mbAdditionalSoldiers
  end

  --tex customSoldierType add mission packs>
  if missionCode>5 then
    --InfCore.LogFlow("InfSoldier.AddMissionPacks: AddBodyPackPaths")--DEBUG
    local bodyInfo=InfEneFova.GetMaleBodyInfo(missionCode)
    InfEneFova.AddBodyPackPaths(bodyInfo)
    local bodyInfo=InfEneFova.GetFemaleBodyInfo(missionCode)
    InfEneFova.AddBodyPackPaths(bodyInfo)
  end
  --<

  if Ivars.enableWildCardFreeRoam:EnabledForMission(missionCode) then
    local bodyInfo=InfEneFova.GetFemaleWildCardBodyInfo()
    InfEneFova.AddBodyPackPaths(bodyInfo)
  end
end

function this.PreMissionLoad(missionCode,currentMissionId)
--OFF TEST
--  if Ivars.enableWildCardFreeRoam:EnabledForMission(missionCode) then
--    local faces={}
--    InfCore.PCallDebug(InfEneFova.WildCardFovaFaces,faces)
--    TppSoldierFace.OverwriteMissionFovaData{face=faces,additionalMode=true}
--    local bodies={}
--    InfCore.PCallDebug(InfEneFova.WildCardFovaBodies,bodies)
--    TppSoldierFace.OverwriteMissionFovaData{body=bodies,additionalMode=true}
--  end
end

function this.Init(missionTable)
  this.messageExecTable=nil

  if not IvarProc.EnabledForMission(this.enableIvars) then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

  this.InitCluster()
end

function this.OnReload(missionTable)
  this.messageExecTable=nil

  if not IvarProc.EnabledForMission(this.enableIvars) then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end

function this.Messages()
  return Tpp.StrCode32Table{
    MotherBaseStage={
      --{msg="MotherBaseCurrentClusterLoadStart",func=this.MotherBaseCurrentClusterLoadStart},
      {msg="MotherBaseCurrentClusterActivated",func=this.MotherBaseCurrentClusterActivated},
    },
  }
end
function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
  Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end

function this.MotherBaseCurrentClusterActivated(clusterId)
  this.InitCluster(clusterId)
end

function this.InitCluster(clusterId)
  --InfCore.PCall(function(clusterId)--DEBUG
  if vars.missionCode~=30050 then
    return
  end

  mbDemoWasPlayed=false

  npcList={}
  npcPlats={}
  npcRoutes={}

  routesForPlat={}
  platForRoute={}

  numSoldiersOnPlat={}
  numSoldiersOnRoute={}

  local isRouteChange=Ivars.mbNpcRouteChange:Is(1)

  local clusterId=clusterId or GetCurrentCluster()
  clusterId=clusterId+1

  --local clusterName=TppDefine.CLUSTER_NAME[clusterId]

  local GetMBEnemyAssetTable=TppEnemy.GetMBEnemyAssetTable or mvars.mbSoldier_funcGetAssetTable
  if GetMBEnemyAssetTable==nil then
    return
  end
  local grade=GetMbStageClusterGrade(clusterId)

  --tex loading an unbuilt cluster probbably doesnt happen anyway lol
  if grade==0 then
    return
  end

  for platIndex=1,grade do
    numSoldiersOnPlat[platIndex]=0

    local clusterAssetTable=GetMBEnemyAssetTable(clusterId)
    local platName=plntPrefix..(platIndex-1)

    local platInfo=clusterAssetTable[platName]

    local sneakRoutes=platInfo.soldierRouteList.Sneak[1].inPlnt
    local nightRoutes=platInfo.soldierRouteList.Night[1].inPlnt
    local cautionRoutes=platInfo.soldierRouteList.Caution[1].inPlnt

    --tex mb doesn't have caution routes by default, should be fine to patch without user action since they wouldn't be used normally
    if #cautionRoutes then
      for i=1,#sneakRoutes do
        --tex TODO: random selection of day/night
        cautionRoutes[i]=sneakRoutes[i]
      end
    end

    if isRouteChange then
      local soldierList=platInfo.soldierList
      for j=1,#soldierList do
        local npcName=soldierList[j]
        local gameId=GetGameObjectId(npcName)
        if gameId==NULL_ID then
          InfCore.Log("WARNING: InfSoldier.InitCluster "..npcName.." not found")--DEBUG
        else
          local newIndex=#npcList+1
          npcList[newIndex]=npcName
          npcPlats[newIndex]=platIndex
          numSoldiersOnPlat[platIndex]=numSoldiersOnPlat[platIndex]+1
        end
      end

      local platRoutes={}
      routesForPlat[platIndex]=platRoutes

      local routes=sneakRoutes
      for n,routes in ipairs({sneakRoutes,nightRoutes})do
        for i=1,#routes do
          local route=routes[i]
          platRoutes[#platRoutes+1]=route
          platForRoute[route]=platIndex
          numSoldiersOnRoute[route]=0--tex TODO: initial soldier route assignemnt is not accounted for, it seems like routes for mb are just assigned soldierlist index>route list index, but not totally sure
        end
      end
      --<isRouteChange
    end
    --<for plats
  end
  --end,clusterId)--DEBUG
end

function this.Update(currentChecks,currentTime,execChecks,execState)
  --InfCore.PCall(function(currentChecks,currentTime,execChecks,execState)--DEBUG
  if not currentChecks.inGame then
    return
  end

  if not this.active:EnabledForMission() then
    return
  end

  local demoName=TppDemo.GetMBDemoName()
  if demoName then
    mbDemoWasPlayed=true
    return
  end

  if #npcList==0 then
    --InfCore.DebugPrint"Update #npcList==0 aborting"--DEBUG
    return
  end

  local clusterId=GetCurrentCluster()+1
  local grade=GetMbStageClusterGrade(clusterId)
  if grade==1 then
    return
  end

  local npcIndex=Random(1,#npcList)
  local npcName=npcList[npcIndex]

  local gameId=GetGameObjectId(npcName)
  if gameId==NULL_ID then
    InfCore.Log("WARNING: InfSoldier.Update "..npcName.." not found")--DEBUG
    return
  end

  local previousPlat=npcPlats[npcIndex]

  local availablePlats={}
  for i=1,grade do
    if numSoldiersOnPlat[i]<maxSoldiersPerPlat and i~=previousPlat then
      availablePlats[#availablePlats+1]=i
    end
  end

  local platIndex=1
  if #availablePlats>0 then
    platIndex=availablePlats[Random(#availablePlats)]
  else
    --InfCore.DebugPrint"#availablePlats==0"--DEBUG
    platIndex=Random(1,grade)
    --return--CULL
  end

  if previousPlat then
    numSoldiersOnPlat[previousPlat]=numSoldiersOnPlat[previousPlat]-1
  end
  npcPlats[npcIndex]=platIndex

  local platRoutes=routesForPlat[platIndex]
  local routeIdx=Random(#platRoutes)
  local route=platRoutes[routeIdx]
  --GOTCHA possible inf loop if #route on plat * maxSoldiersOnSameRoute < maxSoldiersPerPlat
  --InfCore.DebugPrint("#platRoutes:"..#platRoutes.." * maxSoldiersOnSameRoute="..(#platRoutes*maxSoldiersOnSameRoute).." maxSoldiersPerPlat:"..maxSoldiersPerPlat)--DEBUG
  if #platRoutes*maxSoldiersOnSameRoute < maxSoldiersPerPlat then
    InfCore.Log("WARNING: InfSoldier:Update - #platRoutes*maxSoldiersOnSameRoute < maxSoldiersPerPlat, aborting")--DEBUG
    return
  end

  while(numSoldiersOnRoute[route]>=maxSoldiersOnSameRoute)do
    routeIdx=Random(#platRoutes)
    route=platRoutes[routeIdx]
  end

  local lastRoute=npcRoutes[npcIndex]
  npcRoutes[npcIndex]=route

  if lastRoute then
    numSoldiersOnRoute[lastRoute]=numSoldiersOnRoute[lastRoute]-1
  end
  numSoldiersOnRoute[route]=numSoldiersOnRoute[route]+1

  --InfCore.DebugPrint(npcName .. " from plat "..tostring(lastPlat).." to plat "..platIndex.. " routeIdx ".. routeIdx .. " nextRouteTime "..nextRouteTime)--DEBUG
  local command={id="SetSneakRoute",route=route}
  SendCommand(gameId,command)
  local command={id="SwitchRoute",route=route}
  SendCommand(gameId,command)

  execState.nextUpdate=currentTime+Random(updateMin,updateMax)
  --end,currentChecks,currentTime,execChecks,execState)--DEBUG
end

--tex TODO, hook up to msg
function this.OnEliminated(soldierId)
--TODO: find index in npclist
--npcPlats[index] > decrease soldiersonplat,npcRoutes[index] decrease soldiersonroute
end

--tex additional soldiers:

--TUNE
-- CULL local additionalSoldiersPerPlat=5
local maxSoldiersOnPlat=9

this.soldierPool=nil

--caller: mtbs_enemy.OnLoad
--IN/OUT: mb layout lua (ex ly003) .enemyAssetTable (via TppEnemy.GetMBEnemyAssetTable or mvars.mbSoldier_funcGetAssetTable)
--IN-SIDE: InfMain.soldierPool
--tex adds extra soldiers,route names to mb cps
function this.ModifyEnemyAssetTable()
  InfCore.LogFlow"InfSoldier.ModifyEnemyAssetTable"
  --InfCore.PCall(function()--DEBUG
  if not Ivars.mbAdditionalSoldiers:EnabledForMission() then
    return
  end

  if InfMain.IsContinue() then
    return
  end

  --tex this is before ModMissionTable so have to set up itself
  local numReserveSoldiers=InfMain.reserveSoldierCounts[vars.missionCode] or 0
  this.reserveSoldierNames=InfLookup.GenerateNameList("sol_ih_%04d",numReserveSoldiers)
  this.soldierPool=InfUtil.CopyList(this.reserveSoldierNames)

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
        --        InfCore.DebugPrint("cluster "..clusterId.. " "..platName.." #soldierListpre "..#soldierList)--DEBUG
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
          InfUtil.FillList(numToAdd,this.soldierPool,soldierList)
        end
        soldierCountFinal=soldierCountFinal+#soldierList
        --        if clusterId==mtbs_cluster.GetCurrentClusterId() then--DEBUG>
        --          local totalRouteCount=#sneakRoutes+#nightRoutes
        --          InfCore.DebugPrint("cluster "..clusterId.. " "..platName.. " minRouteCount "..minRouteCount.." totalRouteCount "..totalRouteCount.." numToAdd "..numToAdd.." #soldierList "..#soldierList)--DEBUG
        --          --InfCore.PrintInspect(soldierList)--DEBUG
        --        end--<
      end
    end

    --InfCore.DebugPrint(string.format("cluster:%d routeCount:%d soldierCountFinal:%d",clusterId,routeCount,soldierCountFinal))--DEBUG
  end
  --InfCore.DebugPrint("#this.soldierPool:"..#this.soldierPool)--DEBUG
  --end)--
end

--IN/OUT soldierPool,soldierDefine,travelPlans
--OUT: lrrpDefines
--tex sets up lrrp foot patrols between bases, soldiers are added in ModifyLrrpSoldiers
function this.AddLrrps(soldierDefine,travelPlans,lrrpDefines,emptyCpPool)
  if not Ivars.enableLrrpFreeRoam:EnabledForMission() then
    return
  end

  if InfMain.IsContinue() then
    return
  end

  InfMain.RandomSetToLevelSeed()

  local baseNameBag1=InfUtil.ShuffleBag:New()
  local baseNameBag2=InfUtil.ShuffleBag:New()

  local locationName=InfUtil.GetLocationName()
  local baseNames=InfMain.baseNames[locationName]
  local halfBases=math.ceil(#baseNames/2)

  for n,cpName in pairs(baseNames)do
    local cpDefine=soldierDefine[cpName]
    if cpDefine==nil then
    --InfCore.DebugPrint(tostring(cpName).." cpDefine==nil")--DEBUG
    else
      local cpId=GetGameObjectId("TppCommandPost2",cpName)
      if cpId==NULL_ID then
        InfCore.DebugPrint("baseNames "..tostring(cpName).." cpId==NULL_ID")--DEBUG
      else
        if n<=halfBases then
          baseNameBag1:Add(cpName)
        else
          baseNameBag2:Add(cpName)
        end
      end
    end
  end
  --InfCore.DebugPrint("#baseNameBag:"..baseNameBag:Count())--DEBUG

  local addedLrrpCount=0--DEBUG

  --tex one lrrp per two bases (start at one, head to next) is a nice target for num of lrrps, but lrrp cps or soldiercount may run out first
  local numLrrps=halfBases

  for i=1,numLrrps do
    --tex the main limiter, available empty cps to use for lrrps
    if #emptyCpPool==0 then
      InfCore.Log"#cpPool==0"--DEBUG
      break
    end

    local cpName=emptyCpPool[#emptyCpPool]
    emptyCpPool[#emptyCpPool]=nil

    local cpDefine=soldierDefine[cpName]

    local planName="travelIH_"..cpName
    cpDefine.lrrpTravelPlan=planName
    local base1,base2

    --tex to give variation on start bases
    if math.random(50)>100 then
      base1=baseNameBag1:Next()
      base2=baseNameBag2:Next()
    else
      base2=baseNameBag1:Next()
      base1=baseNameBag2:Next()
    end

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
    lrrpDefines[cpName]=lrrpDefine
    lrrpDefines[#lrrpDefines+1]=cpName

    addedLrrpCount=i
  end

  InfMain.RandomResetToOsTime()

  if this.debugModule then
    InfCore.Log("AddLrrps: addedLrrpCount:"..addedLrrpCount)
    InfCore.PrintInspect(lrrpDefines,{varName="InfMain.lrrpDefines"})
  end
end

--IN/OUT soldierPool,soldierDefine
--IN-SIDE: InfVehicle.inf_patrolVehicleInfo
--tex adjusts soldiers assigned to lrrp vehicles
function this.ModifyLrrpSoldiers(soldierDefine,soldierPool)
  if InfMain.IsContinue() then
    return
  end

  InfMain.RandomSetToLevelSeed()

  local seatChanges={}--DEBUG
  local initPoolSize=#soldierPool--DEBUG
  for cpName,cpDefine in pairs(soldierDefine)do
    local fillDelta=0

    if cpDefine.lrrpVehicle then
      if Ivars.vehiclePatrolProfile:EnabledForMission() then
        local numSeats=this.GetNumSeats(cpDefine.lrrpVehicle)--tex figure out how many soldiers for the vehicle
        fillDelta=numSeats-#cpDefine--tex #cpDefine is number of cp soldiers
        seatChanges[cpDefine.lrrpVehicle]=fillDelta--DEBUG
      end
    elseif cpDefine.lrrpWalker then
      --if Ivars.enableWalkerGearsFREE:EnabledForMission() then
      local lrrpSize=InfWalkerGear.walkersPerLrrp
      fillDelta=lrrpSize-#cpDefine
      --end
    elseif cpDefine.lrrpTravelPlan and not cpDefine.lrrpVehicle then
      if Ivars.enableLrrpFreeRoam:EnabledForMission() then
        local lrrpSize=this.numLrrpSoldiers
        fillDelta=lrrpSize-#cpDefine
      end
    end

    if fillDelta<0 then--tex over filled,back into soldierPool
      local soldiersRemoved=InfUtil.FillList(-fillDelta,cpDefine,soldierPool)
    elseif fillDelta>0 then--tex under filled,add soldiers
      local soldiersAdded=InfUtil.FillList(fillDelta,soldierPool,cpDefine)
    end
  end

  if this.debugModule then
    local poolChange=#soldierPool-initPoolSize
    InfCore.Log("ModifyLrrpSoldiers #soldierPool:"..#soldierPool.." pool change:"..poolChange)
    InfCore.PrintInspect(soldierPool,{varName="soldierPool"})
    InfCore.PrintInspect(seatChanges,{varName="seatChanges"})
  end

  InfMain.RandomResetToOsTime()
end

--TUNE:
--afgh has ~39 cps, mafr ~33

--tex total limit TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT=16
this.numWildCards={
  MALE=5,
  FEMALE=5,
}

this.numWildCards.total=this.numWildCards.MALE+this.numWildCards.FEMALE

local wildCardSubTypes={
  afgh="SOVIET_WILDCARD",
  mafr="PF_WILDCARD",
}

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

--ASSUMPTION, ordered after vehicle cpdefines have been modified
--IN/OUT: soldierPool,soldierDefine,soldierSubTypes,soldierPowerSettings,soldierPersonalAbilitySettings
--IN-SIDE: InfEneFova.inf_wildCardFemaleFaceList,InfEneFova.inf_wildCardMaleFaceList
--IN-SIDE: this.numWildCards
--OUT-SIDE: this.ene_wildCardInfo
--tex sets up some soldiers of existing cps as wildcard soldiers
function this.AddWildCards(soldierDefine,soldierSubTypes,soldierPowerSettings,soldierPersonalAbilitySettings)
  if not Ivars.enableWildCardFreeRoam:EnabledForMission() then
    return
  end

  local InfEneFova=InfEneFova
  --CULL
  --  if not InfEneFova.inf_wildCardFemaleFaceList or #InfEneFova.inf_wildCardFemaleFaceList==0  then
  --    InfCore.Log("AddWildCards InfEneFova.inf_wildCardFemaleFaceList not set up, aborting",true)
  --    return
  --  end
  --  if not InfEneFova.inf_wildCardMaleFaceList or #InfEneFova.inf_wildCardMaleFaceList==0  then
  --    InfCore.Log("AddWildCards InfEneFova.inf_wildCardMaleFaceList not set up, aborting",true)
  --    return
  --  end

  local uniqueSettings=TppEneFova.GetUniqueSettings()
  --  InfCore.Log"TppEneFova uniqueSettings pre:"
  --  InfCore.PrintInspect(uniqueSettings)
  --

  if InfMain.IsContinue() then
    for soldierName,wildCardInfo in pairs(this.ene_wildCardInfo)do
      local gameObjectId=GetGameObjectId("TppSoldier2",soldierName)
      if gameObjectId==NULL_ID then
        InfCore.Log("WARNING: AddWildCards continue "..soldierName.."==NULL_ID")--DEBUG
      else
        local command={id="UseExtendParts",enabled=wildCardInfo.isFemale}
        SendCommand(gameObjectId,command)
      end
    end
    return
  end

  InfMain.RandomSetToLevelSeed()

  local baseNamePool=InfMain.BuildCpPoolWildCard(soldierDefine)

  local locationName=InfUtil.GetLocationName()
  local wildCardSubType=wildCardSubTypes[locationName]or "SOVIET_WILDCARD"

  local weaponPowersBag=InfUtil.ShuffleBag:New(weaponPowers)

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

  this.ene_wildCardNames={}
  this.ene_wildCardInfo={}

  local numFemales=0
  local maleFaceIdPool=InfUtil.CopyList(InfEneFova.inf_wildCardMaleFaceList)
  local femaleFaceIdPool=InfUtil.CopyList(InfEneFova.inf_wildCardFemaleFaceList)
  --InfCore.DebugPrint("#maleFaceIdPool:"..#maleFaceIdPool.." #femaleFaceIdPool:"..#femaleFaceIdPool)--DEBUG
  --  InfCore.DebugPrint"ene_wildCardFaceList"--DEBUG >
  --  InfCore.PrintInspect(InfEneFova.inf_wildCardFaceList)--<

  for i=1,this.numWildCards.total do
    if #baseNamePool==0 then
      InfCore.DebugPrint"#baseNamePool==0"--DEBUG
      break
    end

    local cpName=InfUtil.GetRandomPool(baseNamePool)
    local cpDefine=soldierDefine[cpName]
    local soldierName=cpDefine[math.random(#cpDefine)]

    local gameObjectId=GetGameObjectId("TppSoldier2",soldierName)
    if gameObjectId==NULL_ID then
      InfCore.Log("WARNING: AddWildCards "..soldierName.."==NULL_ID")--DEBUG
    else

      local isFemale=false
      if numFemales<this.numWildCards.FEMALE then
        isFemale=true
        numFemales=numFemales+1
      elseif IvarProc.EnabledForMission"customSoldierType" then
        --InfCore.Log("AddWildCards EnabledForMission customSoldierType and > numFemales, bailing")--DEBUG
        --tex bail out of male because customSoldierType interferes TODO: extend wildcard to other soldiertypes with multiple bodies
        break
      end

      --tex choose face
      local faceIdPool
      if isFemale then
        faceIdPool=femaleFaceIdPool
      else
        faceIdPool=maleFaceIdPool
      end
      if #faceIdPool==0 then
        InfCore.Log("#faceIdPool too small, aborting",true)--DEBUG
        break
      end

      local faceId=InfUtil.GetRandomPool(faceIdPool)

      --tex choose body
      local bodyId=EnemyFova.INVALID_FOVA_VALUE
      if isFemale then
        local bodyInfo=InfEneFova.GetFemaleWildCardBodyInfo()
        if not bodyInfo or not bodyInfo.bodyId then
          InfCore.Log("WARNING no bodyinfo for wildcard",true)--DEBUG
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

      --tex RegisterUniqueSetting face,body
      --tex GOTCHA LIMIT TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT
      local hasSetting=false
      local uniqueSettings=TppEneFova.GetUniqueSettings()
      for i=1,#uniqueSettings do
        if uniqueSettings[i].name==soldierName then
          hasSetting=true
          if isFemale and not InfEneFova.IsFaceFemale(uniqueSettings[i].faceId) then
            InfCore.Log("WARNING: AddWildCards "..soldierName.." marked as female and uniqueSetting face not female",true)--DEBUG
          end
        end
      end
      if not hasSetting then
        TppEneFova.RegisterUniqueSetting("enemy",soldierName,faceId,bodyId)
      end


      local command={id="UseExtendParts",enabled=isFemale}
      SendCommand(gameObjectId,command)


      --
      soldierSubTypes[wildCardSubType]=soldierSubTypes[wildCardSubType] or {}
      table.insert(soldierSubTypes[wildCardSubType],soldierName)

      local soldierPowers={}
      for n,power in pairs(gearPowers) do
        soldierPowers[#soldierPowers+1]=power
      end
      soldierPowers[#soldierPowers+1]=weaponPowersBag:Next()

      soldierPowerSettings[soldierName]=soldierPowers

      soldierPersonalAbilitySettings[soldierName]=personalAbilitySettings

      --OFF this.RegenerateStaffParams(gameObjectId)--tex too early for this aparently

      local wildCardInfo={
        cpName=cpName,
        isFemale=isFemale,
        faceId=faceId,
        bodyId=bodyId,
        soldierPowers=soldierPowers,
      }
      this.ene_wildCardNames[#this.ene_wildCardNames+1]=soldierName
      this.ene_wildCardInfo[soldierName]=wildCardInfo
    end
  end

  --DEBUG
  if this.debugModule then
    InfCore.PrintInspect(this.ene_wildCardInfo,{varName="ene_wildCardInfo"})
    local uniqueSettings=TppEneFova.GetUniqueSettings()
    InfCore.PrintInspect(uniqueSettings,{varName="TppEneFova uniqueSettings"})

    --InfCore.DebugPrint("numadded females:"..tostring(numFemales))--DEBUG

    --InfCore.Log("num wildCards"..numLrrps)--DEBUG
  end
  InfMain.RandomResetToOsTime()
end

function this.SetUpEnemy(missionTable)
  if not Ivars.enableWildCardFreeRoam:EnabledForMission() then
    return
  end

  if not TppMission.IsMissionStart() then
    return
  end

  InfMain.RandomSetToLevelSeed()

  for soldierName,wildCardInfo in pairs(this.ene_wildCardInfo)do
    local gameId=GetGameObjectId("TppSoldier2",soldierName)
    if gameId==NULL_ID then
      InfCore.Log("WARNING: InfSoldier.SetUpEnemy - "..soldierName.."==NULL_ID")--DEBUG
    else
      local staffInfo=this.RegenerateStaffParams(gameId)
      wildCardInfo.staffInfo=staffInfo
    end
  end

  InfMain.RandomResetToOsTime()
end

local skills={
  --physical
  "Reflex",
  "Ninja",
  "Athlete",
  "FultonExpert",
  "QuickReload",
  "Study",
  "Lucky",
  "Grappler",
  "Botanist",
  "QuickDraw",
  --sevice
  "Surgeon",
  "Physician",
  "Counselor",
  --
  "GunsmithHandGun",
  "GunsmithSubmachineGun",
  "GunsmithAssultRifle",
  "GunsmithShotGun",
  "GunsmithGrenadeLauncher",
  "GunsmithSniperRifle",
  "GunsmithMachineGun",
  "GunsmithMissile",
  --
  --"TranqEngineer",
  --"SuppressorEngineer",
  --"MissileHomingEngineer",
  --"Zoologist",
  --"SleepingGasEngineer",
  --"ElectricEngineer",
  --"ElectromagneticNetEngineer",
  --"RadarEngineer",
  --"MetamaterialEngineer",
  --"DrugEngineer",
  --"MechatronicsEngineer",
  --"CyberneticsEngineer",
  --"RocketControlEngineer",
  --"ElectricSpinningEngineer",
  --"MaterialEngineer",
  --"HaulageEngineer",
  --"MonitorEngineer",
  --translators
  --"TranslateRussian",
  --"TranslateAfrikaans",
  --"TranslateKikongo",
  --"TranslatePashto",
  --retailpatch new
  "Defender1",
  "Defender3",
  "Sentry1",
  "Sentry2",
  "Sentry3",
  "Ranger1",
  "Ranger2",
  "Ranger3",
  "Medic1",
  "Medic2",
  "Medic3",
  "LiquidCarbonMissileEngineer1",
  "LiquidCarbonMissileEngineer2",
  "LiquidCarbonMissileEngineer3",
  "InterceptorMissileEngineer1",
  "InterceptorMissileEngineer2",
  "InterceptorMissileEngineer3",
  --troublemakers
  --"BigMouth",
  "TroublemakerViolence",
  "TroublemakerIntemperately",
  "TroublemakerHarassment",
  "Moodmaker",
--"None",
}

function this.RegenerateStaffParams(gameId)
  local staffInfo={
    gameObjectId=gameId,
    --tex see MbmCommonSetting
    staffTypeId=math.random(2,62),
    randomRangeId=6,
    skill=InfUtil.GetRandomInList(skills),
  --DEBUG
  --  staffTypeId=62
  --  randomRangeId=3
  --  skill="InterceptorMissileEngineer3"
  }

  TppMotherBaseManagement.RegenerateGameObjectStaffParameter(staffInfo)

  return staffInfo
end

--IN-SIDE: InfVehicle.inf_patrolVehicleInfo
function this.GetNumSeats(lrrpVehicle)
  local numSeats=2
  if InfVehicle.inf_patrolVehicleInfo then
    local vehicleInfo=InfVehicle.inf_patrolVehicleInfo[lrrpVehicle]
    if vehicleInfo then
      local baseTypeInfo=InfVehicle.vehicleBaseTypes[vehicleInfo.baseType]
      if baseTypeInfo then
        numSeats=math.random(math.min(numSeats,baseTypeInfo.seats),baseTypeInfo.seats)
        --InfCore.DebugPrint(cpDefine.lrrpVehicle .. " numVehSeats "..numSeats)--DEBUG
      end
    end
  end
  return numSeats
end

function this.ModMissionTableTop(missionTable,emptyCpPool)
  if this.debugModule then
    InfCore.LogFlow("InfSoldier.ModMissionTableTop")
    InfCore.Log("#soldierPool:"..#InfMain.soldierPool)
    InfCore.PrintInspect(InfMain.soldierPool,{varName="InfMain.soldierPool"})

    InfCore.Log("#emptyCpPool:"..#emptyCpPool)
    InfCore.PrintInspect(emptyCpPool,{varName="emptyCpPool"})

    local baseCpPool=InfMain.BuildBaseCpPool(missionTable.enemy.soldierDefine)
    InfCore.Log("#baseCpPool:"..#baseCpPool)
    InfCore.PrintInspect(baseCpPool,{varName="baseCpPool"})
  end
end

function this.ModMissionTableBottom(missionTable,emptyCpPool)
  if this.debugModule then
    InfCore.LogFlow("InfSoldier.ModMissionTableBottom")
    InfCore.Log("#soldierPool:"..#InfMain.soldierPool)
    InfCore.PrintInspect(InfMain.soldierPool,{varName="InfMain.soldierPool"})

    InfCore.Log("#emptyCpPool:"..#emptyCpPool)
    InfCore.PrintInspect(emptyCpPool,{varName="emptyCpPool"})
  end
end

return this
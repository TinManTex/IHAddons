-- InfNPC.lua
-- tex implements soldier additions/modificationa and route changes on MB
-- Ivars: vehiclePatrolProfile, enableLrrpFreeRoam, enableWildCardFreeRoam, mbAdditionalSoldiers, mbNpcRouteChange
local this={}

--LOCALOPT
local InfLog=InfLog
local InfMain=InfMain
local StrCode32=Fox.StrCode32
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
this.ene_wildCardInfo={}

this.packages={
  "/Assets/tpp/pack/mission2/ih/ih_soldier_loc_mb.fpk"--tex still relies on totalCount in f30050_npc.fox2
}

function this.AddMissionPacks(missionCode,packPaths)
  if not Ivars.mbAdditionalSoldiers:EnabledForMission() then
    return
  end

  for i,packPath in ipairs(this.packages) do
    packPaths[#packPaths+1]=packPath
  end
end

function this.Init(missionTable)
  if not IvarProc.EnabledForMission(this.enableIvars) then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
  
  this.InitCluster()
end

function this.OnReload(missionTable)
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
  if not IvarProc.EnabledForMission(this.enableIvars) then
    return
  end

  Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end

function this.MotherBaseCurrentClusterActivated(clusterId)
  this.InitCluster(clusterId)
end

function this.InitCluster(clusterId)
  --InfLog.PCall(function(clusterId)--DEBUG
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
          InfLog.Add("WARNING: InfNPC.InitCluster "..npcName.." not found")--DEBUG
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
  --InfLog.PCall(function(currentChecks,currentTime,execChecks,execState)--DEBUG
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
    --InfLog.DebugPrint"Update #npcList==0 aborting"--DEBUG
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
    InfLog.Add("WARNING: InfNPC.Update "..npcName.." not found")--DEBUG
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
    --InfLog.DebugPrint"#availablePlats==0"--DEBUG
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
  --InfLog.DebugPrint("#platRoutes:"..#platRoutes.." * maxSoldiersOnSameRoute="..(#platRoutes*maxSoldiersOnSameRoute).." maxSoldiersPerPlat:"..maxSoldiersPerPlat)--DEBUG
  if #platRoutes*maxSoldiersOnSameRoute < maxSoldiersPerPlat then
    InfLog.Add("WARNING: InfNPC:Update - #platRoutes*maxSoldiersOnSameRoute < maxSoldiersPerPlat, aborting")--DEBUG
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

  --InfLog.DebugPrint(npcName .. " from plat "..tostring(lastPlat).." to plat "..platIndex.. " routeIdx ".. routeIdx .. " nextRouteTime "..nextRouteTime)--DEBUG
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
  InfLog.AddFlow"InfNPC.ModifyEnemyAssetTable"
  --InfLog.PCall(function()--DEBUG
  if not Ivars.mbAdditionalSoldiers:EnabledForMission() then
    return
  end
  
  if InfMain.IsContinue() then
    return
  end

  --tex this is before ModMissionTable so have to set up itself
  local numReserveSoldiers=InfMain.reserveSoldierCounts[vars.missionCode] or 0
  this.reserveSoldierNames=InfLookup.GenerateNameList("sol_ih_%04d",numReserveSoldiers)   
  this.soldierPool=InfMain.ResetPool(this.reserveSoldierNames)

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
          InfMain.FillList(numToAdd,this.soldierPool,soldierList)
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

  local baseNameBag1=InfMain.ShuffleBag:New()
  local baseNameBag2=InfMain.ShuffleBag:New()

  local locationName=InfMain.GetLocationName()
  local baseNames=InfMain.baseNames[locationName]
  local halfBases=math.ceil(#baseNames/2)

  for n,cpName in pairs(baseNames)do
    local cpDefine=soldierDefine[cpName]
    if cpDefine==nil then
    --InfLog.DebugPrint(tostring(cpName).." cpDefine==nil")--DEBUG
    else
      local cpId=GetGameObjectId("TppCommandPost2",cpName)
      if cpId==NULL_ID then
        InfLog.DebugPrint("baseNames "..tostring(cpName).." cpId==NULL_ID")--DEBUG
      else
        if n<=halfBases then
          baseNameBag1:Add(cpName)
        else
          baseNameBag2:Add(cpName)
        end
      end
    end
  end
  --InfLog.DebugPrint("#baseNameBag:"..baseNameBag:Count())--DEBUG

  local addedLrrpCount=0--DEBUG

  --tex one lrrp per two bases (start at one, head to next) is a nice target for num of lrrps, but lrrp cps or soldiercount may run out first
  local numLrrps=halfBases

  for i=1,numLrrps do
    --tex the main limiter, available empty cps to use for lrrps
    if #emptyCpPool==0 then
      InfLog.Add"#cpPool==0"--DEBUG
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
    InfLog.Add("AddLrrps: addedLrrpCount:"..addedLrrpCount)
    InfLog.Add"InfMain.lrrpDefines"
    InfLog.PrintInspect(lrrpDefines)
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
      local soldiersRemoved=InfMain.FillList(-fillDelta,cpDefine,soldierPool)
    elseif fillDelta>0 then--tex under filled,add soldiers
      local soldiersAdded=InfMain.FillList(fillDelta,soldierPool,cpDefine)
    end
  end

  if this.debugModule then
    local poolChange=#soldierPool-initPoolSize
    InfLog.Add("ModifyLrrpSoldiers #soldierPool:"..#soldierPool.." pool change:"..poolChange)
    InfLog.PrintInspect(soldierPool)
    InfLog.Add"seatChanges"
    InfLog.PrintInspect(seatChanges)
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
this.numWildCards=10--tex limit TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT=16
this.numWildCardFemales=5

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
--IN-SIDE: this.numWildCards,this.numWildCardFemales
--OUT-SIDE: this.ene_wildCardInfo
--tex sets up some soldiers of existing cps as wildcard soldiers
function this.AddWildCards(soldierDefine,soldierSubTypes,soldierPowerSettings,soldierPersonalAbilitySettings)
  if not Ivars.enableWildCardFreeRoam:EnabledForMission() then
    return
  end

  local InfEneFova=InfEneFova
  if not InfEneFova.inf_wildCardFemaleFaceList or #InfEneFova.inf_wildCardFemaleFaceList==0  then
    InfLog.Add("AddWildCards InfEneFova.inf_wildCardFemaleFaceList not set up, aborting",true)
    return
  end
  if not InfEneFova.inf_wildCardMaleFaceList or #InfEneFova.inf_wildCardMaleFaceList==0  then
    InfLog.Add("AddWildCards InfEneFova.inf_wildCardMaleFaceList not set up, aborting",true)
    return
  end

  local uniqueSettings=TppEneFova.GetUniqueSettings()
  InfLog.Add"TppEneFova uniqueSettings:"
  InfLog.PrintInspect(uniqueSettings)
  --

  if InfMain.IsContinue() then
    for soldierName,wildCardInfo in pairs(this.ene_wildCardInfo)do
      local gameObjectId=GetGameObjectId("TppSoldier2",soldierName)
      if gameObjectId==NULL_ID then
        InfLog.Add("WARNING: AddWildCards continue "..soldierName.."==NULL_ID")--DEBUG
      else
        local command={id="UseExtendParts",enabled=wildCardInfo.isFemale}
        SendCommand(gameObjectId,command)
      end
    end
    return
  end

  InfMain.RandomSetToLevelSeed()

  local baseNamePool=InfMain.BuildCpPoolWildCard(soldierDefine)

  local locationName=InfMain.GetLocationName()
  local wildCardSubType=wildCardSubTypes[locationName]or "SOVIET_WILDCARD"

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
  --this.numWildCards=math.min(TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT,this.numWildCards)
  --tex shifted outside of function-- this.numWildCardFemales=math.max(1,math.ceil(numWildCards/2))--SYNC: MAX_WILDCARD_FACES
  --InfLog.Add("numwildcards: "..this.numWildCards .. " numFemale:"..this.numWildCardFemales)--DEBUG

  --  InfLog.DebugPrint"ene_wildCardFaceList"--DEBUG >
  --  InfLog.PrintInspect(InfEneFova.inf_wildCardFaceList)--<

  this.ene_wildCardInfo={}

  local numFemales=0
  local maleFaceIdPool=InfMain.ResetPool(InfEneFova.inf_wildCardMaleFaceList)
  local femaleFaceIdPool=InfMain.ResetPool(InfEneFova.inf_wildCardFemaleFaceList)
  --InfLog.DebugPrint("#maleFaceIdPool:"..#maleFaceIdPool.." #femaleFaceIdPool:"..#femaleFaceIdPool)--DEBUG

  for i=1,this.numWildCards do
    if #baseNamePool==0 then
      InfLog.DebugPrint"#baseNamePool==0"--DEBUG
      break
    end

    local cpName=InfMain.GetRandomPool(baseNamePool)
    local cpDefine=soldierDefine[cpName]
    local soldierName=cpDefine[math.random(#cpDefine)]

    local isFemale=false
    if numFemales<this.numWildCardFemales then
      isFemale=true
      numFemales=numFemales+1
    end

    --tex choose face
    local faceIdPool
    if isFemale then
      faceIdPool=femaleFaceIdPool
    else
      faceIdPool=maleFaceIdPool
    end
    if #faceIdPool==0 then
      InfLog.Add("#faceIdPool too small, aborting",true)--DEBUG
      break
    end
    local faceId=InfMain.GetRandomPool(faceIdPool)

    --tex choose body
    local bodyId=EnemyFova.INVALID_FOVA_VALUE
    if isFemale then
      local bodyInfo=InfEneFova.GetFemaleWildCardBodyInfo()
      if not bodyInfo or not bodyInfo.bodyId then
        InfLog.Add("WARNING no bodyinfo for wildcard",true)--DEBUG
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
        if isFemale and not FaceIsFemale(uniqueSettings[i].faceId) then
          InfLog.Add("WARNING: AddWildCards "..soldierName.." marked as female and uniqueSetting face not female",true)--DEBUG
        end
      end
    end
    if not hasSetting then
      TppEneFova.RegisterUniqueSetting("enemy",soldierName,faceId,bodyId)
    end

    local gameObjectId=GetGameObjectId("TppSoldier2",soldierName)
    if gameObjectId==NULL_ID then
      InfLog.Add("WARNING: AddWildCards "..soldierName.."==NULL_ID")--DEBUG
    else
      local command={id="UseExtendParts",enabled=isFemale}
      SendCommand(gameObjectId,command)
    end

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

    local wildCardInfo={
      cpName=cpName,
      isFemale=isFemale,
      faceId=faceId,
      bodyId=bodyId,
      soldierPowers=soldierPowers,
    }
    this.ene_wildCardInfo[soldierName]=wildCardInfo
    this.ene_wildCardInfo[#this.ene_wildCardInfo+1]=soldierName
  end

  --DEBUG
  if this.debugModule then
    InfLog.Add"ene_wildCardInfo:"
    InfLog.PrintInspect(this.ene_wildCardInfo)
    --  local uniqueSettings=TppEneFova.GetUniqueSettings()
    --  InfLog.Add"TppEneFova uniqueSettings"
    --  InfLog.PrintInspect(uniqueSettings)

    --InfLog.DebugPrint("numadded females:"..tostring(numFemales))--DEBUG

    --InfLog.Add("num wildCards"..numLrrps)--DEBUG
  end
  InfMain.RandomResetToOsTime()
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
        --InfLog.DebugPrint(cpDefine.lrrpVehicle .. " numVehSeats "..numSeats)--DEBUG
      end
    end
  end
  return numSeats
end

--DEBUGNOW
function this.ModMissionTableTop(missionTable,emptyCpPool)
  if this.debugModule then
  InfLog.Add("----ModMissionTableTop----")
  InfLog.Add("#soldierPool:"..#InfMain.soldierPool)
  InfLog.PrintInspect(InfMain.soldierPool)

  InfLog.Add("#emptyCpPool:"..#emptyCpPool)
  InfLog.PrintInspect(emptyCpPool)

  local baseCpPool=InfMain.BuildBaseCpPool(missionTable.enemy.soldierDefine)
  InfLog.Add("#baseCpPool:"..#baseCpPool)
  InfLog.PrintInspect(baseCpPool)
  end
end

function this.ModMissionTableBottom(missionTable,emptyCpPool)
  if this.debugModule then
  InfLog.Add("----ModMissionTableBottom----")
  InfLog.Add("#soldierPool:"..#InfMain.soldierPool)
  InfLog.PrintInspect(InfMain.soldierPool)

  InfLog.Add("#emptyCpPool:"..#emptyCpPool)
  InfLog.PrintInspect(emptyCpPool)
  end
end

return this
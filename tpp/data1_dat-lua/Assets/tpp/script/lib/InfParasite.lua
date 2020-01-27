-- DOBUILD: 1
-- InfParasite.lua
local this={}

local GetGameObjectId=GameObject.GetGameObjectId
local NULL_ID=GameObject.NULL_ID
local SendCommand=GameObject.SendCommand
local lastAppearTime=0
local TimerStart=GkEventTimerManager.Start
local TimerStop=GkEventTimerManager.Stop
local IsTimerActive=GkEventTimerManager.IsTimerActive

--STATE
local numFultonedThisMap=0
local numDownedThisEvent=0
local clearLimit=4
this.parasitePos=nil

this.parasiteAttackedCount=0--tex mbqf hostage parasites
this.forceEvent=false

--TUNE
local triggerAttackCount=45--tex mbqf hostage parasites

local PARASITE_PARAMETERS={
  NORMAL={--10020
    sightDistance = 20,
    sightVertical = 36.0,
    sightHorizontal = 48.0,
  },
  HARD = {
    sightDistance = 30,
    sightVertical = 55.0,
    sightHorizontal = 48.0,
  },
}

--10090
--local PARASITE_PARAMETERS={
--  NORMAL = {
--    sightDistance         = 25,
--    sightDistanceCombat       = 75,
--
--    sightHorizontal         = 60,
--    noiseRate           = 8,
--    avoidSideMin          = 8,
--    avoidSideMax          = 12,
--    areaCombatBattleRange     = 50,
--    areaCombatBattleToSearchTime  = 1,
--    areaCombatLostSearchRange   = 1000,
--    areaCombatLostToGuardTime   = 120,
--
--    throwRecastTime         = 10,
--  },
--
--  EXTREME={
--    sightDistance         = 25,
--    sightDistanceCombat       = 100,
--
--    sightHorizontal         = 100,
--    noiseRate           = 10,
--    avoidSideMin          = 8,
--    avoidSideMax          = 12,
--    areaCombatBattleRange     = 50,
--    areaCombatBattleToSearchTime  = 1,
--    areaCombatLostSearchRange   = 1000,
--    areaCombatLostToGuardTime   = 60,
--
--    throwRecastTime         = 10,
--  },
--}

local PARASITE_GRADE = {
  NORMAL = {
    defenseValueMain = 4000,
    defenseValueArmor = 7000,
    defenseValueWall = 8000,
    offenseGrade = 2,
    defenseGrade = 7,
  },
  HARD = {
    defenseValueMain = 4000,
    defenseValueArmor = 8400,
    defenseValueWall = 9600,
    offenseGrade = 5,
    defenseGrade = 7,
  },
}

--seconds
local monitorRate=15
local parasiteAppearTimeMin=5
local parasiteAppearTimeMax=15

local playerRange=175
local escapeDistance=250
--distsqr
playerRange=playerRange*playerRange
escapeDistance=escapeDistance*escapeDistance

local spawnRadius=40

local cpZombieLife=300
local cpZombieStamina=200


this.parasiteNames={
  "Parasite0",
  "Parasite1",
  "Parasite2",
  "Parasite3",
}

function this.ParasiteEventEnabled()
  if (Ivars.enableParasiteEvent:Is(1) or this.forceEvent) and (Ivars.enableParasiteEvent:MissionCheck() or vars.missionCode==30250) then
    return true
  end
  return false
end


function this.SetupParasites()
  local parameters=PARASITE_PARAMETERS.NORMAL
  local combatGrade=PARASITE_GRADE.NORMAL
  GameObject.SendCommand({type="TppParasite2"},{id="SetParameters",params=parameters})
  GameObject.SendCommand(
    {type="TppParasite2"},
    {
      id="SetCombatGrade",
      defenseValueMain=combatGrade.defenseValueMain,
      defenseValueArmor=combatGrade.defenseValueArmor,
      defenseValueWall=combatGrade.defenseValueWall,
      offenseGrade=combatGrade.offenseGrade,
      defenseGrade=combatGrade.defenseGrade,
    }
  )
end

function this.OnDamage(gameId,attackId,attackerId)
  local typeIndex=GameObject.GetTypeIndex(gameId)
  --TODO
  if typeIndex==TppGameObject.GAME_OBJECT_TYPE_PARASITE2 then
    if not this.ParasiteEventEnabled() then
      return
    end
    --InfLog.DebugPrint"OnDamage para"--DEBUG
    --  if harden and not hardened then
    --    GameObject.SendCommand( { type="TppParasite2" }, { id="StartCombat",harden=true } )
    --  end
  end
end

local hostageParasites={
  "hos_wmu00_0000",
  "hos_wmu00_0001",
  "hos_wmu01_0000",
  "hos_wmu01_0001",
  "hos_wmu03_0000",
  "hos_wmu03_0001",
}
function this.OnDamageMbqfParasite(gameId,attackId,attackerId)
  if vars.missionCode~=30250 then
    return
  end
  --InfLog.DebugPrint"OnDamage"--DEBUG

  local isHostage=false
  for i,parasiteName in pairs(hostageParasites) do
    local gameId=GetGameObjectId(parasiteName)
    if gameId==gameId then
      isHostage=true
      break
    end
  end

  if isHostage then
    this.parasiteAttackedCount=this.parasiteAttackedCount+1
    --InfLog.Add("parasiteAttackedCount "..this.parasiteAttackedCount,true)--DEBUG

    if this.parasiteAttackedCount>triggerAttackCount then
      this.parasiteAttackedCount=0
      this.forceEvent=true
      this.StartEvent()
    end
  end
end

function this.OnDying(gameId)
  --InfLog.DebugPrint"OnDying para"--DEBUG
  local typeIndex=GameObject.GetTypeIndex(gameId)
  if typeIndex==TppGameObject.GAME_OBJECT_TYPE_PARASITE2 then
    if not this.ParasiteEventEnabled() then
      return
    end
    --InfLog.DebugPrint"OnDying is para"--DEBUG
    --tex in theory dont need to do this since messages is already using parasiteNames as sender
    --  for k,parasiteName in pairs(this.parasiteNames) do
    --    local gameObjectId=GameObject.GetGameObjectId(parasiteName)
    --    if gameObjectId~=nil then
    --      --isParasite=true
    --      break
    --    end
    --  end
    if clearLimit<=0 then
      InfLog.DebugPrint"WARNING: OnDying and clearLimit <= 0"--DEBUG
      return
    end
    clearLimit=clearLimit-1
    --InfLog.DebugPrint("OnDying para clearlimit post"..clearLimit)--DEBUG
    if clearLimit==0 then
      --InfLog.DebugPrint"OnDying all eliminated"--DEBUG
      this.EndEvent()
    end
  end
end

function this.OnFulton(gameId,gimmickInstance,gimmickDataSet,stafforResourceId)
  if not this.ParasiteEventEnabled() then
    return
  end

  numFultonedThisMap=numFultonedThisMap+1
  --InfLog.DebugPrint("numFultonedThisMap:"..numFultonedThisMap)--DEBUG
end

function this.FadeInOnGameStart()
  if not this.ParasiteEventEnabled() then
    return
  end

  if Ivars.enableParasiteEvent:Is(0) then
    return
  end

  if Ivars.inf_parasiteEvent:Is()>0 then
    if TppMission.IsMissionStart() then
      --InfLog.DebugPrint"mission start clear, StartEventTimer"--DEBUG
      Ivars.inf_parasiteEvent:Set(0)
      this.StartEventTimer()
    else
      --InfLog.DebugPrint"mission start ContinueEvent"--DEBUG
      this.ContinueEvent()
    end
  else
    --InfLog.DebugPrint"mission start StartEventTimer"--DEBUG
    this.StartEventTimer()
  end
end

function this.InitEvent()
  this.forceEvent=false
  this.parasiteAttackedCount=0

  if TppMission.IsMissionStart() then
    --InfLog.DebugPrint"InitEvent IsMissionStart clear"--DEBUG
    Ivars.inf_parasiteEvent:Set(0)
  end

  clearLimit=#this.parasiteNames
  numFultonedThisMap=0
  numDownedThisEvent=0

  if not this.ParasiteEventEnabled() and vars.missionCode~=30250 then
    return
  end

  this.SetupParasites()
end

local Timer_ParasiteEventStr="Timer_ParasiteEvent"
function this.StartEventTimer()
  if not this.ParasiteEventEnabled() then
    return
  end

  if Ivars.enableParasiteEvent:Is(0) then
    return
  end

  --InfLog.PCall(function()--DEBUG
  --InfLog.DebugPrint("Timer_ParasiteEvent start")--DEBUG
  local minute=60
  --local nextEventTime=10--DEBUG
  local nextEventTime=math.random(Ivars.parasitePeriod_MIN:Get()*minute,Ivars.parasitePeriod_MAX:Get()*minute)
  --InfLog.DebugPrint("Timer_ParasiteEvent start in "..nextEventTime)--DEBUG
  TimerStop(Timer_ParasiteEventStr)
  TimerStart(Timer_ParasiteEventStr,nextEventTime)
  --end)--
end

function this.StartEvent()
  if IsTimerActive(Timer_ParasiteEventStr)then
    TimerStop(Timer_ParasiteEventStr)
  end
  --InfLog.DebugPrint"Timer_ParasiteEvent hit"--DEBUG
  if numFultonedThisMap==#this.parasiteNames then
    --InfLog.DebugPrint"StartEvent elimintated all parasites, aborting"--DEBUG
    return
  end
  if numFultonedThisMap>=#this.parasiteNames then
    --InfLog.DebugPrint"StartEvent WARNING, eliminated>num parasites"--DEBUG
    return
  end

  local fogDensity=math.random(0.001,0.9)
  TppWeather.ForceRequestWeather(TppDefine.WEATHER.FOGGY,4,{fogDensity=fogDensity})

  local parasiteAppearTime=math.random(parasiteAppearTimeMin,parasiteAppearTimeMax)
  TimerStart("Timer_ParasiteAppear",parasiteAppearTime)
end

function this.ContinueEvent()
  --InfLog.DebugPrint"ContinueEvent hit"--DEBUG
  if numFultonedThisMap==#this.parasiteNames then
    --InfLog.DebugPrint"StartEvent elimintated all parasites, aborting"--DEBUG
    this.EndEvent()
    return
  end
  if numFultonedThisMap>=#this.parasiteNames then
    --InfLog.DebugPrint"StartEvent WARNING, eliminated>num parasites"--DEBUG
    this.EndEvent()
    return
  end

  local parasiteAppearTime=math.random(parasiteAppearTimeMin,parasiteAppearTimeMax)
  TimerStart("Timer_ParasiteAppear",parasiteAppearTime)
end

function this.ParasiteAppear()
  --InfLog.PCall(function()--DEBUG
  --InfLog.DebugPrint"ParasiteAppear"--DEBUG

  numDownedThisEvent=0
  lastAppearTime=Time.GetRawElapsedTimeSinceStartUp()

  local playerPosition={vars.playerPosX,vars.playerPosY,vars.playerPosZ}
  local closestPos=playerPosition

  --TODO TUNE
  local disableDamage=false
  local isHalf=false
  local msfRate=10--mb only


  local isMb=vars.missionCode==30050 or vars.missionCode==30250
  if isMb then
    for cpName,cpDefine in pairs(mvars.ene_soldierDefine)do
      for i,soldierName in ipairs(cpDefine)do
        local soldierId=GetGameObjectId("TppSoldier2",soldierName)
        if soldierId~=NULL_ID then
          local isMsf=math.random(100)<msfRate
          this.SetZombie(cpDefine[i],disableDamage,isHalf,cpZombieLife,cpZombieStamina,isMsf)

          --tex GOTCHA setfriendlycp seems to be one-way only
          local command={id="SetFriendly",enabled=false}
          SendCommand(soldierId,command)
        end
      end
    end
  else
    local closestLz,lzDistance,lzPosition=InfMain.GetClosestLz(playerPosition)
    if closestLz==nil then
      InfLog.DebugPrint"WARNING: StartEvent closestLz==nil"--DEBUG
      return
    end
    if lzPosition==nil then
      InfLog.DebugPrint"WARNING: StartEvent lzPosition==nil"--DEBUG
      return
    end

    local closestCp,cpDistance,cpPosition=InfMain.GetClosestCp(playerPosition)
    if closestCp==nil then
      InfLog.DebugPrint"WARNING: StartEvent closestCp==nil"--DEBUG
      return
    end
    if cpPosition==nil then
      InfLog.DebugPrint"WARNING: StartEvent cpPosition==nil"--DEBUG
      return
    end

    --    InfLog.DebugPrint(closestLz..":"..math.sqrt(lzDistance))--DEBUG
    --    InfLog.DebugPrint(closestCp..":"..math.sqrt(cpDistance))--DEBUG

    local lzCpDist=TppMath.FindDistance(lzPosition,cpPosition)
    local closestDist=cpDistance
    closestPos=cpPosition
    if cpDistance>lzDistance and lzCpDist>playerRange*2 then
      closestPos=lzPosition
      closestDist=lzDistance
    end

    if closestDist>playerRange then
      closestPos=playerPosition
    end

    --tex TODO doesn't cover visiting lrrp
    if closestPos==cpPosition then
      --InfLog.DebugPrint("closestPos==cpPosition")--DEBUG
      local cpDefine=mvars.ene_soldierDefine[closestCp]
      if cpDefine==nil then
        InfLog.DebugPrint("WARNING StartEvent could not find cpdefine for "..closestCp)--DEBUG
      else
        for i=1,#cpDefine do
          this.SetZombie(cpDefine[i],disableDamage,isHalf,cpZombieLife,cpZombieStamina)
        end
      end

      --tex foot lrrps
      --InfLog.DebugPrint(closestPos[1]..closestPos[2]..closestPos[3])--DEBUG

      local SetZombies=function(soldierNames,cpPosition)
        for i,soldierName in ipairs(soldierNames) do
          local gameId=GetGameObjectId("TppSoldier2",soldierName)
          if gameId~=NULL_ID then
            local soldierPosition=SendCommand(gameId,{id="GetPosition"})
            local soldierCpDistance=TppMath.FindDistance({soldierPosition:GetX(),soldierPosition:GetY(),soldierPosition:GetZ()},cpPosition)
            if soldierCpDistance<escapeDistance then
              --InfLog.DebugPrint(soldierName.." close to "..closestCp.. ", zombifying")--DEBUG
              this.SetZombie(soldierName,disableDamage,isHalf,cpZombieLife,cpZombieStamina)
            end
          end
        end
      end

      if InfMain.lrrpDefines then
        for i=1,#InfMain.lrrpDefines do
          local lrrpDefine=InfMain.lrrpDefines[i]
          if lrrpDefine.base1==closestCp or lrrpDefine.base2==closestCp then
            SetZombies(lrrpDefine.cpDefine,cpPosition)
          end
        end
      end

      --TODO VERIFY
      if mvars.ene_soldierDefine and mvars.ene_soldierDefine.quest_cp then
        SetZombies(mvars.ene_soldierDefine.quest_cp,cpPosition)
      end
    end
  end

  Ivars.inf_parasiteEvent:Set(1)
  clearLimit=#this.parasiteNames-numFultonedThisMap
  this.parasitePos=closestPos
  --InfLog.DebugPrint("clearlimit "..clearLimit)--DEBUG

  --tex after fultoning parasites don't appear, try and reset
  --doesnt work, parasite does appear, but is in fulton pose lol
  --  if numFultonedThisMap>0 then
  --    for k,parasiteName in pairs(this.parasiteNames) do
  --      local gameId=GetGameObjectId(parasiteName)
  --      if gameId~=NULL_ID then
  --        SendCommand(gameId,{id="Realize"})
  --      end
  --    end
  --  end

  SendCommand({type="TppParasite2"},{id="StartAppearance",position=Vector3(closestPos[1],closestPos[2],closestPos[3]),radius=spawnRadius})

  --tex once one parasite has been fultoned the rest will be stuck in some kind of idle ai state on next appearance
  --forcing combat bypasses this
  if numFultonedThisMap>0 then
    --InfLog.DebugPrint"Timer_ParasiteCombat start"--DEBUG
    TimerStart("Timer_ParasiteCombat",4)
  end

  TimerStart("Timer_ParasiteMonitor",monitorRate)
  this.StartEventTimer()--tex schedule next
  --end)--
end

function this.StartCombat()
  SendCommand({type="TppParasite2"},{id="StartCombat"})
end

function this.MonitorEvent()
  --  InfLog.PCall(function()--DEBUG
  --InfLog.DebugPrint"MonitorEvent"--DEBUG
  if Ivars.inf_parasiteEvent:Is(0) then
    return
  end

  if this.parasitePos==nil then
    InfLog.DebugPrint"WARNING MonitorEvent parasitePos==nil"--DEBUG
    return
  end

  local outOfRange=false
  local playerPos={vars.playerPosX,vars.playerPosY,vars.playerPosZ}
  local distSqr=TppMath.FindDistance(playerPos,this.parasitePos)
  if distSqr>escapeDistance then
    outOfRange=true
  end

  --InfLog.DebugPrint("dist:"..math.sqrt(distSqr))--DEBUG

  --tex TppParasites aparently dont support GetPosition, frustrating inconsistancy, you'd figure it would be a function of all gameobjects
  --  for k,parasiteName in pairs(this.parasiteNames) do
  --    local gameId=GetGameObjectId(parasiteName)
  --    if gameId~=NULL_ID then
  --      local parasitePos=SendCommand(gameId,{id="GetPosition"})
  --      local distSqr=TppMath.FindDistance(playerPos,{parasitePos:GetX(),parasitePos:GetY(),parasitePos:GetZ()})
  --     -- InfLog.DebugPrint(parasiteName.." dist:"..math.sqrt(distSqr))--DEBUG
  --      if distSqr<escapeDistance then
  --        outOfRange=false
  --        break
  --      end
  --    end
  --  end

  if outOfRange then
    --InfLog.DebugPrint"MonitorEvent: out of range, ending event"--DEBUG
    this.EndEvent()
    this.StartEventTimer()
  else
    TimerStart("Timer_ParasiteMonitor",monitorRate)
  end
  --end)--
end

function this.EndEvent()
  --InfLog.DebugPrint"EndEvent"--DEBUG
  this.forceEvent=false
  this.parasiteAttackedCount=0
  
  Ivars.inf_parasiteEvent:Set(0)
  TppWeather.CancelForceRequestWeather(TppDefine.WEATHER.SUNNY,7)
  SendCommand({type="TppParasite2"},{id="StartWithdrawal"})
end

function this.SetZombie(gameObjectName,disableDamage,isHalf,life,stamina,isMsf)
  isHalf=isHalf or false

  local gameObjectId=GetGameObjectId("TppSoldier2",gameObjectName)
  SendCommand(gameObjectId,{id="SetZombie",enabled=true,isHalf=isHalf,isZombieSkin=true,isHagure=true,isMsf=isMsf})
  SendCommand(gameObjectId,{id="SetMaxLife",life=life,stamina=stamina})
  SendCommand(gameObjectId,{id="SetZombieUseRoute",enabled=false})
  if disableDamage==true then
    SendCommand(gameObjectId,{id="SetDisableDamage",life=false,faint=true,sleep=true})
  end
  if isHalf then
    local ignoreFlag=0
    SendCommand(gameObjectId,{id="SetIgnoreDamageAction",flag=ignoreFlag})
  end
end

return this

-- DOBUILD: 1
-- InfMBVisit.lua
local this={}

--TUNE tex TODO: do I want to fuzz these?
local rewardOnSalutesCount=14--12 is nice if stacking since it's a division of total, but it's just a smidgen too easy for a single
local rewardOnClustersCount={
  [5]=true,
  [7]=true
}
local rewardOnVisitDaysCount=3
local revengeDecayOnVisitDaysCount=3

--STATE
local saluteClusterCounts={}
local visitedClusterCounts={}
local visitDaysCount=0

local lastSalute=0

local saluteRewards=0
local clusterRewards={}
local longVisitRewards=0
local revengeDecayCount=0

function this.ClearMoraleInfo()
  if vars.missionCode~=30050 and vars.missionCode~=30250 then
    return
  end

  for i=1,#TppDefine.CLUSTER_NAME+1 do
    saluteClusterCounts[i]=0
    visitedClusterCounts[i]=false
  end
  visitDaysCount=0

  saluteRewards=0
  for n,bool in pairs(rewardOnClustersCount) do
    clusterRewards[n]=false
  end
  longVisitRewards=0

  revengeDecayCount=0

  lastSalute=0
end

function this.PrintMoraleInfo()
  InfLog.DebugPrint("saluteRewards:"..saluteRewards)
end

function this.GetTotalSalutes()
  local total=0
  for i=1,#TppDefine.CLUSTER_NAME+1 do
    total=total+saluteClusterCounts[i]
  end
  return total
end

function this.CheckSalutes()
  --InfLog.PCall(function()--DEBUG
  if (vars.missionCode==30050 or vars.missionCode==30250) and Ivars.mbMoraleBoosts:Is(1) then
    if vars.missionCode==30250 then--PATCHUP
      rewardOnSalutesCount=6--tex not so many out there, plus they get lonely
    end

    local currentCluster=mtbs_cluster.GetCurrentClusterId()

    saluteClusterCounts[currentCluster]=saluteClusterCounts[currentCluster]+1
    local totalSalutes=this.GetTotalSalutes()
    --InfLog.DebugPrint("SaluteRaiseMorale cluster "..currentCluster.." count:"..saluteClusterCounts[currentCluster].. " total sulutes:"..totalSalutes)--DEBUG
    --InfLog.PrintInspect(saluteClusterCounts)--DEBUG

    local modTotalSalutes=totalSalutes%rewardOnSalutesCount
    --InfLog.DebugPrint("totalSalutes % rewardSalutesCount ="..modTotalSalutes)--DEBUG
    if modTotalSalutes==0 then
      saluteRewards=saluteRewards+1
      --InfLog.DebugPrint("REWARD for "..totalSalutes.." salutes")--DEBUG
      InfMenu.PrintLangId"mb_morale_visit_noticed"
    end

    local totalClustersVisited=0
    for clusterId,saluteCount in pairs(saluteClusterCounts) do
      if saluteCount>0 then
        totalClustersVisited=totalClustersVisited+1
      end
    end
    --InfLog.DebugPrint("totalClustersVisited:"..totalClustersVisited)--DEBUG
    if rewardOnClustersCount[totalClustersVisited] and clusterRewards[totalClustersVisited]==false then
      clusterRewards[totalClustersVisited]=true
      --InfLog.DebugPrint("REWARD for ".. totalClustersVisited .." clusters visited")--DEBUG
      InfMenu.PrintLangId"mb_morale_visit_noticed"
    end

    lastSalute=Time.GetRawElapsedTimeSinceStartUp()
  end
  --end)--
end

function this.CheckMoraleReward()
  local moraleBoost=0
  --tex was considering stacking, but even at the minimum 1 it's close to OP with a large staff size
  --actually with the standard morale decay, and making it take some effort to get in the first place it should be ok

  if Ivars.mbMoraleBoosts:Is(1) then
    for numClusters,reward in pairs(clusterRewards) do
      if reward then
        moraleBoost=moraleBoost+1
      end
    end

    if saluteRewards>0 then
      moraleBoost=moraleBoost+saluteRewards
    end

    if longVisitRewards>0 then
      moraleBoost=moraleBoost+longVisitRewards
    end

    --InfLog.DebugPrint("Global moral boosted by "..moraleBoost.." by visit")--DEBUG
    if moraleBoost>0 then
      InfMenu.PrintLangId"mb_morale_boosted"
      TppMotherBaseManagement.IncrementAllStaffMorale{morale=moraleBoost}
    end
  end
end

function this.GetMbVisitRevengeDecay()
  if visitDaysCount>0 then
    return revengeDecayCount
  end
  return 0
end

--mbvisit
--GOTCHA: it's a clock time that registered, so registering current + 12 hour will trigger first in 12 hours, then again in 24
--so just register current time if you want 24 from start
--REF
--lvl 1 cigar is 6 cigars of 12hr so 3 day, 1 cigar about 15-17 seconds (takes a couple of seconds anim before time actually starts accell)
--lvl 2 is 8 cigars of 24hr so 8 days, ~28 seconds realtime
--lvl 3 is 10 cigars of 36hr so 15 days ~40 seconds
function this.StartLongMbVisitClock()
  if vars.missionCode~=30050 and vars.missionCode~=30250 then
    return
  end

  visitDaysCount=0

  local currentTime=TppClock.GetTime("number")
  TppClock.RegisterClockMessage("MbVisitDay",currentTime)
end
function this.OnMbVisitDay(sender,time)
  if vars.missionCode==30050 or vars.missionCode==30250 then
    --InfLog.DebugPrint"OnMbVisitDay"--DEBUG
    visitDaysCount=visitDaysCount+1
    if visitDaysCount>0 then
      local modLongVisit=visitDaysCount%rewardOnVisitDaysCount
      if modLongVisit==0 then
        longVisitRewards=longVisitRewards+1
        InfMenu.PrintLangId"mb_morale_visit_noticed"
      end
      local modRewardDecay=visitDaysCount%revengeDecayOnVisitDaysCount
      if modRewardDecay==0 then
        revengeDecayCount=revengeDecayCount+1
        -- TODO message?
      end
    end
  else
    TppClock.UnregisterClockMessage("MbVisitDay")
  end
end

return this
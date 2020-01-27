--InfMission.lua
local this={}

this.locationInfo={}
this.missionIds={}

this.missionInfo={}

this.missionListSlotIndices={}--tex need it for OpenMissions


function this.PostModuleReload(prevModule)
  this.locationInfo=prevModule.locationInfo
  this.missionIds=prevModule.missionIds
  this.missionInfo=prevModule.missionInfo
  this.missionListSlotIndices=prevModule.missionListSlotIndices
end


--WIP
this.femaleFaceIdList={394,351,373,456,463,455,511,502}
this.maleFaceIdList={195,144,214,6,217,83,273,60,87,71,256,201,290,178,102,255,293,165,85,18,228,12,65,134,31,132,161,342,107,274,184,226,153,247,344,242,56,183,54,126,223}

local MAX_REALIZED_COUNT=EnemyFova.MAX_REALIZED_COUNT
local fovaSetupFuncs={}
function fovaSetupFuncs.basic(locationName,missionId)
  local faces={}
  local faceCounts={}

  for i,faceId in ipairs(this.maleFaceIdList)do
    if faceCounts[faceId]==nil then
      faceCounts[faceId]=2
    else
      faceCounts[faceId]=faceCounts[faceId]+1
    end
  end
  for i,faceId in ipairs(this.femaleFaceIdList)do
    if faceCounts[faceId]==nil then
      faceCounts[faceId]=2
    else
      faceCounts[faceId]=faceCounts[faceId]+1
    end
  end


  for faceId,faceCount in pairs(faceCounts)do
    table.insert(faces,{faceId,faceCount,faceCount,0})
  end
  table.insert(faces,{623,1,1,0})
  table.insert(faces,{TppEnemyFaceId.dds_balaclava2,10,10,0})
  table.insert(faces,{TppEnemyFaceId.dds_balaclava6,2,2,0})
  table.insert(faces,{TppEnemyFaceId.dds_balaclava7,2,2,0})

  local bodies={
    {146,MAX_REALIZED_COUNT},
  }
  --TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dds/ddr1_main0_def_v00.parts"}
  TppSoldierFace.OverwriteMissionFovaData{face=faces}--,body=bodies}
end

--DEBUGNOW
fovaSetupFuncs[12020]=fovaSetupFuncs.basic
fovaSetupFuncs[12050]=fovaSetupFuncs.basic

--this.locationInfo[45].locationMapParams=this.locationMapParams.MBA0--

--REF from RegisterMissionCodeList
--this.missionUiNumbers={
--  [10010]=0,
--  [10020]=1,
--  [10030]=2,
--  [10036]=3,
--  [10043]=4,
--  [10033]=5,
--  [10040]=6,
--  [10041]=7,
--  [10044]=8,
--  [10054]=9,
--  [10052]=10,
--  [10050]=11,
--  [10070]=12,
--  [10080]=13,
--  [10086]=14,
--  [10082]=15,
--  [10090]=16,
--  [10091]=17,
--  [10100]=18,
--  [10195]=19,
--  [10110]=20,
--  [10121]=21,
--  [10115]=22,
--  [10120]=23,
--  [10085]=24,
--  [10200]=25,
--  [10211]=26,
--  [10081]=27,
--  [10130]=28,
--  [10140]=29,
--  [10150]=30,
--  [10151]=31,
--  [10045]=32,
--  [11043]=33,
--  [11054]=34,
--  [10093]=35,
--  [11082]=36,
--  [11090]=37,
--  [10156]=38,
--  [11033]=39,
--  [11050]=40,
--  [10171]=41,
--  [11140]=42,
--  [10240]=43,
--  [11080]=44,
--  [10260]=45,
--  [10280]=46,
--  [11121]=47,
--  [11130]=48,
--  [11044]=49,
--  [11151]=50,
--}
--#51

--REF TppDefine.MISSION_LIST
--  "10010",--1
--  "10020",--
--  "10030",--
--  "10036",--
--  "10043",--
--  "10033",--
--  "10040",--
--  "10041",--
--  "10044",--
--  "10052",--10
--  "10054",--
--  "10050",--
--  "10070",--
--  "10080",--
--  "10086",--
--  "10082",--
--  "10090",--
--  "10195",--
--  "10091",--
--  "10100",--20
--  "10110",--
--  "10121",--
--  "10115",--
--  "10120",--
--  "10085",--
--  "10200",--
--  "10211",--
--  "10081",--
--  "10130",--
--  "10140",--30
--  "10150",--
--  "10151",--
--  "10045",--
--  "10156",--
--  "10093",--
--  "10171",--
--  "10240",--
--  "10260",--
--  "10280",--
--  "10230",--no number mission40
--  "11043",--
--  "11041",--no number mission
--  "11054",--
--  "11085",--no number mission
--  "11082",--
--  "11090",--
--  "11036",--no number mission
--  "11033",--
--  "11050",--
--  "11091",--no number mission 50
--  "11195",--no number mission
--  "11211",--no number mission
--  "11140",--
--  "11200",--no number mission
--  "11080",--
--  "11171",--no number mission
--  "11121",--
--  "11115",--no number mission
--  "11130",--
--  "11044",--60
--  "11052",--no number mission
--  "11151",--62
--#62

this.highestUiMission=50--tex vanilla

function this.LoadLocationDefs()
  local missionFiles=InfCore.GetFileList(InfCore.files.locations,".lua")
  for i,fileName in ipairs(missionFiles)do
    InfCore.Log("InfMission.LoadLocationsDefs: "..fileName)

    local locationInfo=InfCore.LoadSimpleModule(InfCore.paths.locations,fileName)
    if locationInfo then
      local locationId=locationInfo.locationId
      if not locationId then
        InfCore.Log("WARNING: could not find missionCode on "..fileName)
      else
        if this.locationInfo[locationId] then
          InfCore.Log("Existing locationInfo already found for "..locationId)
        end
        this.locationInfo[locationId]=locationInfo
      end
    end
  end
end

function this.LoadMissionDefs()
  local missionFiles=InfCore.GetFileList(InfCore.files.missions,".lua")
  for i,fileName in ipairs(missionFiles)do
    InfCore.Log("InfMission.LoadMissionDefs: "..fileName)

    local missionInfo=InfCore.LoadSimpleModule(InfCore.paths.missions,fileName)
    if missionInfo then
      local missionCode=missionInfo.missionCode
      if not missionCode then
        InfCore.Log("WARNING: could not find missionCode on "..fileName)
      else
        if this.missionInfo[missionCode] then
          InfCore.Log("Existing missionInfo already found for "..missionCode)
        end
        this.missionInfo[missionCode]=missionInfo
      end
    end
  end
end

function this.SetupMissions()
  InfCore.LogFlow("InfMission.SetupMissions")

  this.LoadLocationDefs()
  this.LoadMissionDefs()

  --tex add in locations
  for locationId,locationInfo in pairs(this.locationInfo)do
    local locationName=locationInfo.locationName
    if not locationName then
      InfCore.Log("WARNING: Could nof find locationName for "..locationId)
    else
      InfCore.Log("Adding location: "..locationName.." "..locationId)
      if TppDefine.LOCATION_ID[locationName] then
        InfCore.Log("WARNING: location already defined "..locationId)
      end
      TppDefine.LOCATION_ID[locationName]=locationId
      TppMissionList.locationPackTable[locationId]=locationInfo.packs
    end
  end

  for locationId,locationInfo in pairs(this.locationInfo)do
    local locationName=locationInfo.locationName
    if  locationName then
      InfUtil.locationIdForName[string.lower(locationName)]=locationId
    end
  end
  for locationName,locationId in pairs(InfUtil.locationIdForName)do
    InfUtil.locationNames[locationId]=locationName
  end

  TppLocation.GetLocationName=InfUtil.GetLocationName--tex replace the vanilla function with IHs

  --tex add in missions
  for missionCode,missionInfo in pairs(this.missionInfo)do
    InfCore.Log("Adding mission "..missionCode)

    TppMissionList.missionPackTable[missionCode]=missionInfo.packs

    local locationMissions=TppDefine.LOCATION_HAVE_MISSION_LIST[missionInfo.location] or {}
    local hasMission=false
    for i,_missionCode in ipairs(locationMissions)do
      if _missionCode==missionCode then
        hasMission=true
        break
      end
    end
    if not hasMission then
      table.insert(locationMissions,missionCode)
    end
    TppDefine.LOCATION_HAVE_MISSION_LIST[missionInfo.location]=locationMissions

    TppDefine.NO_HELICOPTER_MISSION_START_POSITION[missionCode]=missionInfo.startPos
  end


  --tex TODO: add to (but allow via a param)
  --tex indicates that theres no free roam mission box start
  --  TppDefine.NO_ORDER_BOX_MISSION_LIST
  --  TppDefine.NO_ORDER_BOX_MISSION_ENUM=TppDefine.Enum(TppDefine.NO_ORDER_BOX_MISSION_LIST)

  --tex TODO: add to (but allow via a param)
  --TppDefine.NO_HELICOPTER_ROUTE_MISSION_LIST
  --TppDefine.NO_HELICOPTER_ROUTE_ENUM=TppDefine.Enum(TppDefine.NO_HELICOPTER_ROUTE_MISSION_LIST)

  --tex TODO:
  --TppMission.MISSION_GUARANTEE_GMP
  --TppMission.MISSION_TASK_LIST

  --tex TODO:
  --TppTerminal.noAddVolunteerMissions

  --tex TODO:
  --mbdvc_map_mission_parameter.GetMissionParameter, probably will have to do same as GetMapLocationParameter



  --DEBUGNOW TODO: add from missionInfo
  for missionCode,fovaFunc in pairs(fovaSetupFuncs) do
    if type(missionCode)=="number" then
      TppEneFova.fovaSetupFuncs[missionCode]=fovaFunc
    end
  end

  this.missionIds={}
  for missionCode,missionInfo in pairs(this.missionInfo)do
    table.insert(this.missionIds,missionCode)
  end
  table.sort(this.missionIds)

  --tex WORKAROUND exe/ui seems to have same limit as TppDefine.MISSION_COUNT_MAX
  --but there's issues with mission completed rank not matching and seeminly no lua>ui was to set it
  --unlike the rest of the information via Mission.RegisterMissionCodeList, the gmp and task completion via TppResult.GetMbMissionListParameterTable
  --so am reusing the MISSING_NUMBER_MISSION_LIST which is flyk and some uncompleted exreme/subsidence of other missions
  --plus the 2 actual free missionlist slots
  this.missionListSlotIndices={}--tex need it for OpenMissions
  for i,missionCodeStr in ipairs(TppDefine.MISSING_NUMBER_MISSION_LIST)do
    local missionIndex=TppDefine.MISSION_ENUM[missionCodeStr]+1
    table.insert(this.missionListSlotIndices,missionIndex)
  end
  for i=#TppDefine.MISSION_LIST+1,TppDefine.MISSION_COUNT_MAX do
    table.insert(this.missionListSlotIndices,i)
  end
  table.sort(this.missionListSlotIndices)
  local numFreeMissions=TppDefine.MISSION_COUNT_MAX-#TppDefine.MISSION_LIST

  if this.debugModule then
    InfCore.Log("numFreeMissions="..numFreeMissions)
    InfCore.PrintInspect(this.missionListSlotIndices,"missionListSlotIndices")
    InfCore.PrintInspect(TppDefine.MISSION_LIST,"missionlist vanill")
  end

  local freeSlot=0
  for i,missionCode in ipairs(this.missionIds)do
    if freeSlot==#this.missionListSlotIndices then
      InfCore.Log("WARNING: No free MISSION_LIST slots")
      break
    else
      local missionIndex=this.missionListSlotIndices[freeSlot+1]
      freeSlot=freeSlot+1
      TppDefine.MISSION_LIST[missionIndex]=tostring(missionCode)
    end
  end
  TppDefine.MISSION_ENUM=TppDefine.Enum(TppDefine.MISSION_LIST)

  if this.debugModule then
    InfCore.PrintInspect(TppDefine.MISSION_LIST,"missionlist modded")
    InfCore.PrintInspect(#TppDefine.MISSION_LIST,"#missionlist")
  end

  local highestMissionNum=this.highestUiMission
  for i,missionCode in ipairs(this.missionIds)do
    highestMissionNum=highestMissionNum+1
    InfCore.Log("RegistMissionEpisodeNo("..missionCode..","..highestMissionNum..")")
    TppUiCommand.RegistMissionEpisodeNo(missionCode,highestMissionNum)
  end

  --DEBUGNOW exp
  --  local uiMissionList={}
  --  local max=40
  --  for i,missionCodeStr in ipairs(TppDefine.MISSION_LIST)do
  --    if i<max or this.missionInfo[tonumber(missionCodeStr)] then
  --      --if not TppDefine.MISSING_NUMBER_MISSION_ENUM[missionCodeStr] then
  --      --if this.missionInfo[tonumber(missionCodeStr)] then
  --      uiMissionList[#uiMissionList+1]=missionCodeStr
  --    end
  --  end
  --  --Mission.RegisterMissionCodeList{codeList=uiMissionList}--

  Mission.RegisterMissionCodeList{codeList=TppDefine.MISSION_LIST}

  if this.debugModule then
    InfCore.PrintInspect(this.locationInfo,"locationInfo")
    InfCore.PrintInspect(this.missionInfo,"missionInfo")
    InfCore.PrintInspect(TppMissionList.locationPackTable,"TppMissionList.locationPackTable")
    InfCore.PrintInspect(TppMissionList.missionPackTable,"TppMissionList.missionPackTable")
    InfCore.PrintInspect(TppDefine.LOCATION_ID,"TppDefine.LOCATION_ID")
    InfCore.PrintInspect(TppDefine.LOCATION_HAVE_MISSION_LIST,"TppDefine.LOCATION_HAVE_MISSION_LIST")
    InfCore.PrintInspect(TppDefine.NO_HELICOPTER_MISSION_START_POSITION,"TppDefine.NO_HELICOPTER_MISSION_START_POSITION")
    --InfCore.PrintInspect(mbdvc_map_location_parameter,"mbdvc_map_location_parameter")
  end
end

--tex cant patch in to script since it seems mbdvc_map_location_parameter is torn down/reloaded so instead called from mbdvc_map_location_parameter
function this.GetMapLocationParameter(locationId)
  local locationInfo=this.locationInfo[locationId]
  if locationInfo then
    return locationInfo.locationMapParams
  end
end

--CALLER: mbdvc_map_mission_parameter.GetMissionParameter
function this.GetMapMissionParameter(missionCode)
  --TODO mgo style map param for location
  --TODO see if mgo map params are useful
  local missionInfo=this.missionInfo[missionCode]
  if missionInfo then
    return missionInfo.missionMapParams
  end
end

--CALLER: TppStory.UpdateStorySequence
function this.OpenMissions()
  InfCore.LogFlow("InfMission.OpenMissions")
  
  --tex close all missing number missions and > vanilla missions first so its ok if user uninstalls mission
  for i,missionListIndex in ipairs(this.missionListSlotIndices)do
    InfCore.Log("Clearing "..missionListIndex)
    gvars.str_missionOpenPermission[missionListIndex-1]=false
    gvars.str_missionOpenFlag[missionListIndex-1]=false
    gvars.str_missionNewOpenFlag[missionListIndex-1]=false
    gvars.str_missionClearedFlag[missionListIndex-1]=false
  end
  
  --tex TODO: save/restore mission flags

  for i,missionCode in ipairs(this.missionIds)do
    InfCore.Log("Opening "..missionCode)
    TppStory.PermitMissionOpen(missionCode)
    TppStory.SetMissionOpenFlag(missionCode,true)
    --TppStory.MissionOpen(missionCode)
  end
end

--CALLER: TppTerminal.ReleaseFreePlay
function this.EnableLocationChangeMissions()
--  TppUiCommand.EnableChangeLocationMenu{locationId=45,missionId=12000}
end

--from TppResult. , currently conflict with Anyones Improvements
--OFF
function this.GetMbMissionListParameterTable()
  InfCore.LogFlow("InfMission.GetMbMissionListParameterTable")--tex DEBUG
  local missionListParameterTable={}
  for missionCodeStr,enum in pairs(TppDefine.MISSION_ENUM)do
    local missionCode=tonumber(missionCodeStr)
    local missionParameters={}
    missionParameters.missionId=missionCode
    if this.MISSION_GUARANTEE_GMP[missionCode]then
      missionParameters.baseGmp=101--DEBUGNOWthis.MISSION_GUARANTEE_GMP[missionCode]
      missionParameters.currentGmp=101--DEBUGNOW this.GetMissionGuaranteeGMP(missionCode)
    end
    if this.MISSION_TASK_LIST[missionCode]then
      missionParameters.completedTaskNum=TppUI.GetTaskCompletedNumber(missionCode)
      missionParameters.maxTaskNum=#this.MISSION_TASK_LIST[missionCode]
      missionParameters.taskList=this.MISSION_TASK_LIST[missionCode]
    end
    local isMissingNumberMission=TppDefine.MISSING_NUMBER_MISSION_ENUM[missionCodeStr]--tex --DEBUGNOW
    if isMissingNumberMission then--DEBUGNOW
      InfCore.Log("---------- GetMbMissionListParameterTable "..missionCodeStr)
    end--DEBUGNOW
    if not isMissingNumberMission then--tex added skip
      table.insert(missionListParameterTable,missionParameters)
    end
  end
  return missionListParameterTable
end

--
function this.Init(missionTable)
  --  if TppUiCommand.RegisterMbMissionListFunction then
  --    if TppUiCommand.IsTppUiReady()then
  --    --TppUiCommand.RegisterMbMissionListFunction("InfMission","GetMbMissionListParameterTable")
  --    end
  --  end

  --tex TODO figure out zone system
  if this.missionInfo[vars.missionCode] then
    --tex in tppmission.init
    mvars.mis_isAlertOutOfMissionArea=false
    
    --tex in tppui init
    TppUiCommand.HideInnerZone() 
    TppUiCommand.HideOuterZone()
  end
end

return this

-- Ivars.lua
--tex Ivar system
--Property system used by IH menu and code to provide modifyable and savable settings.
--Ivars can be defined in other IH modules and their names added to <module>.registerIvars, these will actually be built in to the Ivars module.

--workings:
--combines gvar setup, enums, functions per setting in one ungodly mess.
--lots of shortcuts/ivar setup depending-on defined values is done in SetupIvars
--Ivars as a whole are actually split across several modules/tables
--this module is mostly defintion of the bounds, settings and functions to run on changing Ivar state
--the working state/value of an Ivar is in the global ivar table, with save values in either gvars (the game save system) or evars (IHs save system)
--the IvarProc module ties together the Ivar definitions and their live state in igvars{} (global) via utility functions
--save values are split out to evars{} (global), this mirrors the prior setup of ivar/gvar pair split and is currently mostly to allow ivars to be temporarily disconnected from their
--saved state as in ih events

--NOTE: Resetsettings will call OnChange, so/and make sure defaults are actual default game behaviour,
--in general this means all stuff should have a 0 that at least does nothing,
--dont let the lure of nice straight setting>game value lure you, just -1 it
local this={}

this.debugModule=true--DEBUGNOW

--LOCALOPT:
local Ivars=this
local InfCore=InfCore

local NULL_ID=GameObject.NULL_ID
local GetGameObjectId=GameObject.GetGameObjectId
local SendCommand=GameObject.SendCommand

local GLOBAL=TppScriptVars.CATEGORY_GAME_GLOBAL
local MISSION=TppScriptVars.CATEGORY_MISSION
local RETRY=TppScriptVars.CATEGORY_RETRY
local MB_MANAGEMENT=TppScriptVars.CATEGORY_MB_MANAGEMENT
local QUEST=TppScriptVars.CATEGORY_QUEST
local CONFIG=TppScriptVars.CATEGORY_CONFIG
local RESTARTABLE=TppScriptVars.CATEGORY_MISSION_RESTARTABLE
local PERSONAL=TppScriptVars.CATEGORY_PERSONAL

local EXTERNAL=IvarProc.CATEGORY_EXTERNAL

--tex set via IvarsProc.MissionModeIvars, used by IsForMission,EnabledForMission
this.missionModeIvarsNames={}
this.missionModeIvars={}

this.profiles={}
--
local int8=256
local int16=2^16
local int32=2^32

this.MAX_SOLDIER_STATE_COUNT = 360--tex from <mission>_enemy.lua, free missions/whatever was highest

this.switchRange={max=1,min=0,increment=1}

this.switchSettings={"OFF","ON"}
this.simpleProfileSettings={"DEFAULT","CUSTOM"}
--

--ivar definitions
--tex NOTE: should be mindful of max setting for save vars,
--currently the ivar setup fits to the nearest save size type and I'm not sure of behaviour when you change ivars max enough to have it shift save size and load a game with an already saved var of different size

this.debugMode={
  inMission=true,
  nonConfig=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
  -- CULL settings={"OFF","NORMAL","BLANK_LOADING_SCREEN"},
  allowFob=true,
  OnChange=function(self,prevStting,setting)
    InfMain.DebugModeEnable(setting==1)
  end,
}

this.debugMessages={
  inMission=true,
  nonConfig=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
}

this.debugFlow={
  inMission=true,
  nonConfig=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
}

this.debugOnUpdate={
  inMission=true,
  nonConfig=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
  OnChange=function(self,prevStting,setting)
    InfCore.debugOnUpdate=setting==1
  end,
}

this.enableIHExt={
  inMission=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
  OnSelect=function(self)
    if not InfCore.IHExtInstalled() then
      self.settingNames="ihext_not_installed_settings"
    end
  end,
  PreChange=function(self,prevSetting,setting)
    if setting==0 then
      if InfCore.extSession==0 then
      else
        InfCore.ExtCmd("Shutdown")
      end
    end
  end,
  OnChange=function(self,prevSetting,setting)
    if setting==1 then
      --tex extSession 0 should catch this without
      --      if not InfCore.IHExtInstalled() then
      --        --InfCore.Log("WARNING: could not find IHExt.exe")
      --        self:Set(0)
      --        return
      --      end

      --if InfCore.extSession==0 then
      InfCore.StartIHExt()
      InfMenu.MenuOff()--tex stuff is only triggered on menu on
      InfCore.manualIHExtStart=true
      --else
      --InfCore.ExtCmd("shutdown")--DEBUGNOW TODO wont actually fire since ExtCmd aborts on enableIHExt off
      --end
    end
  end,
}

this.enableHelp={
  inMission=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
}

this.printPressedButtons={
  inMission=true,
  range=Ivars.switchRange,
  settingNames="set_switch",
}

this.printOnBlockChange={
  inMission=true,
  range=Ivars.switchRange,
  settingNames="set_switch",
}

--motherbase>


--patchup
this.langOverride={
  inMission=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  allowFob=true,
}

this.startOffline={
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
}

this.skipLogos={
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
}

this.enableQuickMenu={
  inMission=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  range=Ivars.switchRange,
  settingNames="set_switch",
}
--
this.manualMissionCode={
  inMission=true,
  --OFF save=IvarProc.CATEGORY_EXTERNAL,
  settings={
    --LOC,TYPE,Notes
    --    "1",--INIT
    --    "5",--TITLE
    --storyMissions
    "10010",--CYPR
    "10020",
    "10030",
    "10036",
    "10043",
    "10033",
    "10040",
    "10041",
    "10044",
    "10052",
    "10054",
    "10050",
    "10070",
    "10080",
    "10086",
    "10082",
    "10090",
    "10195",
    "10091",
    "10100",
    "10110",
    "10121",
    "10115",
    "10120",
    "10085",
    "10200",
    "10211",
    "10081",
    "10130",
    "10140",
    "10150",
    "10151",
    "10045",
    "10156",
    "10093",
    "10171",
    "10240",
    "10260",
    "10280",--CYPR
    --hard missions
    "11043",
    "11041",--missingno
    "11054",
    "11085",--missingno
    "11082",
    "11090",
    "11036",--missingno
    "11033",
    "11050",
    "11091",--missingno
    "11195",--missingno
    "11211",--missingno
    "11140",
    "11200",--missingno
    "11080",
    "11171",--missingno
    "11121",
    "11115",--missingno
    "11130",
    "11044",
    "11052",--missingno
    "11151",
    --
    --"10230",--FLYK,missing completely, chap 3, no load
    --in PLAY_DEMO_END_MISSION, no other refs
    --    "11070",
    --    "11100",
    --    "11110",
    --    "11150",
    --    "11240",
    --    "11260",
    --    "11280",
    --    "11230",
    --free mission
    "30010",--AFGH,FREE
    "30020",--MAFR,FREE
    "30050",--MTBS,FREE
    "30150",--MTBS,MTBS_ZOO,FREE
    "30250",--MBQF,MBTS_WARD,FREE
    --heli space
    "40010",--AFGH,AFGH_HELI,HLSP
    "40020",--MAFR,MAFR_HELI,HLSP
    "40050",--MTBS
  --"40060",--HLSP,HELI_SPACE,--no load
  --online
  --"50050",--MTBS,FOB
  --select??
  --"60000",--SELECT --6e4
  --show demonstrations (not demos lol)
  --    "65020",--AFGH,e3_2014
  --    "65030",--MTBS,e3_2014
  --    "65050",--MAFR??,e3_2014
  --    "65060",--MAFR,tgs_2014
  --    "65414",--gc_2014
  --    "65415",--tgs_2014
  --    "65416",--tgs_2014
  },
  OnActivate=function(self,setting)
    local settingStr=self.settings[setting+1]
    local missionCode=tonumber(settingStr)
    InfCore.Log("manualMissionCode "..settingStr)

    local loadDirect=false

    --TppMission.Load( tonumber(settingStr), vars.missionCode, { showLoadingTips = false } )
    --TppMission.RequestLoad(tonumber(settingStr),vars.missionCode,{force=true,showLoadingTips=true})--,ignoreMtbsLoadLocationForce=mvars.mis_ignoreMtbsLoadLocationForce})
    --TppMission.RequestLoad(10036,vars.missionCode,{force=true,showLoadingTips=true})--,ignoreMtbsLoadLocationForce=mvars.mis_ignoreMtbsLoadLocationForce})
    if loadDirect then
      gvars.mis_nextMissionCodeForMissionClear=missionCode
      mvars.mis_showLoadingTipsOnMissionFinalize=false
      --mvars.heli_missionStartRoute
      --mvars.mis_nextLayoutCode
      --mvars.mis_nextClusterId
      --mvars.mis_ignoreMtbsLoadLocationForce

      TppMission.ExecuteMissionFinalize()
    else
      TppMission.ReserveMissionClear{
        missionClearType=TppDefine.MISSION_CLEAR_TYPE.FROM_HELISPACE,
        nextMissionId=missionCode,
      }
    end
  end,
}

--AFGH={10020,10033,10034,10036,10040,10041,10043,10044,10045,10050,10052,10054,10060,10070,10150,10151,10153,10156,10164,10199,10260,,,
--11036,11043,11041,11033,11050,11054,11044,11052,11151},
--MAFR={10080,10081,10082,10085,10086,10090,10091,10093,10100,10110,10120,10121,10130,10140,10154,10160,10162,10171,10200,10195,10211,,,
--11085,11082,11090,11091,11195,11211,11140,11200,11080,11171,11121,11130},
--MTBS={10030,10115,11115,10240},

this.manualSequence={
  inMission=true,
  --save=IvarProc.CATEGORY_EXTERNAL,
  range={max=1},--DYNAMIC
  OnSelect=function(self)
    self.settingNames={}
    --tex also mvars.seq_demoSequneceList (a subset)
    for sequenceName,enum in pairs(mvars.seq_sequenceNames)do
      self.settingNames[enum]=sequenceName
    end
    --InfCore.PrintInspect(self.settingNames)--DEBUG
    self.range.max=#self.settingNames-1
  end,
  OnActivate=function(self,setting)
    local settingStr=self.settingNames[setting+1]
    --InfCore.DebugPrint(tostring(settingStr))--DEBUG
    TppSequence.SetNextSequence(settingStr)
  end,
}

this.loadAddonMission={
  --OFF save=IvarProc.CATEGORY_EXTERNAL,
  settings={},
  OnSelect=function(self)
    self.settings={}
    for i,missionCode in pairs(InfMission.missionIds)do
      self.settings[#self.settings+1]=tostring(missionCode)
    end
    self.range.max=#self.settings-1
    self.settingNames=self.settings
  end,
  GetSettingText=function(self,setting)
    if #self.settings==0 then
      return "No addon missions installed"--DEBUGNOW TODO langid
    end

    local settingStr=self.settings[setting+1]
    local missionCode=tonumber(settingStr)
    local missionInfo=InfMission.missionInfo[missionCode]
    if missionInfo then
      return missionInfo.description or settingStr--DEBUGNOW
    else
      return "No missionInfo for "..settingStr --DEBUGNOW TODO langid
    end
  end,
  OnActivate=function(self,setting)
    if #self.settings==0 then
      return
    end

    local settingStr=self.settings[setting+1]
    local missionCode=tonumber(settingStr)
    InfCore.Log("manualMissionCode "..settingStr)

    local loadDirect=false

    --TppMission.Load( tonumber(settingStr), vars.missionCode, { showLoadingTips = false } )
    --TppMission.RequestLoad(tonumber(settingStr),vars.missionCode,{force=true,showLoadingTips=true})--,ignoreMtbsLoadLocationForce=mvars.mis_ignoreMtbsLoadLocationForce})
    --TppMission.RequestLoad(10036,vars.missionCode,{force=true,showLoadingTips=true})--,ignoreMtbsLoadLocationForce=mvars.mis_ignoreMtbsLoadLocationForce})
    if loadDirect then
      gvars.mis_nextMissionCodeForMissionClear=missionCode
      mvars.mis_showLoadingTipsOnMissionFinalize=false
      --mvars.heli_missionStartRoute
      --mvars.mis_nextLayoutCode
      --mvars.mis_nextClusterId
      --mvars.mis_ignoreMtbsLoadLocationForce

      TppMission.ExecuteMissionFinalize()
    else
      TppMission.ReserveMissionClear{
        missionClearType=TppDefine.MISSION_CLEAR_TYPE.FROM_HELISPACE,
        nextMissionId=missionCode,
      }
    end
  end,
}

this.selectedCp={
  inMission=true,
  nonConfig=true,
  --save=IvarProc.CATEGORY_EXTERNAL,
  range={max=1},--DYNAMIC
  prev=nil,--STATE
  OnSelect=function(self,setting)
    if not mvars.ene_cpList then
      self:Set(0)
      return
    end

    if not mvars.ene_cpList[setting] then
      self:Set(0)
    end

    self.range.max=#mvars.ene_cpList
  end,
  GetNext=function(self,currentSetting)
    self.prev=self.setting
    if mvars.ene_cpList==nil then
      InfCore.DebugPrint"mvars.ene_cpList==nil"--DEBUG
      return 0
    end--

    local nextSetting=currentSetting
    if currentSetting==0 then
      nextSetting=next(mvars.ene_cpList)
    else
      nextSetting=next(mvars.ene_cpList,currentSetting)
    end
    if nextSetting==nil then
      --InfCore.DebugPrint"self setting==nil"--DEBUG
      nextSetting=next(mvars.ene_cpList)
    end
    return nextSetting
  end,
  GetPrev=function(self,currentSetting)
    local nextSetting=currentSetting
    if self.prev~=nil then
      nextSetting=self.prev
      self.prev=nil
    else
      nextSetting=next(mvars.ene_cpList)--tex go back to start
    end
    return nextSetting
  end,
  GetSettingText=function(self,setting)
    if setting==nil then
      return "nil"
    end
    if self.setting==0 then
      return "none"
    end
    return mvars.ene_cpList and mvars.ene_cpList[setting] or "no cp for setting"
  end,
}

--
this.dropLoadedEquip={--WIP
  inMission=true,
  nonConfig=true,
  --OFF save=IvarProc.CATEGORY_EXTERNAL,
  range={max=1,min=1},--tex DYNAMIC
  OnSelect=function(self)
    self.settingsTable={}
    for equipId,bool in pairs(InfEquip.currentLoadTable)do
      self.settingsTable[#self.settingsTable+1]=equipId
    end
    self.range.max=#self.settingsTable
    if self.range.max==0 then
      self.range.max=1
    end
  end,
  GetSettingText=function(self,setting)
    local equipId=self.settingsTable[setting]
    local equipName=InfLookup.TppEquip.equipId[equipId]
    return tostring(equipName)
  end,
  OnActivate=function(self,setting)
    local equipId=self.settingsTable[setting]
    local equipName=InfLookup.TppEquip.equipId[equipId]
    if equipId==nil then
      InfCore.DebugPrint("no equipId found for "..equipName)
      return
    else
      InfCore.DebugPrint("drop "..equipName)
      local dropPosition=Vector3(vars.playerPosX,vars.playerPosY+1,vars.playerPosZ)

      local linearMax=2
      local angularMax=14

      local number=100

      TppPickable.DropItem{
        equipId=equipId,
        number=number,
        position=dropPosition,
        rotation=Quat.RotationY(0),
        linearVelocity=Vector3(math.random(-linearMax,linearMax),math.random(-linearMax,linearMax),math.random(-linearMax,linearMax)),
        angularVelocity=Vector3(math.random(-angularMax,angularMax),math.random(-angularMax,angularMax),math.random(-angularMax,angularMax)),
      }
    end
  end,
}

this.dropTestEquip={--WIP
  inMission=true,
  nonConfig=true,
  --OFF save=IvarProc.CATEGORY_EXTERNAL,
  range={max=1,min=1},--tex DYNAMIC
  OnSelect=function(self)
    self.range.max=#InfEquip.tppEquipTableTest
    if self.range.max==0 then
      self.range.max=1
    end
  end,
  GetSettingText=function(self,setting)
    return tostring(InfEquip.tppEquipTableTest[setting])
  end,
  OnActivate=function(self,setting)
    local equipName=InfEquip.tppEquipTableTest[setting]
    local equipId=TppEquip[equipName]
    if equipId==nil then
      InfCore.DebugPrint("no equipId found for "..equipName)
      return
    else
      --      InfCore.DebugPrint("set "..equipName)
      --      Player.ChangeEquip{
      --        equipId = equipId,
      --        stock = 30,
      --        stockSub = 30,
      --        ammo = 30,
      --        ammoSub = 30,
      --        suppressorLife = 100,
      --        isSuppressorOn = true,
      --        isLightOn = false,
      --        dropPrevEquip = true,
      --      -- toActive = true,
      --      }
      --    end

      --      Player.ChangeEquip{
      --        equipId = equipId,
      --        stock = 30,
      --        stockSub = 0,
      --        ammo = 30,
      --        ammoSub = 0,
      --        suppressorLife = 0,
      --        isSuppressorOn = false,
      --        isLightOn = false,
      --        toActive = false,
      --        dropPrevEquip = false,
      --        temporaryChange = true,
      --      }

      InfCore.DebugPrint("drop "..equipName)
      local dropPosition=Vector3(vars.playerPosX,vars.playerPosY+1,vars.playerPosZ)

      local linearMax=2
      local angularMax=14

      local number=100

      TppPickable.DropItem{
        equipId=equipId,
        number=number,
        position=dropPosition,
        rotation=Quat.RotationY(0),
        linearVelocity=Vector3(math.random(-linearMax,linearMax),math.random(-linearMax,linearMax),math.random(-linearMax,linearMax)),
        angularVelocity=Vector3(math.random(-angularMax,angularMax),math.random(-angularMax,angularMax),math.random(-angularMax,angularMax)),
      }
    end
  end,
}

this.selectedGameObjectType={
  inMission=true,
  nonConfig=true,
  --save=IvarProc.CATEGORY_EXTERNAL,
  range={max=1},--DYNAMIC (not currently, TODO)
  OnSelect=function(self)
    self.range.max=#InfLookup.gameObjectClass-1
  end,
  GetSettingText=function(self,setting)
    return InfLookup.gameObjectClass[setting+1]
  end,
}

this.selectProfile={
  nonConfig=true,
  --save=IvarProc.CATEGORY_EXTERNAL,
  range={min=0,max=0},--DYNAMIC
  GetSettingText=function(self,setting)
    if Ivars.profiles==nil or self.settings==nil then
      return InfMenu.LangString"no_profiles_installed"
    else
      local profileName=self.settings[setting+1]
      local profileInfo=Ivars.profiles[profileName]
      return profileInfo.description or profileName
    end
  end,
  OnSelect=function(self)
    local profileNames=Ivars.profileNames
    if profileNames then
      self.range.max=#profileNames-1
      self.settings=profileNames
    else
      self.range.max=0
      ivars[self.name]=0
    end
  end,
  OnActivate=function(self,setting)
    if self.settings==nil then
      InfMenu.PrintLangId"no_profiles_installed"
    end

    local profileName=self.settings[setting+1]
    local profileInfo=Ivars.profiles[profileName]
    --local profileDescription=profileInfo.description or profileName
    InfMenu.PrintLangId"applying_profile"
    IvarProc.ApplyProfile(profileInfo.profile)
  end,
  GetProfileInfo=function(self)
    if not Ivars.profiles or self.settings==nil then
      return nil
    else
      local profileName=self:GetTableSetting()
      return Ivars.profiles[profileName]
    end
  end,
}

this.warpToListObject={
  inMission=true,
  range={max=1},--DYNAMIC
  GetSettingText=function(self,setting)
    local objectName,info,position=InfLookup.GetObjectInfoOrPos(setting+1)
    if info and not position then
      return info
    end

    return objectName.." pos:".. math.ceil(position[1])..",".. math.ceil(position[2]).. ","..math.ceil(position[3])
  end,
  OnSelect=function(self)
    local objectList=InfLookup.GetObjectList()
    self.range.max=#objectList-1
    self.setting=0
  end,
  OnActivate=function(self,setting)
    local objectName,info,position=InfLookup.GetObjectInfoOrPos(setting+1)
    if position==nil then
      return
    end

    if position[1]~=0 or position[2]~=0 or position[3]~=0 then
      position[2]=position[2]+1
      InfCore.Log(objectName.." pos:".. position[1]..",".. position[2].. ","..position[3],true)
      TppPlayer.Warp{pos=position,rotY=vars.playerCameraRotation[1]}
    end
  end,
}

this.warpToListPosition={
  inMission=true,
  range={max=1},--DYNAMIC
  GetSettingText=function(self,setting)
    local positionsList=InfLookup.GetWarpPositions()
    if #positionsList==0 then
      return "no positions"
    end
    local position=positionsList[setting+1]
    return "pos:".. math.ceil(position[1])..",".. math.ceil(position[2]).. ","..math.ceil(position[3])
  end,
  OnSelect=function(self)
    local positionsList=InfLookup.GetWarpPositions()
    local numObjects=#positionsList

    self.range.max=numObjects-1
    self.setting=0
  end,
  OnActivate=function(self,setting)
    local positionsList=InfLookup.GetWarpPositions()
    local position=positionsList[setting+1]

    if position[1]~=0 or position[2]~=0 or position[3]~=0 then
      position[2]=position[2]+1
      InfCore.Log("pos:".. position[1]..",".. position[2].. ","..position[3],true)
      TppPlayer.Warp{pos=position,rotY=vars.playerCameraRotation[1]}
    end
  end,
}

this.setCamToListObject={
  inMission=true,
  range={max=1},--DYNAMIC
  GetSettingText=function(self,setting)
    local objectName,info,position=InfLookup.GetObjectInfoOrPos(setting+1)
    if info and not position then
      return info
    end

    return objectName.." pos:".. math.ceil(position[1])..",".. math.ceil(position[2]).. ","..math.ceil(position[3])
  end,
  OnSelect=function(self)
    local objectList=InfLookup.GetObjectList()
    local numObjects=#objectList

    self.range.max=numObjects-1
    self.setting=0
  end,
  OnActivate=function(self,setting)
    local objectName,info,position=InfLookup.GetObjectInfoOrPos(setting+1)
    if position==nil then
      return
    end

    if position[1]~=0 or position[2]~=0 or position[3]~=0 then
      position[2]=position[2]+1
      InfCore.Log(objectName.." pos:".. position[1]..",".. position[2].. ","..position[3],true)
      InfCamera.WritePosition("FreeCam",Vector3(position[1],position[2],position[3]))
    end
  end,
}

this.debugValue={
  inMission=true,
  nonConfig=true,
  save=IvarProc.CATEGORY_EXTERNAL,
  default=400,
  range={max=400,min=0,increment=10},
  OnChange=function(self,previousSetting,setting)
    InfCore.Log("debugValue:"..setting)
  end,
}
--end ivar defines

function this.IsIvar(ivar)--TYPEID
  return type(ivar)=="table" and (ivar.range or ivar.settings)
end

--ivar system setup>
--gvars setup
function this.DeclareVars()
  local varTable={}
  --varTable={
  --   {name="ene_typeForcedName",type=TppScriptVars.UINT32,value=false,arraySize=this.MAX_SOLDIER_STATE_COUNT,save=true,category=TppScriptVars.CATEGORY_MISSION},--NONUSER:
  --   {name="ene_typeIsForced",type=TppScriptVars.TYPE_BOOL,value=false,arraySize=this.MAX_SOLDIER_STATE_COUNT,save=true,category=TppScriptVars.CATEGORY_MISSION},--NONUSER:
  --}
  --  from MakeSVarsTable, a bit looser, but strings to strcode is interesting
  --    local valueType=type(value)
  --    if valueType=="boolean"then
  --      type=TppScriptVars.TYPE_BOOL,value=value
  --    elseif valueType=="number"then
  --      type=TppScriptVars.TYPE_INT32,value=value
  --    elseif valueType=="string"then
  --      type=TppScriptVars.TYPE_UINT32,value=StrCode32(value)
  --    elseif valueType=="table"then
  --      value=value
  --    end

  for name, ivar in pairs(Ivars) do
    if this.IsIvar(ivar) then
      if ivar.save and ivar.save~=EXTERNAL then
        local ok=true
        local svarType=0
        local max=ivar.range.max or 0
        local min=ivar.range.min
        if ivar.svarType then
          svarType=ivar.svarType
        elseif ivar.isFloat then
          svarType=TppScriptVars.TYPE_FLOAT
          --elseif max < 2 then --tex TODO: bool support
          --svar.type=TppScriptVars.TYPE_BOOL
        elseif max < int8 then
          svarType=TppScriptVars.TYPE_UINT8
        elseif max < int16 then
          svarType=TppScriptVars.TYPE_UINT16
        elseif max < int32 or max==0 then
          svarType=TppScriptVars.TYPE_INT32
        else
          ok=false
          InfCore.Log("WARNING Ivars.DeclareVars could not find svarType")
        end

        local gvar={name=name,type=svarType,value=ivar.default,save=true,sync=false,wait=false,category=ivar.save}--tex what is sync? think it's network synce, but MakeSVarsTable for seqences sets it to true for all (but then 50050/fob does make a lot of use of it)
        if ok then
          varTable[#varTable+1]=gvar
        end
      end--save
    end--ivar
  end

  --InfInterrogation --DEBUGNOW
  local maxQuestSoldiers=20--SYNC InfInterrogate numQuestSoldiers
  local arrays={
    {name="inf_interCpQuestStatus",arraySize=maxQuestSoldiers,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
  }
  for i,gvar in ipairs(arrays)do
    varTable[#varTable+1]=gvar
  end

  return varTable
end

--TABLESETUP: Ivars
function this.Enum(enumNames)
  if type(enumNames)~="table"then
    return
  end
  local enumTable={}
  for i,enumName in pairs(enumNames)do
    enumTable[enumName]=i-1--NMC: lua tables indexed from 1, enums indexed from 0
  end
  return enumTable
end

local optionType="OPTION"
--build out full definition
function this.BuildIvar(name,ivar)
  local ivars=ivars
  local IvarProc=IvarProc
  if this.IsIvar(ivar) then
    ivar.optionType=optionType
    --ivar.name=ivar.name or name
    ivar.name=name

    ivar.range=ivar.range or {}
    ivar.range.max=ivar.range.max or 1
    ivar.range.min=ivar.range.min or 0
    ivar.range.increment=ivar.range.increment or 1

    ivar.default=ivar.default or ivar.range.min
    ivars[ivar.name]=ivars[ivar.name] or ivar.default

    if ivar.settings then
      ivar.enum=this.Enum(ivar.settings)
      --      for name,enum in ipairs(ivar.enum) do
      --        ivar[name]=false
      --        if enum==ivar.default then
      --          ivar[name]=true
      --        end
      --      end
      --      ivar[ivar.settings[ivar.default] ]=true
      ivar.range.max=#ivar.settings-1--tex ivars are indexed by 1, lua tables (settings) by 1
    end
    local i,f = math.modf(ivar.range.increment)--tex get fractional part
    f=math.abs(f)
    ivar.isFloat=false
    if f<1 and f~=0 then
      ivar.isFloat=true
    end

    ivar.IsDefault=IvarProc.OptionIsDefault
    ivar.Is=IvarProc.OptionIsSetting
    ivar.Get=IvarProc.OptionIsSetting
    ivar.Set=IvarProc.SetSetting
    ivar.SetDirect=IvarProc.SetDirect
    ivar.Reset=IvarProc.ResetSetting
    ivar.GetTableSetting=IvarProc.GetTableSetting
    ivar.GetSettingName=IvarProc.GetSettingName
    ivar.MissionCheck=ivar.MissionCheck--tex OFF or IvarProc.MissionCheckAll--rather have the functions on it bring up warnings than have it cause issues by going through
    ivar.EnabledForMission=IvarProc.IvarEnabledForMission

    if ivar.save and ivar.save==EXTERNAL then
      evars[ivar.name]=evars[ivar.name] or ivars[ivar.name]
      ivars[ivar.name]=evars[ivar.name]--tex for late-defined/module ivars a previously saved value will already be loaded
    end
  end--is ivar
  return ivar
end

function this.SetupIvars()
  InfCore.LogFlow("Ivars.SetupIvars")
  for name,ivar in pairs(this) do
    this.BuildIvar(name,ivar)
  end
end

function this.PostAllModulesLoad()
  InfCore.LogFlow("Adding module Ivars")
  --tex add module ivars to this
  for i,module in ipairs(InfModules) do
    if module.registerIvars and module~=Ivars then
      if this.debugModule then
        InfCore.PrintInspect(module.registerIvars,module.name..".registerIvars")
      end
      for j,name in pairs(module.registerIvars)do
        local ivarDef=module[name]
        if not ivarDef then
          InfCore.Log("Ivars.PostAllModulesLoad: WARNING: could not find "..name.." in "..module.name)
        elseif not this.IsIvar(ivarDef) then
          InfCore.Log("Ivars.PostAllModulesLoad: WARNING: "..name.." in "..module.name.." is not an Ivar.")
        else
          --InfCore.Log("Ivars.PostAllModulesLoad: Adding Ivar "..name.." from "..module.name)
          --tex set them to nonconfig by default so to not trip up AutoDoc
          --DEBUGNOW
          --          if ivarDef.nonConfig~=false then--tex unless we specficially want it to be for config
          --            ivarDef.nonConfig=true
          --          end
          --
          --          if ivarDef.noDoc~=false then
          --            ivarDef.noDoc=true
          --          end
          this[name]=this.BuildIvar(name,ivarDef)
        end
      end
    end
  end

  --tex fill actual references in missionModeIvars now that the ivars are actually here
  for i,module in ipairs(InfModules) do
    if module.missionModeIvarsNames then
      if this.debugModule then
        InfCore.PrintInspect(module.missionModeIvarsNames,module.name..".missionModeIvarsNames")
      end
      for name,ivarNames in pairs(module.missionModeIvarsNames)do
        this.missionModeIvars[name]={}
        for i,ivarName in ipairs(ivarNames)do
          local ivar=this[ivarName]
          if not ivar then
            InfCore.Log("Ivars.PostAllModulesLoad: WARNING: could not find missionMode Ivar ".. ivarName.." from "..module.name)
          else
            table.insert(this.missionModeIvars[name],ivar)
          end
        end
      end
    end
  end

  --tex likewise update vars
  local convertIvars={
    'active',
    'updateRate',
  }
  for i,module in ipairs(InfModules) do
    --KLUDGE: just doing in-place conversion, these values where already Ivar or number, so why not string > Ivar fixup lol
    for i,convertName in ipairs(convertIvars)do
      if type(module[convertName])=="string" then
        local ivar=Ivars[module[convertName]]
        if not ivar then
          InfCore.Log("Ivars.PostAllModulesLoad: WARNING: could not find active Ivar ".. convertName.." from "..module.name)
        else
          module[convertName]=ivar
        end
      end
    end
  end

  if this.debugModule then
    --InfCore.PrintInspect(this.missionModeIvars,"missionModeIvars")
  end

--CULL: moved to InfLangProc
--  --tex check to see if theres a settingNames in InfLang
--  --has to be postmodules since InfLang is loaded after Ivars
--  --GOTCHA this will lock in language till next modules reload (not that there's any actual InfLang translations I'm aware of lol)
--  local settingsStr="Settings"
--  local languageCode=AssetConfiguration.GetDefaultCategory"Language"
--  local langTable=InfLang[languageCode] or InfLang.eng
--  for name,ivar in pairs(this) do
--    if this.IsIvar(ivar) then
--      local settingNames=name..settingsStr
--      if langTable[settingNames] then
--        ivar.settingNames=settingNames
--      end
--      ivar.settingNames=ivar.settingNames or ivar.settings--tex fall back to settings table
--    end
--  end

  --tex kill orphaned save values
  for name,value in pairs(evars)do
    if not ivars[name] then
      InfCore.Log("Ivars.PostAllModulesLoad: WARNING: Could not find ivar for evar "..name)
      evars[name]=nil
    end
  end

end
--<

--EXEC
--InfCore.PCall(function()
--DEBUG
--local breakSave=false
--if breakSave then
--  for i=1,100000 do
--    this["breakVar"..i]={
--      save=MISSION,
--      default=100,
--      range={max=1000,min=0,increment=1},
--    }
--  end
--end

--DEBUG turn off saving
--for name, ivar in pairs(this) do
--  if this.IsIvar(ivar) then
--    ivar.save=nil
--  end
--end
--end)

InfCore.PCall(this.SetupIvars)

return this
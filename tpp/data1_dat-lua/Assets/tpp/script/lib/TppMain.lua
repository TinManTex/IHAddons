-- DOBUILD: 1
-- ORIGINALQAR: data1
-- FILEPATH: \Assets\tpp\script\lib\TppMain.lua
local e={}
--local debugSplash=SplashScreen.Create("debugSplash","/Assets/tpp/ui/texture/Emblem/front/ui_emb_front_5005_l_alp.ftex",1280,640)--tex ghetto as 'did this compile?' indicator
--SplashScreen.Show(debugSplash,0,0.3,0)--tex eagle
local this=e--tex DEMINIFY:
--tex shit I want to keep at top for easy manual changing
this.DEBUGMODE=false
this.modVersion = "r34"
this.modName = "Infinite Heaven"
--tex strings, till we figure out how to access custom values in .lang files this will have to do.
--tex SYNC: with uses of TppUiCommand.AnnounceLogView
this.modStrings={
  menuOff="Menu Off",
  settingDefaults="Setting mod options to defaults...",
}
--tex DEMINIFY:
local IsFunc=Tpp.IsTypeFunc
local Enum=TppDefine.Enum
--tex the bulk of my shit REFACTOR: until we can load our own lua files this is a good a spot as any
--tex button press system. TODO: work out the duplicate bitmasks/those that don't work, and those that are missing
this.buttonMasks={--tex: SYNC: buttonstate
  PlayerPad.DECIDE,
  PlayerPad.STANCE,
  PlayerPad.ACTION,
  PlayerPad.RELOAD,
  PlayerPad.STOCK,
  PlayerPad.MB_DEVICE,
  PlayerPad.CALL,
  PlayerPad.UP,
  PlayerPad.DOWN,
  PlayerPad.LEFT,
  PlayerPad.RIGHT,
  PlayerPad.SIDE_ROLL,
  PlayerPad.ZOOM_CHANGE,
  PlayerPad.LIGHT_SWITCH,
  PlayerPad.EVADE,
  --PlayerPad.VEHICLE_FIRE,--]]--tex button/bitmask always set for some reason
  PlayerPad.VEHICLE_CALL,
  PlayerPad.VEHICLE_DASH,
  --PlayerPad.BUTTON_PLACE_MARKER,--]]--tex button/bitmask always set for some reason
  --PlayerPad.PLACE_MARKER,--]]--tex button/bitmask always set for some reason
  PlayerPad.INTERROGATE,
  PlayerPad.RIDE_ON,
  PlayerPad.RIDE_OFF,
  PlayerPad.VEHICLE_CHANGE_SIGHT,
  PlayerPad.VEHICLE_LIGHT_SWITCH,
  PlayerPad.VEHICLE_TOGGLE_WEAPON,
  PlayerPad.JUMP,
  PlayerPad.MOVE_ACTION,
  PlayerPad.PRIMARY_WEAPON,
  PlayerPad.SECONDARY_WEAPON,
  --[[PlayerPad.STICK_L,
  PlayerPad.STICK_R,
  PlayerPad.TRIGGER_L,
  PlayerPad.TRIGGER_R,
  PlayerPad.TRIGGER_ACCEL,
  PlayerPad.TRIGGER_BREAK,
  --PlayerPad.ALL--]]
}
this.buttonState={--tex: SYNC: buttonmasks
  [PlayerPad.DECIDE]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.STANCE]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.ACTION]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.RELOAD]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.STOCK]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.MB_DEVICE]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.CALL]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.UP]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.DOWN]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.LEFT]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.RIGHT]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.SIDE_ROLL]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.ZOOM_CHANGE]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.LIGHT_SWITCH]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.EVADE]={isPressed=false,holdTime=0,startTime=0},
  --[[[PlayerPad.VEHICLE_FIRE]={isPressed=false,holdTime=0,startTime=0},--]]--tex button/bitmask always set for some reason
  [PlayerPad.VEHICLE_CALL]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.VEHICLE_DASH]={isPressed=false,holdTime=0,startTime=0},
  --[[[PlayerPad.BUTTON_PLACE_MARKER]={isPressed=false,holdTime=0,startTime=0},--]]--tex button/bitmask always set for some reason
  --[[[PlayerPad.PLACE_MARKER]={isPressed=false,holdTime=0,startTime=0},--]]--tex button/bitmask always set for some reason
  [PlayerPad.INTERROGATE]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.RIDE_ON]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.RIDE_OFF]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.VEHICLE_CHANGE_SIGHT]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.VEHICLE_LIGHT_SWITCH]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.VEHICLE_TOGGLE_WEAPON]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.JUMP]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.MOVE_ACTION]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.PRIMARY_WEAPON]={isPressed=false,holdTime=0,startTime=0},
  [PlayerPad.SECONDARY_WEAPON]={isPressed=false,holdTime=0,startTime=0},
}
this.toggleMenuButton=PlayerPad.RELOAD
function this.UpdatePressedButtons()
  for i, button in pairs(this.buttonMasks) do
    this.buttonState[button].isPressed = this.ButtonDown(button)
  end
end
function this.UpdateHeldButtons()
  for i, button in pairs(this.buttonMasks) do
    if this.buttonState[button].holdTime~=0 then
      if this.OnButtonDown(button)then
        this.buttonState[button].startTime=Time.GetRawElapsedTimeSinceStartUp()
      end
      if not this.ButtonDown(button)then
        this.buttonState[button].startTime=0
      end
    end
  end
end
function this.ButtonDown(button)
  --[[if (bit.band(PlayerVars.scannedButtonsDirect,button)==button) then
    TppUiCommand.AnnounceLogView("ButtonPressed:" .. bit.tohex(button))--tex DEBUG: CULL:
  end--]]
  return bit.band(PlayerVars.scannedButtonsDirect,button)==button
end
--tex GOTCHA: OnButton functions will have a gameframe of latency, sorry to dissapoint all the pro gamers
function this.OnButtonDown(button)
  return not this.buttonState[button].isPressed and (bit.band(PlayerVars.scannedButtonsDirect,button)==button)
end
function this.OnButtonUp(button)
  return this.buttonState[button].isPressed and not (bit.band(PlayerVars.scannedButtonsDirect,button)==button)
end
function this.OnButtonHoldTime(button)
  local buttonState = this.buttonState[button]
  if buttonState.holdTime~=0 and buttonState.startTime~=0 then
    if Time.GetRawElapsedTimeSinceStartUp() - buttonState.startTime > buttonState.holdTime then
      buttonState.startTime=0
      return true
    end
  end
  return false
end
--[[function this.TimerReset(timer,length)--tex REF: CULL: using the code straight for now, no point in throwing extra function calls at it for no real benefit, and the games timer system will do for most uses
  timer.holdTime=length
end
function this.TimerStart(timer)
  timer.startTime=Time.GetRawElapsedTimeSinceStartUp()
end
function this.TimerStop(timer)
  timer.startTime=0
end
function this.TimerIsDone(timer)
  return timer.holdTime~=0 and timer.startTime~=0 and Time.GetRawElapsedTimeSinceStartUp() - timer.startTime > timer.holdTime
end--]]
--tex mod settings setup
this.subsistenceLoadouts={--tex pure,secondary.
  TppDefine.CYPR_PLAYER_INITIAL_WEAPON_TABLE,
  TppDefine.SUBSISTENCE_SECONDARY_INITIAL_WEAPON_TABLE
}
this.SUBSISTENCE_BOUND=2--tex: SPECIAL: RETRY:
this.switchSlider={max=1,min=0,increment=1}
this.healthMultSlider={max=4,min=0,increment=0.2}
this.switchSettingNames={"Off","On"}
function this.SettingInfoHealth()
  return vars.playerLifeMax
end
this.modSettings={
  {
    name="Subsistence Mode",
    gvarName="isManualSubsistence",
    default=0,
    slider={max=2,min=0,increment=1},
    settingNames={"Off","Pure (OSP -Items -Hand -Suit -Support -Fulton -Vehicle -Buddy)","Bounder (Pure +Buddy +Suit +Fulton)"},
    onChange=function()--tex DEPENDENCY: settings dependency, isManualSubsistence, subsistenceLoadout
      if gvars.isManualSubsistence==0 then
        gvars.subsistenceLoadout=0
      elseif gvars.subsistenceLoadout==0 then
        gvars.subsistenceLoadout=1
      end
    end
  },
  {
    name="OSP Weapon Loadout",
    gvarName="subsistenceLoadout",
    default=0,
    slider={max=#this.subsistenceLoadouts,min=0,increment=1},
    settingNames={"Off","Pure","Secondary enabled"},
    helpText="Start with no primary and secondary weapons, can be used seperately from subsistence mode"
  },
  {
    name="Enemy Preparedness",
    gvarName="revengeMode",    
    default=0,
    slider=this.switchSlider,
    settingNames={"Regular","Max"},
  },
  {
    name="General Enemy Parameters",
    gvarName="modParameters",
    default=0,
    slider=this.switchSlider,
    settingNames={"Tweaked","Default (mods can override)"},
  },
  {
    name="Player life scale",
    gvarName="playerHealthMult",
    default=1,
    slider=this.healthMultSlider,
    isFloatSetting=true,
    infoFunc=this.SettingInfoHealth,
  },
  {
    name="Enemy life scale",
    gvarName="enemyHealthMult",
    default=1,
    slider=this.healthMultSlider,
    isFloatSetting=true,
  },
  {
    name="Unlock Sideops (some currently don't spawn objectives)",
    gvarName="unlockSideOps",
    default=0,
    slider=this.switchSlider,
    settingNames={"Off","Enabled"},
  },
  {
    name="Reset all settings",
    default=0,
    slider=this.switchSlider,
    settingNames={">","Reset"},
    onChange=function()
      this.ResetSettingsDisplay()        
    end
  },
  {
    name="Turn off menu",
    default=0,
    slider=this.switchSlider,
    settingNames={">","Off"},
    onChange=function()
      this.modMenuOn=false
      this.currentOption=1
      TppUiCommand.AnnounceLogView(TppMain.modStrings.menuOff)    
    end
  },
}
this.currentOption=1--tex lua tables are indexed from 1
this.currentSetting=0--tex settings from 0, to better fit variables
this.lastDisplay=0
this.autoDisplayRate=2.8
this.modMenuOn=false
--tex mod settings menu manipulation
function this.NextOption()
  this.currentOption=this.currentOption+1
  if this.currentOption > #this.modSettings then
    this.currentOption = 1
  end
  this.GetSetting()
end
function this.PreviousOption()
  this.currentOption = this.currentOption-1
  if this.currentOption < 1 then
    this.currentOption = #this.modSettings
  end
  this.GetSetting()
end
function this.GetSetting()
  local modSetting=this.modSettings[this.currentOption]
  this.currentSetting=modSetting.default
  if modSetting.gvarName ~= nil then
    local gvar=gvars[modSetting.gvarName]
    if gvar ~= nil then
      this.currentSetting=gvar
    else
      TppUiCommand.AnnounceLogView("Option Menu Error: gvar -"..modSetting.gvarName.."- not found")
    end
  end
end
function this.ChangeSetting(modSetting,value)
  --TppUiCommand.AnnounceLogView("DBG:MNU: changesetting increment:"..value)--tex DEBUG: CULL:
  local newSetting=this.currentSetting
  if modSetting.gvarName~=nil then
    --TppUiCommand.AnnounceLogView("DBG:MNU: found gvarName:" .. modSetting.gvarName)--tex DEBUG: CULL:
    local gvar=gvars[modSetting.gvarName]
    if gvar ~= nil then
      --TppUiCommand.AnnounceLogView("DBG:MNU: gvar:" .. modSetting.gvarName .. "=" .. gvar)--tex DEBUG: CULL:
      newSetting=gvar+value
      --TppUiCommand.AnnounceLogView("DBG:MNU: newsetting:"..newSetting)--tex DEBUG: CULL:
      newSetting=TppMath.Clamp(newSetting,modSetting.slider.min,modSetting.slider.max)
      --TppUiCommand.AnnounceLogView("DBG:MNU: newsetting clamped:"..newSetting)--tex DEBUG: CULL:
    else
      TppUiCommand.AnnounceLogView("Option Menu Error: gvar -" .. modSetting.gvarName .. "- not found")
    end
    if modSetting.confirm == nil then 
      gvars[modSetting.gvarName]=newSetting
      --TppUiCommand.AnnounceLogView("DBG:MNU: gvar set:" .. modSetting.gvarName .. "=" .. gvar)--tex DEBUG: CULL:
      if IsFunc(modSetting.onChange) then
        modSetting.onChange()
      end
    elseif newSetting==modSetting.default then--tex let confirm settings turn off without having to confirm lol
      gvars[modSetting.gvarName]=newSetting
      --TppUiCommand.AnnounceLogView("DBG:MNU: gvar set:" .. modSetting.gvarName .. "=" .. gvar)--tex DEBUG: CULL:
      if IsFunc(modSetting.onChange) then
        modSetting.onChange()
      end      
    end
  else--gvar nil
    newSetting=this.currentSetting+value
    newSetting=TppMath.Clamp(newSetting,modSetting.slider.min,modSetting.slider.max)
    if IsFunc(modSetting.onChange) then
      modSetting.onChange()
    end   
  end
  --TppUiCommand.AnnounceLogView("DBG:MNU: new currentSetting:" .. newSetting)
  return newSetting
end
function this.ConfirmCurrent()
  this.ConfirmSetting(this.modSettings[this.currentOption],this.currentSetting)
end
function this.ConfirmSetting(modSetting,value)
  if modSetting.confirm ~= nil then
    if modSetting.gvarName~=nil then
      local gvar=gvars[modSetting.gvarName]
      if gvar ~= nil then
        gvars[modSetting.gvarName]=value
        if IsFunc(modSetting.onChange) then
          modSetting.onChange()
        end
      end
    end
  end
end
function this.NextSetting()
  local modSetting=this.modSettings[this.currentOption]
  this.currentSetting=this.ChangeSetting(modSetting,modSetting.slider.increment)
end
function this.PreviousSetting()
  local modSetting=this.modSettings[this.currentOption]
  this.currentSetting=this.ChangeSetting(modSetting,-modSetting.slider.increment)
end
function this.DisplayCurrentSetting()
  if this.modMenuOn then
    this.DisplaySetting(this.currentOption)
  end
end
function this.DisplaySetting(optionIndex)
  this.lastDisplay=Time.GetRawElapsedTimeSinceStartUp() 
  local modSetting=this.modSettings[optionIndex]
  local settingText="UNDEFINED"
  if modSetting.settingNames ~= nil then
    if this.currentSetting < 0 or this.currentSetting > #modSetting.settingNames-1 then
      settingText="CURRENTSETTING OUT OF BOUNDS"
    else
      settingText=modSetting.settingNames[this.currentSetting+1]--tex lua indexed from 1, but settings from 0
      if modSetting.confirm ~= nil then
        if this.currentSetting ~= modSetting.default then
          if modSetting.gvarName ~= nil and gvars[modSetting.gvarName] ~= nil then
            if gvars[modSetting.gvarName] ~= this.currentSetting then
              settingText=settingText.." (Press<Reload> to confirm)"
            else--tex ASSUMPTION SPECIAL setting text is "Enable"
              settingText=modSetting.confirm
            end
          end
        end
      end
    end
  elseif modSetting.isFloatSetting then
    settingText=math.floor(100*this.currentSetting) .. "%"
  else
    settingText=tostring(this.currentSetting)
  end
  local info = 0
  if IsFunc(modSetting.infoFunc) then
    info = modSetting.infoFunc()
  end
  TppUiCommand.AnnounceLogDelayTime(0)
  TppUiCommand.AnnounceLogView(optionIndex..":"..modSetting.name.." = "..settingText)--tex thank you ThreeSocks3, you're a god damn legend for finding custom text output, heres a better way to do things than string.format, in lua .. concatenates strings, does simple format conversion
end
function this.DisplaySettings()--tex display all
  for i=1,#this.modSettings do
    this.DisplaySetting(i)
  end
end
function this.AutoDisplay()
  if this.modMenuOn then
    if this.autoDisplayRate > 0 then
      if Time.GetRawElapsedTimeSinceStartUp() - this.lastDisplay > this.autoDisplayRate then
        this.DisplayCurrentSetting()
      end
    end
  end
end
function this.ResetSettings()
  for i=1,#this.modSettings do
    local gvarName=this.modSettings[i].gvarName
    if gvarName~=nil then
      gvars[gvarName]=this.modSettings[i].default
    end
  end
end
function this.ResetSettingsDisplay()
  TppUiCommand.AnnounceLogView(TppMain.modStrings.settingDefaults)--tex "Setting mod options to defaults..."
  for i=1,#this.modSettings do
    local modSetting=this.modSettings[i]
    if modSetting.gvarName~=nil then
      gvars[modSetting.gvarName]=modSetting.default
      this.currentSetting=modSetting.default
      this.DisplaySetting(i)
    end
  end
  this.GetSetting()
end
function this.UpdateModMenu()--tex RETRY: called from TppMission.Update, had 'troubles' running in main
--local debugSplash=SplashScreen.Create("debugSplash","/Assets/tpp/ui/texture/Emblem/front/ui_emb_front_5005_l_alp.ftex",1280,640)--tex ghetto as 'does it run?' indicator
--SplashScreen.Show(debugSplash,0,0.3,0)--tex eagle
  ModStart()--tex: TODO: move to actual run once on startup init thing, make sure to check ModStart itself to see affected code
  this.UpdateHeldButtons()
  if not mvars.mis_missionStateIsNotInGame then--tex actually loaded game, ie at least 'continued' from title screen
    if TppMission.IsHelicopterSpace(vars.missionCode)then
      --tex RETRY: still not happy, want to read menu status but cant find any way
      if this.OnButtonHoldTime(this.toggleMenuButton) then
        this.modMenuOn = not this.modMenuOn
        if this.modMenuOn then
          this.GetSetting()
          TppUiCommand.AnnounceLogView(this.modName.." "..this.modVersion)
          --this.lastDisplay=Time.GetRawElapsedTimeSinceStartUp()
          if this.autoDisplayRate==0 then
            this.DisplayCurrentSetting()
          end
        else
          TppUiCommand.AnnounceLogView(this.modStrings.menuOff)
        end
      end
      if this.modMenuOn then
        if this.OnButtonDown(PlayerPad.MB_DEVICE) then
          this.modMenuOn=false
          TppUiCommand.AnnounceLogView(this.modStrings.menuOff)
        end
        --[[if this.OnButtonDown(PlayerPad.RELOAD) then
          this.ConfirmCurrent()
        end--]]
        if this.OnButtonDown(PlayerPad.UP) then
          this.PreviousOption()
          this.DisplayCurrentSetting()
        end
        if this.OnButtonDown(PlayerPad.DOWN) then
          this.NextOption()
          this.DisplayCurrentSetting()
        end
        if this.OnButtonDown(PlayerPad.LEFT) then
          this.PreviousSetting()
          this.DisplayCurrentSetting()
        end
        if this.OnButtonDown(PlayerPad.RIGHT) then
          this.NextSetting()
          this.DisplayCurrentSetting()
        end
      end
      this.AutoDisplay()
    else--!ishelispace
      this.modMenuOn = false
      if this.DEBUGMODE then
        if this.OnButtonDown(PlayerPad.LIGHT_SWITCH) then
          TppUiCommand.AnnounceLogView("")
        end
      end
    end
  else--!ingame
    this.modMenuOn = false
  end
  this.UpdatePressedButtons()--tex GOTCHA: should be after all key reads, sets current keys to prev keys for onbutton checks
--local debugSplash=SplashScreen.Create("debugSplash","/Assets/tpp/ui/texture/Emblem/front/ui_emb_front_5020_l_alp.ftex",1280,640)--tex ghetto as 'does it run?' indicator
--SplashScreen.Show(debugSplash,0,0.3,0)--tex dog
end
function ModStart()--tex currently called from UpdateModMenu, RETRY: find an actual place for on start/run once init.
  gvars.isManualHard = false--tex PATCHUP: not currently exposed to mod menu, force off to patch those that might have saves from prior mod with it on 
  this.buttonState[PlayerPad.LIGHT_SWITCH].holdTime=1--tex set up hold buttons
  this.buttonState[PlayerPad.RELOAD].holdTime=1
end
function this.ModWelcome()
  TppUiCommand.AnnounceLogView(this.modName .. " " .. this.modVersion)
  TppUiCommand.AnnounceLogView("Hold X key or Dpad Right for 1 second to enable menu")
end
function this.ModMissionMessage()
  TppUiCommand.AnnounceLogView("ModMissionMessage test")
end
--tex soldier2parametertables shiz REFACTOR: find somewhere nicer to put/compartmentalize this, Solider2ParameterTables.lua aparently can't be referenced even though there's a TppSolder2Parameter string in the exe, load hang on trying to do anything with it (and again no debug feedback to know why the fuck anything)
local nightSightDebug={
  discovery={distance=10,verticalAngle=30,horizontalAngle=40},
  indis={distance=15,verticalAngle=60,horizontalAngle=60},
  dim={distance=40,verticalAngle=60,horizontalAngle=60},
  far={distance=350,verticalAngle=60,horizontalAngle=60}--tex debug hax
}
--tex in sightFormParameter
local sandstormSightDefault={distanceRate=.6,angleRate=.8}
local rainSightDefault={distanceRate=1,angleRate=1}
local cloudySightDefault={distanceRate=1,angleRate=1}
local foggySightDefault={distanceRate=.5,angleRate=.6}
--tex BALLANCE: being conservative, could be more agressive if coupled with a bump in the sight dist it modifies, but I like the retail settings in general
local sandstormSightImproved={distanceRate=.6,angleRate=.8}
local rainSightImproved={distanceRate=.9,angleRate=0.95}
local cloudySightImproved={distanceRate=0.95,angleRate=1}
local foggySightImproved={distanceRate=.5,angleRate=.6}

this.lifeParameterTableDefault={maxLife=2600,maxStamina=3e3,maxLimbLife=1500,maxArmorLife=7500,maxHelmetLife=500,sleepRecoverSec=300,faintRecoverSec=50,dyingSec=60}
this.lifeParameterTableMod={maxLife=2600,maxStamina=3e3,maxLimbLife=1500,maxArmorLife=7500,maxHelmetLife=500,sleepRecoverSec=300,faintRecoverSec=50,dyingSec=60}--tex modified in-place by enemy health scale
this.soldierParametersDefault = {--tex  SYNC: soldierParametersMod. actually using my slight tweaks rather than true default
  sightFormParameter={
    contactSightForm={distance=2,verticalAngle=160,horizontalAngle=130},
    normalSightForm={distance=60,verticalAngle=60,horizontalAngle=100},
    farSightForm={distance=90,verticalAngle=30,horizontalAngle=30},
    searchLightSightForm={distance=50,verticalAngle=15,horizontalAngle=15},
    observeSightForm={distance=200,verticalAngle=5,horizontalAngle=5},
    baseSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=20,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}
    },
    nightSight={
      discovery={distance=10,verticalAngle=30,horizontalAngle=40},
      indis={distance=15,verticalAngle=60,horizontalAngle=60},
      dim={distance=40,verticalAngle=60,horizontalAngle=60},
      far={distance=50,verticalAngle=8,horizontalAngle=6}
    },
    combatSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=50,verticalAngle=60,horizontalAngle=100},
      far={distance=70,verticalAngle=30,horizontalAngle=30}},
    walkerGearSight={
      discovery={distance=15,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=55,verticalAngle=60,horizontalAngle=100},
      far={distance=85,verticalAngle=30,horizontalAngle=30}},
    observeSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=70,verticalAngle=12,horizontalAngle=8},
      dim={distance=45,verticalAngle=5,horizontalAngle=5},
      far={distance=70,verticalAngle=5,horizontalAngle=5},
      observe={distance=200,verticalAngle=5,horizontalAngle=5}
    },
    snipingSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=70,verticalAngle=12,horizontalAngle=8},
      dim={distance=45,verticalAngle=5,horizontalAngle=5},
      far={distance=70,verticalAngle=5,horizontalAngle=5},
      observe={distance=200,verticalAngle=5,horizontalAngle=5}
    },
    searchLightSight={
      discovery={distance=30,verticalAngle=8,horizontalAngle=8},
      indis={distance=0,verticalAngle=0,horizontalAngle=0},
      dim={distance=50,verticalAngle=12,horizontalAngle=12},
      far={distance=0,verticalAngle=0,horizontalAngle=0}},
    armoredVehicleSight={
      discovery={distance=20,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=55,verticalAngle=60,horizontalAngle=100},
      far={distance=85,verticalAngle=30,horizontalAngle=30},
      observe={distance=120,verticalAngle=5,horizontalAngle=5}},
    zombieSight={
      discovery={distance=7,verticalAngle=36,horizontalAngle=48},
      indis={distance=14,verticalAngle=60,horizontalAngle=80},
      dim={distance=31.5,verticalAngle=60,horizontalAngle=80},
      far={distance=0,verticalAngle=12,horizontalAngle=8}},
    msfSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=20,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}},
    vehicleSight={
      discovery={distance=15,verticalAngle=36,horizontalAngle=48},
      indis={distance=25,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}
    },
    sandstormSight=sandstormSightImproved,
    rainSight=rainSightImproved,
    cloudySight=cloudySightImproved,
    foggySight=foggySightImproved
  },
  sightCamouflageParameter={
    discovery={enemy=530,character=530,object=530},
    indis={enemy=80,character=210,object=270},
    dim={enemy=-50,character=30,object=130},
    far={enemy=-310,character=0,object=70},
    bushDensityThresold=100
  },
  hearingRangeParameter={
    normal={zero=0,ss=4.5,hs=5.5,s=9,m=15,l=30,hll=60,ll=160,alert=160,special=500},
    sandstorm={zero=0,ss=0,hs=0,s=0,m=15,l=30,hll=60,ll=160,alert=160,special=500},
    rain={zero=0,ss=0,hs=0,s=4.5,m=15,l=30,hll=60,ll=160,alert=160,special=500}
  },
  lifeParameterTable=this.lifeParameterTableMod,
  zombieParameterTable={highHeroicValue=1e3}
}
this.soldierParametersMod={--tex: SYNC: soldierParametersDefault. Ugly, but don't want to blow out the stack by doing table copies at runtime
  sightFormParameter={
    contactSightForm={distance=2,verticalAngle=160,horizontalAngle=130},
    normalSightForm={distance=60,verticalAngle=60,horizontalAngle=100},
    farSightForm={distance=90,verticalAngle=30,horizontalAngle=30},
    searchLightSightForm={distance=50,verticalAngle=15,horizontalAngle=15},
    observeSightForm={distance=200,verticalAngle=5,horizontalAngle=5},
    baseSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=20,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}
    },
    nightSight={
      discovery={distance=10,verticalAngle=30,horizontalAngle=40},
      indis={distance=15,verticalAngle=60,horizontalAngle=60},
      dim={distance=40,verticalAngle=60,horizontalAngle=60},
      far={distance=50,verticalAngle=8,horizontalAngle=6}
    },
    combatSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=50,verticalAngle=60,horizontalAngle=100},
      far={distance=70,verticalAngle=30,horizontalAngle=30}},
    walkerGearSight={
      discovery={distance=15,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=55,verticalAngle=60,horizontalAngle=100},
      far={distance=85,verticalAngle=30,horizontalAngle=30}},
    observeSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=70,verticalAngle=12,horizontalAngle=8},
      dim={distance=45,verticalAngle=5,horizontalAngle=5},
      far={distance=70,verticalAngle=5,horizontalAngle=5},
      observe={distance=200,verticalAngle=5,horizontalAngle=5}
    },
    snipingSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=70,verticalAngle=12,horizontalAngle=8},
      dim={distance=45,verticalAngle=5,horizontalAngle=5},
      far={distance=70,verticalAngle=5,horizontalAngle=5},
      observe={distance=200,verticalAngle=5,horizontalAngle=5}
    },
    searchLightSight={
      discovery={distance=30,verticalAngle=8,horizontalAngle=8},
      indis={distance=0,verticalAngle=0,horizontalAngle=0},
      dim={distance=50,verticalAngle=12,horizontalAngle=12},
      far={distance=0,verticalAngle=0,horizontalAngle=0}},
    armoredVehicleSight={
      discovery={distance=20,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=55,verticalAngle=60,horizontalAngle=100},
      far={distance=85,verticalAngle=30,horizontalAngle=30},
      observe={distance=120,verticalAngle=5,horizontalAngle=5}},
    zombieSight={
      discovery={distance=7,verticalAngle=36,horizontalAngle=48},
      indis={distance=14,verticalAngle=60,horizontalAngle=80},
      dim={distance=31.5,verticalAngle=60,horizontalAngle=80},
      far={distance=0,verticalAngle=12,horizontalAngle=8}},
    msfSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=20,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}},
    vehicleSight={
      discovery={distance=15,verticalAngle=36,horizontalAngle=48},
      indis={distance=25,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}
    },
    sandstormSight=sandstormSightImproved,
    rainSight=rainSightImproved,
    cloudySight=cloudySightImproved,
    foggySight=foggySightImproved
  },
  sightCamouflageParameter={
    discovery={enemy=530,character=530,object=530},
    indis={enemy=80,character=210,object=270},
    dim={enemy=-50,character=30,object=130},
    far={enemy=-310,character=0,object=70},
    bushDensityThresold=100
  },
  hearingRangeParameter={
    normal={zero=0,ss=4.5,hs=5.5,s=9,m=15,l=30,hll=60,ll=160,alert=160,special=500},
    sandstorm={zero=0,ss=0,hs=0,s=0,m=15,l=30,hll=60,ll=160,alert=160,special=500},
    rain={zero=0,ss=0,hs=0,s=4.5,m=15,l=30,hll=60,ll=160,alert=160,special=500}
  },
  lifeParameterTable=this.lifeParameterTableMod,
  zombieParameterTable={highHeroicValue=1e3}
}
function this.LoadTrueDefaultEnemyParams()--tex DEBUG: REF: CULL:
TppSoldier2.ReloadSoldier2ParameterTables{
  sightFormParameter={
    contactSightForm={distance=2,verticalAngle=160,horizontalAngle=130},
    normalSightForm={distance=60,verticalAngle=60,horizontalAngle=100},
    farSightForm={distance=90,verticalAngle=30,horizontalAngle=30},
    searchLightSightForm={distance=50,verticalAngle=15,horizontalAngle=15},
    observeSightForm={distance=200,verticalAngle=5,horizontalAngle=5},
    baseSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=20,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}
    },
    nightSight={
      discovery={distance=10,verticalAngle=30,horizontalAngle=40},
      indis={distance=15,verticalAngle=60,horizontalAngle=60},
      dim={distance=40,verticalAngle=60,horizontalAngle=60},
      far={distance=0,verticalAngle=0,horizontalAngle=0}
    },
    combatSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=50,verticalAngle=60,horizontalAngle=100},
      far={distance=70,verticalAngle=30,horizontalAngle=30}},
    walkerGearSight={
      discovery={distance=15,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=55,verticalAngle=60,horizontalAngle=100},
      far={distance=85,verticalAngle=30,horizontalAngle=30}},
    observeSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=70,verticalAngle=12,horizontalAngle=8},
      dim={distance=45,verticalAngle=5,horizontalAngle=5},
      far={distance=70,verticalAngle=5,horizontalAngle=5},
      observe={distance=200,verticalAngle=5,horizontalAngle=5}
    },
    snipingSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=70,verticalAngle=12,horizontalAngle=8},
      dim={distance=45,verticalAngle=5,horizontalAngle=5},
      far={distance=70,verticalAngle=5,horizontalAngle=5},
      observe={distance=200,verticalAngle=5,horizontalAngle=5}
    },
    searchLightSight={
      discovery={distance=30,verticalAngle=8,horizontalAngle=8},
      indis={distance=0,verticalAngle=0,horizontalAngle=0},
      dim={distance=50,verticalAngle=12,horizontalAngle=12},
      far={distance=0,verticalAngle=0,horizontalAngle=0}},
    armoredVehicleSight={
      discovery={distance=20,verticalAngle=36,horizontalAngle=60},
      indis={distance=25,verticalAngle=60,horizontalAngle=100},
      dim={distance=55,verticalAngle=60,horizontalAngle=100},
      far={distance=85,verticalAngle=30,horizontalAngle=30},
      observe={distance=120,verticalAngle=5,horizontalAngle=5}},
    zombieSight={
      discovery={distance=7,verticalAngle=36,horizontalAngle=48},
      indis={distance=14,verticalAngle=60,horizontalAngle=80},
      dim={distance=31.5,verticalAngle=60,horizontalAngle=80},
      far={distance=0,verticalAngle=12,horizontalAngle=8}},
    msfSight={
      discovery={distance=10,verticalAngle=36,horizontalAngle=48},
      indis={distance=20,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}},
    vehicleSight={
      discovery={distance=15,verticalAngle=36,horizontalAngle=48},
      indis={distance=25,verticalAngle=60,horizontalAngle=80},
      dim={distance=45,verticalAngle=60,horizontalAngle=80},
      far={distance=70,verticalAngle=12,horizontalAngle=8}
    },
    sandstormSight={distanceRate=.6,angleRate=.8},
    rainSight={distanceRate=1,angleRate=1},
    cloudySight={distanceRate=1,angleRate=1},
    foggySight={distanceRate=.5,angleRate=.6}},
  sightCamouflageParameter={
    discovery={enemy=530,character=530,object=530},
    indis={enemy=80,character=210,object=270},
    dim={enemy=-50,character=30,object=130},
    far={enemy=-310,character=0,object=70},
    bushDensityThresold=100
  },
  hearingRangeParameter={
    normal={zero=0,ss=4.5,hs=5.5,s=9,m=15,l=30,hll=60,ll=160,alert=160,special=500},
    sandstorm={zero=0,ss=0,hs=0,s=0,m=15,l=30,hll=60,ll=160,alert=160,special=500},
    rain={zero=0,ss=0,hs=0,s=4.5,m=15,l=30,hll=60,ll=160,alert=160,special=500}
  },
  lifeParameterTable={maxLife=2600,maxStamina=3e3,maxLimbLife=1500,maxArmorLife=7500,maxHelmetLife=500,sleepRecoverSec=300,faintRecoverSec=50,dyingSec=60},
  zombieParameterTable={highHeroicValue=1e3}
}
end--tex end of shit
local l=Tpp.ApendArray
local n=Tpp.DEBUG_StrCode32ToString
local i=Tpp.IsTypeFunc
local t=Tpp.IsTypeTable
local f=TppScriptVars.IsSavingOrLoading
local m=ScriptBlock.UpdateScriptsInScriptBlocks
local M=Mission.GetCurrentMessageResendCount
local o={}
local p=0
local T={}
local a=0
local d={}
local u=0
local n={}
local n=0
local S={}
local P={}
local s=0
local c={}
local h={}
local r=0
local function n()--tex NMC: cant actually see this referenced anywhere
  if QuarkSystem.GetCompilerState()==QuarkSystem.COMPILER_STATE_WAITING_TO_LOAD then
    QuarkSystem.PostRequestToLoad()
    coroutine.yield()
    while QuarkSystem.GetCompilerState()==QuarkSystem.COMPILER_STATE_WAITING_TO_LOAD do
      coroutine.yield()
    end
  end
end
function this.DisableGameStatus()
  TppMission.DisableInGameFlag()
  Tpp.SetGameStatus{target="all",enable=false,except={S_DISABLE_NPC=false},scriptName="TppMain.lua"}
end
function this.DisableGameStatusOnGameOverMenu()
  TppMission.DisableInGameFlag()
  Tpp.SetGameStatus{target="all",enable=false,scriptName="TppMain.lua"}
end
function this.EnableGameStatus()
  TppMission.EnableInGameFlag()
  Tpp.SetGameStatus{target={S_DISABLE_PLAYER_PAD=true,S_DISABLE_TARGET=true,S_DISABLE_NPC=true,S_DISABLE_NPC_NOTICE=true,S_DISABLE_PLAYER_DAMAGE=true,S_DISABLE_THROWING=true,S_DISABLE_PLACEMENT=true},enable=true,scriptName="TppMain.lua"}
end
function this.EnableGameStatusForDemo()
  TppDemo.ReserveEnableInGameFlag()
  Tpp.SetGameStatus{target={S_DISABLE_PLAYER_PAD=true,S_DISABLE_TARGET=true,S_DISABLE_NPC=true,S_DISABLE_NPC_NOTICE=true,S_DISABLE_PLAYER_DAMAGE=true,S_DISABLE_THROWING=true,S_DISABLE_PLACEMENT=true},enable=true,scriptName="TppMain.lua"}
end
function this.EnableAllGameStatus()
  TppMission.EnableInGameFlag()
  Tpp.SetGameStatus{target="all",enable=true,scriptName="TppMain.lua"}
end
function this.EnablePlayerPad()
  TppGameStatus.Reset("TppMain.lua","S_DISABLE_PLAYER_PAD")
end
function this.DisablePlayerPad()
  TppGameStatus.Set("TppMain.lua","S_DISABLE_PLAYER_PAD")
end
function this.EnablePause()
  TppPause.RegisterPause"TppMain.lua"end
function this.DisablePause()
  TppPause.UnregisterPause"TppMain.lua"end
function this.EnableBlackLoading(e)
  TppGameStatus.Set("TppMain.lua","S_IS_BLACK_LOADING")
  if e then
    TppUI.StartLoadingTips()
  end
end
function this.DisableBlackLoading()
  TppGameStatus.Reset("TppMain.lua","S_IS_BLACK_LOADING")
  TppUI.FinishLoadingTips()
end
function this.OnAllocate(n)
  TppWeather.OnEndMissionPrepareFunction()
  this.DisableGameStatus()
  this.EnablePause()
  TppClock.Stop()
  o={}
  p=0
  d={}
  u=0
  TppUI.FadeOut(TppUI.FADE_SPEED.FADE_MOMENT,nil,nil)
  TppSave.WaitingAllEnqueuedSaveOnStartMission()
  if TppMission.IsFOBMission(vars.missionCode)then
    this.ResetSettings()--tex reset settings on FOB
    TppMission.SetFOBMissionFlag()
    TppGameStatus.Set("Mission","S_IS_ONLINE")
  else
    TppGameStatus.Reset("Mission","S_IS_ONLINE")
  end
  Mission.Start()
  TppMission.WaitFinishMissionEndPresentation()
  TppMission.DisableInGameFlag()
  TppException.OnAllocate(n)
  TppClock.OnAllocate(n)
  TppTrap.OnAllocate(n)
  TppCheckPoint.OnAllocate(n)
  TppUI.OnAllocate(n)
  TppDemo.OnAllocate(n)
  TppScriptBlock.OnAllocate(n)
  TppSound.OnAllocate(n)
  TppPlayer.OnAllocate(n)
  TppMission.OnAllocate(n)
  TppTerminal.OnAllocate(n)
  TppEnemy.OnAllocate(n)
  TppRadio.OnAllocate(n)
  TppGimmick.OnAllocate(n)
  TppMarker.OnAllocate(n)
  TppRevenge.OnAllocate(n)
  this.ClearStageBlockMessage()
  TppQuest.OnAllocate(n)
  TppAnimal.OnAllocate(n)
  local function o()
    if TppLocation.IsAfghan()then
      if afgh then
        afgh.OnAllocate()
      end
    elseif TppLocation.IsMiddleAfrica()then
      if mafr then
        mafr.OnAllocate()
      end
    elseif TppLocation.IsCyprus()then
      if cypr then
        cypr.OnAllocate()
      end
    elseif TppLocation.IsMotherBase()then
      if mtbs then
        mtbs.OnAllocate()
      end
    end
  end
  o()
  if n.sequence then
    if i(n.sequence.MissionPrepare)then
      n.sequence.MissionPrepare()        
    end
    if i(n.sequence.OnEndMissionPrepareSequence)then
      TppSequence.SetOnEndMissionPrepareFunction(n.sequence.OnEndMissionPrepareSequence)
    end
  end
  for n,e in pairs(n)do
    if i(e.OnLoad)then
      e.OnLoad()
    end
  end
  do
    local s={}
    for t,e in ipairs(Tpp._requireList)do
      if _G[e]then
        if _G[e].DeclareSVars then
          l(s,_G[e].DeclareSVars(n))
        end
      end
    end
    local o={}
    for n,e in pairs(n)do
      if i(e.DeclareSVars)then
        l(o,e.DeclareSVars())
      end
      if t(e.saveVarsList)then
        l(o,TppSequence.MakeSVarsTable(e.saveVarsList))
      end
    end
    l(s,o)
    TppScriptVars.DeclareSVars(s)
    TppScriptVars.SetSVarsNotificationEnabled(false)
    while f()do
      coroutine.yield()
    end    
    TppRadioCommand.SetScriptDeclVars()
    local i=vars.mbLayoutCode
    if gvars.ini_isTitleMode then
      TppPlayer.MissionStartPlayerTypeSetting()
    else
      if TppMission.IsMissionStart()then
        TppVarInit.InitializeForNewMission(n)     
        TppPlayer.MissionStartPlayerTypeSetting()
        if not TppMission.IsFOBMission(vars.missionCode)then
          TppSave.VarSave(vars.missionCode,true)
        end
      else
        TppVarInit.InitializeForContinue(n)
      end
      TppVarInit.ClearIsContinueFromTitle()
    end
    TppStory.SetMissionClearedS10030()
    TppTerminal.StartSyncMbManagementOnMissionStart()
    if TppLocation.IsMotherBase()then
      if i~=vars.mbLayoutCode then
        if vars.missionCode==30050 then
          vars.mbLayoutCode=i
        else
          vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(TppMotherBaseManagement.GetMbsTopologyType())
        end
      end
    end
    this.StageBlockCurrentPosition(true)
    TppMission.SetSortieBuddy()
    TppStory.UpdateStorySequence{updateTiming="BeforeBuddyBlockLoad"}
    if n.sequence then
      local e=n.sequence.DISABLE_BUDDY_TYPE
      if e then
        local n
        if t(e)then
          n=e
        else
          n={e}
        end
        for n,e in ipairs(n)do
          TppBuddyService.SetDisableBuddyType(e)
        end
      end
    end
    --tex changed to issubs check, more robust even without my mod
    --if(vars.missionCode==11043)or(vars.missionCode==11044)then
    if TppMission.IsSubsistenceMission() and gvars.isManualSubsistence~=this.SUBSISTENCE_BOUND then--tex disable
      TppBuddyService.SetDisableAllBuddy()
    end
    if TppGameSequence.GetGameTitleName()=="TPP"then
      if n.sequence and n.sequence.OnBuddyBlockLoad then
        n.sequence.OnBuddyBlockLoad()
      end
      if TppLocation.IsAfghan()or TppLocation.IsMiddleAfrica()then
        TppBuddy2BlockController.Load()
      end
    end
    TppSequence.SaveMissionStartSequence()
    TppScriptVars.SetSVarsNotificationEnabled(true)
  end
  if gvars.modParameters==0 then--tex use tweaked soldier parameters
  --tex REF: this.lifeParameterTableDefault={maxLife=2600,maxStamina=3e3,maxLimbLife=1500,maxArmorLife=7500,maxHelmetLife=500,sleepRecoverSec=300,faintRecoverSec=50,dyingSec=60}
    local healthMult=gvars.enemyHealthMult--tex mod enemy health scale
    this.lifeParameterTableMod.maxLife = TppMath.ScaleValueClamp1(this.lifeParameterTableDefault.maxLife,healthMult)
    this.lifeParameterTableMod.maxLimbLife = TppMath.ScaleValueClamp1(this.lifeParameterTableDefault.maxLimbLife,healthMult)
    this.lifeParameterTableMod.maxArmorLife = TppMath.ScaleValueClamp1(this.lifeParameterTableDefault.maxArmorLife,healthMult)
    this.lifeParameterTableMod.maxHelmetLife = TppMath.ScaleValueClamp1(this.lifeParameterTableDefault.maxHelmetLife,healthMult)
    TppSoldier2.ReloadSoldier2ParameterTables(this.soldierParametersMod)--tex reloadsoldierparams changes
  end--
  --this.LoadTrueDefaultEnemyParams()--tex DEBUG: CULL:
  if n.enemy then
    if t(n.enemy.soldierPowerSettings)then
      TppEnemy.SetUpPowerSettings(n.enemy.soldierPowerSettings)
    end
  end
  TppRevenge.DecideRevenge(n)
  if TppEquip.CreateEquipMissionBlockGroup then
    if(vars.missionCode>6e4)then
      TppEquip.CreateEquipMissionBlockGroup{size=(380*1024)*24}
    else
      TppPlayer.SetEquipMissionBlockGroupSize()
    end
  end
  if TppEquip.CreateEquipGhostBlockGroups then
    if TppSystemUtility.GetCurrentGameMode()=="MGO"then
      TppEquip.CreateEquipGhostBlockGroups{ghostCount=16}
    elseif TppMission.IsFOBMission(vars.missionCode)then
      TppEquip.CreateEquipGhostBlockGroups{ghostCount=1}
    end
  end
  TppEquip.StartLoadingToEquipMissionBlock()
  TppPlayer.SetMaxPickableLocatorCount()
  TppPlayer.SetMaxPlacedLocatorCount()
  TppEquip.AllocInstances{instance=60,realize=60}
  TppEquip.ActivateEquipSystem()
  if TppEnemy.IsRequiredToLoadDefaultSoldier2CommonPackage()then
    TppEnemy.LoadSoldier2CommonBlock()
  end
  if n.sequence then
    mvars.mis_baseList=n.sequence.baseList
    TppCheckPoint.RegisterCheckPointList(n.sequence.checkPointList)
  end
end
function this.OnInitialize(n)
  if TppMission.IsFOBMission(vars.missionCode)then
    TppMission.SetFobPlayerStartPoint()
  elseif TppMission.IsNeedSetMissionStartPositionToClusterPosition()then
    TppMission.SetMissionStartPositionMtbsClusterPosition()
    e.StageBlockCurrentPosition(true)
  else
    TppCheckPoint.SetCheckPointPosition()
  end
  if TppEnemy.IsRequiredToLoadSpecialSolider2CommonBlock()then
    TppEnemy.LoadSoldier2CommonBlock()
  end
  if TppMission.IsMissionStart()then
    TppTrap.InitializeVariableTraps()
  else
    TppTrap.RestoreVariableTrapState()
  end
  TppAnimalBlock.InitializeBlockStatus()
  if TppQuestList then
    TppQuest.RegisterQuestList(TppQuestList.questList)
    TppQuest.RegisterQuestPackList(TppQuestList.questPackList)
  end
  TppHelicopter.AdjustBuddyDropPoint()
  if n.sequence then
    local e=n.sequence.NPC_ENTRY_POINT_SETTING
    if t(e)then
      TppEnemy.NPCEntryPointSetting(e)
    end
  end
  TppLandingZone.OverwriteBuddyVehiclePosForALZ()
  if n.enemy then
    if t(n.enemy.vehicleSettings)then
      TppEnemy.SetUpVehicles()
    end
    if i(n.enemy.SpawnVehicleOnInitialize)then
      n.enemy.SpawnVehicleOnInitialize()
    end
    TppReinforceBlock.SetUpReinforceBlock()
  end
  for t,e in pairs(n)do
    if i(e.Messages)then
      n[t]._messageExecTable=Tpp.MakeMessageExecTable(e.Messages())
    end
  end
  if mvars.loc_locationCommonTable then
    mvars.loc_locationCommonTable.OnInitialize()
  end
  TppLandingZone.OnInitialize()
  for t,e in ipairs(Tpp._requireList)do
    if _G[e].Init then
      _G[e].Init(n)
    end
  end
  if n.enemy then
    if GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
      GameObject.SendCommand({type="TppSoldier2"},{id="CreateFaceIdList"})
    end
    if t(n.enemy.soldierDefine)then
      TppEnemy.DefineSoldiers(n.enemy.soldierDefine)
    end
    if n.enemy.InitEnemy and i(n.enemy.InitEnemy)then
      n.enemy.InitEnemy()
    end
    if t(n.enemy.soldierPersonalAbilitySettings)then
      TppEnemy.SetUpPersonalAbilitySettings(n.enemy.soldierPersonalAbilitySettings)
    end
    if t(n.enemy.travelPlans)then
      TppEnemy.SetTravelPlans(n.enemy.travelPlans)
    end
    TppEnemy.SetUpSoldiers()
    if t(n.enemy.soldierDefine)then
      TppEnemy.InitCpGroups()
      TppEnemy.RegistCpGroups(n.enemy.cpGroups)
      TppEnemy.SetCpGroups()
      if mvars.loc_locationGimmickCpConnectTable then
        TppGimmick.SetCommunicateGimmick(mvars.loc_locationGimmickCpConnectTable)
      end
    end
    if t(n.enemy.interrogation)then
      TppInterrogation.InitInterrogation(n.enemy.interrogation)
    end
    if t(n.enemy.useGeneInter)then
      TppInterrogation.AddGeneInter(n.enemy.useGeneInter)
    end
    if t(n.enemy.uniqueInterrogation)then
      TppInterrogation.InitUniqueInterrogation(n.enemy.uniqueInterrogation)
    end
    do
      local e
      if t(n.enemy.routeSets)then
        e=n.enemy.routeSets
        for e,n in pairs(e)do
          if not t(mvars.ene_soldierDefine[e])then
          end
        end
      end
      if e then
        TppEnemy.RegisterRouteSet(e)
        TppEnemy.MakeShiftChangeTable()
        TppEnemy.SetUpCommandPost()
        TppEnemy.SetUpSwitchRouteFunc()
      end
    end
    if n.enemy.soldierSubTypes then
      TppEnemy.SetUpSoldierSubTypes(n.enemy.soldierSubTypes)
    end
    TppRevenge.SetUpEnemy()
    TppEnemy.ApplyPowerSettingsOnInitialize()
    TppEnemy.ApplyPersonalAbilitySettingsOnInitialize()
    TppEnemy.SetOccasionalChatList()
    TppEneFova.ApplyUniqueSetting()
    if n.enemy.SetUpEnemy and i(n.enemy.SetUpEnemy)then
      n.enemy.SetUpEnemy()
    end
    if TppMission.IsMissionStart()then
      TppEnemy.RestoreOnMissionStart2()
    else
      TppEnemy.RestoreOnContinueFromCheckPoint2()
    end
  end
  if not TppMission.IsMissionStart()then
    TppWeather.RestoreFromSVars()
    TppMarker.RestoreMarkerLocator()
  end
  TppPlayer.RestoreSupplyCbox()
  TppPlayer.RestoreSupportAttack()
  TppTerminal.MakeMessage()
  if n.sequence then
    local e=n.sequence.SetUpRoutes
    if e and i(e)then
      e()
    end
    TppEnemy.RegisterRouteAnimation()
    local e=n.sequence.SetUpLocation
    if e and i(e)then
      e()
    end
  end
  for n,e in pairs(n)do
    if e.OnRestoreSVars then
      e.OnRestoreSVars()
    end
  end
  TppMission.RestoreShowMissionObjective()
  TppRevenge.SetUpRevengeMine()
  if TppPickable.StartToCreateFromLocators then
    TppPickable.StartToCreateFromLocators()
  end
  if TppPlaced and TppPlaced.StartToCreateFromLocators then
    TppPlaced.StartToCreateFromLocators()
  end
  if TppMission.IsMissionStart()then
    TppRadioCommand.RestoreRadioState()
  else
    TppRadioCommand.RestoreRadioStateContinueFromCheckpoint()
  end
  TppMission.PostMissionOrderBoxPositionToBuddyDog()
  e.SetUpdateFunction(n)
  e.SetMessageFunction(n)
  TppQuest.UpdateActiveQuest()
  TppDevelopFile.OnMissionCanStart()
  if (TppMission.GetMissionID()==30010 or TppMission.GetMissionID()==30020) then
    if TppQuest.IsActiveQuestHeli()then
      TppEnemy.ReserveQuestHeli()
    end
  end
  TppDemo.UpdateNuclearAbolitionFlag()
  TppQuest.AcquireKeyItemOnMissionStart()--tex NMC: 0006 patch
end
function this.SetUpdateFunction(e)
  o={}
  p=0
  T={}
  a=0
  d={}
  u=0
  o={TppMission.Update,TppSequence.Update,TppSave.Update,TppDemo.Update,TppPlayer.Update,TppMission.UpdateForMissionLoad}
  p=#o
  for n,e in pairs(e)do
    if i(e.OnUpdate)then
      a=a+1
      T[a]=e.OnUpdate
    end
  end
end
function this.OnEnterMissionPrepare()
  if TppMission.IsMissionStart()then
    TppScriptBlock.PreloadSettingOnMissionStart()
  end
  TppScriptBlock.ReloadScriptBlock()
end
function this.OnTextureLoadingWaitStart()
  if not TppMission.IsHelicopterSpace(vars.missionCode)then
    StageBlockCurrentPositionSetter.SetEnable(false)
  end
  gvars.canExceptionHandling=true
end
function this.OnMissionStartSaving()
end
function this.OnMissionCanStart()
  if TppMission.IsMissionStart()then
    TppWeather.SetDefaultWeatherProbabilities()
    TppWeather.SetDefaultWeatherDurations()
    if(not gvars.ini_isTitleMode)and(not TppMission.IsFOBMission(vars.missionCode))then
      TppSave.VarSave(nil,true)
    end
  end
  TppLocation.ActivateBlock()
  TppWeather.OnMissionCanStart()
  TppMarker.OnMissionCanStart()
  TppResult.OnMissionCanStart()
  TppQuest.InitializeQuestLoad()
  TppRatBird.OnMissionCanStart()
  TppMission.OnMissionStart()
  if mvars.loc_locationCommonTable then
    mvars.loc_locationCommonTable.OnMissionCanStart()
  end
  TppLandingZone.OnMissionCanStart()
  TppOutOfMissionRangeEffect.Disable(0)
  if TppLocation.IsMiddleAfrica()then
    TppGimmick.MafrRiverPrimSetting()
  end
  if MotherBaseConstructConnector.RefreshGimmicks then
    if vars.locationCode==TppDefine.LOCATION_ID.MTBS then
      MotherBaseConstructConnector.RefreshGimmicks()
    end
  end
  if vars.missionCode==10240 and TppLocation.IsMBQF()then
    Player.AttachGasMask()
  end
end
function this.OnMissionGameStart(n)
  TppClock.Start()
  if not gvars.ini_isTitleMode then
    PlayRecord.RegistPlayRecord"MISSION_START"end
  TppQuest.InitializeQuestActiveStatus()
  if mvars.seq_demoSequneceList[mvars.seq_missionStartSequence]then
    e.EnableGameStatusForDemo()
  else
    e.EnableGameStatus()
  end
  if Player.RequestChickenHeadSound~=nil then
    Player.RequestChickenHeadSound()
  end
  TppTerminal.OnMissionGameStart()
  if TppSequence.IsLandContinue()then
    TppMission.EnableAlertOutOfMissionAreaIfAlertAreaStart()
  end
  TppSoundDaemon.ResetMute"Telop"
end
function this.ClearStageBlockMessage()
  StageBlock.ClearLargeBlockNameForMessage()
  StageBlock.ClearSmallBlockIndexForMessage()
end
--tex REF: working some better var names out
-- called from tppmission:VarSaveForMissionAbort && Executemissionfinalize
--(TppDefine.MISSION_LOAD_TYPE.MISSION_ABORT,o=ishelispace,s=isfreemission,t=isheli(mvars.mis_nextMissionCodeForAbort),i=IsFreeMission(mvars.mis_nextMissionCodeForAbort),a=mvars.mis_isAbortWithSave|nil,p=vars.missioncode changed)
function this.ReservePlayerLoadingPosition(loadType,isMissionHeliSpace,isMissionFreeMission,isAbortMissionHeliSpace,isAbortMissionFreeMission,isAbortWithSave,isMissionCodeChanged)
  this.DisableGameStatus()
  if loadType==TppDefine.MISSION_LOAD_TYPE.MISSION_FINALIZE then
    if isAbortMissionHeliSpace then
      TppHelicopter.ResetMissionStartHelicopterRoute()
      TppPlayer.ResetInitialPosition()
      TppPlayer.ResetMissionStartPosition()
      TppPlayer.ResetNoOrderBoxMissionStartPosition()
      TppMission.ResetIsStartFromHelispace()
      TppMission.ResetIsStartFromFreePlay()
    elseif isMissionHeliSpace then
      if gvars.heli_missionStartRoute~=0 then
        TppPlayer.SetStartStatusRideOnHelicopter()
        if mvars.mis_helicopterMissionStartPosition then
          TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
          TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
        end
      else
        TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
        local e=TppDefine.NO_HELICOPTER_MISSION_START_POSITION[vars.missionCode]
        if e then
          TppPlayer.SetInitialPosition(e,0)
          TppPlayer.SetMissionStartPosition(e,0)
        else
          TppPlayer.ResetInitialPosition()
          TppPlayer.ResetMissionStartPosition()
        end
      end
      TppPlayer.ResetNoOrderBoxMissionStartPosition()
      TppMission.SetIsStartFromHelispace()
      TppMission.ResetIsStartFromFreePlay()
    elseif isAbortMissionFreeMission then
      if TppLocation.IsMotherBase()then
        TppPlayer.SetStartStatusRideOnHelicopter()
      else
        TppPlayer.ResetInitialPosition()
        TppHelicopter.ResetMissionStartHelicopterRoute()
        TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
        TppPlayer.SetMissionStartPositionToCurrentPosition()
      end
      TppPlayer.ResetNoOrderBoxMissionStartPosition()
      TppMission.ResetIsStartFromHelispace()
      TppMission.ResetIsStartFromFreePlay()
      TppLocation.MbFreeSpecialMissionStartSetting(TppMission.GetMissionClearType())
    elseif(isMissionFreeMission and TppLocation.IsMotherBase())then
      if gvars.heli_missionStartRoute~=0 then
        TppPlayer.SetStartStatusRideOnHelicopter()
      else
        TppPlayer.ResetInitialPosition()
        TppPlayer.ResetMissionStartPosition()
      end
      TppPlayer.ResetNoOrderBoxMissionStartPosition()
      TppMission.SetIsStartFromHelispace()
      TppMission.ResetIsStartFromFreePlay()
    else
      if isMissionFreeMission then
        if mvars.mis_orderBoxName then
          TppMission.SetMissionOrderBoxPosition()
          TppPlayer.ResetNoOrderBoxMissionStartPosition()
        else
          TppPlayer.ResetInitialPosition()
          TppPlayer.ResetMissionStartPosition()
          local e={
          [10020]={1449.3460693359,339.18698120117,1467.4300537109,-104},
          [10050]={-1820.7060546875,349.78659057617,-146.44400024414,139},
          [10070]={-792.00512695313,537.3740234375,-1381.4598388672,136},
          [10080]={-439.28802490234,-20.472593307495,1336.2784423828,-151},
          [10140]={499.91635131836,13.07358455658,1135.1315917969,79},
          [10150]={-1732.0286865234,543.94067382813,-2225.7587890625,162},
          [10260]={-1260.0454101563,298.75305175781,1325.6383056641,51}
          }
          e[11050]=e[10050]
          e[11080]=e[10080]
          e[11140]=e[10140]
          e[10151]=e[10150]
          e[11151]=e[10150]
          local e=e[vars.missionCode]
          if TppDefine.NO_ORDER_BOX_MISSION_ENUM[tostring(vars.missionCode)]and e then
            TppPlayer.SetNoOrderBoxMissionStartPosition(e,e[4])
          else
            TppPlayer.ResetNoOrderBoxMissionStartPosition()
          end
        end
        local e=TppDefine.NO_ORDER_FIX_HELICOPTER_ROUTE[vars.missionCode]
        if e then--tex added issub check
          TppPlayer.SetStartStatusRideOnHelicopter()
          TppMission.SetIsStartFromHelispace()
          TppMission.ResetIsStartFromFreePlay()
        else
          TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
          TppHelicopter.ResetMissionStartHelicopterRoute()
          TppMission.ResetIsStartFromHelispace()
          TppMission.SetIsStartFromFreePlay()
        end
        local e=TppMission.GetMissionClearType()
        TppQuest.SpecialMissionStartSetting(e)
      else
        TppPlayer.ResetInitialPosition()
        TppPlayer.ResetMissionStartPosition()
        TppPlayer.ResetNoOrderBoxMissionStartPosition()
        TppMission.ResetIsStartFromHelispace()
        TppMission.ResetIsStartFromFreePlay()
      end
    end
  elseif loadType==TppDefine.MISSION_LOAD_TYPE.MISSION_ABORT then
    TppPlayer.ResetInitialPosition()
    TppHelicopter.ResetMissionStartHelicopterRoute()
    TppMission.ResetIsStartFromHelispace()
    TppMission.ResetIsStartFromFreePlay()
    if isAbortWithSave then
      if isAbortMissionFreeMission then
        TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
        TppHelicopter.ResetMissionStartHelicopterRoute()
        TppPlayer.SetMissionStartPositionToCurrentPosition()
        TppPlayer.ResetNoOrderBoxMissionStartPosition()
      elseif isAbortMissionHeliSpace then
        TppPlayer.ResetMissionStartPosition()
      elseif vars.missionCode~=5 then
      end
    else
      if isAbortMissionHeliSpace then
        TppHelicopter.ResetMissionStartHelicopterRoute()
        TppPlayer.ResetInitialPosition()
        TppPlayer.ResetMissionStartPosition()
      elseif isAbortMissionFreeMission then
        TppMission.SetMissionOrderBoxPosition()
      elseif vars.missionCode~=5 then
      end
    end
  elseif loadType==TppDefine.MISSION_LOAD_TYPE.MISSION_RESTART then
  elseif loadType==TppDefine.MISSION_LOAD_TYPE.CONTINUE_FROM_CHECK_POINT then
  end
  if isMissionHeliSpace and isMissionCodeChanged then
    Mission.AddLocationFinalizer(function()this.StageBlockCurrentPosition()end)
  else
    this.StageBlockCurrentPosition()
  end
end
function this.StageBlockCurrentPosition(e)
  if vars.initialPlayerFlag==PlayerFlag.USE_VARS_FOR_INITIAL_POS then
    StageBlockCurrentPositionSetter.SetEnable(true)
    StageBlockCurrentPositionSetter.SetPosition(vars.initialPlayerPosX,vars.initialPlayerPosZ)
  else
    StageBlockCurrentPositionSetter.SetEnable(false)
  end
  if TppMission.IsHelicopterSpace(vars.missionCode)then
    StageBlockCurrentPositionSetter.SetEnable(true)
    StageBlockCurrentPositionSetter.DisablePosition()
    if e then
      while not StageBlock.LargeAndSmallBlocksAreEmpty()do
        coroutine.yield()
      end
    end
  end
end
function this.OnReload(n)
  for t,e in pairs(n)do
    if i(e.OnLoad)then
      e.OnLoad()
    end
    if i(e.Messages)then
      n[t]._messageExecTable=Tpp.MakeMessageExecTable(e.Messages())
    end
  end
  if n.enemy then
    if t(n.enemy.routeSets)then
      TppClock.UnregisterClockMessage"ShiftChangeAtNight"
      TppClock.UnregisterClockMessage"ShiftChangeAtMorning"
      TppEnemy.RegisterRouteSet(n.enemy.routeSets)
      TppEnemy.MakeShiftChangeTable()
    end
  end
  for t,e in ipairs(Tpp._requireList)do
    if _G[e].OnReload then
      _G[e].OnReload(n)
    end
  end
  if mvars.loc_locationCommonTable then
    mvars.loc_locationCommonTable.OnReload()
  end
  if n.sequence then
    TppCheckPoint.RegisterCheckPointList(n.sequence.checkPointList)
  end
  this.SetUpdateFunction(n)
  this.SetMessageFunction(n)
end
function this.OnUpdate(e)
  local e
  local n=o
  local t=T
  local e=d
  for e=1,p do
    n[e]()
  end
  for e=1,a do
    t[e]()
  end
  m()
end
function this.OnChangeSVars(e,n,t)
  for i,e in ipairs(Tpp._requireList)do
    if _G[e].OnChangeSVars then
      _G[e].OnChangeSVars(n,t)
    end
  end
end
function this.SetMessageFunction(e)
  S={}
  s=0
  c={}
  r=0
  for n,e in ipairs(Tpp._requireList)do
    if _G[e].OnMessage then
      s=s+1
      S[s]=_G[e].OnMessage
    end
  end
  for n,t in pairs(e)do
    if e[n]._messageExecTable then
      r=r+1
      c[r]=e[n]._messageExecTable
    end
  end
end
function this.OnMessage(e,n,t,i,l,a,p)
  local e=mvars
  local o=""
  local T
  local m=Tpp.DoMessage
  local d=TppMission.CheckMessageOption
  local T=TppDebug
  local T=P
  local T=h
  local T=TppDefine.MESSAGE_GENERATION[n]and TppDefine.MESSAGE_GENERATION[n][t]
  if not T then
    T=TppDefine.DEFAULT_MESSAGE_GENERATION
  end
  local u=M()
  if u<T then
    return Mission.ON_MESSAGE_RESULT_RESEND
  end
  for e=1,s do
    local o=o
    S[e](n,t,i,l,a,p,o)
  end
  for e=1,r do
    local o=o
    m(c[e],d,n,t,i,l,a,p,o)
  end
  if e.loc_locationCommonTable then
    e.loc_locationCommonTable.OnMessage(n,t,i,l,a,p,o)
  end
  if e.order_box_script then
    e.order_box_script.OnMessage(n,t,i,l,a,p,o)
  end
  if e.animalBlockScript and e.animalBlockScript.OnMessage then
    e.animalBlockScript.OnMessage(n,t,i,l,a,p,o)
  end
end
function this.OnTerminate(e)
  if e.sequence then
    if i(e.sequence.OnTerminate)then
      e.sequence.OnTerminate()
    end
  end
end
return this

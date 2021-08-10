--AFN0.lua
local this={
  description="Red Fortress",
  locationName="AFN0",
  locationId=102,
  packs={"/Assets/mgo/pack/location/afn0/afn0.fpk"},
  locationMapParams={
    stageSize=582*1,
    scrollMaxLeftUpPosition=Vector3(-291,0,-202.5),
    scrollMaxRightDownPosition=Vector3(44.5,0,133),
    highZoomScale=2,
    middleZoomScale=1,
    lowZoomScale=.5,
    locationNameLangId="tpp_loc_afn0",--"mgo_idt_Hill",
    stageRotate=0,
    heightMapTexturePath="/Assets/mgo/ui/texture/map/afn0/afn0_iDroid_clp.ftex",
    photoRealMapTexturePath="/Assets/mgo/ui/texture/map/afn0/afn0_hill_sat_clp.ftex"
  },--locationMapParams
  questAreas={      
    --tex only one area covering map
    {
      areaName="afn0",
      --xMin,yMin,xMax,yMax
      --a bit bigger than it needs to be but whatever
      loadArea={102,102,107,107},
      activeArea={103,103,106,106},
      invokeArea={103,103,106,106},
    },
  },--questAreas
  requestTppBuddy2BlockController=true,
  --tex location afn0_common.fpk afn0_climateSettings.twpf doesnt have weather support
  --times/weather the twpf does support in Utils.WeatherRequest
  --6:12 - clear,sandstorm
  --1:00 - clear,sandstorm
  weatherProbabilities={
    {TppDefine.WEATHER.SUNNY,100},
    --{TppDefine.WEATHER.CLOUDY,70},
    --{TppDefine.WEATHER.SUNNY,30},
  },
  extraWeatherProbabilities={
    {TppDefine.WEATHER.SANDSTORM,100},
  },
}--this
return this

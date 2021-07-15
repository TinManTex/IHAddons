local this={
  description="Gray Rampart",
  locationName="AFDA",
  locationId=103,
  packs={"/Assets/mgo/pack/location/afda/afda.fpk"},
  locationMapParams={
    stageSize=336*1,
    scrollMaxLeftUpPosition=Vector3(-138,0,-155),
    scrollMaxRightDownPosition=Vector3(168,0,151),
    highZoomScale=2,
    middleZoomScale=1,
    lowZoomScale=.5,
    locationNameLangId="tpp_loc_afda",--"mgo_idt_Dam",
    stageRotate=0,
    heightMapTexturePath="/Assets/mgo/ui/texture/map/afda/afda_iDroid_clp.ftex",
    photoRealMapTexturePath="/Assets/mgo/ui/texture/map/afda/afda_dam_sat_clp.ftex"
  },--
  questAreas={      
    --tex only one area covering map
    {
      areaName="afda",
      --xMin,yMin,xMax,yMax
      --a bit bigger than it needs to be but whatever
      loadArea={102,102,107,107},
      activeArea={103,103,106,106},
      invokeArea={103,103,106,106},
    },
  },
  requestTppBuddy2BlockController=true,
  --tex location afc1_common.fpk afc1_climateSettings.twpf doesnt have weather support
  --times/weather the twpf does support in Utils.WeatherRequest
  --6:30 - cloudy,rainy
  --1:00 - clear,rainy
  weatherProbabilities={
    {TppDefine.WEATHER.CLOUDY,100},  
    --{TppDefine.WEATHER.CLOUDY,70},
    --{TppDefine.WEATHER.SUNNY,30},
  },
  extraWeatherProbabilities={
    {TppDefine.WEATHER.RAINY,100},
    --{TppDefine.WEATHER.RAINY,60},
    --{TppDefine.WEATHER.FOGGY,40},
  },
}--this locationMapParams
return this

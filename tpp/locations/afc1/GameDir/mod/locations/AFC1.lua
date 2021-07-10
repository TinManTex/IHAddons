local this={
  description="Amber Station",
  locationName="AFC1",
  locationId=104,
  packs={"/Assets/mgo/pack/location/afc1/afc1.fpk"},
  locationMapParams={
   stageSize=276*1,
    scrollMaxLeftUpPosition=Vector3(-128,0,-128),
    scrollMaxRightDownPosition=Vector3(138,0,128),
    highZoomScale=2,
    middleZoomScale=1,
    lowZoomScale=.5,
    locationNameLangId="tpp_loc_afc1",--"mgo_idt_Africa",
    stageRotate=0,
    heightMapTexturePath="/Assets/mgo/ui/texture/map/afc1/afc1_iDroid_clp.ftex",
    photoRealMapTexturePath="/Assets/mgo/ui/texture/map/afc1/afc1_indus_sat_clp.ftex"
  },
  questAreas={      
    --tex only one area covering map
    {
      areaName="afc1",
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
    {TppDefine.WEATHER.CLOUDY,70}
    {TppDefine.WEATHER.SUNNY,30},
  },
  extraWeatherProbabilities={
    {TppDefine.WEATHER.RAINY,100},
    --{TppDefine.WEATHER.RAINY,60},
    --{TppDefine.WEATHER.FOGGY,40},
  },
}--this
return this

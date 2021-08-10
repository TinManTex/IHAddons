local this={
  description="Jade Forest",
  locationName="AFC0",
  locationId=101,
  packs={"/Assets/mgo/pack/location/afc0/afc0.fpk"},
  locationMapParams={
    stageSize=556*1,
    scrollMaxLeftUpPosition=Vector3(-255,0,-275),
    scrollMaxRightDownPosition=Vector3(255,0,275),
    highZoomScale=2,
    middleZoomScale=1,
    lowZoomScale=.5,
    locationNameLangId="tpp_loc_afc0",--"mgo_idt_Jungle",
    stageRotate=0,
    heightMapTexturePath="/Assets/mgo/ui/texture/map/afc0/afc0_iDroid_clp.ftex",
    photoRealMapTexturePath="/Assets/mgo/ui/texture/map/afc0/afc0_jungle_sat_clp.ftex"
  },
  questAreas={      
    --tex only one area covering map
    {
      areaName="afc0",
      --xMin,yMin,xMax,yMax
      loadArea={102,102,107,107},
      activeArea={103,103,106,106},
      invokeArea={103,103,106,106},
    },
  },
  requestTppBuddy2BlockController=true,
  --tex location afc0_common.fpk afc0_climateSettings.twpf doesnt have all weather support
  --times/weather the twpf does support in Utils.WeatherRequest
  --15:00 - clear,rainy
  --1:00  - clear,cloudy
  weatherProbabilities={
    {TppDefine.WEATHER.SUNNY,60},
    {TppDefine.WEATHER.CLOUDY,40}
  },
  extraWeatherProbabilities={
    --{TppDefine.WEATHER.RAINY,60},
    --{TppDefine.WEATHER.FOGGY,40},
  },
}--this

return this

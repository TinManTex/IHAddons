local this={
	description="Jade Forest",
	missionCode=12020,
    location="AFC0",
    packs=function(missionCode)
      TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_WAIT)
      TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s12000/s12000_area.fpk"
    end,--DEBUGNOW
    startPos={-11.788,8.483,165.559},--rotY=-30.511,},--DEBUGNOW
}

return this
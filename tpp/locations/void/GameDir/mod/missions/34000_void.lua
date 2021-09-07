local this={	
	missionCode=34000,
    location="VOID",
    missionPacks=function(missionCode)
    	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/minimal_mission.fpk"
    	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/fvoid/fvoid_mission.fpk"
    	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/quest_block.fpk"
    end,--missionPacks
    startPos={0,0,0},
}--this
return this
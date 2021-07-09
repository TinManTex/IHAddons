local this={
	description="Amber Station Free Roam",
	missionCode=33004,
	location="AFC1",
	startPos={3.847,-5.105,79.635},--rotY=159.648,},
	packs=function(missionCode)
    	TppPackList.AddMissionPack"/Assets/mgo/pack/location/afc0/pack_common/afc0_script.fpk"--REF TppPackList.AddLocationCommonScriptPack(missionCode), not set up for addon locations. even though mgo location doesnt have common script pack keeping it in there just to be consistant with the other location packs
	    --REF TppPackList.AddLocationCommonMissionAreaPack(missionCode)-- not set up for addon locations --> 
	    --TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_helicopter.fpk"--MISSION_COMMON_PACK.HELICOPTER
	    --TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"--MISSION_COMMON_PACK.MAFR_MISSION_AREA--tex actually soldier pack, added below
	    --TppPackList.AddMissionPack"/Assets/tpp/pack/collectible/decoy/decoy_pf.fpk"--MISSION_COMMON_PACK.MAFR_DECOY
	    --<
	    --TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_order_box.fpk",--MISSION_COMMON_PACK.ORDER_BOX)
	    --tex split out a lot of stuff that's usually bundled in mission pack
	    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/bgm_fob_ih.fpk"
	    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/ih_soldier_base.fpk"--tex mis_com_mafr isn't actually a complete enemy pack, normal missions roll these files into the mission packs
	    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"--soldier pack
	    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/snd_ene_af.fpk"--EnemyType.TYPE_PF, CpType.TYPE_AFRIKAANS
	    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/subs_boot_ene_af.fpk"-- f30020_subtitles -> <lang>Voice/<lang>Text/ene_common_af.subp,_str.subp
	    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/quest_block.fpk"--DEBUGNOW test if solder locators work here or if they need to be after Soldier2GameObject in _mission pack
	    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/fafc1/fafc1_mission.fpk"--tex deviating from the norm a bit and naming it after location rather than free missioncode, also vanilla free mission packs dont have _mission suffix, story have _area to indicate they are just part of the location I guess
  	end,--packs
  },
}--this
return this

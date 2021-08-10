local this={
	description="Red Fortress Free Roam",
	missionCode=33002,
	location="AFN0",
	startPos={240.353,4.580,135.816},--rotY=-118.252,},
	packs=function(missionCode)
	--DEBUGNOW TppPackList.AddMissionPack"/Assets/mgo/pack/location/afda/pack_common/afda_script.fpk"--REF TppPackList.AddLocationCommonScriptPack(missionCode), not set up for addon locations. even though mgo location doesnt have common script pack keeping it in there just to be consistant with the other location packs
	  --REF TppPackList.AddLocationCommonMissionAreaPack(missionCode)-- not set up for addon locations --> 
	  --TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_helicopter.fpk"--MISSION_COMMON_PACK.HELICOPTER
	  --TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"--MISSION_COMMON_PACK.MAFR_MISSION_AREA--tex actually soldier pack, added below
	  --TppPackList.AddMissionPack"/Assets/tpp/pack/collectible/decoy/decoy_pf.fpk"--MISSION_COMMON_PACK.MAFR_DECOY
	  --<
	  --TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_order_box.fpk",--MISSION_COMMON_PACK.ORDER_BOX)
	  --tex split out a lot of stuff that's usually bundled in mission pack
	  
	  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/ih_soldier_base.fpk"--tex mis_com_mafr isn't actually a complete enemy pack, normal missions roll these files into the mission packs
	  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_afgh.fpk"--soldier pack
	  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/snd_ene_ru.fpk"--EnemyType.TYPE_SOVIET, CpType.TYPE_SOVIET
	  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/subs_boot_ene_ru.fpk"-- f30010_subtitles -> <lang>Voice/<lang>Text/ene_common_ru.subp,_str.subp
	  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/quest_block.fpk"--DEBUGNOW test if solder locators work here or if they need to be after Soldier2GameObject in _mission pack
	  --
	  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/fafn0/fafn0_mission.fpk"--tex deviating from the norm a bit and naming it after location rather than free missioncode, also vanilla free mission packs dont have _mission suffix, story have _area to indicate they are just part of the location I guess
	  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/bgm_fob_ih.fpk"
	end,--packs
	fovaSetupFunc=function(locationName,missionId)
		TppEneFova.SetupFovaForLocation"afgh"
		TppSoldierFace.SetUseZombieFova{enabled=true}
		--tex from f30020, but hangs using a SideopsCompanion built hostage quest
		-- local body={{TppEnemyBodyId.prs6_main0_v00,EnemyFova.MAX_REALIZED_COUNT}}
		-- TppSoldierFace.OverwriteMissionFovaData{body=body}
		-- TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs6_main0_v00}}
		-- TppHostage2.SetDefaultBodyFovaId{parts="/Assets/tpp/parts/chara/prs/prs6_main0_def_v00.parts",bodyId=TppEnemyBodyId.prs6_main0_v00}
	end,--fovaSetupFunc
	missionMapParams={
		--tex TODO: no actual heli support yet, but these work as start on foot
		heliLandPoint={
		  {
		    point=Vector3(240.353,4.580,135.816),
		    startPoint=Vector3(240.353,4.580,135.816),
		    routeId="lz_drp_creek_S|rt_drp_creek_S",--DEBUGNOW NAME
		  },
		  {
		    point=Vector3(250.9509,14.68579,-20.3357),
		    startPoint=Vector3(250.9509,14.68579,-20.3357),
		    routeId="lz_drp_entrance_N|rt_drp_entrance_N",--Northeast entrance
		  },
		  {
		    point=Vector3(102.823,9.978523,183.4415),
		    startPoint=Vector3(102.823,9.978523,183.4415),
		    routeId="lz_drp_entrance_S|rt_drp_entrance_S",--Northeast entrance
		  },
		  {
		    point=Vector3(153.7262,16.33193,-139.1948),
		    startPoint=Vector3(153.7262,16.33193,-139.1948),
		    routeId="lz_drp_cliff_N|rt_drp_cliff_N",--Northeast entrance
		  },
		},--heliLandPoint
	},--missionMapParams
}--this
return this
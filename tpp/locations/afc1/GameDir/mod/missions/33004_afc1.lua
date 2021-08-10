local this={
	description="Amber Station Free Roam",
	missionCode=33004,
	location="AFC1",
	startPos={3.847,-5.105,79.635},--rotY=159.648,},--south main entrance
	--{pos={46.245,6.992,-90.018},rotY=106.905,},--north east pipe fence
	--{pos={-47.508,-5.277,-97.715},rotY=23.791,},--north west entrance
	--{pos={-88.233,-7.741,50.745},rotY=-158.378,},--south west ship
	--{pos={93.708,-5.128,74.872},rotY=-124.019,},--south east yard
	packs=function(missionCode)
		--DEBUGNOW TppPackList.AddMissionPack"/Assets/mgo/pack/location/afc1/pack_common/afc1_script.fpk"--REF TppPackList.AddLocationCommonScriptPack(missionCode), not set up for addon locations. even though mgo location doesnt have common script pack keeping it in there just to be consistant with the other location packs
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
	    --TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/motion_player_pipe.fpk"--DEBUGNOW IH r256
	end,--packs
	fovaSetupFunc=function(locationName,missionId)
		TppEneFova.SetupFovaForLocation("mafr")
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
				point=Vector3(3.847,-5.105,79.635),
				startPoint=Vector3(3.847,-5.105,79.635),
				routeId="lz_drp_afc1_entrance_S|rt_drp_afc1_entrance_S",
			},
			{
				point=Vector3(46.245,6.992,-90.018),
				startPoint=Vector3(46.245,6.992,-90.018),
				routeId="lz_drp_afc1_pipefence_N|rt_drp_afc1_pipefence_N",
			},
			{
				point=Vector3(-47.508,-5.277,-97.715),
				startPoint=Vector3(-47.508,-5.277,-97.715),
				routeId="lz_drp_afc1_entrance_N|rt_drp_afc1_entrance_N",
			},
			{
				point=Vector3(-88.233,-7.741,50.745),
				startPoint=Vector3(-88.233,-7.741,50.745),
				routeId="lz_drp_afc1_ship_S|rt_drp_afc1_ship_S",
			},
			{
				point=Vector3(93.708,-5.128,74.872),
				startPoint=Vector3(93.708,-5.128,74.872),
				routeId="lz_drp_afc1_yard_S|rt_drp_afc1_yard_S",
			},
		},--heliLandPoint
	},--missionMapParams
}--this
return this

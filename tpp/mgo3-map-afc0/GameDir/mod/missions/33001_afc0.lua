local this={	
  description="Jade Forest Free Roam",
  missionCode=33001,
  location="AFC0",  
  startPos={-71.862,0.584,248.143},--rotY=143.701,},--bottom of map by river
  --startPos={-11.788,8.483,165.559},--rotY=-30.511,},--mgo title pos next to radio
  packs=function(missionCode)
    --TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
    --TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV)
    --TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV_CANNON)
    --TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)
    --TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_DECOY)
    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/bgm_fob_ih.fpk"
    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/ih_soldier_base.fpk"--tex mis_com_mafr isn't actually a complete enemy pack, normal missions roll these files into the mission packs
    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"
    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/snd_ene_af.fpk"--EnemyType.TYPE_PF, CpType.TYPE_AFRIKAANS
    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/subs_boot_ene_af.fpk"-- f30020_subtitles -> <lang>Voice/<lang>Text/ene_common_af.subp,_str.subp
    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/ih/quest_block.fpk"--DEBUGNOW test if solder locators work here or if they need to be after Soldier2GameObject in _mission pack
    TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/fafc0/fafc0_mission.fpk"
  end,
  fovaSetupFunc=function(locationName,missionId)
    TppEneFova.SetupFovaForLocation("mafr")
    TppSoldierFace.SetUseZombieFova{enabled=true}
    --tex from f30020, but hangs using a SideopsCompanion built hostage quest
    -- local body={{TppEnemyBodyId.prs6_main0_v00,EnemyFova.MAX_REALIZED_COUNT}}
    -- TppSoldierFace.OverwriteMissionFovaData{body=body}
    -- TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs6_main0_v00}}
    -- TppHostage2.SetDefaultBodyFovaId{parts="/Assets/tpp/parts/chara/prs/prs6_main0_def_v00.parts",bodyId=TppEnemyBodyId.prs6_main0_v00}
  end,
}

return this
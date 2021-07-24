local this={}
local StrCode32=InfCore.StrCode32
local StrCode32Table=Tpp.StrCode32Table
local GetGameObjectId=GameObject.GetGameObjectId
local NULL_ID=GameObject.NULL_ID
local SendCommand=GameObject.SendCommand

this.requires={}

--tex requires the proper vox_ene_common_ soundbank to be loaded, see InfSoundInfo for pack paths 
--or add the required voxs to your sdf loadbanks
this.cpTypes=CpType.TYPE_SOVIET--tex apply to all cps

--REF TppEnemy._AnnouncePhaseChange, cpSubTypeToLangId
--this.cpAnounceLangIds="cmmn_ene_pf"--tex apply to all cps

this.cpSubTypes="SOVIET_B"--tex apply to all cps

this.soldierDefine={
	afda_turbine_cp={
		"sol_afda_0000",
		"sol_afda_0001",
		"sol_afda_0002",
		"sol_afda_0003",
		"sol_afda_0004",
		"sol_afda_0005",
		"sol_afda_0006",
		"sol_afda_0007",
		"sol_afda_0008",
		"sol_afda_0009",
		"sol_afda_0010",
		"sol_afda_0011",
		"sol_afda_0012",
		"sol_afda_0013",
		"sol_afda_0014",
		"sol_afda_0015",
		"sol_afda_0016",
		"sol_afda_0017",
		"sol_afda_0018",
		"sol_afda_0019",
		"sol_afda_0020",
		"sol_afda_0021",
		"sol_afda_0022",
		"sol_afda_0023",
		"sol_afda_0024",
		"sol_afda_0025",
		"sol_afda_0026",
		"sol_afda_0027",
		"sol_afda_0028",
		"sol_afda_0029",
		"sol_afda_0030",
		"sol_afda_0031",
		"sol_afda_0032",
		"sol_afda_0033",
		"sol_afda_0034",
		"sol_afda_0035",
		"sol_afda_0036",
		"sol_afda_0037",
		"sol_afda_0038",
		"sol_afda_0039",
	},--afda_turbine_cp
	quest_cp={
		"sol_quest_0000",
		"sol_quest_0001",
		"sol_quest_0002",
		"sol_quest_0003",
		"sol_quest_0004",
		"sol_quest_0005",
		"sol_quest_0006",
		"sol_quest_0007",
	},
}--soldierDefine

this.soldierTypes="SOVIET"--REF EnemyType["TYPE_"..soldierType]--tex apply to all soldiers

this.soldierSubTypes=true--tex true = use cpSubTypes to define soldier subtypes

this.routeSets={
	--TODO move to common routesets once theyre solid - \Assets\mgo\pack\location\afc0\pack_common\afda_script.fpkd
	afda_turbine_cp={
		priority={
			"groupA",
			"groupB",
			"groupC",
			"groupD",
		},
		sneak_day={
			groupA={
				"rt_afda_c_0000",
				"rt_afda_c_0001",
				"rt_afda_c_0002",
				"rt_afda_c_0003",
				"rt_afda_c_0004",
				"rt_afda_c_0005",
				"rt_afda_c_0006",
				"rt_afda_c_0007",
				"rt_afda_c_0008",
				"rt_afda_c_0009",
				"rt_afda_c_0010",
				"rt_afda_c_0011",
				"rt_afda_c_0012",
				"rt_afda_c_0013",
				"rt_afda_c_0014",
				"rt_afda_c_0015",
				"rt_afda_c_0016",
				"rt_afda_c_0017",
				"rt_afda_c_0018",
				"rt_afda_c_0019",
				"rt_afda_c_0020",
				"rt_afda_c_0021",
				"rt_afda_c_0022",
				"rt_afda_c_0023",
				"rt_afda_c_0024",
				"rt_afda_c_0025",
				"rt_afda_c_0026",
				"rt_afda_c_0027",
				"rt_afda_c_0028",
				"rt_afda_c_0029",
				"rt_afda_c_0030",
				"rt_afda_c_0031",
				"rt_afda_c_0032",
				"rt_afda_c_0033",
				"rt_afda_c_0034",
				"rt_afda_c_0035",
				"rt_afda_c_0036",
				"rt_afda_c_0037",
				"rt_afda_c_0038",
				"rt_afda_c_0039",
			},
		},--sneak_day
		sneak_night= {
			groupA={
				"rt_afda_c_0000",
				"rt_afda_c_0001",
				"rt_afda_c_0002",
				"rt_afda_c_0003",
				"rt_afda_c_0004",
				"rt_afda_c_0005",
				"rt_afda_c_0006",
				"rt_afda_c_0007",
				"rt_afda_c_0008",
				"rt_afda_c_0009",
				"rt_afda_c_0010",
				"rt_afda_c_0011",
				"rt_afda_c_0012",
				"rt_afda_c_0013",
				"rt_afda_c_0014",
				"rt_afda_c_0015",
				"rt_afda_c_0016",
				"rt_afda_c_0017",
				"rt_afda_c_0018",
				"rt_afda_c_0019",
				"rt_afda_c_0020",
				"rt_afda_c_0021",
				"rt_afda_c_0022",
				"rt_afda_c_0023",
				"rt_afda_c_0024",
				"rt_afda_c_0025",
				"rt_afda_c_0026",
				"rt_afda_c_0027",
				"rt_afda_c_0028",
				"rt_afda_c_0029",
				"rt_afda_c_0030",
				"rt_afda_c_0031",
				"rt_afda_c_0032",
				"rt_afda_c_0033",
				"rt_afda_c_0034",
				"rt_afda_c_0035",
				"rt_afda_c_0036",
				"rt_afda_c_0037",
				"rt_afda_c_0038",
				"rt_afda_c_0039",
			},
		},--sneak_night
		caution={
			groupA={
				"rt_afda_c_0000",
				"rt_afda_c_0001",
				"rt_afda_c_0002",
				"rt_afda_c_0003",
				"rt_afda_c_0004",
				"rt_afda_c_0005",
				"rt_afda_c_0006",
				"rt_afda_c_0007",
				"rt_afda_c_0008",
				"rt_afda_c_0009",
				"rt_afda_c_0010",
				"rt_afda_c_0011",
				"rt_afda_c_0012",
				"rt_afda_c_0013",
				"rt_afda_c_0014",
				"rt_afda_c_0015",
				"rt_afda_c_0016",
				"rt_afda_c_0017",
				"rt_afda_c_0018",
				"rt_afda_c_0019",
				"rt_afda_c_0020",
				"rt_afda_c_0021",
				"rt_afda_c_0022",
				"rt_afda_c_0023",
				"rt_afda_c_0024",
				"rt_afda_c_0025",
				"rt_afda_c_0026",
				"rt_afda_c_0027",
				"rt_afda_c_0028",
				"rt_afda_c_0029",
				"rt_afda_c_0030",
				"rt_afda_c_0031",
				"rt_afda_c_0032",
				"rt_afda_c_0033",
				"rt_afda_c_0034",
				"rt_afda_c_0035",
				"rt_afda_c_0036",
				"rt_afda_c_0037",
				"rt_afda_c_0038",
				"rt_afda_c_0039",
			},
		},--caution
	},--afda_turbine_cp
	quest_cp={USE_COMMON_ROUTE_SETS=true,},--DEBUGNOW TODO
}--routeSets

this.combatSetting={
	--TODO move to common combat script
	afda_turbine_cp={
		"TppGuardTargetData0000",
		"TppGuardTargetData0001",
		"TppGuardTargetData0002",
		"TppGuardTargetData0003",
		"TppGuardTargetData0004",
		"TppGuardTargetData0005",
	},
	nil
}--combatSetting

this.InitEnemy=function()
end

this.SetUpEnemy=function()
	TppEnemy.RegisterCombatSetting(this.combatSetting)
	TppEnemy.SetupQuestEnemy()
end--SetUpEnemy

this.OnLoad=function()
end

return this

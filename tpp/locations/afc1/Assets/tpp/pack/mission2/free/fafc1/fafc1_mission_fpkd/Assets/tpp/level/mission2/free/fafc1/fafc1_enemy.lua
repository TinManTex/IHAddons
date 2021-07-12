local this={}
local StrCode32=InfCore.StrCode32
local StrCode32Table=Tpp.StrCode32Table
local GetGameObjectId=GameObject.GetGameObjectId
local NULL_ID=GameObject.NULL_ID
local SendCommand=GameObject.SendCommand

this.requires={}

--tex requires the proper vox_ene_common_ soundbank to be loaded, see InfSoundInfo for pack paths 
--or add the required voxs to your sdf loadbanks
this.cpTypes=CpType.TYPE_AFRIKAANS--tex apply to all cps

--REF TppEnemy._AnnouncePhaseChange, cpSubTypeToLangId
--this.cpAnounceLangIds="cmmn_ene_pf"--tex apply to all cps

this.cpSubTypes="PF_A"--tex apply to all cps

this.soldierDefine={
	afc1_admin_cp={
		--"sol_afc1_0000",
		"sol_afc1_0001",
		"sol_afc1_0002",
		"sol_afc1_0003",
		"sol_afc1_0004",
		"sol_afc1_0005",
		"sol_afc1_0006",
		"sol_afc1_0007",
		"sol_afc1_0008",
		"sol_afc1_0009",
		"sol_afc1_0010",
		"sol_afc1_0011",
		"sol_afc1_0012",
		"sol_afc1_0013",
		"sol_afc1_0014",
		"sol_afc1_0015",
		"sol_afc1_0016",
		"sol_afc1_0017",
		"sol_afc1_0018",
		"sol_afc1_0019",
		"sol_afc1_0020",
		"sol_afc1_0021",
		"sol_afc1_0022",
		"sol_afc1_0023",
		"sol_afc1_0024",
		"sol_afc1_0025",
		"sol_afc1_0026",
		"sol_afc1_0027",
		"sol_afc1_0028",

		"sol_afc1_0029",
		"sol_afc1_0030",
		"sol_afc1_0031",
		"sol_afc1_0032",
		"sol_afc1_0033",
		--[[
		"sol_afc1_0034",
		"sol_afc1_0035",
		"sol_afc1_0036",
		"sol_afc1_0037",
		--]]
	},--afc1_admin_cp
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

this.soldierTypes="PF"--REF EnemyType["TYPE_"..soldierType]--tex apply to all soldiers

this.soldierSubTypes=true--tex true = use cpSubTypes to define soldier subtypes

this.routeSets={
	--TODO move to common routesets once theyre solid - \Assets\mgo\pack\location\afc0\pack_common\afc1_script.fpkd
	afc1_admin_cp={
		priority={
			"groupA",
			"groupB",
			"groupC",
			"groupD",
		},
		sneak_day={
			groupA={
				--"rt_afc1_c_0000",
				"rt_afc1_c_0001",
				"rt_afc1_c_0002",
				"rt_afc1_c_0003",
				"rt_afc1_c_0004",
				"rt_afc1_c_0005",
				"rt_afc1_c_0006",
				"rt_afc1_c_0007",
				"rt_afc1_c_0008",
				"rt_afc1_c_0009",
				--"rt_afc1_c_0010",
				"rt_afc1_c_0011",
				"rt_afc1_c_0012",
				"rt_afc1_c_0013",
				"rt_afc1_c_0014",
				"rt_afc1_c_0015",
				"rt_afc1_c_0016",
				"rt_afc1_c_0017",
				"rt_afc1_c_0018",
				"rt_afc1_c_0019",
				"rt_afc1_c_0020",
				"rt_afc1_c_0021",
				"rt_afc1_c_0022",
				"rt_afc1_c_0023",
				"rt_afc1_c_0024",
				"rt_afc1_c_0025",
				"rt_afc1_c_0026",
				"rt_afc1_c_0027",
				"rt_afc1_c_0028",
			},
		},--sneak_day
		sneak_night= {
			groupA={
				--"rt_afc1_c_0000",
				"rt_afc1_c_0001",
				"rt_afc1_c_0002",
				"rt_afc1_c_0003",
				"rt_afc1_c_0004",
				"rt_afc1_c_0005",
				"rt_afc1_c_0006",
				"rt_afc1_c_0007",
				"rt_afc1_c_0008",
				"rt_afc1_c_0009",
				--"rt_afc1_c_0010",
				"rt_afc1_c_0011",
				"rt_afc1_c_0012",
				"rt_afc1_c_0013",
				"rt_afc1_c_0014",
				"rt_afc1_c_0015",
				"rt_afc1_c_0016",
				"rt_afc1_c_0017",
				"rt_afc1_c_0018",
				"rt_afc1_c_0019",
				"rt_afc1_c_0020",
				"rt_afc1_c_0021",
				"rt_afc1_c_0022",
				"rt_afc1_c_0023",
				"rt_afc1_c_0024",
				"rt_afc1_c_0025",
				"rt_afc1_c_0026",
				"rt_afc1_c_0027",
				"rt_afc1_c_0028",
			},
		},--sneak_night
		caution={
			groupA={
				--"rt_afc1_c_0000",
				"rt_afc1_c_0001",
				"rt_afc1_c_0002",
				"rt_afc1_c_0003",
				"rt_afc1_c_0004",
				"rt_afc1_c_0005",
				"rt_afc1_c_0006",
				"rt_afc1_c_0007",
				"rt_afc1_c_0008",
				"rt_afc1_c_0009",
				--"rt_afc1_c_0010",
				"rt_afc1_c_0011",
				"rt_afc1_c_0012",
				"rt_afc1_c_0013",
				"rt_afc1_c_0014",
				"rt_afc1_c_0015",
				"rt_afc1_c_0016",
				"rt_afc1_c_0017",
				"rt_afc1_c_0018",
				"rt_afc1_c_0019",
				"rt_afc1_c_0020",
				"rt_afc1_c_0021",
				"rt_afc1_c_0022",
				"rt_afc1_c_0023",
				"rt_afc1_c_0024",
				"rt_afc1_c_0025",
				"rt_afc1_c_0026",
				"rt_afc1_c_0027",
				"rt_afc1_c_0028",
			},
		},--caution
	},--afc1_admin_cp
	quest_cp={USE_COMMON_ROUTE_SETS=true,},--DEBUGNOW TODO
}--routeSets

this.combatSetting={
	--TODO move to common combat script
	afc1_admin_cp={
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

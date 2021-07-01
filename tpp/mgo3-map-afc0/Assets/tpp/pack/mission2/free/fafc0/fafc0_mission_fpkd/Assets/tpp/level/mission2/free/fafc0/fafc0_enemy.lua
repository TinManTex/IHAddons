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
--tex or per cp cpType
--this.cpTypes={
--	afc0_briefing_ob=CpType.TYPE_AFRIKAANS,
--	afc0_village_cp=CpType.TYPE_AMERICA,
--}--cpTypes

--REF TppEnemy._AnnouncePhaseChange, cpSubTypeToLangId
--this.cpAnounceLangIds="cmmn_ene_pf"--tex apply to all cps
--tex or per cp
--this.cpAnounceLangIds={
--	afc0_briefing_ob="cmmn_ene_pf",
--	afc0_village_cp="cmmn_ene_zrs",
--}--cpAnounceLangIds

this.cpSubTypes="PF_B"--tex apply to all cps
--tex or per cp subtype
--this.cpSubTypes={
--	afc0_briefing_ob="PF_C",
--	afc0_village_cp="PF_B",
--}--cpSubTypes

this.soldierDefine={
	afc0_briefing_ob={--17
		"sol_afc0_0000",
		"sol_afc0_0001",
		"sol_afc0_0002",
		"sol_afc0_0003",
		"sol_afc0_0004",
		"sol_afc0_0005",
		"sol_afc0_0006",
		"sol_afc0_0007",
		"sol_afc0_0008",
		"sol_afc0_0009",
		"sol_afc0_0010",
		"sol_afc0_0011",
		"sol_afc0_0012",
		"sol_afc0_0013",
		"sol_afc0_0014",
		--"sol_afc0_0015",
		--"sol_afc0_0016",
	},--afc0_briefing_ob
	afc0_village_cp={--21
		"sol_afc0_0017",
		"sol_afc0_0018",
		"sol_afc0_0019",
		"sol_afc0_0020",
		"sol_afc0_0021",
		"sol_afc0_0022",
		"sol_afc0_0023",
		"sol_afc0_0024",
		"sol_afc0_0025",
		"sol_afc0_0026",
		"sol_afc0_0027",
		"sol_afc0_0028",
		"sol_afc0_0029",
		"sol_afc0_0030",
		"sol_afc0_0031",
		"sol_afc0_0032",
		"sol_afc0_0033",
		"sol_afc0_0034",
		"sol_afc0_0035",
		"sol_afc0_0036",
		--"sol_afc0_0037",
	},--afc0_village_cp	
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
--tex or per soldier type (can only really do main type and extend type, then subtypes would need to match for those soldiers
--this.soldierTypes={
--	PF={
--		this.soldierDefine.afc0_briefing_ob,
--		this.soldierDefine.afc0_village_cp,
--	},
--  CHILD={
--    
--  },
--}--soldierTypes

this.soldierSubTypes=true--tex true = use cpSubTypes to define soldier subtypes for
--tex or per soldier sub type
--this.soldierSubTypes={	
	--PF_C={
		--"sol_afc0_0019",
		--this.soldierDefine.afc0_briefing_ob,	
	--},
	--PF_B={
	--	this.soldierDefine.afc0_village_cp,
	--},
--}--soldierSubTypes

this.routeSets={
	--TODO move to common routesets once theyre solid - \Assets\mgo\pack\location\afc0\pack_common\afc0_script.fpkd
	afc0_briefing_ob={
		priority={
			"groupA",
			"groupB",
			"groupC",
		},
		sneak_day={
			groupA={
				"rt_afc0_d_0000",
				"rt_afc0_d_0001",
				"rt_afc0_d_0002",
				"rt_afc0_d_0003",
				"rt_afc0_d_0004",
			},
			groupB={
				"rt_afc0_d_0005",
				"rt_afc0_d_0006",
				"rt_afc0_d_0007",
				"rt_afc0_d_0008",
				--TODO: reevaluate position "rt_afc0_d_0009",
				--TODO: reevaluate position "rt_afc0_d_0010",
			},
			groupC={
				"rt_afc0_d_0032",
				"rt_afc0_d_0033",
				"rt_afc0_d_0034",
				"rt_afc0_d_0035",
				"rt_afc0_d_0036",			
			},
		},--sneak_day
		sneak_night= {
			groupA={
				"rt_afc0_d_0000",
				"rt_afc0_d_0001",
				"rt_afc0_d_0002",
				"rt_afc0_d_0003",
				"rt_afc0_d_0004",
			},
			groupB={
				"rt_afc0_d_0005",
				"rt_afc0_d_0006",
				"rt_afc0_d_0007",
				"rt_afc0_d_0008",
				--TODO: reevaluate position "rt_afc0_d_0009",
				--TODO: reevaluate position "rt_afc0_d_0010",
			},
			groupC={
				"rt_afc0_d_0032",
				"rt_afc0_d_0033",
				"rt_afc0_d_0034",
				"rt_afc0_d_0035",
				"rt_afc0_d_0036",			
			},
		},--sneak_night
		caution={
			groupA={
				"rt_afc0_d_0000",
				"rt_afc0_d_0001",
				"rt_afc0_d_0002",
				"rt_afc0_d_0003",
				"rt_afc0_d_0004",
				"rt_afc0_d_0005",
				"rt_afc0_d_0006",
				"rt_afc0_d_0007",
				"rt_afc0_d_0008",
				--TODO: reevaluate position "rt_afc0_d_0009",
				--TODO: reevaluate position "rt_afc0_d_0010",
				"rt_afc0_d_0032",
				"rt_afc0_d_0033",
				"rt_afc0_d_0034",
				"rt_afc0_d_0035",
				"rt_afc0_d_0036",
			},
			groupB={

			},
			groupC={
		
			},
		},--caution
	},--afc0_briefing_ob
	afc0_village_cp={
		priority={
			"groupA",
			"groupB",
			"groupC",
			"groupD",
		},
		sneak_day={
			groupA={
				"rt_afc0_d_0011",
				"rt_afc0_d_0012",
				"rt_afc0_d_0013",
				"rt_afc0_d_0014",
				"rt_afc0_d_0015",
			},
			groupB={			
				"rt_afc0_d_0016",
				"rt_afc0_d_0017",
				"rt_afc0_d_0018",
				"rt_afc0_d_0019",
				"rt_afc0_d_0020",
				"rt_afc0_d_0021",
			},
			groupC={
				"rt_afc0_d_0022",
				"rt_afc0_d_0023",
				"rt_afc0_d_0024",
				"rt_afc0_d_0025",
				"rt_afc0_d_0026",
			},
			groupD={
				"rt_afc0_d_0027",
				"rt_afc0_d_0028",
				"rt_afc0_d_0029",
				"rt_afc0_d_0030",
				--TODO: reevaluate position "rt_afc0_d_0031",
			},
		},--sneak_day
		sneak_night= {
			groupA={
				"rt_afc0_d_0011",
				"rt_afc0_d_0012",
				"rt_afc0_d_0013",
				"rt_afc0_d_0014",
				"rt_afc0_d_0015",
			},
			groupB={			
				"rt_afc0_d_0016",
				"rt_afc0_d_0017",
				"rt_afc0_d_0018",
				"rt_afc0_d_0019",
				"rt_afc0_d_0020",
				"rt_afc0_d_0021",
			},
			groupC={
				"rt_afc0_d_0022",
				"rt_afc0_d_0023",
				"rt_afc0_d_0024",
				"rt_afc0_d_0025",
				"rt_afc0_d_0026",
			},
			groupD={
				"rt_afc0_d_0027",
				"rt_afc0_d_0028",
				"rt_afc0_d_0029",
				"rt_afc0_d_0030",
				--TODO: reevaluate position "rt_afc0_d_0031",
			},
		},--sneak_night
		caution={
			groupA={
				"rt_afc0_d_0011",
				"rt_afc0_d_0012",
				"rt_afc0_d_0013",
				"rt_afc0_d_0014",
				"rt_afc0_d_0015",				
				"rt_afc0_d_0016",
				"rt_afc0_d_0017",
				"rt_afc0_d_0018",
				"rt_afc0_d_0019",
				"rt_afc0_d_0020",
				"rt_afc0_d_0021",				
				"rt_afc0_d_0022",
				"rt_afc0_d_0023",
				"rt_afc0_d_0024",
				"rt_afc0_d_0025",
				"rt_afc0_d_0026",				
				"rt_afc0_d_0027",
				"rt_afc0_d_0028",
				"rt_afc0_d_0029",
				"rt_afc0_d_0030",
				--TODO: reevaluate position "rt_afc0_d_0031",
			},
			groupB={
			},
			groupC={
			},
			groupD={
			},
		},--caution
	},--afc0_village_cp
	quest_cp={USE_COMMON_ROUTE_SETS=true,},
}--routeSets

this.combatSetting={
	--TODO move to common combat script
	afc0_briefing_ob={
		"TppGuardTargetData0000",
		"TppGuardTargetData0001",
		"TppGuardTargetData0002",
	},
	afc0_village_cp={
		"TppGuardTargetData0003",
		"TppGuardTargetData0004",
		"TppGuardTargetData0005",
	},
	--tex doesnt seem to work even though theres vanilla examples of arealists with empty locatorsetnames
	--[[
	afc0_briefing_ob={
		combatAreaList={
			area1={
				{guardTargetName="TppGuardTargetData0000",locatorSetName="",},
			},
			area2={
				{guardTargetName="TppGuardTargetData0001",locatorSetName="",},
			},
			--area3={
			--	{guardTargetName="TppGuardTargetData0002",locatorSetName="",},
			--},
		},
	},
	afc0_village_cp={
		combatAreaList={
			area1={
				{guardTargetName="TppGuardTargetData0002",locatorSetName="",},
			},
			area2={
				{guardTargetName="TppGuardTargetData0003",locatorSetName="",},
			},
			--area3={
			--	{guardTargetName="TppGuardTargetData0005",locatorSetName="",},
			--},
		},
	},
	--]]
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

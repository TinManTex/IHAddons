local this = {}
local quest_step = {}

local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId

this.QUEST_TABLE = {
	
	questType = TppDefine.QUEST_TYPE.SHOOTING_PRACTIVE,

	gimmickTimerList = {
		displayTimeSec	= 60 * 5,--tex time limit of shooting practice quest. Changing this at a later point may cause issues since the best time is saved as a value of the 'time left' from the time limit.
		cautionTimeSec	= 60 * 1,--tex time when the countdown goes red and starts beeping more, IH has an option that overrides this and sets it to best time
	},
	--tex WORKAROUND: the shootingpractice setup code assumes that certain positions are defined as offsets relative to the cluster center named in gimmickOffsetType
	--the start ground circle, the target positions.
	--However as Command cluster has its center is 0,0,0 you can use that and use world positions 
	--though that limits you to one mb layout.
	--gimmickOffsetType = "Command",

	startUiPosition = {0,0.01,10},--tex position of the start marker ground circle, usually same position as trap_shootingPractice_start

	startMarkerName = "ly003_cl04_npc0000|cl04pl2_q30210|Marker_shootingPractice",--entity name, in layout fpkd fox2
 
	startTrapName = "ly003_cl04_npc0000|cl04pl2_q30210|trap_shootingPractice_start",--entity name, in layout fpkd fox2

	gimmickPermanentGimmickName = "mtbs_bord001_vrtn003_ev_gim_i0000|TppPermanentGimmick_mtbs_bord001_vrtn003_ev",--name of the TppPermanentGimmickData that defines the targets lba 

	gimmickMarkList = {
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0000|srt_mtbs_bord001_vrtn003_ev",--tex name of a target in the lba, don't really need to rename these
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",--tex point it to the quest fox2 that defines the target .lbas, just do a find and replace to match your fox2 name
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0001|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0002|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0003|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0004|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0005|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0006|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0007|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0008|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0009|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0010|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0011|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0012|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0013|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0014|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0015|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0016|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0017|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0018|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0019|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0020|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0021|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0022|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0023|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0024|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0025|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0026|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0027|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0028|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0029|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0030|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0031|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0032|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0033|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
		{
			locatorName = "mtbs_bord001_vrtn003_ev_gim_n0034|srt_mtbs_bord001_vrtn003_ev",
			dataSetName = "/Assets/tpp/level/mission2/quest/void/quest_q30211.fox2",
			setIndex	= 0,
		},
	},
}
--tex don't really need to change anything past this point



function this.OnAllocate()
	 TppQuest.RegisterQuestStepList{
		"QStep_Start",
		nil
	}
	
	
	TppGimmick.OnAllocateQuest( this.QUEST_TABLE )
	
	TppQuest.RegisterQuestStepTable( quest_step )
	TppQuest.RegisterQuestSystemCallbacks{
		OnActivate = function()
			Fox.Log("Quest Shooting Practice OnActivate")
			
			TppGimmick.OnActivateQuest( this.QUEST_TABLE )
			TppQuest.ShowShootingPracticeStartUi( this.QUEST_TABLE.gimmickOffsetType, this.QUEST_TABLE.startUiPosition, this.QUEST_TABLE.startMarkerName )--tex added startMarkerName
			
			mvars.isShootingPracticeQuestActivated = true
		end,
		OnDeactivate = function()
			Fox.Log("Quest Shooting Practice OnDeactivate")
			
			TppGimmick.OnDeactivateQuest( this.QUEST_TABLE )
			TppQuest.OnDeactivate( this.QUEST_TABLE )
			
			mvars.isShootingPracticeQuestActivated = false
		end,
		OnOutOfAcitveArea = function()
		end,
		OnTerminate = function()
			Fox.Log("Quest Shooting Practice OnTerminate")
			
			TppGimmick.OnTerminateQuest( this.QUEST_TABLE )
		end,
	}

	
	TppPlayer.AddTrapSettingForQuest{
		questName	= "ShootingPractice",
		trapName	= this.QUEST_TABLE.startTrapName,
	}
end





this.Messages = function()
	return
	StrCode32Table {
		Block = {
			{
				msg = "StageBlockCurrentSmallBlockIndexUpdated",
				func = function() end,
			},
		},
		Player = {
			{
				--NMC sent by ActionIcon of start trap
				--GOTCHA: InfQuest is overrides this message when quest_enableShootingPracticeRetry is on
				msg = "QuestStarted",
				sender = "ShootingPractice",
				func = function( questNameHash )
					Fox.Log( "QuestStarted" )
					TppPlayer.QuestStarted( questNameHash )
					
					TppQuest.SetQuestShootingPractice()
					
					mvars.needToUpdateRankingInMedical = false
				end
			},
			{	
				msg = "RideHelicopter",
				func = function( questNameHash )
					
					if TppQuest.IsShootingPracticeActivated() == false then
						Fox.Log( "Quest Trap Enter: ShootingPractice is Deactivated. Return" )
						return
					end
					
					if TppQuest.IsShootingPracticeStarted() then
						TppQuest.CancelShootingPractice()
					else
						TppQuest.HideShootingPracticeMarker()
					end
				end
			},
			{	
				msg = "LandingFromHeli",
				func = function( questNameHash )
					
					if TppQuest.IsShootingPracticeActivated() == false then
						Fox.Log( "Quest Trap Enter: ShootingPractice is Deactivated. Return" )
						return
					end
					
					if TppQuest.IsShootingPracticeStarted() then return end
					TppQuest.ShowShootingPracticeMarker()
				end
			},
		},
		Trap = {
			{
				msg = "Enter", sender = this.QUEST_TABLE.startTrapName,
				func = function( trap, player )
					if TppQuest.IsShootingPracticeActivated() == false then
						Fox.Log( "Quest Trap Enter: ShootingPractice is Deactivated. Return" )
						return
					end

					TppPlayer.OnEnterQuestTrap( trap, player )
				end
			},
			{
				msg = "Exit", sender = this.QUEST_TABLE.startTrapName,
				func = TppPlayer.OnExitQuestTrap
			}
		},
	}
end




function this.OnInitialize()
	TppQuest.QuestBlockOnInitialize( this )
end

function this.OnUpdate()
	TppQuest.QuestBlockOnUpdate( this )
	
	this.UpdateRankingInMedical()
end

function this.OnTerminate()
	TppQuest.QuestBlockOnTerminate( this )
end







function this.UpdateRankingInMedical()
	
	if mvars.needToUpdateRankingInMedical == true then
		
		local leftTime = TppUiCommand.GetLeftTimeFromDisplayTimer()
		if leftTime > 0 then
			local questName = TppQuest.GetCurrentQuestName()
			TppRanking.UpdateShootingPracticeClearTime( questName, leftTime )
			
			mvars.needToUpdateRankingInMedical = false
		end
	end
end





quest_step.QStep_Start = {
	
	Messages = function( self )
		return
		StrCode32Table {
			GameObject = {
				{	
					msg = "BreakGimmick",
					func = function( gameObjectId, locatorNameHash, dataSetNameHash )
						local isClearType = TppGimmick.CheckQuestAllTarget( this.QUEST_TABLE.questType, locatorNameHash )
						TppQuest.ClearWithSave( isClearType )
						
						
						if isClearType == TppDefine.QUEST_CLEAR_TYPE.SHOOTING_CLEAR then
							mvars.needToUpdateRankingInMedical = true
						end
					end
				},
			},
			UI = {
				{	
					msg = "DisplayTimerTimeUp",
					func = function()
						local isClearType = TppGimmick.CheckQuestAllTarget( this.QUEST_TABLE.questType, nil, true )
						TppQuest.ClearWithSave( isClearType )
					end
				},
			},
		}
	end,
	
	OnEnter = function()
		
	end,
}

return this

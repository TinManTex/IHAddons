local this = {}
local quest_step = {}
local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId
local ELIMINATE = TppDefine.QUEST_TYPE.ELIMINATE
local RECOVERED = TppDefine.QUEST_TYPE.RECOVERED
local KILLREQUIRED = 9
local CPNAME = InfMain.GetClosestCp{-8,20,27}
local DISTANTCP = "mafr_labWest_ob"
local questTrapName = "trap_preDeactiveQuestArea_banana"
local SUBTYPE = "PF_A"


this.QUEST_TABLE = {
    questType = ELIMINATE,
    soldierSubType = SUBTYPE,
    cpList = {
      nil
    },
    enemyList = {
        nil, 
    },
    hostageList = {
        {
            hostageName = "Hostage_0",
            isFaceRandom = true,
            isTarget = true,
            voiceType = {"hostage_a", "hostage_b",  "hostage_c", "hostage_d",},
            langType = "english",  
            bodyId = TppDefine.QUEST_BODY_ID_LIST.AFGH_HOSTAGE_FEMALE,
            position = {pos = {78.22093,33.83066,-0.9476498}, rotY = 6.00,},
            commands = {},
        }, 
        {
            hostageName = "Hostage_1",
            isFaceRandom = true,
            isTarget = true,
            voiceType = {"hostage_a", "hostage_b",  "hostage_c", "hostage_d",},
            langType = "english",  
            bodyId = TppDefine.QUEST_BODY_ID_LIST.AFGH_HOSTAGE_FEMALE,
            position = {pos = {9.298136,23.43221,-52.51197}, rotY = 79.00,},
            commands = {},
        }, 
        {
            hostageName = "Hostage_2",
            isFaceRandom = true,
            isTarget = true,
            voiceType = {"hostage_a", "hostage_b",  "hostage_c", "hostage_d",},
            langType = "english",  
            bodyId = TppDefine.QUEST_BODY_ID_LIST.AFGH_HOSTAGE_FEMALE,
            position = {pos = {-13.44396,38.17081,-122.0629}, rotY = 172.99,},
            commands = {},
        }, 
        {
            hostageName = "Hostage_3",
            isFaceRandom = true,
            isTarget = true,
            voiceType = {"hostage_a", "hostage_b",  "hostage_c", "hostage_d",},
            langType = "english",  
            bodyId = TppDefine.QUEST_BODY_ID_LIST.AFGH_HOSTAGE_FEMALE,
            position = {pos = {-85.5149,29.26844,10.19794}, rotY = 176.00,},
            commands = {},
        }, 
    },
    vehicleList = {
        nil, 
    },
    targetList = {"Hostage_0", "Hostage_1", "Hostage_2", "Hostage_3", 
    },
}


function this.WarpHostages()
  for i,hostageInfo in ipairs(this.QUEST_TABLE.hostageList)do
    local gameObjectId= GetGameObjectId(hostageInfo.hostageName)
    if gameObjectId~=GameObject.NULL_ID then
      local position=hostageInfo.position
      local command={id="Warp",degRotationY=position.rotY,position=Vector3(position.pos[1],position.pos[2],position.pos[3])}
      GameObject.SendCommand(gameObjectId,command)
    end
  end
end

function this.SetHostageAttributes()
  for i,hostageInfo in ipairs(this.QUEST_TABLE.hostageList)do
    local gameObjectId= GetGameObjectId(hostageInfo.hostageName)
    if gameObjectId~=GameObject.NULL_ID then
	  if hostageInfo.commands then
        for j,hostageCommand in ipairs(hostageInfo.commands)do
	      GameObject.SendCommand(gameObjectId, hostageCommand)
	    end
	  end
    end
  end
end

function this.OnAllocate()
  TppQuest.RegisterQuestStepList{
    "QStep_Start",
    "QStep_Main",
    nil
  }
  TppEnemy.OnAllocateQuestFova(this.QUEST_TABLE)
  TppQuest.RegisterQuestStepTable(quest_step)
  TppQuest.RegisterQuestSystemCallbacks{
    OnActivate = function()
      TppEnemy.OnActivateQuest(this.QUEST_TABLE)
      TppAnimal.OnActivateQuest(this.QUEST_TABLE)
    end,
    OnDeactivate = function()
      TppEnemy.OnDeactivateQuest(this.QUEST_TABLE)
      TppAnimal.OnDeactivateQuest(this.QUEST_TABLE)
    end,
    OnOutOfAcitveArea = function() 
    end,
    OnTerminate = function()
      TppEnemy.OnTerminateQuest(this.QUEST_TABLE)
      TppAnimal.OnTerminateQuest(this.QUEST_TABLE)
    end,
  }
  mvars.fultonInfo = NONE
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
    }
end

function this.OnInitialize()
	TppQuest.QuestBlockOnInitialize( this )
end

function this.OnUpdate()
  TppQuest.QuestBlockOnUpdate(this)
end

function this.OnTerminate()
	TppQuest.QuestBlockOnTerminate(this)
end

quest_step.QStep_Start = {
  OnEnter = function()
    InfCore.PCall(this.WarpHostages)
    InfCore.PCall(this.SetHostageAttributes)
    TppQuest.SetNextQuestStep("QStep_Main")
  end,
}

quest_step.QStep_Main = {
  Messages = function( self )
    return
      StrCode32Table {
        GameObject = {
          {
            msg = "Dead", 
            func = function(gameObjectId,gameObjectId01,animalId)
              local isClearType = this.CheckQuestAllTargetDynamic("Dead",gameObjectId, animalId)
              TppQuest.ClearWithSave(isClearType)
            end
          },
          {
            msg = "FultonInfo", 
            func = function(gameObjectId)
              if mvars.fultonInfo ~= NONE then
                TppQuest.ClearWithSave(mvars.fultonInfo)
              end
              mvars.fultonInfo = NONE
            end
          },
          {
            msg = "Fulton", 
            func = function(gameObjectId, animalId)
              local isClearType = this.CheckQuestAllTargetDynamic("Fulton", gameObjectId, animalId)
              TppQuest.ClearWithSave(isClearType)
            end
          },
          {
            msg = "FultonFailed", 
            func = function(gameObjectId, locatorName, locatorNameUpper, failureType)
              if failureType == TppGameObject.FULTON_FAILED_TYPE_ON_FINISHED_RISE then
                local isClearType = this.CheckQuestAllTargetDynamic("FultonFailed", gameObjectId, locatorName)
                TppQuest.ClearWithSave(isClearType)
              end
            end
          },
          {
            msg = "PlacedIntoVehicle", 
            func = function(gameObjectId, vehicleGameObjectId)
              if Tpp.IsHelicopter(vehicleGameObjectId) then
                local isClearType = this.CheckQuestAllTargetDynamic("InHelicopter", gameObjectId)
                TppQuest.ClearWithSave(isClearType)
              end
            end
          },
          {
            msg = "VehicleBroken", 
            func = function(gameObjectId, state)
			  if state == StrCode32("End") then
				local isClearType = this.CheckQuestAllTargetDynamic("VehicleBroken", gameObjectId)
				TppQuest.ClearWithSave(isClearType)
			  end
			end
          },
          {
            msg = "LostControl", 
            func = function(gameObjectId, state)
			  if state == StrCode32("End") then
				local isClearType = this.CheckQuestAllTargetDynamic("LostControl", gameObjectId)
				TppQuest.ClearWithSave(isClearType)
			  end
			end
          },
        },
      }
  end,
  OnEnter = function() end,
  OnLeave = function() end,
}


function this.CheckIsHostage(gameId)
  return Tpp.IsHostage(gameId)
end

ObjectiveTypeList = {
  genericTargets = {
    {Check = this.CheckIsHostage, Type = RECOVERED},
  },
}


function this.IsTargetSetMessageIdForGenericEnemy(gameId, messageId, checkAnimalId)
  if mvars.ene_questTargetList[gameId] then
	local targetInfo = mvars.ene_questTargetList[gameId]
	local intended = true
	if targetInfo.messageId ~= "None" and targetInfo.isTarget == true then
	  intended = false
	elseif targetInfo.isTarget == false then
	  intended = false
	end
	targetInfo.messageId = messageId or "None"
	return true, intended
  end
  return false, false
end

function this.TallyGenericTargets(totalTargets, objectiveCompleteCount, objectiveFailedCount)
  for targetGameId, targetInfo in pairs(mvars.ene_questTargetList) do
    local dynamicQuestType = ELIMINATE
    local isTarget = targetInfo.isTarget or false
    local targetMessageId = targetInfo.messageId

    if isTarget == true then
      if ObjectiveTypeList.genericTargets ~= nil then
        for _, ObjectiveTypeInfo in ipairs(ObjectiveTypeList.genericTargets) do
          if ObjectiveTypeInfo.Check(targetGameId) then
            dynamicQuestType = ObjectiveTypeInfo.Type
            break
          end
        end
      end

      if targetMessageId ~= "None" then
        if dynamicQuestType == RECOVERED then
          if (targetMessageId == "Fulton") or (targetMessageId == "InHelicopter") then
            objectiveCompleteCount = objectiveCompleteCount + 1
          elseif (targetMessageId == "FultonFailed") or (targetMessageId == "Dead") or (targetMessageId == "VehicleBroken") or (targetMessageId == "LostControl") then
            objectiveFailedCount = objectiveFailedCount + 1
          end

        elseif dynamicQuestType == ELIMINATE then
          if (targetMessageId == "Fulton") or (targetMessageId == "InHelicopter") or (targetMessageId == "FultonFailed") or (targetMessageId == "Dead") or (targetMessageId == "VehicleBroken") or (targetMessageId == "LostControl") then
            objectiveCompleteCount = objectiveCompleteCount + 1
          end

        elseif dynamicQuestType == KILLREQUIRED then
          if (targetMessageId == "FultonFailed") or (targetMessageId == "Dead") or (targetMessageId == "VehicleBroken") or (targetMessageId == "LostControl") then
            objectiveCompleteCount = objectiveCompleteCount + 1
          elseif (targetMessageId == "Fulton") or (targetMessageId == "InHelicopter")  then
            objectiveFailedCount = objectiveFailedCount + 1
          end
        end
      end
      totalTargets = totalTargets + 1
    end
  end
  return totalTargets, objectiveCompleteCount, objectiveFailedCount
end

local CheckQuestMethodList = {
  {IsTargetSetMessageMethod = this.IsTargetSetMessageIdForGenericEnemy, TallyMethod = this.TallyGenericTargets},
}


function this.CheckQuestAllTargetDynamic(messageId, gameId, checkAnimalId)
  local currentQuestName=TppQuest.GetCurrentQuestName()
  if TppQuest.IsEnd(currentQuestName) then
    return TppDefine.QUEST_CLEAR_TYPE.NONE
  end

  local inTargetList = false
  local intendedTarget = true
  for _, CheckMethods in ipairs(CheckQuestMethodList) do
    inTargetList, intendedTarget = CheckMethods.IsTargetSetMessageMethod(gameId, messageId, checkAnimalId)
    if inTargetList == true then
      break
    end
  end

  if inTargetList == false then
    return TppDefine.QUEST_CLEAR_TYPE.NONE
  end

  local totalTargets = 0
  local objectiveCompleteCount = 0
  local objectiveFailedCount = 0
  for _, CheckMethods in ipairs(CheckQuestMethodList) do
    totalTargets, objectiveCompleteCount, objectiveFailedCount = CheckMethods.TallyMethod(totalTargets, objectiveCompleteCount, objectiveFailedCount)
  end

  if totalTargets > 0 then
    if objectiveCompleteCount >= totalTargets then
      return TppDefine.QUEST_CLEAR_TYPE.CLEAR
    elseif objectiveFailedCount > 0 then
      return TppDefine.QUEST_CLEAR_TYPE.FAILURE
    elseif objectiveCompleteCount > 0 then
      if intendedTarget == true then
        local showAnnounceLogId=TppQuest.questCompleteLangIds[TppQuest.GetCurrentQuestName()]
        if showAnnounceLogId then
          TppUI.ShowAnnounceLog(showAnnounceLogId,objectiveCompleteCount,totalTargets)
        end
      end
    end
  end
  return TppDefine.QUEST_CLEAR_TYPE.NONE
end

return this

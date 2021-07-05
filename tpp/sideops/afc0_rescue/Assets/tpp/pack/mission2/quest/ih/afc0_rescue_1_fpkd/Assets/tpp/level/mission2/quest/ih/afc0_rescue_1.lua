local this = {}
local quest_step = {}
local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId
local ELIMINATE = TppDefine.QUEST_TYPE.ELIMINATE
local RECOVERED = TppDefine.QUEST_TYPE.RECOVERED
local KILLREQUIRED = 9
local CPNAME = InfMain.GetClosestCp{23.9,11.93,12.9}
local DISTANTCP = "mafr_labWest_ob"
local questTrapName = "trap_preDeactiveQuestArea_banana"
local SUBTYPE = "PF_A"
local questWalkerGearList = {}
local playerWGResetPosition
local walkerGearGameId
local inMostActiveQuestArea = true
local exitOnce = true


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
            bodyId = TppDefine.QUEST_BODY_ID_LIST.MAFR_HOSTAGE_FEMALE,
            position = {pos = {-85.03081,3.65925,-82.72048}, rotY = 12.00,},
            commands = {},
        }, 
        {
            hostageName = "Hostage_1",
            isFaceRandom = true,
            isTarget = true,
            voiceType = {"hostage_a", "hostage_b",  "hostage_c", "hostage_d",},
            langType = "english",  
            bodyId = TppDefine.QUEST_BODY_ID_LIST.MAFR_HOSTAGE_FEMALE,
            position = {pos = {77.19106,15.75323,-110.3437}, rotY = 76.00,},
            commands = {},
        }, 
        {
            hostageName = "Hostage_2",
            isFaceRandom = true,
            isTarget = true,
            voiceType = {"hostage_a", "hostage_b",  "hostage_c", "hostage_d",},
            langType = "english",  
            bodyId = TppDefine.QUEST_BODY_ID_LIST.MAFR_HOSTAGE_FEMALE,
            position = {pos = {-21.43786,8.11221,73.72742}, rotY = 103.00,},
            commands = {},
        }, 
        {
            hostageName = "Hostage_3",
            isFaceRandom = true,
            isTarget = true,
            voiceType = {"hostage_a", "hostage_b",  "hostage_c", "hostage_d",},
            langType = "english",  
            bodyId = TppDefine.QUEST_BODY_ID_LIST.MAFR_HOSTAGE_FEMALE,
            position = {pos = {55.36925,11.91024,137.8172}, rotY = 144.00,},
            commands = {},
        }, 
    },
    vehicleList = {
        nil, 
    },
    walkerList = {
        {
            walkerName = "WalkerGear_0",
            colorType = 1,
            primaryWeapon = 0,
            position = {pos = {-80.365,2.965,-78.161}, rotY = -92.12,},
        }, 
    },
    animalList = {
        {
            animalName = "Animal_Cluster_0",
            animalType = "TppNubian",
        }, 
        {
            animalName = "Animal_Cluster_1",
            animalType = "TppNubian",
        }, 
        {
            animalName = "Animal_Cluster_2",
            animalType = "TppNubian",
        }, 
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

function this.OneTimeAnnounce(announceString1, announceString2, isFresh)
  if isFresh == true then
    InfCore.DebugPrint(announceString1)
    InfCore.DebugPrint(announceString2)
  end

  return false
end

function this.ReboundWalkerGear(walkerGearGameObjectId)
  local commandPos={ id = "SetPosition", rotY = playerWGResetPosition.rotY, pos = playerWGResetPosition.pos}
  GameObject.SendCommand(walkerGearGameObjectId,commandPos)
end
local setupOnce = true

function this.SetupGearsQuest(setupOnce)
  if setupOnce == true then
    for i,walkerInfo in ipairs(this.QUEST_TABLE.walkerList)do
      local walkerId = GetGameObjectId("TppCommonWalkerGear2",walkerInfo.walkerName)
      if walkerId ~= GameObject.NULL_ID then

        local commandWeapon={ id = "SetMainWeapon", weapon = walkerInfo.primaryWeapon}
        GameObject.SendCommand(walkerId, commandWeapon)

        local commandColor = { id = "SetColoringType", type = walkerInfo.colorType }
        GameObject.SendCommand(walkerId, commandColor)

        if walkerInfo.riderName then
          local soldierId = GetGameObjectId( "TppSoldier2", walkerInfo.riderName )
          local commandRide = { id = "SetRelativeVehicle", targetId = walkerId, rideFromBeginning = true  }
          GameObject.SendCommand( soldierId, commandRide )
        end

		local position = walkerInfo.position
        local commandPos={ id = "SetPosition", rotY = position.rotY, pos = position.pos}
        GameObject.SendCommand(walkerId,commandPos)
      end
    end
  end
  return false
end

function this.BuildWalkerGameObjectIdList()
  for i,walkerInfo in ipairs(this.QUEST_TABLE.walkerList)do
    local walkerId = GetGameObjectId("TppCommonWalkerGear2",walkerInfo.walkerName)
    if walkerId ~= GameObject.NULL_ID then
      questWalkerGearList[walkerId] = walkerInfo.walkerName
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
  setupOnce = this.SetupGearsQuest(setupOnce)
end

function this.OnTerminate()
	TppQuest.QuestBlockOnTerminate(this)
end

quest_step.QStep_Start = {
  OnEnter = function()
    InfCore.PCall(this.WarpHostages)
    InfCore.PCall(this.SetHostageAttributes)
    InfCore.PCall(this.BuildWalkerGameObjectIdList)
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
        Trap = {
          {
            msg = "Exit", 
            sender = questTrapName, 
            func = function()
              inMostActiveQuestArea = false
              walkerGearGameId = vars.playerVehicleGameObjectId
              if questWalkerGearList[walkerGearGameId] then
                playerWGResetPosition = {pos= {vars.playerPosX, vars.playerPosY + 1, vars.playerPosZ},rotY= 0,}
                GkEventTimerManager.Start("OutOfMostActiveArea", 7)
                exitOnce = this.OneTimeAnnounce("The Walker Gear cannot travel beyond this point.", "Return to the Side Op area.", exitOnce)
              end
            end
          },
          {
            msg = "Enter", 
            sender = questTrapName, 
            func = function()
              inMostActiveQuestArea = true
              if GkEventTimerManager.IsTimerActive("OutOfMostActiveArea") and walkerGearGameId == vars.playerVehicleGameObjectId then
                GkEventTimerManager.Stop("OutOfMostActiveArea")
                GkEventTimerManager.Start("AnnounceOnceCooldown", 3)
              end
            end
          },
        },
        Timer = {
          {
            msg = "Finish", 
            sender = "OutOfMostActiveArea", 
            func = function()
              if inMostActiveQuestArea == false then
                InfCore.DebugPrint("Returning Walker Gear to Side Op area...")
                this.ReboundWalkerGear(walkerGearGameId)
              end
            end
          },
          {
            msg = "Finish", 
            sender = "AnnounceOnceCooldown", 
            func = function()
              exitOnce = true
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

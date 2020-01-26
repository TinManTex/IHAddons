-- DOBUILD: 1

local this={}
--tex lines kinda blurry between Commands and Ivars, currently commands arent saved/have no gvar associated
--NOTE: tablesetup at end sets up every table in this with an OnChange as a menu command

--menu menu items
this.menuOffItem={
  OnChange=function()
    InfMenu.MenuOff()
    InfMenu.currentIndex=1
  end,
}
this.resetSettingsItem={
  OnChange=function()
    InfMenu.ResetSettingsDisplay()
    InfMenu.MenuOff()
  end,
}
this.resetAllSettingsItem={
  OnChange=function()
    InfMenu.PrintLangId"setting_all_defaults"
    InfMenu.ResetSettings()
    Ivars.PrintNonDefaultVars()
    InfMenu.PrintLangId"done"
    InfMenu.MenuOff()
  end,
}
this.goBackItem={
  settingNames="set_goBackItem",
  OnChange=function()
    InfMenu.GoBackCurrent()
  end,
}

--commands
this.showPosition={
  OnChange=function()
    TppUiCommand.AnnounceLogView(string.format("%.2f,%.2f,%.2f | %.2f",vars.playerPosX,vars.playerPosY,vars.playerPosZ,vars.playerRotY))
  end,
}

this.showMissionCode={
  OnChange=function()
    TppUiCommand.AnnounceLogView("MissionCode: "..vars.missionCode)--ADDLANG
  end,
}

this.showMbEquipGrade={
  OnChange=function()
    local soldierGrade = TppMotherBaseManagement.GetMbsClusterSecuritySoldierEquipGrade{}
    local infGrade = InfMain.GetMbsClusterSecuritySoldierEquipGrade()
    TppUiCommand.AnnounceLogView("Security Grade: "..soldierGrade)--ADDLANG
    TppUiCommand.AnnounceLogView("Inf Grade: "..soldierGrade)--ADDLANG
  end,
}

this.showLangCode={
  OnChange=function()
    local languageCode=AssetConfiguration.GetDefaultCategory"Language"
    TppUiCommand.AnnounceLogView(InfMenu.LangString"language_code"..": "..languageCode)
  end,
}

this.showQuietReunionMissionCount={
  OnChange=function()
    TppUiCommand.AnnounceLogView("quietReunionMissionCount: "..gvars.str_quietReunionMissionCount)
  end,
}

this.loadMission={
  OnChange=function()
    local settingStr=Ivars.manualMissionCode.settings[Ivars.manualMissionCode:Get()+1]
    InfMenu.DebugPrint("TppMission.Load "..settingStr)
    --TppMission.Load( tonumber(settingStr), vars.missionCode, { showLoadingTips = false } )
    --TppMission.RequestLoad(tonumber(settingStr),vars.missionCode,{force=true,showLoadingTips=true})--,ignoreMtbsLoadLocationForce=mvars.mis_ignoreMtbsLoadLocationForce})
    --TppMission.RequestLoad(10036,vars.missionCode,{force=true,showLoadingTips=true})--,ignoreMtbsLoadLocationForce=mvars.mis_ignoreMtbsLoadLocationForce})
    gvars.mis_nextMissionCodeForMissionClear=tonumber(settingStr)
    mvars.mis_showLoadingTipsOnMissionFinalize=false
    --mvars.heli_missionStartRoute
    --mvars.mis_nextLayoutCode
    --mvars.mis_nextClusterId
    --mvars.mis_ignoreMtbsLoadLocationForce

    TppMission.ExecuteMissionFinalize()
  end,
}

this.ogrePointChange=999999
this.setDemon={
  OnChange=function(self)
    --TppMotherBaseManagement.SetOgrePoint{ogrePoint=99999999}
    TppHero.SetOgrePoint(this.ogrePointChange)
    InfMenu.Print("-"..this.ogrePointChange .. InfMenu.LangString"set_demon")
  end,
}
this.removeDemon={
  OnChange=function(self)
    --TppMotherBaseManagement.SetOgrePoint{ogrePoint=1}
    --TppMotherBaseManagement.SubOgrePoint{ogrePoint=-999999999}
    TppHero.SetOgrePoint(-this.ogrePointChange)
    InfMenu.Print(this.ogrePointChange .. InfMenu.LangString"removed_demon")
  end,
}

this.returnQuiet={
  settingNames="set_quiet_return",
  OnChange=function()
    if not TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)then
      InfMenu.PrintLangId"quiet_already_returned"--"Quiet has already returned."
    else
      --InfPatch.QuietReturn()
      TppStory.RequestReunionQuiet()
    end
  end,
}

this.resetRevenge={
  OnChange=function()
    TppRevenge.ResetRevenge()
    TppRevenge._SetUiParameters()
    InfMenu.PrintLangId("revenge_reset")
  end,
}

this.pullOutHeli={
  OnChange=function()
    local gameObjectId=GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
    if gameObjectId~=nil and gameObjectId~=GameObject.NULL_ID then
      GameObject.SendCommand(gameObjectId,{id="PullOut",forced=true})
    end
  end
}

--game progression unlocks

this.unlockPlayableAvatar={
  OnChange=function()
    if vars.isAvatarPlayerEnable==1 then
      InfMenu.PrintLangId"allready_unlocked"
    else
      vars.isAvatarPlayerEnable=1
    end
  end,
}
this.unlockWeaponCustomization={
  OnChange=function()
    if vars.mbmMasterGunsmithSkill==1 then
      InfMenu.PrintLangId"allready_unlocked"
    else
      vars.mbmMasterGunsmithSkill=1
    end
  end,
}

--
--this.resetCameraSettings={--CULL
--  OnChange=function()
--    InfMain.ResetCamPosition()
--    InfMenu.PrintLangId"cam_settings_reset"
--  end,
--}
--
this.doEnemyReinforce={--WIP
  OnChange=function()
  --TODO: GetClosestCp
  --  _OnRequestLoadReinforce(reinforceCpId)--NMC game message "RequestLoadReinforce"

  --or

  --  TppReinforceBlock.LoadReinforceBlock(reinforceType,reinforceCpId,reinforceColoringType)
  end,
}

--
this.printSightFormParameter={
  OnChange=function()
    InfSoldierParams.ApplySightIvarsToSoldierParams()
    --local sightFormStr=InfInspect.Inspect(InfSoldierParams.soldierParameters.sightFormParameter)
    --InfMenu.DebugPrint(sightFormStr)
    InfSoldierParams.PrintSightForm()
  end,
}

this.printHearingTable={
  OnChange=function()
    InfSoldierParams.ApplyHearingIvarsToSoldierParams()
    local ins=InfInspect.Inspect(InfSoldierParams.soldierParameters.hearingRangeParameter)
    InfMenu.DebugPrint(ins)
  end,
}

this.printHealthTableParameter={
  OnChange=function()
    InfSoldierParams.ApplyHealthIvarsToSoldierParams()
    local sightFormStr=InfInspect.Inspect(InfSoldierParams.lifeParameterTable)
    InfMenu.DebugPrint(sightFormStr)
  end,
}

this.printCustomRevengeConfig={
  OnChange=function()
    local revengeConfig=InfMain.CreateCustomRevengeConfig()
    local ins=InfInspect.Inspect(revengeConfig)
    InfMenu.DebugPrint(ins)
  end
}

--debug commands

this.printCurrentAppearance={
  OnChange=function()
    InfMenu.Print("playerType: " .. tostring(vars.playerType))
    InfMenu.Print("playerCamoType: " .. tostring(vars.playerCamoType))
    InfMenu.Print("playerPartsType: " .. tostring(vars.playerPartsType))
    InfMenu.Print("playerFaceEquipId: " .. tostring(vars.playerFaceEquipId))
    InfMenu.Print("playerFaceId: " .. tostring(vars.playerFaceId))
  end,
}

this.forceAllQuestOpenFlagFalse={
  OnChange=function()
    for n,questIndex in ipairs(TppDefine.QUEST_INDEX)do
      gvars.qst_questOpenFlag[questIndex]=false
      gvars.qst_questActiveFlag[questIndex]=false
    end
    TppQuest.UpdateActiveQuest()
    InfMenu.PrintLangId"done"
  end,
}

--
this.warpPlayerCommand={--WIP
  OnChange=function()
    --    local playerId={type="TppPlayer2",index=0}
    --    local position=Vector3(9,.8,-42.5)
    --    GameObject.SendCommand(playerId,{id="Warp",position=position})

    --local pos={8.647,.8,-28.748}
    --local rotY=-25
    --pos,rotY=mtbs_cluster.GetPosAndRotY("Medical","plnt0",pos,rotY)
    local rotY=0
    --local pos={9,.8,-42.5}--command helipad
    local pos={-139,-3.20,-975}


    TppPlayer.Warp{pos=pos,rotY=rotY}
    --Player.RequestToSetCameraRotation{rotX=0,rotY=rotY}

    --TppPlayer.SetInitialPosition(pos,rotY)
  end,
}

this.warpToCamPos={
  OnChange=function()
    local warpPos=InfMain.ReadPosition"FreeCam"
    InfMenu.DebugPrint("warp pos:".. warpPos:GetX()..",".. warpPos:GetY().. ","..warpPos:GetZ())
    TppPlayer.Warp{pos={warpPos:GetX(),warpPos:GetY(),warpPos:GetZ()},rotY=vars.playerCameraRotation[1]}
  end,
}

local toggle=false
this.DEBUG_SomeShiz={
  OnChange=function()
  InfInspect.TryFunc(function()
    local params={
      locator="veh_cl00_cl04_0000",
      armorPosition={x=211.62,y=0.41,z=-121.13},armorRot=178
    }
    local pos=params.armorPosition
    if pos then
      local vec3=Vector3(pos.x,pos.y,pos.z)
      local rot=params.armorRot
    
      local gameId=GameObject.GetGameObjectId(params.locator)
      local typeIndex=GameObject.GetTypeIndex(gameId)
      if gameId==GameObject.NULL_ID then
        InfMenu.DebugPrint(params.locator.."==NULL_ID")
      else
        InfMenu.DebugPrint(params.locator.." setposition")
        GameObject.SendCommand(gameId,{id="SetPosition",position=vec3,rotY=rot})
      end
    end
end)
    if true then return true end


    InfMenu.DebugPrint(tostring(vars.mbLayoutCode))

    local gameId=GameObject.GetGameObjectId("sol_ih_0000")
    if gameId==GameObject.NULL_ID then
      InfMenu.DebugPrint("gameId==NULL_ID")
    else
      InfMenu.DebugPrint("bip")

      local command={id="SetEnabled",enabled=true}
      GameObject.SendCommand(gameId,command)

      local routes={

          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_d_0000",
      }

      local routeIdx=math.random(#routes)
      InfMenu.DebugPrint("routeIdx:"..routeIdx)
      local command={id="SetSneakRoute",route=routes[routeIdx]}
      GameObject.SendCommand(gameId,command)

    end

    local ins=InfInspect.Inspect( mtbs_enemy.plntParamTable)
    InfMenu.DebugPrint(ins)


    if true then return end
    --30050
    if mvars.mbItem_funcGetAssetTable then
      local clusterId=0





      --    type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER,
      --    locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001",
      --    dataSetName = "/Assets/tpp/level/mission2/story/s10093/s10093_item.fox2",
      --    gimmickType = TppGimmick.GIMMICK_TYPE.CNTN,

      local layoutCode=vars.mbLayoutCode
      local dataSet = string.format( "/Assets/tpp/level/location/mtbs/block_area/ly%03d/cl%02d/mtbs_ly%03d_cl%02d_item.fox2", layoutCode, clusterId, layoutCode, clusterId )


      local assetTable = mvars.mbItem_funcGetAssetTable( clusterId + 1 )

      --        local ins=InfInspect.Inspect(assetTable.containers)
      --        InfMenu.DebugPrint(ins)
      if assetTable.containers then
        for k,v in ipairs(assetTable.containers)do
          if (k % 4) == 0 then
            if type(v)=="string" then
              --InfMenu.DebugPrint(tostring(v))
              --TppGimmick.Hide(v)
              local status, err = pcall(function ()
                Gimmick.InvisibleGimmick(TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER,v,dataSet,true)
              end)
              if err then
                InfMenu.DebugPrint(tostring(err))
              end
            end
          end
        end


      end
      InfMenu.DebugPrint("doop")

    else
      InfMenu.DebugPrint( mvars.mbItem_funcGetAssetTable==nil)
    end

    if true then return true end
    --  InfMenu.DebugPrint"DEBUG_SomeShiz start"
    --  --this.AllDeveloped()
    --  local grade=4
    --  local isNew=false
    --
    --  toggle=not toggle
    --
    --  if toggle then
    --    InfMenu.DebugPrint"grade3"
    --    TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Command",grade=3,buildStatus="Completed",timeMinute=10,isNew=isNew}
    --  else
    --    InfMenu.DebugPrint"grade4"
    --    TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Command",grade=4,buildStatus="Completed",timeMinute=10,isNew=isNew}
    --  end


    InfMenu.DebugPrint"DEBUG_SomeShiz end"
    if true then return true end


    if InfMain.IsDDBodyEquip() then
      InfMenu.DebugPrint"IsDDBodyEquip"
    else
      InfMenu.DebugPrint"not IsDDBodyEquip"
    end

    InfMain.GetCurrentDDBodyInfo()
    InfMain.GetCurrentDDBodyInfo(true)

    InfMenu.DebugPrint("mbRepopDiamondCountdown=="..tostring(Ivars.mbRepopDiamondCountdown:Get()))


    local clusterId=1
    if mvars.mbSoldier_clusterParamList and mvars.mbSoldier_clusterParamList[clusterId] then
      local clusterParam=mvars.mbSoldier_clusterParamList[clusterId]
      local cpId=GameObject.GetGameObjectId(clusterParam.CP_NAME)
      if cpId==GameObject.NULL_ID then
        InfMenu.DebugPrint("cpId "..clusterParam.CP_NAME.."==NULL_ID ")
      else
        local currentPosition=GameObject.SendCommand(cpId,{id="GetPosition"})
        if currentPosition then
          InfMenu.DebugPrint(" pos:".. currentPosition:GetX()..",".. currentPosition:GetY().. ","..currentPosition:GetZ())
        else
        end
      end
    end
    if true then return end
    --==================================
    local objectName="ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|TppOcelot2GameObjectLocator"

    --local objectName="ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|TppLiquid2GameObjectLocator"

    --local objectName="TppHuey2GameObjectLocator"

    --local objectName="hos_ih_0000"

    local gameId=GameObject.GetGameObjectId(objectName)
    if gameId==GameObject.NULL_ID then
      InfMenu.DebugPrint("gameId==NULL_ID")
    else
      InfMenu.DebugPrint("bip")

      local command={id="SetEnabled",enabled=true}
      GameObject.SendCommand(gameId,command)

      --        GameObject.SendCommand( gameId, { id = "SetMotherbaseMode"} )
      --        GameObject.SendCommand( gameId, { id = "InitiateCombat"} )
      local startX=-1.0001540184021
      local startY=34.23641204834
      local startZ=-13.921287536621

      local currentPosition=GameObject.SendCommand(gameId,{id="GetPosition"})
      InfMenu.DebugPrint(objectName.." pos:".. currentPosition:GetX()..",".. currentPosition:GetY().. ","..currentPosition:GetZ())

      -- if currentPosition:GetX()==startX and currentPosition:GetY()==startY and currentPosition:GetZ()==startZ then

      local position=Vector3(9.8,0.9,-18)
      local rotY=-180

      --      local position=Vector3(44,8.511,-15.1)
      --      local rotY=-180
      --
      --      local position=Vector3(.14,24.83,-5.37)
      --      local rotY=79


      local command={id="Warp",position=position,degRotationY = rotY}
      GameObject.SendCommand(gameId,command)

      -- local isReal=GameObject.SendCommand(gameId,{id="IsReal"})

      --       local command = { id = "SetNoticeState", state = TppGameObject.HOSTAGE_NOTICE_STATE_FLEE }
      --  GameObject.SendCommand( gameId , command )
      --
      --  --TppEnemy.RegistHoldRecoveredState(objectName)
      --
      --  local command = {
      --    id = "SetHostage2Flag",
      --    flag = "unlocked",
      --    on = true,
      --  }
      ----
      -- GameObject.SendCommand( gameId, command )



      --    local command = { id = "SetNoticeState", state = TppGameObject.HOSTAGE_NOTICE_STATE_EXECUTE_READY }
      --
      --      GameObject.SendCommand( gameObjectId, { id = "SetNoticeState", state = TppGameObject.HOSTAGE_NOTICE_STATE_EXECUTED } )

      --  local command = { id = "SetNoticeState", state = TppGameObject.HOSTAGE_NOTICE_STATE_NORMAL }
      --  GameObject.SendCommand( gameId , command )

      --    local command = { id = "SetHostage2Flag", flag = "commonNpc", on = true, }
      --    GameObject.SendCommand( gameId, command )

      --    local cmdHosState = {
      --        id = "SetHostage2Flag",
      --        flag = "disableFulton",
      --        on = true,
      --    }

      --oce0_main0_v00=370,
      --oce0_main0_v01=371,
      --oce0_main0_v02=372,

      local command={id="ChangeFova",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=371}
      GameObject.SendCommand(gameId,command)

      local position=GameObject.SendCommand(gameId,{id="GetPosition"})
      InfMenu.DebugPrint(objectName.." pos:".. position:GetX()..",".. position:GetY().. ","..position:GetZ())
    end

    InfMenu.DebugPrint("bop")
    --end


    --
    --    InfMenu.DebugPrint("inittest="..tostring(InfMain.initTest))
    --
    --
    --    local ins = InfInspect.Inspect(InfMain.ene_wildCardSoldiers)
    --    InfMenu.DebugPrint(ins)
    --    local ins = InfInspect.Inspect(InfMain.ene_femaleWildCardSoldiers)
    --    InfMenu.DebugPrint(ins)
    --


    --    local ins = InfInspect.Inspect(InfMain.soldierPool)
    --    InfMenu.DebugPrint(ins)


    --    local soldierName="sol_ih_0000"
    --    local gameId=GameObject.GetGameObjectId("TppSoldier2",soldierName)
    --    local ins=InfInspect.Inspect(gameId)
    --    InfMenu.DebugPrint(ins)
    --    local soldierPositions={}
    --    for n,soldierName in ipairs(InfMain.reserveSoldierNames) do
    --      local gameId=GameObject.GetGameObjectId("TppSoldier2",soldierName)
    --      if gameId==GameObject.NULL_ID then
    --        InfMenu.DebugPrint(soldierName.." gameId==NULL_ID")
    --      else
    --        local warpPos=GameObject.SendCommand(gameId,{id="GetPosition"})
    --        --InfMenu.DebugPrint(soldierName.." pos:".. warpPos:GetX()..",".. warpPos:GetY().. ","..warpPos:GetZ())
    --        local string=soldierName.." pos:".. warpPos:GetX()..",".. warpPos:GetY().. ","..warpPos:GetZ()
    --        table.insert(soldierPositions,string)
    --      end
    --    end
    --    local ins=InfInspect.Inspect(soldierPositions)
    --    InfMenu.DebugPrint(ins)
    --    -------------
    --    local lrrps={}
    --    for cpName,cpDefine in pairs( mvars.ene_soldierDefine)do
    --      if string.find(cpName, "_lrrp")~=nil then
    --        lrrps[cpName]=cpDefine
    --      end
    --    end
    --    local ins=InfInspect.Inspect(lrrps)
    --    InfMenu.DebugPrint(ins)
    ---------------
    --      --
    --      --
    --    -- InfMenu.DebugPrint("names")
    --    -- local ins=InfInspect.Inspect(InfMain.reserveSoldierNames)
    --    -- InfMenu.DebugPrint(ins)
    --    -- InfMenu.DebugPrint("pool")
    --    local ins=InfInspect.Inspect(InfMain.reserveSoldierPool)
    --    InfMenu.DebugPrint(ins)





    ---------------------


    --   if GameObject.DoesGameObjectExistWithTypeName"TppEnemyHeli" then
    --    InfMenu.DebugPrint"has heli"
    --
    --   else
    --   InfMenu.DebugPrint"does not have heli"
    --   end

    -- InfMenu.DebugPrint("EnemyFova.MAX_REALIZED_COUNT="..tostring(EnemyFova.MAX_REALIZED_COUNT))

    --    InfMain.CreateCustomRevengeConfig()
    --    TppRevenge._CreateRevengeConfig()

    if true then return end
    -------------

    -----
    --InfMenu.DebugPrint"DEBUG_PrintSomeShiz"
    --InfMenu.DebugPrint("usermarkerposx: "..tostring(vars.userMarkerPosX))
    --    local ins=InfInspect.Inspect(vars,{depth=1})
    --    InfMenu.DebugPrint(ins)

    -- InfInspect.PrintGlobals()

    --    userMarkerPosX
    --userMarkerPosY
    --userMarkerPosZ
    --userMarkerAddFlag
    --userMarkerGameObjId
    --userMarkerLocationId
    --userMarkerSaveCount
  end
}


this.DEBUG_SomeShiz2={
  OnChange=function()
    local ins=InfInspect.Inspect(InfMain.mbdvc_map_mbstage_parameter)
    InfMenu.DebugPrint(ins)--

    local ins=InfInspect.Inspect(InfMain.heliLandPointTable)
    InfMenu.DebugPrint(ins)--

    if true then return true end
    --
    local objectName="ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|TppOcelot2GameObjectLocator"

    --   local objectName="ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|TppLiquid2GameObjectLocator"
    --local objectName="TppHuey2GameObjectLocator"

    --local objectName="hos_ih_0000"

    local gameId=GameObject.GetGameObjectId(objectName)
    if gameId==GameObject.NULL_ID then
      InfMenu.DebugPrint("gameid==NULL_ID")
    else

      local routes={

          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_d_0000",
          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_d_0001",
          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_d_0002",
          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_d_0003",
          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_d_0004",
          "ly003_cl00_route0000|cl00pl0_uq_0000_free|rt_free_d_0005",

      --          "ly003_cl00_route0000|cl00pl1_0_dv_0090_free|rt_free_d_0000",
      --          "ly003_cl00_route0000|cl00pl1_0_dv_0090_free|rt_free_d_0001",
      --
      --          "ly003_cl00_route0000|cl00pl1_1_dv_0080_free|rt_free_d_0000",
      --          "ly003_cl00_route0000|cl00pl1_1_dv_0080_free|rt_free_d_0001",
      --          "ly003_cl00_route0000|cl00pl1_1_dv_0080_free|rt_free_d_0002",
      --
      --          "ly003_cl00_route0000|cl00pl1_2_dv_0030_free|rt_free_d_0000",
      --          "ly003_cl00_route0000|cl00pl1_2_dv_0030_free|rt_free_d_0001",
      --          "ly003_cl00_route0000|cl00pl1_2_dv_0030_free|rt_free_d_0002",
      --
      --          "ly003_cl00_route0000|cl00pl1_3_dv_0000_free|rt_free_d_0000",
      --          "ly003_cl00_route0000|cl00pl1_3_dv_0000_free|rt_free_d_0001",
      --
      --          "ly003_cl00_route0000|cl00pl1_mb_fndt_plnt_free|rt_free_d_0000",
      --          "ly003_cl00_route0000|cl00pl1_mb_fndt_plnt_free|rt_free_d_0001",
      }

      local routeIdx=math.random(#routes)
      InfMenu.DebugPrint("routeIdx:"..routeIdx)
      local command={id="SetSneakRoute",route=routes[routeIdx]}
      GameObject.SendCommand(gameId,command)

    end
  end
}

this.DEBUG_DropItem={
  OnChange=function()

    local downposition=Vector3(vars.playerPosX,vars.playerPosY+1,vars.playerPosZ)
    --  TppPickable.DropItem{
    --    equipId =  TppEquip.EQP_IT_DevelopmentFile,
    --    number = TppMotherBaseManagementConst.DESIGN_2006,
    --    position = downposition,
    --    rotation = Quat.RotationY( 0 ),
    --    linearVelocity = Vector3(0,2,0),--Vector3( 0, 2, 0 ),
    --    angularVelocity = Vector3(0,2,0),--Vector3( 0, 2, 0 )
    --  }

    local linearMax=2
    local angularMax=14
    TppPickable.DropItem{
      equipId =  TppEquip.EQP_SWP_SmokeGrenade_G01,--EQP_SWP_C4_G04,
      number = 65535,
      position = downposition,
      rotation = Quat.RotationY( 0 ),
      linearVelocity = Vector3(math.random(-linearMax,linearMax),math.random(-linearMax,linearMax),math.random(-linearMax,linearMax)),
      angularVelocity = Vector3(math.random(-angularMax,angularMax),math.random(-angularMax,angularMax),math.random(-angularMax,angularMax)),
    }

  end
}

this.DEBUG_PrintVarsClock={
  OnChange=function()
    InfMenu.DebugPrint("vars.clock:"..vars.clock)
  end,
}

this.DEBUG_PrintPrologueTrapVars={
  OnChange=function()
    InfMenu.DebugPrint("playerInCorridorDemoTrap:"..mvars.playerInCorridorDemoTrap.." ishmaelInCorridorDemoTrap:"..mvars.ishmaelInCorridorDemoTrap)
  end,
}

this.DEBUG_PrintFultonSuccessInfo={
  OnChange=function()
    local mbFultonRank=TppMotherBaseManagement.GetSectionFuncRank{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SUPPORT_FULTON}
    local mbSectionSuccess=TppPlayer.mbSectionRankSuccessTable[mbFultonRank]or 0

    InfMenu.DebugPrint("mbFultonRank:"..mbFultonRank.." mbSectionSuccess:"..mbSectionSuccess)

    --  local doFuncSuccess=TppTerminal.DoFuncByFultonTypeSwitch(gameId,RENAMEanimalId,r,staffOrReourceId,nil,nil,nil,this.GetSoldierFultonSucceedRatio,this.GetVolginFultonSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio)
    --
    --  if doFuncSuccess==nil then
    --    InfMenu.DebugPrint"doFuncSuccess nil, bumped to 100"
    --    doFuncSuccess=100
    --  end
    --  InfMenu.DebugPrint("doFuncSuccess:"..doFuncSuccess)

  end,
}

this.DEBUG_ShowRevengeConfig={
  OnChange=function()
    --InfMenu.DebugPrint("RevRandomValue: "..gvars.rev_revengeRandomValue)
    InfMenu.DebugPrint("RevengeType:")
    local revengeType=InfInspect.Inspect(mvars.revenge_revengeType)
    InfMenu.DebugPrint(revengeType)

    InfMenu.DebugPrint("RevengeConfig:")
    local revengeConfig=InfInspect.Inspect(mvars.revenge_revengeConfig)
    InfMenu.DebugPrint(revengeConfig)
  end,
}

this.DEBUG_PrintSoldierDefine={
  OnChange=function()
    InfMenu.DebugPrint("SoldierDefine:")
    local soldierDefine=InfInspect.Inspect(mvars.ene_soldierDefine)
    InfMenu.DebugPrint(soldierDefine)
  end,
}


this.DEBUG_PrintSoldierIDList={
  OnChange=function()
    InfMenu.DebugPrint("SoldierIdList:")
    local soldierIdList=InfInspect.Inspect(mvars.ene_soldierIDList)
    InfMenu.DebugPrint(soldierIdList)
  end,
}


this.DEBUG_PrintReinforceVars={
  OnChange=function()
    InfMenu.DebugPrint("reinforce_activated: "..tostring(mvars.reinforce_activated))
    InfMenu.DebugPrint("reinforceType: "..mvars.reinforce_reinforceType)
    InfMenu.DebugPrint("reinforceCpId: "..mvars.reinforce_reinforceCpId)
    InfMenu.DebugPrint("isEnabledSoldiers: "..tostring(mvars.reinforce_isEnabledSoldiers))
    InfMenu.DebugPrint("isEnabledVehicle: "..tostring(mvars.reinforce_isEnabledVehicle))
  end,
}

this.DEBUG_PrintVehicleTypes={
  OnChange=function()
    InfMenu.DebugPrint("Vehicle.type.EASTERN_LIGHT_VEHICLE="..Vehicle.type.EASTERN_LIGHT_VEHICLE)
    InfMenu.DebugPrint("Vehicle.type.WESTERN_LIGHT_VEHICLE="..Vehicle.type.WESTERN_LIGHT_VEHICLE)
    InfMenu.DebugPrint("Vehicle.type.EASTERN_TRUCK="..Vehicle.type.EASTERN_TRUCK)
    InfMenu.DebugPrint("Vehicle.type.WESTERN_TRUCK="..Vehicle.type.WESTERN_TRUCK)
    InfMenu.DebugPrint("Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE="..Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE)
    InfMenu.DebugPrint("Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE="..Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE)
    InfMenu.DebugPrint("Vehicle.type.EASTERN_TRACKED_TANK="..Vehicle.type.EASTERN_TRACKED_TANK)
    InfMenu.DebugPrint("Vehicle.type.WESTERN_TRACKED_TANK="..Vehicle.type.WESTERN_TRACKED_TANK)
  end,
}

this.DEBUG_PrintVehiclePaint={
  OnChange=function()
    InfMenu.DebugPrint("Vehicle.class.DEFAULT="..Vehicle.class.DEFAULT)
    InfMenu.DebugPrint("Vehicle.class.DARK_GRAY="..Vehicle.class.DARK_GRAY)
    InfMenu.DebugPrint("Vehicle.class.OXIDE_RED="..Vehicle.class.OXIDE_RED)
    InfMenu.DebugPrint("Vehicle.paintType.NONE="..Vehicle.paintType.NONE)
    InfMenu.DebugPrint("Vehicle.paintType.FOVA_0="..Vehicle.paintType.FOVA_0)
    InfMenu.DebugPrint("Vehicle.paintType.FOVA_1="..Vehicle.paintType.FOVA_1)
    InfMenu.DebugPrint("Vehicle.paintType.FOVA_2="..Vehicle.paintType.FOVA_2)
  end,
}

this.DEBUG_CheckReinforceDeactivate={
  OnChange=function()
    InfMain.CheckReinforceDeactivate()
  end,
}

this.DEBUG_RandomizeCp={--CULL only for debug purpose with a print in the function
  OnChange=function()
    InfMain.RandomizeCpSubTypeTable()
  end,
}

this.DEBUG_PrintRealizedCount={
  OnChange=function()
    InfMenu.DebugPrint("MAX_REALIZED_COUNT:"..EnemyFova.MAX_REALIZED_COUNT)
  end,
}
this.DEBUG_PrintEnemyFova={
  OnChange=function()
    local infene=InfInspect.Inspect(EnemyFova)
    InfMenu.DebugPrint(infene)
    local infenemeta=InfInspect.Inspect(getmetatable(EnemyFova))
    InfMenu.DebugPrint(infenemeta)
  end,
}

this.DEBUG_PrintPowersCount={
  OnChange=function()
    --local ins=InfInspect.Inspect(mvars.ene_soldierPowerSettings)
    --InfMenu.DebugPrint(ins)
    local totalPowerSettings={}

    local totalSoldierCount=0
    local armorCount=0
    local lrrpCount=0
    for soldierId, powerSettings in pairs(mvars.ene_soldierPowerSettings) do
      totalSoldierCount=totalSoldierCount+1
      for powerType,setting in pairs(powerSettings)do
        if totalPowerSettings[powerType]==nil then
          totalPowerSettings[powerType]=0
        end

        totalPowerSettings[powerType]=totalPowerSettings[powerType]+1
      end
    end
    InfMenu.DebugPrint("totalSoldierCount:"..totalSoldierCount)
    local ins=InfInspect.Inspect(totalPowerSettings)
    InfMenu.DebugPrint(ins)
  end
}

this.DEBUG_PrintCpPowerSettings={
  OnChange=function()
    --local ins=InfInspect.Inspect(mvars.ene_soldierPowerSettings)
    -- InfMenu.DebugPrint(ins)
    if Ivars.selectedCp:Is()>0 then
      local soldierList=mvars.ene_soldierIDList[Ivars.selectedCp:Get()]
      if soldierList then
        for soldierId,n in pairs(soldierList)do
          local ins=InfInspect.Inspect(mvars.ene_soldierPowerSettings[soldierId])
          InfMenu.DebugPrint(ins)
        end
      end
    end
  end
}

this.DEBUG_PrintCpSizes={
  OnChange=function()
    local cpTypesCount={
      cp=0,
      ob=0,
      lrrp=0,
    }
    local cpTypesTotal={
      cp=0,
      ob=0,
      lrrp=0,
    }
    local cpTypesAverage={
      cp=0,
      ob=0,
      lrrp=0,
    }

    local cpSizes={}
    for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
      local soldierCount=0


      for key,value in pairs(soldierList)do
        if type(value)=="string" then
          soldierCount=soldierCount+1
        end
      end

      if soldierCount~=0 then
        if string.find(cpName, "_cp")~=nil then
          cpTypesCount.cp=cpTypesCount.cp+1
          cpTypesTotal.cp=cpTypesTotal.cp+soldierCount
        elseif string.find(cpName, "_ob")~=nil then
          cpTypesCount.ob=cpTypesCount.cp+1
          cpTypesTotal.ob=cpTypesTotal.ob+soldierCount
        elseif string.find(cpName, "_lrrp")~=nil then
          cpTypesCount.lrrp=cpTypesCount.lrrp+1
          cpTypesTotal.lrrp=cpTypesTotal.lrrp+soldierCount
        end

        cpSizes[cpName]=soldierCount
      end
    end

    for cpType,total in pairs(cpTypesTotal)do
      if cpTypesCount[cpType]~=0 then
        cpTypesAverage[cpType]=total/cpTypesCount[cpType]
      end
    end

    local ins=InfInspect.Inspect(cpSizes)
    InfMenu.DebugPrint(ins)

    local ins=InfInspect.Inspect(cpTypesAverage)
    InfMenu.DebugPrint(ins)
  end
}

this.DEBUG_ChangePhase={
  OnChange=function()
    InfMenu.DebugPrint("Changephase b")
    for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
      InfMain.ChangePhase(cpName,Ivars.maxPhase:Get())
    end
    InfMenu.DebugPrint("Changephase e")
  end
}

this.DEBUG_KeepPhaseOn={
  OnChange=function()
    InfMenu.DebugPrint("DEBUG_KeepPhaseOn b")
    for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
      InfMain.SetKeepAlert(cpName,true)
    end
    InfMenu.DebugPrint("DEBUG_KeepPhaseOn e")
  end
}

this.DEBUG_KeepPhaseOff={
  OnChange=function()
    InfMenu.DebugPrint("DEBUG_KeepPhaseOff b")
    for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
      InfMain.SetKeepAlert(cpName,false)
    end
    InfMenu.DebugPrint("DEBUG_KeepPhaseOff e")
  end
}

this.printPlayerPhase={
  OnChange=function()
    InfMenu.DebugPrint("vars.playerPhase=".. vars.playerPhase ..":".. Ivars.phaseSettings[vars.playerPhase+1])
  end,
}

this.DEBUG_SetPlayerPhaseToIvar={
  OnChange=function()
    vars.playerPhase=Ivars.maxPhase:Get()
  end,
}

this.DEBUG_ShowPhaseEnums={
  OnChange=function()
    for n, phaseName in ipairs(Ivars.maxPhase.settings) do
      InfMenu.DebugPrint(phaseName..":".. Ivars.maxPhase.settingsTable[n])
    end
  end,
}


this.DEBUG_Item2={
  OnChange=function()
    InfMenu.DebugPrint("EnemyTypes:")
    InfMenu.DebugPrint("TYPE_DD:"..EnemyType.TYPE_DD)
    InfMenu.DebugPrint("TYPE_SKULL:"..EnemyType.TYPE_SKULL )
    InfMenu.DebugPrint("TYPE_SOVIET:"..EnemyType.TYPE_SOVIET)
    InfMenu.DebugPrint("TYPE_PF:"..EnemyType.TYPE_PF )
    InfMenu.DebugPrint("TYPE_CHILD:".. EnemyType.TYPE_CHILD )
    --InfMenu.DebugPrint("bef")
    -- local strout=InfInspect.Inspect(gvars.soldierTypeForced)
    -- InfMenu.DebugPrint(strout)
    -- InfMenu.DebugPrint("aft")
  end,
}

this.DEBUG_InspectAllMenus={
  OnChange=function()
    --local instr=InfInspect.Inspect(InfMenuDefs.allMenus)
    --InfMenu.DebugPrint(instr)
    for n,menu in ipairs(InfMenuDefs.allMenus) do
      if menu==nil then
        InfMenu.DebugPrint("menu==nil at index "..n)
      elseif menu.name==nil then
        InfMenu.DebugPrint("menu.name==nil at index "..n)
      else
        InfMenu.DebugPrint(InfMenu.PrintLangId(menu.name))
      end
    end
  end,
}

this.DEBUG_ClearAnnounceLog={
  OnChange=function()
    --TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")--pretty sure this is disable
    TppUiStatusManager.ClearStatus"AnnounceLog"
  end,
}

local currentObject=1
this.DEBUG_WarpToSoldier={
  OnChange=function()
    local objectList=InfMain.reserveSoldierNames

    --local objectList=InfMain.ene_wildCardSoldiers

    --local objectList={TppReinforceBlock.REINFORCE_DRIVER_SOLDIER_NAME}

    --local objectList={"ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|TppOcelot2GameObjectLocator"}
    --local objectList={"WestHeli0001","WestHeli0000","WestHeli0002"}
    --local objectList={"EnemyHeli"}
    --local objectList={"ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|sol_plnt0_0000"}

    --local objectList={"ly003_cl00_npc0000|cl00pl0_uq_0000_npc2|TppLiquid2GameObjectLocator"}

    local objectList={
      "veh_cl01_cl00_0000",
      "veh_cl02_cl00_0000",
      "veh_cl03_cl00_0000",
      "veh_cl04_cl00_0000",
      "veh_cl05_cl00_0000",
      "veh_cl06_cl00_0000",
      "veh_cl00_cl04_0000",
      "veh_cl00_cl02_0000",
      "veh_cl00_cl03_0000",
      "veh_cl00_cl01_0000",
      "veh_cl00_cl05_0000",
      "veh_cl00_cl06_0000",
    }

    if objectList==nil then
      InfMenu.DebugPrint"objectList nil"
      return
    end

    if #objectList==0 then
      InfMenu.DebugPrint"objectList empty"
      return
    end

    local count=0
    local warpPos=Vector3(0,0,0)
    local objectName="NULL"
    local function Step()
      objectName=objectList[currentObject]
      local gameId=GameObject.GetGameObjectId(objectName)
      if gameId==GameObject.NULL_ID then
        InfMenu.DebugPrint"gameId==NULL_ID"
        warpPos=Vector3(0,0,0)
      else
        warpPos=GameObject.SendCommand(gameId,{id="GetPosition"})
        InfMenu.DebugPrint(currentObject..":"..objectName.." pos:".. warpPos:GetX()..",".. warpPos:GetY().. ","..warpPos:GetZ())
      end
      currentObject=currentObject+1
      if currentObject>#objectList then
        currentObject=1
      end
      count=count+1
    end

    Step()

    while (warpPos:GetX()==0 and warpPos:GetY()==0 and warpPos:GetZ()==0) and count<=#objectList do
      Step()
    end


    if warpPos:GetX()~=0 or warpPos:GetY()~=0 or warpPos:GetZ()~=0 then
      TppPlayer.Warp{pos={warpPos:GetX(),warpPos:GetY()+1,warpPos:GetZ()},rotY=vars.playerCameraRotation[1]}

      --      local gameId=GameObject.GetGameObjectId("TppSoldier2",soldierName)
      --      if gameId==nil or  gameId==GameObject.NULL_ID then
      --        InfMenu.DebugPrint"gameId==NULL_ID"
      --      else
      --        GameObject.SendCommand(gameId,{id="SetEnabled",enabled=true})
      --        GameObject.SendCommand(gameId,{id="SetForceRealize"})
      --      end
    end



  end,
}

this.DEBUG_WarpToReinforceVehicle={
  OnChange=function()
    local vehicleId=GameObject.GetGameObjectId("TppVehicle2",TppReinforceBlock.REINFORCE_VEHICLE_NAME)
    local driverId=GameObject.GetGameObjectId("TppSoldier2",TppReinforceBlock.REINFORCE_DRIVER_SOLDIER_NAME)

    if vehicleId==GameObject.NULL_ID then
      InfMenu.DebugPrint"vehicleId==NULL_ID"
      return
    end
    local warpPos=GameObject.SendCommand(vehicleId,{id="GetPosition"})
    InfMenu.DebugPrint("reinforce vehicle pos:".. warpPos:GetX()..",".. warpPos:GetY().. ","..warpPos:GetZ())
    TppPlayer.Warp{pos={warpPos:GetX(),warpPos:GetY(),warpPos:GetZ()},rotY=vars.playerCameraRotation[1]}
  end,
}

this.DEBUG_PrintNonDefaultVars={
  OnChange=function()
    Ivars.PrintNonDefaultVars()
  end,
}

this.DEBUG_PrintSaveVarCount={
  OnChange=function()
    Ivars.PrintSaveVarCount()
  end,
}


this.HeliMenuOnTest={--CULL: UI system overrides it :(
  OnChange=function()
    local dvcMenu={
      {menu=TppTerminal.MBDVCMENU.MSN_HELI,active=true},
      {menu=TppTerminal.MBDVCMENU.MSN_HELI_RENDEZVOUS,active=true},
      {menu=TppTerminal.MBDVCMENU.MSN_HELI_ATTACK,active=true},
      {menu=TppTerminal.MBDVCMENU.MSN_HELI_DISMISS,active=true},
    }
    InfMenu.DebugPrint("blih")--DEBUG
    TppTerminal.EnableDvcMenuByList(dvcMenu)
    InfMenu.DebugPrint("bleh")--DEBUG
  end,
}

this.changeToIdleStateHeli={--tex seems to set heli into 'not called'/invisible/wherever it goes after it's 'left'
  OnChange=function()
    local gameObjectId=GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
    if gameObjectId~=nil and gameObjectId~=GameObject.NULL_ID then
      GameObject.SendCommand(gameObjectId,{id="ChangeToIdleState"})
    end
  end
}

--TABLESETUP: MenuCommands
local IsTable=Tpp.IsTypeTable
local switchRange={max=1,min=0,increment=1}
for name,item in pairs(this) do
  if IsTable(item) then
    if item.OnChange then--TYPEID
      item.name=name
      item.default=item.default or 0
      item.setting=item.default
      item.range=item.range or switchRange
      item.settingNames=item.settingNames or "set_do"
    end
  end
end

return this

--mgo maps dont have _script packs by default
--see freeroam script packs for reference
local afc0={}
InfCore.Log("afc0locationscript")--DEBUGNOW
afc0.requires={
	--"/Assets/mgo/script/location/afc0/afc0_checkPoint.lua",
	--"/Assets/mgo/script/location/afc0/afc0_animal.lua",
	--"/Assets/mgo/script/location/afc0/afc0_gimmick.lua",
	"/Assets/mgo/script/location/afc0/afc0_routeSets.lua",
	"/Assets/mgo/script/location/afc0/afc0_cpGroups.lua",
	--"/Assets/mgo/script/location/afc0/afc0_travelPlans.lua",
	"/Assets/mgo/script/location/afc0/afc0_combat.lua",
	--"/Assets/mgo/script/location/afc0/afc0_baseTelop.lua",
	--"/Assets/mgo/script/location/afc0/afc0_base.lua",
	--"/Assets/mgo/script/location/afc0/afc0_siren.lua",
	--"/Assets/mgo/level/location/afc0/block_common/afc0_luxury_block_list.lua",
}

function afc0.OnAllocate()
	Fox.Log("###############afc0.OnAllocate###############")
	mvars.loc_locationCommonTable=afc0
	--mvars.loc_locationCommonCheckPointList=afc0_checkPoint.CheckPointList
	mvars.loc_locationCommonRouteSets=afc0_routeSets
	mvars.loc_locationCommonCpGroups=afc0_cpGroups
	--mvars.loc_locationCommonTravelPlans=afc0_travelPlans
	mvars.loc_locationCommonCombat=afc0_combat
	--mvars.loc_locationGimmickCpConnectTable=afc0_gimmick.gimmickCpConnectTable
	--mvars.loc_locationBaseTelop=afc0_baseTelop
	--mvars.loc_locationSiren=afc0_siren
	--afc0_animal.OnAllocate()
end

function afc0.OnInitialize()
	Fox.Log("###############afc0.OnInitialize###############")
	--afc0_gimmick.OnInitialize()
	--afc0_base.OnInitialize()	
end

function afc0.OnReload()
	
end

function afc0.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
	strLogText="afc0.lua:"..strLogText
	
	--ifafc0_animal.OnMessagethen
	--	afc0_animal.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
	--end
	--afc0_gimmick.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end

function afc0.OnMissionCanStart()
	--afc0_luxury_block_list.RegistLuxuryBlock()
	--afc0_animal.OnMissionCanStart()
end

return afc0
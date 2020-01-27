-- ih_save.lua
-- Save file for IH options
-- While this file is editable, editing an inMission save is likely to cause issues, and it's preferable that you use InfProfiles.lua instead.
-- See Readme for more info
local this={}
this.loadToACC=false
this.ihVer=232
this.saveTime=1550528974
this.inMission=false
this.evars={
	enableWildCardFreeRoam=1,
	mbUnlockGoalDoors=1,
	repopulateRadioTapes=1,
	defaultHeliDoorOpenTime=120,
	mbShowCodeTalker=1,
	selectEvent=9,
	revengeDecayOnLongMbVisit=1,
	resourceScalePoster=1000,
	handLevelPhysical=2,
	supportHeliPatrolsMB=3,
	mbPrioritizeFemale=3,
	speedCamWorldTimeScale=3,
	mbCollectionRepop=1,
	customWeaponTableMB_ALL=1,
	mbEnableOcelot=1,
	mbEnablePuppy=2,
	enableIRSensorsMB=1,
	soldierNightSightDistScale=105,
	customSoldierTypeFREE=25,
	mbEnableBuddies=1,
	allowHeadGearCombo=1,
	allowUndevelopedDDEquip=1,
	weaponTableStrength=2,
	armorParasiteEnabled=0,
	enableFovaMod=1,
	unlockSideOps=1,
	unlockSideOpNumber=162,
	soldierHearingDistScale=110,
	resourceScaleMaterial=1000,
	playerHealthScale=650,
	soldierSightDistScale=115,
	resourceScaleDiamond=1000,
	enableHelp=1,
	customSoldierTypeMB_ALL=25,
	applyPowersToLrrp=1,
	disableHeliAttack=1,
	hideAAGatlingsMB=1,
	speedCamContinueTime=1000,
	mbShowShips=1,
	randomizeMineTypes=1,
	revengeModeMB_ALL=4,
	disableOutOfBoundsChecks=1,
	enableResourceScale=1,
	setLandingZoneWaitHeightTop=10,
	disableNoStealthCombatRevengeMission=1,
	weather_fogDensity=0.001001,
	mbWargameFemales=40,
	handLevelPrecision=2,
	enableMgVsShotgunVariation=1,
	debugMessages=1,
	setInvincibleHeli=1,
	additionalMineFields=1,
	enableIHExt=1,
	mbEnableBirds=1,
	mbShowHuey=1,
	mbShowSahelan=1,
	fovaPlayerType=1,
	mbAdditionalNpcs=1,
	enableSoldiersWithVehicleReinforce=1,
	speedCamPlayerTimeScale=4.1,
	enableLrrpFreeRoam=1,
	mbShowEli=1,
	mbqfEnableSoldiers=1,
	mbNpcRouteChange=1,
	putEquipOnTrucks=1,
	vehiclePatrolProfile=2,
	mbWalkerGearsColor=7,
	attackHeliPatrolsMB=4,
	attackHeliPatrolsFREE=4,
	allowMissileWeaponsCombo=1,
	sys_increaseMemoryAlloc=1,
	vehiclePatrolClass=5,
	mistParasiteEnabled=0,
	soldierAlertOnHeavyVehicleDamage=1,
	revengeModeMISSION=1,
	enableQuickMenu=1,
	mbAdditionalSoldiers=1,
	showAllOpenSideopsOnUi=1,
	enableInfInterrogation=1,
	useSoldierForDemos=1,
	enableWalkerGearsFREE=1,
	mbForceBattleGearDevelopLevel=1,
	sideOpsSelectionMode=1,
	soldierParamsProfile=1,
	customSoldierTypeFemaleMB_ALL=7,
	mbMoraleBoosts=1,
	gameEventChanceFREE=5,
	enableWalkerGearsMB=1,
	debugMode=1,
	fovaSelection=13,
	moveScale=1.004,
	startOnFootMB_ALL=1,
	debugFlow=1,
	maleFaceId=89,
	mbEnableMissionPrep=1,
	startOnFootFREE=2,
	quest_useAltForceFulton=1,
	resourceScalePlant=1000,
	mbEnemyHeliColor=4,
	resourceScaleContainer=1000,
	forceSuperReinforce=2,
	applyPowersToOuterBase=1,
	debugOnUpdate=1,
}
this.igvars={
	mis_isGroundStart=true,
	inf_event=false,
	name="IvarsPersist",
	bodyTypeExtend="",
	bodyType="",
	mbRepopDiamondCountdown=2,
	inf_levelSeed=-57738979,
}
this.questStates={
	ih_quest_q30100=25,
	ih_quest_q30155=9,
	ih_quest_q30101=17,
	ih_quest_q30102=17,
}
return this
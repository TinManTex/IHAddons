--InfNPCHeli.lua
--handles heli variations and patrols
--thanks caplag for discovering that TppHeli2Parameter works across heli types (great find!), which allows the attackHeliType UTH option
--TODO: test TppEnemyHeli west_heli to see what issues it has
--one obvious issue is it not firing its missiles
--caplag also noticed it was missing sounds? (what ones?)
--TODO: better patrol routes
--loop around base with (if possible) gun looking at spots inside, but than would have to start tracking state again to give it a number of loops (or just manually build a few loops into route)
--TODO: shift to custom routes and sendmessage, then can kill update and shift route changes to timers.
--DEBUGNOW msg_heli_patrol_route_end etc
--TODO: rebuild reinforce_west_heli_<location>_ih packs to be based off combo of vanilla reinforce_heli_<location>
--to be a standalone reinforce_heli_<location> replacement
--currently is just reinforce_heli_<location> with modded enemy_heli_afgh
--and is just relying on mis_com_heli being loaded to support UTH
--TODO: heli packs:
--/Assets/tpp/pack/soldier/reinforce/reinforce_heli_afgh.fpk
--figure out why Internal doors are visually dark on the outside
--/Assets/tpp/pack/fova/mecha/uth/uth_v00_fv2_ih.fpk
--build pftxs for all the uth fova
--TODO: if have more than 3 fova types then split fova from heliclass
--(that is if cmd SetColoring coloringType actually controls it independantly/doesnt have other side effects)
local this={}

--LOCALOPT
local InfCore=InfCore
local InfMain=InfMain
local StrCode32=InfCore.StrCode32
local NULL_ID=GameObject.NULL_ID
local GetGameObjectId=GameObject.GetGameObjectId
local GetTypeIndex=GameObject.GetTypeIndex
local SendCommand=GameObject.SendCommand
local TppMath=TppMath
local math=math
local IsNight=WeatherManager.IsNight
local InfUtil=InfUtil
local Ivars=Ivars
local IvarProc=IvarProc

this.debugModule=false

--updateState
this.active=0
this.execCheckTable={inGame=true,inSafeSpace=false}
this.execState={
  nextUpdate=0,
}

--STATE
this.heliList={}

local heliTimes={}
this.heliClusters={}--tex cluster for mb


this.enabledLzs=nil--tex free: is just this.heliRoutes[locationName], for mb is enabled lz in mtbs_cluster.SetUpLandingZone

local routesBag=nil--tex Free: ShuffleBag of enabledLzs

--TUNE
local routeTimeMbMin=3*60
local routeTimeMbMax=6*60

local routeTimeMin=4*60
local routeTimeMax=5*60

local levelToColor={0,0,0,1,1,2}

local attackHeliPatrolsStr="attackHeliPatrols"

this.totalAttackHelis=5--tex for svars, must match max instance count/fox2 totalcount (so includes reinforce/quest heli)

--tex see note where this is actually read (in AddMissionPacks)
--GOTCH: if you expand fova you will need to convert attackHeliFova to cmd SetColoring coloringType, which I think sets the health of the heli
this.packages={
  SBH={
    --tex modded versions of vanilla reinforce_heli_<location>.fpks
    --increases totalCount and realisedCount, adds Internal / interior
    --TODO figure out why Internal doors are visually dark on the outside
    afgh="/Assets/tpp/pack/soldier/reinforce/reinforce_heli_afgh.fpk",
    mafr="/Assets/tpp/pack/soldier/reinforce/reinforce_heli_mafr.fpk",
    mtbs="/Assets/tpp/pack/soldier/reinforce/reinforce_heli_afgh.fpk",--TODO
    fova={
      --DEFAULT=,
      BLACK="/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_blk.fpk",
      RED="/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_red.fpk",
    },
  },
  UTH={
    afgh="/Assets/tpp/pack/soldier/reinforce/reinforce_west_heli_afgh_ih.fpk",
    mafr="/Assets/tpp/pack/soldier/reinforce/reinforce_west_heli_afgh_ih.fpk",--TODO
    mtbs="/Assets/tpp/pack/soldier/reinforce/reinforce_west_heli_afgh_ih.fpk",--TODO
    fova={
      uth_v00="/Assets/tpp/pack/fova/mecha/uth/uth_v00_fv2_ih.fpk",
      uth_v02="/Assets/tpp/pack/fova/mecha/uth/uth_v02_fv2_ih.fpk",
      uth_v03="/Assets/tpp/pack/fova/mecha/uth/uth_v03_fv2_ih.fpk",
    },
  },
  afgh={"/Assets/tpp/pack/mission2/ih/heli_patrol_routes_afgh.fpk",},
  mafr={"/Assets/tpp/pack/mission2/ih/heli_patrol_routes_mafr.fpk",},
  mtbs={},
  mbqf={},
  --tex currently only mtbs
  westheli={
    "/Assets/tpp/pack/mission2/ih/ih_westheli_defloc.fpk",
  },
  "/Assets/tpp/pack/mission2/ih/ih_enemyheli_loc.fpk",--tex 4 TppEnemyHeli locators
}--packages

--tex indexed by fovaId
this.heliFova={
  SBH={
    "",--DEFAULT,
    "/Assets/tpp/fova/mecha/sbh/sbh_ene_blk.fv2",
    "/Assets/tpp/fova/mecha/sbh/sbh_ene_red.fv2",
  },
  UTH={
    "/Assets/tpp/fova/mecha/uth/uth_v00_fv2.fv2",
    "/Assets/tpp/fova/mecha/uth/uth_v02_fv2.fv2",
    "/Assets/tpp/fova/mecha/uth/uth_v03_fv2.fv2",
  },
}

--tex defined by the entity/data definitions
this.heliNames={
  UTH={
    "WestHeli0000",
    "WestHeli0001",
    "WestHeli0002",
  },
  --GOTCHA: UTH/west_heli as TppEnemyHeli uses the EnemyHeli locators
  EnemyHeli={--tex was HP48
    --tex don't know if I want to use "EnemyHeli" since there's a lot of other stuff tied to its name via quest heli and reinforce heli
    --"EnemyHeli",
    "EnemyHeli0000",
    "EnemyHeli0001",
    "EnemyHeli0002",
    "EnemyHeli0003",
  --tex reduced due to crash bug/match enemy_heli_<locaction>.fox2
  --      "EnemyHeli0004",
  --      "EnemyHeli0005",
  --    "EnemyHeli0006",
  },
}--heliNames

--SYNC number of locators
this.maxHelis={
  UTH=3,
  EnemyHeli=4,
}

--tex TODO: pre convert to str32
this.heliRoutes={
  afgh={
    --    "lz_drp_enemyBase_N0000|rt_drp_enemyBase_N_0000",
    --    "lz_drp_field_N0000|rt_drp_field_N_0000",
    --    "lz_drp_enemyBase_S0000|rt_drp_enemyBase_S_0000",
    --    "lz_drp_citadelSouth_S0000|rt_drp_citadelSouth_S_0000",
    --    "lz_drp_commFacility_S0000|rt_drp_commFacility_S_0000",
    --    "lz_drp_cliffTown_N0000|rt_drp_clifftown_N_0000",
    --    "lz_drp_sovietBase_N0000|rt_drp_sovietBase_N_0000",
    --    "lz_drp_cliffTownWest_S0000|rt_drp_cliffTownWest_S_0000",
    --    "lz_drp_field_W0000|rt_drp_field_W_0000",
    "lz_drp_field_I0000|rt_drp_field_I_0000-IH",--fort with fields assault (Da Shago Kallai)
    --    "lz_drp_remnantsNorth_N0000|rt_drp_remnantsNorth_N_0000",
    --    "lz_drp_fort_E0000|rt_drp_fort_E_0000",
    --    "lz_drp_slopedTownEast_E0000|rt_drp_slopedTownEast_E_0000",
    "lz_drp_commFacility_I0000|rt_drp_commFacility_I_0000-IH",--Eastern Communications Post assault
    --    "lz_drp_waterway_I0000|rt_drp_waterway_I_0000",
    --    "lz_drp_sovietBase_S0000|rt_drp_sovietBase_S_0000",
    --    "lz_drp_powerPlant_S0000|rt_drp_powerPlant_S_0000",
    --    "lz_drp_bridge_S0000|rt_drp_bridge_S_0000",
    --    "lz_drp_fieldWest_S0000|rt_drp_fiieldWest_S_0000",
    --    "lz_drp_remnants_S0000|rt_drp_remnants_S_0000",
    --    "lz_drp_slopedTown_E0000|rt_drp_slopedTown_E_0000",
    --    "lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000",
    "lz_drp_slopedTown_I0000|rt_drp_slopedTown_I_0000-IH",--Da Ghwandai Khar assault
    "lz_drp_fort_I0000|rt_drp_fort_I_0000-IH",--valley fort assault (Sa Smasei Laman)
    "lz_drp_tent_I0000|rt_drp_tent_I_0000-IH",--volgin body fort assault (Yakho Oboo Supply Outpost)
    --    "lz_drp_village_W0000|rt_drp_village_W_0000",
    --    "lz_drp_remnantsNorth_S0000|rt_drp_remnantsNorth_S_0000",
    "lz_drp_village_N0000|rt_drp_village_N_0000-IH",--Da Wialo Kallai (not assault)
    --    "lz_drp_tent_N0000|rt_drp_tent_N_0000",
    --    "lz_drp_tent_E0000|rt_drp_tent_E_0000",
    --    "lz_drp_slopedTown_W0000|rt_drp_slopedTown_W_0000",
    "lz_drp_remnants_I0000|rt_drp_remnants_I_0000-IH",--Palace assault (Lamar Khaate Palace)
    --    "lz_drp_fort_W0000|rt_drp_fort_W_0000",
    --    "lz_drp_commFacility_W0000|rt_drp_commFacility_W_0000",
    "lz_drp_cliffTown_I0000|rt_drp_cliffTown_I0000-IH",--cliff town assault (Qarya Sakhra Ee)
    "lz_drp_powerPlant_E0000|rt_drp_powerPlant_E_0000-IH",--powerplant assault (Serak Power Plant)
    --    "lz_drp_cliffTown_S0000|rt_drp_cliffTown_S_0000",
    "lz_drp_enemyBase_I0000|rt_drp_enemyBase_I_0000-IH",--Barracks assault (Wakh Sind Barracks)
    --    "lz_drp_ruins_S0000|rt_drp_ruins_S_0000",
    "lz_drp_sovietBase_E0000|rt_drp_sovietBase_E_0000-IH",--Central Base assault (Afhanistan Central Base Camp)
  --"lz_drp_sovietSouth_S0000|rt_drp_sovietSouth_S_0000",
  },
  mafr={
    "lz_drp_lab_W0000|rt_drp_lab_W_0000-IH",--Luftwa Valley NW, OB 08 E
    "lz_drp_hill_I0000|rt_drp_hill_I_0000-IH",--Munoko ya Nioka Station assault
    --"lz_drp_diamond_N0000|rt_drp_diamond_N_0000",--Mine N
    --"lz_drp_swamp_S0000|rt_drp_swamp_S_0000",--Kiziba Camp SW
    --"lz_drp_savannahWest_N0000|lz_drp_savannahWest_N_0000",--Plantation S, OB 04 E, OB 03 W, OB 05 W, OB09 N
    --"lz_drp_diamondWest_S0000|lz_drp_diamondWest_S_0000",--Mine W, OB05,03 SE, OB07 W
    "lz_drp_swamp_I0000|rt_drp_swamp_I_0000-IH",--Kiziba Camp assault
    "lz_drp_pfCamp_I0000|rt_drp_pfCamp_I_0000-IH",-- Airport assault (Nova Braga)
    "lz_drp_savannah_I0000|rt_drp_savannah_I_0000-IH",--Abandoned village tall hill/overlooking cliff assault (Ditadi Abandoned Village)
    --"lz_drp_pfCamp_N0000|rt_drp_pfcamp_N_0000",
    "lz_drp_diamond_I0000|rt_drp_diamond_I_0000-IH",--Mine assault (Kungenga Mine)
    --"lz_drp_diamondSouth_W0000|rt_drp_diamondSouth_W_0000",--Mine SW, OB05,07 S, OB13N
    --"lz_drp_factoryWest_S0000|lz_drp_factoryWest_S_0000",
    --"lz_drp_pfCamp_S0000|lz_drp_pfCamp_S_0000",
    --"lz_drp_swamp_N0000|lz_drp_swamp_N_0000",--Kiziba N, OB 01 E
    --"lz_drp_labWest_W0000|rt_drp_labWest_W_0000",--Luftwa Valley W, OB02 E, OB08 W
    --"lz_drp_lab_S0000|rt_drp_lab_S_0000",--Luftwa Valley SW
    --"lz_drp_savannahEast_S0000|lz_drp_savannahEast_S_0000",
    --"lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000",
    --"lz_drp_hill_N0000|lz_drp_hill_N_0000",
    --"lz_drp_pfCampNorth_S0000|rt_drp_pfCampNorth_S_0000",
    --"lz_drp_swamp_W0000|lz_drp_swamp_W_0000",--Mfinda S, Kizba NW, OP 01 W
    --"lz_drp_bananaSouth_N0000|rt_drp_bananaSouth_N_0000",
    --"lz_drp_swampEast_N0000|lz_drp_swampEast_N_0000",--Kiziba E, OB 10 N
    --"lz_drp_diamondSouth_S0000|lz_drp_diamondSouth_S_0000",
    --"lz_drp_hillSouth_W0000|lz_drp_hillSouth_W_0000",
    "lz_drp_banana_I0000|rt_drp_banana_I_0000-IH",--Bampeve Plantation assault
    --"lz_drp_hill_E0000|lz_drp_hill_E_0000",
    --"lz_drp_factory_N0000|rt_drp_factory_N_0000",
    --"lz_drp_savannahEast_N0000|rt_drp_savannahEast_N_0000",
    --"lz_drp_flowStation_E0000|lz_drp_flowStation_E_0000",--Mfinda Oilfield east/ outpost 01
    "lz_drp_flowStation_I0000|rt_drp_flowStation_I_0000-IH",--Mfinda Oilfield assault
  --"lz_drp_outland_S0000|rt_drp_outland_S_0000",
  },
}

--tex distances are distsquared
local routeInfos={
  afgh={
    --    "lz_drp_enemyBase_N0000|rt_drp_enemyBase_N_0000",
    --    "lz_drp_field_N0000|rt_drp_field_N_0000",
    --    "lz_drp_enemyBase_S0000|rt_drp_enemyBase_S_0000",
    --    "lz_drp_citadelSouth_S0000|rt_drp_citadelSouth_S_0000",
    --    "lz_drp_commFacility_S0000|rt_drp_commFacility_S_0000",
    --    "lz_drp_cliffTown_N0000|rt_drp_clifftown_N_0000",
    --    "lz_drp_sovietBase_N0000|rt_drp_sovietBase_N_0000",
    --    "lz_drp_cliffTownWest_S0000|rt_drp_cliffTownWest_S_0000",
    --    "lz_drp_field_W0000|rt_drp_field_W_0000",
    [StrCode32"lz_drp_field_I0000|rt_drp_field_I_0000"]={arrivedDistance=10,exitTime={25,60}},--fort with fields assault (Da Shago Kallai)
    --    "lz_drp_remnantsNorth_N0000|rt_drp_remnantsNorth_N_0000",
    --    "lz_drp_fort_E0000|rt_drp_fort_E_0000",
    --    "lz_drp_slopedTownEast_E0000|rt_drp_slopedTownEast_E_0000",
    [StrCode32"lz_drp_commFacility_I0000|rt_drp_commFacility_I_0000"]={arrivedDistance=10,exitTime={20,60}},--Eastern Communications Post assault --could have long exit 5+
    --    "lz_drp_waterway_I0000|rt_drp_waterway_I_0000",
    --    "lz_drp_sovietBase_S0000|rt_drp_sovietBase_S_0000",
    --    "lz_drp_powerPlant_S0000|rt_drp_powerPlant_S_0000",
    --    "lz_drp_bridge_S0000|rt_drp_bridge_S_0000",
    --    "lz_drp_fieldWest_S0000|rt_drp_fiieldWest_S_0000",
    --    "lz_drp_remnants_S0000|rt_drp_remnants_S_0000",
    --    "lz_drp_slopedTown_E0000|rt_drp_slopedTown_E_0000",
    --    "lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000",
    [StrCode32"lz_drp_slopedTown_I0000|rt_drp_slopedTown_I_0000"]={arrivedDistance=12,exitTime={25,50}},--Kaz rescue village assault (Da Ghwandai Khar)
    [StrCode32"lz_drp_fort_I0000|rt_drp_fort_I_0000"]={arrivedDistance=20,exitTime={30,50}},--valley fort assault (Sa Smasei Laman)
    [StrCode32"lz_drp_tent_I0000|rt_drp_tent_I_0000"]={stickDistance=260},--volgin body fort assault (Yakho Oboo Supply Outpost)
    --    "lz_drp_village_W0000|rt_drp_village_W_0000",
    --    "lz_drp_remnantsNorth_S0000|rt_drp_remnantsNorth_S_0000",
    [StrCode32"lz_drp_village_N0000|rt_drp_village_N_0000"]={arrivedDistance=28,exitTime={15,50}},--Da Wialo Kallai (not assault) -- could have long exit 5+
    --    "lz_drp_tent_N0000|rt_drp_tent_N_0000",
    --    "lz_drp_tent_E0000|rt_drp_tent_E_0000",
    --    "lz_drp_slopedTown_W0000|rt_drp_slopedTown_W_0000",
    [StrCode32"lz_drp_remnants_I0000|rt_drp_remnants_I_0000"]={arrivedDistance=35,exitTime={20,35}},--Palace assault (Lamar Khaate Palace)
    --    "lz_drp_fort_W0000|rt_drp_fort_W_0000",
    --    "lz_drp_commFacility_W0000|rt_drp_commFacility_W_0000",
    [StrCode32"lz_drp_cliffTown_I0000|rt_drp_cliffTown_I0000"]={arrivedDistance=30,exitTime={40,60}},--cliff town assault (Qarya Sakhra Ee) --could have long exit
    [StrCode32"lz_drp_powerPlant_E0000|rt_drp_powerPlant_E_0000"]={arrivedDistance=440,exitTime={35,60}},--powerplant assault (Serak Power Plant), almost gets stuck, stickdist would be ~440, sould have long
    --    "lz_drp_cliffTown_S0000|rt_drp_cliffTown_S_0000",
    [StrCode32"lz_drp_enemyBase_I0000|rt_drp_enemyBase_I_0000"]={arrivedDistance=10,exitTime={25,60}},--Barracks assault (Wakh Sind Barracks)
    --    "lz_drp_ruins_S0000|rt_drp_ruins_S_0000",
    [StrCode32"lz_drp_sovietBase_E0000|rt_drp_sovietBase_E_0000"]={arrivedDistance=10,exitTime={50,70}},--Central Base assault (Afhanistan Central Base Camp)
  --"lz_drp_sovietSouth_S0000|rt_drp_sovietSouth_S_0000",
  },
  mafr={
    [StrCode32"lz_drp_lab_W0000|rt_drp_lab_W_0000"]={stickDistance=102},--Luftwa Valley NW, OB 08 E
    [StrCode32"lz_drp_hill_I0000|rt_drp_hill_I_0000"]={stickDistance=60},--Munoko ya Nioka Station assault
    --[StrCode32"lz_drp_diamond_N0000|rt_drp_diamond_N_0000"--Mine N
    --[StrCode32"lz_drp_swamp_S0000|rt_drp_swamp_S_0000"--Kiziba Camp SW
    --[StrCode32"lz_drp_savannahWest_N0000|lz_drp_savannahWest_N_0000"--Plantation S, OB 04 E, OB 03 W, OB 05 W, OB09 N
    --[StrCode32"lz_drp_diamondWest_S0000|lz_drp_diamondWest_S_0000"--Mine W, OB05,03 SE, OB07 W
    [StrCode32"lz_drp_swamp_I0000|rt_drp_swamp_I_0000"]={arrivedDistance=10,exitTime={20,60}},--Kiziba Camp assault
    [StrCode32"lz_drp_pfCamp_I0000|rt_drp_pfCamp_I_0000"]={arrivedDistance=10,exitTime={20,60}},-- Airport assault (Nova Braga)
    [StrCode32"lz_drp_savannah_I0000|rt_drp_savannah_I_0000"]={arrivedDistance=10,exitTime={20,40}},--Abandoned village tall hill/overlooking cliff assault (Ditadi Abandoned Village)
    --[StrCode32"lz_drp_pfCamp_N0000|rt_drp_pfcamp_N_0000",
    [StrCode32"lz_drp_diamond_I0000|rt_drp_diamond_I_0000"]={stickDistance=60},--Mine assault (Kungenga Mine)
    --[StrCode32"lz_drp_diamondSouth_W0000|rt_drp_diamondSouth_W_0000"--Mine SW, OB05,07 S, OB13N
    --[StrCode32"lz_drp_factoryWest_S0000|lz_drp_factoryWest_S_0000",
    --[StrCode32"lz_drp_pfCamp_S0000|lz_drp_pfCamp_S_0000",
    --[StrCode32"lz_drp_swamp_N0000|lz_drp_swamp_N_0000"--Kiziba N, OB 01 E
    --[StrCode32"lz_drp_labWest_W0000|rt_drp_labWest_W_0000"--Luftwa Valley W, OB02 E, OB08 W
    --[StrCode32"lz_drp_lab_S0000|rt_drp_lab_S_0000"--Luftwa Valley SW
    --[StrCode32"lz_drp_savannahEast_S0000|lz_drp_savannahEast_S_0000",
    --[StrCode32"lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000",
    --[StrCode32"lz_drp_hill_N0000|lz_drp_hill_N_0000",
    --[StrCode32"lz_drp_pfCampNorth_S0000|rt_drp_pfCampNorth_S_0000",
    --[StrCode32"lz_drp_swamp_W0000|lz_drp_swamp_W_0000"--Mfinda S, Kizba NW, OP 01 W
    --[StrCode32"lz_drp_bananaSouth_N0000|rt_drp_bananaSouth_N_0000",
    --[StrCode32"lz_drp_swampEast_N0000|lz_drp_swampEast_N_0000"--Kiziba E, OB 10 N
    --[StrCode32"lz_drp_diamondSouth_S0000|lz_drp_diamondSouth_S_0000",
    --[StrCode32"lz_drp_hillSouth_W0000|lz_drp_hillSouth_W_0000",
    [StrCode32"lz_drp_banana_I0000|rt_drp_banana_I_0000"]={stickDistance=15},--Bampeve Plantation assault
    --[StrCode32"lz_drp_hill_E0000|lz_drp_hill_E_0000",
    --[StrCode32"lz_drp_factory_N0000|rt_drp_factory_N_0000",
    --[StrCode32"lz_drp_savannahEast_N0000|rt_drp_savannahEast_N_0000",
    --[StrCode32"lz_drp_flowStation_E0000|lz_drp_flowStation_E_0000"--Mfinda Oilfield east/ outpost 01
    [StrCode32"lz_drp_flowStation_I0000|rt_drp_flowStation_I_0000"]={arrivedDistance=10,exitTime={20,60}},--Mfinda Oilfield assault
  --[StrCode32"lz_drp_outland_S0000|rt_drp_outland_S_0000",
  },
}
this.heliRouteToCp={
  afgh={
    ["lz_drp_field_I0000|rt_drp_field_I_0000"]="afgh_field_cp",
    ["lz_drp_commFacility_I0000|rt_drp_commFacility_I_0000"]="afgh_commFacility_cp",
    --    "lz_drp_waterway_I0000|rt_drp_waterway_I_0000",--??
    ["lz_drp_slopedTown_I0000|rt_drp_slopedTown_I_0000"]="afgh_slopedTown_cp",
    ["lz_drp_fort_I0000|rt_drp_fort_I_0000"]="afgh_fort_cp",
    ["lz_drp_tent_I0000|rt_drp_tent_I_0000"]="afgh_tent_cp",
    ["lz_drp_village_N0000|rt_drp_village_N_0000"]="afgh_village_cp",
    ["lz_drp_remnants_I0000|rt_drp_remnants_I_0000"]="afgh_remnants_cp",
    ["lz_drp_cliffTown_I0000|rt_drp_cliffTown_I0000"]="afgh_cliffTown_cp",
    ["lz_drp_powerPlant_E0000|rt_drp_powerPlant_E_0000"]="afgh_powerPlant_cp",
    ["lz_drp_enemyBase_I0000|rt_drp_enemyBase_I_0000"]="afgh_enemyBase_cp",
    ["lz_drp_sovietBase_E0000|rt_drp_sovietBase_E_0000"]="afgh_sovietBase_cp",
  },
  mafr={
    ["lz_drp_hill_I0000|rt_drp_hill_I_0000"]="mafr_hill_cp",
    ["lz_drp_swamp_I0000|rt_drp_swamp_I_0000"]="mafr_swamp_cp",
    ["lz_drp_pfCamp_I0000|rt_drp_pfCamp_I_0000"]="mafr_pfCamp_cp",
    ["lz_drp_savannah_I0000|rt_drp_savannah_I_0000"]="mafr_savannah_cp",
    ["lz_drp_diamond_I0000|rt_drp_diamond_I_0000"]="mafr_diamond_cp",
    ["lz_drp_banana_I0000|rt_drp_banana_I_0000"]="mafr_banana_cp",
    ["lz_drp_flowStation_I0000|rt_drp_flowStation_I_0000"]="mafr_flowStation_cp",
  },
}
this.cpToHeliRoute={
  afgh={},
  mafr={},
}
for location,routeCpInfo in pairs(this.heliRouteToCp)do
  for route,cpName in pairs(routeCpInfo)do
    this.cpToHeliRoute[location][cpName]=route
  end
end

--ivar defs>
this.registerIvars={
  "supportHeliPatrolsMB",
}

IvarProc.MissionModeIvars(
  this,
  "attackHeliPatrols",
  {
    save=IvarProc.CATEGORY_EXTERNAL,
    --CULL range={max=4,min=0,increment=1},
    settings={"0","1","2","3","4","ENEMY_PREP"},--SYNC #InfNPCHeli.heliNames.EnemyHeli
    settingNames="attackHeliPatrolsSettings",
  },
  {"FREE","MB",}
)
this.attackHeliPatrolsFREE.MissionCheck=IvarProc.MissionCheckFreeVanilla--tex WORKAROUND: want to change the mission mode check but don't want to trample users exising saves with a name change

IvarProc.MissionModeIvars(
  this,
  "attackHeliType",
  {
    save=IvarProc.CATEGORY_EXTERNAL,
    settings={"SBH","UTH"},
    settingNames="attackHeliTypeSettings",
  },
  {"FREE","MB",}--tex MB also has supportHeliPatrolsMB, but those are TppOtherHeli, want TppEnemyHeli for WARGAMES/MB attack
)
this.settingsHeliType={
  SBH={"DEFAULT","BLACK","RED","RANDOM","RANDOM_EACH","ENEMY_PREP"},
  UTH={"uth_v00","uth_v02","uth_v03","RANDOM","RANDOM_EACH","ENEMY_PREP"},
}
IvarProc.MissionModeIvars(
  this,
  "attackHeliFova",
  {
    save=IvarProc.CATEGORY_EXTERNAL,
    settings={},--DYNAMIC
    OnSelect=function(self)
      local attackHeliTypeName=this["attackHeliType"..self.missionMode]:GetSettingName()
      local currentSettings=this.settingsHeliType[attackHeliTypeName]
      IvarProc.SetSettings(self,currentSettings)
      self.settingNames="attackHeliFovaSettings"..attackHeliTypeName
    end,
  },
  {"FREE","MB",}
)

this.supportHeliPatrolsMB={
  save=IvarProc.CATEGORY_EXTERNAL,
  range={max=3,min=0,increment=1},
  MissionCheck=IvarProc.MissionCheckMb,
}
--<
this.langStrings={
  eng={
    attackHeliTypeFREE="Attack heli type in FreeRoam",
    attackHeliTypeMB="Attack heli type in MB",
    attackHeliTypeSettings={"HP-48 Krokodil","UTH-66 Blackfoot"},
    attackHeliFovaFREE="Attack heli class in FreeRoam",
    attackHeliFovaMB="Attack heli class in MB",
    attackHeliFovaSettingsSBH={"Default","Black","Red","All one random type","Each heli random type","Enemy prep"},
    attackHeliFovaSettingsUTH={"uth_v00","uth_v02","uth_v03","All one random type","Each heli random type","Enemy prep"},
    attackHeliPatrolsFREE="Attack heli patrols in free roam",
    attackHeliPatrolsMB="Attack heli patrols in MB",
    supportHeliPatrolsMB="NPC support heli patrols in MB",
    attackHeliPatrolsSettings={"No helis","1 heli","2 helis","3 helis","4 helis","Enemy prep"},
  },
  help={
    eng={
      attackHeliPatrolsMB="Spawns some npc attack helis that roam around mother base.",
      supportHeliPatrolsMB="Spawns some npc support helis that roam around mother base.",
      attackHeliPatrolsFREE="Allows multiple enemy helicopters that travel between larger CPs. Due to limitations their current position will not be saved/restored so may 'dissapear/appear' on reload.",
      attackHeliFovaFREE="Combined appearance and health",
      attackHeliFovaFREE="Combined appearance and health",
    },
  }
}
--<
function this.AddMissionPacks(missionCode,packPaths)
  --tex DEBUGNOW might be better to shift TppEnemyHeli stuff back to TppReinforceBlock .GetFpk
  --but this way makes it independent of reinforce_block being loaded
  --tex GOTCHA: this overrides TppReinforceBlock.LoadReinforceBlock GetFpk / TppReinforceBlock.REINFORCE_FPK
  --since the fox2 (which is derived from the normal reinforce fpk) is already loaded by the time TppReinforceBlock spins up.
  local locationName=InfUtil.GetLocationName()
  if IvarProc.EnabledForMission(attackHeliPatrolsStr,missionCode) then

    --tex add packs by heliType
    local attackHeliTypeName=IvarProc.GetSettingNameForMission("attackHeliType",missionCode)
    InfCore.Log("InfNPCHeli.AddMissionPacks: attackHeliTypeName:"..tostring(attackHeliTypeName))--tex DEBUG
    local heliPackages=this.packages[attackHeliTypeName]
    local heliTypeLocationPack=heliPackages[locationName]
    if type(heliTypeLocationPack)~="string"then
      InfCore.Log("WARNING: InfNPCHeli.AddMissionPacks: heliPackageForLocation is not a string")
    else
      table.insert(packPaths,heliTypeLocationPack)
    end
    --tex fova packs / sbh reinforce block 'coloring'
    --DEBUGNOW I should only add color packs requested by ivar, but since the RANDOM is only resolved in Init thats not a quick implement
    --so just adding all
    for fovaType,fpkPath in pairs(heliPackages.fova)do
      table.insert(packPaths,fpkPath)
    end
    --tex add all for location
    --ASSUMPTION: table, ASSUMPTION: has locationName
    for i,packPath in ipairs(this.packages[locationName])do
      table.insert(packPaths,packPath)
    end
    --tex currently just ih_enemyheli_loc DEBUGNOW rethink
    for i,packPath in ipairs(this.packages) do
      if type(packPath)=="string"then
        packPaths[#packPaths+1]=packPath
      end
    end
  end
  if Ivars.supportHeliPatrolsMB:EnabledForMission(missionCode) then
    for i,packPath in ipairs(this.packages.westheli)do
      packPaths[#packPaths+1]=packPath
    end
  end
end--AddMissionPacks

function this.Init(missionTable,currentChecks)
  this.messageExecTable=nil

  this.active=0

  if not IvarProc.EnabledForMission(attackHeliPatrolsStr) and not Ivars.supportHeliPatrolsMB:EnabledForMission() then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

  local isMb=vars.missionCode==30050
  local isOuterPlat=vars.missionCode==30150 or vars.missionCode==30250

  if isMb then
    this.active=1
  end

  this.heliList={}

  local numAttackHelis=IvarProc.GetForMission(attackHeliPatrolsStr)

  local level=InfMainTpp.GetAverageRevengeLevel()
  if numAttackHelis>#this.heliNames.EnemyHeli then--tex ENEMY_PREP
    local levelToHeli={0,1,2,3,4,4}--tex SYNC #this.heliNames.EnemyHeli
    numAttackHelis=levelToHeli[level+1]
  end
  InfCore.Log("InfNPCHeli.Init: AverageRevengeLevel:"..level.." numAttackHelis:"..numAttackHelis)--DEBUG

  if isOuterPlat then
    return
  elseif isMb then
    local numClusters=0
    for clusterId, clusterName in ipairs(TppDefine.CLUSTER_NAME) do--DEBUGNOW
      local grade=TppMotherBaseManagement.GetMbsClusterGrade{category=TppDefine.CLUSTER_NAME[clusterId]}
      if grade>0 then
        numClusters=numClusters+1
      end
    end
    --InfCore.Log("InfNPCHeli numClusters "..numClusters)--DEBUG
    local numSupportHelis=Ivars.supportHeliPatrolsMB:Get()
    numSupportHelis=math.min(numSupportHelis,numClusters)
    if numSupportHelis>0 then
      this.heliNames.UTH=InfUtil.GenerateNameList("WestHeli%04d",numSupportHelis)
      for i=1,numSupportHelis do
        this.heliList[#this.heliList+1]=this.heliNames.UTH[i]
      end
    end

    local numHelisAvailable=numClusters-#this.heliList
    numHelisAvailable=math.min(numAttackHelis,numHelisAvailable)
    if numHelisAvailable>0 then
      this.heliNames.EnemyHeli=InfUtil.GenerateNameList("EnemyHeli%04d",numHelisAvailable)

      for i=1,numHelisAvailable do
        this.heliList[#this.heliList+1]=this.heliNames.EnemyHeli[i]
      end
    end
  elseif numAttackHelis>0 then
    this.heliNames.EnemyHeli=InfUtil.GenerateNameList("EnemyHeli%04d",numAttackHelis)

    for i=1,numAttackHelis do
      this.heliList[#this.heliList+1]=this.heliNames.EnemyHeli[i]
    end
  end

  for n=1,#this.heliList do
    heliTimes[n]=0
    this.heliClusters[n]=0
  end

  --      local heliMeshTypes={
  --        "uth_v00",
  --        "uth_v01",
  --        "uth_v02",
  --      }
  --      local meshType=heliMeshTypes[math.random(#heliMeshTypes)]
  --      GameObject.SendCommand( heliObjectId, { id = "SetMeshType", typeName = meshType, } )

  InfMain.RandomSetToLevelSeed()

  local attackHeliType=IvarProc.GetSettingNameForMission("attackHeliType",vars.missionCode)
  local attackHeliFova=IvarProc.GetSettingNameForMission("attackHeliFova",vars.missionCode)

  local fovaId
  if attackHeliFova=="RANDOM" then
    fovaId=math.random(0,2)
  elseif attackHeliFova=="ENEMY_PREP" then
    --tex: cant use BLACK_SUPER_REINFORCE/SUPER_REINFORCE since it's not inited when I need it.
    --tex alt tuning for combined stealth/combat average, but I think I like heli color tied to combat better thematically,
    --sure have them put more helis out if stealth level is high (see numAttackHelis), but only put beefier helis if your actually causing a ruckus
    --local level=InfMainTpp.GetAverageRevengeLevel()
    --local levelToColor={0,0,1,1,2,2}--tex normally super reinforce(black,1) is combat 3,4, while super(red,2) is combat 5
    local level=TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)
    fovaId=levelToColor[level+1]
  elseif attackHeliFova=="RANDOM_EACH" then
  --tex set per heli below
  else
    fovaId=IvarProc.GetForMission("attackHeliFova",vars.missionCode)
  end
  InfCore.Log("InfNPCHeli.Init: attackHeliType:"..attackHeliType.." attackHeliFova:"..attackHeliFova.." fovaId:"..tostring(fovaId))--DEBUG

  for n=1,#this.heliList do
    local heliName=this.heliList[n]
    local heliObjectId = GetGameObjectId(heliName)
    if heliObjectId==NULL_ID then
    --InfCore.DebugPrint(heliName.."==NULL_ID")--DEBUG, will trigger in battlegear hangar since it's a different pack --DEBUG
    else
      local typeIndex=GetTypeIndex(heliObjectId)
      if typeIndex==TppGameObject.GAME_OBJECT_TYPE_ENEMY_HELI then
        if isMb and Ivars.mbEnemyHeli:Is(0) then
          SendCommand(heliObjectId,{id="SetEyeMode",mode="Close"})
          SendCommand(heliObjectId,{id="SetRestrictNotice",enabled=true})
          SendCommand(heliObjectId,{id="SetCombatEnabled",enabled=false})
          --TppMarker2System.DisableMarker{gameObjectId=heliObjectId}
        end

        if attackHeliFova=="RANDOM_EACH" then
          fovaId=math.random(0,2)
        end

        if fovaId~=nil then
          SendCommand(heliObjectId,{id="SetColoring",coloringType=fovaId,fova=this.heliFova[attackHeliType][fovaId]})--GOTCHA: I think coloringType may set the health of the heli
        end
      end--if GAME_OBJECT_TYPE_ENEMY_HELI
    end--if heliObject
  end--for heliList
  InfMain.RandomResetToOsTime()

  InfCore.PrintInspect(this.heliList,"InfNPCHeli.heliList")--DEBUG
end

function this.OnMissionCanStart(currentChecks)
  if not IvarProc.EnabledForMission(attackHeliPatrolsStr) and not Ivars.supportHeliPatrolsMB:EnabledForMission() then
    return
  end
  local isMb=vars.missionCode==30050
  if isMb then
    --tex done in mtbs_cluster.SetUpLandingZone
    return
  end

  --tex set up lz info
  local locationName=InfUtil.GetLocationName()
  this.enabledLzs=this.heliRoutes[locationName]
  routesBag=InfUtil.ShuffleBag:New(this.enabledLzs)

  if not gvars.sav_varRestoreForContinue then
    for heliIndex=1,#this.heliList do
      local heliName=this.heliList[heliIndex]
      local heliObjectId = GetGameObjectId(heliName)
      if heliObjectId==NULL_ID then
        InfCore.Log(heliName.."==NULL_ID")--DEBUGNOW
      else
        local heliRoute=routesBag:Next()
        InfCore.Log("InfNPCHeli.OnMissionCanStart: "..heliObjectId.." set to:"..heliRoute)--DEBUGNOW
        SendCommand(heliObjectId,{id="SetSneakRoute",route=heliRoute,point=1,warp=true})--DEBUGNOW
      end
    end
  end--if contine
end

function this.OnReload(missionTable)
  this.messageExecTable=nil

  this.active=0

  if not IvarProc.EnabledForMission(attackHeliPatrolsStr) and not Ivars.supportHeliPatrolsMB:EnabledForMission() then
    return
  end

  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

  if vars.missionCode==30050 then
    this.active=1
  end
end

function this.Messages()
  return Tpp.StrCode32Table{
    GameObject={
      {msg="RoutePoint2",func=this.OnRouteMessage},
      {msg="StartedPullingOut",func=function()
        --InfCore.DebugPrint("StartedPullingOut")--DEBUG
        --this.heliSelectClusterId=nil
        end},
    },
    Terminal={
      {msg="MbDvcActSelectLandPoint",func=function(nextMissionId,routeName,layoutCode,clusterId)
        --InfCore.DebugPrint("MbDvcActSelectLandPoint:"..tostring(InfLookup.str32LzToLz[routeName]).. " "..tostring(clusterId))--DEBUG
        this.heliSelectClusterId=clusterId
      end},
      {msg="MbDvcActSelectLandPointTaxi",func=function(nextMissionId,routeName,layoutCode,clusterId)
        --InfCore.DebugPrint("MbDvcActSelectLandPointTaxi:"..tostring(routeName).. " "..tostring(clusterId))--DEBUG
        this.heliSelectClusterId=clusterId
      end},
    },
  }
end

function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
  Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end

function this.Update(currentChecks,currentTime,execChecks,execState)
  --InfCore.PCall(function(currentChecks,currentTime,execChecks,execState)--DEBUG
  if not currentChecks.inGame then
    return
  end

  if this.active==0 then
    return
  end

  --tex TODO: this.active (set up on init/reload) instead
  if not IvarProc.EnabledForMission(attackHeliPatrolsStr) and not Ivars.supportHeliPatrolsMB:EnabledForMission() then
    return
  end

  if this.heliList==nil or #this.heliList==0 then
    --InfCore.DebugPrint"UpdateNPCHeli: helilist empty"--DEBUG
    return
  end

  --tex don't start til ready
  if this.enabledLzs==nil or #this.enabledLzs==0 then
    --InfCore.DebugPrint"enabledLzs empty"--DEBUG
    return
  end
  local isMb=vars.missionCode==30050

  if not isMb then
    this.active=0
    return
  end

  local isNight=IsNight()
  for heliIndex=1,#this.heliList do
    local heliName=this.heliList[heliIndex]
    local heliObjectId = GetGameObjectId(heliName)
    if heliObjectId==NULL_ID then
    --InfCore.DebugPrint(heliName.."==NULL_ID")--DEBUG
    else
      --tex choose new route
      if heliTimes[heliIndex]<currentTime then
        heliTimes[heliIndex]=currentTime+math.random(routeTimeMbMin,routeTimeMbMax)

        local heliRoute=this.UpdateHeliMB(heliObjectId,heliIndex,this.heliClusters)
        SendCommand(heliObjectId,{id="SetForceRoute",route=heliRoute})
        --SendCommand(heliObjectId,{id="SetForceRoute",route=heliRoute,point=0,warp=true})
        --SendCommand(heliObjectId,{id="SetLandingZnoeDoorFlag",name="heliRoute",leftDoor="Close",rightDoor="Close"})

        --InfCore.DebugPrint(n.." "..heliName.." route: "..tostring(InfLookup.str32LzToLz[heliRouteIds[n]]))--DEBUG
        -- is > heliTime--<
      end

      --not NULL_ID<
    end
    --for heliname<
  end
  --end,currentChecks,currentTime,execChecks,execState)--DEBUG
end


--IN-SIDE heliRouteIds
function this.UpdateHeliMB(heliObjectId,heliIndex,heliClusters)
  local prevCluster=heliClusters[heliIndex]--DEBUG
  local clusterId=this.ChooseRandomHeliCluster(heliClusters,heliTimes,this.heliSelectClusterId)
  heliClusters[heliIndex]=clusterId

  --        local clusterTime=heliTimes[n]-elapsedTime--DEBUG
  --        InfCore.DebugPrint(n.." "..heliName .. " from ".. tostring(TppDefine.CLUSTER_NAME[prevCluster]) .." to cluster ".. tostring(TppDefine.CLUSTER_NAME[clusterId]) .. " for "..clusterTime)--DEBUG
  this.SetHeliToClusterCp(heliObjectId,clusterId)


  local clusterLzs=this.enabledLzs[clusterId]
  if clusterLzs and #clusterLzs>0 then
    local currentLandingZoneName=clusterLzs[math.random(#clusterLzs)]
    local nextLandingZoneName=clusterLzs[math.random(#clusterLzs)]
    if currentLandingZoneName and nextLandingZoneName then--tex may be nil on demos
      local heliTaxiSettings=mtbs_helicopter.RequestHeliTaxi(heliObjectId,StrCode32(currentLandingZoneName),StrCode32(nextLandingZoneName))
      if heliTaxiSettings then
        local currentClusterRoute=heliTaxiSettings.currentClusterRoute
        local relayRoute=heliTaxiSettings.relayRoute
        local nextClusterRoute=heliTaxiSettings.nextClusterRoute

        return currentClusterRoute
      else
        InfCore.DebugPrint("Warning: UpdateNPCHeli - no heliTaxiSettings for".. currentLandingZoneName .." ".. nextLandingZoneName)
      end
    end
  end
end

function this.SetHeliToClusterCp(heliObjectId,clusterId)
  if mvars.mbSoldier_clusterParamList and mvars.mbSoldier_clusterParamList[clusterId] then
    local clusterParam=mvars.mbSoldier_clusterParamList[clusterId]
    local cpId=GetGameObjectId("TppCommandPost2",clusterParam.CP_NAME)
    if cpId==NULL_ID then
      InfCore.Log("cpId "..clusterParam.CP_NAME.."==NULL_ID ")
    else
      SendCommand(heliObjectId,{id="SetCommandPost",cp=clusterParam.CP_NAME})
    end
  end
end

local msg_heli_patrol_route_endStr="msg_heli_patrol_route_end"
local msg_heli_patrol_route_endS32=StrCode32(msg_heli_patrol_route_endStr)
--msg RoutePoint2
this.OnRouteMessage=function(gameObjectId,routeId,routeNodeIndexOrParam,message)
  if message~=msg_heli_patrol_route_endS32 then
    return
  end

  local heliRoute=routesBag:Next()
  InfCore.Log("InfNPCHeli.OnRouteMessage: msg_heli_patrol_route_end - "..gameObjectId.." changing to:"..heliRoute)--DEBUGNOW
  --heliRoute=StrCode32(heliRoute)

  if heliRoute then
    SendCommand(gameObjectId,{id="SetSneakRoute",route=heliRoute})
  end
end

--DEBUG
function this.ClearHeliState()
  for n=1,#this.heliList do
    heliTimes[n]=0
    --heliClusters[n]=0
  end
end

function this.ChooseRandomHeliCluster(heliClusters,heliTimes,supportHeliClusterId)
  local cohabitTimeLimit=60
  local blockClusters={}
  for n,heliCluster in ipairs(heliClusters)do
    if heliTimes[n]-Time.GetRawElapsedTimeSinceStartUp() > cohabitTimeLimit then
      blockClusters[heliCluster]=true
    end
  end

  if supportHeliClusterId then
  --OFF blockClusters[supportHeliClusterId]=true--tex TODO need to find an accurate way to get the cluster, or lz of a called in heli
  end

  local clusterPool={}

  for clusterId, clusterName in ipairs(TppDefine.CLUSTER_NAME) do
    local grade=TppMotherBaseManagement.GetMbsClusterGrade{category=TppDefine.CLUSTER_NAME[clusterId]}
    if grade>0 and not blockClusters[clusterId] then
      clusterPool[#clusterPool+1]=clusterId
    end
  end

  --tex no sure why this is happening, in invasion at least, maybe a bunch of helis stacking up on same cluster
  --so try again without block
  if #clusterPool==0 then
    --InfCore.DebugPrint"#clusterPool==0"--DEBUG
    for clusterId, clusterName in ipairs(TppDefine.CLUSTER_NAME) do
      local grade=TppMotherBaseManagement.GetMbsClusterGrade{category=TppDefine.CLUSTER_NAME[clusterId]}
      if grade>0 then
        clusterPool[#clusterPool+1]=clusterId
      end
    end
  end

  if #clusterPool==0 then
    --InfCore.DebugPrint"#clusterPool==0"--DEBUG
    return nil
  end

  return clusterPool[math.random(#clusterPool)]
end

--DEBUG
function this.ClearRoute(heliIndex)
  local route=nil

  local heliName=this.heliList[heliIndex]
  local heliObjectId = GetGameObjectId(heliName)
  if heliObjectId==NULL_ID then
  --InfCore.DebugPrint(heliName.."==NULL_ID")--DEBUG
  else
    --SendCommand(heliObjectId,{id="SetForceRoute",route=route})--DEBUG
    SendCommand(heliObjectId,{id="SetSneakRoute",route=route})
    SendCommand(heliObjectId,{id="SetCautionRoute",route=route})
    SendCommand(heliObjectId,{id="SetAlertRoute",route=route})
    InfCore.DebugPrint(heliIndex.." "..heliName.." clearroute")--DEBUG
  end
end

return this

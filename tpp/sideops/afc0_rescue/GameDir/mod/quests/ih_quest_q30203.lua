local this = {
    questPackList = {
        "/Assets/tpp/pack/mission2/ih/ih_hostage_base.fpk", 
        "/Assets/tpp/pack/mission2/ih/prs6_main0_mdl.fpk", 
        "/Assets/tpp/pack/mission2/common/mis_com_walkergear.fpk", 
        "/Assets/tpp/pack/mission2/quest/ih/afc0_rescue_1.fpk", 
        randomFaceListIH = { gender = "FEMALE", count = 4},
    },
    locationId = TppDefine.LOCATION_ID.AFC0,
    areaName = "afc0",
    iconPos = Vector3(23.9,11.93,12.9),
    radius = 5,
    category = TppQuest.QUEST_CATEGORIES_ENUM.PRISONER,
    questCompleteLangId = "quest_extract_hostage",
    canOpenQuest=InfQuest.AllwaysOpenQuest,
    questRank = TppDefine.QUEST_RANK.E,
    disableLzs = {},
    requestEquipIds = {},
} return this
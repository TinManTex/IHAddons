local this = {
    questPackList = {
        "/Assets/tpp/pack/mission2/ih/ih_hostage_base.fpk", 
        "/Assets/tpp/pack/mission2/ih/prs3_main0_mdl.fpk", 
        "/Assets/tpp/pack/mission2/quest/ih/afn0_rescue_1.fpk", 
        randomFaceListIH = { gender = "FEMALE", count = 4},
    },
    locationId = TppDefine.LOCATION_ID.AFN0,
    areaName = "afn0",
    iconPos = Vector3(110,10,32),
    radius = 5,
    category = TppQuest.QUEST_CATEGORIES_ENUM.PRISONER,
    questCompleteLangId = "quest_extract_hostage",
    canOpenQuest=InfQuest.AllwaysOpenQuest,
    questRank = TppDefine.QUEST_RANK.E,
    disableLzs = {},
    requestEquipIds = {},
} return this
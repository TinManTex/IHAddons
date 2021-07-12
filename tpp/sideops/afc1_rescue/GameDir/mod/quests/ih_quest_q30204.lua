local this = {
    questPackList = {
        "/Assets/tpp/pack/mission2/ih/ih_hostage_base.fpk", 
        "/Assets/tpp/pack/mission2/ih/prs6_main0_mdl.fpk", 
        "/Assets/tpp/pack/mission2/quest/ih/afc1_rescue_1.fpk", 
        randomFaceListIH = { gender = "FEMALE", count = 4},
    },
    locationId = 104,
    areaName = "afc1",
    iconPos = Vector3(5,3.6,10),
    radius = 4,
    category = TppQuest.QUEST_CATEGORIES_ENUM.PRISONER,
    questCompleteLangId = "quest_extract_hostage",
    canOpenQuest=InfQuest.AllwaysOpenQuest,
    questRank = TppDefine.QUEST_RANK.E,
    disableLzs = {},
    requestEquipIds = {},
} return this
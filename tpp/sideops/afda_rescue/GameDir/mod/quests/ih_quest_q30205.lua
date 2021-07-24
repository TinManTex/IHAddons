local this = {
    questPackList = {
        "/Assets/tpp/pack/mission2/ih/ih_hostage_base.fpk", 
        "/Assets/tpp/pack/mission2/ih/prs3_main0_mdl.fpk", 
        "/Assets/tpp/pack/mission2/quest/ih/afda_rescue_1.fpk", 
        randomFaceListIH = { gender = "FEMALE", count = 4},
    },
    locationId = 103,
    areaName = "afda",
    iconPos = Vector3(-8,20,27),
    radius = 4,
    category = TppQuest.QUEST_CATEGORIES_ENUM.PRISONER,
    questCompleteLangId = "quest_extract_hostage",
    canOpenQuest=InfQuest.AllwaysOpenQuest,
    questRank = TppDefine.QUEST_RANK.E,
    disableLzs = {},
    requestEquipIds = {},
} return this
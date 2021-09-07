local this={
    questId=30211,
    questPackList={
        "/Assets/tpp/pack/mission2/quest/void/quest_q30211_shootingpractice.fpk",
    },
    locationId=TppDefine.LOCATION_ID.VOID,
    areaName="void",
    iconPos=Vector3(0,0,0),--position of the quest area circle in idroid
    radius=4,--radius of the quest area circle
    category=TppQuest.QUEST_CATEGORIES_ENUM.TARGET_PRACTICE,
    questCompleteLangId="quest_target_eliminate",
    canOpenQuest=InfQuest.AllwaysOpenQuest,
    questRank=TppDefine.QUEST_RANK.I,
    --shooting practice quests need a marker and geotrap to start the quest which needs to be resident
    missionPacks={
        "/Assets/tpp/pack/mission2/quest/void/quest_q30211_void_shootingpractice_start.fpk",
    },--missionPacks
    startTrapName="ly003_cl04_npc0000|cl04pl2_q30210|trap_shootingPractice_start",--entity name, in layout fpkd fox2
    startMarkerName="ly003_cl04_npc0000|cl04pl2_q30210|Marker_shootingPractice",--entity name, in layout fpkd fox2
}
return this
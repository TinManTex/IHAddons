local n={}
local e=Fox.StrCode32
local e=Tpp.StrCode32Table
function n.CreateInstance(e)
local e={}
e.radioList={}
e.debugRadioLineTable={Seq_Game_Ready={"AI???????????????????????????????????????????????????"},Seq_Game_Stealth={"AI??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????","AI??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????","AI?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????","AI???????????????????????????????????????????????????????????????????????????????????????????????????????????????"},Seq_Game_DefenseWave={"AI??????????????????????????????????????????????????????????????????","AI?????????????????????????????????????????????????????????????????????????????????????????????"},Seq_Game_DefenseBreak={"AI??????????????????????????????????????????????????????????????????","AI??????????????????????????????????????????????????????????????????????????????????????????","AI????????????????????????Wave????????????????????????????????????","AI????????????Wave???????????????????????????????????????????????????????????????????????????"},Seq_Game_Escape={"AI???????????????????????????????????????????????????????????????????????????","AI?????????????????????????????????????????????","AI?????????????????????????????????????????????"},expandTimeLimit={"AI???????????????????????????????????????????????????","AI????????????????????????????????????????????????????????????????????????????????????"},mineTrap={"AI?????????????????????????????????????????????????????????????????????","AI??????????????????????????????"},bossSmell={"AI??????????????????????????????????????????????????????????????????","AI???????????????????????????????????????????????????????????????????????????????????????","AI??????????????????????????????????????????????????????????????????????????????","AI???????????????????????????????????????????????????????????????????????????","AI??????????????????????????????????????????????????????????????????????????????????????????"},bossDefeated={"AI??????????????????????????????????????????????????????????????????","AI??????????????????????????????????????????????????????????????????","AI?????????????????????????????????????????????"},treasureBoxBroken={"AI???????????????????????????????????????????????????????????????","AI?????????????????????????????????????????????","AI?????????????????????????????????????????????"},miningMachineBroken={"AI???????????????????????????????????????????????????????????????","AI?????????????????????????????????????????????","AI?????????????????????????????????????????????"},timeUp={"AI????????????????????????????????????????????????????????????????????????????????????????????????","AI?????????????????????????????????????????????","AI?????????????????????????????????????????????"},baseTrap={"AI?????????????????????????????????????????????????????????","AI?????????????????????????????????????????????????????????????????????????????????????????????????????????","AI????????????????????????????????????????????????????????????????????????"},votingResultEscape={"AI????????????????????????????????????","AI??????????????????????????????????????????"}}
function e.OnSequenceStarted()
local n=TppSequence.GetCurrentSequenceName()
if e.debugRadioLineTable[n]then
end
end
function e.OnGimmickBroken()
end
function e.OnEnemyEnteredMineTrap()
end
function e.OnBossSmell()
end
function e.OnBossDefeated()
end
function e.OnTreasureBoxBroken()
end
function e.OnTimeUp()
end
function e.OnMiningMachineBroken()
end
function e.OnBaseTrap()
end
function e.OnVotingResultEscape()
end
return e
end
return n
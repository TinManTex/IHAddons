characterLookup={"A","B","C","D","E","F","G","H"}
function GetWidget(o)
local e=""..o
local _=""..(o+1)
local t="id_customize_chr_record000"..(e..".UI_ID_Customize_Chr_record")
local a=""..(250+(20*o))
local t={type="MgoUiMenuEntry",name="menu_character_select_entry_".._,states={{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout=t..".UI_ID_C_Chr_FocusOut"},{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout=t..".UI_ID_C_Chr_Normal"},{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout=t..".UI_ID_C_Chr_On"},{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout=t..".UI_ID_C_Chr_UnLink"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="play",layout=t..".UI_ID_C_Chr_On"},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="enter",control="play",layout=t..".UI_ID_C_Chr_Focus"},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="enter",control="stop",layout=t..".UI_ID_C_Chr_FocusOut"},{type="MgoUiAnimationStateSwitch",name="stateIdle",mode="enter",control="play",layout=t..".UI_ID_C_Chr_FocusOut"},{type="MgoUiAnimationStateSwitch",name="stateIdle",mode="enter",control="stop",layout=t..".UI_ID_C_Chr_Focus"},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="enter",control="play",layout=t..".UI_ID_C_Chr_Current"},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="exit",control="play",layout=t..".UI_ID_C_Chr_Normal"},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="enter",control="play",loop="true",layout=t..".UI_ID_C_Chr_Noise"},{type="MgoUiAnimationStateSwitch",name="stateIdle",mode="enter",control="stop",layout=t..".UI_ID_C_Chr_Noise"},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="exit",control="stop",layout=t..".UI_ID_C_Chr_Noise"}},widgets={{type="MgoUiLabel",name="label_char_index_letter_".._,layout=t..".UI_ID_Customize_SlotNum_txt",default=characterLookup[o+1]},{type="MgoUiLabel",name="label_char_select_name_".._,source="mgo_idroid_character_edit_name",index=e,layout=t..".UI_ID_Customize_Character_L_txt",default="name_".._,pos={x="180",y=a,w="80",h="20"},scroll="true"},{type="MgoUiLabel",name="label_char_select_locked_".._,source="mgo_idroid_character_edit_name",index=e,layout=t..".UI_ID_C_Chr_LOCKED_txt",default="name_".._,pos={x="180",y=a,w="80",h="20"}},{type="MgoUiAnimation",name="anim_char_edit_".._,source="mgo_idroid_character_edit_class",index=e,layout="",options={{key="_rec_",layout=t..".UI_ID_C_Chr_REC"},{key="_inf_",layout=t..".UI_ID_C_Chr_INF"},{key="_tec_",layout=t..".UI_ID_C_Chr_TEC"},{key="_new_",layout=t..".UI_ID_C_Chr_Add"},{key="",layout=t..".UI_ID_C_Chr_Class_Off"}}},{type="MgoUiAnimation",name="anim_char_edit_prestige_"..(_.."_lvl"),source="mgo_idroid_character_edit_prestige",index=e,layout="",options={{key="",layout=t..".UI_ID_C_Chr_Rank_1"},{key="_1_",layout=t..".UI_ID_C_Chr_Rank_2"},{key="_2_",layout=t..".UI_ID_C_Chr_Rank_3"},{key="_3_",layout=t..".UI_ID_C_Chr_Rank_4"}}},{type="MgoUiAnimation",name="anim_char_select_modifier_".._,source="mgo_idroid_character_edit_ctrl",index=e,layout="",options={{key="_char_",layout=t..".UI_ID_C_Chr_UnLock"},{key="_new_",layout=t..".UI_ID_C_Chr_Add"},{key="_lock_",layout=t..".UI_ID_C_Chr_Lock"},{key="_coin_lock_",layout=t..".UI_ID_C_Chr_Lock_mb"},{key="_$_",layout=t..".UI_ID_C_Chr_Dollar"},{key="_on_",layout=t..".UI_ID_C_Chr_On"},{key="_half_",layout=t..".UI_ID_C_Chr_On_half"},{key="_off_",layout=t..".UI_ID_C_Chr_Off"}}},{type="MgoUiLabel",name="label_char_select_level_".._,source="mgo_idroid_character_edit_level",index=e,layout=t..".UI_ID_Customize_Character_Lvl_txt",default="c_lvl_".._,pos={x="520",y=a,w="80",h="20"}}}}
return t
end
CharacterModCharacterSelect={widgets={{type="MgoUiMenu",name="menu_character_select",states={{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_Hide"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="stop",layout="id_customize_chr_record0000.UI_ID_Customize_Chr_record.UI_ID_C_Chr_UnLink"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="play",layout="id_customize_chr_record0000.UI_ID_Customize_Chr_record.UI_ID_C_Chr_Link"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_Show"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="stop",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_Hide"},{type="MgoUiAnimationStateSwitch",name="stateHide",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_Hide"},{type="MgoUiAnimationStateSwitch",name="stateHide",mode="enter",control="stop",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_Show"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_ChrDesc_On"},{type="MgoUiAnimationStateSwitch",name="stateHide",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_ChrDesc_Off"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_Bracket_On"},{type="MgoUiAnimationStateSwitch",name="stateHide",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_Bracket_Off"},{type="MgoUiAnimationStateSwitch",name="stateHide",mode="enter",control="play",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_LND_Off"}},widgets={GetWidget(0),GetWidget(1),GetWidget(2),GetWidget(3),GetWidget(4),GetWidget(5),GetWidget(6),GetWidget(7)}},{type="MgoUiLabel",name="label_character_desc",source="mgo_idroid_char_desc",layout="UI_ID_Customize_PT1_layout.UI_Customize_Chr_Desc_txt",shadow="UI_ID_Customize_PT1_layout.UI_Customize_Chr_Desc_sdw_txt",textUnitCount=7},{type="MgoUiLabel",name="label_char_locked",source="mgo_idroid_current_3d_txt",langTag="mgo_ui_idt_locked",layout="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_LOCKED_txt",shadow="UI_ID_Customize_PT1_layout.UI_ID_C_PT1_Chr_LOCKED_sdw_txt"},{type="MgoUiAnimation",name="anim_char_3d",source="mgo_idroid_current_3d",index=strNum,layout="",options={{key="_char_",layout="UI_ID_Customize_PT1_layout"..".UI_ID_C_PT1_LND_Off"},{key="_new_",layout="UI_ID_Customize_PT1_layout"..".UI_ID_C_PT1_NONE"},{key="_lock_",layout="UI_ID_Customize_PT1_layout"..".UI_ID_C_PT1_LOCKED"},{key="_$_",layout="UI_ID_Customize_PT1_layout"..".UI_ID_C_PT1_DOLLAR"}}}}}

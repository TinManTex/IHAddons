function GetAvailableItemWidget(e,o)
local t=""..e
local _=""..(e+1)
local e="id_customize_gearOV_record000"..(t..".UI_ID_C_GearOV_record.")
local e={type="MgoUiMenuEntry",name="menu_entry_gear_overview_".._,states={{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout=e.."UI_ID_C_GearOV_FocusOut"},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="enter",control="play",layout=e.."UI_ID_C_GearOV_FocusIn"},{type="MgoUiAnimationStateSwitch",name="stateIdle",mode="enter",control="play",layout=e.."UI_ID_C_GearOV_FocusOut"},{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout=e..("."..o)},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="play",layout=e..("."..o)},{type="MgoUiAnimationStateSwitch",name="stateHot",mode="enter",control="play",loop="true",layout=e.."UI_ID_GearOV_Cursor_Noise"}},widgets={{type="MgoUiLabel",name="label_gear_overview_".._,source="mgo_idroid_gear_overview_name",sourceValue="mgo_idroid_gear_overview_desc",index=t,layout=e.."UI_ID_C_GearOV_txt",scroll="true",default=""},{type="MgoUiLabel",name="label_gear_overview_sdw_".._,source="mgo_idroid_gear_overview_name",index=t,layout=e.."UI_ID_C_GearOV_sdw_txt",scroll="true",default=""},{type="MgoUiImage",name="image_gear_overview_".._,source="mgo_idroid_gear_overview_texture",index=t,layout=e.."UI_ID_C_GearOV_Icon",default="Icon"},{type="MgoUiImage",name="image_gear_overview_ref_".._,source="mgo_idroid_gear_overview_texture",index=t,layout=e.."UI_ID_C_GearOV_Icon_ref",default="Icon"},{type="MgoUiAnimation",name="anim_gear_overview_"..(_.."_enable"),source="mgo_idroid_gear_overview_anim_enable",index=t,layout="",options={{key="_on_",layout=e.."UI_ID_C_GearOV_Full"},{key="_off_",layout=e.."UI_ID_C_GearOV_Dim"}}},{type="MgoUiAnimation",name="anim_gear_overview_"..(_.."_ctrl"),source="mgo_idroid_gear_overview_anim_ctrl",index=t,layout="",options={{key="_on_",layout=e.."UI_ID_C_GearOV_Gear"},{key="_off_",layout=e.."UI_ID_C_GearOV_None"}}},{type="MgoUiAnimation",name="anim_gear_overview_"..(_.."_new"),source="mgo_idroid_gear_overview_anim_new",index=t,layout="",options={{key="_on_",layout=e.."UI_ID_C_GearOV_NEW_On"},{key="_off_",layout=e.."UI_ID_C_GearOV_NEW_Off"}}}}}
return e
end
CharacterModGearOverview={widgets={{type="MgoUiMenu",name="menu_gear_overview",states={{type="MgoUiAnimationStateSwitch",name="stateInit",mode="enter",control="play",layout="UI_ID_Customize_PT3_layout.UI_ID_C_PT3_WepParams_Hide"},{type="MgoUiAnimationStateSwitch",name="stateShow",mode="enter",control="play",layout="UI_ID_Customize_PT3_layout.UI_ID_C_PT3_GearOV_Loc_Setin"},{type="MgoUiAnimationStateSwitch",name="stateHide",mode="enter",control="play",layout="UI_ID_Customize_PT3_layout.UI_ID_C_PT3_GearOV_Loc_Setout"}},widgets={{type="MgoUiLabel",name="label_gear_overview_desc",source="",layout="UI_ID_Customize_PT3_layout.UI_C_GearOV_Desc_txt",textUnitCount=12,default=""},{type="MgoUiLabel",name="label_gear_overview_desc_sdw",source="",layout="UI_ID_Customize_PT3_layout.UI_C_GearOV_Desc_sdw_txt",textUnitCount=12,default=""},GetAvailableItemWidget(0,"UI_ID_C_GearOV_HG"),GetAvailableItemWidget(1,"UI_ID_C_GearOV_VE"),GetAvailableItemWidget(2,"UI_ID_C_GearOV_SU"),GetAvailableItemWidget(3,"UI_ID_C_GearOV_ACC")}}}}
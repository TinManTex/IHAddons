local this={
--NMC: maps a friendly id (in this case something close to the fv2 name) to an enum. in Soldier2FacaAndBodyData the enum is then mapped(via bodyFova table)to the actual fv2 path and fpk (bodyFile table > 
--SOVIET see TppEnemy.bodyIdTable
svs0_rfl_v00_a=0,
svs0_rfl_v01_a=1,
svs0_rfl_v02_a=2,
svs0_mcg_v00_a=5,
svs0_mcg_v01_a=6,
svs0_mcg_v02_a=7,
svs0_snp_v00_a=10,
svs0_rdo_v00_a=11,
svs0_rfl_v00_b=20,
svs0_rfl_v01_b=21,
svs0_rfl_v02_b=22,
svs0_mcg_v00_b=25,
svs0_mcg_v01_b=26,
svs0_mcg_v02_b=27,
svs0_snp_v00_b=30,
svs0_rdo_v00_b=31,
sva0_v00_a=49,--armor
--PF see TppEnemy.bodyIdTable
pfs0_rfl_v00_a=50,
pfs0_rfl_v01_a=51,
pfs0_mcg_v00_a=55,
pfs0_snp_v00_a=60,
pfs0_rdo_v00_a=61,
pfs0_rfl_v00_b=70,
pfs0_rfl_v01_b=71,
pfs0_mcg_v00_b=75,
pfs0_snp_v00_b=80,
pfs0_rdo_v00_b=81,
pfs0_rfl_v00_c=90,
pfs0_rfl_v01_c=91,
pfs0_mcg_v00_c=95,
pfs0_snp_v00_c=100,
pfs0_rdo_v00_c=101,
--pf armor
pfa0_v00_b=107,
pfa0_v00_c=108,
pfa0_v00_a=109,
--prisonors
prs2_main0_v00=110,--AFGH_HOSTAGE_MALE--Q19013--commFacility_q19013,Q99070--sovietBase_q99070,Q99072--tent_q99072
prs5_main0_v00=111,--MAFR_HOSTAGE_MALE--Q19012--hill_q19012
prs3_main0_v00=112,--AFGH_HOSTAGE_FEMALE
prs6_main0_v00=113,--MAFR_HOSTAGE_FEMALE
--children
chd0_v00=115,
chd0_v01=116,
chd0_v02=117,
chd0_v03=118,
chd0_v04=119,
chd0_v05=120,
chd0_v06=121,
chd0_v07=122,
chd0_v08=123,
chd0_v09=124,
chd0_v10=125,
chd0_v11=126,
chd1_v00=130,
chd1_v01=131,
chd1_v02=132,
chd1_v03=133,
chd1_v04=134,
chd1_v05=135,

dds0_main1_v00=140,--DD_PW--10115--bodyIdTable ASSAULT
dds0_main1_v01=141,--DD_PW--10115
dds3_main0_v00=142,--DD_A default/drab
dds5_main0_v00=143,--DD_FOB Tiger
dds5_main0_v01=144,--unused?
dds5_main0_v02=145,--unused?

ddr0_main0_v00=146,
ddr0_main0_v01=147,
ddr0_main0_v02=148,
ddr0_main1_v00=149,
ddr0_main1_v01=150,
ddr0_main1_v02=151,
ddr0_main1_v03=152,
ddr0_main1_v04=153,
ddr1_main0_v00=154,
ddr1_main0_v01=155,
ddr1_main0_v02=156,
ddr1_main1_v00=157,
ddr1_main1_v01=158,
ddr1_main1_v02=159,
dds3_main0_v01=160,
dds5_main0_v03=161,
dds6_main0_v00=162,
dds6_main0_v01=163,
dds8_main0_v00=164,
dds8_main0_v01=165,
ddr0_main0_v03=166,
ddr0_main0_v04=167,
ddr0_main1_v05=168,
ddr0_main1_v06=169,
dds3_main0_v02=170,
dds8_main0_v02=171,
dds4_enem0_def=172,
dds4_enef0_def=173,
dds5_enem0_def=174,
dds5_enef0_def=175,
dds5_main0_v04=176,
dla0_plym0_def=177,
dla1_plym0_def=178,
dlb0_plym0_def=179,
dlc0_plyf0_def=180,
dlc1_plyf0_def=181,
dld0_plym0_def=182,
dle0_plyf0_def=183,
dle1_plyf0_def=184,
wss4_main0_v00=190,
wss4_main0_v01=191,
wss4_main0_v02=192,
wss0_main0_v00=195,
wss3_main0_v00=196,
prs2_main0_v01=200,
prs5_main0_v01=201,
prs3_main0_v01=202,
prs6_main0_v01=203,
--children
chd2_v00=205,--Q20913--outland_q20913
chd2_v01=206,--Q20914--lab_q20914
chd2_v02=207,--Q20910--tent_q20910
chd2_v03=208,--Q20911--fort_q20911
chd2_v04=209,--Q20912--sovietBase_q20912
--unique bodies
pfs0_unq_v210=250,--black beret, glases, black vest, red shirt, tan pants
pfs0_unq_v250=251,--black beret, white coyote tshirt, black pants
pfs0_unq_v360=253,--red long sleeve shirt, black pants
pfs0_unq_v280=254,--black suit, white shirt, red white striped tie
pfs0_unq_v150=255,--green beret, brown leather top, light tan muddy pants--Q19011--outland_q19011
pfs0_unq_v220=256,--mafr tan shorts, looks normal, maybe the shoulder rank decorations?
svs0_unq_v010=257,--red beret
svs0_unq_v080=258,--digital camo, seems like it would be in the normal soviet body selection, dont know.
svs0_unq_v020=259,--green beret, brown coat--Q19010--ruins_q19010
svs0_unq_v040=260,--urban camo radio
svs0_unq_v050=261,--urban camo, cap
svs0_unq_v060=262,--black hoodie, green vest, urban pants
svs0_unq_v100=263,--tan/brown hoodie, brown pants
pfs0_unq_v140=264,--cap, glases, badly clipping medal, brown leather top, light tan muddy pants--Q99071--outland_q99071
pfs0_unq_v241=265,--brown leather top, light tan muddy pants
pfs0_unq_v242=266,--brown leather top, light tan muddy pants, cant tell any difference?
pfs0_unq_v450=267,--red beret, brown leather top, light tan muddy pants
svs0_unq_v070=268,--red beret, green vest, tan top, pants
svs0_unq_v071=269,--red beret, woodland camo
svs0_unq_v072=270,--red beret, glases, urban, so no headgear
svs0_unq_v420=271,--dark brown hoodie
pfs0_unq_v440=272,--red beret, black leather top, black pants--10093 vip
svs0_unq_v009=273,--red beret, green vest, grey top, pants
svs0_unq_v421=274,--wood camo
pfs0_unq_v155=275,--red beret cfa light tank shortpants
--lost msf soldiers mafr
pfs0_dds0_v00=280,--MSF_01--q80060
pfs0_dds0_v01=281,--MSF_02--q80020
pfs0_dds0_v02=282,
pfs0_dds0_v03=283,
pfs0_dds0_v04=284,
pfs0_dds0_v05=285,
pfs0_dds0_v06=286,--MSF_07--q80010
pfs0_dds0_v07=287,
pfs0_dds0_v08=288,--MSF_09--q80080
pfs0_dds0_v09=289,--MSF_10--q80040
--lost msf soldiers afgh
svs0_dds0_v00=290,
svs0_dds0_v01=291,
svs0_dds0_v02=292,--MSF_03--q80100
svs0_dds0_v03=293,--MSF_04--q80200
svs0_dds0_v04=294,--MSF_05--q80600
svs0_dds0_v05=295,--MSF_06--q80400
svs0_dds0_v06=296,
svs0_dds0_v07=297,--MSF_08--q80700
svs0_dds0_v08=298,
svs0_dds0_v09=299,
--cyprus hospital patients
ptn0_v00=300,
ptn0_v01=301,
ptn0_v02=302,
ptn0_v03=303,
ptn0_v04=304,
ptn0_v05=305,
ptn0_v06=306,
ptn0_v07=307,
ptn0_v08=308,
ptn0_v09=309,
ptn0_v10=310,
ptn0_v11=311,
ptn0_v12=312,
ptn0_v13=313,
ptn0_v14=314,
ptn0_v15=315,
ptn0_v16=316,
ptn0_v17=317,
ptn0_v18=318,
ptn0_v19=319,
ptn0_v20=320,
ptn0_v21=321,
ptn0_v22=322,
ptn0_v23=323,
ptn0_v24=324,
ptn0_v25=325,
ptn0_v26=326,
ptn0_v27=327,
ptn0_v28=328,
ptn0_v29=329,
ptn0_v30=330,
ptn0_v31=331,
ptn0_v32=332,
ptn0_v33=333,
ptn0_v34=334,
ptn1_v00=335,
ptn2_v00=336,
--cyprus hospital nurses
nrs0_v00=340,
nrs0_v01=341,
nrs0_v02=342,
nrs0_v03=343,
nrs0_v04=344,
nrs0_v05=345,
nrs0_v06=346,
nrs0_v07=347,
--cyprus hospital doc
dct0_v00=348,
dct0_v01=349,

plh0_v00=350,
plh0_v01=351,
plh0_v02=352,
plh0_v03=353,
plh0_v04=354,
plh0_v05=355,
plh0_v06=356,
plh0_v07=357,
--ocellot
oce0_main0_v00=370,--normal
oce0_main0_v01=371,--glasses
oce0_main0_v02=372,--??

prs7_main0_v00=373,--Q99080_01--not in questPackList.bodyIdList??
prs7_main0_v01=374,--Q99080_02--cliffTown_q99080

wsp_def=375,
wsp_dam=376,
--huey
hyu0_main0_v00=377,
hyu0_main0_v01=378,
hyu0_main0_v02=379,
--ishmael
ish0_v00=380,
ish0_v01=381
}
return this

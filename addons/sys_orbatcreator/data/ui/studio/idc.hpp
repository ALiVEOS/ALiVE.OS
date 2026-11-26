// ORBAT Creator studio: every IDD and IDC of the studio displays.
// Defines only, no classes: also included by every studio/ function.
// 14500-14699 are left free for later tabs; only IDCs that exist are listed.
// Author: Jman

// ---------------------------------------------------------------- displays
#define FS_IDD_STUDIO               14000
#define FS_IDD_BROWSER              14800
#define FS_IDD_PICKER               14820
#define FS_IDD_CARGO                14830
#define FS_IDD_TEXTBOX              14850
#define FS_IDD_PROMPT               14870
#define FS_IDD_HELP                 14890
#define FS_IDD_POOLS                14910

// ---------------------------------------------------------------- frame
#define FS_IDC_PANEL                14001
#define FS_IDC_TITLE                14002
#define FS_IDC_FACTION              14003
#define FS_IDC_STATUS               14005
#define FS_IDC_EXIT                 14006
#define FS_IDC_HELP                 14007
#define FS_IDC_MOUSE                14008
#define FS_IDC_CAPTION              14009
#define FS_IDC_TAB_FACTION          14010
#define FS_IDC_TAB_UNITS            14011
#define FS_IDC_TAB_VEHICLES         14012
#define FS_IDC_TAB_GROUPS           14013
#define FS_IDC_TAB_EXPORT           14014
#define FS_IDC_LOGO                 14015
#define FS_IDC_TAB_ALIVE            14016

// tab groups
#define FS_IDC_GRP_FACTION          14100
#define FS_IDC_GRP_UNITS            14200
#define FS_IDC_GRP_VEHICLES         14300
#define FS_IDC_GRP_GROUPS           14400
#define FS_IDC_GRP_ALIVE            14500
#define FS_IDC_GRP_EXPORT           14700

// ---------------------------------------------------------------- Faction tab
#define FS_IDC_F_NAME               14101
#define FS_IDC_F_TAG                14102
#define FS_IDC_F_CLASS              14103
#define FS_IDC_F_SIDE               14104
#define FS_IDC_F_FLAG               14105
#define FS_IDC_F_FLAGPATH           14106
#define FS_IDC_F_AUTHOR             14107
#define FS_IDC_F_MODNAME            14108
#define FS_IDC_F_LIBLIST            14120
#define FS_IDC_F_LIBSAVE            14121
#define FS_IDC_F_LIBLOAD            14122
#define FS_IDC_F_LIBDELETE          14123
#define FS_IDC_F_NEW                14124
#define FS_IDC_F_RESTORE            14125
#define FS_IDC_F_IMPORT             14130
#define FS_IDC_F_COPY               14131
#define FS_IDC_F_PASTE              14132
#define FS_IDC_F_FILELOAD           14133
#define FS_IDC_F_FILENAME           14134
#define FS_IDC_F_COUNTS             14140

// ---------------------------------------------------------------- Units tab
#define FS_IDC_U_LIST               14201
#define FS_IDC_U_ADD                14202
#define FS_IDC_U_DUPLICATE          14203
#define FS_IDC_U_DELETE             14204
#define FS_IDC_U_UP                 14205
#define FS_IDC_U_DOWN               14206
#define FS_IDC_U_NAME               14210
#define FS_IDC_U_CLASS              14211
#define FS_IDC_U_CLASSAUTO          14212
#define FS_IDC_U_BASE               14213
#define FS_IDC_U_BASECHANGE         14214
#define FS_IDC_U_CATEGORY           14215
#define FS_IDC_U_LOADOUT            14216
#define FS_IDC_U_UNDO               14217
#define FS_IDC_U_ARSENAL            14218
#define FS_IDC_U_FIXED              14219
#define FS_IDC_U_IDENTITY           14220
#define FS_IDC_U_SUMMARY            14221
#define FS_IDC_U_POOLSLABEL         14222
#define FS_IDC_U_POOLS              14223
#define FS_IDC_U_POOLSEDIT          14224
#define FS_IDC_U_ROLL               14225
#define FS_IDC_U_UNROLL             14226
#define FS_IDC_U_SPECOPS            14227
#define FS_IDC_U_ROLE               14228
#define FS_IDC_U_ROLELABEL          14229
#define FS_IDC_U_SPECOPSLABEL       14230
#define FS_IDC_U_OPTIONAL           14231
#define FS_IDC_U_OPTIONALLABEL      14232
#define FS_IDC_U_ENGINEER           14233
#define FS_IDC_U_ENGINEERLABEL      14234
#define FS_IDC_U_EOD                14235
#define FS_IDC_U_EODLABEL           14236
#define FS_IDC_U_MEDIC              14237
#define FS_IDC_U_MEDICLABEL         14238
#define FS_IDC_U_UAVHACKER          14239
#define FS_IDC_U_UAVHACKERLABEL     14240
#define FS_IDC_U_INITLABEL          14241
#define FS_IDC_U_INIT               14242
#define FS_IDC_U_INITEDIT           14243
#define FS_IDC_U_ACEMEDIC           14244
#define FS_IDC_U_ACEMEDICLABEL      14245
#define FS_IDC_U_ACEDOCTOR          14246
#define FS_IDC_U_ACEDOCTORLABEL     14247
#define FS_IDC_U_ACEENGINEER        14248
#define FS_IDC_U_ACEENGINEERLABEL   14249

// ---------------------------------------------------------------- Vehicles tab
#define FS_IDC_V_LIST               14301
#define FS_IDC_V_ADD                14302
#define FS_IDC_V_DUPLICATE          14303
#define FS_IDC_V_DELETE             14304
#define FS_IDC_V_UP                 14305
#define FS_IDC_V_DOWN               14306
#define FS_IDC_V_NAME               14310
#define FS_IDC_V_CLASS              14311
#define FS_IDC_V_CLASSAUTO          14312
#define FS_IDC_V_BASE               14313
#define FS_IDC_V_BASECHANGE         14314
#define FS_IDC_V_CATEGORY           14315
#define FS_IDC_V_CREW               14316
#define FS_IDC_V_SEATS              14317
#define FS_IDC_V_GUNNER             14318
#define FS_IDC_V_TEXTURE            14319
#define FS_IDC_V_NOTE               14321
#define FS_IDC_V_PARTS              14322
#define FS_IDC_V_CARGOLABEL         14323
#define FS_IDC_V_CARGO              14324
#define FS_IDC_V_CARGOEDIT          14325
#define FS_IDC_V_PYLONS             14326
#define FS_IDC_V_OPTIONAL           14327
#define FS_IDC_V_OPTIONALLABEL      14328
#define FS_IDC_V_INITLABEL          14329
#define FS_IDC_V_INIT               14330
#define FS_IDC_V_INITEDIT           14331

// ---------------------------------------------------------------- Groups tab
#define FS_IDC_G_CATEGORY           14401
#define FS_IDC_G_LIST               14402
#define FS_IDC_G_NEW                14403
#define FS_IDC_G_DUPLICATE          14404
#define FS_IDC_G_DELETE             14405
#define FS_IDC_G_AUTO               14406
#define FS_IDC_G_AUTOREBUILD        14407
#define FS_IDC_G_NAME               14410
#define FS_IDC_G_CLASS              14411
#define FS_IDC_G_CLASSAUTO          14412
#define FS_IDC_G_RARITY             14413
#define FS_IDC_G_RARITYVALUE        14414
#define FS_IDC_G_ICON               14415
#define FS_IDC_G_MEMBERS            14420
#define FS_IDC_G_MEMBERPICK         14421
#define FS_IDC_G_MEMBERADD          14422
#define FS_IDC_G_MEMBERREMOVE       14423
#define FS_IDC_G_MEMBERUP           14424
#define FS_IDC_G_MEMBERDOWN         14425
#define FS_IDC_G_RANK               14426
#define FS_IDC_G_NOTE               14430

// ---------------------------------------------------------------- ALiVE tab
#define FS_IDC_A_SECTION            14501
#define FS_IDC_A_SECTIONLABEL       14502
#define FS_IDC_A_PREVIEW            14510
#define FS_IDC_A_HOOK               14511
#define FS_IDC_A_RARITY             14512
#define FS_IDC_A_LIVE               14513
#define FS_IDC_A_HOOKLABEL          14514
#define FS_IDC_A_RARITYLABEL        14515
#define FS_IDC_A_COPY               14516
#define FS_IDC_A_CRATELIST          14520
#define FS_IDC_A_CRATEEDIT          14521
#define FS_IDC_A_CRATEAUTO          14522
#define FS_IDC_A_CRATENOTE          14523
#define FS_IDC_A_CRATENEW           14524
#define FS_IDC_A_CRATERENAME        14525
#define FS_IDC_A_CRATEREMOVE        14526
#define FS_IDC_A_CRATEBOXLABEL      14527
#define FS_IDC_A_CRATEBOX           14528
#define FS_IDC_A_LISTPICK           14530
#define FS_IDC_A_LIST               14531
#define FS_IDC_A_LISTSOURCE         14532
#define FS_IDC_A_LISTADD            14533
#define FS_IDC_A_LISTREMOVE         14534
#define FS_IDC_A_LISTAUTO           14535
#define FS_IDC_A_LISTPICKLABEL      14536
#define FS_IDC_A_LISTSOURCELABEL    14537
#define FS_IDC_A_LISTNOTE           14538
#define FS_IDC_A_REDIRFROM          14540
#define FS_IDC_A_REDIRTO            14541
#define FS_IDC_A_REDIRNOTE          14542
#define FS_IDC_A_REDIRTOLABEL       14543

// ---------------------------------------------------------------- Export tab
#define FS_IDC_E_PATH               14701
#define FS_IDC_E_NORANDOM           14702
#define FS_IDC_E_FORCE              14703
#define FS_IDC_E_CHECK              14710
#define FS_IDC_E_EXPORT             14711
#define FS_IDC_E_COPY               14712
#define FS_IDC_E_COPYPATH           14713
#define FS_IDC_E_ADVANCED           14714
#define FS_IDC_E_RESULTS            14720
#define FS_IDC_E_DEPS               14721

// ---------------------------------------------------------------- Browser popup
#define FS_IDC_BR_SEARCH            14801
#define FS_IDC_BR_FACTION           14802
#define FS_IDC_BR_KIND              14803
#define FS_IDC_BR_SIDE              14804
#define FS_IDC_BR_LIST              14805
#define FS_IDC_BR_COUNT             14806
#define FS_IDC_BR_PARENT            14807
#define FS_IDC_BR_ADD               14808
#define FS_IDC_BR_KEEP              14809
#define FS_IDC_BR_CLOSE             14810
#define FS_IDC_BR_TAKE              14811
#define FS_IDC_BR_TITLE             14812
#define FS_IDC_BR_PARENT_LABEL      14813
// the four areas of open view around a popup (popups.hpp)
#define FS_IDC_POPUP_TOP            14990
#define FS_IDC_POPUP_BOTTOM         14991
#define FS_IDC_POPUP_LEFT           14992
#define FS_IDC_POPUP_RIGHT          14993

// ---------------------------------------------------------------- Faction picker popup
#define FS_IDC_PK_LIST              14821
#define FS_IDC_PK_NEW               14822
#define FS_IDC_PK_MERGE             14823
#define FS_IDC_PK_CLOSE             14825

// ---------------------------------------------------------------- Text box popup
// cargo (14830)
#define FS_IDC_CG_TITLE             14831
#define FS_IDC_CG_MODE              14832
#define FS_IDC_CG_LIST              14833
#define FS_IDC_CG_COUNT             14834
#define FS_IDC_CG_SETCOUNT          14835
#define FS_IDC_CG_REMOVE            14836
#define FS_IDC_CG_CLEAR             14837
#define FS_IDC_CG_UNIT              14838
#define FS_IDC_CG_ADDUNIT           14839
#define FS_IDC_CG_BASE              14840
#define FS_IDC_CG_CLOSE             14841

#define FS_IDC_TB_TITLE             14851
#define FS_IDC_TB_TEXT              14852
#define FS_IDC_TB_COPY              14853
#define FS_IDC_TB_CLOSE             14854

// ---------------------------------------------------------------- Prompt popup
#define FS_IDC_PR_QUESTION          14871
#define FS_IDC_PR_EDIT              14872
#define FS_IDC_PR_OK                14873
#define FS_IDC_PR_CANCEL            14874

// help (14890)
#define FS_IDC_HL_TITLE             14891
#define FS_IDC_HL_GROUP             14892
#define FS_IDC_HL_TEXT              14893
#define FS_IDC_HL_NOSHOW            14894
#define FS_IDC_HL_CLOSE             14895
#define FS_IDC_HL_DRAG              14896
#define FS_IDC_HL_BACK              14897
#define FS_IDC_HL_LABEL             14898
// the preview's mouse area behind every popup

// gear pools (14910)
#define FS_IDC_PL_TITLE             14911
#define FS_IDC_PL_LIST              14912
#define FS_IDC_PL_NAME              14913
#define FS_IDC_PL_RENAME            14914
#define FS_IDC_PL_NEW               14915
#define FS_IDC_PL_DELETE            14916
#define FS_IDC_PL_USE               14917
#define FS_IDC_PL_SLOT              14918
#define FS_IDC_PL_ENTRIES           14919
#define FS_IDC_PL_WEIGHT            14920
#define FS_IDC_PL_SETWEIGHT         14921
#define FS_IDC_PL_REMOVE            14922
#define FS_IDC_PL_UNIT              14923
#define FS_IDC_PL_ADDUNIT           14924
#define FS_IDC_PL_ROLL              14925
#define FS_IDC_PL_CLOSE             14926
#define FS_IDC_PL_USERS             14927

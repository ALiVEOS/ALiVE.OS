/*
 * Civ Pop Defaults
 */

ALIVE_civilianWeapons = [] call ALIVE_fnc_hashCreate;

// Vanilla
[ALIVE_civilianWeapons, "CIV", [["hgun_Pistol_heavy_01_F","11Rnd_45ACP_Mag"],["hgun_PDW2000_F","30Rnd_9x21_Mag"],["SMG_02_ARCO_pointg_F","30Rnd_9x21_Mag"],["arifle_TRG21_F","30Rnd_556x45_Stanag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "CIV_F", [["hgun_Pistol_heavy_01_F","11Rnd_45ACP_Mag"],["hgun_PDW2000_F","30Rnd_9x21_Mag"],["SMG_02_ARCO_pointg_F","30Rnd_9x21_Mag"],["arifle_TRG21_F","30Rnd_556x45_Stanag"]]] call ALIVE_fnc_hashSet;

// Custom
[ALIVE_civilianWeapons, "mas_afr_civ", [["arifle_mas_ak_74m","30Rnd_mas_545x39_mag"],["arifle_mas_aks74u","30Rnd_mas_545x39_mag"],["arifle_mas_akm","30Rnd_mas_762x39_mag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "caf_ag_afr_civ", [["caf_AK47","CAF_30Rnd_762x39_AK"],["caf_AK74","CAF_30Rnd_545x39_AK"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "caf_ag_me_civ", [["caf_AK47","CAF_30Rnd_762x39_AK"],["caf_AK74","CAF_30Rnd_545x39_AK"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "drirregularsC", [["arifle_mas_ak_74m","30Rnd_mas_545x39_mag"],["arifle_mas_aks74u","30Rnd_mas_545x39_mag"],["arifle_mas_akm","30Rnd_mas_762x39_mag"]]] call ALIVE_fnc_hashSet;

// CUP
[ALIVE_civilianWeapons, "CUP_C_TK", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CUP_C_CHERNARUS", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CUP_C_RU", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

// CFP
[ALIVE_civilianWeapons, "CFP_C_ME", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_AFRISLAMIC", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_AFRCHRISTIAN", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_ASIA", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_AFG", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

// Civ Pop Panic Noises
ALiVE_CivPop_PanicNoises = [
	"ALiVE_Civpop_Audio_Fear1",
    "ALiVE_Civpop_Audio_Fear2",
    "ALiVE_Civpop_Audio_Fear3",
    "ALiVE_Civpop_Audio_Fear4",
    "ALiVE_Civpop_Audio_Fear5",
    "ALiVE_Civpop_Audio_Fear6",
    "ALiVE_Civpop_Audio_Fear7",
    "ALiVE_Civpop_Audio_Fear8",
    "ALiVE_Civpop_Audio_Fear9",
    "ALiVE_Civpop_Audio_Fear10",
    "ALiVE_Civpop_Audio_Fear11",
    "ALiVE_Civpop_Audio_Fear12",
	"ALiVE_Civpop_Audio_Fear13"
];

// Civ Pop Env sounds default
ALIVE_civilianHouseTracks = [] call ALIVE_fnc_hashCreate;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_1", 180] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_2", 188] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_3", 199] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_4", 246] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_5", 335] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_6", 199] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_7", 177] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_8", 235] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_9", 246] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_10", 292] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_11", 189] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_12", 203] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_13", 16] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_14", 128] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_15", 14] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_16", 7] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_17", 19] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_18", 4] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_19", 22] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_20", 2] call ALIVE_fnc_hashSet;

// Civ Pop Env sounds by faction
ALIVE_civilianFactionHouseTracks = [] call ALIVE_fnc_hashCreate;

CUP_C_TK_ALIVE_civilianHouseTracks = +ALIVE_civilianHouseTracks;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_1", 135] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_2", 85] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_3", 35] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_4", 55] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_5", 45] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_6", 50] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_7", 50] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_8", 85] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_9", 140] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_10", 125] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_11", 95] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_12", 70] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_13", 21] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_14", 280] call ALIVE_fnc_hashSet;
[CUP_C_TK_ALIVE_civilianHouseTracks, "ALiVE_Civpop_Audio_ME_15", 335] call ALIVE_fnc_hashSet;

[ALIVE_civilianFactionHouseTracks, "CUP_C_TK", CUP_C_TK_ALIVE_civilianHouseTracks] call ALIVE_fnc_hashSet;

CFP_C_AFG_ALIVE_civilianHouseTracks = +CUP_C_TK_ALIVE_civilianHouseTracks;
[ALIVE_civilianFactionHouseTracks, "CFP_C_AFG", CFP_C_AFG_ALIVE_civilianHouseTracks] call ALIVE_fnc_hashSet;

CFP_C_ME_ALIVE_civilianHouseTracks = +CUP_C_TK_ALIVE_civilianHouseTracks;
[ALIVE_civilianFactionHouseTracks, "CFP_C_ME", CFP_C_ME_ALIVE_civilianHouseTracks] call ALIVE_fnc_hashSet;


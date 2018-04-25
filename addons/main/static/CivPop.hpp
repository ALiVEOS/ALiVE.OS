/*
 * Civ Pop Defaults
 */

ALIVE_civilianWeapons = [] call ALIVE_fnc_hashCreate;
[ALIVE_civilianWeapons, "CIV", [["hgun_Pistol_heavy_01_F","11Rnd_45ACP_Mag"],["hgun_PDW2000_F","30Rnd_9x21_Mag"],["SMG_02_ARCO_pointg_F","30Rnd_9x21_Mag"],["arifle_TRG21_F","30Rnd_556x45_Stanag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "CIV_F", [["hgun_Pistol_heavy_01_F","11Rnd_45ACP_Mag"],["hgun_PDW2000_F","30Rnd_9x21_Mag"],["SMG_02_ARCO_pointg_F","30Rnd_9x21_Mag"],["arifle_TRG21_F","30Rnd_556x45_Stanag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "mas_afr_civ", [["arifle_mas_ak_74m","30Rnd_mas_545x39_mag"],["arifle_mas_aks74u","30Rnd_mas_545x39_mag"],["arifle_mas_akm","30Rnd_mas_762x39_mag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "caf_ag_afr_civ", [["caf_AK47","CAF_30Rnd_762x39_AK"],["caf_AK74","CAF_30Rnd_545x39_AK"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "caf_ag_me_civ", [["caf_AK47","CAF_30Rnd_762x39_AK"],["caf_AK74","CAF_30Rnd_545x39_AK"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "drirregularsC", [["arifle_mas_ak_74m","30Rnd_mas_545x39_mag"],["arifle_mas_aks74u","30Rnd_mas_545x39_mag"],["arifle_mas_akm","30Rnd_mas_762x39_mag"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CUP_C_TK", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_ME", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_AFRISLAMIC", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_AFRCHRISTIAN", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

[ALIVE_civilianWeapons, "CFP_C_AFG", [["CUP_arifle_ak47","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_ak74","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKM","CUP_30Rnd_762x39_AK47_M"],["CUP_arifle_AKS","CUP_30Rnd_762x39_AK47_M"],["CUP_srifle_LeeEnfield","CUP_10x_303_M"],["CUP_hgun_Makarov","CUP_8Rnd_9x18_Makarov_M"]]] call ALIVE_fnc_hashSet;

ALIVE_civilianHouseTracks = [] call ALIVE_fnc_hashCreate;
[ALIVE_civilianHouseTracks, "Track1", 180] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track2", 188] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track3", 199] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track4", 246] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track5", 335] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track6", 199] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track7", 177] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track8", 235] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track9", 246] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track10", 292] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track11", 189] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track12", 203] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track13", 16] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track14", 128] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track15", 14] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track16", 7] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track17", 19] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track18", 4] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track19", 22] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track20", 2] call ALIVE_fnc_hashSet;




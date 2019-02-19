// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_CDF_SNW", [
		"CFP_B_CDF_BMP_2Ambulance_SNW_01",
		"CFP_B_CDF_Ural_Refuel_SNW_01",
		"CFP_B_CDF_koda_1203_Ambulance_SNW_01",
		"CFP_B_CDF_UAZ_SNW_01",
		"CFP_B_CDF_Ural_SNW_01",
		"CFP_B_CDF_Ural_Ammo_SNW_01",
		"CFP_B_CDF_Ural_Empty_SNW_01",
		"CFP_B_CDF_Ural_Open_SNW_01",
		"CFP_B_CDF_Ural_Repair_SNW_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_CDF_SNW", ["CFP_B_CDF_SNW_AmmoBox","CFP_B_CDF_SNW_WeaponsBox","CFP_B_CDF_SNW_LaunchersBox","CFP_B_CDF_SNW_UniformBox","CFP_B_CDF_SNW_SupportBox","CFP_B_CDF_SNW_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_CDF_SNW", [
		"CFP_B_CDF_Ural_SNW_01",
		"CFP_B_CDF_Ural_Ammo_SNW_01",
		"CFP_B_CDF_Ural_Empty_SNW_01",
		"CFP_B_CDF_Ural_Open_SNW_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_CDF_SNW", [
		"CFP_B_CDF_Mi_6A_Hook_VIV_SNW_01",
		"CFP_B_CDF_Mi_6T_Hook_SNW_01",
		"CFP_B_CDF_Mi_8MT_Medevac_SNW_01",
		"CFP_B_CDF_Mi_8MT_SNW_01"
	]
] call ALIVE_fnc_hashSet;

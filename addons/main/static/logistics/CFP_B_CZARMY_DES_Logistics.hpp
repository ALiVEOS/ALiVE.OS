// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CUP_B_CZ", [
		"CUP_B_UAZ_Open_ACR",
		"CFP_B_CZARMY_HMMWV_Ambulance_WDL_01",
		"CUP_B_LR_Ambulance_CZ_W",
		"CUP_B_LR_Transport_CZ_W",
		"CUP_B_T810_Reammo_CZ_WDL",
		"CUP_B_T810_Unarmed_CZ_WDL",
		"CUP_B_T810_Refuel_CZ_WDL",
		"CUP_B_T810_Repair_CZ_WDL",
		"CUP_B_UAZ_Unarmed_ACR"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CUP_B_CZ", [
		"CUP_CZBasicWeapons_EP1"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CUP_B_CZ", [
		"CUP_B_T810_Repair_CZ_WDL",
		"CUP_B_T810_Reammo_CZ_WDL",
		"CUP_B_T810_Unarmed_CZ_WDL",
		"CUP_B_T810_Refuel_CZ_WDL"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CUP_B_CZ", [
		"CFP_B_CZARMY_Mi_171Sh_Unarmed_WDL_01"
	]
] call ALIVE_fnc_hashSet;


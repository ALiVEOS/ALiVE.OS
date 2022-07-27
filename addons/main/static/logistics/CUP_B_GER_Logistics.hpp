// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CUP_B_GER", [
		"CUP_B_T810_Unarmed_CZ_DES"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CUP_B_GER", [
		"CUP_GERBasicWeapons_EP1"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CUP_B_GER", [
		"CUP_B_T810_Unarmed_CZ_DES"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CUP_B_GER", [
		"CUP_B_CH53E_GER",
		"CUP_B_CH53E_VIV_GER",
		"CUP_B_UH1D_GER_KSK_Des",
		"CUP_B_UH1D_slick_GER_KSK_Des"
	]
] call ALIVE_fnc_hashSet;


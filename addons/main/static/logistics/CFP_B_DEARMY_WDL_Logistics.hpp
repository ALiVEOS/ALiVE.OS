// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_DEARMY_WDL", [
		"CUP_B_T810_Unarmed_CZ_WDL"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_DEARMY_WDL", [
		"CUP_GERBasicWeapons_EP1"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_DEARMY_WDL", [
		"CUP_B_T810_Unarmed_CZ_WDL"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_DEARMY_WDL", [
		"CFP_B_DEArmy_CH_53G_Super_Stallion_WDL_01",
		"CFP_B_DEArmy_CH_53G_Super_Stallion_VIV_WDL_01",
		"CUP_B_UH1D_GER_KSK",
		"CUP_B_UH1D_slick_GER_KSK"
	]
] call ALIVE_fnc_hashSet;


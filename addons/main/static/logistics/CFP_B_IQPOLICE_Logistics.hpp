// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_IQPOLICE", [
		"cfp_b_iqpolice_Ural",
		"cfp_b_iqpolice_offroad"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_IQPOLICE", ["CFP_B_IQPOLICE_AmmoBox","CFP_B_IQPOLICE_WeaponsBox","CFP_B_IQPOLICE_LaunchersBox","CFP_B_IQPOLICE_UniformBox","CFP_B_IQPOLICE_SupportBox","CFP_B_IQPOLICE_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_IQPOLICE", [
		"cfp_b_iqpolice_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_IQPOLICE", [
		"CUP_B_UH1Y_UNA_USMC"
	]
] call ALIVE_fnc_hashSet;


// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_AFGPOLICE", [
		"CFP_B_AFGPolice_Offroad_01",
		"CFP_B_AFGPolice_Offroad_ANCOP_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_AFGPOLICE", ["CFP_B_AFGPOLICE_AmmoBox","CFP_B_AFGPOLICE_WeaponsBox","CFP_B_AFGPOLICE_LaunchersBox","CFP_B_AFGPOLICE_UniformBox","CFP_B_AFGPOLICE_SupportBox","CFP_B_AFGPOLICE_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_AFGPOLICE", [
		"CFP_B_AFGPolice_Offroad_01",
		"CFP_B_AFGPolice_Offroad_ANCOP_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_AFGPOLICE", [
		"CUP_B_UH1Y_UNA_USMC"
	]
] call ALIVE_fnc_hashSet;


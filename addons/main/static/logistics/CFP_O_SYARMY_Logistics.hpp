// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_SYARMY", [
		"cfp_o_syarmy_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_SYARMY", ["CFP_O_SYARMY_AmmoBox","CFP_O_SYARMY_WeaponsBox","CFP_O_SYARMY_LaunchersBox","CFP_O_SYARMY_UniformBox","CFP_O_SYARMY_SupportBox","CFP_O_SYARMY_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_SYARMY", [
"cfp_o_syarmy_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_SYARMY", []
] call ALIVE_fnc_hashSet;


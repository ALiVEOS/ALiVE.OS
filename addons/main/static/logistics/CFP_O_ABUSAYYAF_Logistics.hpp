// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_ABUSAYYAF", [
		"CFP_O_ABUSAYYAF_Offroad_01",
		"CFP_O_ABUSAYYAF_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_ABUSAYYAF", ["CFP_O_ABUSAYYAF_AmmoBox","CFP_O_ABUSAYYAF_WeaponsBox","CFP_O_ABUSAYYAF_LaunchersBox","CFP_O_ABUSAYYAF_UniformBox","CFP_O_ABUSAYYAF_SupportBox","CFP_O_ABUSAYYAF_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_ABUSAYYAF", [
		"CFP_O_ABUSAYYAF_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_ABUSAYYAF", [
	]
] call ALIVE_fnc_hashSet;


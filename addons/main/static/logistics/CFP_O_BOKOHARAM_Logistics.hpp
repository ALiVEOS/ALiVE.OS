// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_BOKOHARAM", [
		"CFP_O_BH_Ural_01",
		"CFP_O_BH_Offroad_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_BOKOHARAM", ["CFP_O_BOKOHARAM_AmmoBox","CFP_O_BOKOHARAM_WeaponsBox","CFP_O_BOKOHARAM_LaunchersBox","CFP_O_BOKOHARAM_UniformBox","CFP_O_BOKOHARAM_SupportBox","CFP_O_BOKOHARAM_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_BOKOHARAM", [
		"CFP_O_BH_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_BOKOHARAM", [
	]
] call ALIVE_fnc_hashSet;


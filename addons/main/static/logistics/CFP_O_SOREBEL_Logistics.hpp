// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_SOREBEL", [
		"CFP_O_SOREBEL_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_O_SOREBEL", ["CFP_O_SOREBEL_AmmoBox","CFP_O_SOREBEL_WeaponsBox","CFP_O_SOREBEL_LaunchersBox","CFP_O_SOREBEL_UniformBox","CFP_O_SOREBEL_SupportBox","CFP_O_SOREBEL_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_SOREBEL", [
		"CFP_O_SOREBEL_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_SOREBEL", [
	]
] call ALIVE_fnc_hashSet;


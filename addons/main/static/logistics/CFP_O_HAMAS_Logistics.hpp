// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_HAMAS", [
		"CFP_O_HAMAS_Technical_Unarmed_01",
		"CFP_O_HAMAS_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_HAMAS", ["CFP_O_HAMAS_AmmoBox","CFP_O_HAMAS_WeaponsBox","CFP_O_HAMAS_LaunchersBox","CFP_O_HAMAS_UniformBox","CFP_O_HAMAS_SupportBox","CFP_O_HAMAS_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_HAMAS", [
		"CFP_O_HAMAS_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_HAMAS", [
	]
] call ALIVE_fnc_hashSet;


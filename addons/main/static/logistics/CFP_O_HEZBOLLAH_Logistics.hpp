// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_HEZBOLLAH", [
		"CFP_O_HEZBOLLAH_Truck_01",
		"CFP_O_HEZBOLLAH_Quad_Bike_01",
		"CFP_O_HEZBOLLAH_Offroad_01",
		"CFP_O_HEZBOLLAH_Offroad_flag_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_HEZBOLLAH", ["CFP_O_HEZBOLLAH_AmmoBox","CFP_O_HEZBOLLAH_WeaponsBox","CFP_O_HEZBOLLAH_LaunchersBox","CFP_O_HEZBOLLAH_UniformBox","CFP_O_HEZBOLLAH_SupportBox","CFP_O_HEZBOLLAH_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_HEZBOLLAH", [
		"CFP_O_HEZBOLLAH_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_HEZBOLLAH", []
] call ALIVE_fnc_hashSet;


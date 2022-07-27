// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_ALQAEDA", [
		"CFP_O_ALQAEDA_Datsun_Pickup_01",
		"CFP_O_ALQAEDA_Offroad_01",
		"CFP_O_ALQAEDA_Truck_01",
		"CFP_O_ALQAEDA_Ural_Open_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_ALQAEDA", ["CFP_O_ALQAEDA_AmmoBox","CFP_O_ALQAEDA_WeaponsBox","CFP_O_ALQAEDA_LaunchersBox","CFP_O_ALQAEDA_UniformBox","CFP_O_ALQAEDA_SupportBox","CFP_O_ALQAEDA_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_ALQAEDA", [
		"CFP_O_ALQAEDA_Ural_Open_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_ALQAEDA", []
] call ALIVE_fnc_hashSet;


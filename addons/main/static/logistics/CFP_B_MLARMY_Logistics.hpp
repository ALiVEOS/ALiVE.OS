// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_MLARMY", [
		"CFP_B_MLARMY_Land_Rover_Ambulance_01",
		"CFP_B_MLARMY_Technical_01",
		"CFP_B_MLARMY_Truck_01",
		"CFP_B_MLARMY_Ural_01",
		"CFP_B_MLARMY_Ural_Ammo_01",
		"CFP_B_MLARMY_Ural_Refuel_01",
		"CFP_B_MLARMY_Ural_Open_01",
		"CFP_B_MLARMY_Ural_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

// Copy this part to ALiVE logistics static data
[ALIVE_factionDefaultSupplies, "CFP_B_MLARMY", ["CFP_B_MLARMY_AmmoBox","CFP_B_MLARMY_WeaponsBox","CFP_B_MLARMY_LaunchersBox","CFP_B_MLARMY_UniformBox","CFP_B_MLARMY_SupportBox","CFP_B_MLARMY_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_MLARMY", [
		"CFP_B_MLARMY_Truck_01",
		"CFP_B_MLARMY_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_MLARMY", [
		"CFP_B_MLARMY_SA_330_Puma_01",
		"CFP_B_MLARMY_Harbin_ZB_9_01"
	]
] call ALIVE_fnc_hashSet;


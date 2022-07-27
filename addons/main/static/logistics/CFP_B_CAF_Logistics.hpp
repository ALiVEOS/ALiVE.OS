// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_CAF", [
		"CFP_B_CAF_Truck_01",
		"CFP_B_CAF_Ural_01",
		"CFP_B_CAF_Ural_Ammo_01",
		"CFP_B_CAF_Ural_Refuel_01",
		"CFP_B_CAF_Ural_Repair_01",
		"CFP_B_CAF_UAZ_Open_01",
		"CFP_B_CAF_Technical_Unarmed_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_B_CAF", ["CFP_B_CAF_AmmoBox","CFP_B_CAF_WeaponsBox","CFP_B_CAF_LaunchersBox","CFP_B_CAF_UniformBox","CFP_B_CAF_SupportBox","CFP_B_CAF_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_CAF", [
		"CFP_B_CAF_Truck_01",
		"CFP_B_CAF_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_CAF", [
		"CFP_B_CAF_Mi_8MT_01"
	]
] call ALIVE_fnc_hashSet;


// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_ALSHABAAB", [
		"CFP_O_ALSHABAAB_Offroad_01",
		"CFP_O_ALSHABAAB_Truck_01",
		"CFP_O_ALSHABAAB_Technical_01",
		"CFP_O_ALSHABAAB_Zamak_01",
		"CFP_O_ALSHABAAB_Ural_Ammo_01",
		"CFP_O_ALSHABAAB_Ural_Repair_01",
		"CFP_O_ALSHABAAB_Ural_Open_01",
		"CFP_O_ALSHABAAB_Ural_Fuel_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_O_ALSHABAAB", ["CFP_O_ALSHABAAB_AmmoBox","CFP_O_ALSHABAAB_WeaponsBox","CFP_O_ALSHABAAB_LaunchersBox","CFP_O_ALSHABAAB_UniformBox","CFP_O_ALSHABAAB_SupportBox","CFP_O_ALSHABAAB_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_ALSHABAAB", [
		"CFP_O_ALSHABAAB_Zamak_01",
		"CFP_O_ALSHABAAB_Ural_Ammo_01",
		"CFP_O_ALSHABAAB_Ural_Repair_01",
		"CFP_O_ALSHABAAB_Ural_Open_01",
		"CFP_O_ALSHABAAB_Ural_Fuel_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_ALSHABAAB", [
	]
] call ALIVE_fnc_hashSet;


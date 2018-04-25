// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_UGARMY", [
		"CFP_B_UGARMY_UAZ_01",
		"CFP_B_UGARMY_Ural_01",
		"CFP_B_UGARMY_UAZ_Open_01",
		"CFP_B_UGARMY_Ural_Ammo_01",
		"CFP_B_UGARMY_Ural_Open_01",
		"CFP_B_UGARMY_Ural_Refuel_01",
		"CFP_B_UGARMY_Ural_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_B_UGARMY", ["CFP_B_UGARMY_AmmoBox","CFP_B_UGARMY_WeaponsBox","CFP_B_UGARMY_LaunchersBox","CFP_B_UGARMY_UniformBox","CFP_B_UGARMY_SupportBox","CFP_B_UGARMY_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_UGARMY", [
		"CFP_B_UGARMY_Ural_01",
		"CFP_B_UGARMY_Ural_Ammo_01",
		"CFP_B_UGARMY_Ural_Open_01",
		"CFP_B_UGARMY_Ural_Refuel_01",
		"CFP_B_UGARMY_Ural_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_UGARMY", [
		"CFP_B_UGARMY_Mi_17_01",
		"CFP_B_UGARMY_Mi_17_VIV_01"
	]
] call ALIVE_fnc_hashSet;


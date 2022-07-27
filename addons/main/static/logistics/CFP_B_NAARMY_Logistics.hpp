// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_NAARMY", [
		"CFP_B_NAARMY_Land_Rover_01",
		"CFP_B_NAARMY_Land_Rover_Ambulance_01",
		"CFP_B_NAARMY_Ural_01",
		"CFP_B_NAARMY_Ural_Ammo_01",
		"CFP_B_NAARMY_Ural_Refuel_01",
		"CFP_B_NAARMY_Ural_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_B_NAARMY", ["CFP_B_NAARMY_AmmoBox","CFP_B_NAARMY_WeaponsBox","CFP_B_NAARMY_LaunchersBox","CFP_B_NAARMY_UniformBox","CFP_B_NAARMY_SupportBox","CFP_B_NAARMY_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_NAARMY", [
		"CFP_B_NAARMY_Ural_Ammo_01",
		"CFP_B_NAARMY_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_NAARMY", [
		"CFP_B_NAARMY_Mi_8MTV3_01"
	]
] call ALIVE_fnc_hashSet;


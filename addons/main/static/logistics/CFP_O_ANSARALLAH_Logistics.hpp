// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_ANSARALLAH", [
	"CFP_O_ANSARALLAH_Offroad_01",
	"CFP_O_ANSARALLAH_Technical_01",
	"CFP_O_ANSARALLAH_Ural_Ammo_01",
	"CFP_O_ANSARALLAH_Ural_Fuel_01",
	"CFP_O_ANSARALLAH_Ural_Open_01",
	"CFP_O_ANSARALLAH_Ural_Repair_01",
	"CFP_O_ANSARALLAH_Zamak_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_O_ANSARALLAH", ["CFP_O_ANSARALLAH_AmmoBox","CFP_O_ANSARALLAH_WeaponsBox","CFP_O_ANSARALLAH_LaunchersBox","CFP_O_ANSARALLAH_UniformBox","CFP_O_ANSARALLAH_SupportBox","CFP_O_ANSARALLAH_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_ANSARALLAH", [
	"CFP_O_ANSARALLAH_Ural_Ammo_01",
	"CFP_O_ANSARALLAH_Ural_Fuel_01",
	"CFP_O_ANSARALLAH_Ural_Open_01",
	"CFP_O_ANSARALLAH_Ural_Repair_01",
	"CFP_O_ANSARALLAH_Zamak_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_ANSARALLAH", [
	]
] call ALIVE_fnc_hashSet;


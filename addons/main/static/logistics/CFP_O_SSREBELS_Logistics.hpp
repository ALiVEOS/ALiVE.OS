// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_SSREBELS", [
	"CFP_O_SSREBELS_Land_Rover_01",
	"CFP_O_SSREBELS_Offroad_02",
	"CFP_O_SSREBELS_Offroad_White_Army_01",
	"CFP_O_SSREBELS_Pickup_01",
	"CFP_O_SSREBELS_Praga_V3S_01",
	"CFP_O_SSREBELS_Praga_V3S_Ammunition_01",
	"CFP_O_SSREBELS_Truck_01",
	"CFP_O_SSREBELS_Truck_White_Army_01",
	"CFP_O_SSREBELS_Praga_V3S_Refuel_01",
	"CFP_O_SSREBELS_Praga_V3S_Repair_01",
	"CFP_O_SSREBELS_Pickup_White_Army_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_SSREBELS", ["CFP_O_SSREBELS_AmmoBox","CFP_O_SSREBELS_WeaponsBox","CFP_O_SSREBELS_LaunchersBox","CFP_O_SSREBELS_UniformBox","CFP_O_SSREBELS_SupportBox","CFP_O_SSREBELS_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_SSREBELS", [
	"CFP_O_SSREBELS_Praga_V3S_01",
	"CFP_O_SSREBELS_Praga_V3S_Ammunition_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_SSREBELS", [
	]
] call ALIVE_fnc_hashSet;


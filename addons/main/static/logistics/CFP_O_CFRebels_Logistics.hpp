// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_CFRebels", [
	"CFP_O_CFRebels_Offroad_Repair_01",
	"CFP_O_CFRebels_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_O_CFRebels", ["CFP_O_CFRebels_AmmoBox","CFP_O_CFRebels_WeaponsBox","CFP_O_CFRebels_LaunchersBox","CFP_O_CFRebels_UniformBox","CFP_O_CFRebels_SupportBox","CFP_O_CFRebels_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_CFRebels", [
	"CFP_O_CFRebels_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_CFRebels", [
	]
] call ALIVE_fnc_hashSet;


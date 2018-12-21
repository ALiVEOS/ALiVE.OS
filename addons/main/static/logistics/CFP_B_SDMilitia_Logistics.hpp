// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_SDMilitia", [
	"CFP_B_SDMilitia_Land_Rover_01",
	"CFP_B_SDMilitia_Offroad_01",
	"CFP_B_SDMilitia_Pickup_01",
	"CFP_B_SDMilitia_Truck_01",
	"CFP_B_SDMilitia_Walid_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_SDMilitia", ["CFP_B_SDMilitia_AmmoBox","CFP_B_SDMilitia_WeaponsBox","CFP_B_SDMilitia_LaunchersBox","CFP_B_SDMilitia_UniformBox","CFP_B_SDMilitia_SupportBox","CFP_B_SDMilitia_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_SDMilitia", [
		"CFP_B_SDMilitia_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_SDMilitia", [
		"CFP_B_SDARMY_Mi_8MT_01"
	]
] call ALIVE_fnc_hashSet;


// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_SDRebels", [
		"CFP_O_SDRebels_Land_Rover_01",
		"CFP_O_SDRebels_Offroad_01",
		"CFP_O_SDRebels_Pickup_01",
		"CFP_O_SDRebels_Truck_01",
		"CFP_O_SDRebels_Van_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_SDRebels", ["CFP_O_SDRebels_AmmoBox","CFP_O_SDRebels_WeaponsBox","CFP_O_SDRebels_LaunchersBox","CFP_O_SDRebels_UniformBox","CFP_O_SDRebels_SupportBox","CFP_O_SDRebels_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_SDRebels", [
		"CFP_O_SDRebels_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_SDRebels", [
	]
] call ALIVE_fnc_hashSet;


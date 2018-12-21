// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_I_SDRebels", [
		"CFP_I_SDRebels_Land_Rover_01",
		"CFP_I_SDRebels_Offroad_02",
		"CFP_I_SDRebels_Praga_V3S_01",
		"CFP_I_SDRebels_Praga_V3S_Ammunition_01",
		"CFP_I_SDRebels_Praga_V3S_Refuel_01",
		"CFP_I_SDRebels_Praga_V3S_Repair_01",
		"CFP_I_SDRebels_Truck_01",
		"CFP_I_SDRebels_Pickup_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_I_SDRebels", ["CFP_I_SDRebels_AmmoBox","CFP_I_SDRebels_WeaponsBox","CFP_I_SDRebels_LaunchersBox","CFP_I_SDRebels_UniformBox","CFP_I_SDRebels_SupportBox","CFP_I_SDRebels_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_I_SDRebels", [
		"CFP_I_SDRebels_Praga_V3S_01",
		"CFP_I_SDRebels_Praga_V3S_Ammunition_01",
		"CFP_I_SDRebels_Praga_V3S_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_I_SDRebels", [
	]
] call ALIVE_fnc_hashSet;


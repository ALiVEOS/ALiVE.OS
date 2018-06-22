// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_I_SSArmy", [
		"CFP_I_SSArmy_Ambulance_01",
		"CFP_I_SSArmy_Land_Rover_01",
		"CFP_I_SSArmy_Offroad_01",
		"CFP_I_SSArmy_Pickup_01",
		"CFP_I_SSArmy_Praga_V3S_01",
		"CFP_I_SSArmy_Truck_01",
		"CFP_I_SSArmy_Skoda_1203_01",
		"CFP_I_SSArmy_Ural_01",
		"CFP_I_SSArmy_Ural_Open_01",
		"CFP_I_SSArmy_Van_Transport_01",
		"CFP_I_SSArmy_Ural_Ammunition_01",
		"CFP_I_SSArmy_Ural_Refuel_01",
		"CFP_I_SSArmy_Ural_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_I_SSArmy", ["CFP_I_SSArmy_AmmoBox","CFP_I_SSArmy_WeaponsBox","CFP_I_SSArmy_LaunchersBox","CFP_I_SSArmy_UniformBox","CFP_I_SSArmy_SupportBox","CFP_I_SSArmy_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_I_SSArmy", [
		"CFP_I_SSArmy_Praga_V3S_01",
		"CFP_I_SSArmy_Ural_01",
		"CFP_I_SSArmy_Ural_Open_01",
		"CFP_I_SSArmy_Ural_Ammunition_01",
		"CFP_I_SSArmy_Ural_Refuel_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_I_SSArmy", [
		"CFP_I_SSArmy_Mi_17_01"
	]
] call ALIVE_fnc_hashSet;


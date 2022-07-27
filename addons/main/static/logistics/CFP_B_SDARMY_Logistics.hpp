// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_SDARMY", [
		"CFP_B_SDARMY_Walid_01",
		"CFP_B_SDARMY_HMMWV_01",
		"CFP_B_SDARMY_Land_Rover_Ambulance_01",
		"CFP_B_SDARMY_Offroad_01",
		"CFP_B_SDARMY_Offroad_Police_01",
		"CFP_B_SDARMY_Truck_01",
		"CFP_B_SDARMY_Pickup_01",
		"CFP_B_SDARMY_UAZ_01",
		"CFP_B_SDARMY_Ural_01",
		"CFP_B_SDARMY_Ural_Open_01",
		"CFP_B_SDARMY_Ural_Refuel_01",
		"CFP_B_SDARMY_Ural_Ammunition_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_SDARMY", ["CFP_B_SDARMY_AmmoBox","CFP_B_SDARMY_WeaponsBox","CFP_B_SDARMY_LaunchersBox","CFP_B_SDARMY_UniformBox","CFP_B_SDARMY_SupportBox","CFP_B_SDARMY_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_SDARMY", [
		"CFP_B_SDARMY_Ural_01",
		"CFP_B_SDARMY_Ural_Open_01",
		"CFP_B_SDARMY_Ural_Refuel_01",
		"CFP_B_SDARMY_Ural_Ammunition_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_SDARMY", [
	"CFP_B_SDARMY_Mi_8MT_01"
	]
] call ALIVE_fnc_hashSet;


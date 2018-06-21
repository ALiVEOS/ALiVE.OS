// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_I_WestUltra", [
	"CFP_I_WestUltra_4WD_01",
	"CFP_I_WestUltra_Quad_Bike_01",
	"CFP_I_WestUltra_SUV_02",
	"CFP_I_WestUltra_Car_01",
	"CFP_I_WestUltra_Offroad_01",
	"CFP_I_WestUltra_Truck_01",
	"CFP_I_WestUltra_Van_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_I_WestUltra", ["CFP_I_WestUltra_AmmoBox","CFP_I_WestUltra_WeaponsBox","CFP_I_WestUltra_LaunchersBox","CFP_I_WestUltra_UniformBox","CFP_I_WestUltra_SupportBox","CFP_I_WestUltra_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_I_WestUltra", [
		"CFP_I_WestUltra_Truck_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_I_WestUltra", [
	]
] call ALIVE_fnc_hashSet;

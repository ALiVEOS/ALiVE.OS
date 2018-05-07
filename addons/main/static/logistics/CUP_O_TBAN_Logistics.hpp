// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_TBAN", [
		"CFP_O_TBAN_Truck_01",
		"CFP_O_TBAN_Dastun_Pickup_01",
		"CFP_O_TBAN_Praga_V3S_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_TBAN", [
		"CUP_TKVehicleBox_EP1",
		"CUP_TKSpecialWeapons_EP1",
		"CUP_TKLaunchers_EP1",
		"CUP_GuerillaCacheBox_EP1",
		"CUP_TKOrdnanceBox_EP1",
		"CUP_TKBasicWeapons_EP1",
		"CUP_TKBasicAmmunitionBox_EP1",
		"CUP_GuerillaCacheBox_EP1",
		"CUP_TKOrdnanceBox_EP1",
		"CUP_TKBasicWeapons_EP1",
		"CUP_TKBasicAmmunitionBox_EP1"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_TBAN", [
		"CFP_O_TBAN_Truck_01",
		"CFP_O_TBAN_Dastun_Pickup_01",
		"CFP_O_TBAN_Praga_V3S_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_TBAN", [
	]
] call ALIVE_fnc_hashSet;


// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_RUMVD", [
		"CFP_O_RUMVD_UAZ_01",
		"CFP_O_RUMVD_UAZ_Medevac_01",
		"CFP_O_RUMVD_UAZ_Open_01",
		"CFP_O_RUMVD_GAZ_Vodnik_Medical_01",
		"CFP_O_RUMVD_Ural_01",
		"CFP_O_RUMVD_Ural_Ammo_01",
		"CFP_O_RUMVD_Ural_Open_01",
		"CFP_O_RUMVD_Ural_Refuel_01",
		"CFP_O_RUMVD_Ural_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_RUMVD", [
		"CUP_RUBasicAmmunitionBox",
		"CUP_RUBasicWeaponsBox",
		"CUP_RUOrdnanceBox",
		"CUP_RULaunchersBox",
		"CUP_RUSpecialWeaponsBox",
		"CUP_RUVehicleBox"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_RUMVD", [
		"CFP_O_RUMVD_Ural_01",
		"CFP_O_RUMVD_Ural_Ammo_01",
		"CFP_O_RUMVD_Ural_Open_01",
		"CFP_O_RUMVD_Ural_Refuel_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_RUMVD", [
		"CFP_O_RUMVD_Mi_6T_Hook_01",
		"CFP_O_RUMVD_Mi_8AMT_Medevac_01",
		"CFP_O_RUMVD_Mi_8AMT_VIV_01",
		"CFP_O_RUMVD_Ka_60_Kasatka_Rockets_01"
	]
] call ALIVE_fnc_hashSet;


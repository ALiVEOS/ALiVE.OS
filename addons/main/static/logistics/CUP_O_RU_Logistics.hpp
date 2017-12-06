// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CUP_O_RU", [
		"CUP_O_UAZ_Unarmed_RU",
		"CUP_O_UAZ_Open_RU",
		"CUP_O_UAZ_AMB_RU",
		"CUP_O_Ural_RU",
		"CUP_O_Ural_Reammo_RU",
		"CUP_O_Ural_Empty_RU",
		"CUP_O_Ural_Refuel_RU",
		"CUP_O_Ural_Repair_RU",
		"CUP_O_Ural_Open_RU"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CUP_O_RU", [
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
[ALIVE_factionDefaultTransport, "CUP_O_RU", [
		"CUP_O_Ural_RU",
		"CUP_O_Ural_Reammo_RU",
		"CUP_O_Ural_Open_RU",
		"CUP_O_Ural_Refuel_RU"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CUP_O_RU", [
		"CUP_O_Mi8_RU",
		"CUP_O_Mi8_VIV_RU",
		"CUP_O_MI6T_RU",
		"CUP_O_MI6A_RU",
		"CUP_O_Ka60_Grey_RU"
	]
] call ALIVE_fnc_hashSet;


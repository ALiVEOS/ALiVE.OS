// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_RUARMY_DES", [
		"CFP_O_RUARMY_UAZ_DES_01",
		"CFP_O_RUARMY_Ural_DES_01",
		"CFP_O_RUARMY_Ural_Empty_DES_01",
		"CFP_O_RUARMY_Ural_Repair_DES_01",
		"CFP_O_RUARMY_Ural_Ammo_DES_01",
		"CFP_O_RUARMY_Ural_Refuel_DES_01",
		"CFP_O_RUARMY_BMP_2Ambulance_DES_01",
		"CFP_O_RUARMY_GAZ_Vodnik_Medical_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_RUARMY_DES", [
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
[ALIVE_factionDefaultTransport, "CFP_O_RUARMY_DES", [
		"CFP_O_RUARMY_Ural_DES_01",
		"CFP_O_RUARMY_Ural_Ammo_DES_01",
		"CFP_O_RUARMY_Ural_Refuel_DES_01",
		"CFP_O_RUARMY_Ural_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_RUARMY_DES", [
		"CFP_O_RUARMY_Mi_8MTV3_DES_01",
		"CFP_O_RUARMY_Mi_8AMT_VIV_DES_01",
		"CFP_O_RUARMY_Ka_60_Kasatka_Rockets_DES_01"
	]
] call ALIVE_fnc_hashSet;


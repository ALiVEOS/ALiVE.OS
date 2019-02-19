// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_CHDKZ_SNW", [
		"CFP_O_CHDKZ_BMP_2Ambulance_SNW_01",
		"CFP_O_CHDKZ_Ural_SNW_01",
		"CFP_O_CHDKZ_TT650_SNW_01",
		"CFP_O_CHDKZ_Datsun_620_Pickup_Woodland_SNW_01",
		"CFP_O_CHDKZ_UAZ_SNW_01",
		"CFP_O_CHDKZ_Ural_Ammo_SNW_01",
		"CFP_O_CHDKZ_Ural_Empty_SNW_01",
		"CFP_O_CHDKZ_Ural_Refuel_SNW_01",
		"CFP_O_CHDKZ_Ural_Repair_SNW_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_CHDKZ_SNW", ["CFP_O_CHDKZ_SNW_AmmoBox","CFP_O_CHDKZ_SNW_WeaponsBox","CFP_O_CHDKZ_SNW_LaunchersBox","CFP_O_CHDKZ_SNW_UniformBox","CFP_O_CHDKZ_SNW_SupportBox","CFP_O_CHDKZ_SNW_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_CHDKZ_SNW", [
		"CFP_O_CHDKZ_Ural_SNW_01",
		"CFP_O_CHDKZ_Ural_Ammo_SNW_01",
		"CFP_O_CHDKZ_Ural_Empty_SNW_01",
		"CFP_O_CHDKZ_Ural_Refuel_SNW_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_CHDKZ_SNW", [
		"CFP_O_CHDKZ_Mi_8MT_SNW_01",
		"CFP_O_CHDKZ_Mi_8MT_VIV_SNW_01",
		"CFP_O_CHDKZ_Mi_8MT_Medevac_SNW_01"
	]
] call ALIVE_fnc_hashSet;

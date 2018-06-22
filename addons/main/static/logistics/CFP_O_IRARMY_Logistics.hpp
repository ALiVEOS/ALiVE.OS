// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_IRARMY", [
		"CFP_O_IRARMY_Safir_01",
		"CFP_O_IRARMY_Ural_01",
		"CFP_O_IRARMY_Volha_01",
		"CFP_O_IRARMY_Ural_Ammo_01",
		"CFP_O_IRARMY_Ural_Open_01",
		"CFP_O_IRARMY_Ural_Refuel_01",
		"CFP_O_IRARMY_Ural_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_IRARMY", ["CFP_O_IRARMY_AmmoBox","CFP_O_IRARMY_WeaponsBox","CFP_O_IRARMY_LaunchersBox","CFP_O_IRARMY_UniformBox","CFP_O_IRARMY_SupportBox","CFP_O_IRARMY_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_IRARMY", [
		"CFP_O_IRARMY_Ural_01",
		"CFP_O_IRARMY_Ural_Ammo_01",
		"CFP_O_IRARMY_Ural_Open_01",
		"CFP_O_IRARMY_Ural_Refuel_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_IRARMY", [
		"CFP_O_IRARMY_Mi_8_01",
		"CFP_O_IRARMY_CH47_VIV_01",
		"CFP_O_IRARMY_CH47_01"
	]
] call ALIVE_fnc_hashSet;


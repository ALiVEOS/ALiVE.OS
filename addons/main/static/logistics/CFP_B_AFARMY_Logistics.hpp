// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_AFARMY", [
		"CFP_B_AFARMY_HMMWV_01",
		"CFP_B_AFARMY_MTVR_Ammo_01",
		"CFP_B_AFARMY_HMMWV_DShKM_01",
		"CFP_B_AFARMY_MTVR_Repair_01",
		"CFP_B_AFARMY_MTVR_Refuel_01",
		"CFP_B_AFARMY_MTVR_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_AFARMY", ["CFP_B_AFARMY_AmmoBox","CFP_B_AFARMY_WeaponsBox","CFP_B_AFARMY_LaunchersBox","CFP_B_AFARMY_UniformBox","CFP_B_AFARMY_SupportBox","CFP_B_AFARMY_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_AFARMY", [
		"CFP_B_AFARMY_MTVR_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_AFARMY", [
		"CFP_B_AFARMY_Mi_8MT_01",
		"CFP_B_AFARMY_UH_60M_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
[ALIVE_factionDefaultContainers, "CFP_B_AFRARMY", [
		"ALIVE_B_T_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"
	]
] call ALIVE_fnc_hashSet;


// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_KEARMY", [
		"CFP_B_KEARMY_HMMWV_Unarmed_01",
		"CFP_B_KEARMY_HMMWV_Transport_01",
		"CFP_B_KEARMY_Landrover_Transport_01",
		"CFP_B_KEARMY_M1151_Unarmed_01",
		"CFP_B_KEARMY_M1152_ECV_01",
		"CFP_B_KEARMY_Tatra_T810_Ammo_01",
		"CFP_B_KEARMY_Tatra_T810_Covered_01",
		"CFP_B_KEARMY_Tatra_T810_Fuel_01",
		"CFP_B_KEARMY_Tatra_T810_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "CFP_B_KEARMY", ["CFP_B_KEARMY_AmmoBox","CFP_B_KEARMY_WeaponsBox","CFP_B_KEARMY_LaunchersBox","CFP_B_KEARMY_UniformBox","CFP_B_KEARMY_SupportBox","CFP_B_KEARMY_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_KEARMY", [
		"CFP_B_KEARMY_Tatra_T810_Ammo_01",
		"CFP_B_KEARMY_Tatra_T810_Covered_01",
		"CFP_B_KEARMY_Tatra_T810_Fuel_01",
		"CFP_B_KEARMY_Tatra_T810_Repair_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_KEARMY", [
		"CFP_B_KEARMY_SA330_Puma_01"
	]
] call ALIVE_fnc_hashSet;


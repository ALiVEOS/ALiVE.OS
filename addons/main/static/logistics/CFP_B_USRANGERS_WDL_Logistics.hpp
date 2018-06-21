// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USRANGERS_WDL", [
		"CFP_B_USRANGERS_HEMTT_Ammo_WDL_01",
		"CFP_B_USRANGERS_HEMTT_Fuel_WDL_01",
		"CFP_B_USRANGERS_HEMTT_Repair_WDL_01",
		"CFP_B_USRANGERS_Polaris_DAGOR_WDL_01",
		"CFP_B_USRANGERS_Quad_Bike_WDL_01",
		"CFP_B_USRANGERS_M1133_MEV_Slat_WDL_01",
		"CFP_B_USRANGERS_M1133_MEV_WDL_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_USRANGERS_WDL", ["CFP_B_USRANGERS_WDL_AmmoBox","CFP_B_USRANGERS_WDL_WeaponsBox","CFP_B_USRANGERS_WDL_LaunchersBox","CFP_B_USRANGERS_WDL_UniformBox","CFP_B_USRANGERS_WDL_SupportBox","CFP_B_USRANGERS_WDL_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_USRANGERS_WDL", [
		"CFP_B_USRANGERS_HEMTT_Ammo_WDL_01",
		"CFP_B_USRANGERS_HEMTT_Fuel_WDL_01",
		"CFP_B_USRANGERS_HEMTT_Repair_WDL_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USRANGERS_WDL", [
		"CFP_B_USRANGERS_CH_47F_WDL_01",
		"CFP_B_USRANGERS_CH_47F_VIV_WDL_01"
	]
] call ALIVE_fnc_hashSet;


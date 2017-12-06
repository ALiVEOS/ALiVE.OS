// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USARMY_WDL", [
		"CFP_B_USARMY_HMMWV_Unarmed_USA",
		"CFP_B_USARMY_HMMWV_Ambulance_USA",
		"CFP_B_USARMY_HMMWV_Transport_USA",
		"CFP_B_USARMY_HMMWV_Terminal_USA",
		"CUP_B_M113_Med_USA",
		"CUP_B_M1151_WDL_USA",
		"CUP_B_M1152_WDL_USA",
		"CFP_B_USARMY_MTVR_USA",
		"CFP_B_USARMY_MTVR_Ammo_USA",
		"CFP_B_USARMY_MTVR_Refuel_USA",
		"CFP_B_USARMY_MTVR_Repair_USA"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_USARMY_WDL", [
		"CUP_USBasicAmmunitionBox_EP1",
		"CUP_USBasicWeapons_EP1",
		"CUP_USOrdnanceBox_EP1",
		"CUP_USLaunchers_EP1",
		"CUP_USSpecialWeapons_EP1",
		"CUP_USVehicleBox_EP1"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_USARMY_WDL", [
		"CFP_B_USARMY_MTVR_USA",
		"CFP_B_USARMY_MTVR_Ammo_USA",
		"CFP_B_USARMY_MTVR_Refuel_USA",
		"CFP_B_USARMY_MTVR_Repair_USA"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USARMY_WDL", [
		"CFP_B_USARMY_CH47F_USA",
		"CFP_B_USARMY_CH47F_VIV_USA",
		"CFP_B_USARMY_UH60M_US",
		"CFP_B_USARMY_UH60M_FFV_US",
		"CFP_B_USARMY_UH60M_Unarmed_US",
		"CFP_B_USARMY_UH60M_Unarmed_FFV_US"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
[ALIVE_factionDefaultContainers, "CFP_B_USARMY_WDL", [
		"ALIVE_B_T_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"
	]
] call ALIVE_fnc_hashSet;

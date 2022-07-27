// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USARMY_WDL", [
		"CUP_B_HMMWV_Unarmed_USA",
		"CUP_B_HMMWV_Ambulance_USA",
		"CUP_B_HMMWV_Transport_USA",
		"CUP_B_HMMWV_Terminal_USA",
		"CUP_B_M1151_USA",
		"CUP_B_M1152_USA",
		"CUP_B_MTVR_USA",
		"CUP_B_MTVR_Ammo_USA",
		"CUP_B_MTVR_Refuel_USA",
		"CUP_B_MTVR_Repair_USA"
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
		"CUP_B_MTVR_USA",
		"CUP_B_MTVR_Ammo_USA",
		"CUP_B_MTVR_Refuel_USA",
		"CUP_B_MTVR_Repair_USA"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USARMY_WDL", [
		"CUP_B_CH47F_USA",
		"CUP_B_CH47F_VIV_USA",
		"CUP_B_UH60M_US",
		"CUP_B_UH60M_FFV_US",
		"CUP_B_UH60M_Unarmed_US",
		"CUP_B_UH60M_Unarmed_FFV_US",
		"CUP_B_UH60M_Unarmed_FFV_MEV_US"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
[ALIVE_factionDefaultContainers, "CFP_B_USARMY_WDL", [
		"ALIVE_B_T_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"
	]
] call ALIVE_fnc_hashSet;

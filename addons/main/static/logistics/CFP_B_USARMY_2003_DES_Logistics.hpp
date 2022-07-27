// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USARMY_2003_DES", [
		"CFP_B_USARMY_2003_HMMWV_Unarmed_DES_01",
		"CFP_B_USARMY_2003_HMMWV_Ambulance_DES_01",
		"CFP_B_USARMY_2003_HMMWV_Transport_DES_01",
		"CFP_B_USARMY_2003_M113A3_DES_01",
		"CFP_B_USARMY_2003_M1151_Unarmed_DES_01",
		"CFP_B_USARMY_2003_M1152_ECV_DES_01",
		"CFP_B_USARMY_2003_MTVR_DES_01",
		"CFP_B_USARMY_2003_MTVR_Ammo_DES_01",
        "CFP_B_USARMY_2003_MTVR_Refuel_DES_01",
        "CFP_B_USARMY_2003_MTVR_Repair_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_USARMY_2003_DES", [
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
[ALIVE_factionDefaultTransport, "CFP_B_USARMY_2003_DES", [
		"CFP_B_USARMY_2003_MTVR_DES_01",
		"CFP_B_USARMY_2003_MTVR_Ammo_DES_01",
        "CFP_B_USARMY_2003_MTVR_Refuel_DES_01",
        "CFP_B_USARMY_2003_MTVR_Repair_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USARMY_2003_DES", [
		"CFP_B_USARMY_2003_CH_47F_DES_01",
        "CFP_B_USARMY_2003_CH_47F_VIV_DES_01",
        "CFP_B_USARMY_2003_UH_60M_DES_01",
        "CFP_B_USARMY_2003_UH_60M_MEV_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
[ALIVE_factionDefaultContainers, "CFP_B_USARMY_2003_DES", [
		"ALIVE_B_T_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"
	]
] call ALIVE_fnc_hashSet;
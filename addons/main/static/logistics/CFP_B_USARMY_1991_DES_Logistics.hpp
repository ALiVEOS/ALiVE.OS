// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USARMY_1991_DES", [
		"CFP_B_USARMY_1991_HMMWV_Unarmed_Des_01",
        "CFP_B_USARMY_1991_HMMWV_Ambulance_Des_01",
        "CFP_B_USARMY_1991_HMMWV_Transport_Des_01",
        "CFP_B_USARMY_1991_MTVR_Des_01",
        "CFP_B_USARMY_1991_MTVR_Ammo_Des_01",
        "CFP_B_USARMY_1991_MTVR_Refuel_Des_01",
        "CFP_B_USARMY_1991_MTVR_Repair_Des_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_USARMY_1991_DES", [
		"CFP_B_USARMY_1991_DES_AmmoBox",
		"CFP_B_USARMY_1991_DES_WeaponsBox",
		"CFP_B_USARMY_1991_DES_LaunchersBox",
		"CFP_B_USARMY_1991_DES_UniformBox",
		"CFP_B_USARMY_1991_DES_SupportBox",
		"CFP_B_USARMY_1991_DES_SupplyBox",
		"CUP_USVehicleBox_EP1"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_USARMY_1991_DES", [
		"CFP_B_USARMY_1991_MTVR_Des_01",
        "CFP_B_USARMY_1991_MTVR_Ammo_Des_01",
        "CFP_B_USARMY_1991_MTVR_Refuel_Des_01",
        "CFP_B_USARMY_1991_MTVR_Repair_Des_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USARMY_1991_DES", [
		"CFP_B_USARMY_1991_UH_60M_MEV_Des_01",
        "CFP_B_USARMY_1991_UH_60M_Des_01",
        "CFP_B_USARMY_1991_CH_47F_VIV_Des_01",
        "CFP_B_USARMY_1991_CH_47F_Des_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
[ALIVE_factionDefaultContainers, "CFP_B_USARMY_1991_DES", [
		"ALIVE_B_T_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"
	]
] call ALIVE_fnc_hashSet;
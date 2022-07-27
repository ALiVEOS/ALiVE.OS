// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USMC_DES", [
		"CFP_B_USMC_HMMWV_Unarmed_DES_01",
		"CFP_B_USMC_HMMWV_Ambulance_DES_01",
		"CUP_B_M1151_DSRT_USMC",
		"CFP_B_USMC_MTVR_DES_01",
		"CFP_B_USMC_MTVR_Ammo_DES_01",
		"CFP_B_USMC_MTVR_Refuel_DES_01",
		"CFP_B_USMC_MTVR_Repair_DES_01",
		"CFP_B_USMC_M1030_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_USMC_DES", [
		"CUP_USBasicAmmunitionBox",
		"CUP_USBasicWeaponsBox",
		"CUP_USOrdnanceBox",
		"CUP_USSpecialWeaponsBox",
		"CUP_USVehicleBox"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_USMC_DES", [
		"CFP_B_USMC_MTVR_DES_01",
		"CFP_B_USMC_MTVR_Ammo_DES_01",
		"CFP_B_USMC_MTVR_Refuel_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USMC_DES", [
		"CFP_B_USMC_CH_53E_Super_Stallion_DES_01",
		"CFP_B_USMC_CH_53E_Super_Stallion_VIV_DES_01",
		"CFP_B_USMC_MH_60S_Knighthawk_ESSS_x2_DES_01",
		"CFP_B_USMC_MH_60S_Knighthawk_ESSS_x4_DES_01",
		"CFP_B_USMC_MH_60S_Seahawk_DES_01",
		"CFP_B_USMC_MH_60S_Seahawk_FFV_DES_01",
		"CFP_B_USMC_UH_1Y_Venom_Transport_DES_01",
		"CFP_B_USMC_UH_1Y_Venom_MEV_DES_01"
	]
] call ALIVE_fnc_hashSet;

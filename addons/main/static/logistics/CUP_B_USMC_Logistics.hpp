// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USMC_DES", [
		"CUP_B_HMMWV_Unarmed_USMC",
		"CUP_B_M1151_USMC",
		"CUP_B_MTVR_USMC",
		"CUP_B_MTVR_Ammo_USMC",
		"CUP_B_MTVR_Refuel_USMC",
		"CUP_B_MTVR_Repair_USMC",
		"CUP_B_HMMWV_Ambulance_USMC"
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
		"CUP_B_MTVR_USMC",
		"CUP_B_MTVR_Ammo_USMC",
		"CUP_B_MTVR_Refuel_USMC"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USMC_DES", [
		"CUP_B_CH53E_USMC",
		"CUP_B_CH53E_VIV_USMC",
		"CUP_B_MH60L_DAP_2x_USN",
		"CUP_B_MH60L_DAP_4x_USN",
		"CUP_B_MH60S_USMC",
		"CUP_B_MH60S_FFV_USMC",
		"CUP_B_UH60S_USN",
		"CUP_B_UH1Y_MEV_USMC",
		"CUP_B_UH1Y_UNA_USMC"
	]
] call ALIVE_fnc_hashSet;

// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_GBARMY_WDL", [
		"CUP_B_BAF_Coyote_L2A1_W",
		"CUP_B_LR_Ambulance_GB_W",
		"CUP_B_LR_Transport_GB_W",
		"CUP_B_Mastiff_LMG_GB_W",
		"CUP_B_Ridgback_LMG_GB_W",
		"CUP_B_Wolfhound_LMG_GB_W"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_GBARMY_WDL", [
		"CUP_BAF_BasicWeapons","CUP_BAF_BasicAmmunitionBox","CUP_BAF_BasicWeapons","CUP_BAF_BasicAmmunitionBox","CUP_BAF_BasicWeapons","CUP_BAF_OrdnanceBox","CUP_BAF_Launchers","CUP_BAF_VehicleBox"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_GBARMY_WDL", [
		"CUP_B_Mastiff_LMG_GB_W",
		"CUP_B_Mastiff_LMG_GB_W",
		"CUP_B_Mastiff_LMG_GB_W",
		"CUP_B_Mastiff_LMG_GB_W",
		"CUP_B_Wolfhound_LMG_GB_W",
		"CUP_B_MTVR_USMC"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_GBARMY_WDL", [
		"CFP_B_GBARMY_Chinook_HC_4_WDL_01",
		"CFP_B_GBARMY_Chinook_HC_4VIV_WDL_01",
		"CFP_B_GBARMY_Merlin_HC3_WDL_01",
		"CFP_B_GBARMY_Merlin_HC3_VIV_WDL_01",
		"CFP_B_GBARMY_Merlin_HC3A_WDL_01",
		"CFP_B_GBARMY_SA_330_Puma_HC2_WDL_01",
		"CFP_B_GBARMY_SA_330_Puma_HC1_WDL_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
[ALIVE_factionDefaultContainers, "CFP_B_GBARMY_WDL", [
		"ALIVE_B_T_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"
	]
] call ALIVE_fnc_hashSet;

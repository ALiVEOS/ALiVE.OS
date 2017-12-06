// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CUP_B_GB", [
		"CUP_B_BAF_Coyote_L2A1_D",
		"CUP_B_LR_Ambulance_GB_D",
		"CUP_B_LR_Transport_GB_D",
		"CUP_B_Mastiff_LMG_GB_D",
		"CUP_B_Ridgback_LMG_GB_D",
		"CUP_B_Wolfhound_LMG_GB_D"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CUP_B_GB", [
		"CUP_BAF_BasicWeapons","CUP_BAF_BasicAmmunitionBox","CUP_BAF_BasicWeapons","CUP_BAF_BasicAmmunitionBox","CUP_BAF_BasicWeapons","CUP_BAF_OrdnanceBox","CUP_BAF_Launchers","CUP_BAF_VehicleBox"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CUP_B_GB", [
		"CUP_B_Mastiff_LMG_GB_D",
		"CUP_B_Mastiff_LMG_GB_D",
		"CUP_B_Mastiff_LMG_GB_D",
		"CUP_B_Mastiff_LMG_GB_D",
		"CUP_B_Wolfhound_LMG_GB_D",
		"CUP_B_MTVR_USMC"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CUP_B_GB", [
		"CUP_B_CH47F_GB",
		"CUP_B_CH47F_VIV_GB",
		"CUP_B_Merlin_HC3_GB",
		"CUP_B_Merlin_HC3_VIV_GB",
		"CUP_B_Merlin_HC3A_GB",
		"CUP_B_SA330_Puma_HC1_BAF",
		"CUP_B_SA330_Puma_HC2_BAF"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
[ALIVE_factionDefaultContainers, "CUP_B_GB", [
		"ALIVE_B_T_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"
	]
] call ALIVE_fnc_hashSet;

// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USSEALS_DES", [
		"CFP_B_USSEALS_ATV_DES_01",
		"CFP_B_USSEALS_Polaris_Dagor_DES_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_USSEALS_DES", ["CFP_B_USSEALS_DES_AmmoBox","CFP_B_USSEALS_DES_WeaponsBox","CFP_B_USSEALS_DES_LaunchersBox","CFP_B_USSEALS_DES_UniformBox","CFP_B_USSEALS_DES_SupportBox","CFP_B_USSEALS_DES_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_USSEALS_DES", [
	"CUP_B_MTVR_Ammo_USA",
	"CUP_B_MTVR_USA"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USSEALS_DES", [
		"CUP_B_CH47F_USA",
		"CUP_B_CH47F_VIV_USA",
		"CFP_B_USSEALS_UH_60M_DES_01"
	]
] call ALIVE_fnc_hashSet;


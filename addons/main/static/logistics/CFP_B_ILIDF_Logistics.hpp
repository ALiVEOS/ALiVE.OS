// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_ILIDF", [
	"CFP_B_ILIDF_ATV_01",
	"CFP_B_ILIDF_HEMTT_01",
	"CFP_B_ILIDF_HEMTT_Ammo_01",
	"CFP_B_ILIDF_HEMTT_Box_01",
	"CFP_B_ILIDF_HEMTT_Fuel_01",
	"CFP_B_ILIDF_HEMTT_Medical_01",
	"CFP_B_ILIDF_HEMTT_Transport_01",
	"CFP_B_ILIDF_HEMTT_Transport_Covered_01",
	"CFP_B_ILIDF_HMMWV_Unarmed_01",
	"CFP_B_ILIDF_HMMWV_Ambulance_01",
	"CFP_B_ILIDF_HMMWV_UAV_Terminal_01",
	"CFP_B_ILIDF_MDT_David_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_ILIDF", ["CFP_B_ILIDF_AmmoBox","CFP_B_ILIDF_WeaponsBox","CFP_B_ILIDF_LaunchersBox","CFP_B_ILIDF_UniformBox","CFP_B_ILIDF_SupportBox","CFP_B_ILIDF_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_ILIDF", [
		"CFP_B_ILIDF_HEMTT_Ammo_01",
		"CFP_B_ILIDF_HEMTT_Box_01",
		"CFP_B_ILIDF_HEMTT_Fuel_01",
		"CFP_B_ILIDF_HEMTT_Medical_01",
		"CFP_B_ILIDF_HEMTT_Transport_01",
		"CFP_B_ILIDF_HEMTT_Transport_Covered_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_ILIDF", [
		"CFP_B_ILIDF_CH_53_Yasur_01",
		"CFP_B_ILIDF_CH_53_Yasur_VIV_01"
	]
] call ALIVE_fnc_hashSet;


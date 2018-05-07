// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_YPG", [
	"cfp_b_ypg_offroad",
	"cfp_b_ypg_offroad_flag"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_YPG", ["CFP_B_YPG_AmmoBox","CFP_B_YPG_WeaponsBox","CFP_B_YPG_LaunchersBox","CFP_B_YPG_UniformBox","CFP_B_YPG_SupportBox","CFP_B_YPG_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_YPG", [
"cfp_b_ypg_offroad_flag"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_YPG", []
] call ALIVE_fnc_hashSet;


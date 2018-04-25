// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_O_IS", [
	"cfp_o_is_M113",
	"cfp_o_is_M113_flag",
	"cfp_o_is_Ural",
	"cfp_o_is_LR_Unarmed"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_O_IS", ["CFP_O_IS_AmmoBox","CFP_O_IS_WeaponsBox","CFP_O_IS_LaunchersBox","CFP_O_IS_UniformBox","CFP_O_IS_SupportBox","CFP_O_IS_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_O_IS", [
		"cfp_o_is_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_O_IS", [
	]
] call ALIVE_fnc_hashSet;



// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "cfp_i_IS", [
	"cfp_i_is_M113",
	"cfp_i_is_M113_flag",
	"cfp_i_is_Ural",
	"cfp_i_is_LR_Unarmed"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "cfp_i_IS", ["cfp_i_IS_AmmoBox","cfp_i_IS_WeaponsBox","cfp_i_IS_LaunchersBox","cfp_i_IS_UniformBox","cfp_i_IS_SupportBox","cfp_i_IS_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "cfp_i_IS", [
		"cfp_i_is_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "cfp_i_IS", [
	]
] call ALIVE_fnc_hashSet;
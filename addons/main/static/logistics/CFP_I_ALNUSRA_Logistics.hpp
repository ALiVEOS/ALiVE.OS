// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_I_ALNUSRA", [
		"cfp_i_alNusra_LR_Unarmed",
		"cfp_i_alNusra_offroad",
		"cfp_i_alNusra_UAZ_Unarmed",
		"cfp_i_alNusra_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */


// Copy this part to ALiVE logistics static data
[ALIVE_factionDefaultSupplies, "CFP_I_ALNUSRA", ["CFP_I_ALNUSRA_AmmoBox","CFP_I_ALNUSRA_WeaponsBox","CFP_I_ALNUSRA_LaunchersBox","CFP_I_ALNUSRA_UniformBox","CFP_I_ALNUSRA_SupportBox","CFP_I_ALNUSRA_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_I_ALNUSRA", [
		"cfp_i_alNusra_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_I_ALNUSRA", []
] call ALIVE_fnc_hashSet;


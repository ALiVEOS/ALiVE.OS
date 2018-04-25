// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_IQARMY", [
		"cfp_b_iqarmy_Ural",
		"cfp_b_iqarmy_mrap_mastiff_lmg"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_IQARMY", ["CFP_B_IQARMY_AmmoBox","CFP_B_IQARMY_WeaponsBox","CFP_B_IQARMY_LaunchersBox","CFP_B_IQARMY_UniformBox","CFP_B_IQARMY_SupportBox","CFP_B_IQARMY_SupplyBox"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_IQARMY", [
		"cfp_b_iqarmy_Ural",
		"cfp_b_iqarmy_mrap_mastiff_lmg"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_IQARMY", [
		"cfp_b_iqarmy_MI24P",
		"cfp_b_iqarmy_MI24V"
	]
] call ALIVE_fnc_hashSet;


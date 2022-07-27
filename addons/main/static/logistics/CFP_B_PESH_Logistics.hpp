// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_PESH", [
"cfp_b_pesh_Ural",
"cfp_b_pesh_offroad"
]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_PESH", ["CFP_B_PESH_AmmoBox","CFP_B_PESH_WeaponsBox","CFP_B_PESH_LaunchersBox","CFP_B_PESH_UniformBox","CFP_B_PESH_SupportBox","CFP_B_PESH_SupplyBox"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_PESH", [
"cfp_b_pesh_Ural"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_PESH", []
] call ALIVE_fnc_hashSet;


// Faction Static Data Template for ALiVE

/*
 * Mil placement ambient vehicles per faction
 */
[ALIVE_factionDefaultSupports, "CFP_B_USCIA", [
		"CFP_B_USCIA_Datsun_PK_01",
		"CFP_B_USCIA_Datsun_PK_02",
		"CFP_B_USCIA_LSV_01",
		"CFP_B_USCIA_LSV_02",
		"CFP_B_USCIA_MB_4WD_01",
		"CFP_B_USCIA_Offroad_02",
		"CFP_B_USCIA_SUV_01",
		"CFP_B_USCIA_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */
[ALIVE_factionDefaultSupplies, "CFP_B_USCIA", [
		"CFP_USCIA_BasicAmmunitionBox",
		"CFP_USCIA_BasicWeaponsBox",
		"CFP_USCIA_OrdnanceBox",
		"CFP_USCIA_LaunchersBox",
		"CFP_USCIA_SpecialWeaponsBox",
		"CFP_USCIA_VehicleBox"
	]
] call ALIVE_fnc_hashSet;


/*
 * Mil logistics convoy transport vehicles per faction
 */
[ALIVE_factionDefaultTransport, "CFP_B_USCIA", [
		"CFP_B_USCIA_Ural_01"
	]
] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */
[ALIVE_factionDefaultAirTransport, "CFP_B_USCIA", [
		"CFP_B_USCIA_UH_1H_01",
		"CFP_B_USCIA_Mi_8MT_01"
	]
] call ALIVE_fnc_hashSet;

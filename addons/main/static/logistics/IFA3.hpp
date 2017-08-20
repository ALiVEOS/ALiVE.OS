/*
 * Custom transport,support, and ammo classes for factions
 * Used by MP,MCP,ML to place support vehicles and ammo boxes
 * If no faction specific settings are found will fall back to side
 */

/*
 * Mil placement ambient vehicles per faction
 */

[ALIVE_factionDefaultSupports, "LIB_RKKA", ["LIB_Zis5v_Med","LIB_Zis6_Parm","LIB_Zis5v_Fuel","LIB_US6_Ammo","LIB_Zis5v"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_RKKA_w", ["LIB_Zis5v_w","LIB_Zis5v_med_w","LIB_Zis5v_fuel_w","LIB_Zis6_parm_w"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_NAC", ["LIB_US_NAC_GMC_Ambulance","LIB_US_NAC_GMC_Ammo","LIB_US_NAC_GMC_Fuel","LIB_US_NAC_GMC_Parm","LIB_US_NAC_Willys_MB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_US_ARMY", ["LIB_US_GMC_Ambulance","LIB_US_GMC_Ammo","IB_US_GMC_Fuel","LIB_US_GMC_Parm","LIB_US_Willys_MB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_US_RANGERS", ["LIB_US_GMC_Ambulance","LIB_US_GMC_Ammo","IB_US_GMC_Fuel","LIB_US_GMC_Parm","LIB_US_Willys_MB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_US_101AB", ["LIB_US_GMC_Ambulance","LIB_US_GMC_Ammo","IB_US_GMC_Fuel","LIB_US_GMC_Parm","LIB_US_Willys_MB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_US_82AB", ["LIB_US_GMC_Ambulance","LIB_US_GMC_Ammo","IB_US_GMC_Fuel","LIB_US_GMC_Parm","LIB_US_Willys_MB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_US_ARMY_w", ["LIB_US_GMC_Ambulance_w","LIB_US_GMC_Ammo_w","IB_US_GMC_Fuel_w","LIB_US_GMC_Parm_w","LIB_US_Willys_MB_w"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["LIB_Kfz1","LIB_Kfz1_Hood","LIB_opelblitz_ambulance","LIB_opelblitz_ammo","LIB_opelblitz_fuel","LIB_opelblitz_parm"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT_w", ["LIB_Kfz1_w","LIB_Kfz1_Hood_w","LIB_opelblitz_ambulance","LIB_opelblitz_ammo","LIB_opelblitz_fuel","LIB_opelblitz_parm"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_DAK", ["LIB_DAK_opelblitz_ambulance","LIB_DAK_opelblitz_fuel","LIB_DAK_opelblitz_parm","LIB_DAK_opelblitz_ammo","LIB_DAK_Kfz1","LIB_DAK_Kfz1_hood"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "LIB_LUFTWAFFE", ["LIB_Kfz1","LIB_Kfz1_Hood","LIB_opelblitz_ambulance"]] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["LIB_BasicAmmunitionBox_SU","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA_w", ["LIB_BasicAmmunitionBox_SU","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_NAC", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_ARMY", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_RANGERS", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_101AB", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_82AB", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_ARMY_w", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["LIB_BasicAmmunitionBox_GER","LIB_AmmoCrate_Mortar_GER","LIB_AmmoCrate_Arty_GER","LIB_BasicWeaponsBox_GER","LIB_WeaponsBox_Big_GER","LIB_4Rnd_RPzB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT_w", ["LIB_BasicAmmunitionBox_GER","LIB_AmmoCrate_Mortar_GER","LIB_AmmoCrate_Arty_GER","LIB_BasicWeaponsBox_GER","LIB_WeaponsBox_Big_GER","LIB_4Rnd_RPzB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_DAK", ["LIB_BasicAmmunitionBox_GER","LIB_AmmoCrate_Mortar_GER","LIB_AmmoCrate_Arty_GER","LIB_BasicWeaponsBox_GER","LIB_WeaponsBox_Big_GER","LIB_4Rnd_RPzB"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_LUFTWAFFE", ["LIB_BasicAmmunitionBox_GER","LIB_AmmoCrate_Mortar_GER","LIB_AmmoCrate_Arty_GER","LIB_BasicWeaponsBox_GER","LIB_WeaponsBox_Big_GER","LIB_4Rnd_RPzB"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */

[ALIVE_factionDefaultTransport, "LIB_RKKA", ["LIB_US6_Tent","LIB_US6_Open","LIB_Zis5v"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA_w", ["LIB_Us6_tent_w","LIB_Zis5v_w"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_NAC", ["LIB_US_NAC_GMC_Tent","LIB_US_NAC_GMC_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_ARMY", ["LIB_US_GMC_Tent","LIB_US_GMC_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_RANGERS", ["LIB_US_GMC_Tent","LIB_US_GMC_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_101AB", ["LIB_US_GMC_Tent","LIB_US_GMC_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_82AB", ["LIB_US_GMC_Tent","LIB_US_GMC_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_ARMY_w", ["LIB_US_GMC_Tent_w","LIB_US_GMC_Open_w"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["LIB_opelblitz_tent_y_camo","LIB_opelblitz_open_y_camo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT_w", ["LIB_opelblitz_open_y_camo_w"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_DAK", ["LIB_DAK_opelblitz_open","LIB_DAK_opelblitz_tent"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_LUFTWAFFE", ["LIB_opelblitz_tent_y_camo","LIB_opelblitz_open_y_camo"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */

[ALIVE_factionDefaultAirTransport, "LIB_RKKA", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_RKKA_w", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_NAC", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_ARMY", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_RANGERS", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_101AB", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_82AB", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_ARMY_w", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_WEHRMACHT", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_WEHRMACHT_w", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_DAK", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_LUFTWAFFE", []] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */

[ALIVE_factionDefaultContainers, "LIB_RKKA", ["ALIVE_O_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_RKKA_w", ["ALIVE_O_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_NAC", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_US_ARMY", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_US_RANGERS", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_US_101AB", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_US_82AB", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_US_ARMY_w", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_WEHRMACHT", ["ALIVE_B_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_WEHRMACHT_w", ["ALIVE_B_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_DAK", ["ALIVE_B_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "LIB_LUFTWAFFE", ["ALIVE_B_supplyCrate_F"]] call ALIVE_fnc_hashSet;
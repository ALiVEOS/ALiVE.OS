if (isnil "ALiVE_PLACEMENT_CUSTOM_UNITBLACKLIST") then {ALiVE_PLACEMENT_CUSTOM_UNITBLACKLIST = []};
if (isnil "ALiVE_PLACEMENT_CUSTOM_VEHICLEBLACKLIST") then {ALiVE_PLACEMENT_CUSTOM_VEHICLEBLACKLIST = []};
if (isnil "ALiVE_PLACEMENT_CUSTOM_GROUPBLACKLIST") then {ALiVE_PLACEMENT_CUSTOM_GROUPBLACKLIST = []};

/*
 * Mil placement / Ambient civilians / Mil logistics unit blacklist
 */

ALiVE_PLACEMENT_UNITBLACKLIST = ALiVE_PLACEMENT_CUSTOM_UNITBLACKLIST +
[
    "O_UAV_AI",
    "B_UAV_AI",
    "C_Driver_1_black_F",
    "C_Driver_1_blue_F",
    "C_Driver_1_F",
    "C_Driver_1_green_F",
    "C_Driver_1_orange_F",
    "C_Driver_1_random_base_F",
    "C_Driver_1_red_F",
    "C_Driver_1_white_F",
    "C_Driver_1_yellow_F",
    "C_Driver_2_F",
    "C_Driver_3_F",
    "C_Driver_4_F",
    "B_Soldier_VR_F",
    "O_Soldier_VR_F",
    "I_Soldier_VR_F",
    "C_Soldier_VR_F",
    "B_Protagonist_VR_F",
    "O_Protagonist_VR_F",
    "I_Protagonist_VR_F",
    "C_Marshal_F",
    "C_man_pilot_F",
    "C_Protagonist_VR_F",
    // JETS
    "B_Deck_Crew_F"
];

/*
 * Mil placement / Ambient civilians / Mil logistics vehicle blacklist
 */

ALiVE_PLACEMENT_VEHICLEBLACKLIST = ALiVE_PLACEMENT_CUSTOM_VEHICLEBLACKLIST +
[
    "O_UGV_01_F",
    "O_UGV_01_rcws_F",
    "O_Parachute_02_F",
    "B_UGV_01_F",
    "B_UGV_01_rcws_F",
    "B_Parachute_02_F",
    "I_UGV_01_F",
    "I_UGV_01_rcws_F",
    "I_Parachute_02_F",
    "Parachute",
    "Parachute_02_base_F",
    "ParachuteBase",
    "ParachuteEast",
    "ParachuteG",
    "ParachuteWest",
    "B_Parachute",
    "B_O_Parachute_02_F",
    "C_Kart_01_Blu_F",
    "C_Kart_01_F",
    "C_Kart_01_F_Base",
    "C_Kart_01_Fuel_F",
    "C_Kart_01_Red_F",
    "C_Kart_01_Vrana_F",
    "C_Kart_01_black_F",
    "C_Kart_01_white_F",
    "C_Kart_01_orange_F",
    "C_Kart_01_yellow_F",
    "C_Kart_01_green_F",
    "Steerable_Parachute_F",
    "O_UAV_01_F",
    "B_UAV_01_F",
    "I_UAV_01_F",

    // APEX
    "O_T_UGV_01_ghex_F",
    "O_T_UGV_01_rcws_ghex_F"
];

/*
 * Mil placement group blacklist
 */

ALiVE_PLACEMENT_GROUPBLACKLIST = ALiVE_PLACEMENT_CUSTOM_GROUPBLACKLIST +
[
    "HAF_AttackTeam_UAV",
    "HAF_ReconTeam_UAV",
    "HAF_AttackTeam_UGV",
    "HAF_ReconTeam_UGV",
    "HAF_SmallTeam_UAV",
    "HAF_DiverTeam",
    "HAF_DiverTeam_Boat",
    "HAF_DiverTeam_SDV",
    "BUS_AttackTeam_UAV",
    "BUS_ReconTeam_UAV",
    "BUS_AttackTeam_UGV",
    "BUS_ReconTeam_UGV",
    "BUS_SmallTeam_UAV",
    "BUS_DiverTeam",
    "BUS_DiverTeam_Boat",
    "BUS_DiverTeam_SDV",
    "OI_AttackTeam_UAV",
    "OI_ReconTeam_UAV",
    "OI_AttackTeam_UGV",
    "OI_ReconTeam_UGV",
    "OI_SmallTeam_UAV",
    "OI_diverTeam",
    "OI_diverTeam_Boat",
    "OI_diverTeam_SDV",
    "BUS_TankPlatoon_AA", // BUG in CfgGroups vehicle name wrong
    "BUS_MechInf_AA" , // BUG in CfgGroups vehicle name wrong
    // APEX
    "B_T_AttackTeam_UAV",
    "B_T_ReconTeam_UAV",
    "B_T_AttackTeam_UGV",
    "B_T_ReconTeam_UGV",
    "B_T_SmallTeam_UAV",
    "B_T_DiverTeam",
    "B_T_DiverTeam_Boat",
    "B_T_DiverTeam_SDV",
    "O_T_AttackTeam_UAV",
    "O_T_ReconTeam_UAV",
    "O_T_AttackTeam_UGV",
    "O_T_ReconTeam_UGV",
    "O_T_SmallTeam_UAV",
    "O_T_diverTeam",
    "O_T_diverTeam_Boat",
    "O_T_diverTeam_SDV"
];

/*
 * Mil placement ambient vehicles for sides
 */

ALIVE_sideDefaultSupports = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultSupports, "EAST", ["O_Truck_02_Ammo_F","O_Truck_02_box_F","O_Truck_02_fuel_F","O_Truck_02_medical_F","O_Truck_02_transport_F","O_Truck_02_covered_F"]] call ALIVE_fnc_hashSet; // ,"Box_East_AmmoVeh_F"
[ALIVE_sideDefaultSupports, "WEST", ["B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_medical_F","B_Truck_01_Repair_F","B_Truck_01_transport_F","B_Truck_01_covered_F"]] call ALIVE_fnc_hashSet; // ,"Box_IND_AmmoVeh_F"
[ALIVE_sideDefaultSupports, "GUER", ["I_Truck_02_ammo_F","I_Truck_02_box_F","I_Truck_02_fuel_F","I_Truck_02_medical_F","I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultSupports, "CIV", ["C_Van_01_box_F","C_Van_01_transport_F","C_Van_01_fuel_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil placement ambient vehicles per faction
 */

ALIVE_factionDefaultSupports = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultSupports, "OPF_F", ["O_Truck_03_repair_F","O_Truck_03_ammo_F","O_Truck_03_fuel_F","O_Truck_03_medical_F","O_Truck_02_box_F","O_Truck_02_medical_F","O_Truck_02_Ammo_F","O_Truck_02_fuel_F","O_Truck_02_covered_F","O_Truck_02_transport_F","O_Truck_03_transport_F","O_Truck_03_covered_F","O_Truck_03_device_F"]] call ALIVE_fnc_hashSet; // ,"Box_East_AmmoVeh_F"
[ALIVE_factionDefaultSupports, "OPF_G_F", ["O_G_Offroad_01_armed_F","O_G_Van_01_fuel_F","O_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "IND_F", ["I_Truck_02_ammo_F","I_Truck_02_box_F","I_Truck_02_fuel_F","I_Truck_02_medical_F","I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet; // ,"Box_IND_AmmoVeh_F"
[ALIVE_factionDefaultSupports, "BLU_F", ["B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_medical_F","B_Truck_01_Repair_F","B_Truck_01_transport_F","B_Truck_01_covered_F","B_APC_Tracked_01_CRV_F","B_Truck_01_mover_F"]] call ALIVE_fnc_hashSet; // ,"Box_NATO_AmmoVeh_F"
[ALIVE_factionDefaultSupports, "BLU_G_F", ["B_G_Van_01_fuel_F","B_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "CIV_F", ["C_Van_01_box_F","C_Van_01_transport_F","C_Van_01_fuel_F"]] call ALIVE_fnc_hashSet;

// APEX
[ALIVE_factionDefaultSupports, "OPF_T_F", ["O_T_Truck_03_repair_ghex_F","O_T_Truck_03_ammo_ghex_F","O_T_Truck_03_ghex_fuel_ghex_F","O_T_Truck_03_medical_ghex_F","O_T_Truck_03_transport_ghex_F","O_T_Truck_03_covered_ghex_F","O_T_Truck_03_device_ghex_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "IND_C_F", ["I_C_Offroad_02_unarmed_F","I_C_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "BLU_T_F", ["B_T_Truck_01_ammo_F","B_T_Truck_01_fuel_F","B_T_Truck_01_medical_F","B_T_Truck_01_Repair_F","B_T_Truck_01_transport_F","B_T_Truck_01_covered_F","B_T_APC_Tracked_01_CRV_F","B_T_Truck_01_mover_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "Gendarmerie", ["B_GEN_Offroad_01_gen_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "BLU_CTRG_F", ["B_T_Truck_01_ammo_F","B_T_Truck_01_fuel_F","B_T_Truck_01_medical_F","B_T_Truck_01_Repair_F","B_T_Truck_01_transport_F","B_T_Truck_01_covered_F","B_T_APC_Tracked_01_CRV_F","B_T_Truck_01_mover_F","B_CTRG_LSV_01_light_F"]] call ALIVE_fnc_hashSet;


/*
 * Mil placement random supply boxes for sides
 */

ALIVE_sideDefaultSupplies = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultSupplies, "EAST", ["Box_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Grenades_F","Box_East_Support_F","Box_East_Wps_F","Box_East_WpsLaunch_F","Box_East_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultSupplies, "WEST", ["Box_NATO_Ammo_F","Box_NATO_AmmoOrd_F","Box_NATO_Grenades_F","Box_NATO_Support_F","Box_NATO_Wps_F","Box_NATO_WpsLaunch_F","Box_NATO_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultSupplies, "GUER", ["Box_IND_Ammo_F","Box_IND_AmmoOrd_F","Box_IND_Grenades_F","Box_IND_Support_F","Box_IND_Wps_F","Box_IND_WpsLaunch_F","Box_IND_WpsSpecial_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

ALIVE_factionDefaultSupplies = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultSupplies, "OPF_F", ["Box_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Grenades_F","Box_East_Support_F","Box_East_Wps_F","Box_East_WpsLaunch_F","Box_East_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "OPF_G_F", ["Box_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Grenades_F","Box_East_Support_F","Box_East_Wps_F","Box_East_WpsLaunch_F","Box_East_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "IND_F", ["Box_IND_Ammo_F","Box_IND_AmmoOrd_F","Box_IND_Grenades_F","Box_IND_Support_F","Box_IND_Wps_F","Box_IND_WpsLaunch_F","Box_IND_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "BLU_F", ["Box_NATO_Ammo_F","Box_NATO_AmmoOrd_F","Box_NATO_Grenades_F","Box_NATO_Support_F","Box_NATO_Wps_F","Box_NATO_WpsLaunch_F","Box_NATO_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "BLU_G_F", ["Box_IND_Ammo_F","Box_IND_AmmoOrd_F","Box_IND_Grenades_F","Box_IND_Support_F","Box_IND_Wps_F","Box_IND_WpsLaunch_F","Box_IND_WpsSpecial_F"]] call ALIVE_fnc_hashSet;

// APEX
[ALIVE_factionDefaultSupplies, "OPF_T_F", ["Box_T_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Grenades_F","Box_East_Support_F","Box_T_East_Wps_F","Box_East_WpsLaunch_F","Box_T_East_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "IND_C_F", ["Box_Syndicate_Ammo_F","Box_IND_AmmoOrd_F","Box_IND_Grenades_F","Box_IND_Support_F","Box_Syndicate_Wps_F","Box_Syndicate_WpsLaunch_F","Box_IND_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "Gendarmerie", ["Box_GEN_Equip_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "BLU_T_F", ["Box_NATO_Ammo_F","Box_NATO_AmmoOrd_F","Box_NATO_Grenades_F","Box_NATO_Support_F","Box_T_NATO_Wps_F","Box_NATO_WpsLaunch_F","Box_T_NATO_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "BLU_CTRG_F", ["Box_NATO_Ammo_F","Box_NATO_AmmoOrd_F","Box_NATO_Grenades_F","Box_NATO_Support_F","Box_T_NATO_Wps_F","Box_NATO_WpsLaunch_F","Box_T_NATO_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
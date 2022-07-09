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
    "B_Deck_Crew_F",

    // VN
    "vn_b_men_jetpilot_07",
    "vn_b_men_aircrew_13",
    "vn_b_men_aircrew_09",
    "vn_b_men_aircrew_16",
    "vn_b_men_aircrew_12",
    "vn_b_men_aircrew_15",
    "vn_b_men_aircrew_11",
    "vn_b_men_jetpilot_08",
    "vn_b_men_aircrew_14",
    "vn_b_men_aircrew_10",
    "vn_b_men_jetpilot_01",
    "vn_b_men_jetpilot_09",
    "vn_b_men_aircrew_01",
    "vn_b_men_aircrew_04",
    "vn_b_men_aircrew_03",
    "vn_b_men_jetpilot_02",
    "vn_b_men_jetpilot_10",
    "vn_b_men_aircrew_02",
    "vn_b_men_aircrew_01",
    "vn_b_men_jetpilot_05",
    "vn_b_men_jetpilot_03",
    "vn_b_men_aircrew_21",
    "vn_b_men_navy_06",
    "vn_b_men_navy_05",
    "vn_b_men_aircrew_24",
    "vn_b_men_aircrew_23",
    "vn_b_men_navy_03",
    "vn_b_men_jetpilot_06",
    "vn_b_men_jetpilot_04",
    "vn_b_men_aircrew_22",
    "vn_b_men_navy_02",
    "vn_b_men_navy_01",
    "vn_b_men_army_30",
    "vn_b_men_army_31",
    "vn_b_men_aircrew_25",
    "vn_b_men_aircrew_26",
    "vn_b_men_army_25",
    "vn_b_men_army_24",
    "vn_b_men_army_23",
    "vn_b_men_aircrew_07",
    "vn_b_men_army_13",
    "vn_b_men_army_26",
    "vn_b_men_army_14",
    "vn_b_men_aircrew_06",
    "vn_b_men_aircrew_17",
    "vn_b_men_aircrew_20",
    "vn_b_men_aircrew_19",
    "vn_b_men_aircrew_18",
    "vn_o_men_aircrew_06",
    "vn_o_men_aircrew_05",
    "vn_o_men_aircrew_08",
    "vn_o_men_aircrew_07",
    "vn_o_men_aircrew_01",
    "vn_o_men_aircrew_04",
    "vn_o_men_aircrew_03",
    "vn_o_men_aircrew_02",
    "vn_b_men_aircrew_38",
    "vn_b_men_aircrew_39",
    "vn_b_men_aircrew_40",
    "vn_b_men_aircrew_37",
    "vn_b_men_aircrew_32",
    "vn_b_men_aircrew_33",
    "vn_b_men_aircrew_34",
    "vn_b_men_aircrew_31",
    "vn_b_men_aircrew_28",
    "vn_b_men_aircrew_29",
    "vn_b_men_aircrew_30",
    "vn_b_men_aircrew_27",
    "vn_b_men_aus_army_66_14",
    "vn_b_men_aus_army_66_13",
    "vn_b_men_aus_army_66_23",
    "vn_b_men_aus_army_66_24",
    "vn_b_men_aus_army_66_25",
    "vn_b_men_aus_army_68_14",
    "vn_b_men_aus_army_68_13",
    "vn_b_men_aus_army_70_14",
    "vn_b_men_aus_army_70_13",
    "vn_b_men_aus_army_70_23",
    "vn_b_men_aus_army_70_24",
    "vn_b_men_aus_army_70_25",
    "vn_b_men_nz_army_66_21",
    "vn_b_men_nz_army_66_22",
    "vn_b_men_rok_army_65_29",
    "vn_b_men_rok_army_65_31",
    "vn_b_men_rok_army_65_30",
    "vn_b_men_rok_army_65_26",
    "vn_b_men_rok_army_65_14",
    "vn_b_men_rok_army_65_13",
    "vn_b_men_rok_army_68_14",
    "vn_b_men_rok_army_68_13",
    "vn_b_men_rok_army_68_23",
    "vn_b_men_rok_army_68_24",
    "vn_b_men_rok_army_68_25",
    "vn_b_men_rok_army_68_29",
    "vn_b_men_rok_army_68_30",
    "vn_b_men_rok_army_68_26",
    "vn_b_men_rok_marine_65_14",
    "vn_b_men_rok_marine_65_13",
    "vn_b_men_rok_marine_65_29",
    "vn_b_men_rok_marine_65_31",
    "vn_b_men_rok_marine_65_30",
    "vn_b_men_rok_marine_68_14",
    "vn_b_men_rok_marine_68_13",
    "vn_b_men_rok_marine_68_29",
    "vn_b_men_rok_marine_68_31",
    "vn_b_men_rok_marine_68_30",
    "vn_i_men_rla_14",
    "vn_i_men_rla_13",
    "vn_i_men_rla_25",
    "vn_i_men_rla_24",
    "vn_i_men_rla_23",
    "vn_o_men_pl_18",
    "vn_o_men_pl_20",
    "vn_o_men_pl_19"
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
    "O_T_UGV_01_rcws_ghex_F",

    // CDLC
    "vn_b_air_f4b_ejection_seat_01"
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
    "BUS_MechInf_AA", // BUG in CfgGroups vehicle name wrong

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
    "O_T_diverTeam_SDV",

    //VN
    // aircraft crews and boat groups
    "vn_b_group_men_cobra_01",
    "vn_b_group_men_cobra_02",
    "vn_b_group_men_cobra_03",
    "vn_b_group_men_plane_01", "vn_b_group_men_plane_02", "vn_b_group_men_plane_03","vn_b_group_men_plane_04","vn_b_group_men_plane_05", "vn_b_group_men_plane_06",
    "vn_b_group_men_uh1_01", "vn_b_group_men_uh1_02", "vn_b_group_men_uh1_03","vn_b_group_men_uh1_04","vn_b_group_men_uh1_05", "vn_b_group_men_uh1_06",
    "vn_b_group_motor_army_07",
    "vn_b_group_mech_army_03", "vn_b_group_mech_army_04", "vn_b_group_mech_army_05", "vn_b_group_mech_army_06",
    "vn_b_group_boat_01", "vn_b_group_boat_02",
    "vn_b_group_men_navy_01",

    "vn_b_group_men_army_05", // tank crew
    "vn_b_group_men_army_06", // tunnel rats
    "vn_b_group_men_army_07", // artillery gun crew
    "vn_b_group_men_army_09", // vehicle crew

    "vn_o_group_boat_01","vn_o_group_boat_02",
    "vn_o_group_mech_nva_02","vn_o_group_mech_nva_03","vn_o_group_mech_nva_04","vn_o_group_mech_nva_05",
    "vn_o_group_mech_nva_65_02","vn_o_group_mech_nva_65_03","vn_o_group_mech_nva_65_04","vn_o_group_mech_nva_65_05",
    "vn_o_group_mech_nvam_02","vn_o_group_mech_nvam_03","vn_o_group_mech_nvam_04","vn_o_group_mech_nvam_05",
    "vn_o_group_men_nva_05", // tank crew
    "vn_o_group_men_nva_08", // vehicle crew
    "vn_o_group_men_nva_navy_01",
    "vn_o_group_men_nva_navy_02",
    "vn_o_group_men_vpaf_01","vn_o_group_men_vpaf_02","vn_o_group_men_vpaf_03",
    "vn_o_group_motor_nva_07",
    "vn_o_group_motor_nva_65_07",
    "vn_o_group_motor_nvam_07",

    "vn_o_group_boat_vcmf_02","vn_o_group_boat_vcmf_03", "vn_o_group_boat_vcmf_04", "vn_o_group_boat_vcmf_05", "vn_o_group_boat_vcmf_06",
    "vn_o_group_mech_vcmf_02", "vn_o_group_mech_vcmf_03", "vn_o_group_mech_vcmf_04", "vn_o_group_mech_vcmf_05",
    "vn_o_group_motor_vcmf_07",

    "vn_i_group_mech_army_03", "vn_i_group_mech_army_04",
    "vn_i_group_men_ch34_01",
    "vn_i_group_men_plane_01",
    "vn_i_group_men_uh1_01",
    "vn_i_group_motor_army_07",
    "vn_i_group_men_army_05",
    "vn_i_group_men_army_09"

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

// VN CDLC Default Supports
[ALIVE_factionDefaultSupports, "O_PAVN", [
    "vn_o_bicycle_02",
    "vn_o_wheeled_btr40_02",
    "vn_o_wheeled_btr40_01",
    "vn_o_wheeled_z157_ammo",
    "vn_o_wheeled_z157_fuel",
    "vn_o_wheeled_z157_repair",
    "vn_o_wheeled_z157_02",
    "vn_o_wheeled_z157_01"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "O_VC", [
    "vn_o_bicycle_02_vcmf",
    "vn_o_wheeled_btr40_02_vcmf",
    "vn_o_wheeled_btr40_01_vcmf",
    "vn_o_wheeled_z157_ammo_vcmf",
    "vn_o_wheeled_z157_fuel_vcmf",
    "vn_o_wheeled_z157_01_vcmf",
    "vn_o_wheeled_z157_repair_vcmf",
    "vn_o_wheeled_z157_02_vcmf"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "O_PL", [
    "vn_o_bicycle_01_pl",
    "vn_o_bicycle_02_pl",
    "vn_o_wheeled_btr40_mg_02_pl",
    "vn_o_wheeled_btr40_02_pl",
    "vn_o_wheeled_btr40_01_pl",
    "vn_o_wheeled_z157_ammo_pl",
    "vn_o_wheeled_z157_fuel_pl",
    "vn_o_wheeled_z157_repair_pl",
    "vn_o_wheeled_z157_02_pl",
    "vn_o_wheeled_z157_01_pl"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "I_ARVN", [
    "vn_i_wheeled_m54_03",
    "vn_i_wheeled_m151_01",
    "vn_i_wheeled_m151_02",
    "vn_i_wheeled_m151_02_mp",
    "vn_i_wheeled_m151_01_mp",
    "vn_i_wheeled_m54_repair",
    "vn_i_wheeled_m54_fuel",
    "vn_i_wheeled_m54_ammo",
    "vn_i_wheeled_m54_01",
    "vn_i_wheeled_m54_02"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "I_LAO", [
    "vn_i_wheeled_m54_fuel_rla",
    "vn_i_wheeled_m54_ammo_rla",
    "vn_i_wheeled_m151_02_rla",
    "vn_i_wheeled_m151_01_rla",
    "vn_i_wheeled_m54_03_rla",
    "vn_i_wheeled_m54_repair_rla",
    "vn_i_wheeled_m54_01_rla",
    "vn_i_wheeled_m54_02_rla"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "B_MACV", [
    "vn_b_wheeled_m151_01",
    "vn_b_wheeled_m54_01_sog",
    "vn_b_wheeled_m151_02",
    "vn_b_wheeled_m151_02_mp",
    "vn_b_wheeled_m151_01_mp",
    "vn_b_wheeled_m54_repair",
    "vn_b_wheeled_m54_fuel",
    "vn_b_wheeled_m54_ammo",
    "vn_b_wheeled_m54_01",
    "vn_b_wheeled_m54_02_sog",
    "vn_b_wheeled_m54_02"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "B_AUS", [
    "vn_b_wheeled_m54_03_aus_army",
    "vn_b_wheeled_m151_01_aus_army",
    "vn_b_wheeled_m151_02_aus_army",
    "vn_b_wheeled_m54_repair_aus_army",
    "vn_b_wheeled_m54_fuel_aus_army",
    "vn_b_wheeled_m54_ammo_aus_army",
    "vn_b_wheeled_m54_01_aus_army",
    "vn_b_wheeled_m54_02_aus_army"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "B_NZ", [
    "vn_b_wheeled_m54_03_nz_army",
    "vn_b_wheeled_m151_01_nz_army",
    "vn_b_wheeled_m151_02_nz_army",
    "vn_b_wheeled_m54_repair_nz_army",
    "vn_b_wheeled_m54_fuel_nz_army",
    "vn_b_wheeled_m54_ammo_nz_army",
    "vn_b_wheeled_m54_01_nz_army",
    "vn_b_wheeled_m54_02_nz_army"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "B_ROK", [
    "vn_b_wheeled_m54_03_rok_army",
    "vn_b_wheeled_m151_01_rok_army",
    "vn_b_wheeled_m151_02_rok_army",
    "vn_b_wheeled_m54_repair_rok_army",
    "vn_b_wheeled_m54_fuel_rok_army",
    "vn_b_wheeled_m54_ammo_rok_army",
    "vn_b_wheeled_m54_01_rok_army",
    "vn_b_wheeled_m54_02_rok_army"
]] call ALIVE_fnc_hashSet;

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

// VN CDLC
[ALIVE_factionDefaultSupplies, "O_PAVN", [
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_kit_nva",
    "vn_o_ammobox_full_01",
    "vn_o_ammobox_full_03",
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_04",
    "vn_o_ammobox_full_08"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "O_VC", [
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_01",
    "vn_o_ammobox_full_03",
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_04",
    "vn_o_ammobox_full_05"
]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultSupplies, "O_PL", [
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_01",
    "vn_o_ammobox_full_03",
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_04",
    "vn_o_ammobox_full_11"
]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultSupplies, "I_ARVN", [
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_supply_01",
    "vn_b_ammobox_full_01",
    "vn_b_ammobox_full_10",
    "vn_b_ammobox_full_03",
    "vn_b_ammobox_full_02",
    "vn_b_ammobox_full_04",
    "vn_b_ammobox_full_09"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "I_LAO", [
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_supply_01",
    "vn_b_ammobox_full_01",
    "vn_b_ammobox_full_10",
    "vn_b_ammobox_full_03",
    "vn_b_ammobox_full_02",
    "vn_b_ammobox_full_04",
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_full_25",
    "vn_b_ammobox_full_20"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "B_MACV", [
    "vn_b_ammobox_supply_01",
    "vn_b_ammobox_full_01",
    "vn_b_ammobox_full_10",
    "vn_b_ammobox_full_03",
    "vn_b_ammobox_full_02",
    "vn_b_ammobox_full_04",
    "vn_b_ammobox_kit_sog",
    "vn_b_ammobox_full_09"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "B_AUS", [
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_supply_01",
    "vn_b_ammobox_full_01",
    "vn_b_ammobox_full_10",
    "vn_b_ammobox_full_03",
    "vn_b_ammobox_full_02",
    "vn_b_ammobox_full_04",
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_full_23",
    "vn_b_ammobox_full_22",
    "vn_b_ammobox_full_16"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "B_NZ", [
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_supply_01",
    "vn_b_ammobox_full_01",
    "vn_b_ammobox_full_10",
    "vn_b_ammobox_full_03",
    "vn_b_ammobox_full_02",
    "vn_b_ammobox_full_04",
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_full_17"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "B_ROK", [
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_supply_01",
    "vn_b_ammobox_full_01",
    "vn_b_ammobox_full_10",
    "vn_b_ammobox_full_03",
    "vn_b_ammobox_full_02",
    "vn_b_ammobox_full_04",
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_full_24",
    "vn_b_ammobox_full_19"
]] call ALIVE_fnc_hashSet;
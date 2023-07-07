if (isnil "ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES") then {ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES = []};
if (isnil "ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST") then {ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST = []};
if (isnil "ALiVE_MIL_CQB_CUSTOM_STRATEGICPLATFORMS") then {ALiVE_MIL_CQB_CUSTOM_STRATEGICPLATFORMS = []};
/*
 * CQB houses
 */

ALiVE_MIL_CQB_STRATEGICHOUSES = ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES +
[
    //A3
    "Land_Cargo_Patrol_V1_F",
    "Land_Cargo_Patrol_V2_F",
    "Land_Cargo_House_V1_F",
    "Land_Cargo_House_V2_F",
    "Land_Cargo_Tower_V3_F",
    "Land_Airport_Tower_F",
    "Land_Cargo_HQ_V1_F",
    "Land_Cargo_HQ_V2_F",
    "Land_MilOffices_V1_F",
    "Land_Offices_01_V1_F",
    "Land_Research_HQ_F",
    "Land_CarService_F",
    "Land_Hospital_main_F",
    "Land_dp_smallFactory_F",
    "Land_Radar_F",
    "Land_TentHangar_V1_F",

    //A2
    "Land_A_TVTower_Base",
    "Land_Dam_ConcP_20",
    "Land_Ind_Expedice_1",
    "Land_Ind_SiloVelke_02",
    "Land_Mil_Barracks",
    "Land_Mil_Barracks_i",
    "Land_Mil_Barracks_L",
    "Land_Mil_Guardhouse",
    "Land_Mil_House",
    "Land_Fort_Watchtower",
    "Land_Vysilac_FM",
    "Land_SS_hangar",
    "Land_telek1",
    "Land_vez",
    "Land_A_FuelStation_Shed",
    "Land_watertower1",
    "Land_trafostanica_velka",
    "Land_Ind_Oil_Tower_EP1",
    "Land_A_Villa_EP1",
    "Land_fortified_nest_small_EP1",
    "Land_Mil_Barracks_i_EP1",
    "Land_fortified_nest_big_EP1",
    "Land_Fort_Watchtower_EP1",
    "Land_Ind_PowerStation_EP1",
    "Land_Ind_PowerStation",

    // VN - CDLC S.O.G Prairie Fire 1.3
    "Land_vn_b_tower_01",
    "Land_vn_pillboxbunker_01_big_f",
    "Land_vn_hut_tower_03",
    "Land_vn_hut_tower_02",
    "Land_vn_hut_tower_01",
    "Land_vn_guardtower_01_f",
    "Land_vn_guardtower_02_f",
    "Land_vn_guardtower_04_f",
    "Land_WaterTower_01_F",
    "Land_vn_fuelstation_shed_f",
    "Land_vn_pillboxbunker_02_hex_f",
    "Land_vn_dp_bigtank_f",
    "Land_vn_tower_signal_01",
    "Land_vn_mobileradar_01_radar_f",
    "Land_vn_bunker_small_01",
    "Land_vn_b_trench_firing_01",
    "Land_vn_b_trench_bunker_01_01",
    "Land_vn_b_trench_firing_05",
    "Land_vn_b_trench_bunker_04_01",
    "Land_vn_tropo_antenna_01",
    "Land_vn_airport_01_controltower_f",
    "Land_vn_o_tower_03",
    "Land_vn_o_tower_02",
    "Land_vn_o_tower_01",
    "Land_vn_o_bunker_02",
    "Land_vn_o_platform_06",
    "Land_vn_hut_tower_02",
    "Land_vn_o_shelter_01",
    "Land_vn_cave_01",
    "Land_vn_cave_01_01",
    "Land_vn_cave_02",
    "Land_vn_cave_02_01",
    "Land_vn_cave_03",
    "Land_vn_cave_03_01",
    "Land_vn_cave_04",
    "Land_vn_cave_04_01",
    "Land_vn_cave_05",
    "Land_vn_cave_06",
    "Land_vn_cave_07",
    "Land_vn_o_platform_01",
    "Land_vn_o_platform_02",
    "Land_vn_o_platform_03",
    "Land_vn_o_snipertree_01",
    "Land_vn_o_snipertree_04",
    "Land_vn_o_snipertree_02",
    "Land_vn_o_snipertree_03",
    
    // SPE
    "Land_SPE_US_Tent",
    "Land_SPE_Guardbox",
    "Land_SPE_Tent_01",
    "Land_SPE_Tent_02",
    "Land_SPE_Tent_03",
    "Land_SPE_German_Tent",
    "Land_SPE_German_Tent_Oak",
    "Land_SPE_Barn_01",
    "Land_SPE_Barn_Thatch_01",
    "Land_SPE_Barn_Thatch_02",
    "Land_SPE_A3_barn_01_brown",
    "Land_SPE_A3_barn_01_grey",
    "Land_SPE_Church_BellTower_01",
    "Land_SPE_Church_BellTower_02",
    "Land_SPE_Church_BellTower_03",
    "Land_SPE_Windmill" 
];

/*
 * CQB unit blacklist
 */

ALiVE_MIL_CQB_UNITBLACKLIST = ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST +
[
    //A3
    "B_Helipilot_F",
    "B_diver_F",
    "B_diver_TL_F",
    "B_diver_exp_F",
    "B_RangeMaster_F",
    "B_crew_F",
    "B_Pilot_F",
    "B_helicrew_F",

    "O_helipilot_F",
    "O_diver_F",
    "O_diver_TL_F",
    "O_diver_exp_F",
    "O_crew_F",
    "O_Pilot_F",
    "O_helicrew_F",
    "O_UAV_AI",

    "I_crew_F",
    "I_helipilot_F",
    "I_helicrew_F",
    "I_diver_F",
    "I_diver_exp_F",
    "I_diver_TL_F",
    "I_pilot_F",
    "I_Story_Colonel_F",

    "B_Soldier_VR_F",
    "O_Soldier_VR_F",
    "I_Soldier_VR_F",
    "C_Soldier_VR_F",
    "B_Protagonist_VR_F",
    "O_Protagonist_VR_F",
    "I_Protagonist_VR_F",

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
    "C_Marshal_F",
    "C_man_pilot_F",

     //APEX
    "B_T_Crew_F",
    "B_T_Pilot_F",
    "B_T_Helicrew_F",
    "B_T_Diver_F",
    "B_T_Diver_TL_F",
    "B_T_Diver_exp_F",
    "B_UAV_AI",
    "B_CTRG_Miller_F",
    "O_T_Helipilot_F",
    "O_T_Diver_F",
    "O_T_Diver_TL_F",
    "O_T_Diver_exp_F",
    "O_T_Crew_F",
    "O_T_Pilot_F",
    "O_T_Helicrew_F",
    "I_C_Helipilot_F",
    "I_C_Pilot_F",
    "I_C_Soldier_Camo_F",

    // JETS
    "B_Deck_Crew_F",

    // VN - CDLC S.O.G Prairie Fire 1.3
    "vn_b_men_aircrew_01",
    "vn_b_men_aircrew_02",
    "vn_b_men_aircrew_03",
    "vn_b_men_aircrew_04",
    "vn_b_men_aircrew_05",
    "vn_b_men_aircrew_06",
    "vn_b_men_aircrew_07",
    "vn_b_men_aircrew_08",
    "vn_b_men_aircrew_09",
    "vn_b_men_aircrew_10",
    "vn_b_men_aircrew_11",
    "vn_b_men_aircrew_12",
    "vn_b_men_aircrew_13",
    "vn_b_men_aircrew_14",
    "vn_b_men_aircrew_15",
    "vn_b_men_aircrew_16",
    "vn_b_men_aircrew_17",
    "vn_b_men_aircrew_18",
    "vn_b_men_aircrew_19",
    "vn_b_men_aircrew_20",
    "vn_b_men_aircrew_21",
    "vn_b_men_aircrew_22",
    "vn_b_men_aircrew_23",
    "vn_b_men_aircrew_24",
    "vn_b_men_aircrew_25",
    "vn_b_men_aircrew_26",
    "vn_b_men_aircrew_27",
    "vn_b_men_aircrew_28",
    "vn_b_men_aircrew_29",
    "vn_b_men_aircrew_30",
    "vn_b_men_aircrew_31",
    "vn_b_men_aircrew_32",
    "vn_b_men_aircrew_33",
    "vn_b_men_aircrew_34",
    "vn_b_men_aircrew_35",
    "vn_b_men_aircrew_36",
    "vn_b_men_aircrew_37",
    "vn_b_men_aircrew_38",
    "vn_b_men_aircrew_39",
    "vn_b_men_aircrew_40",
    "vn_b_men_aircrew_41",
    "vn_b_men_aircrew_42",
    "vn_b_men_aircrew_43",
    "vn_b_men_aircrew_44",
    "vn_b_men_aircrew_45",
    "vn_b_men_aircrew_46",
    "vn_b_men_aircrew_47",
    "vn_b_men_aircrew_48",
    "vn_b_men_aircrew_49",
    "vn_b_men_aircrew_50",
    "vn_b_men_army_13", // Crew (Driver)
    "vn_b_men_army_14", // Crew (Commander)
    "vn_b_men_army_22", // Military Policeman
    "vn_b_men_army_23", // Crewman (Commander)
    "vn_b_men_army_24", // Crewman (Driver)
    "vn_b_men_army_25", // Crewman (Gunner)
    "vn_b_men_army_26", // Tunnel Rat
    "vn_b_men_army_29", // Gun crew (Chief of Smoke)
    "vn_b_men_army_30", // Gun crew (Swabber)
    "vn_b_men_army_31", // Gun crew (Rammer)
    "vn_b_men_aus_army_66_13", // Crewman (APC Driver)
    "vn_b_men_aus_army_66_14", // Crewman (APC Commander)
    "vn_b_men_aus_army_66_23", // Crewman (Tank Commander)
    "vn_b_men_aus_army_66_24", // Crewman (Tank Driver)
    "vn_b_men_aus_army_66_25", // Crewman (Tank Gunner)
    "vn_b_men_aus_army_66_26", // Gun Crew (Bombardier)
    "vn_b_men_aus_army_66_27", // Gun Crew (Gunner)
    "vn_b_men_aus_army_68_13", // Crewman (APC Driver)
    "vn_b_men_aus_army_68_14", // Crewman (APC Commander)
    "vn_b_men_aus_army_70_13", // Crewman (APC Driver)
    "vn_b_men_aus_army_70_14", // Crewman (APC Commander)
    "vn_b_men_aus_army_70_23", // Crewman (Tank Commander)
    "vn_b_men_aus_army_70_24", // Crewman (Tank Driver)
    "vn_b_men_aus_army_70_25", // Crewman (Tank Gunner)
    "vn_b_men_aus_army_70_26", // Gun Crew (Bombardier)
    "vn_b_men_aus_army_70_27", // Gun Crew (Gunner)
    "vn_b_men_jetpilot_01", // Pilot (Wolfpack)
    "vn_b_men_jetpilot_02", // Copilot (Wolfpack)
    "vn_b_men_jetpilot_03", // Pilot (Sundowners)
    "vn_b_men_jetpilot_04", // Copilot (Sundowners)
    "vn_b_men_jetpilot_05", // Pilot (VA196)
    "vn_b_men_jetpilot_06", // Copilot (VA196)
    "vn_b_men_jetpilot_07", // Pilot (VM121)
    "vn_b_men_jetpilot_08", // Copilot (VM121)
    "vn_b_men_jetpilot_09", // Pilot (Hobo)
    "vn_b_men_jetpilot_10", // Copilot (Hobo)
    "vn_b_men_jetpilot_11", // Pilot (Tiger)
    "vn_b_men_jetpilot_12", // Pilot (Khaki)
    "vn_b_men_navy_01", // Captain
    "vn_b_men_navy_02", // Bosun
    "vn_b_men_navy_03", // Corpsman
    "vn_b_men_navy_04", // Stoker
    "vn_b_men_navy_05", // Gunner
    "vn_b_men_navy_06", // Gunner 2
    "vn_b_men_navy_07", // Mate
    "vn_b_men_navy_08", // RTO
    "vn_b_men_navy_09", // Lookout
    "vn_b_men_nz_army_66_21", // Gun Crew (Bombardier)
    "vn_b_men_nz_army_66_22", // Gun Crew (Gunner)
    "vn_b_men_rok_army_65_13", // Crew (Driver)
    "vn_b_men_rok_army_65_14", // Crew (Commander)
    "vn_b_men_rok_army_65_26", // Tunnel Rat
    "vn_b_men_rok_army_65_29", // Gun crew (Chief of Smoke)
    "vn_b_men_rok_army_65_30", // Gun crew (Swabber)
    "vn_b_men_rok_army_65_31", // Gun crew (Rammer)
    "vn_b_men_rok_army_68_13", // Crew (Driver)
    "vn_b_men_rok_army_68_14", // Crew (Commander)
    "vn_b_men_rok_army_68_23", // Crewman (Commander)
    "vn_b_men_rok_army_68_24", // Crewman (Driver)
    "vn_b_men_rok_army_68_25", // Crewman (Gunner)
    "vn_b_men_rok_army_68_26", // Tunnel Rat
    "vn_b_men_rok_army_68_29", // Gun crew (Chief of Smoke)
    "vn_b_men_rok_army_68_30", // Gun crew (Swabber)
    "vn_b_men_rok_army_68_31", // Gun crew (Rammer)
    "vn_b_men_rok_marine_65_13", // Crew (Driver)
    "vn_b_men_rok_marine_65_14", // Crew (Commander)
    "vn_b_men_rok_marine_65_29", // Gun crew (Chief of Smoke)
    "vn_b_men_rok_marine_65_30", // Gun crew (Swabber)
    "vn_b_men_rok_marine_65_31", // Gun crew (Rammer)
    "vn_b_men_rok_marine_68_13", // Crew (Driver)
    "vn_b_men_rok_marine_68_14", // Crew (Commander)
    "vn_b_men_rok_marine_68_29", // Gun crew (Chief of Smoke)
    "vn_b_men_rok_marine_68_30", // Gun crew (Swabber)
    "vn_b_men_rok_marine_68_31", // Gun crew (Rammer)
    "vn_b_men_seal_28", // Diver 1
    "vn_b_men_seal_29", // Diver 2
    "vn_b_men_seal_30", // Diver 3
    "vn_b_men_seal_31", // Diver 4
    "vn_b_men_seal_32", // Diver 5
    "vn_b_men_seal_33", // Diver 6
    "vn_b_men_seal_34", // Diver 7
    "vn_b_men_seal_35", // Diver 8
    "vn_b_men_seal_36", // Diver 9
    "vn_b_men_usmc_66_13", // Crew (Driver)
    "vn_b_men_usmc_66_23", // Crewman (Commander)
    "vn_b_men_usmc_66_24", // Crewman (Driver)
    "vn_b_men_usmc_66_25", // Crewman (Gunner)
    "vn_b_men_usmc_66_26", // Gun crew (Chief of Smoke)
		"vn_b_men_usmc_66_27", // Gun crew (Swabber)
		"vn_b_men_usmc_66_28", // Gun crew (Rammer)
		"vn_b_men_usmc_68_13", // Crew (Driver)
		"vn_b_men_usmc_68_23", // Crewman (Commander)
		"vn_b_men_usmc_68_24", // Crewman (Driver)
		"vn_b_men_usmc_68_25", // Crewman (Gunner)
		"vn_b_men_usmc_68_26", // Gun crew (Chief of Smoke)
		"vn_b_men_usmc_68_27", // Gun crew (Swabber)
		"vn_b_men_usmc_68_28", // Gun crew (Rammer)
		"vn_b_men_usmc_70_13", // Crew (Driver)
		"vn_b_men_usmc_70_23", // Crewman (Commander)
		"vn_b_men_usmc_70_24", // Crewman (Driver)
		"vn_b_men_usmc_70_25", // Crewman (Gunner)
		"vn_b_men_usmc_70_26", // Gun crew (Chief of Smoke)
		"vn_b_men_usmc_70_27", // Gun crew (Swabber)
		"vn_b_men_usmc_70_28", // Gun crew (Rammer)
		"vn_i_men_aircrew_01",
		"vn_i_men_aircrew_02",
		"vn_i_men_aircrew_03",
		"vn_i_men_aircrew_04",
		"vn_i_men_aircrew_05",
		"vn_i_men_aircrew_06",
		"vn_i_men_aircrew_07",
		"vn_i_men_aircrew_08",
		"vn_i_men_aircrew_09",
		"vn_i_men_aircrew_10",
		"vn_i_men_aircrew_11",
		"vn_i_men_aircrew_12",
		"vn_i_men_army_13", // Crewman (Driver)
		"vn_i_men_army_14", // Crewman (Commander)
		"vn_i_men_army_22", // Quan Canh Policeman
		"vn_i_men_army_23", // Crewman (Commander)
		"vn_i_men_army_24", // Crewman (Driver)
		"vn_i_men_army_25", // Crewman (Gunner)
		"vn_i_men_fank_70_13", // Crew (Driver)
		"vn_i_men_fank_70_14", // Crew (Commander)
		"vn_i_men_fank_70_23", // Crewman (Commander)
		"vn_i_men_fank_70_24", // Crewman (Driver)
		"vn_i_men_fank_70_25", // Crewman (Gunner)
		"vn_i_men_fank_71_13", // Crew (Driver)
		"vn_i_men_fank_71_14", // Crew (Commander)
		"vn_i_men_fank_71_23", // Crewman (Commander)
		"vn_i_men_fank_71_24", // Crewman (Driver)
		"vn_i_men_fank_71_25", // Crewman (Gunner)
		"vn_i_men_jetpilot_01", // Jet Pilot
		"vn_i_men_jetpilot_02", // Jet Copilot
		"vn_i_men_marine_13", // Crew (Driver)
		"vn_i_men_marine_14", // Crew (Commander)
		"vn_i_men_marine_23", // Gun crew (Chief of Smoke)
		"vn_i_men_marine_24", // Gun crew (Swabber)
		"vn_i_men_marine_25", // Gun crew (Rammer)
		"vn_i_men_ranger_13", // Crew (Driver)
		"vn_i_men_ranger_14", // Crew (Commander)
		"vn_i_men_rla_13", // Crew (Driver)
		"vn_i_men_rla_14", // Crew (Commander)
		"vn_i_men_rla_23", // Gun crew (Chief of Smoke)
		"vn_i_men_rla_24", // Gun crew (Swabber)
		"vn_i_men_rla_25", // Gun crew (Rammer)
		"vn_o_men_aircrew_01", // Heli Pilot (PM)
		"vn_o_men_aircrew_02", // Heli Co-Pilot (TT-33)
		"vn_o_men_aircrew_03", // Heli Crew Chief (PM)
		"vn_o_men_aircrew_04", // Heli Gunner (TT-33)
		"vn_o_men_aircrew_05", // Pilot (PM)
		"vn_o_men_aircrew_06", // Pilot (TT-33)
		"vn_o_men_aircrew_07", // Jet Pilot (PM)
		"vn_o_men_aircrew_08", // Jet Pilot (TT-33)
		"vn_o_men_kr_70_18", // Crewman (Commander)
		"vn_o_men_kr_70_19", // Crewman (Driver)
		"vn_o_men_kr_70_20", // Crewman (Gunner)
		"vn_o_men_kr_75_18", // Crewman (Commander)
		"vn_o_men_kr_75_19", // Crewman (Driver)
		"vn_o_men_kr_75_20", // Crewman (Gunner)
		"vn_o_men_nva_37", // Crewman (Commander)
		"vn_o_men_nva_38", // Crewman (Driver)
		"vn_o_men_nva_39", // Crewman (Gunner)
		"vn_o_men_nva_40", // Crewman (Commander)
		"vn_o_men_nva_41", // Crewman (Driver)
		"vn_o_men_nva_42", // Crewman (Gunner)
		"vn_o_men_nva_65_35", // Crewman (Commander)
		"vn_o_men_nva_65_36", // Crewman (Driver)
		"vn_o_men_nva_65_37", // Crewman (Gunner)
		"vn_o_men_nva_65_38", // Crewman (Commander)
		"vn_o_men_nva_65_39", // Crewman (Driver)
		"vn_o_men_nva_65_40", // Crewman (Gunner)
		"vn_o_men_pl_18", // Crewman (Commander)
		"vn_o_men_pl_19", // Crewman (Driver)
		"vn_o_men_pl_20", // Crewman (Gunner)
		
		// SPE
		"SPE_sturmtrooper_tank_crew",
		"SPE_sturmtrooper_tank_unterofficer",
		"SPE_sturmtrooper_tank_lieutenant",
		"SPE_GER_pilot",
		"SPE_GER_gun_crew",
		"SPE_GER_gun_SquadLead",
		"SPE_GER_gun_lieutenant",
		"SPE_GER_spg_crew",
		"SPE_GER_spg_unterofficer",
		"SPE_GER_spg_lieutenant",
		"SPE_GER_tank_crew",
		"SPE_GER_tank_unterofficer",
		"SPE_GER_tank_lieutenant",
		"SPE_FR_Tank_Crew",
		"SPE_FR_Tank_Second_Lieutenant",
		"SPE_FR_Tank_Sergeant",
		"SPE_US_Pilot_2",
		"SPE_US_Pilot",
		"SPE_US_Pilot_Unequipped",
		"SPE_US_Guncrew",
		"SPE_US_Guncrew_Sergeant",
		"SPE_US_Tank_Crew",
		"SPE_US_Tank_Second_Lieutenant",
		"SPE_US_Tank_Sergeant"
];


ALiVE_MIL_CQB_STRATEGICPLATFORMS = ALiVE_MIL_CQB_CUSTOM_STRATEGICPLATFORMS +
[
    // VN - CDLC S.O.G Prairie Fire 1.3
    "Land_vn_b_tower_01",
    "Land_vn_hut_tower_03",
    "Land_vn_hut_tower_02",
    "Land_vn_hut_tower_01",
    "Land_vn_guardtower_01_f",
    "Land_vn_guardtower_02_f",
    "Land_vn_guardtower_04_f",
    "Land_vn_o_tower_03",
    "Land_vn_o_tower_02",
    "Land_vn_o_tower_01",
    "Land_vn_hut_tower_02",
    "Land_vn_o_platform_01",
    "Land_vn_o_platform_02",
    "Land_vn_o_platform_03",
    "Land_vn_o_snipertree_01",
    "Land_vn_o_snipertree_04",
    "Land_vn_o_snipertree_02",
    "Land_vn_o_snipertree_03"
];

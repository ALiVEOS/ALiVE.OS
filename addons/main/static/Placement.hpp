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
		
		// SPE - CDLC Spearhead 1944 1.1
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
		"SPE_US_Tank_Sergeant",
		
     // GM - CDLC Global Mobilization 1.5
		"gm_gc_army_ammobox_smallarms_80", 
		"gm_dk_army_ammobox_smallarms_80", 
		"gm_ge_bgs_bicycle_01_grn",
		"gm_ge_army_bicycle_01_oli", 
		"gm_ge_bgs_bicycle_01_grn", 
		"gm_gc_army_bicycle_01_oli", 
    "gm_ge_army_general_p1_80_oli",
    "gm_gc_army_rifleman_80_blk",
    "gm_ge_pol_pilot_p1_80_grn", 
    "gm_ge_adak_pilot_80_sar", 
    "gm_ge_pol_bicycle_01_grn", 
    "gm_xx_civ_bicycle_01", 
    "gm_gc_civ_pilot_80_blk", 
    "gm_ge_dbp_bicycle_01_ylw"
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

    // VN - CDLC S.O.G Prairie Fire 1.3
    "vn_b_air_f4b_ejection_seat_01",
    "vn_b_air_f100d_ejection_seat"
    
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


    // VN - CDLC S.O.G Prairie Fire 1.3
    // WEST
    // MACV (B_MACV) - Military Assistance Command, Vietnam
    
    // vn_b_group_men_aircrew
    "vn_b_group_men_ch47_01", // CH-47 Crew (US Army)
    "vn_b_group_men_ch47_02", // CH-47 Crew (Air Cavalry)
    "vn_b_group_men_ch47_03", // ACH-47 Crew (US Army)
    "vn_b_group_men_cobra_01", // AH-1 Crew (Air Cavalry)
    "vn_b_group_men_cobra_02", // AH-1 Crew (USAF Green Hornets)
    "vn_b_group_men_cobra_03", // AH-1 Crew (USMC Scarface)
    "vn_b_group_men_plane_01", // Plane Crew (20th TASS Covey)
    "vn_b_group_men_plane_02", // F-4 Crew (USAF Wolfpack)
    "vn_b_group_men_plane_03", // F-4 Crew (USAF Hobo)
    "vn_b_group_men_plane_04", // F-4 Crew (USMC VM121)
    "vn_b_group_men_plane_05", // F-4 Crew (Navy Sundowners)
    "vn_b_group_men_plane_06", // F-4 Crew (Navy VA196)
    "vn_b_group_men_uh1_01", // UH-1 Crew (Air Cavalry)
    "vn_b_group_men_uh1_02", // UH-1 Crew (USAF Green Hornets)
    "vn_b_group_men_uh1_03", // UH-1 Crew (Navy Seawolves)
    "vn_b_group_men_uh1_04", // UH-1 Crew (US 195th AHC)
    "vn_b_group_men_uh1_05", // UH-1 Crew (USMC)
    "vn_b_group_men_uh1_06", // H-34 Crew (USMC HMM-362)
    
    // vn_b_group_motor_army
    "vn_b_group_motor_army_07", // M54 Reinforcements
    
    // vn_b_group_motor_usmc
    "vn_b_group_motor_usmc_07", // M54 Reinforcements
    
    // vn_b_group_mech_army
    "vn_b_group_mech_army_03", // M54 Convoy (Airport)
    "vn_b_group_mech_army_04", // M54 Convoy
    "vn_b_group_mech_army_05", // M54 Convoy (Heavy)
    "vn_b_group_mech_army_06", // M54 Convoy (Supply)
    
    // vn_b_group_mech_usmc
    "vn_b_group_mech_usmc_04", // M54 Convoy
    "vn_b_group_mech_usmc_05", // M54 Convoy (Heavy)
    "vn_b_group_mech_usmc_06", // M54 Convoy (Supply)
    
    // vn_b_group_boats
    "vn_b_group_boat_01", // PTF Nasty Boats (Patrol)
    "vn_b_group_boat_02", // PTF Nasty Boats (Squadron)
    "vn_b_group_boat_03", // SEAL Attack Boats (Patrol)
    "vn_b_group_boat_04", // SEAL Attack (Squadron)
    "vn_b_group_boat_05", // PBR Mk II Boats (Patrol)
    "vn_b_group_boat_06", // PBR Mk II Boats (Squadron)

    // vn_b_group_men_navy
    "vn_b_group_men_navy_01", // Boat Crew (PTF)

    // vn_b_group_men_army
    "vn_b_group_men_army_05", // Tank Crew
    "vn_b_group_men_army_06", // Tunnel Rats
    "vn_b_group_men_army_07", // Artillery Gun Crew
    "vn_b_group_men_army_09", // Vehicle Crew
    
    // vn_b_group_men_usmc_66
    "vn_b_group_men_usmc_66_05", // Tank Crew
    "vn_b_group_men_usmc_66_07", // Artillery Gun Crew
    "vn_b_group_men_usmc_66_09", // Vehicle Crew

    // vn_b_group_men_usmc_68
    "vn_b_group_men_usmc_68_05", // Tank Crew
    "vn_b_group_men_usmc_68_07", // Artillery Gun Crew
    "vn_b_group_men_usmc_68_09", // Vehicle Crew

    // vn_b_group_men_usmc_70
    "vn_b_group_men_usmc_70_05", // Tank Crew
    "vn_b_group_men_usmc_70_07", // Artillery Gun Crew
    "vn_b_group_men_usmc_70_09", // Vehicle Crew


    // CIA
    
    // vn_b_group_men_cia
    "vn_b_group_men_cia_01", // UH-1 Crew (Air America)
    

    // NZ (B_NZ) - New Zealand Army, Vietnam
    
    // vn_b_group_mech_nz_army
    "vn_b_group_mech_nz_army_02", // M54 Convoy
    "vn_b_group_mech_nz_army_03", // name = "M54 Convoy (Supply)";
    
    //b vn_b_group_motor_nz_army
    "vn_b_group_motor_nz_army_04", // M54 Reinforcements
    "vn_b_group_mech_rok_marines_03",  // M151 Convoy (Supply/ Marines)
    
    // ROK (B_ROK) - Republic of Korea
    
    // vn_b_group_mech_rok_army
    "vn_b_group_mech_rok_army_02", // M54 Convoy
    "vn_b_group_mech_rok_army_03", // M54 Convoy (Supply)
    
    // vn_b_group_mech_rok_marines
    "vn_b_group_mech_rok_marines_02", // M54 Convoy (Marines)
    
    // vn_b_group_men_rok_army_65
    "vn_b_group_men_rok_army_65_06", // Gun Team
    
    // vn_b_group_men_rok_army_68
    "vn_b_group_men_rok_army_68_06", // Gun Team
    "vn_b_group_men_rok_army_68_07", // APC Crew
    
    // vn_b_group_men_rok_marines_65
    "vn_b_group_men_rok_marines_65_06", // Gun Team
    
    // vn_b_group_men_rok_marines_68
    "vn_b_group_men_rok_marines_68_06", // Gun Team
    
    // vn_b_group_motor_rok_army
    "vn_b_group_motor_rok_army_04", // M54 Reinforcements
    
    // vn_b_group_motor_rok_marines
    "vn_b_group_motor_rok_marines_04", // M54 Reinforcements (Marines)
    
    // AUS (B_AUS) - Australian Army, Vietnam
    
    // vn_b_group_mech_aus_army
    "vn_b_group_mech_aus_army_02", // M54 Convoy
    "vn_b_group_mech_aus_army_03", // M54 Convoy (Supply)
    
    // vn_b_group_men_aus_army_66
    "vn_b_group_men_aus_army_66_06", // Gun Team
    "vn_b_group_men_aus_army_66_07", // APC Crew (3rd Cavalry Regiment)
    
    // vn_b_group_men_aus_raaf
    "vn_b_group_men_aus_raaf_01", // UH-1 Crew (No.9 Squadron)
    
    // vn_b_group_men_aus_ran    
    "vn_b_group_men_aus_ran_01", // UH-1 Crew (Emu Flight 135 AHC)
    
    // vn_b_group_motor_aus_army
    "vn_b_group_motor_aus_army_04", // M54 Reinforcements
    
    
    // EAST
    
    // PL (O_PL) - Pathet lao
    
    // vn_o_group_boats_pl
    "vn_o_group_boat_pl_01", // Armed Boats (Patrol)
    "vn_o_group_boat_pl_02", // Armed Boats (Squadron)
    "vn_o_group_boat_pl_03", // Boats (Transport)
    "vn_o_group_boat_pl_04", // Boats (Supply)
    
    // vn_o_group_mech_pl
    "vn_o_group_mech_pl_02", // Z-157 Convoy (Ammo)
    "vn_o_group_mech_pl_03", // Z-157 Convoy (Supply)
    "vn_o_group_mech_pl_04", // Z-157 Convoy
    "vn_o_group_mech_pl_05", // Z-157 Convoy (Heavy)
    
    
    // vn_o_group_motor_pl
    "vn_o_group_motor_pl_07", // Z-157 Reinforcements
    "vn_o_group_motor_pl_08", // Mule Convoy (Bicycle)
    "vn_o_group_motor_pl_09", // Scout Convoy (Bicycle)
    
    
    // KR (O_CAM) - Khmer Rouge
    
    // vn_o_group_boats_kr_70
    "vn_o_group_boat_kr_70_01", // Armed Boats (Patrol)
    "vn_o_group_boat_kr_70_02", // Armed Boats (Squadron)
    "vn_o_group_boat_kr_70_03", // Boats (Transport)
    "vn_o_group_boat_kr_70_04", // Boats (Supply)
    "vn_o_group_boat_kr_75_05", // Sampans (Transport)
    "vn_o_group_boat_kr_75_06", // Sampans (Supply)
    
    // vn_o_group_mech_kr_75
    "vn_o_group_mech_kr_75_02", // Z-157 Convoy (Ammo)
    "vn_o_group_mech_kr_75_03", // Z-157 Convoy (Supply)
    "vn_o_group_mech_kr_75_04", // Z-157 Convoy
    "vn_o_group_mech_kr_75_05", //  Z-157 Convoy (Heavy)
    
    
    // vn_o_group_men_kr_70
    "vn_o_group_men_kr_70_05", // Artillery Gun Crew
    
    // vn_o_group_men_kr_75
    "vn_o_group_men_kr_75_05", // Artillery Gun Crew
    
    // vn_o_group_motor_kr_75
    "vn_o_group_motor_kr_75_07", // Z-157 Reinforcements
    
    
    // VC (O_VC) - Viet Cong
   
    // vn_o_group_boats_vcmf
    "vn_o_group_boat_vcmf_01", // Armed Boats (Patrol)
    "vn_o_group_boat_vcmf_02", // Armed Boats (Squadron)
    "vn_o_group_boat_vcmf_03", // Boats (Transport)
    "vn_o_group_boat_vcmf_04", // Boats (Supply)
    "vn_o_group_boat_vcmf_05", // Sampans (Transport)
    "vn_o_group_boat_vcmf_06", // Sampans (Supply)
    "vn_o_group_boat_vcmf_07", // Armed Boats (Patrol)
    "vn_o_group_boat_vcmf_08", // Armed Boats (Patrol)
    
    
    // vn_o_group_mech_vcmf
    "vn_o_group_mech_vcmf_02", // Z-157 Convoy (Ammo)
    "vn_o_group_mech_vcmf_03", // Z-157 Convoy (Supply)
    "vn_o_group_mech_vcmf_04", // Z-157 Convoy
    "vn_o_group_mech_vcmf_05", // Z-157 Convoy (Heavy)
    
    // vn_o_group_motor_vcmf
    "vn_o_group_motor_vcmf_07", // Z-157 Reinforcements
    "vn_o_group_motor_vcmf_08", // Mule Convoy (Bicycle)
    "vn_o_group_motor_vcmf_09", // Scout Convoy (Bicycle)
    "vn_o_group_motor_vcmf_11", // Car convoy
    "vn_o_group_motor_vcmf_12", // Car convoy (large)
    
    
    // PAVN (O_PAVN) - People's Army of Vietnam
    
    // vn_o_group_boats
    "vn_o_group_boat_01", // Shantou Boats (Patrol)
    "vn_o_group_boat_02", // Shantou Boats (Squadron)
    "vn_o_group_boat_03", // Shantou Boats (Patrol)
    "vn_o_group_boat_04", // Shantou Boats (Patrol)
    
    // vn_o_group_mech_nva
    "vn_o_group_mech_nva_02", // Z-157 Convoy (S-75)
    "vn_o_group_mech_nva_03", // Z-157 Convoy (Supply)
    "vn_o_group_mech_nva_04", // Z-157 Convoy
    "vn_o_group_mech_nva_05", // Z-157 Convoy (Heavy)
    
    // vn_o_group_mech_nva_65
    "vn_o_group_mech_nva_65_02", // Z-157 Convoy (S-75)
    "vn_o_group_mech_nva_65_03", // Z-157 Convoy (Supply)
    "vn_o_group_mech_nva_65_04", // Z-157 Convoy
    "vn_o_group_mech_nva_65_05", // Z-157 Convoy (Heavy)
    
    // vn_o_group_mech_nvam
    "vn_o_group_mech_nvam_02", // Z-157 Convoy (S-75)
    "vn_o_group_mech_nvam_03", // Z-157 Convoy (Supply)
    "vn_o_group_mech_nvam_04", // Z-157 Convoy
    "vn_o_group_mech_nvam_05", // Z-157 Convoy (Heavy)
    
    // vn_o_group_men_nva
    "vn_o_group_men_nva_05", // Tank Crew
    "vn_o_group_men_nva_07", // Mortar Team
    "vn_o_group_men_nva_08", // Vehicle Crew
    
    // vn_o_group_men_nva_65
    "vn_o_group_men_nva_65_05", // Tank Crew
    "vn_o_group_motor_nva_65_07", // Mortar Team
    "vn_o_group_men_nva_65_08", // Vehicle Crew
    
    // vn_o_group_men_nva_65_field
    "vn_o_group_men_nva_65_field_05", // Tank Crew
    "vn_o_group_men_nva_65_field_07", // Mortar Team
    "vn_o_group_men_nva_65_field_08", // Vehicle Crew
    
    // vn_o_group_men_nva_field
    "vn_o_group_men_nva_field_05", // Tank Crew
    "vn_o_group_men_nva_field_07", // Mortar Team
    "vn_o_group_men_nva_field_08", // Vehicle Crew
    
    // vn_o_group_men_nva_navy
    "vn_o_group_men_nva_navy_01", // Naval Squad 1
    "vn_o_group_men_nva_navy_02", // Boat Crew (Shantou)
    
    
    // vn_o_group_men_vpaf
    "vn_o_group_men_vpaf_01", // Plane Crew
    "vn_o_group_men_vpaf_02", // MiG Crew
    "vn_o_group_men_vpaf_03", // Mi-2 Crew
    
    // vn_o_group_motor_nva
    "vn_o_group_motor_nva_07", // Z-157 Reinforcements
    "vn_o_group_motor_nva_08", // Mule Convoy (Bicycle)
    "vn_o_group_motor_nva_09", // Scout Convoy (Bicycle)
    
    // vn_o_group_motor_nva_65
    "vn_o_group_motor_nva_65_07", // Z-157 Reinforcements
    "vn_o_group_motor_nva_65_08", // Mule Convoy (Bicycle)
    "vn_o_group_motor_nva_65_09", // Scout Convoy (Bicycle)
    
    // vn_o_group_motor_nvam
    "vn_o_group_motor_nvam_07", // Z-157 Reinforcements
    "vn_o_group_motor_nvam_08", // Scout Convoy (Bicycle)
    
    
    // INDEP
    
    // ARVN (I_ARVN) - Army of the Republic of Vietnam
    
    // vn_i_group_mech_army
    "vn_i_group_mech_army_03", // M54 Convoy
    "vn_i_group_mech_army_04", // M54 Convoy (Supply)

    // vn_i_group_mech_marines
    "vn_i_group_mech_marines_02", // M54 Convoy (Marines)
    "vn_i_group_mech_marines_03", // M151 Convoy (Supply/ Marines)
    
    // vn_i_group_men_aircrew
    "vn_i_group_men_ch34_01",  // CH-34 Crew (ARVN Kingbee)
    "vn_i_group_men_plane_01", // Plane Crew (ARVN)
    "vn_i_group_men_uh1_01", // UH-1 Crew (ARVN)

    // vn_i_group_men_army
    "vn_i_group_men_army_04", // Quan Canh Police
    "vn_i_group_men_army_05", // Tank Crew
    "vn_i_group_men_army_09", // Vehicle Crew

    // vn_i_group_men_marines
    "vn_i_group_men_marines_09", // Vehicle Crew
    "vn_i_group_men_marines_10", // Gun Team

    // vn_i_group_motor_army
    "vn_i_group_motor_army_07", // M54 Reinforcements

    // vn_i_group_motor_marines
    "vn_i_group_motor_marines_07", // M54 Reinforcements (Marines)
    
    
    // FANK (I_CAM) - Forces Armee National Khmer
    
    // vn_i_group_boats_fank_71
    "vn_i_group_boat_fank_70_03", // Armed Boats (Patrol)
    "vn_i_group_boat_fank_70_04", // Armed Boats (Squadron)
    "vn_i_group_boat_fank_70_05", // Boats (Transport)
    "vn_i_group_boat_fank_70_06", // Boats (Supply)
    "vn_i_group_boat_fank_71_01", // PBR Mk II Boats (Patrol)
    "vn_i_group_boat_fank_71_02", // PBR Mk II Boats (Squadron)
    
    // vn_i_group_mech_fank_70
    "vn_i_group_mech_fank_70_02", // Z-157 Convoy (Ammo)
    "vn_i_group_mech_fank_70_03", // Z-157 Convoy (Supply)
    "vn_i_group_mech_fank_70_04", // Z-157 Convoy
    "vn_i_group_mech_fank_70_05", // Z-157 Convoy (Heavy)
    
    // vn_i_group_mech_fank_71
    "vn_i_group_mech_fank_71_02", // M54 Convoy
    "vn_i_group_mech_fank_71_03", // M54 Convoy (Supply)
    
    // vn_i_group_men_aircrew
    "vn_i_group_men_fank_71_uh1_01", // UH-1 Crew (ARVN)
    
    // vn_i_group_men_fank_70
    "vn_i_group_men_fank_70_07", // Vehicle Crew
    
    // vn_i_group_men_fank_71
    "vn_i_group_men_fank_71_07", // Vehicle Crew
    
    // vn_i_group_motor_fank_70
    "vn_i_group_motor_fank_70_07", // Z-157 Reinforcements
    
    // vn_i_group_motor_fank_71
    "vn_i_group_motor_fank_71_07", // M54 Reinforcements
    
    
    // RLA (I_LAO) - Royal Lao Army
    
    // vn_i_group_mech_rla
    "vn_i_group_mech_rla_02", // M54 Convoy
    "vn_i_group_mech_rla_03", // M54 Convoy (Supply)
    
    // vn_i_group_men_rla
    "vn_i_group_men_rla_05", // Vehicle Crew
    
    // "n_i_group_motor_rla
    "vn_i_group_motor_rla_07" // M54 Reinforcements
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



// VN - CDLC S.O.G Prairie Fire 1.3

// Army of the Republic of Vietnam
[ALIVE_factionDefaultSupports, "I_ARVN", [
    "vn_i_armor_m113_01",
    "vn_i_armor_m113_acav_02",
    "vn_i_armor_m132_01",
    "vn_i_armor_m577_02",
    "vn_i_armor_m577_01",
    "vn_i_wheeled_m54_01",
    "vn_i_wheeled_m54_02",
    "vn_i_wheeled_m54_03",
    "vn_i_wheeled_m151_01",
    "vn_i_wheeled_m151_02",
    "vn_i_wheeled_m151_mg_01",
    "vn_i_wheeled_m54_repair",
    "vn_i_wheeled_m54_fuel",
    "vn_i_wheeled_m54_ammo",
    "vn_i_wheeled_m151_02_mp",
    "vn_i_wheeled_m151_01_mp"
]] call ALIVE_fnc_hashSet;


// Forces Armee National Khmer
[ALIVE_factionDefaultSupports, "I_CAM", [
    "vn_i_armor_m113_01_fank_71",
    "vn_i_wheeled_btr40_01_fank_70",
    "vn_i_wheeled_btr40_02_fank_70",
    "vn_i_wheeled_btr40_mg_02_fank_70",
    "vn_i_wheeled_lr2a_mg_01_fank_71",
    "vn_i_wheeled_m151_01_fank_71",
    "vn_i_wheeled_m151_02_fank_71",
    "vn_i_wheeled_z157_ammo_fank_70",
    "vn_i_wheeled_z157_fuel_fank_70",
    "vn_i_wheeled_z157_repair_fank_70",
    "vn_i_wheeled_z157_01_fank_70",
    "vn_i_wheeled_z157_02_fank_70"
]] call ALIVE_fnc_hashSet;


// Royal Lao Army
[ALIVE_factionDefaultSupports, "I_LAO", [
		"vn_i_wheeled_m54_03_rla",
		"vn_i_wheeled_m54_02_rla",
		"vn_i_wheeled_m54_01_rla",
		"vn_i_wheeled_m54_ammo_rla",
		"vn_i_wheeled_m54_fuel_rla",
		"vn_i_wheeled_m54_repair_rla",
		"vn_i_wheeled_m151_mg_01_rla",
		"vn_i_wheeled_m151_02_rla",
		"vn_i_wheeled_m151_01_rla"
]] call ALIVE_fnc_hashSet;


// People's Army of Vietnam
[ALIVE_factionDefaultSupports, "O_PAVN", [
		"vn_o_bicycle_01_nva65",
		"vn_o_bicycle_02_nva65",
		"vn_o_armor_btr50pk_03_nva65",
		"vn_o_armor_btr50pk_01_nvam",
		"vn_o_armor_m113_01",
		"vn_o_armor_m577_01",
		"vn_o_armor_m577_02",
		"vn_o_wheeled_z157_ammo",
		"vn_o_wheeled_btr40_01_nva65",
		"vn_o_wheeled_btr40_02_nva65",
		"vn_o_wheeled_btr40_mg_01_nva65",
		"vn_o_wheeled_z157_02_nva65",
		"vn_o_wheeled_z157_01_nva65",
		"vn_o_wheeled_z157_repair_nva65",
		"vn_o_wheeled_z157_03_nva65",
		"vn_o_wheeled_z157_04_nva65",
		"vn_o_wheeled_z157_fuel"
]] call ALIVE_fnc_hashSet;

// Viet Cong
[ALIVE_factionDefaultSupports, "O_VC", [
		"vn_o_bicycle_01_vcmf",
		"vn_o_bicycle_02_vcmf",
		"vn_o_wheeled_btr40_mg_04_vcmf",
		"vn_o_wheeled_btr40_02_vcmf",
		"vn_o_wheeled_btr40_01_vcmf",
		"vn_o_car_01_01",
		"vn_o_car_03_01",
		"vn_o_car_02_01",
		"vn_o_car_04_01",
		"vn_o_car_04_mg_01",
		"vn_o_wheeled_z157_04_vcmf",
		"vn_o_wheeled_z157_fuel_vcmf",
		"vn_o_wheeled_z157_ammo_vcmf",
		"vn_o_wheeled_z157_02_vcmf",
		"vn_o_wheeled_z157_01_vcmf",
		"vn_o_wheeled_z157_03_vcmf",
		"vn_o_wheeled_z157_repair_vcmf"
]] call ALIVE_fnc_hashSet;

// Pathet lao
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


// Khmer Rouge
[ALIVE_factionDefaultSupports, "O_CAM", [
    "vn_o_bicycle_01",
    "vn_o_bicycle_02",
    "vn_o_armor_m113_01_kr",
    "vn_o_wheeled_btr40_mg_01_kr",
    "vn_o_wheeled_btr40_02_kr",
    "vn_o_wheeled_btr40_01_kr",
    "vn_o_car_01_01_kr",
    "vn_o_car_03_01_kr",
    "vn_o_car_02_01_kr",
    "vn_o_car_04_mg_01_kr",
    "vn_o_car_04_01_kr",
    "vn_o_wheeled_z157_ammo_kr",
    "vn_o_wheeled_z157_fuel_kr",
    "vn_o_wheeled_z157_repair_kr",
    "vn_o_wheeled_z157_01_kr",
    "vn_o_wheeled_z157_02_kr"
]] call ALIVE_fnc_hashSet;



// Military Assistance Command, Vietnam
[ALIVE_factionDefaultSupports, "B_MACV", [
		"vn_b_armor_m577_01",
		"vn_b_armor_m577_02",
		"vn_b_armor_m113_01",
		"vn_b_armor_m132_01",
		"vn_b_wheeled_m54_03",
		"vn_b_wheeled_m151_mg_04",
		"vn_b_wheeled_m54_01_sog",
		"vn_b_wheeled_m54_02_sog",
		"vn_b_wheeled_m54_02",
		"vn_b_wheeled_m54_fuel",
		"vn_b_wheeled_m54_01",
		"vn_b_wheeled_m54_ammo",
		"vn_b_wheeled_m274_02_01",
		"vn_b_wheeled_m151_01",
		"vn_b_wheeled_m54_repair",
		"vn_b_wheeled_m151_02",
		"vn_b_wheeled_m274_01_01"
]] call ALIVE_fnc_hashSet;


// Australian Army, Vietnam
[ALIVE_factionDefaultSupports, "B_AUS", [
		"vn_b_armor_m577_01_aus_army",
		"vn_b_armor_m113_01_aus_army",
		"vn_b_armor_m577_02_aus_army",
		"vn_b_wheeled_lr2a_mg_01_aus_army",
		"vn_b_wheeled_m54_03_aus_army",
		"vn_b_wheeled_m151_mg_02_aus_army",
		"vn_b_wheeled_m151_01_aus_army",
		"vn_b_wheeled_lr2a_01_aus_army",
		"vn_b_wheeled_lr2a_02_aus_army",
		"vn_b_wheeled_lr2a_03_aus_army",
		"vn_b_wheeled_m151_02_aus_army",
		"vn_b_wheeled_m54_repair_aus_army",
		"vn_b_wheeled_m54_fuel_aus_army",
		"vn_b_wheeled_m54_ammo_aus_army",
		"vn_b_wheeled_m54_01_aus_army",
		"vn_b_wheeled_m54_02_aus_army"
]] call ALIVE_fnc_hashSet;


// New Zealand Army, Vietnam
[ALIVE_factionDefaultSupports, "B_NZ", [
		"vn_b_wheeled_m54_02_nz_army",
		"vn_b_wheeled_m54_ammo_nz_army",
		"vn_b_wheeled_m54_01_nz_army",
		"vn_b_wheeled_m54_repair_nz_army",
		"vn_b_wheeled_m54_fuel_nz_army",
		"vn_b_wheeled_lr2a_mg_01_nz_army",
		"vn_b_wheeled_m151_02_nz_army",
		"vn_b_wheeled_m151_01_nz_army",
		"vn_b_wheeled_m151_mg_02_nz_army",
		"vn_b_wheeled_m54_03_nz_army",
		"vn_b_wheeled_lr2a_01_nz_army",
		"vn_b_wheeled_lr2a_02_nz_army",
		"vn_b_wheeled_lr2a_03_nz_army"
]] call ALIVE_fnc_hashSet;


// Republic of Korea
[ALIVE_factionDefaultSupports, "B_ROK", [
		"vn_b_wheeled_m54_02_rok_army",
		"vn_b_wheeled_m54_01_rok_army",
		"vn_b_wheeled_m54_ammo_rok_army",
		"vn_b_wheeled_m54_fuel_rok_army",
		"vn_b_wheeled_m54_repair_rok_army",
		"vn_b_wheeled_m151_mg_02_rok_army",
		"vn_b_wheeled_m151_02_rok_army",
		"vn_b_wheeled_m151_01_rok_army",
		"vn_b_wheeled_m54_03_rok_army",
		"vn_b_armor_m577_01_rok_army",
		"vn_b_armor_m577_02_rok_army",
		"vn_b_armor_m113_01_rok_army"
]] call ALIVE_fnc_hashSet;


// SPE - CDLC Spearhead 1944 1.1
[ALIVE_factionDefaultSupports, "SPE_STURM", ["SPE_ST_OpelBlitz","SPE_ST_OpelBlitz_Open","SPE_ST_OpelBlitz_Fuel","SPE_ST_OpelBlitz_Ambulance","SPE_ST_OpelBlitz_Repair","SPE_ST_OpelBlitz_Ammo","SPE_ST_OpelBlitz_Flak38"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "SPE_WEHRMACHT", ["SPE_OpelBlitz","SPE_OpelBlitz_Open","SPE_OpelBlitz_Fuel","SPE_OpelBlitz_Repair","SPE_OpelBlitz_Ammo","SPE_OpelBlitz_Ambulance","SPE_OpelBlitz_Flak38"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "SPE_US_ARMY", ["SPE_US_M3_Halftrack_Unarmed","SPE_US_M3_Halftrack_Unarmed_Open","SPE_US_M3_Halftrack_Ammo","SPE_US_M3_Halftrack_Fuel","SPE_US_M3_Halftrack_Repair","SPE_US_M3_Halftrack_Ambulance","SPE_US_M16_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "SPE_FR_ARMY", ["SPE_FR_M3_Halftrack_Unarmed","SPE_FR_M3_Halftrack_Unarmed_Open","SPE_FR_M3_Halftrack_Ammo","SPE_FR_M3_Halftrack_Fuel","SPE_FR_M3_Halftrack_Repair","SPE_FR_M3_Halftrack_Ambulance","SPE_FR_M16_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "SPE_FFI", ["SPE_FFI_OpelBlitz","SPE_FFI_OpelBlitz_Open","SPE_FFI_OpelBlitz_Fuel","SPE_FFI_OpelBlitz_Ambulance","SPE_FFI_OpelBlitz_Repair","SPE_FFI_OpelBlitz_Ammo"]] call ALIVE_fnc_hashSet;


// GM - CDLC Global Mobilization 1.5
[ALIVE_factionDefaultSupports, "gm_gc_army", [
		"gm_gc_army_ural4320_cargo",
		"gm_gc_army_ural375d_cargo",
		"gm_gc_army_uaz469_cargo",
		"gm_gc_army_p601",
		"gm_gc_army_ural4320_repair", 
		"gm_gc_army_ural4320_reammo", 
		"gm_gc_army_ural375d_refuel", 
		"gm_gc_army_ural375d_medic", 
		"gm_gc_army_ural44202", 
		"gm_gc_army_uaz469_dshkm", 
		"gm_gc_army_uaz469_spg9"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_gc_army_win", [
		"gm_gc_army_ural375d_cargo_win",
		"gm_gc_army_uaz469_cargo_win",
		"gm_gc_army_p601",
		"gm_gc_army_ural4320_repair_olw", 
		"gm_gc_army_ural375d_refuel_olw", 
		"gm_gc_army_ural4320_reammo_olw", 
		"gm_gc_army_ural44202_olw", 
		"gm_gc_army_brdm2_olw"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_gc_army_bgs", [
		"gm_gc_bgs_ural4320_cargo",
		"gm_gc_bgs_uaz469_cargo",
		"gm_gc_bgs_ural4320_repair", 
		"gm_gc_bgs_ural4320_reammo", 
		"gm_gc_bgs_ural375d_refuel", 
		"gm_gc_bgs_ural375d_medic", 
		"gm_gc_bgs_ural4320_cargo"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_pl_army", [
		"gm_pl_army_ural4320_cargo",
		"gm_pl_army_uaz469_cargo",
		"gm_pl_army_ural4320_repair", 
		"gm_pl_army_ural4320_reammo", 
		"gm_pl_army_ural375d_refuel", 
		"gm_pl_army_ural375d_medic", 
		"gm_pl_army_uaz469_cargo", 
		"gm_pl_army_uaz469_dshkm"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_pl_army_win", [
		"gm_gc_army_ural375d_cargo_win",
		"gm_gc_army_uaz469_cargo_win",
		"gm_gc_army_p601",
		"gm_pl_army_ural4320_repair_olw", 
		"gm_pl_army_ural4320_reammo_olw", 
		"gm_pl_army_ural375d_refuel_olw", 
		"gm_pl_army_uaz469_cargo_olw", 
		"gm_pl_army_uaz469_dshkm_olw"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_ge_army", [
		"gm_ge_army_typ1200_cargo",
		"gm_ge_army_typ247_cargo",
		"gm_ge_army_typ253_cargo",
		"gm_ge_army_iltis_cargo",
		"gm_ge_army_u1300l_cargo",
		"gm_ge_army_u1300l_repair", 
		"gm_ge_army_kat1_451_reammo", 
		"gm_ge_army_kat1_451_refuel", 
		"gm_ge_army_u1300l_medic", 
		"gm_ge_army_kat1_451_cargo", 
		"gm_ge_army_iltis_milan", 
		"gm_ge_army_iltis_mg3", 
		"gm_ge_army_fuchsa0_engineer"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_ge_army_win", [
		"gm_ge_army_typ1200_cargo_win",
		"gm_ge_army_typ247_cargo_win",
		"gm_ge_army_typ253_cargo_win",
		"gm_ge_army_iltis_cargo_win",
		"gm_ge_army_u1300l_cargo_win",
		"gm_ge_army_u1300l_repair_win", 
		"gm_ge_army_kat1_451_reammo_win", 
		"gm_ge_army_kat1_451_refuel_win", 
		"gm_ge_army_kat1_451_cargo_win", 
		"gm_ge_army_iltis_milan_win", 
		"gm_ge_army_iltis_mg3_win", 
		"gm_ge_army_fuchsa0_engineer_win"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_ge_army_bgs", [
		"gm_ge_bgs_k125",
		"gm_ge_bgs_typ253_cargo",
		"gm_ge_bgs_w123_cargo",
		"gm_ge_army_typ247_cargo", 
		"gm_ge_army_u1300l_firefighter", 
		"gm_ge_army_typ253_mp", 
		"gm_ge_army_iltis_cargo", 
		"gm_ge_army_u1300l_cargo"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_dk_army", [
		"gm_dk_army_typ1200_cargo",
		"gm_dk_army_typ247_cargo",
		"gm_dk_army_typ253_cargo",
		"gm_dk_army_u1300l_container"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_dk_army_win", [
		"gm_dk_army_typ1200_cargo_win",
		"gm_dk_army_typ247_cargo_win",
		"gm_dk_army_typ253_cargo_win",
		"gm_dk_army_u1300l_container_win"
]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "gm_xx_army", [
		"gm_ge_civ_typ253",
		"gm_ge_civ_typ1200"
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

// VN - CDLC S.O.G Prairie Fire 1.3

// PAVN (O_PAVN) - People's Army of Vietnam
[ALIVE_factionDefaultSupplies, "O_PAVN", [
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_kit_nva",
    "vn_o_ammobox_full_01",
    "vn_o_ammobox_full_03",
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_04",
    "vn_o_ammobox_full_08"
]] call ALIVE_fnc_hashSet;

// VC (O_VC) - Viet Cong
[ALIVE_factionDefaultSupplies, "O_VC", [
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_01",
    "vn_o_ammobox_full_03",
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_04",
    "vn_o_ammobox_full_05"
]] call ALIVE_fnc_hashSet;

// PL (O_PL) - Pathet lao
[ALIVE_factionDefaultSupplies, "O_PL", [
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_01",
    "vn_o_ammobox_full_03",
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_04",
    "vn_o_ammobox_full_11"
]] call ALIVE_fnc_hashSet;

// KR (O_CAM) - Khmer Rouge
[ALIVE_factionDefaultSupplies, "O_CAM", [
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_01",
    "vn_o_ammobox_full_03",
    "vn_o_ammobox_full_02",
    "vn_o_ammobox_full_04",
    "vn_o_ammobox_full_05"
]] call ALIVE_fnc_hashSet;

// ARVN (I_ARVN) - Army of the Republic of Vietnam
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

// RLA (I_LAO) - Royal Lao Army
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

// FANK (I_CAM) - Forces Armee National Khmer
[ALIVE_factionDefaultSupplies, "I_CAM", [
    "vn_b_ammobox_full_09",
    "vn_b_ammobox_supply_01",
    "vn_b_ammobox_full_01",
    "vn_b_ammobox_full_10",
    "vn_b_ammobox_full_03",
    "vn_b_ammobox_full_02",
    "vn_b_ammobox_full_04",
    "vn_b_ammobox_full_09"
]] call ALIVE_fnc_hashSet;

// MACV (B_MACV) - Military Assistance Command, Vietnam
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

// AUS (B_AUS) - Australian Army, Vietnam
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

// NZ (B_NZ) - New Zealand Army, Vietnam
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

// ROK (B_ROK) - Republic of Korea
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



// SPE - CDLC Spearhead 1944 1.1

[ALIVE_factionDefaultSupplies, "SPE_STURM", [
    "SPE_BasicAmmunitionBox_GER",
    "SPE_BasicWeaponsBox_GER",
    "Land_SPE_Ammobox_German_01",
    "Land_SPE_Ammobox_German_02",
    "Land_SPE_Ammobox_German_03",
    "Land_SPE_Ammobox_German_04",
    "Land_SPE_Ammobox_German_05"
]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultSupplies, "SPE_WEHRMACHT", [
    "SPE_BasicAmmunitionBox_GER",
    "SPE_BasicWeaponsBox_GER",
    "Land_SPE_Ammobox_German_01",
    "Land_SPE_Ammobox_German_02",
    "Land_SPE_Ammobox_German_03",
    "Land_SPE_Ammobox_German_04",
    "Land_SPE_Ammobox_German_05"
]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultSupplies, "SPE_US_ARMY", [
    "SPE_BasicAmmunitionBox_US",
    "SPE_BasicWeaponsBox_US",
    "Land_SPE_Ammocrate_US_01",
    "Land_SPE_Ammocrate_US_02",
    "Land_SPE_Ammocrate_US_03"
]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultSupplies, "SPE_FR_ARMY", [
    "SPE_BasicAmmunitionBox_US",
    "SPE_BasicWeaponsBox_US",
    "Land_SPE_Ammocrate_US_01",
    "Land_SPE_Ammocrate_US_02",
    "Land_SPE_Ammocrate_US_03"

]] call ALIVE_fnc_hashSet;


// GM - CDLC Global Mobilization 1.5

[ALIVE_factionDefaultSupplies, "gm_gc_army", ["gm_gc_army_ammobox_smallarms_80","gm_gc_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_gc_army_win", ["gm_gc_army_ammobox_smallarms_80","gm_gc_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_gc_army_bgs", ["gm_gc_army_ammobox_smallarms_80","gm_gc_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_pl_army", ["gm_pl_army_ammobox_smallarms_80","gm_pl_army_ammobox_everything_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_pl_army_win", ["gm_pl_army_ammobox_smallarms_80","gm_pl_army_ammobox_everything_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_ge_army", ["gm_ge_army_ammobox_everything_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_ge_army_win", ["gm_ge_army_ammobox_everything_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_ge_army_bgs", ["gm_ge_army_ammobox_everything_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_dk_army", ["gm_dk_army_ammobox_everything_80","gm_dk_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_dk_army_win", ["gm_dk_army_ammobox_everything_80","gm_dk_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "gm_xx_army", ["gm_gc_army_ammobox_smallarms_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultSupplies, "SPE_FFI", ["SPE_Hay_WeaponCache_FFI"]] call ALIVE_fnc_hashSet;






if (isnil "ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES") then {ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES = []};
if (isnil "ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST") then {ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST = []};

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
    "Land_Ind_PowerStation"
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

     // APEX
    "B_T_Crew_F",
    "B_T_Pilot_F",
    "B_T_Helicrew_F",
    "B_T_diver_F",
    "B_T_diver_TL_F",
    "B_T_diver_exp_F",
    "B_UAV_AI",

    "B_CTRG_Miller_F",

    "O_T_Helipilot_F",
    "O_T_Diver_F",
    "O_T_Diver_TL_F",
    "O_T_Diver_Exp_F",
    "O_T_Crew_F",
    "O_T_Pilot_F",
    "O_T_Helicrew_F",

    "I_C_Helipilot_F",
    "I_C_Pilot_F",
    "I_C_Soldier_Camo_F"
];

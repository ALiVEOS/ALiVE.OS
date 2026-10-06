// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: pulau (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-06", "web", true];

ALIVE_Indexing_Blacklist = [];
ALIVE_militaryBuildingTypes = [];
ALIVE_militaryParkingBuildingTypes = [];
ALIVE_militarySupplyBuildingTypes = [];
ALIVE_militaryHQBuildingTypes = [];
ALIVE_militaryFieldworkBuildingTypes = [];
ALIVE_airBuildingTypes = [];
ALIVE_militaryAirBuildingTypes = [];
ALIVE_civilianAirBuildingTypes = [];
ALiVE_HeliBuildingTypes = [];
ALIVE_militaryHeliBuildingTypes = [];
ALIVE_civilianHeliBuildingTypes = [];
ALIVE_civilianSettlementBuildingTypes = [];
ALIVE_civilianHQBuildingTypes = [];
ALIVE_civilianPopulationBuildingTypes = [];
ALIVE_civilianPowerBuildingTypes = [];
ALIVE_civilianCommsBuildingTypes = [];
ALIVE_civilianMarineBuildingTypes = [];
ALIVE_civilianRailBuildingTypes = [];
ALIVE_civilianFuelBuildingTypes = [];
ALIVE_civilianConstructionBuildingTypes = [];

ALiVE_mapCompositionType = "Pacific";

 if (tolower(_worldName) == "pulau") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_03_f.p3d",
        "a3\props_f_exp\naval\boats\boat_05_wreck_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_06_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_09_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d",
        "a3\structures_f_argo\military\fortifications\czechhedgehog_01_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_blue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_blue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_blue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_whiteblue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_whiteblue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_blue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_blue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_pink_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_ruins_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\ancienthead_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\ancientstatue_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\ancientstatue_02_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\petroglyphwall_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\petroglyphwall_02_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\raistone_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\stonetanoa_01_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_pile_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_platform_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_4m_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_8m_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_d_left_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_d_right_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_gate_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_stockpile_02_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_sugarcane_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_wide_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_30m_skids_end_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_30m_skids_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_mossy_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_long_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_round_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_short_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_big_4_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_line_3_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_line_5_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_wall_4_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_wall_6_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_wall_corner_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_wall_corridor_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_3m_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_3m_round_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_round_f.p3d",
        "a3\structures_f_exp\military\trenches\trench_01_forest_f.p3d",
        "a3\structures_f_exp\military\trenches\trench_01_grass_f.p3d",
        "a3\structures_f_exp\military\trenches\trenchframe_01_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_8m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_pole_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_2m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_8m_nolc_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_6m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_10m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_d_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_pole_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_16m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_4m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_d_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_pole_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_house_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_d_mossy_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_big_tower_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_tower_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\belltowers\belltower_02_v2_ruins_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_tower_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\house_big_01_b_blue_ruins_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_yellow_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_raw_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_ruins_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_05_ruins_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_02\shop_city_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_05\shop_city_05_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_02\shop_town_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_05\shop_town_05_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_ruins_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_ruins_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_yellow_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_raw_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_dock_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_platform_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_hut_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

};

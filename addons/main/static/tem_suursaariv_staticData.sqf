// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: tem_suursaariv (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";

 if (tolower(_worldName) == "tem_suursaariv") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_enoch\civilian\forest\anthill_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\bark_beetle_trap_03_f.p3d",
        "a3\props_f_enoch\civilian\forest\woodenlog_02_f.p3d",
        "a3\props_f_enoch\industrial\supplies\woodenbox_02_f.p3d",
        "a3\props_f_enoch\military\decontamination\waterspill_01_medium_f.p3d",
        "a3\props_f_enoch\military\decontamination\waterspill_01_small_f.p3d",
        "a3\props_f_enoch\military\decontamination\watertrail_01_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\combineharvester_01_wreck_f.p3d",
        "a3\props_f_exp\naval\boats\boat_05_wreck_f.p3d",
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\training\target_popup_moving_90deg_f.p3d",
        "a3\structures_f_argo\cultural\statues\statue_01_f.p3d",
        "a3\structures_f_argo\cultural\statues\statue_02_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_pine_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_blocks_1_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_blocks_3_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\hutch_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\stonewell_01_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_pump_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_wall_d_l_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_wall_d_r_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\cross_01_small_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_02_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_03_f.p3d",
        "a3\structures_f_enoch\cultural\statues\statue_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_medium1_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_decayed_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_packed_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_stack_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\manurepile_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\strawstack_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\shed_ind_old_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_03_f.p3d",
        "a3\structures_f_enoch\infrastructure\highway\highway_pillar_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\lamps\lampindustrial_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_8m_f.p3d",
        "a3\structures_f_enoch\military\training\disturbedsoil_01_decal_f.p3d",
        "a3\structures_f_enoch\military\training\disturbedsoil_02_decal_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_01_decal_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_decal_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_extralarge_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_large_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_small_f.p3d",
        "a3\structures_f_enoch\military\training\shootingpos_roof_01_f.p3d",
        "a3\structures_f_enoch\military\training\target_line_papertargets_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_02_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_door_01_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_01_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_d_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_pole_old_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_3m_v2_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_end_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound04_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\stonewall_02_s_10m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v1_f.p3d",
        "a3\structures_f_enoch\wrecks\mi8_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\powergenerator_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_ruins_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\raistone_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\military\trenches\trench_01_grass_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_2m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_d_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_2m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_3m_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_6m_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_pole_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_16m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_4m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_gate_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_oldman\decals\decal_bulletholes_small_03_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_01_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_02_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_03_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_04_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_01_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_06_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_07_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_big_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_hq_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_small_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_tall_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\controltower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_right_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_right_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_argo\military\bunkers\bunker_01_big_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_hq_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_small_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_tall_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_right_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_right_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_dam_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_b_clay_f.p3d",
        "a3\structures_f_argo\commercial\supermarket_01\supermarket_01_malden_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w05_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w06_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_bastion_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dpp_01_mainfactory_old_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_warehouse_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\i_shed_ind_old_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_02_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f_argo\commercial\supermarket_01\supermarket_01_malden_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w05_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w06_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_dock_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_roof_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dpp_01_mainfactory_old_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d"
    ];

};

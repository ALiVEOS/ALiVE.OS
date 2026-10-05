// ALiVE 3 index v3.1, made 2026-10-05 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: tanoa (ALiVE 3 index v3.1, 2026-10-05)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-05", "web", true];

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

 if (tolower(_worldName) == "tanoa") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\map_tanoabuka\data\roaddecals\arrow_left.p3d",
        "a3\map_tanoabuka\data\roaddecals\arrow_right.p3d",
        "a3\map_tanoabuka\data\roaddecals\arrow_stright.p3d",
        "a3\map_tanoabuka\data\roaddecals\arrow_strleft.p3d",
        "a3\map_tanoabuka\data\roaddecals\arrow_strright.p3d",
        "a3\map_tanoabuka\data\roaddecals\rd_linec_15deg.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\combineharvester_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\haultruck_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\miningshovel_01_abandoned_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_passenger_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_tank_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_front_water_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_rear_water_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_03_f.p3d",
        "a3\props_f_exp\naval\boats\boat_05_wreck_f.p3d",
        "a3\structures_f\civ\lamps\lampharbour_off_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_02_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_03_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_arrow_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_prices_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_prices_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_05\shop_town_05_addon_f.p3d",
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
        "a3\structures_f_exp\industrial\port\cranerail_01_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouseshelter_01_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_block_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_chute_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_long_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_reclaimer_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_short_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_slope_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_stockpile_01_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_stockpile_02_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_tripper_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_16m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_16m_slope_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_hole_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_sugarcane_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_8m_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_8m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_curve_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_curve_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_end_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_up_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_shredder_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_wide_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_pillar_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_down_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_up_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_10m_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_15deg_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_20m_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_30deg_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_3m_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_7deg_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_bumper_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_crossing_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_switch_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_turnout_left_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_turnout_right_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_30m_end_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_30m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_30m_skids_end_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_30m_skids_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_40m_skids_end_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_40m_skids_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_arrow_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_centerline_10m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_centerline_20m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_centerline_5m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_threshold_20m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_0_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_1_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_2_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_3_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_5_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_7_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_9_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_05_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_11-29_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_11_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_13_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_23-05_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_23_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_29_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_31-13_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_31_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaytilenumber_07_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaytilenumber_25_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_mossy_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_3m_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_3m_round_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_round_f.p3d",
        "a3\structures_f_exp\military\trenches\trench_01_forest_f.p3d",
        "a3\structures_f_exp\military\trenches\trench_01_grass_f.p3d",
        "a3\structures_f_exp\military\trenches\trenchframe_01_f.p3d",
        "a3\structures_f_exp\naval\piers\breakwater_01_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_1m_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gap_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_02_l_1m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_8m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_d_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_pole_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_4m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_8m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_l_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_r_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_4m_nolc_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_nolc_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_d_nolc_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_gate_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_pole_f.p3d",
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
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_4m_nolc_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_8m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_8m_nolc_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_3m_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_6m_f.p3d",
        "a3\structures_f_exp\walls\railings\guardrailing_01_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_10m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_d_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_pole_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_16m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_4m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_d_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_gate_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_45_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_2m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_d_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_gate_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_pole_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_d_mossy_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_40m_end_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_40m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_17-35_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_17_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwayholdmark_35_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
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
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_01_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_03\multistorybuilding_03_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_04\multistorybuilding_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
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
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
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
        "a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_04\multistorybuilding_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_transformer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_chimney_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\boat_f_gamma\boat_civil_04\boat_civil_04_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_arm_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_arm_lowered_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_01_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_02_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_03_f.p3d",
        "a3\structures_f_exp\industrial\port\drydock_01_end_f.p3d",
        "a3\structures_f_exp\industrial\port\drydock_01_middle_f.p3d",
        "a3\structures_f_exp\industrial\port\gantrycrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\mobilecrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\mobilecrane_01_hook_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_02_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_shiploader_arm_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_shiploader_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_dock_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_platform_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_30deg_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_hut_f.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\props_f_exp\infrastructure\railways\locomotive_01_v1_f.p3d",
        "a3\props_f_exp\infrastructure\railways\locomotive_01_v2_f.p3d",
        "a3\props_f_exp\infrastructure\railways\locomotive_01_v3_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_empty_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_bridge_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_roof_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_large_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_small_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_big_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_medium_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_reservoirtower_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_smallfactory_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_end_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_junction_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_crusher_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_reclaimer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_clarifier_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_8m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_end_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_diffuser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_feeder_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_washer_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

};

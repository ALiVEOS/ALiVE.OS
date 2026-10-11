// ALiVE 3 index v3.1, made 2026-10-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: st_swamp (ALiVE 3 index v3.1, 2026-10-11)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-11", "web", true];

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

 if (tolower(_worldName) == "st_swamp") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\industrial\supplies\woodenbox_02_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\combineharvester_01_wreck_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_passenger_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_tank_f.p3d",
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_10m_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_4m_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_dmg_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_pink_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\chickencoop_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\hutch_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\stonewell_01_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\cultural\calvary_03\calvary_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_05_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\feedstorage_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\feedstorage_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_18_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_ground1_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_ground2_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_support_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_bigl_r_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_small_9_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_small_ground1_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_small_ground2_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_smalll_r_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_03_ruins_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_platform_segment_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_platform_start_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_tracke_25nolc_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_tracke_40nolc_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_tracke_8nolc_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_tracke_turnoutr_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_05_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_02_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_door_01_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_d_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_pole_old_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_3m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_3m_v2_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_end_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound04_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\stonewall_02_s_10m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_d_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_gate_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_d_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_end_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_end_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_gate_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_d_4m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_end_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_pole_f.p3d",
        "a3\structures_f_enoch\wrecks\mi8_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\powergenerator_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_epb\items\luggage\luggageheap_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\market\woodenshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\military\trenches\trenchframe_01_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_3m_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_6m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_pole_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_gate_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_2m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_d_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_gate_f.p3d",
        "a3\structures_f_kart\civ\sportsgrounds\oil_spill.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d",
        "st_swamp_b\data\watchtower\st_swamp_watchtower.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\belltowers\belltower_02_v2_ruins_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w06_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_ruins_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_white_ruins_f.p3d",
        "a3\structures_f_enoch\cultural\orthodoxchurches\orthodoxchurch_03_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_c_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_grey_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_factory_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_warehouse_small_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w06_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f_enoch\industrial\power\substation_01_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_small_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_factory_f.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-10-28 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: go_map_fjord (ALiVE 3 index v3.1, 2026-10-28)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-28", "web", true];

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

 if (tolower(_worldName) == "go_map_fjord") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\data\doorlocks\sandbags_1.p3d",
        "a3\structures_f_enoch\furniture\cases\locker\locker_closed_blue_v1.p3d",
        "a3\structures_f_enoch\furniture\cases\locker\locker_closed_blue_v2.p3d",
        "a3\structures_f_enoch\furniture\cases\locker\locker_closed_blue_v3.p3d",
        "a3\structures_f_enoch\furniture\cases\locker\locker_open_blue_v1.p3d",
        "a3\structures_f_enoch\furniture\cases\locker\locker_open_blue_v2.p3d",
        "a3\structures_f_enoch\furniture\cases\locker\locker_open_blue_v3.p3d",
        "a3\structures_f_enoch\furniture\cases\locker\locker_open_v1.p3d",
        "a3\structures_f_enoch\furniture\school_equipment\lab_teacher_bench.p3d",
        "go_structures_j\cultural\go_j_torii.p3d",
        "go_structures_n\decals\go_n_decal_airfieldtrim_winter_60m.p3d",
        "go_structures_n\industrial\timberpiles\go_n_timberlog.p3d",
        "go_structures_n\industrial\timberpiles\go_n_timberpile_01.p3d",
        "go_structures_n\industrial\timberpiles\go_n_timberpile_02.p3d",
        "go_structures_n\industrial\timberpiles\go_n_timberpile_03.p3d",
        "go_structures_n\infrastructure\highway\go_n_tunnel_end.p3d",
        "go_structures_n\infrastructure\highway\go_n_tunnel_middle.p3d",
        "go_structures_n\infrastructure\highway\go_n_tunnel_middle_ee.p3d",
        "go_structures_n\lakes\go_n_frozenlake_50m.p3d",
        "go_structures_n\naval\go_n_pier_straight.p3d",
        "go_structures_n\snowaddons\go_a3_warehouse_03_f_snowaddon.p3d",
        "go_structures_n\snowaddons\go_n_house_01_snowaddon.p3d",
        "go_structures_n\snowaddons\go_n_house_02_snowaddon.p3d",
        "go_structures_n\snowaddons\go_n_house_03_snowaddon.p3d",
        "go_structures_n\snowaddons\go_n_house_04_snowaddon.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d",
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_dam_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d",
        "a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_dam_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\medical\healthcenter_01_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_yellow_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_warehouse_small_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_01_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_03\multistorybuilding_03_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "go_structures_n\civilian\houses\go_n_house_01_red.p3d",
        "go_structures_n\civilian\houses\go_n_house_01_yellow.p3d",
        "go_structures_n\civilian\houses\go_n_house_02_blue.p3d",
        "go_structures_n\civilian\houses\go_n_house_02_red.p3d",
        "go_structures_n\civilian\houses\go_n_house_03_pink.p3d",
        "go_structures_n\civilian\houses\go_n_house_03_red.p3d",
        "go_structures_n\civilian\houses\go_n_house_04_green.p3d",
        "go_structures_n\civilian\houses\go_n_house_04_yellow.p3d",
        "go_structures_n\commercial\departmentstore\go_n_departmentstore.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "go_structures_n\commercial\departmentstore\go_n_departmentstore.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\medical\healthcenter_01_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_yellow_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "go_structures_n\civilian\houses\go_n_house_01_red.p3d",
        "go_structures_n\civilian\houses\go_n_house_01_yellow.p3d",
        "go_structures_n\civilian\houses\go_n_house_02_blue.p3d",
        "go_structures_n\civilian\houses\go_n_house_02_red.p3d",
        "go_structures_n\civilian\houses\go_n_house_03_pink.p3d",
        "go_structures_n\civilian\houses\go_n_house_03_red.p3d",
        "go_structures_n\civilian\houses\go_n_house_04_green.p3d",
        "go_structures_n\civilian\houses\go_n_house_04_yellow.p3d",
        "go_structures_n\commercial\departmentstore\go_n_departmentstore.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\substation_01_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_f.p3d",
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
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_small_f.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f_argo\infrastructure\seaports\lighthouse_03_red_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_arm_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_01_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_02_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_03_f.p3d",
        "a3\structures_f_exp\industrial\port\gantrycrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\mobilecrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\mobilecrane_01_hook_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_02_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_shiploader_arm_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_shiploader_f.p3d",
        "go_structures_n\naval\go_n_jetty.p3d",
        "go_structures_n\naval\go_n_jettybridge.p3d",
        "go_structures_n\naval\go_n_pier_corner_a.p3d",
        "go_structures_n\naval\go_n_pier_corner_b.p3d",
        "go_structures_n\naval\go_n_pier_exit.p3d",
        "go_structures_n\naval\go_n_pier_platform.p3d",
        "go_structures_n\naval\go_n_pier_stairs.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_small_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_small_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_big_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_medium_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\infrastructure\bridges\bridge_metal_01_25m_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_clarifier_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_diffuser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_washer_f.p3d"
    ];

};

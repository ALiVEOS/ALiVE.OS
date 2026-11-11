// ALiVE 3 index v3.1, made 2026-11-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: eaw_map (ALiVE 3 index v3.1, 2026-11-11)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-11", "web", true];

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
[ALIVE_mapBounds, worldName, 20480] call ALIVE_fnc_hashSet;

 if (tolower(_worldName) == "eaw_map") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "eaw_buildings_city\eaw_billboard_1.p3d",
        "eaw_buildings_city\eaw_billboard_10.p3d",
        "eaw_buildings_city\eaw_billboard_11.p3d",
        "eaw_buildings_city\eaw_billboard_12.p3d",
        "eaw_buildings_city\eaw_billboard_13.p3d",
        "eaw_buildings_city\eaw_billboard_14.p3d",
        "eaw_buildings_city\eaw_billboard_15.p3d",
        "eaw_buildings_city\eaw_billboard_16.p3d",
        "eaw_buildings_city\eaw_billboard_17.p3d",
        "eaw_buildings_city\eaw_billboard_18.p3d",
        "eaw_buildings_city\eaw_billboard_19.p3d",
        "eaw_buildings_city\eaw_billboard_2.p3d",
        "eaw_buildings_city\eaw_billboard_20.p3d",
        "eaw_buildings_city\eaw_billboard_21.p3d",
        "eaw_buildings_city\eaw_billboard_22.p3d",
        "eaw_buildings_city\eaw_billboard_23.p3d",
        "eaw_buildings_city\eaw_billboard_24.p3d",
        "eaw_buildings_city\eaw_billboard_25.p3d",
        "eaw_buildings_city\eaw_billboard_26.p3d",
        "eaw_buildings_city\eaw_billboard_27.p3d",
        "eaw_buildings_city\eaw_billboard_28.p3d",
        "eaw_buildings_city\eaw_billboard_29.p3d",
        "eaw_buildings_city\eaw_billboard_3.p3d",
        "eaw_buildings_city\eaw_billboard_30.p3d",
        "eaw_buildings_city\eaw_billboard_31.p3d",
        "eaw_buildings_city\eaw_billboard_32.p3d",
        "eaw_buildings_city\eaw_billboard_33.p3d",
        "eaw_buildings_city\eaw_billboard_34.p3d",
        "eaw_buildings_city\eaw_billboard_35.p3d",
        "eaw_buildings_city\eaw_billboard_36.p3d",
        "eaw_buildings_city\eaw_billboard_4.p3d",
        "eaw_buildings_city\eaw_billboard_5.p3d",
        "eaw_buildings_city\eaw_billboard_6.p3d",
        "eaw_buildings_city\eaw_billboard_7.p3d",
        "eaw_buildings_city\eaw_billboard_8.p3d",
        "eaw_buildings_city\eaw_billboard_9.p3d",
        "eaw_buildings_city\eaw_citywall_gate.p3d",
        "eaw_buildings_city\eaw_citywall_innercorner.p3d",
        "eaw_buildings_city\eaw_citywall_straight.p3d",
        "eaw_buildings_city\eaw_citywallstairwell.p3d",
        "eaw_buildings_city\eaw_fueltank.p3d",
        "eaw_buildings_city\eaw_gardenbridge.p3d",
        "eaw_buildings_village\eaw_plaster_arch.p3d",
        "eaw_buildings_village\eaw_plaster_building_1_1.p3d",
        "eaw_buildings_village\eaw_plaster_wall.p3d",
        "eaw_buildings_village\eaw_plaster_wall_damaged.p3d",
        "eaw_buildings_village\eaw_plaster_wall_damaged_left.p3d",
        "eaw_buildings_village\eaw_plaster_wall_damaged_right.p3d",
        "eaw_buildings_village\eaw_trench_entrance.p3d",
        "eaw_urban_props\eaw_2stall_1.p3d",
        "eaw_urban_props\eaw_3stall_2.p3d",
        "eaw_urban_props\eaw_3stall_3.p3d",
        "eaw_urban_props\eaw_basket_potato.p3d",
        "eaw_urban_props\eaw_box.p3d",
        "eaw_urban_props\eaw_box_bigdrinks.p3d",
        "eaw_urban_props\eaw_brick_bridge_flat.p3d",
        "eaw_urban_props\eaw_bridge_3m.p3d",
        "eaw_urban_props\eaw_bridge_5m.p3d",
        "eaw_urban_props\eaw_bridge_brick.p3d",
        "eaw_urban_props\eaw_empty_lod.p3d",
        "eaw_urban_props\eaw_empty_p3d.p3d",
        "eaw_urban_props\eaw_goat_01.p3d",
        "eaw_urban_props\eaw_goat_03.p3d",
        "eaw_urban_props\eaw_ground_cabbage.p3d",
        "eaw_urban_props\eaw_ground_plates.p3d",
        "eaw_urban_props\eaw_ground_potato.p3d",
        "eaw_urban_props\eaw_ground_tomato.p3d",
        "eaw_urban_props\eaw_lion_01.p3d",
        "eaw_urban_props\eaw_lion_02.p3d",
        "eaw_urban_props\eaw_lion_03.p3d",
        "eaw_urban_props\eaw_lion_04.p3d",
        "eaw_urban_props\eaw_lion_05.p3d",
        "eaw_urban_props\eaw_lion_06.p3d",
        "eaw_urban_props\eaw_market_gate.p3d",
        "eaw_urban_props\eaw_market_tent_plainred.p3d",
        "eaw_urban_props\eaw_market_tent_plainwhite.p3d",
        "eaw_urban_props\eaw_market_tent_whiteblue.p3d",
        "eaw_urban_props\eaw_market_tent_whitegreen.p3d",
        "eaw_urban_props\eaw_market_tent_whitered.p3d",
        "eaw_urban_props\eaw_market_tent_whiteyellow.p3d",
        "eaw_urban_props\eaw_market_tent_yellowblue.p3d",
        "eaw_urban_props\eaw_market_tent_yellowgreen.p3d",
        "eaw_urban_props\eaw_sidewalk_corner.p3d",
        "eaw_urban_props\eaw_sidewalk_corner_nolc.p3d",
        "eaw_urban_props\eaw_sidewalk_long.p3d",
        "eaw_urban_props\eaw_sidewalk_long_curbless.p3d",
        "eaw_urban_props\eaw_sidewalk_long_curbless_nolc.p3d",
        "eaw_urban_props\eaw_sidewalk_long_nolc.p3d",
        "eaw_urban_props\eaw_sidewalk_short.p3d",
        "eaw_urban_props\eaw_sidewalk_short_curbless.p3d",
        "eaw_urban_props\eaw_sidewalk_short_curbless_nolc.p3d",
        "eaw_urban_props\eaw_sidewalk_short_nolc.p3d",
        "eaw_urban_props\eaw_stall_medium.p3d",
        "eaw_urban_props\eaw_stall_tall.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_green_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_cooler_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d",
        "eaw_buildings_city\eaw_snlfbuilding.p3d",
        "eaw_buildings_village\eaw_trench.p3d",
        "eaw_buildings_village\eaw_trench_dirt.p3d",
        "eaw_buildings_village\eaw_trench_large_dirt.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "eaw_buildings_city\eaw_snlfbuilding.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "eaw_buildings_village\eaw_trench.p3d",
        "eaw_buildings_village\eaw_trench_dirt.p3d",
        "eaw_buildings_village\eaw_trench_entrance.p3d",
        "eaw_buildings_village\eaw_trench_large_dirt.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f_argo\cultural\church\church_01_v2_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_bastion_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_white_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_brick_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_loadinghouse_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_warehouse_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\i_shed_ind_old_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_warehouse_small_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "eaw_buildings_city\eaw_bankofchina.p3d",
        "eaw_buildings_city\eaw_bundoffices2.p3d",
        "eaw_buildings_city\eaw_centralhospital.p3d",
        "eaw_buildings_city\eaw_cityblock_2.p3d",
        "eaw_buildings_city\eaw_cityblock_3.p3d",
        "eaw_buildings_city\eaw_cityblock_4.p3d",
        "eaw_buildings_city\eaw_cityblock_6.p3d",
        "eaw_buildings_city\eaw_cityblock_7.p3d",
        "eaw_buildings_city\eaw_cityblock_8.p3d",
        "eaw_buildings_city\eaw_cityblock_9.p3d",
        "eaw_buildings_city\eaw_creekwarehouse.p3d",
        "eaw_buildings_city\eaw_customs_house.p3d",
        "eaw_buildings_city\eaw_hsbc_1.p3d",
        "eaw_buildings_city\eaw_hsbc_2.p3d",
        "eaw_buildings_city\eaw_newlese.p3d",
        "eaw_buildings_city\eaw_northtrain.p3d",
        "eaw_buildings_city\eaw_sihang_1.p3d",
        "eaw_buildings_city\eaw_sihang_2.p3d",
        "eaw_buildings_city\eaw_sihangsluice_left.p3d",
        "eaw_buildings_city\eaw_westbuilding_1.p3d",
        "eaw_buildings_city\eaw_westbuilding_10.p3d",
        "eaw_buildings_city\eaw_westbuilding_11.p3d",
        "eaw_buildings_city\eaw_westbuilding_12.p3d",
        "eaw_buildings_city\eaw_westbuilding_13.p3d",
        "eaw_buildings_city\eaw_westbuilding_14.p3d",
        "eaw_buildings_city\eaw_westbuilding_15.p3d",
        "eaw_buildings_city\eaw_westbuilding_16.p3d",
        "eaw_buildings_city\eaw_westbuilding_17.p3d",
        "eaw_buildings_city\eaw_westbuilding_18.p3d",
        "eaw_buildings_city\eaw_westbuilding_19.p3d",
        "eaw_buildings_city\eaw_westbuilding_2.p3d",
        "eaw_buildings_city\eaw_westbuilding_3.p3d",
        "eaw_buildings_city\eaw_westbuilding_4.p3d",
        "eaw_buildings_city\eaw_westbuilding_6.p3d",
        "eaw_buildings_city\eaw_westbuilding_7.p3d",
        "eaw_buildings_city\eaw_westbuilding_8.p3d",
        "eaw_buildings_city\eaw_westbuilding_9.p3d",
        "eaw_buildings_village\eaw_brick_house_1_2.p3d",
        "eaw_buildings_village\eaw_brick_house_1_3.p3d",
        "eaw_buildings_village\eaw_brick_small.p3d",
        "eaw_buildings_village\eaw_hut.p3d",
        "eaw_buildings_village\eaw_hut_brick.p3d",
        "eaw_buildings_village\eaw_hut_plaster.p3d",
        "eaw_buildings_village\eaw_hut_plaster_ruin.p3d",
        "eaw_buildings_village\eaw_hut_ruin.p3d",
        "eaw_buildings_village\eaw_hut_small.p3d",
        "eaw_buildings_village\eaw_pagodashort.p3d",
        "eaw_buildings_village\eaw_pagodatall.p3d",
        "eaw_buildings_village\eaw_plaster_building_1_2.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_1.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_2.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_3.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_3_ruin_noroof.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_4.p3d",
        "eaw_buildings_village\eaw_plaster_small.p3d",
        "eaw_buildings_village\eaw_wood_house_1.p3d",
        "eaw_buildings_village\eaw_wood_house_2.p3d",
        "eaw_buildings_village\eaw_wood_house_3.p3d",
        "eaw_buildings_village\eaw_wood_house_4.p3d",
        "eaw_buildings_village\eaw_wood_house_5.p3d",
        "eaw_buildings_village\eaw_wood_house_6.p3d",
        "eaw_buildings_village\eaw_wood_hut_1.p3d",
        "eaw_buildings_village\eaw_wood_hut_2.p3d",
        "eaw_buildings_village\eaw_wood_hut_3.p3d",
        "eaw_jp_town\eaw_jp_town_1.p3d",
        "eaw_jp_town\eaw_jp_town_10.p3d",
        "eaw_jp_town\eaw_jp_town_11.p3d",
        "eaw_jp_town\eaw_jp_town_12.p3d",
        "eaw_jp_town\eaw_jp_town_13.p3d",
        "eaw_jp_town\eaw_jp_town_14.p3d",
        "eaw_jp_town\eaw_jp_town_2.p3d",
        "eaw_jp_town\eaw_jp_town_4.p3d",
        "eaw_jp_town\eaw_jp_town_5.p3d",
        "eaw_jp_town\eaw_jp_town_6.p3d",
        "eaw_jp_town\eaw_jp_town_7.p3d",
        "eaw_jp_town\eaw_jp_town_8.p3d",
        "eaw_jp_town\eaw_jp_town_9.p3d",
        "eaw_jp_town\eaw_jp_town_school.p3d",
        "eaw_jp_village\eaw_jp_village_1.p3d",
        "eaw_jp_village\eaw_jp_village_10.p3d",
        "eaw_jp_village\eaw_jp_village_11.p3d",
        "eaw_jp_village\eaw_jp_village_12.p3d",
        "eaw_jp_village\eaw_jp_village_2.p3d",
        "eaw_jp_village\eaw_jp_village_3.p3d",
        "eaw_jp_village\eaw_jp_village_4.p3d",
        "eaw_jp_village\eaw_jp_village_5.p3d",
        "eaw_jp_village\eaw_jp_village_6.p3d",
        "eaw_jp_village\eaw_jp_village_7.p3d",
        "eaw_jp_village\eaw_jp_village_8.p3d",
        "eaw_jp_village\eaw_jp_village_9.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "eaw_buildings_city\eaw_bankofchina.p3d",
        "eaw_buildings_city\eaw_bundoffices2.p3d",
        "eaw_buildings_city\eaw_centralhospital.p3d",
        "eaw_buildings_city\eaw_customs_house.p3d",
        "eaw_buildings_city\eaw_hsbc_1.p3d",
        "eaw_buildings_city\eaw_hsbc_2.p3d",
        "eaw_buildings_city\eaw_sihang_1.p3d",
        "eaw_buildings_city\eaw_sihang_2.p3d",
        "eaw_buildings_city\eaw_sihangsluice_left.p3d",
        "eaw_buildings_city\eaw_westbuilding_19.p3d",
        "eaw_buildings_village\eaw_plaster_building_1_2.p3d",
        "eaw_jp_town\eaw_jp_town_school.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f_argo\cultural\church\church_01_v2_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "eaw_buildings_city\eaw_bankofchina.p3d",
        "eaw_buildings_city\eaw_bundoffices2.p3d",
        "eaw_buildings_city\eaw_centralhospital.p3d",
        "eaw_buildings_city\eaw_cityblock_2.p3d",
        "eaw_buildings_city\eaw_cityblock_3.p3d",
        "eaw_buildings_city\eaw_cityblock_4.p3d",
        "eaw_buildings_city\eaw_cityblock_6.p3d",
        "eaw_buildings_city\eaw_cityblock_7.p3d",
        "eaw_buildings_city\eaw_cityblock_8.p3d",
        "eaw_buildings_city\eaw_cityblock_9.p3d",
        "eaw_buildings_city\eaw_hsbc_1.p3d",
        "eaw_buildings_city\eaw_hsbc_2.p3d",
        "eaw_buildings_city\eaw_newlese.p3d",
        "eaw_buildings_city\eaw_westbuilding_1.p3d",
        "eaw_buildings_city\eaw_westbuilding_10.p3d",
        "eaw_buildings_city\eaw_westbuilding_11.p3d",
        "eaw_buildings_city\eaw_westbuilding_12.p3d",
        "eaw_buildings_city\eaw_westbuilding_13.p3d",
        "eaw_buildings_city\eaw_westbuilding_14.p3d",
        "eaw_buildings_city\eaw_westbuilding_16.p3d",
        "eaw_buildings_city\eaw_westbuilding_17.p3d",
        "eaw_buildings_city\eaw_westbuilding_18.p3d",
        "eaw_buildings_city\eaw_westbuilding_19.p3d",
        "eaw_buildings_city\eaw_westbuilding_2.p3d",
        "eaw_buildings_city\eaw_westbuilding_3.p3d",
        "eaw_buildings_city\eaw_westbuilding_4.p3d",
        "eaw_buildings_city\eaw_westbuilding_6.p3d",
        "eaw_buildings_city\eaw_westbuilding_7.p3d",
        "eaw_buildings_city\eaw_westbuilding_8.p3d",
        "eaw_buildings_city\eaw_westbuilding_9.p3d",
        "eaw_buildings_village\eaw_brick_house_1_2.p3d",
        "eaw_buildings_village\eaw_brick_house_1_3.p3d",
        "eaw_buildings_village\eaw_hut.p3d",
        "eaw_buildings_village\eaw_hut_brick.p3d",
        "eaw_buildings_village\eaw_hut_plaster.p3d",
        "eaw_buildings_village\eaw_hut_small.p3d",
        "eaw_buildings_village\eaw_plaster_building_1_2.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_1.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_2.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_3.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_4.p3d",
        "eaw_buildings_village\eaw_plaster_small.p3d",
        "eaw_buildings_village\eaw_wood_house_1.p3d",
        "eaw_buildings_village\eaw_wood_house_2.p3d",
        "eaw_buildings_village\eaw_wood_house_3.p3d",
        "eaw_buildings_village\eaw_wood_house_4.p3d",
        "eaw_buildings_village\eaw_wood_house_5.p3d",
        "eaw_buildings_village\eaw_wood_house_6.p3d",
        "eaw_buildings_village\eaw_wood_hut_1.p3d",
        "eaw_buildings_village\eaw_wood_hut_2.p3d",
        "eaw_buildings_village\eaw_wood_hut_3.p3d",
        "eaw_jp_town\eaw_jp_town_1.p3d",
        "eaw_jp_town\eaw_jp_town_11.p3d",
        "eaw_jp_town\eaw_jp_town_2.p3d",
        "eaw_jp_town\eaw_jp_town_4.p3d",
        "eaw_jp_town\eaw_jp_town_5.p3d",
        "eaw_jp_town\eaw_jp_town_6.p3d",
        "eaw_jp_town\eaw_jp_town_7.p3d",
        "eaw_jp_town\eaw_jp_town_8.p3d",
        "eaw_jp_town\eaw_jp_town_9.p3d",
        "eaw_jp_town\eaw_jp_town_school.p3d",
        "eaw_jp_village\eaw_jp_village_6.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_transformer_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "eaw_buildings_city\eaw_creekwarehouse.p3d",
        "eaw_buildings_city\eaw_customs_house.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_small_f.p3d",
        "eaw_buildings_city\eaw_northtrain.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_washer_f.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-10-14 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: eaw_sakeshima (ALiVE 3 index v3.1, 2026-10-14)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-14", "web", true];

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

 if (tolower(_worldName) == "eaw_sakeshima") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_front_water_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_rear_water_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_03_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_wall_d_l_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_wall_d_r_f.p3d",
        "a3\structures_f_enoch\industrial\farms\strawstack_01_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\shed_ind_old_ruins_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_airshaft_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_05_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_04_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_02_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_door_01_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_d_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_pole_old_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_ruins_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_pole_f.p3d",
        "eaw_buildings_city\eaw_cityriverbank.p3d",
        "eaw_buildings_city\eaw_cityriverbank_stair.p3d",
        "eaw_buildings_village\eaw_10m_watertile.p3d",
        "eaw_buildings_village\eaw_bamboo_1.p3d",
        "eaw_buildings_village\eaw_crater.p3d",
        "eaw_buildings_village\eaw_crater_large.p3d",
        "eaw_buildings_village\eaw_wood_wall.p3d",
        "eaw_fortification\eaw_sandbagwall1.p3d",
        "eaw_fortification\eaw_sandbagwall3.p3d",
        "eaw_fortification\eaw_sandbagwall4.p3d",
        "eaw_fortification\eaw_sandbagwall5.p3d",
        "eaw_fortification\eaw_sandbagwall6.p3d",
        "eaw_jp_prop\eaw_fence.p3d",
        "eaw_jp_prop\eaw_gardenpump.p3d",
        "eaw_jp_prop\eaw_jp_grave_1.p3d",
        "eaw_jp_prop\eaw_jp_grave_2.p3d",
        "eaw_jp_prop\eaw_jp_grave_3.p3d",
        "eaw_jp_prop\eaw_jp_grave_4.p3d",
        "eaw_jp_prop\eaw_jp_gravepost.p3d",
        "eaw_jp_prop\eaw_jp_gravepost_stack.p3d",
        "eaw_jp_prop\eaw_jp_gravepost_stackempty.p3d",
        "eaw_jp_prop\eaw_jp_lamp.p3d",
        "eaw_jp_prop\eaw_jp_lampwood.p3d",
        "eaw_jp_prop\eaw_jp_lantern7.p3d",
        "eaw_jp_prop\eaw_jp_lantern8.p3d",
        "eaw_jp_prop\eaw_jp_lantern9.p3d",
        "eaw_jp_prop\eaw_jp_pot_large.p3d",
        "eaw_jp_prop\eaw_jp_pot_small.p3d",
        "eaw_jp_prop\eaw_jp_shorttable.p3d",
        "eaw_jp_prop\eaw_jp_table.p3d",
        "eaw_jp_prop\eaw_jp_tub.p3d",
        "eaw_jp_prop\eaw_screen2.p3d",
        "eaw_jp_prop\eaw_screen4.p3d",
        "eaw_jp_prop\eaw_screensmall.p3d",
        "eaw_jp_prop\eaw_smallwashbin.p3d",
        "eaw_jp_prop\eaw_stonetorii.p3d",
        "eaw_jp_prop\eaw_stonetorii_2.p3d",
        "eaw_jp_prop\eaw_torii.p3d",
        "eaw_jp_prop\eaw_washbin.p3d",
        "eaw_jp_prop\eaw_washingboard.p3d",
        "eaw_jp_prop\eaw_washroom.p3d",
        "eaw_jp_trench\eaw_jp_trench_entrance.p3d",
        "eaw_jp_trench\eaw_jp_trench_entrance_mud.p3d",
        "eaw_jp_trench\eaw_jp_trench_mud.p3d",
        "eaw_jp_village\eaw_jp_village_wall_4m.p3d",
        "eaw_jp_village\eaw_jp_village_wall_8m.p3d",
        "eaw_jp_village\eaw_jp_village_wall_post.p3d",
        "eaw_jp_village\eaw_jp_village_woodwall_4m.p3d",
        "eaw_jp_village\eaw_jp_village_woodwall_8m.p3d",
        "eaw_jp_village\eaw_jp_village_woodwall_gate.p3d",
        "eaw_jp_village\eaw_jp_walkway.p3d",
        "eaw_ricefields\eaw_ricefield_large.p3d",
        "eaw_ricefields\eaw_ricefield_large_ripe_rice.p3d",
        "eaw_ricefields\eaw_ricefield_ripe_rice.p3d",
        "eaw_urban_props\eaw_2stall_2.p3d",
        "eaw_urban_props\eaw_3stall_1.p3d",
        "eaw_urban_props\eaw_bamboo_fence.p3d",
        "eaw_urban_props\eaw_barrel.p3d",
        "eaw_urban_props\eaw_basket_cabbage.p3d",
        "eaw_urban_props\eaw_basket_green.p3d",
        "eaw_urban_props\eaw_basket_peach.p3d",
        "eaw_urban_props\eaw_basket_sausage.p3d",
        "eaw_urban_props\eaw_basket_tomato.p3d",
        "eaw_urban_props\eaw_bench.p3d",
        "eaw_urban_props\eaw_box_drinks.p3d",
        "eaw_urban_props\eaw_box_emptydrinks.p3d",
        "eaw_urban_props\eaw_box_goods.p3d",
        "eaw_urban_props\eaw_boxes.p3d",
        "eaw_urban_props\eaw_boxes_old.p3d",
        "eaw_urban_props\eaw_crate.p3d",
        "eaw_urban_props\eaw_crate_tarp.p3d",
        "eaw_urban_props\eaw_dinnertable.p3d",
        "eaw_urban_props\eaw_drinking_stalls.p3d",
        "eaw_urban_props\eaw_goat_02.p3d",
        "eaw_urban_props\eaw_grain_stalls.p3d",
        "eaw_urban_props\eaw_grocer_stalls.p3d",
        "eaw_urban_props\eaw_grocery_stall.p3d",
        "eaw_urban_props\eaw_ground_drinks.p3d",
        "eaw_urban_props\eaw_kongo.p3d",
        "eaw_urban_props\eaw_market_wagon.p3d",
        "eaw_urban_props\eaw_packedup_stalls.p3d",
        "eaw_urban_props\eaw_restaurant_stalls.p3d",
        "eaw_urban_props\eaw_sack.p3d",
        "eaw_urban_props\eaw_sacks.p3d",
        "eaw_urban_props\eaw_shimakaze.p3d",
        "eaw_urban_props\eaw_short_storage_1.p3d",
        "eaw_urban_props\eaw_short_storage_2.p3d",
        "eaw_urban_props\eaw_stall_short.p3d",
        "eaw_urban_props\eaw_table.p3d",
        "eaw_urban_props\eaw_temple_1.p3d",
        "eaw_urban_props\eaw_wagon_goods.p3d",
        "eaw_urban_props\eaw_wagon_grain.p3d",
        "eaw_urban_props\eaw_wagon_grocery.p3d",
        "eaw_urban_props\eaw_wagon_packed.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_right_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_right_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_cooler_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",
        "eaw_fortification\eaw_jptent.p3d",
        "eaw_fortification\eaw_sandbagbunker1.p3d",
        "eaw_fortification\eaw_sandbagbunker2.p3d",
        "eaw_jp_trench\eaw_jp_trench.p3d",
        "eaw_jp_trench\eaw_jp_trench_large.p3d",
        "eaw_jp_trench\eaw_jp_trench_large_mud.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_left_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_right_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_right_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",
        "eaw_jp_trench\eaw_jp_trench.p3d",
        "eaw_jp_trench\eaw_jp_trench_entrance.p3d",
        "eaw_jp_trench\eaw_jp_trench_entrance_mud.p3d",
        "eaw_jp_trench\eaw_jp_trench_large.p3d",
        "eaw_jp_trench\eaw_jp_trench_large_mud.p3d",
        "eaw_jp_trench\eaw_jp_trench_mud.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_bastion_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_ruins_f.p3d",
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_ruins_f.p3d",
        "eaw_buildings_city\eaw_centralhospital.p3d",
        "eaw_buildings_city\eaw_creekwarehouse.p3d",
        "eaw_buildings_city\eaw_northtrain.p3d",
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
        "eaw_buildings_city\eaw_westbuilding_6.p3d",
        "eaw_buildings_city\eaw_westbuilding_7.p3d",
        "eaw_buildings_city\eaw_westbuilding_8.p3d",
        "eaw_buildings_city\eaw_westbuilding_9.p3d",
        "eaw_buildings_village\eaw_brick_house_1_2_ruin.p3d",
        "eaw_buildings_village\eaw_brick_house_1_3_ruin.p3d",
        "eaw_buildings_village\eaw_hut.p3d",
        "eaw_buildings_village\eaw_hut_brick_ruin.p3d",
        "eaw_buildings_village\eaw_hut_plaster_ruin.p3d",
        "eaw_buildings_village\eaw_hut_ruin.p3d",
        "eaw_buildings_village\eaw_hut_small.p3d",
        "eaw_buildings_village\eaw_pagodashort.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_1_ruin.p3d",
        "eaw_buildings_village\eaw_plaster_house_1_2_ruin_noroof.p3d",
        "eaw_buildings_village\eaw_wood_house_1.p3d",
        "eaw_buildings_village\eaw_wood_house_2.p3d",
        "eaw_buildings_village\eaw_wood_house_4.p3d",
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
        "eaw_jp_town\eaw_jp_town_3.p3d",
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
        "eaw_jp_village\eaw_jp_village_9.p3d",
        "eaw_jp_village\eaw_jp_village_pagoda.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_ruins_f.p3d",
        "eaw_buildings_city\eaw_centralhospital.p3d",
        "eaw_buildings_city\eaw_westbuilding_19.p3d",
        "eaw_jp_town\eaw_jp_town_school.p3d",
        "eaw_jp_village\eaw_jp_village_pagoda.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_ruins_f.p3d",
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "eaw_buildings_city\eaw_centralhospital.p3d",
        "eaw_buildings_city\eaw_westbuilding_10.p3d",
        "eaw_buildings_city\eaw_westbuilding_11.p3d",
        "eaw_buildings_city\eaw_westbuilding_12.p3d",
        "eaw_buildings_city\eaw_westbuilding_13.p3d",
        "eaw_buildings_city\eaw_westbuilding_14.p3d",
        "eaw_buildings_city\eaw_westbuilding_16.p3d",
        "eaw_buildings_city\eaw_westbuilding_17.p3d",
        "eaw_buildings_city\eaw_westbuilding_18.p3d",
        "eaw_buildings_city\eaw_westbuilding_19.p3d",
        "eaw_buildings_city\eaw_westbuilding_6.p3d",
        "eaw_buildings_city\eaw_westbuilding_7.p3d",
        "eaw_buildings_city\eaw_westbuilding_8.p3d",
        "eaw_buildings_city\eaw_westbuilding_9.p3d",
        "eaw_buildings_village\eaw_hut.p3d",
        "eaw_buildings_village\eaw_hut_small.p3d",
        "eaw_buildings_village\eaw_wood_house_1.p3d",
        "eaw_buildings_village\eaw_wood_house_2.p3d",
        "eaw_buildings_village\eaw_wood_house_4.p3d",
        "eaw_buildings_village\eaw_wood_house_6.p3d",
        "eaw_buildings_village\eaw_wood_hut_1.p3d",
        "eaw_buildings_village\eaw_wood_hut_2.p3d",
        "eaw_buildings_village\eaw_wood_hut_3.p3d",
        "eaw_jp_town\eaw_jp_town_1.p3d",
        "eaw_jp_town\eaw_jp_town_11.p3d",
        "eaw_jp_town\eaw_jp_town_2.p3d",
        "eaw_jp_town\eaw_jp_town_3.p3d",
        "eaw_jp_town\eaw_jp_town_4.p3d",
        "eaw_jp_town\eaw_jp_town_5.p3d",
        "eaw_jp_town\eaw_jp_town_6.p3d",
        "eaw_jp_town\eaw_jp_town_7.p3d",
        "eaw_jp_town\eaw_jp_town_8.p3d",
        "eaw_jp_town\eaw_jp_town_9.p3d",
        "eaw_jp_town\eaw_jp_town_school.p3d",
        "eaw_jp_village\eaw_jp_village_6.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "eaw_buildings_city\eaw_creekwarehouse.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "eaw_buildings_city\eaw_northtrain.p3d"
    ];

};

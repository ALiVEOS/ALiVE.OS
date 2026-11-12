// ALiVE 3 index v3.1, made 2026-11-12 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: spe_normandy (ALiVE 3 index v3.1, 2026-11-12)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-12", "web", true];

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

ALiVE_mapCompositionType = "Bocage";

 if (tolower(_worldName) == "spe_normandy") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ww2\spe_structures\items\agriculture\spe_apple_single.p3d",
        "ww2\spe_structures\military\supplies\spe_pak40box_01.p3d",
        "ww2\spe_structures\military\supplies\spe_pak40tube.p3d",
        "ww2\spe_structures\walls\stone\french light\spe_french_wall_light_01_gate.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_left_10d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_left_20d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_left_30d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_left_5d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_right_10d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_right_20d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_right_30d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_right_5d_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_10m_straight_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_20m_right_10d_junction_2m_01.p3d",
        "ww2\spe_water\rivers\spe_river_large_20m_right_10d_junction_2m_02.p3d",
        "ww2\spe_water\rivers\spe_river_medium_junction_01.p3d",
        "ww2\spe_water\rivers\spe_river_medium_junction_02.p3d",
        "ww2\spe_water\rivers\spe_river_medium_junction_03.p3d",
        "ww2\spe_water\rivers\spe_river_medium_junction_04.p3d",
        "ww2\spe_water\rivers\spe_river_medium_junction_05.p3d",
        "ww2\spe_water\rivers\spe_river_medium_junction_06.p3d",
        "ww2\spe_water\rivers\spe_river_medium_junction_07.p3d",
        "ww2\spe_water\rivers\spe_river_small_40m_straight_01.p3d",
        "ww2\spe_water\rivers\spe_river_small_junction_01.p3d",
        "ww2\spe_water\rivers\spe_river_small_junction_02.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_left_10d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_left_20d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_left_30d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_left_5d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_right_10d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_right_20d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_right_30d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_right_5d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_10m_straight_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_left_10d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_left_5d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_right_10d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_right_10d_junction_2m_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_right_10d_junction_2m_02.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_right_5d_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_straight_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_20m_straight_01_crossing_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_large_40m_straight_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_medium_junction_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_medium_junction_02.p3d",
        "ww2\spe_water\rivers\spe_river_water_medium_junction_03.p3d",
        "ww2\spe_water\rivers\spe_river_water_medium_junction_04.p3d",
        "ww2\spe_water\rivers\spe_river_water_medium_junction_05.p3d",
        "ww2\spe_water\rivers\spe_river_water_medium_junction_06.p3d",
        "ww2\spe_water\rivers\spe_river_water_medium_junction_07.p3d",
        "ww2\spe_water\rivers\spe_river_water_small_40m_straight_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_small_junction_01.p3d",
        "ww2\spe_water\rivers\spe_river_water_small_junction_02.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_01.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_02.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_03.p3d",
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\civilian\dominants\spe_townhall.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d",
        "ww2\spe_structures\military\spe_guardbox.p3d",
        "ww2\spe_structures\military\spe_tent_01.p3d",
        "ww2\spe_structures\military\spe_tent_02.p3d",
        "ww2\spe_structures\military\spe_tent_03.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_lightblue_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_red_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_yellow_damaged.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ww2\spe_structures\civilian\church\spe_church_belltower_01.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_03.p3d",
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\military\spe_guardbox.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_lightblue_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_red_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_yellow_damaged.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\military\spe_tent_01.p3d",
        "ww2\spe_structures\military\spe_tent_02.p3d",
        "ww2\spe_structures\military\spe_tent_03.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\civilian\dominants\spe_townhall.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_lightblue_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_red_damaged.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\props_f_enoch\civilian\forest\feedshack_01_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_dam_f.p3d",
        "a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_dam_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_raw_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_ruins_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_ruins_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_bastion_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_white_damaged_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_white_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_yellow_damaged_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_yellow_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_c_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_c_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_warehouse_small_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_warehouse_small_ruins_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_ruins_f.p3d",
        "ww2\spe_structures\civilian\church\spe_church_front.p3d",
        "ww2\spe_structures\civilian\church\spe_church_hallway.p3d",
        "ww2\spe_structures\civilian\church\spe_church_rear_01.p3d",
        "ww2\spe_structures\civilian\church\spe_church_rear_02.p3d",
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\civilian\house\spe_bunkhouse.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_01.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_01b.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_01c.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_02.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_03.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_04.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_05.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_06.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_02.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_03.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_04.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_02.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_03.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_04.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_03.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_04.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_05.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d",
        "ww2\spe_structures\commercial\office\spe_office_small_01.p3d",
        "ww2\spe_structures\commercial\office\spe_office_small_02.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_01.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_02.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_03.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_04.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_barn_01.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_barn_thatch_01.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_barn_thatch_02.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_farmhouse_01.p3d",
        "ww2\spe_structures\infrastructure\water_tower\spe_water_tower_01.p3d",
        "ww2\spe_structures\infrastructure\water_tower\spe_water_tower_01_camo.p3d",
        "ww2\spe_structures\ruins\spe_barn_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_corner_house_02_ruins.p3d",
        "ww2\spe_structures\ruins\spe_corner_house_05_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_arch_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_big_02_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_big_04_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_02_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_03_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_04_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_thatch_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_thatch_03_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_thatch_05_ruins.p3d",
        "ww2\spe_structures\ruins\spe_office_small_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_shop_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_shop_02_ruins.p3d",
        "ww2\spe_structures\ruins\spe_shop_04_ruins.p3d",
        "ww2\spe_structures\spe_a3_agriculture\spe_a3_barn_01_brown.p3d",
        "ww2\spe_structures\spe_a3_agriculture\spe_a3_barn_01_grey.p3d",
        "ww2\spe_structures\spe_a3_camps\spe_a3_caravan_01_green.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_lightblue_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_red_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_yellow_damaged.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\civilian\house\spe_bunkhouse.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_03.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_raw_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "ww2\spe_structures\civilian\church\spe_church_front.p3d",
        "ww2\spe_structures\civilian\church\spe_church_hallway.p3d",
        "ww2\spe_structures\civilian\house\spe_bunkhouse.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_01.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_01b.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_01c.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_02.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_03.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_04.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_05.p3d",
        "ww2\spe_structures\civilian\house\spe_corner_house_06.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_02.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_03.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_04.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_02.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_03.p3d",
        "ww2\spe_structures\civilian\house\spe_house_small_04.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_03.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_04.p3d",
        "ww2\spe_structures\civilian\house\spe_house_thatch_05.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d",
        "ww2\spe_structures\commercial\office\spe_office_small_01.p3d",
        "ww2\spe_structures\commercial\office\spe_office_small_02.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_01.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_02.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_03.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_04.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_barn_01.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_barn_thatch_01.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_farmhouse_01.p3d",
        "ww2\spe_structures\spe_a3_agriculture\spe_a3_barn_01_brown.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_lightblue_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_damaged.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_red_damaged.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\structures_f_enoch\infrastructure\railways\rail_station_small_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ww2\spe_structures\infrastructure\water_tower\spe_water_tower_01.p3d",
        "ww2\spe_structures\infrastructure\water_tower\spe_water_tower_01_camo.p3d"
    ];

};

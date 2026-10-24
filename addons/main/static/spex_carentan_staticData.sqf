// ALiVE 3 index v3.1, made 2026-10-22 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: spex_carentan (ALiVE 3 index v3.1, 2026-10-22)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-22", "web", true];

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

 if (tolower(_worldName) == "spex_carentan") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ww2\spe_structures2\infrastructure\platforms\spe_platform_corner_90.p3d",
        "ww2\spe_structures2\items\agriculture\spe_vegetable_patch_02_decal.p3d",
        "ww2\spe_structures2\items\agriculture\spe_vegetable_patch_03_decal.p3d",
        "ww2\spe_structures2\military\spe_tarp_corner_l.p3d",
        "ww2\spe_structures2\military\spe_tarp_corner_r.p3d",
        "ww2\spe_structures2\military\spe_tarp_rectangle_02.p3d",
        "ww2\spe_structures2\military\spe_tarp_side.p3d",
        "ww2\spe_structures2\military\spe_tarp_small_01.p3d",
        "ww2\spe_structures2\military\spe_trenchlogwall_01_post.p3d",
        "ww2\spe_structures2\military\spe_trenchlogwall_01_roof.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_07_cover.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_08_cover.p3d",
        "ww2\spe_structures\items\cultural\spe_church_effigy_mary.p3d",
        "ww2\spe_structures\military\spe_netting_01.p3d",
        "ww2\spe_structures\military\spe_netting_02.p3d",
        "ww2\spe_structures\military\trenches\spe_cnc_trench_4m.p3d",
        "ww2\spe_structures\spe_a3_props_exp\spe_a3_bulldozer_01_wreck_green_us.p3d",
        "ww2\spex_structures\infrastructure\spex_barquette.p3d",
        "ww2\spex_structures\infrastructure\spex_lock_gate.p3d",
        "ww2\spex_structures\infrastructure\spex_lock_wall.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_burn.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_burn2.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_burn3.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_lumme1.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_lumme2.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_water2_light.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_water3_light.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\decals\tem_utah_beach_water5_light.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\bridge\tem_bridge1.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_entrance_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_short_dirt.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_01.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_02.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_03.p3d",
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\civilian\dominants\spe_townhall.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d",
        "ww2\spe_structures\military\casemate\spe_58c.p3d",
        "ww2\spe_structures\military\spe_guardbox.p3d",
        "ww2\spe_structures\military\spe_tent_02.p3d",
        "ww2\spe_structures\military\spe_tent_03.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_corner_60_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_corner_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_end_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_long_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_t_dirt.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ww2\spe_structures\civilian\church\spe_church_belltower_01.p3d",
        "ww2\spe_structures\civilian\church\spe_church_belltower_03.p3d",
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\military\spe_guardbox.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\military\spe_tent_02.p3d",
        "ww2\spe_structures\military\spe_tent_03.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\civilian\dominants\spe_townhall.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_corner_60_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_corner_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_end_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_long_dirt.p3d",
        "ww2\spex_terrains\tem_utah_beach_objects\objects\trenches\utah_beach_trench_t_dirt.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_c_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_01.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_02.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_03.p3d",
        "ww2\spe_structures2\commercial\shop\spe_shop_05.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_office.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_shed.p3d",
        "ww2\spe_structures2\infrastructure\spe_trainstation.p3d",
        "ww2\spe_structures\civilian\church\spe_church_front.p3d",
        "ww2\spe_structures\civilian\church\spe_church_hallway.p3d",
        "ww2\spe_structures\civilian\church\spe_church_rear_01.p3d",
        "ww2\spe_structures\civilian\church\spe_church_rear_02.p3d",
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
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
        "ww2\spe_structures\ruins\spe_barn_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_big_04_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_01_ruins.p3d",
        "ww2\spe_structures\spe_a3_agriculture\spe_a3_barn_01_grey.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ww2\spe_structures\civilian\dominants\spe_chateau_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_03.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ww2\spe_structures2\civilian\house\spe_townhouse_01.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_02.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_03.p3d",
        "ww2\spe_structures2\commercial\shop\spe_shop_05.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_office.p3d",
        "ww2\spe_structures2\infrastructure\spe_trainstation.p3d",
        "ww2\spe_structures\civilian\church\spe_church_front.p3d",
        "ww2\spe_structures\civilian\church\spe_church_hallway.p3d",
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
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d",
        "ww2\spe_structures\commercial\office\spe_office_small_01.p3d",
        "ww2\spe_structures\commercial\office\spe_office_small_02.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_01.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_02.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_03.p3d",
        "ww2\spe_structures\commercial\shops\spe_shop_04.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_barn_01.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_barn_thatch_01.p3d",
        "ww2\spe_structures\industrial\agriculture\spe_farmhouse_01.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\structures_f_enoch\infrastructure\railways\rail_station_small_f.p3d",
        "ww2\spe_structures2\infrastructure\spe_trainstation.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ww2\spe_structures\infrastructure\water_tower\spe_water_tower_01.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-11-12 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: spe_mortain (ALiVE 3 index v3.1, 2026-11-12)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "spe_mortain") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ww2\spe_structures2\industrial\mine\spe_mine_crane.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_entrance.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mineoven.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mineoven_tall.p3d",
        "ww2\spe_structures2\infrastructure\platforms\spe_platform_corner_135.p3d",
        "ww2\spe_structures2\infrastructure\platforms\spe_platform_corner_90.p3d",
        "ww2\spe_structures2\infrastructure\spe_mortain_wall_4.p3d",
        "ww2\spe_structures2\items\agriculture\spe_vegetable_patch_02_decal.p3d",
        "ww2\spe_structures2\items\agriculture\spe_vegetable_patch_03_decal.p3d",
        "ww2\spe_structures2\items\civilian\spe_wheel.p3d",
        "ww2\spe_structures2\military\spe_decoy_01.p3d",
        "ww2\spe_structures2\military\spe_tarp_corner_l.p3d",
        "ww2\spe_structures2\military\spe_tarp_corner_r.p3d",
        "ww2\spe_structures2\military\spe_tarp_rectangle_02.p3d",
        "ww2\spe_structures2\military\spe_tarp_side.p3d",
        "ww2\spe_structures2\military\spe_tarp_small_01.p3d",
        "ww2\spe_structures2\military\spe_tarp_small_02_l.p3d",
        "ww2\spe_structures2\military\spe_tarp_small_02_r.p3d",
        "ww2\spe_structures2\military\spe_trenchlogwall_01_post.p3d",
        "ww2\spe_structures2\military\spe_trenchlogwall_01_roof.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_05.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_06.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_06_stack.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_07.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_07_cover.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_07_stack.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_08.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_08_cover.p3d",
        "ww2\spe_structures2\military\supplies\spe_ammocrate_us_08_stack.p3d",
        "ww2\spe_structures\military\supplies\spe_ammocrate_us_01.p3d",
        "ww2\spe_structures\military\supplies\spe_ammocrate_us_02.p3d",
        "ww2\spe_structures\military\supplies\spe_ammocrate_us_04.p3d",
        "ww2\spe_structures\military\supplies\spe_artillery_rounds_us.p3d",
        "ww2\spe_structures\military\supplies\spe_foodcrate_us_a.p3d",
        "ww2\spe_structures\military\supplies\spe_foodcrate_us_b.p3d",
        "ww2\spe_structures\military\supplies\spe_foodcrate_us_c.p3d",
        "ww2\spe_structures\military\supplies\spe_foodcrate_us_d.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ww2\spe_structures\civilian\church\spe_church_belltower_03.p3d",
        "ww2\spe_structures\civilian\dominants\spe_townhall.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d",
        "ww2\spe_structures\military\spe_guardbox.p3d",
        "ww2\spe_structures\military\spe_tent_01.p3d",
        "ww2\spe_structures\military\spe_tent_02.p3d",
        "ww2\spe_structures\military\spe_tent_03.p3d",
        "ww2\spe_structures\ruins\spe_house_arch_02_ruins.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ww2\spe_structures\civilian\church\spe_church_belltower_03.p3d",
        "ww2\spe_structures\military\spe_guardbox.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ww2\spe_structures\military\spe_tent_01.p3d",
        "ww2\spe_structures\military\spe_tent_02.p3d",
        "ww2\spe_structures\military\spe_tent_03.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ww2\spe_structures\civilian\dominants\spe_townhall.p3d",
        "ww2\spe_structures\civilian\house\spe_house_arch_02.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_yellow_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_c_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_ruins_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_warehouse_small_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_01.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_02.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_03.p3d",
        "ww2\spe_structures2\commercial\shop\spe_shop_05.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_church.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_cloister.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_crypt.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_library.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_long_left.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_long_right.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_addon.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_long.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_short.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_short_end.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_tower.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_tower_corner.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_tower_end.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_tail_left.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_tail_right.p3d",
        "ww2\spe_structures2\cultural\chapel\spe_chapel_01.p3d",
        "ww2\spe_structures2\cultural\church\spe_church_evroult_hall.p3d",
        "ww2\spe_structures2\cultural\church\spe_church_evroult_shorttower.p3d",
        "ww2\spe_structures2\cultural\church\spe_church_evroult_talltower.p3d",
        "ww2\spe_structures2\cultural\church\spe_church_evroult_wings.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_office.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_platform.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_shed.p3d",
        "ww2\spe_structures2\infrastructure\spe_trainstation.p3d",
        "ww2\spe_structures\civilian\church\spe_church_front.p3d",
        "ww2\spe_structures\civilian\church\spe_church_hallway.p3d",
        "ww2\spe_structures\civilian\church\spe_church_rear_01.p3d",
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
        "ww2\spe_structures\ruins\spe_corner_house_02_ruins.p3d",
        "ww2\spe_structures\ruins\spe_corner_house_05_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_arch_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_big_02_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_big_04_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_02_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_03_ruins.p3d",
        "ww2\spe_structures\ruins\spe_house_small_04_ruins.p3d",
        "ww2\spe_structures\ruins\spe_manor_house_ruins.p3d",
        "ww2\spe_structures\ruins\spe_office_small_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_shop_01_ruins.p3d",
        "ww2\spe_structures\ruins\spe_shop_02_ruins.p3d",
        "ww2\spe_structures\spe_a3_agriculture\spe_a3_barn_01_brown.p3d",
        "ww2\spe_structures\spe_a3_agriculture\spe_a3_barn_01_grey.p3d",
        "ww2\spe_structures\spe_a3_camps\spe_a3_caravan_01_green.p3d",
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_damaged.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_crypt.p3d",
        "ww2\spe_structures\civilian\house\spe_bunkhouse.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_01.p3d",
        "ww2\spe_structures\civilian\house\spe_house_big_03.p3d",
        "ww2\spe_structures\civilian\house\spe_manor_house.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_01.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_02.p3d",
        "ww2\spe_structures2\civilian\house\spe_townhouse_03.p3d",
        "ww2\spe_structures2\commercial\shop\spe_shop_05.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_church.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_cloister.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_library.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_long_left.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_long_right.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_addon.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_long.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_short.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_short_end.p3d",
        "ww2\spe_structures2\cultural\abbaye\spe_abbaye_r_tower_corner.p3d",
        "ww2\spe_structures2\cultural\chapel\spe_chapel_01.p3d",
        "ww2\spe_structures2\cultural\church\spe_church_evroult_hall.p3d",
        "ww2\spe_structures2\cultural\church\spe_church_evroult_wings.p3d",
        "ww2\spe_structures2\industrial\mine\spe_mine_office.p3d",
        "ww2\spe_structures2\infrastructure\spe_trainstation.p3d",
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
        "ww2\spe_structures\spe_a3_cultural\spe_a3_church_04_white_damaged.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\structures_f_enoch\infrastructure\railways\rail_station_big_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_station_small_f.p3d",
        "ww2\spe_structures2\infrastructure\spe_trainstation.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ww2\spe_structures\infrastructure\water_tower\spe_water_tower_01.p3d"
    ];

};

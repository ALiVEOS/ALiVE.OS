// ALiVE 3 index v3.1, made 2026-10-13 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: 3as_onderon (ALiVE 3 index v3.1, 2026-10-13)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-13", "web", true];

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

 if (tolower(_worldName) == "3as_onderon") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "3as\3as_environment\cliffs_tatooine\cliff1.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff10.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff11.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff2.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff3.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff4.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff5.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff6.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff7.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff8.p3d",
        "3as\3as_environment\cliffs_tatooine\cliff9.p3d",
        "3as\3as_imperial\model\3as_endorplatform.p3d",
        "3as\3as_imperial\model\3as_imperial_checkpoint.p3d",
        "3as\3as_imperial\model\3as_imperial_radar.p3d",
        "3as\3as_platforms\platforms\baseplate_10x10.p3d",
        "3as\3as_platforms\platforms\baseplate_10x10_thin.p3d",
        "3as\3as_platforms\platforms\baseplate_20x20_thin.p3d",
        "3as\3as_platforms\platforms\baseplate_30x30.p3d",
        "3as\3as_platforms\platforms\baseplate_50x50.p3d",
        "3as\3as_props\crates\big_box_2.p3d",
        "3as\3as_props\debris\debris6.p3d",
        "3as\3as_props\debris\debris8.p3d",
        "3as\3as_props\laserwalls\model\3as_wall_laser.p3d",
        "3as\3as_props\laserwalls\model\3as_wall_laser_corner.p3d",
        "3as\3as_props\laserwalls\model\3as_wall_laser_door.p3d",
        "3as\3as_props\pipes\cisfuelpipes.p3d",
        "3as\3as_props\pipes\cisfuelpipesend.p3d",
        "3as\3as_props\pipes\cisfuelpump2.p3d",
        "3as\3as_props\terminals\holotable_octagon.p3d",
        "3as\3as_structures\city\walls\city_wall.p3d",
        "3as\3as_structures\city\walls\city_wall_desert.p3d",
        "3as\3as_structures\city\walls\city_wall_turn_90.p3d",
        "3as\3as_structures\fob\3as_cis_ramp_v2.p3d",
        "3as\3as_structures\fob\3as_cis_wall_corner_v2.p3d",
        "3as\3as_structures\fob\3as_cis_wall_gate_v2.p3d",
        "3as\3as_structures\fob\3as_cis_wall_long_v2.p3d",
        "3as\3as_structures\fob\3as_cis_wall_platform_med_hanging_v2.p3d",
        "3as\3as_structures\fob\3as_cis_wall_short_v2.p3d",
        "3as\3as_structures\interiors\3as_cis_door_med.p3d",
        "3as\3as_structures\interiors\3as_prison_blast_door.p3d",
        "3as\3as_structures\interiors\3as_prison_corridor_short.p3d",
        "3as\3as_structures\interiors\cis_small_hallway_doorway.p3d",
        "3as\3as_structures\interiors\prison_blast_door_closed.p3d",
        "3as\3as_structures\interiors\prison_corridor_long.p3d",
        "3as\3as_structures\lights\3as_light_s_cis.p3d",
        "3as\3as_structures\lights\3as_light_s_reb.p3d",
        "3as\3as_structures\lights\3as_light_s_small.p3d",
        "3as\3as_structures\lights\3as_light_s_tall.p3d",
        "3as\3as_structures\motherbase\mb_bridge_large.p3d",
        "3as\3as_structures\trenches\trench_long.p3d",
        "3as\3as_structures\trenches\trench_short.p3d",
        "3as\prop_kamino\kamino_large_bridge\model\large_bridge_long.p3d",
        "3as\prop_kamino\kamino_large_platform\model\large_platform_small.p3d",
        "3as\prop_kamino\kamino_lights\model\large_light.p3d",
        "3as\prop_tatooine\buildings\model\3as_tatooine_landingpad.p3d",
        "3as\prop_tatooine\buildings\model\3as_tatooine_moistureevaporator.p3d",
        "3as\prop_tatooine\buildings\model\3as_tatooine_wall1.p3d",
        "3as\prop_tatooine\buildings\model\3as_tatooine_wallarch.p3d",
        "3as\prop_tatooine\buildings\model\3as_tatooine_wallpillar.p3d",
        "3as\prop_tatooine\buildings\model\3as_tatooine_wallpillarshort.p3d",
        "3as\prop_tatooine\buildings\model\3as_tatooine_wallshort.p3d",
        "3as\prop_tatooine\props\model\3as_tatooine_generator.p3d",
        "3as\prop_tatooine\shade\model\shade1blue.p3d",
        "3as\prop_tatooine\shade\model\shade1brown.p3d",
        "3as\prop_tatooine\shade\model\shade1red.p3d",
        "3as\prop_tatooine\shade\model\shade2blue.p3d",
        "3as\prop_tatooine\shade\model\shade2brown.p3d",
        "3as\prop_tatooine\shade\model\shade2red.p3d",
        "3as\prop_tatooine\shade\model\shade3blue.p3d",
        "3as\prop_tatooine\shade\model\shade4blue.p3d",
        "3as\prop_tatooine\shade\model\shade5blue.p3d",
        "3as\prop_tatooine\shade\model\shade5brown.p3d",
        "3as\prop_tatooine\shade\model\shade5red.p3d",
        "3as\prop_tatooine\shade\model\shade6blue.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_jabbapalace_door.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_jabbapalace_largedoor.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_jabbapalace_mainentrance.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_jabbaspalace.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_jabbaspalacetower1.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_large2door.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_largearch.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_largehallway.p3d",
        "3as\prop_tatooine_jabbaspalace\jabbaspalace\model\3as_tatooine_roommedium.p3d",
        "a3\structures_f\dominants\amphitheater\amphitheater_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_06_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_08_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_09_f.p3d",
        "a3\structures_f_argo\cultural\statues\pedestal_01_f.p3d",
        "a3\structures_f_argo\cultural\statues\statue_01_f.p3d",
        "a3\structures_f_argo\cultural\statues\statue_02_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\stonewell_01_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_11_f.p3d",
        "a3\structures_f_enoch\cultural\statues\statue_03_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\manurepile_01_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_03_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\ancientstatue_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\ancientstatue_02_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\petroglyphwall_01_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\petroglyphwall_02_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\raistone_01_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_8m_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_gate_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_stockpile_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_sugarcane_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_orange\humanitarian\flags\banner_01_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "3as\3as_imperial\model\3as_imperial_fuel_pod.p3d",
        "3as\3as_structures\fob\3as_cis_bunker_v2.p3d",
        "3as\3as_structures\fob\3as_cis_wall_tower_v2.p3d",
        "3as\3as_structures\interiors\prison_enterance.p3d",
        "3as\3as_structures\interiors\prison_intersection_2.p3d",
        "3as\3as_structures\shieldgenerator\3as_tent.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "3as\3as_structures\shieldgenerator\3as_tent.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "3as\3as_structures\fob\3as_cis_bunker_v2.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "3as\3as_structures\landingpads\pad_cis.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "3as\3as_structures\landingpads\pad_cis.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\dominants\castle\castle_01_tower_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_blue_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_bastion_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_factory_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_blue_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\industrial\port\mobilecrane_01_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_hut_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "3as\3as_imperial\model\3as_imperial_fuel_pod.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_factory_f.p3d"
    ];

};

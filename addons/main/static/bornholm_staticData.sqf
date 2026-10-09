// ALiVE 3 index v3.1, made 2026-10-09 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: bornholm (ALiVE 3 index v3.1, 2026-10-09)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-09", "web", true];

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

 if (tolower(_worldName) == "bornholm") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\roads_f\runway\invisibleroadway_triangle_f.p3d",
        "a3\roads_f\runway\runway_end02_f.p3d",
        "a3\roads_f\runway\runway_main_f.p3d",
        "a3\roads_f\sidewalks\sw_c_body_6m_f.p3d",
        "a3\roads_f\sidewalks\sw_c_end_l_f.p3d",
        "a3\roads_f\sidewalks\sw_c_turn_f.p3d",
        "a3\structures_f\bridges\bridge_01_f.p3d",
        "a3\structures_f\civ\lamps\lampstadium_f.p3d",
        "a3\structures_f\dominants\amphitheater\amphitheater_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_06_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_09_f.p3d",
        "a3\structures_f\ind\cargo\cargo40_color_v3_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_conv2_f.p3d",
        "a3\structures_f\ind\factory\factory_tunnel_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_rust_ruins_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_3_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall6_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall_corner_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall_corridor_f.p3d",
        "a3\structures_f\training\target_rail_f.p3d",
        "es\bornholmobjects\bo_a_office01.p3d",
        "es\bornholmobjects\bo_a_tvtower_mid.p3d",
        "es\bornholmobjects\bo_a_tvtower_top.p3d",
        "es\bornholmobjects\bo_housev_1i3.p3d",
        "es\bornholmobjects\bo_housev_2t1.p3d",
        "es\bornholmobjects\bo_stanice.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_tower_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_ruins_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_ruins_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_ruins_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "a3\structures_f\mil\radar\radar_ruins_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\mil\radar\radar_small_ruins_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_house_v1_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "es\bornholmobjects\bo_hlidac_budka.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\belltowers\belltower_02_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_small_v1_ruins_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_ruins_f.p3d",
        "a3\structures_f\civ\infoboards\infostand_v1_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_tower_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_small_ruins_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\airport\airport_center_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\factory\factory_main_part2_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "es\bornholmobjects\bo_a_generalstore_01.p3d",
        "es\bornholmobjects\bo_barn_w_01.p3d",
        "es\bornholmobjects\bo_barn_w_02.p3d",
        "es\bornholmobjects\bo_bouda3.p3d",
        "es\bornholmobjects\bo_deutshe.p3d",
        "es\bornholmobjects\bo_deutshe_mini.p3d",
        "es\bornholmobjects\bo_domek_rosa.p3d",
        "es\bornholmobjects\bo_dum_mesto.p3d",
        "es\bornholmobjects\bo_dum_mesto2.p3d",
        "es\bornholmobjects\bo_dum_mesto2l.p3d",
        "es\bornholmobjects\bo_dum_mesto3.p3d",
        "es\bornholmobjects\bo_dum_olezlina.p3d",
        "es\bornholmobjects\bo_dum_rasovna.p3d",
        "es\bornholmobjects\bo_dumruina_mini.p3d",
        "es\bornholmobjects\bo_farm_cowshed_a.p3d",
        "es\bornholmobjects\bo_farm_cowshed_b.p3d",
        "es\bornholmobjects\bo_farm_cowshed_c.p3d",
        "es\bornholmobjects\bo_houseb_tenement.p3d",
        "es\bornholmobjects\bo_houseblock_a1_1.p3d",
        "es\bornholmobjects\bo_houseblock_a3.p3d",
        "es\bornholmobjects\bo_houseblock_b2.p3d",
        "es\bornholmobjects\bo_houseblock_b3.p3d",
        "es\bornholmobjects\bo_houseblock_b4.p3d",
        "es\bornholmobjects\bo_houseblock_b5.p3d",
        "es\bornholmobjects\bo_houseblock_b6.p3d",
        "es\bornholmobjects\bo_housev2_01a.p3d",
        "es\bornholmobjects\bo_housev2_02_interier.p3d",
        "es\bornholmobjects\bo_housev2_04.p3d",
        "es\bornholmobjects\bo_housev2_04_interier.p3d",
        "es\bornholmobjects\bo_housev_1i1.p3d",
        "es\bornholmobjects\bo_housev_1i4.p3d",
        "es\bornholmobjects\bo_housev_1l1.p3d",
        "es\bornholmobjects\bo_housev_1t.p3d",
        "es\bornholmobjects\bo_housev_2i.p3d",
        "es\bornholmobjects\bo_housev_2t2.p3d",
        "es\bornholmobjects\bo_housev_3i2.p3d",
        "es\bornholmobjects\bo_housev_3i3.p3d",
        "es\bornholmobjects\bo_housev_3i4.p3d",
        "es\bornholmobjects\bo_hut06.p3d",
        "es\bornholmobjects\bo_ind_stack_big.p3d",
        "es\bornholmobjects\bo_sara_domek_sedy.p3d",
        "es\bornholmobjects\bo_shed_ind02.p3d",
        "es\bornholmobjects\bo_shed_m01.p3d",
        "es\bornholmobjects\bo_shed_m03.p3d",
        "es\bornholmobjects\bo_shed_w01.p3d",
        "es\bornholmobjects\bo_shed_w02.p3d",
        "es\bornholmobjects\bo_shed_w03.p3d",
        "es\bornholmobjects\bo_shed_w4.p3d",
        "es\bornholmobjects\bo_shed_wooden.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "es\bornholmobjects\bo_a_generalstore_01.p3d",
        "es\bornholmobjects\bo_dum_mesto3.p3d",
        "es\bornholmobjects\bo_houseb_tenement.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\infoboards\infostand_v1_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\airport\airport_center_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\factory\factory_main_part2_f.p3d",
        "es\bornholmobjects\bo_a_generalstore_01.p3d",
        "es\bornholmobjects\bo_barn_w_01.p3d",
        "es\bornholmobjects\bo_barn_w_02.p3d",
        "es\bornholmobjects\bo_deutshe_mini.p3d",
        "es\bornholmobjects\bo_dum_mesto2.p3d",
        "es\bornholmobjects\bo_dum_mesto2l.p3d",
        "es\bornholmobjects\bo_dum_mesto3.p3d",
        "es\bornholmobjects\bo_dum_rasovna.p3d",
        "es\bornholmobjects\bo_farm_cowshed_a.p3d",
        "es\bornholmobjects\bo_farm_cowshed_b.p3d",
        "es\bornholmobjects\bo_farm_cowshed_c.p3d",
        "es\bornholmobjects\bo_houseb_tenement.p3d",
        "es\bornholmobjects\bo_houseblock_a1_1.p3d",
        "es\bornholmobjects\bo_houseblock_a3.p3d",
        "es\bornholmobjects\bo_housev2_01a.p3d",
        "es\bornholmobjects\bo_housev2_02_interier.p3d",
        "es\bornholmobjects\bo_housev2_04.p3d",
        "es\bornholmobjects\bo_housev_1i1.p3d",
        "es\bornholmobjects\bo_housev_1i4.p3d",
        "es\bornholmobjects\bo_housev_1l1.p3d",
        "es\bornholmobjects\bo_housev_2t2.p3d",
        "es\bornholmobjects\bo_housev_3i2.p3d",
        "es\bornholmobjects\bo_hut06.p3d",
        "es\bornholmobjects\bo_sara_domek_sedy.p3d",
        "es\bornholmobjects\bo_shed_ind02.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",
        "es\bornholmobjects\bo_a_tvtower_base.p3d",
        "es\bornholmobjects\bo_vysilac_fm.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_small_f.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "es\bornholmobjects\bo_ind_sawmill.p3d"
    ];

};

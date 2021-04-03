private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: bozcaada"] call ALiVE_fnc_dump;

ALIVE_Indexing_Blacklist = [];
ALIVE_airBuildingTypes = [];
ALIVE_militaryParkingBuildingTypes = [];
ALIVE_militarySupplyBuildingTypes = [];
ALIVE_militaryHQBuildingTypes = [];
ALIVE_militaryAirBuildingTypes = [];
ALIVE_civilianAirBuildingTypes = [];
ALiVE_HeliBuildingTypes = [];
ALIVE_militaryHeliBuildingTypes = [];
ALIVE_civilianHeliBuildingTypes = [];
ALIVE_militaryBuildingTypes = [];
ALIVE_civilianPopulationBuildingTypes = [];
ALIVE_civilianHQBuildingTypes = [];
ALIVE_civilianPowerBuildingTypes = [];
ALIVE_civilianCommsBuildingTypes = [];
ALIVE_civilianMarineBuildingTypes = [];
ALIVE_civilianRailBuildingTypes = [];
ALIVE_civilianFuelBuildingTypes = [];
ALIVE_civilianConstructionBuildingTypes = [];
ALIVE_civilianSettlementBuildingTypes = [];

ALiVE_mapCompositionType = "Urban";

if (tolower(_worldName) == "bozcaada") then {
    [ALIVE_mapBounds, worldName, 21000] call ALIVE_fnc_hashSet;

    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\ind\fuelstation_small\fs_price_f.p3d",
        "a3\structures_f\households\house_small01\d_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\house_big_01_v1_ruins_f.p3d",
        "a3\structures_f\households\house_big02\house_big_02_v1_ruins_f.p3d",
        "a3\structures_f\ind\wavepowerplant\rope_f.p3d",
        "a3\structures_f\ind\factory\factory_hopper_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_main_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_10_f.p3d",
        "a3\structures_f\ind\factory\factory_conv2_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_main_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_hopper_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_10_ruins_f.p3d",
        "a3\structures_f\households\house_shop02\shop_02_v1_ruins_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_blueking_ruins_f.p3d",
        "a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_dam_roadway1_f.p3d",
        "a3\structures_f\households\slum\cargo_addon02_v1_f.p3d",
        "a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d",
        "a3\structures_f\households\stone_big\stone_housebig_v1_ruins_f.p3d",
        "a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d",
        "a3\structures_f\training\shoot_house_panels_f.p3d",
        "a3\structures_f\training\shoot_house_corner_f.p3d",
        "a3\structures_f\training\shoot_house_wall_long_f.p3d",
        "a3\structures_f\training\shoot_house_wall_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_church_ruin_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_14_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_church_b_ruin_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_house_ruin_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_15_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_tower_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_tower_ruins_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_church_a_ruin_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_03_f.p3d",
        "a3\structures_f\households\slum\slum_house02_ruins_f.p3d",
        "a3\structures_f\households\slum\slum_house03_ruins_f.p3d",
        "a3\structures_f\ind\powerlines\powerline_distributor_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_dam_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_dam_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_dam_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_ruins_f.p3d",
        "a3\structures_f\households\slum\slum_house01_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_end_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_dam_f.p3d",
        "a3\structures_f\households\house_small03\house_small_03_v1_ruins_f.p3d",
        "a3\structures_f\households\stone_shed\d_stone_shed_v1_f.p3d",
        "a3\structures_f_bootcamp\items\sport\trophy_01_bronze_f.p3d",
        "a3\structures_f_bootcamp\items\sport\trophy_01_gold_f.p3d",
        "a3\structures_f_bootcamp\civ\sportsgrounds\winnerspodium_01_f.p3d",
        "a3\structures_f_bootcamp\items\sport\trophy_01_silver_f.p3d",
        "a3\structures_f\training\steel_plate_l_f.p3d",
        "a3\structures_f\training\steel_plate_s_f.p3d",
        "a3\structures_f_bootcamp\civ\sportsgrounds\tyrebarrier_01_line_x4_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_tower_ruins_f.p3d",
        "a3\structures_f\households\stone_shed\stone_shed_v1_ruins_f.p3d",
        "a3\structures_f\ind\wavepowerplant\wavepowerplantbroken_f.p3d",
        "a3\structures_f\households\house_small02\house_small_02_v1_ruins_f.p3d",
        "a3\structures_f\items\food\bottleplastic_v1_f.p3d",
        "a3\structures_f\training\skeetmachine\skeet_clay_part04_red_f.p3d",
        "a3\structures_f_bootcamp\civ\sportsgrounds\tyrebarrier_01_white_f.p3d",
        "a3\structures_f_bootcamp\civ\sportsgrounds\tyrebarrier_01_black_f.p3d",
        "a3\structures_f_epc\civ\camping\sunshade_01_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_05_f.p3d",
        "a3\structures_f\civ\belltowers\belltower_01_v1_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_04_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_07_f.p3d",
        "a3\structures_f\naval\piers\pillar_pier_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_12_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_16_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_01_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_step_f.p3d",
        "a3\structures_f\naval\piers\pier_wall_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_02_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_13_f.p3d",
        "a3\structures_f\households\addons\d_addon_02_v1_f.p3d",
        "a3\structures_f\ind\shed\shed_big_ruins_f.p3d",
        "a3\structures_f\households\addons\addon_04_v1_ruins_f.p3d",
        "a3\structures_f\civ\belltowers\belltower_02_v1_ruins_f.p3d",
        "a3\structures_f\mil\barracks\barracks_ruins_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_ruins_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_5_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_1_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\roads_f\runway\runway_main_40_f.p3d",
        "a3\roads_f\runway\runway_end04_f.p3d",
        "a3\roads_f\runway\runway_main_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "a3\structures_f\mil\barracks\barracks_acc_proxy_4_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\ind\factory\factory_tunnel_f.p3d",
        "a3\structures_f\ind\shed\shed_small_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\factory\factory_main_part2_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_house_2_f.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_house_1_f.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_mainbuilding_left_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_dam_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_dam_f.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_mainbuilding_entry_f.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_mainbuilding_right_f.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_mainbuilding_middle_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\ind\windmill\i_windmill01_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\dominants\amphitheater\amphitheater_f.p3d",
        "a3\structures_f_epc\civ\tourism\touristshelter_01_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\ind\windmill\d_windmill01_f.p3d",
        "a3\structures_f\civ\chapels\chapel_small_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_proxy_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\civ\belltowers\belltower_02_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_dam_f.p3d",
        "a3\structures_f\civ\chapels\chapel_small_v2_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_redburger_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_papers_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_blueking_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f_bootcamp\items\sport\karttrolly_01_f.p3d",
        "a3\structures_f_bootcamp\items\sport\kartstand_01_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_dam_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_gyros_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d",
        "a3\structures_f\mil\barracks\barracks_acc_proxy_3_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_v1_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\dominants\church\church_01_proxy_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_dam_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\dominants\church\church_01_proxy_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_dam_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\windpowerplant\wpp_turbine_v2_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d",
        "a3\structures_f\ind\powerlines\powlines_transformer_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\wavepowerplant\wavepowerplant_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f\naval\buoys\buoybig_f.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_small_f.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d"
    ];
};

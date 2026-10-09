// ALiVE 3 index v3.1, made 2026-10-09 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: bozcaada (ALiVE 3 index v3.1, 2026-10-09)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Urban";

 if (tolower(_worldName) == "bozcaada") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\roads_f\runway\runway_main_f.p3d",
        "a3\structures_f\dominants\amphitheater\amphitheater_f.p3d",
        "a3\structures_f\ind\factory\factory_tunnel_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\wavepowerplant\wavepowerplant_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_3_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\training\invisibletarget\center.p3d",
        "a3\structures_f_bootcamp\items\sport\kartstand_01_f.p3d",
        "a3\structures_f_bootcamp\items\sport\karttrolly_01_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\roads_f\runway\runway_end04_f.p3d",
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f\mil\barracks\barracks_acc_proxy_4_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\roads_f\runway\runway_main_40_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\belltowers\belltower_02_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_small_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_small_v2_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_tower_f.p3d",
        "a3\structures_f\dominants\church\church_01_proxy_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_dam_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_dam_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_dam_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f\mil\barracks\barracks_acc_proxy_3_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_proxy_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\chapels\chapel_small_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_proxy_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_dam_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_dam_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_dam_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_dam_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\mil\barracks\barracks_acc_proxy_3_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
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
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
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
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_v1_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d"
    ];

};

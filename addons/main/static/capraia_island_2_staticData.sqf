// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: capraia_island_2 (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-08", "web", true];

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

 if (tolower(_worldName) == "capraia_island_2") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\bridges\bridge_asphalt_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_wall_06_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\naval\piers\pier_doubleside_f.p3d",
        "a3\structures_f\walls\mil_wallbig_gate_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_wine_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_03_winery_f.p3d",
        "a3\structures_f_argo\cultural\statues\pedestal_02_f.p3d",
        "a3\structures_f_argo\cultural\statues\statue_01_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\vineyardfence_01_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_pink_f.p3d",
        "a3\structures_f_argo\walls\net\netfence_02_m_gate_v2_closed_f.p3d",
        "a3\structures_f_argo\walls\pipe\pipefence_01_m_gate_v1_closed_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\dominants\castle\castle_01_tower_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f_argo\civilian\addons\i_addon_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_yellow_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\cultural\church\church_01_v2_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_argo\civilian\addons\i_addon_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_yellow_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\cultural\church\church_01_v2_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-11-12 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: gm_weferlingen_winter (ALiVE 3 index v3.1, 2026-11-12)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";

 if (tolower(_worldName) == "gm_weferlingen_winter") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_awning_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_awning_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_awning_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_awning_04_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_01_25_badroad_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_01_25_patrolpath_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_01_25_track_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_02_20_mainroad_half_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_02_20_normalroad_half_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_02_20_normalroad_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_03_50_highway_half_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_bridge_03_50_highway_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_damage_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_damage_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_damage_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_damage_04_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_damage_05_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_damage_06_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_damage_07_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_roadpatch_asphalt_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_roadpatch_asphalt_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\roads\gm_euro_roadpatch_asphalt_04_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\sidewalks\gm_euro_sidewalk_01_200_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\sidewalks\gm_euro_sidewalk_01_200_win_curve.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\sidewalks\gm_euro_sidewalk_01_200_win_side.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\sidewalks\gm_euro_sidewalk_02_200_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\sidewalks\gm_euro_sidewalk_02_800_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\sidewalks\gm_euro_sidewalk_03_200_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\sidewalks\gm_euro_sidewalk_03_800_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\walls\gm_wall_vehicleditch_700_win.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "gm\gm_structures\gm_structures_euro_80\towers\gm_tower_bt_11_60.p3d",
        "gm\gm_structures\gm_structures_euro_80\towers\gm_tower_bt_6_fuest_80.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_barracks_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_barracks_02_win.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_empty_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_grocer_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_grocer_02_e.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_grocer_02_w.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_post_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_toystore_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_deerstand_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_02.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_03_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_03_02.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_04.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_05.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_06.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_misc_garage_03.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_misc_garage_04.p3d",
        "gm\gm_structures\gm_structures_euro_80\walls\gm_wall_castle_01_tower_01.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_church_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_church_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_dest_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_factory_01_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_factory_01_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_factory_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_farmhouse_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_farmhouse_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_farmhouse_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_fuelstation_01_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_fuelstation_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_01_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_01_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_01_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_02_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_02_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_02_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_03_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_03_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_04_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_04_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_04_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_05_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_05_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_05_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_06_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_06_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_06_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_07_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_07_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_07_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_10_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_10_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_10_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_12_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_12_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_12_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_13_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_13_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_13_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_mine_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_office_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_office_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_office_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_pub_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_pub_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shed_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shed_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shed_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shed_04_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shed_05_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_01_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_02_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_02_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_garage_01_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_garage_01_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_garage_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_kiosk_01_win.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_church_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_church_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_farmhouse_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_01_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_10_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_13_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_office_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_pub_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_pub_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_02_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_02_w_win.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_empty_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_grocer_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_grocer_02_w.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_post_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\insets\gm_inset_shop_toystore_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_gardenshed_03_01.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_church_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_church_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_dest_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_factory_01_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_factory_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_farmhouse_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_farmhouse_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_farmhouse_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_fuelstation_01_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_fuelstation_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_01_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_01_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_01_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_02_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_02_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_02_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_03_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_03_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_04_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_04_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_04_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_05_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_05_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_05_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_06_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_06_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_06_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_07_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_07_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_07_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_08_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_09_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_10_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_10_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_10_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_11_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_12_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_12_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_12_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_13_d_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_13_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_house_13_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_office_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_office_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_office_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_pub_01_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_pub_02_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shed_03_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_01_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_02_e_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_shop_02_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_kiosk_01_win.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_misc_powerbox_01.p3d",
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_misc_powerbox_04_w.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\misc\gm_euro_misc_transformer_01_win.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "gm\gm_structures\gm_structures_euro_80\sidewalks\gm_euro_platform_01.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "gm\gm_structures\gm_structures_euro_80\misc\gm_euro_misc_tank_01_w.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_fuelstation_01_w_win.p3d",
        "gm\gm_structures\gm_structures_euro_80_winter\buildings\gm_euro_fuelstation_02_win.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: thirsk (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "thirsk") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings2\a_advertisingcolumn\a_advertcolumn.p3d",
        "ca\buildings2\a_crane_02\crane_rails.p3d",
        "ca\buildings2\a_crane_02\crane_rails_end.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\roads2\asf1_10 100.p3d",
        "ca\roads2\asf1_10 50.p3d",
        "ca\roads2\dam\dam_conc\dam_concp_20.p3d",
        "ca\structures\ind_quarry\ind_hammermill.p3d",
        "ca\structures\ind_sawmill\ind_sawmill_ruins.p3d",
        "ca\structures\misc\armory\climbing_obstacle\climbing_obstacle.p3d",
        "rhnet\thirsk5\roads\runway_end11.p3d",
        "rhnet\thirsk5\roads\runway_end29.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_barracks_l.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_controltower_ruins.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\structures\mil\mil_house_ruins.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\roads2\runway_main.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\roads2\runway_main.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings2\farm_wtower\farm_wtower.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_1.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_2.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a2.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a2_1.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a3.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b1.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b2.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b3.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b4.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b5.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b6.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b6_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c2.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c3.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c3_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c4.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c5.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d1.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d2.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\hospital.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\molo_beton.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\church_05r\church_05r.p3d",
        "ca\structures\house\housebt\houseb_tenement_ruins.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures\house\housev\housev_2t1.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "ca\structures\house\housev\housev_3i4.p3d",
        "ca\structures\ind_quarry\ind_quarry.p3d",
        "ca\structures\ind_quarry\ind_quarry_ruins.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings\hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures\house\housev\housev_2t2.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_velka.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "ca\buildings\vysilac_fm.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\structures\nav\nav_lighthouse.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-10-05 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: utes (ALiVE 3 index v3.1, 2026-10-05)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-05", "web", true];

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

 if (tolower(_worldName) == "utes") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\roads2\runwayold_40_main.p3d",
        "ca\water2\lhd\helper_snaper.p3d",
        "ca\water2\lhd\lhd_1.p3d",
        "ca\water2\lhd\lhd_2.p3d",
        "ca\water2\lhd\lhd_3.p3d",
        "ca\water2\lhd\lhd_4.p3d",
        "ca\water2\lhd\lhd_5.p3d",
        "ca\water2\lhd\lhd_6.p3d",
        "ca\water2\lhd\lhd_elev_r.p3d",
        "ca\water2\lhd\lhd_house_1.p3d",
        "ca\water2\lhd\lhd_house_2.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\misc2\barrack2\barrack2.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_barracks_l.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\church_05r\church_05r.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev2\housev2_05.p3d",
        "ca\structures\house\housev\housev_1i2.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_1l1.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\structures\house\housev\housev_2t1.p3d",
        "ca\structures\house\housev\housev_3i2.p3d",
        "ca\structures\house\housev\housev_3i4.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\structures\nav\nav_lighthouse.p3d",
        "ca\structures\nav\nav_lighthouse2.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d",
        "ca\structures\nav_pier\nav_pier_c.p3d",
        "ca\structures\nav_pier\nav_pier_c_r.p3d",
        "ca\structures\nav_pier\nav_pier_c_t15.p3d",
        "ca\structures\nav_pier\nav_pier_f_17.p3d",
        "ca\structures\nav_pier\nav_pier_m_1.p3d",
        "ca\structures\nav_pier\nav_pier_m_end.p3d"
    ];

};

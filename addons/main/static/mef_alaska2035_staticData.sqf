// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: mef_alaska2035 (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "mef_alaska2035") then {
    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\budova4.p3d",
        "ca\buildings\budova5.p3d",
        "ca\buildings\hangar_2.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings\bouda3.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\domek_rosa.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\dum_zboreny.p3d",
        "ca\buildings\sara_domek_hospoda.p3d",
        "ca\buildings\sara_domek_kovarna.p3d",
        "ca\buildings\sara_domek_podhradi_1.p3d",
        "ca\buildings\sara_domek_ruina.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_hasic_zbroj.p3d",
        "ca\buildings\zalchata.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\sara_domek_zluty.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\vysilac_fm.p3d",
        "ca\structures_e\misc\com_tower_ep1.p3d"
    ];

};

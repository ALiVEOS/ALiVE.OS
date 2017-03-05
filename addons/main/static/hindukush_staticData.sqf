private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: %1", _worldName] call ALIVE_fnc_dump;

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

if (_worldName == "hindukush") then {
    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "bunker"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barracks"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barracks",
        "jbad_mil_controltower"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "jbad_hangar_"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "helipads"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "helipads"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "hbarrier",
        "tenthangar",
        "jbad_mil_"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "jbad_house_",
        "jbad_house2_",
        "jbad_house3",
        "jbad_house5",
        "jbad_house6",
        "jbad_house7",
        "jbad_house8",
        "jbad_a_mosque_",
        "jbad_a_minaret",
        "jbad_mosque_",
        "jbad_market_",
        "qualat",
        "slum",
        "shed",
        "garage",
        "stone_housebig",
        "stone_housesmall"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "jbad_house2_",
        "jbad_mosque_"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "dieselpowerplant",
        "solarpowerplant",
        "windpowerplant",
        "wavepowerplant",
        "powerstation"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "jbad_tv_",
        "jbad_antenna"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "jbad_a_stationhouse"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "jbad_ind_garage01",
        "indpipe"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "concretemixingplant",
        "scrapyard",
        "wip",
        "jbad_bedna",
        "jbad_cihly1",
        "jbad_cihly2",
        "jbad_cihly3",
        "jbad_cihly4",
        "jbad_koz",
        "jbad_ind_coltan",
        "jbad_ind_shed"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [];
};

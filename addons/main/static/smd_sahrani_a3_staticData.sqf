private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: %1", _worldName] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";

if (_worldName == "smd_sahrani_a3") then {
    [ALIVE_mapBounds, worldName, 20480] call ALIVE_fnc_hashSet;

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "smd_ss_hangard_"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "army",
        "vez",
        "budova"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "army"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "mesto3"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "vez",
        "hlaska",
        "budova",
        "posed",
        "hospital"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "rohova"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "najezd",
        "cargo",
        "nabrezi",
        "podesta"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "expedice",
        "indpipe"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "house",
        "plot_",
        "dum_",
        "hut0",
        "olezlina",
        "domek",
        "dum",
        "kulna",
        "statek",
        "afbar",
        "panelak",
        "deutshe",
        "mesto",
        "hotel",
        "jezek_kov"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [];
};

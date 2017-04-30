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

ALiVE_mapCompositionType = "Desert";

if (_worldName == "fata") then {
    [ALIVE_mapBounds, worldName, 11000] call ALIVE_fnc_hashSet;

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_guardhouse",
        "deerstand"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_guardhouse",
        "deerstand"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barrack",
        "mil_house"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "deerstand",
        "vez",
        "barrack",
        "mil_house",
        "mil_guardhouse",
        "deerstand",
        "barrier",
        "hlaska",
        "watchtower",
        "hbarrier"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a_office01"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "powerstation",
        "trafostanica",
        "ind_coltan_mine"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "vysilac_fm"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "ind_tankbig"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "wip",
        "ind_coltan_mine"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "house"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [];
};

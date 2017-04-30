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

ALiVE_mapCompositionType = "Woodland";

if (_worldName == "woodland_acr") then {
    [ALIVE_mapBounds, worldName, 8000] call ALIVE_fnc_hashSet;

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "mil"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "mil"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_controltower"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "deerstand"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a_office01",
        "a_office02"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "pec_",
        "powerstation",
        "trafostanica"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "vysilac_fm",
        "telek"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "crane",
        "nav_pier",
        "pier_",
        "pier"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "rail_house",
        "rail_station",
        "rail_platform",
        "rails_bridge",
        "stationhouse"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "expedice",
        "indpipe",
        "komin",
        "ind_stack_big",
        "ind_tankbig",
        "fuel_tank_big"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "workshop"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "hospital",
        "houseblock",
        "generalstore",
        "house"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [];
};

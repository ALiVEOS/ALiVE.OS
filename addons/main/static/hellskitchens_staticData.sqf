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

if (_worldName == "hellskitchens") then {
    [ALIVE_mapBounds, worldName, 6000] call ALIVE_fnc_hashSet;

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "barrack",
        "mil_controltower",
        "guardtower",
        "killhouse",
        "watchtower"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barrack",
        "mil_controltower",
        "guardtower",
        "killhouse"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barrack",
        "mil_controltower"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ss_hangar",
        "hangar_2",
        "hangar"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "heli_h_army"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "barrack",
        "mil_controltower",
        "hesco",
        "guardtower",
        "killhouse",
        "watchtower",
        "nest"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a_office01"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "powerstation",
        "trafostanica"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "illuminanttower",
        "vysilac_fm",
        "telek"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "nav_pier",
        "pier_",
        "pier"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "indpipe",
        "ind_tankbig"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "wip",
        "sawmillpen",
        "workshop",
        "cementworks"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "generalstore",
        "house",
        "dum_",
        "hut"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [];
};

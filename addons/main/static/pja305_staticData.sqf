private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: pja305"] call ALIVE_fnc_dump;

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

if (tolower(_worldName) == "pja305") then {
    [ALIVE_mapBounds, worldName, 21000] call ALIVE_fnc_hashSet;

    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "army_hut",
        "vez",
        "watchtower",
        "fortified",
        "miloffices"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "fortified"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_controltower",
        "fortified"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_guardhouse",
        "mil_controltower"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ss_hangar",
        "hangar_2",
        "hangar"
    ];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "hospital",
        "dum",
        "shed",
        "hut",
        "house",
        "minaret",
        "mosque",
        "offices_01_v1_f",
        "a_office01",
        "a_office02",
        "villa"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a_office01",
        "a_office02"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "hospital",
        "dum",
        "shed",
        "hut",
        "house",
        "minaret",
        "mosque",
        "offices_01_v1_f",
        "a_office01",
        "a_office02",
        "villa"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "pec_",
        "powerstation",
        "trafostanica"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "illuminanttower",
        "vysilac_fm",
        "telek"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "crane",
        "wtower",
        "najezd",
        "cargo"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "stationhouse"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "expedice",
        "indpipe",
        "komin",
        "ind_tankbig",
        "fuel_tank_big"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ind_mlyn_01",
        "ind_pec_01",
        "wip",
        "sawmillpen",
        "workshop",
        "coltan",
        "ind_cementworks"
    ];
};

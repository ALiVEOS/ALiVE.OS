//v3.8
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

if (_worldName == "dingor") then {
    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "barrack",
        "mil_house",
        "fort_",
        "mil_",
        "mil_controltower",
        "mil_guardhouse",
        "misc_deerstand",
        "deerstand"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_controltower",
        "mil_guardhouse"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barrack",
        "barracks",
        "tent_",
        "mil_house",
        "mil_controltower"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ss_hangar",
        "airport",
        "hangar",
        "runway_beton",
        "runway_end",
        "runway_",
        "runway_main",
        "runway_secondary"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "deerstand",
        "vez",
        "army_hut",
        "tents",
        "fort_",
        "barrack",
        "mil_",
        "mil_house",
        "mil_controltower",
        "mil_guardhouse",
        "misc_deerstand",
        "deerstand"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a_office01",
        "police_station"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "pec_",
        "powerstation",
        "trafostanica"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "illuminanttower",
        "vysilac_fm",
        "telek",
        "telek1",
        "tvtower",
        "radiotelescope"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "crane",
        "lighthouse",
        "nav_",
        "nav_pier",
        "pier_",
        "pier"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "rail_loco"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "expedice",
        "indpipe",
        "komin",
        "ind_tankbig"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "wip",
        "ind_",
        "a_cranecon",
        "a_buildingwip",
        "sawmillpen",
        "workshop"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "generalstore",
        "budova",
        "shed_",
        "chapels",
        "house",
        "plot_",
        "households",
        "housea",
        "housebt",
        "housec",
        "housek",
        "housel",
        "housev",
        "domek",
        "slums",
        "a_castle_",
        "dum_",
        "hut0",
        "misc_market",
        "barn_",
        "hut_",
        "flats",
        "shanties"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [];
};

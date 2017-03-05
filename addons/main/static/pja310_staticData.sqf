private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: pja310"] call ALIVE_fnc_dump;

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

if (tolower(_worldName) == "pja310") then {
    [ALIVE_mapBounds, worldName, 21000] call ALIVE_fnc_hashSet;

    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "vez",
        "army_hut",
        "watchtower",
        "mil_guardhouse",
        "fortified"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "fortified",
        "budova",
        "mil_guardhouse"
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
        "mil_controltower"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "mil_hangar"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ss_hangar",
        "hangar"
    ];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "hospital",
        "dum_",
        "shed",
        "hut",
        "house",
        "a_castle_",
        "kasna",
        "majak",
        "repair_center",
        "statek",
        "garage",
        "a_mosque",
        "a_minaret",
        "a_villa",
        "generalstore",
        "barn_",
        "workshop"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a_office01",
        "a_office02"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "hospital",
        "dum_",
        "shed",
        "hut",
        "house",
        "a_castle_",
        "kasna",
        "majak",
        "repair_center",
        "statek",
        "garage",
        "a_mosque",
        "a_minaret",
        "a_villa",
        "generalstore",
        "barn_",
        "workshop"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "pec_",
        "powerstation",
        "misc_powerline",
        "trafostanica"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "illuminanttower",
        "vysilac_fm",
        "telek"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "crane",
        "lighthouse",
        "nav_boathouse",
        "nav_pier",
        "wtower",
        "najezd",
        "cargo"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a_stationhouse"
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
        "coltan",
        "ind_cementworks"
    ];
};

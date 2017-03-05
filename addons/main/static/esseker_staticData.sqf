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

if (_worldName == "esseker") then {
    [ALIVE_mapBounds, worldName, 13000] call ALIVE_fnc_hashSet;

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "bunker",
        "cargo_house_v",
        "cargo_patrol_",
        "research",
        "barrack",
        "airport",
        "mil_house",
        "mil_controltower",
        "mil_guardhouse",
        "deerstand",
        "u_barracks_v2_f"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barrack",
        "cargo_hq_",
        "miloffices",
        "cargo_house_v",
        "cargo_patrol_",
        "research",
        "posed",
        "mil_controltower",
        "fuelstation_army",
        "mil_house"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barrack",
        "cargo_hq_",
        "miloffices",
        "cargo_tower"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "tenthangar"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ss_hangar",
        "hangar_2",
        "hangar",
        "runway_beton",
        "runway_end",
        "runway_main",
        "runway_secondary"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "helipads"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "helipads"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "airport_tower",
        "radar",
        "bunker",
        "cargo_house_v",
        "cargo_patrol_",
        "research",
        "mil_wall",
        "fortification",
        "razorwire",
        "airport_tower",
        "bunker",
        "cargo_patrol_",
        "research",
        "army_hut",
        "mil_wall",
        "fortification",
        "dome",
        "deerstand",
        "barrack",
        "mil_house",
        "mil_controltower",
        "mil_guardhouse",
        "deerstand",
        "hospital"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "house_",
        "shop_",
        "garage_",
        "stone_",
        "House",
        "domek",
        "sara"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "offices"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "dp_main",
        "spp_t",
        "pec_",
        "powerstation",
        "trafostanica"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "communication_f",
        "ttowerbig_",
        "communication_f",
        "telek",
        "telek1",
        "transmitter_tower"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "crane",
        "lighthouse",
        "nav_pier",
        "pier_",
        "pier"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [

    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "dp_bigtank",
        "indpipe",
        "komin",
        "ind_tankbig"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "wip",
        "bridge_highway",
        "sawmillpen",
        "workshop"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "church",
        "hospital",
        "amphitheater",
        "chapel_v",
        "households",
        "generalstore",
        "house",
        "domek",
        "dum_",
        "kulna",
        "afbar",
        "panelak",
        "deutshe",
        "dum_mesto_in",
        "dum_mesto2",
        "hotel"
    ];
};

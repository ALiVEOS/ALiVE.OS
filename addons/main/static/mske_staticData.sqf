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

if (_worldName == "mske") then {
    [ALIVE_mapBounds, worldName, 26000] call ALIVE_fnc_hashSet;

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ss_hangar",
        "hangar",
        "tenthangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "bunker",
        "cargo_house_v",
        "cargo_patrol_",
        "research",
        "airport",
        "fortified",
        "army"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barracks",
        "cargo_hq_",
        "miloffices",
        "cargo_house_v",
        "cargo_patrol_",
        "research",
        "fortified",
        "fuelstation_army"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "cargo_hq_",
        "miloffices"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ss_hangar",
        "tenthangar"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ss_hangar",
        "hangar_f",
        "runway_"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "helipads",
        "helipadcircle",
        "heli_h_army"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "helipads",
        "heli_h_civil",
        "heli_h_cross",
        "heli_h_rescue"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "airport_tower",
        "army_hut",
        "ammostore2",
        "bagfence",
        "radar",
        "cargo_house_v",
        "cargo_patrol_",
        "research",
        "mil_wall",
        "fortification",
        "razorwire",
        "dome",
        "hbarrier",
        "bighbarrier",
        "fortified",
        "hlaska",
        "posed",
        "shooting_range"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "budova",
        "shop",
        "shop_",
        "stone_",
        "pub",
        "residential",
        "housedoubleal",
        "market",
        "garaz",
        "letistni_hala",
        "hospital"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "offices",
        "a_office",
        "a_municipaloffice"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "dieselpowerplant",
        "wpp_",
        "spp_t",
        "pec_",
        "trafostanica",
        "ind_coltan_mine",
        "ind_pipeline",
        "ind_pipes",
        "ind_powerstation"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "communication_f",
        "com_tower",
        "transmitter_tower",
        "vysilac_fm",
        "telek",
        "tvtower"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "crane",
        "lighthouse",
        "piers",
        "molo_",
        "nav_pier",
        "sea_wall_",
        "najezd",
        "cargo",
        "nabrezi",
        "podesta",
        "nav_boathouse"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "rail_najazdovarampa"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "indpipe",
        "dp_bigtank",
        "expedice",
        "komin",
        "fuel_tank_big",
        "ind_tank"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "wip",
        "ind_coltan_mine",
        "concretemixingplant",
        "factory",
        "torvana",
        "ind_workshop",
        "ind_quarry",
        "ind_sawmill",
        "ind_cementworks",
        "civilengineering",
        "vez"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "barrack",
        "barn",
        "bouda",
        "bozi",
        "budova",
        "carservice",
        "church",
        "commonwealthbank",
        "deutshe",
        "dum",
        "garaz",
        "generalstore",
        "ghosthotel",
        "hangar_2",
        "helfenburk",
        "hlidac_budka",
        "hospital",
        "hotel",
        "housedoubleal",
        "households",
        "house",
        "hut",
        "kasna",
        "kiosk",
        "kostel2",
        "kostelik",
        "kulna",
        "market",
        "panelak",
        "policestation",
        "postb",
        "prison",
        "pub",
        "repair_center",
        "residential_a",
        "shed",
        "shop",
        "shops",
        "stadium",
        "stanek",
        "statek",
        "watertower"
    ];
};

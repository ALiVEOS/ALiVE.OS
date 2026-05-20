

/*
 * Map bounds for analysis grid, this is for when the map bounds function is faulty
 * due to incorrect map size values from config.
 */

ALIVE_mapBounds = [] call ALIVE_fnc_hashCreate;
[ALIVE_mapBounds, "Imrali", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "wake", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Colleville", 6000] call ALIVE_fnc_hashSet;

// Add fix for problematic hangars
ALIVE_problematicHangarBuildings = [];

/*
 * CP MP building types for cluster generation
 */

private["_worldName","_fileExists"];

_worldName = worldName;

// Load map static data
// check file exists, if not then load hardcoded
_fileExists = false;

if (!isDedicated) then {
    _fileExists = [format["x\alive\addons\main\static\%1_staticData.sqf", toLower(worldName)]] call ALiVE_fnc_fileExists;

    If (_fileExists) then {
        ["LOADING MAP DATA: %1",_worldName] call ALiVE_fnc_dump;
        _file = format["x\alive\addons\main\static\%1_staticData.sqf", toLower(worldName)];
        call compile preprocessFileLineNumbers _file;
    };
};

if (!_fileExists) then {

    ["SETTING UP MAP: %1",_worldName] call ALiVE_fnc_dump;

    ALIVE_airBuildingTypes = [];
    ALIVE_militaryParkingBuildingTypes = [];
    ALIVE_militarySupplyBuildingTypes = [];
    ALIVE_militaryHQBuildingTypes = [];
    ALIVE_militaryAirBuildingTypes = [];
    ALIVE_civilianAirBuildingTypes = [];
    ALIVE_militaryHeliBuildingTypes = [];
    ALIVE_civilianHeliBuildingTypes = [];
    ALIVE_militaryBuildingTypes = [];
    ALIVE_heliBuildingTypes = [];
    ALIVE_civilianPopulationBuildingTypes = [];
    ALIVE_civilianHQBuildingTypes = [];
    ALIVE_civilianPowerBuildingTypes = [];
    ALIVE_civilianCommsBuildingTypes = [];
    ALIVE_civilianMarineBuildingTypes = [];
    ALIVE_civilianRailBuildingTypes = [];
    ALIVE_civilianFuelBuildingTypes = [];
    ALIVE_civilianConstructionBuildingTypes = [];
    ALIVE_civilianSettlementBuildingTypes = [];

    // Altis Stratis
    if(_worldName == "Altis" || _worldName == "Stratis" || _worldName == "sfp_wamako" || _worldName == "Imrali" || _worldName == "wake" || _worldName == "gorgona") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker",
            "cargo_house_v",
            "cargo_patrol_",
            "research"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "cargo_hq_",
            "miloffices",
            "cargo_house_v",
            "cargo_patrol_",
            "research"
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
            "hangar",
            "runway_beton",
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
            "dome"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
            "house_",
            "shop_",
            "garage_",
            "stone_"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "offices"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "dp_main",
            "spp_t"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "communication_f",
            "ttowerbig_"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
            "nav_pier",
            "pier_"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [

        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "dp_bigtank"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "wip",
            "bridge_highway"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "church",
            "hospital",
            "amphitheater",
            "chapel_v",
            "households"
        ];

        ALIVE_problematicHangarBuildings = ALIVE_problematicHangarBuildings + [
            "[14401.4,16225.4,-0.000520706]"
        ];

    };

    // Iron Front
    if(_worldName == "Baranow" || _worldName == "Staszow" || _worldName == "ivachev" || _worldName == "Panovo" || _worldName == "Colleville") then {

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "Land_lib_Mil_Barracks",
            "lib_posed",
            "blockhouse",
            "barrier_p1",
            "ZalChata",
            "lib_Mil_Barracks_L",
            "dum01",
            "lib_m3",
            "lib_m2",
            "fort_bagfence_round",
            "lib_bunker_mg",
            "lib_bunker_gun_l",
            "lib_bunker_gun_r"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "Land_lib_Mil_Barracks",
            "lib_posed",
            "blockhouse",
            "barrier_p1",
            "ZalChata",
            "lib_Mil_Barracks_L",
            "dum01",
            "lib_m3",
            "lib_m2",
            "fort_bagfence_round",
            "lib_bunker_mg",
            "lib_bunker_gun_l",
            "lib_bunker_gun_r"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "Land_lib_Mil_Barracks",
            "lib_Mil_Barracks_L",
            "dum01"
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "Land_lib_Mil_Barracks",
            "lib_posed",
            "blockhouse",
            "barrier_p1",
            "ZalChata",
            "lib_Mil_Barracks_L",
            "dum01",
            "lib_m3",
            "lib_m2",
            "fort_bagfence_round",
            "lib_bunker_mg",
            "lib_bunker_gun_l",
            "lib_bunker_gun_r"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "lib_admin",
            "lib_kostel_1",
            "lib_church"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "kulna",
            "lib_dom",
            "lib_cr",
            "lib_sarai",
            "lib_Kladovka",
            "lib_hata",
            "lib_apteka",
            "lib_city_shop",
            "lib_kirpich",
            "lib_banya",
            "lib_dlc1_corner_house",
            "lib_dlc1_apteka",
            "lib_dlc1_city_house",
            "lib_dlc1_kirpich",
            "lib_french_stone_house",
            "lib_dlc1_house_1floor_pol"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    if (count ALIVE_civilianPopulationBuildingTypes == 0) then { // if no buildings try loading from file
        ["MAP NOT INDEXED OR DEDI SERVER FILE LOAD... LOADING MAP DATA: %1",_worldName] call ALiVE_fnc_dump;
        _file = format["x\alive\addons\main\static\%1_staticData.sqf", toLower(worldName)];
        // why the hell are we even calling this here
        if ([_file] call ALiVE_fnc_fileExists) then {
            call compile preprocessFileLineNumbers _file;
        };
    };
};

// Universal building-type defaults. Applied AFTER both the per-terrain
// staticData load AND the family-fallback branch, so every map inherits
// the common hangar / helipad substrings on top of whatever its own
// staticData file specified. fnc_findBuildingsInClusterNodes does a
// substring containment match against the lowercased p3d path, so
// "hangar" alone catches Land_HangarS / Land_Hangar_F / Land_Hangar_2
// / ss_hangar etc. across A2 / A3 / CUP / RHS / Apex / GM / SOG / etc.
//
// Without these defaults, per-terrain staticData files that wipe the
// list to [] and then add only a control tower (e.g. cup_chernarus_a3
// at 2026-05-20 -- file only listed controltower_02_f.p3d) leave
// mil_placement's hangar-loop with zero matching buildings, so no
// fixed-wing aircraft spawn even on terrains with real hangars on the
// airfield. The original indexer's detection gap is captured in
// strategy_default_building_types.md; this Maps.hpp merge is the
// systemic fix that covers every terrain at once.
//
// Defaults are additive + deduped via arrayIntersect self-intersect.
// Terrain-specific entries (controltower_02_f.p3d, terrain-specific
// hangar mods, etc.) remain untouched in the final list.
private _defaultAirBuildings = [
    "hangar"
];
private _defaultHeliBuildings = [
    "helipad"
];

ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + _defaultAirBuildings;
ALIVE_airBuildingTypes = ALIVE_airBuildingTypes arrayIntersect ALIVE_airBuildingTypes;

ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + _defaultHeliBuildings;
ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes arrayIntersect ALIVE_heliBuildingTypes;

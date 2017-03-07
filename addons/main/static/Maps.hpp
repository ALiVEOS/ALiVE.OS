

/*
 * Map bounds for analysis grid, this is for when the map bounds function is faulty
 * due to incorrect map size values from config.
 */
ALIVE_mapBounds = [] call ALIVE_fnc_hashCreate;
[ALIVE_mapBounds, "utes", 5000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "fallujah", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Thirsk", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "ThirskW", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Chernarus", 16000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Chernarus_Summer", 16000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "FDF_Isle1_a", 21000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Takistan", 13000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "IsolaDiCapraia", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "fata", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "hellskitchen", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "hellskitchens", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Celle", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Takistan", 13000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "praa_av", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "tavi", 26000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Woodland_ACR", 8000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Imrali", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "wake", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Colleville", 6000] call ALIVE_fnc_hashSet;
//[ALIVE_mapBounds, "Panthera3", 10000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "anim_helvantis_v2", 10200] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "smd_sahrani_a3", 20480] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Esseker", 13000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Mog", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Pandora", 21000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "mske", 26000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Kunduz", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "australia", 40960] call ALIVE_fnc_hashSet;

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
        ["ALiVE LOADING MAP DATA: %1",_worldName] call ALIVE_fnc_dump;
        _file = format["x\alive\addons\main\static\%1_staticData.sqf", toLower(worldName)];
        call compile preprocessFileLineNumbers _file;
    };
};

if (!_fileExists) then {

    ["ALiVE SETTING UP MAP: %1",_worldName] call ALIVE_fnc_dump;

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

    };

    // Esseker
    if(_worldName == "Esseker") then {

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

    // Mogadishu, Nam (Pandora)
    if(_worldName == "Mog" || _worldName == "Pandora") then {

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
            "sara",
            "jbad_house_",
            "jbad_house2_",
            "jbad_house3",
            "jbad_house5",
            "jbad_house6",
            "jbad_house7",
            "jbad_house8",
            "jbad_a_mosque_",
            "jbad_a_minaret",
            "jbad_mosque_",
            "jbad_market_",
            "qualat",
            "slum",
            "shed",
            "garage",
            "stone_housebig",
            "stone_housesmall"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "offices",
            "jbad_house2_",
            "jbad_mosque_"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "dp_main",
            "spp_t",
            "pec_",
            "powerstation",
            "trafostanica",
            "dieselpowerplant",
            "solarpowerplant",
            "windpowerplant",
            "wavepowerplant",
            "powerstation"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "communication_f",
            "ttowerbig_",
            "communication_f",
            "telek",
            "telek1",
            "transmitter_tower",
            "jbad_tv_",
            "jbad_antenna"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
            "nav_pier",
            "pier_",
            "pier"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "jbad_a_stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "dp_bigtank",
            "indpipe",
            "komin",
            "ind_tankbig",
            "jbad_ind_garage01"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "wip",
            "bridge_highway",
            "sawmillpen",
            "workshop",
            "jbad_bedna",
            "jbad_cihly1",
            "jbad_cihly2",
            "jbad_cihly3",
            "jbad_cihly4",
            "jbad_koz",
            "jbad_ind_coltan",
            "jbad_ind_shed"
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

    // Kunduz
    if(tolower(_worldName) == "kunduz") then {
        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["pra3\pra3_tunnels\floor_sandy.p3d","pra3\pra3_tunnels\tunnel_small_ramp.p3d","pra3\pra3_tunnels\wood_beams_h_join.p3d","pra3\pra3_tunnels\wood_beams_h_sloped.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_tunnels\tunnel_small_bend.p3d","pra3\pra3_tunnels\tunnel_large_s_bend.p3d","pra3\pra3_tunnels\tunnel_large_room_1door.p3d","pra3\pra3_tunnels\wood_beams_t.p3d","pra3\pra3_tunnels\wood_beams.p3d","pra3\pra3_tunnels\tunnel_large_room_4doors.p3d","pra3\pra3_tunnels\wood_beams_h.p3d","pra3\pra3_tunnels\cable_hanging.p3d","pra3\pra3_tunnels\cable_ground.p3d"];
        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];
        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["pra3\pra3_tunnels\floor_sandy.p3d","pra3\pra3_tunnels\tunnel_small_ramp.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_tunnels\tunnel_small_bend.p3d","pra3\pra3_tunnels\tunnel_large_room_1door.p3d"];
        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_tunnels\tunnel_large_room_1door.p3d"];
        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];
        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];
        ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];
        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];
        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["pra3\pra3_structures\walls\walls_l\jbad_wall_l_5m.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5_corner.p3d","pra3\pra3_misc\misc_market\jbad_stand_water.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_stuff.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5_gate.p3d","pra3\pra3_misc\misc_market\jbad_market_stalls_01.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_reservoir.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d","pra3\pra3_misc\misc_market\jbad_market_shelter.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_5m_dam.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_mosque_2.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d","pra3\pra3_misc\misc_market\jbad_covering_hut_big.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l1_pillar.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d","pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d","pra3\pra3_structures\afghan_houses\jbad_house5.p3d","pra3\pra3_structures\afghan_houses\jbad_house_1.p3d","a3\structures_f\walls\net_fence_gate_f.p3d","pra3\pra3_structures\afghan_houses\jbad_terrace.p3d","pra3\pra3_misc\misc_well\jbad_misc_well_c.p3d","pra3\pra3_misc\misc_market\jbad_covering_hut.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l1_5m.p3d","pra3\pra3_misc\misc_market\jbad_stand_meat.p3d","pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d","pra3\pra3_misc\misc_construction\jbad_misc_concbox.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","pra3\pra3_structures\afghan_houses\jbad_house6.p3d","pra3\pra3_structures\afghan_houses\jbad_house8.p3d","pra3\pra3_structures\afghan_houses\jbad_house3.p3d","pra3\pra3_structures\afghan_houses\jbad_house7.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d","pra3\pra3_structures\fata\qalat.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l2_5m.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l2_5m_end.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l3_gate.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l3_5m.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d","pra3\pra3_misc\misc_market\jbad_kiosk.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l1_gate.p3d","pra3\pra3_structures\afghan_houses_a\a_minaret\jbad_a_minaret.p3d"];
        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d","pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d","pra3\pra3_structures\afghan_houses\jbad_house5.p3d","pra3\pra3_structures\afghan_houses\jbad_house_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d","pra3\pra3_tunnels\floor_sandy.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_structures\afghan_houses\jbad_house6.p3d","pra3\pra3_structures\afghan_houses\jbad_house8.p3d","pra3\pra3_structures\afghan_houses\jbad_house3.p3d","pra3\pra3_structures\afghan_houses\jbad_house7.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d"];
        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_stuff.p3d","pra3\pra3_misc\misc_market\jbad_market_stalls_01.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d","pra3\pra3_misc\misc_well\jbad_misc_well_l.p3d","pra3\pra3_misc\misc_market\jbad_market_shelter.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d","pra3\pra3_misc\misc_market\jbad_covering_hut_big.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d","pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d","pra3\pra3_structures\afghan_houses\jbad_house5.p3d","pra3\pra3_structures\afghan_houses\jbad_house_1.p3d","pra3\pra3_structures\afghan_houses\jbad_terrace.p3d","pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_structures\afghan_houses\jbad_house6.p3d","pra3\pra3_structures\afghan_houses\jbad_house8.p3d","pra3\pra3_structures\afghan_houses\jbad_house3.p3d","pra3\pra3_structures\afghan_houses\jbad_house7.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d","pra3\pra3_misc\misc_market\jbad_kiosk.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d"];
        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["a3\structures_f\ind\powerlines\powercable_submarine_f.p3d"];
        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];
        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];
        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [];
        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["pra3\pra3_misc\misc_construction\jbad_misc_ironpipes.p3d","pra3\pra3_misc\misc_ruins\jbad_rubble_concrete_01.p3d","pra3\pra3_misc\misc_construction\jbad_misc_concpipeline.p3d","pra3\pra3_misc\misc_construction\jbad_misc_concbox.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","pra3\pra3_tunnels\wood_beam.p3d","pra3\pra3_misc\bridge\ic_002_bridge.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_4_d.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_4.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_end_3.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_end_2.p3d"];
    };

    // Hindu Kush
    if(_worldName == "HinduKush") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barracks"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barracks",
            "jbad_mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "jbad_hangar_"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
            "helipads"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
            "helipads"
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "hbarrier",
            "tenthangar",
            "jbad_mil_"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
            "jbad_house_",
            "jbad_house2_",
            "jbad_house3",
            "jbad_house5",
            "jbad_house6",
            "jbad_house7",
            "jbad_house8",
            "jbad_a_mosque_",
            "jbad_a_minaret",
            "jbad_mosque_",
            "jbad_market_",
            "qualat",
            "slum",
            "shed",
            "garage",
            "stone_housebig",
            "stone_housesmall"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "jbad_house2_",
            "jbad_mosque_"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "dieselpowerplant",
            "solarpowerplant",
            "windpowerplant",
            "wavepowerplant",
            "powerstation"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "jbad_tv_",
            "jbad_antenna"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "jbad_a_stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "jbad_ind_garage01",
            "indpipe"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "concretemixingplant",
            "scrapyard",
            "wip",
            "jbad_bedna",
            "jbad_cihly1",
            "jbad_cihly2",
            "jbad_cihly3",
            "jbad_cihly4",
            "jbad_koz",
            "jbad_ind_coltan",
            "jbad_ind_shed"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        ];

    };

    // Bornholm
    if(_worldName == "Bornholm") then {

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
            "dome_"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
            "house_",
            "shop_",
            "garage_",
            "stone_",
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
            "deutshe",
            "house"
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
            "ttowerbig",
            "tvtower",
            "illuminanttower",
            "vysilac_fm",
            "telek"
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
            "dp_bigtank",
            "expedice",
            "indpipe",
            "komin",
            "ind_stack_big",
            "ind_tankbig",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "wip",
            "bridge_highway",
            "ind_mlyn_01",
            "ind_pec_01",
            "sawmill",
            "workshop",
            "ind_timbers"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "church",
            "hospital",
            "amphitheater",
            "chapel_v",
            "households",
            "church",
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
            "deutshe",
            "house"
        ];

    };

    // Lingor A3
    if(_worldName == "lingor3") then {

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

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        ];

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

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

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

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            ];
    };

    // Fallujah
    if(_worldName == "fallujah") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "airport",
            "bunker",
            "watchtower",
            "fortified"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower",
            "watchtower",
            "fortified"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower",
            "miloffices"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
            "heli_h_rescue"
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "radar",
            "bunker",
            "deerstand",
            "hbarrier",
            "razorwire",
            "vez",
            "watchtower",
            "fortified"
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
            "illuminanttower",
            "vysilac_fm",
            "telek",
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "wtower"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
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
            "ind_mlyn_01",
            "ind_pec_01",
            "wip",
            "bridge_highway",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "fallujah_hou",
            "hospital"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // everon2014
    if(_worldName == "everon2014") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker",
            "cargo_house_v",
            "cargo_patrol_",
            "research",
            "airport",
            "bunker",
            "watchtower",
            "fortified",
            "army",
            "vez",
            "budova",
            "mesto3"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "cargo_hq_",
            "miloffices",
            "cargo_house_v",
            "cargo_patrol_",
            "research",
            "barrack",
            "mil_house",
            "mil_controltower",
            "watchtower",
            "fortified"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "cargo_hq_",
            "miloffices",
            "cargo_tower",
            "barrack",
            "mil_house",
            "mil_controltower",
            "miloffices"
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
            "helipads",
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
            "helipads",
            "heli_h_rescue"
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
            "dome",
            "deerstand",
            "hbarrier",
            "vez",
            "watchtower",
            "fortified",
            "vez",
            "hlaska",
            "budova",
            "posed",
            "hospital"
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
            "spp_t",
            "pec_",
            "powerstation",
            "trafostanica"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "communication_f",
            "ttowerbig_",
            "illuminanttower",
            "vysilac_fm",
            "telek",
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
            "nav_pier",
            "pier_",
            "najezd",
            "cargo",
            "nabrezi",
            "podesta"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "dp_bigtank",
            "fuelstation",
            "expedice",
            "komin",
            "fuel_tank_big"
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
            "households",
            "olezlina",
            "domek",
            "dum",
            "kulna",
            "statek",
            "afbar",
            "panelak",
            "deutshe",
            "mesto",
            "hotel"
        ];

    };

    // Namalsk
    if(_worldName == "Namalsk") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [

        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
            "heli_h_civil"
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "razorwire",
            "vez",
            "hlaska"
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
            "vysilac_fm"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "Crane",
            "lighthouse",
            "nav_pier",
            "pier_",
            "wtower"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "expedice",
            "komin",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // smd sahrani a3
    if(_worldName == "smd_sahrani_a3") then {

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

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [

        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

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

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [

        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [

        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "najezd",
            "cargo",
            "nabrezi",
            "podesta"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "expedice",
            "indpipe"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [

        ];

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

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [

        ];
    };

    // SMD Sahrani
    if(_worldName == "smd_sahrani_a2" || _worldName == "Sara" || _worldName == "SaraLite" || _worldName == "Sara_dbe1") then {

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

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "olezlina",
            "domek",
            "dum",
            "kulna",
            "statek",
            "afbar",
            "panelak",
            "deutshe",
            "mesto",
            "hotel"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "najezd",
            "cargo",
            "nabrezi",
            "podesta"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Thirsk
    if(_worldName == "thirsk" || _worldName == "thirskw" ) then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "airport"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "ss_hangar",
            "hangar",
            "runway_end",
            "runway_main"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [

        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
            "heli_h_civil"
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "razorwire",
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office02"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "powerstation",
            "trafostanica"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "illuminanttower",
            "vysilac_fm",
            "telek",
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "wtower"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "indpipe",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Chernarus
    if(_worldName == "Chernarus" || _worldName == "Chernarus_Summer" || _worldName == "sfp_sturko" || _worldName == "tavi") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02",
            "a_municipaloffice"
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
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
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
            "ind_mlyn_01",
            "ind_pec_01",
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "houseblock",
            "generalstore",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Chernarus Winter
    if(tolower(_worldName) == "chernarus_winter") then {
        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["airport_tower","radar","bunker","cargo_house_v","cargo_patrol_","research","mil_wall","fortification","razorwire","dome","deerstand","vez"];
        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["bunker","cargo_house_v","cargo_patrol_","research","bunker"];
        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["barrack","cargo_hq_","miloffices","cargo_house_v","cargo_patrol_","research","barrack","mil_house","mil_controltower"];
        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["barrack","cargo_hq_","miloffices","cargo_tower","barrack","mil_house","mil_controltower"];
        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["hangar","hangar"];
        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + ["tenthangar"];
        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + ["hangar","runway_beton","runway_main","runway_secondary","ss_hangar","hangar_2","hangar","runway_beton","runway_end","runway_main","runway_secondary"];
        ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["helipads"];
        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["helipads"];
        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + ["helipads"];
        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["church","hospital","amphitheater","chapel_v","households","hospital","houseblock","generalstore","house"];
        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["offices","a_office01","a_office02","a_municipaloffice"];
        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["church","hospital","amphitheater","chapel_v","households","hospital","houseblock","generalstore","house"];
        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["dp_main","spp_t","pec_","powerstation","trafostanica"];
        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + ["communication_f","ttowerbig_","illuminanttower","vysilac_fm","telek","tvtower"];
        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["crane","lighthouse","nav_pier","pier_","crane","lighthouse","nav_pier","pier_","pier"];
        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + ["rail_house","rail_station","rail_platform","rails_bridge","stationhouse"];
        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["fuelstation","dp_bigtank","fuelstation","expedice","indpipe","komin","ind_stack_big","ind_tankbig","fuel_tank_big"];
        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["wip","bridge_highway","ind_mlyn_01","ind_pec_01","wip","sawmillpen","workshop"];
    };

    // Helvantis
    if(_worldName == "anim_helvantis_v2") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "ss_hangar",
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "wf_",
            "wf_depot",
            "wf_field_hospital_west",
            "wf_field_hospital_east",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "tents",
            "tent_",
            "tent_east",
            "tent_west",
            "mil_",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "ss_hangar",
            "hangar_2",
            "hangar",
            "airport_center_f",
            "airport_left_f",
            "airport_right_f",
            "airport_tower_f",
            "runway_beton",
            "runway_end",
            "runway_main",
            "runway_secondary"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "misc3",
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02",
            "a_municipaloffice"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "pec_",
            "powerstation",
            "solarpowerplant",
            "trafostanica",
            "dieselpowerplant"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "illuminanttower",
            "transmitter_tower",
            "vysilac_fm",
            "telek",
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
            "nav_pier",
            "pier_",
            "pier"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "rail_house",
            "rail_station",
            "rail_station_big",
            "rail_platform",
            "rails_bridge",
            "stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "ind_oil_mine",
            "expedice",
            "indpipe",
            "komin",
            "ind_stack_big",
            "ind_tankbig",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "ind_mlyn_01",
            "ind_quarry",
            "cmp_",
            "ind_sawmill",
            "factory",
            "ind_pec_01",
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "a_castle_",
            "barn_",
            "barn_w",
            "houseblock",
            "houseblocks",
            "generalstore",
            "ghosthotel",
            "households",
            "sara_",
            "domek",
            "dum_",
            "panelaky",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Podagorsk
    if(_worldName == "fdf_isle1_a") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02",
            "a_municipaloffice"
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
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
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
            "ind_mlyn_01",
            "ind_pec_01",
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "houseblock",
            "generalstore",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // MBG Celle 2
    if(_worldName == "mbg_celle2" || _worldName == "Celle") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02",
            "a_municipaloffice"
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
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
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
            "ind_mlyn_01",
            "ind_pec_01",
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "houseblock",
            "generalstore",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Shapur
    if(_worldName == "Shapur_BAF") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "powerstation"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "indpipe",
            "komin",
            "ind_tankbig",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Takistan
    if(_worldName == "Takistan") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "airport",
            "watchtower",
            "fortified"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower",
            "watchtower",
            "fortified"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower",
            "miloffices"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "hangar",
            "runway_beton",
            "runway_end",
            "runway_main"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "razorwire",
            "vez",
            "watchtower",
            "fortified"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "powerstation"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "indpipe",
            "ind_tankbig",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "coltan"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Zargabad
    if(_worldName == "Zargabad") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker",
            "barrack"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "hangar",
            "runway_beton",
            "runway_end",
            "runway_main",
            "runway_secondary"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "powerstation"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "indpipe",
            "komin",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "houseblock",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // CLAfghan
    if(_worldName == "CLAfghan") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker",
            "barrack",
            "guardhouse"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "hangar",
            "runway_beton",
            "runway_end",
            "runway_main",
            "runway_secondary"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "vez",
            "guardtower",
            "tents",
            "fortified",
            "bunker",
            "guardhouse",
            "fortress"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "powerstation"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "indpipe",
            "komin",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "ind_sawmill"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "houseblock",
            "house",
            "opxbuildings"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // MCN Hazarkot
    if(_worldName == "MCN_HazarKot") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "ind_coltan_mine"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Isola Di Capraia
    if(_worldName == "isoladicapraia" || _worldName == "napf") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02",
            "a_municipaloffice"
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
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
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
            "ind_mlyn_01",
            "ind_pec_01",
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "houseblock",
            "generalstore",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Caribou
    if(_worldName == "caribou") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "bunker"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "vez"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02",
            "a_municipaloffice"
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
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane",
            "lighthouse",
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
            "ind_mlyn_01",
            "ind_pec_01",
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "houseblock",
            "generalstore",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Tigeria
    if(_worldName == "tigeria") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower",
            "mil_guardhouse",
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
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand",
            "vez",
            "army_hut",
            "barrack",
            "mil_house",
            "mil_controltower",
            "mil_guardhouse",
            "deerstand"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01"
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
            "tvtower"
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
            "expedice",
            "indpipe",
            "komin",
            "ind_tankbig"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "wip",
            "sawmillpen",
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "generalstore",
            "house",
            "domek",
            "dum_",
            "hut0"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Fata
    if(_worldName == "fata") then {

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

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

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

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

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

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Afghan Village
    if(_worldName == "praa_av") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "mil"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "mil"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "vez",
            "mil"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "powerstation",
            "ind_coltan_mine",
            "ind_pipes"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "ind_tankbig"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "wip",
            "ind_coltan_mine"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Sangin
    if(_worldName == "hellskitchen" || _worldName == "hellskitchens") then {

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

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "ss_hangar",
            "hangar_2",
            "hangar"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [

        ];

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

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

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

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Torabora
    if(_worldName == "torabora") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "construction"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // TUP Qom
    if(_worldName == "tup_qom") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "barrack"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower",
            "guardhouse"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

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
            "heli_h_army"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "vez",
            "barrack",
            "mil_house",
            "mil_controltower",
            "guardhouse"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "pec_",
            "powerstation",
            "trafostanica",
            "powerstation"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "illuminanttower",
            "vysilac_fm",
            "telek",
            "tvtower"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
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
            "ind_mlyn_01",
            "wip",
            "workshop",
            "ind_coltan_mine"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "hospital",
            "generalstore",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;
    };

    // Utes
    if(_worldName == "utes") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "barrack"
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower",
            "guardhouse"
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
            "barrack",
            "mil_house",
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "ss_hangar",
            "hangar_2",
            "hangar"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "vez",
            "barrack",
            "mil_house",
            "mil_controltower",
            "guardhouse"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "nav_"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    //Kalu Khan (6)
    if(tolower(_worldName) == "pja306") then {
        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["ca\misc_e\fortified_nest_small_ep1.p3d","ca\structures_e\mil\mil_barracks_l_ep1.p3d","ca\buildings2\ind_tank\ind_tankbig.p3d","ca\structures_e\mil\mil_barracks_i_ep1.p3d","ca\misc_e\fortified_nest_big_ep1.p3d","ca\structures_e\mil\mil_house_ep1.p3d","ca\structures_e\mil\mil_guardhouse_ep1.p3d"];
        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];
        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["ca\structures_e\mil\mil_barracks_l_ep1.p3d"];
        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["ca\structures_e\mil\mil_house_ep1.p3d"];
        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["ca\roads_e\runway\runway_main_ep1.p3d","ca\roads_e\runway\runway_main_40_ep1.p3d"];
        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + ["ca\roads_e\runway\runway_main_ep1.p3d","ca\roads_e\runway\runway_main_40_ep1.p3d"];
        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];
        ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];
        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];
        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housec\house_c_5_v1_ep1.p3d","ca\structures_e\housec\house_c_5_v2_ep1.p3d","ca\structures_e\housel\house_l_3_ruins_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures\shed_ind\shed_ind02.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d","ca\structures_e\misc\shed_m01_ep1.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d","ca\structures_e\housec\house_c_3_ep1.p3d","ca\structures_e\housel\house_l_7_ruins_ep1.p3d","ca\structures_e\housel\house_l_8_ruins_ep1.p3d","ca\structures_e\housek\house_k_1_ruins_ep1.p3d","ca\structures_e\housec\house_c_12_ruins_ep1.p3d","ca\structures_e\housec\house_c_4_ruins_ep1.p3d","ca\structures_e\housek\house_k_6_ruins_ep1.p3d","ca\structures_e\housek\house_k_5_ruins_ep1.p3d","ca\structures_e\housec\house_c_2_ruins_ep1.p3d","ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housec\house_c_5_v3_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d"];
        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d"];
        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housec\house_c_5_v1_ep1.p3d","ca\structures_e\housec\house_c_5_v2_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_3_ep1.p3d","ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housec\house_c_5_v3_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d"];
        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [];
        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];
        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];
        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + ["ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_end_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_switch_ep1.p3d"];
        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d"];
        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["ca\structures_e\misc\misc_construction\misc_concbox_ep1.p3d","ca\structures_e\misc\misc_construction\misc_concoutlet_ep1.p3d"];
    };

    // Reshmaan
    if(_worldName == "reshmaan") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
            "watchtower",
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
            "mil_controltower"
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "hangar",
            "runway_beton",
            "runway_end",
            "runway_main"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
            "heli_h_army",
            "heli_h_rescue"
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "vez",
            "fortified"
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
           "vysilac_fm"
       ];

       ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
           "crane",
           "cargo"
       ];

       ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
           "stationhouse"
       ];

       ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
           "fuelstation"
       ];

       ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
           "wip",
           "ind_coltan_mine"
       ];

       ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
           "hospital",
           "dum",
           "shed",
           "house"
       ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // MCN Aliabad
    if(_worldName == "MCN_Aliabad") then {

        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        ];

        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        ];

        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        ];

        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        ];

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
            "misc_powerline"
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "ind_coltan_mine"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Bystrica
    if(_worldName == "woodland_acr") then {

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

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

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

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Bukovina
    if(_worldName == "bootcamp_acr") then {

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

        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

        ];

        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
            "hangar"
        ];

        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        ];

        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        ];

        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
            "deerstand"
        ];

        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
            "a_office01",
            "a_office02"
        ];

        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        ];

        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
            "vysilac_fm"
        ];

        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
            "crane"
        ];

        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
            "stationhouse"
        ];

        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
            "fuelstation",
            "komin",
            "fuel_tank_big"
        ];

        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
            "workshop"
        ];

        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
            "houseblock",
            "generalstore",
            "house"
        ];

        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

    };

    // Australia down under shrimps on the barbie mate - not Austria!
    if(tolower(_worldName) == "australia") then {
        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d","a3\structures_f\mil\offices\miloffices_v1_f.p3d","ca\buildings\hangar_2.p3d","ca\buildings\army_hut2_int.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","ca\buildings\hlidac_budka.p3d","mm_bank\commonwealthbank.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","mm_buildings\prison\gaol_main.p3d","mm_buildings\prison\mapobject\gaol_tower.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","ca\buildings\budova4_in.p3d","ca\buildings\army_hut3_long.p3d","ca\buildings\army_hut_int.p3d","ca\buildings\army_hut3_long_int.p3d","ca\buildings\hlaska.p3d","ca\buildings\tents\fortress_01.p3d","ca\buildings\army_hut_storrage.p3d","mm_buildings\prison\proxy\mainsection.p3d","ca\buildings\garaz_bez_tanku.p3d","ca\buildings\garaz_s_tankem.p3d","ca\buildings\budova2.p3d","ca\buildings\army_hut2.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","ca\buildings\ammostore2.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","ca\misc_e\guardshed_ep1.p3d","ausextras\objects\ausbunker.p3d","a3\structures_f\research\dome_big_f.p3d","ca\misc3\fortified_nest_small.p3d","ca\buildings\budova1.p3d","ca\misc2\barrack2\barrack2.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d","a3\structures_f\mil\cargo\medevac_house_v1_f.p3d"];
        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","ca\buildings\budova4_in.p3d","ca\buildings\army_hut3_long.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d"];
        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","mm_bank\commonwealthbank.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","ca\buildings\budova4_in.p3d","mm_buildings\prison\proxy\mainsection.p3d","ca\buildings\garaz_bez_tanku.p3d","ca\buildings\garaz_s_tankem.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","a3\structures_f\research\dome_big_f.p3d"];
        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","mm_bank\commonwealthbank.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","mm_buildings\prison\proxy\mainsection.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","ca\misc2\barrack2\barrack2.p3d"];
        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["ca\roads\runway_pojdraha.p3d","a3\roads_f\runway\runway_end02_f.p3d","a3\roads_f\runway\runway_main_f.p3d","a3\structures_f\ind\airport\hangar_f.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d","ca\roads\runway_end0.p3d","ca\roads\runway_poj_end9.p3d","ca\roads\runway_poj_tcross.p3d","ca\roads\runway_main.p3d","ca\roads\runway_end27.p3d","ca\roads\runway_poj_end27.p3d","ca\roads2\runway_end33.p3d","ca\roads\runway_dirt.p3d","ca\buildings\letistni_hala.p3d","ca\roads\runway_end9.p3d","ca\misc\heli_h_civil.p3d"];
        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + ["a3\structures_f\ind\airport\airport_left_f.p3d","a3\structures_f\ind\airport\airport_right_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","ca\misc\heli_h_civil.p3d"];
        ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["ca\misc\heli_h_army.p3d","mm_buildings\prison\mapobject\helipad\helipad.p3d","ca\misc\heli_h_rescue.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d","a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"];
        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["ca\misc\heli_h_army.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d","a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"];
        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + ["ca\misc\heli_h_rescue.p3d"];
        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","ca\buildings\hangar_2.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","ca\buildings\hut_old02.p3d","a3\structures_f\households\slum\cargo_house_slum_f.p3d","e76_buildings\shops\e76_shop_multi1.p3d","mm_buildings3\pub_c\pub_c.p3d","mm_post\build2\postb.p3d","mm_bank\commonwealthbank.p3d","mm_residential\residential_a\houseb.p3d","mm_residential\residential_a\housea.p3d","mm_residential\residential_a\houseb1.p3d","ausextras\a_generalstore_01\iga_generalstore.p3d","ca\buildings\kulna.p3d","mm_residential\residential_a\housea1.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","mm_buildings3\pub_a\pub_a.p3d","a3\structures_f\dominants\hospital\hospital_side1_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\ind\carservice\carservice_f.p3d","a3\structures_f\households\slum\slum_house02_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","mm_residential2\housedoubleal2.p3d","a3\structures_f_epc\civ\kiosks\kiosk_gyros_f.p3d","a3\structures_f_epc\civ\kiosks\kiosk_redburger_f.p3d","ausextras\a_generalstore_01\iga_generalstore2.p3d","mm_residential\residential_a\house_l\housec1_l.p3d","mm_residential\residential_a\housec_r.p3d","a3\structures_f_epc\dominants\stadium\stadium_p3_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p2_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p9_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p4_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p1_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p5_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p8_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p6_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p7_f.p3d","mm_buildings4\centrelink.p3d","ca\buildings\dum_istan4.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","e76_buildings\shops\e76_shop_single1.p3d","ca\buildings\hotel.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d","mm_residential2\housedoubleal.p3d","ca\structures_e\housec\house_c_10_ep1.p3d","ca\misc\water_tank.p3d","ca\structures\furniture\cases\skrin_bar\skrin_bar.p3d","a3\structures_f_epc\civ\kiosks\kiosk_papers_f.p3d","ca\buildings\shop2.p3d","ca\buildings\shop3.p3d","ca\buildings\shop1.p3d","ca\buildings\shop1_double.p3d","ca\buildings\shop2_double.p3d","ca\buildings\shop4.p3d","ca\buildings\shop5_double.p3d","ca\buildings\dum_istan3_hromada2.p3d","a3\structures_f\dominants\church\church_01_v1_f.p3d","ca\buildings\hut04.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_gazebo_f.p3d","a3\structures_f_epc\civ\kiosks\kiosk_blueking_f.p3d","ca\structures\house\a_stationhouse\a_stationhouse.p3d","ca\structures\barn_w\barn_w_02.p3d","mm_residential\residential_a\house_l\housea1_l.p3d","ca\buildings\dum_istan4_big.p3d","ca\buildings\dum_mesto3_istan.p3d","ca\buildings\dum_istan4_big_inverse.p3d","ca\structures\house\housebt\houseb_tenement.p3d","ca\structures\a_municipaloffice\a_municipaloffice.p3d","ca\buildings\shop5.p3d","ca\buildings\dum_istan2_01.p3d","ca\buildings\dum_istan2b.p3d","ca\buildings\dum_istan4_inverse.p3d","ca\buildings\dum_istan4_detaily1.p3d","e76_buildings\tower\e76_tower7.p3d","ca\buildings\dum_istan2_03.p3d","ca\buildings\garaz.p3d","ca\buildings\dum_istan3_hromada.p3d","ca\buildings\dum_istan2_02.p3d","ca\buildings\dum_istan2_04a.p3d","ausextras\shops\shopelectricsdouble.p3d","ca\buildings\kostel2.p3d","ca\buildings\hotel_riviera1.p3d","ca\buildings\hotel_riviera2.p3d","ca\buildings\statek_kulna.p3d","ca\structures\house\housev\housev_1i4.p3d","ca\buildings\bouda2_vnitrek.p3d","ca\structures\house\a_office01\data\proxy\doorinterier.p3d","mm_residential\residential_a\house_l\houseb1_l.p3d","ca\buildings\budova3.p3d","plp_beachobjects\plp_bo_beachbar.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\buildings\hut02.p3d"];
        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","ca\buildings\hut_old02.p3d","mm_buildings3\pub_c\pub_c.p3d","mm_post\build2\postb.p3d","mm_bank\commonwealthbank.p3d","mm_residential\residential_a\houseb.p3d","mm_residential\residential_a\housea.p3d","mm_residential\residential_a\houseb1.p3d","mm_residential\residential_a\housea1.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","mm_residential2\housedoubleal2.p3d","mm_residential\residential_a\house_l\housec1_l.p3d","mm_residential\residential_a\housec_r.p3d","mm_buildings4\centrelink.p3d","ca\structures\house\a_office02\a_office02.p3d","ca\buildings\hotel.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","mm_residential2\housedoubleal.p3d","mm_apartment\a_office02c.p3d","ca\structures\barn_w\barn_w_02.p3d","mm_residential\residential_a\house_l\housea1_l.p3d","ca\structures\house\housebt\houseb_tenement.p3d","mm_residential\residential_a\house_l\houseb1_l.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\buildings\hut02.p3d"];
        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["a3\structures_f\households\slum\cargo_house_slum_f.p3d","mm_buildings3\pub_c\pub_c.p3d","mm_residential\residential_a\houseb.p3d","mm_residential\residential_a\housea.p3d","mm_residential\residential_a\houseb1.p3d","mm_residential\residential_a\housea1.p3d","mm_buildings3\pub_a\pub_a.p3d","a3\structures_f\households\slum\slum_house02_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","mm_residential2\housedoubleal2.p3d","mm_residential\residential_a\house_l\housec1_l.p3d","mm_residential\residential_a\housec_r.p3d","ca\buildings\hotel.p3d","mm_residential2\housedoubleal.p3d","mm_residential\residential_a\house_l\housea1_l.p3d","ca\structures\house\housebt\houseb_tenement.p3d","mm_residential\residential_a\house_l\houseb1_l.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\buildings\hut02.p3d"];
        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d","a3\structures_f\ind\powerlines\highvoltagecolumn_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d","a3\structures_f\ind\powerlines\powerline_distributor_f.p3d","a3\structures_f\civ\lamps\lampsolar_f.p3d","a3\structures_f\items\electronics\portable_generator_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d","a3\structures_f\ind\transmitter_tower\tbox_f.p3d","a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d","ca\buildings\trafostanica_mala.p3d","a3\structures_f\ind\windpowerplant\wpp_turbine_v2_f.p3d","ca\buildings\misc\stozarvn_1.p3d","a3\structures_f\ind\powerlines\highvoltageend_f.p3d","ca\misc_e\powgen_big_ep1.p3d","a3\structures_f\ind\windpowerplant\wpp_turbine_v1_f.p3d","a3\structures_f\ind\windpowerplant\powergenerator_f.p3d","ca\misc_e\powgen_big.p3d","ca\misc2\samsite\powgen_big.p3d","a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d","a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d","ca\buildings\watertower1.p3d","ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d","a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d"];
        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + ["a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d","ca\buildings\vysilac_fm.p3d","dbe1\models_dbe1\vysilac\vysilac_budova.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d","ca\buildings\telek1.p3d","ca\structures\proxy_buildingparts\roof\antennabigroof\antenna_big_roof.p3d","ca\structures\a_tvtower\a_tvtower_mid.p3d","ca\structures\a_tvtower\a_tvtower_top.p3d","ca\structures\a_tvtower\a_tvtower_base.p3d","a3\structures_f\ind\transmitter_tower\communication_f.p3d","ca\structures_e\misc\com_tower_ep1.p3d","a3\structures_f\mil\radar\radar_f.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d","ca\buildings\vysilac_fm2.p3d","ca\misc_e\76n6_clamshell_ep1.p3d","a3\structures_f\mil\radar\radar_small_f.p3d"];
        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["ca\buildings\molo_krychle.p3d","a3\structures_f\naval\piers\pier_f.p3d","ca\buildings2\a_crane_02\a_crane_02b.p3d","ca\buildings2\a_crane_02\a_crane_02a.p3d","a3\structures_f\dominants\lighthouse\lighthouse_f.p3d","a3\structures_f\naval\piers\pier_wall_f.p3d","ca\buildings\molo_beton.p3d","ca\buildings\nabrezi.p3d","ca\buildings\nabrezi_najezd.p3d","ca\structures\nav_pier\nav_pier_f_17.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","ca\buildings\hut01.p3d","ca\structures\nav_pier\nav_pier_m_end.p3d","ca\structures\nav_pier\nav_pier_m_2.p3d","ca\structures\nav_boathouse\nav_boathouse_pierr.p3d","ca\structures\nav_boathouse\nav_boathouse_pierl.p3d","ca\structures\nav_boathouse\nav_boathouse.p3d","ca\structures\nav_pier\nav_pier_c.p3d","ca\structures\nav_pier\nav_pier_c2.p3d","ca\structures\nav_pier\nav_pier_c_90.p3d","ca\structures\nav_pier\nav_pier_m_1.p3d","a3\structures_f\naval\piers\pillar_pier_f.p3d","ca\structures\nav_pier\nav_pier_c_r.p3d","ca\structures\nav_pier\nav_pier_c_r30.p3d","ca\structures\nav_pier\nav_pier_c_l.p3d","ca\structures\nav_pier\nav_pier_c_big.p3d","ca\structures\nav_pier\nav_pier_c_t20.p3d"];
        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["ca\buildings\fuelstation_army.p3d","ca\misc\fuel_tank_small.p3d","a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d","a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d","ca\buildings2\ind_pipeline\indpipe2\indpipe2_smallbuild2_l.p3d","ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d","ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d","a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d","ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d","ca\buildings2\ind_tank\ind_tanksmall.p3d","ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d","ca\buildings2\ind_tank\ind_tanksmall2.p3d","ca\buildings\fuelstation.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d"];
        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d","ca\structures\a_buildingwip\a_buildingwip.p3d","ca\buildings2\ind_workshop01\ind_workshop01_box.p3d","ca\buildings2\ind_workshop01\ind_workshop01_01.p3d","ca\buildings2\ind_workshop01\ind_workshop01_03.p3d","ca\buildings2\ind_workshop01\ind_workshop01_l.p3d","ca\buildings2\ind_workshop01\ind_workshop01_02.p3d","ca\buildings2\ind_workshop01\ind_workshop01_04.p3d","ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d","ca\structures\ind_sawmill\ind_sawmillpen.p3d","ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d","ca\buildings\komin.p3d","ca\structures_e\housea\a_buildingwip\a_buildingwip_ep1.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d","ca\structures\shed_ind\shed_ind02.p3d","a3\structures_f\households\wip\unfinished_building_01_f.p3d","a3\structures_f\households\addons\metal_shed_f.p3d","ca\structures\a_cranecon\a_cranecon.p3d","ca\buildings\repair_center.p3d","ca\misc3\toilet.p3d","mm_residential2\studs\studstage1.p3d","mm_residential2\studs\studstage3.p3d","ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d","ca\buildings2\ind_cementworks\ind_silomale\ind_silomale.p3d","ca\buildings2\barn_metal\barn_metal.p3d","a3\structures_f\ind\factory\factory_conv1_10_f.p3d","a3\structures_f\ind\factory\factory_conv1_main_f.p3d","a3\structures_f\ind\factory\factory_hopper_f.p3d","a3\structures_f\ind\factory\factory_main_f.p3d","a3\structures_f\ind\factory\factory_conv1_end_f.p3d","a3\structures_f\ind\factory\factory_conv2_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d","a3\structures_f\households\wip\unfinished_building_02_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","mm_civilengineering\crane\cranebase.p3d","mm_civilengineering\crane\cranemid.p3d","mm_civilengineering\crane\cranetop.p3d","mm_residential2\studs\studstage2.p3d","ca\buildings\budova2.p3d","ca\buildings\army_hut2.p3d","ca\structures\ind_sawmill\ind_sawmill.p3d","a3\structures_f\ind\concretemixingplant\cmp_hopper_f.p3d","ca\structures\ind_quarry\ind_hammermill.p3d","a3\structures_f\ind\shed\u_shed_ind_f.p3d","ausextras\objects\crane.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_end_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_switch_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d"];
    };

    // MSKE
    if(_worldName == "mske") then {

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

    //Kunar Region
    if(tolower(_worldName) == "kunar_region") then {
        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["ca\misc3\fort_watchtower.p3d","ca\misc\fort_razorwire.p3d","ca\misc3\camonetb_nato.p3d","ca\misc2\barrack2\barrack2.p3d","ca\misc3\antenna.p3d","ca\misc3\fort_bagfence_round.p3d","ca\misc2\guardshed.p3d","ca\misc3\fort_bagfence_long.p3d","ca\misc2\hbarrier5_round15.p3d","ca\misc3\fort_bagfence_corner.p3d","ca\misc3\tent2_west.p3d","ca\misc3\fort_rampart.p3d","ca\misc3\fortified_nest_big.p3d","ca\misc3\fortified_nest_small.p3d","ca\misc3\wf\wf_hesco_big_10x.p3d","ca\misc3\camonet_nato_var1.p3d","ca\structures_e\mil\mil_guardhouse_ep1.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d","ca\structures_e\mil\mil_repair_center_ep1.p3d","ca\structures_e\mil\mil_barracks_i_ep1.p3d","ca\structures_e\mil\mil_barracks_l_ep1.p3d","ca\misc3\fort_artillery_nest.p3d"];
        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["ca\misc2\barrack2\barrack2.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d","ca\structures_e\mil\mil_repair_center_ep1.p3d"];
        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["ca\misc2\barrack2\barrack2.p3d","ca\misc3\tent_west.p3d","ca\misc3\tent2_west.p3d","ca\structures_e\mil\mil_guardhouse_ep1.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d"];
        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["ca\misc2\barrack2\barrack2.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d"];
        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];
        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];
        ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];
        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];
        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d","ca\structures_e\misc\misc_market\kiosk_ep1.p3d","ca\structures_e\misc\misc_market\covering_hut_big_ep1.p3d","ca\structures_e\misc\shed_w02_ep1.p3d","ca\structures_e\misc\shed_m01_ep1.p3d","opxbuildings\hut6.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d","ca\structures_e\housec\house_c_1_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d","ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d"];
        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d"];
        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housec\house_c_1_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d"];
        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["ca\misc3\powergenerator\powergenerator.p3d"];
        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];
        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];
        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["ca\misc\fuel_tank_small.p3d"];
        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["ca\structures_e\misc\misc_construction\misc_concbox_ep1.p3d","opxbuildings\ruin.p3d"];
    };

    //Kapaulio - index by psvialli
    if(tolower(_worldName) == "kapaulio") then {
        ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + ["a3\structures_f_epa\civ\constructions\portablelight_double_f.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","a3\structures_f_epb\naval\fishing\fishinggear_01_f.p3d","a3\structures_f\walls\cncwall4_f.p3d","a3\structures_f_epa\items\medical\defibrillator_f.p3d","a3\structures_f_epa\items\medical\disinfectantspray_f.p3d","a3\structures_f_epa\items\tools\ducttape_f.p3d","a3\structures_f_bootcamp\items\food\foodcontainer_01_f.p3d","a3\structures_f_epa\items\medical\antibiotic_f.p3d","a3\structures_f_epa\items\medical\bandage_f.p3d","a3\roads_f\runway\runwaylights\flush_light_red_f.p3d","a3\structures_f\wrecks\wreck_hunter_f.p3d","a3\structures_f\mil\bagfence\bagfence_long_f.p3d","a3\structures_f_epb\naval\fishing\fishinggear_02_f.p3d","a3\structures_f\ind\wavepowerplant\wavepowerplant_f.p3d","a3\structures_f\ind\wavepowerplant\wavepowerplantbroken_f.p3d","jbad_misc\misc_market\jbad_crates.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_stairs_f.p3d","a3\structures_f\training\rampconcrete_f.p3d","a3\structures_f\training\rampconcretehigh_f.p3d","a3\structures_f\wrecks\wreck_ural_f.p3d","a3\structures_f\items\electronics\survivalradio_f.p3d","a3\structures_f\items\food\tacticalbacon_f.p3d","a3\structures_f_epa\mil\scrapyard\pallet_milboxes_f.p3d","a3\structures_f_epa\items\medical\vitaminbottle_f.p3d","a3\structures_f_epa\items\food\ricebox_f.p3d","a3\structures_f_epa\civ\camping\woodentable_large_f.p3d","a3\structures_f\walls\cncwall1_f.p3d","a3\structures_f_epa\mil\scrapyard\paperbox_open_full_f.p3d","a3\structures_f\items\food\bottleplastic_v1_f.p3d","a3\structures_f_epa\items\food\bottleplastic_v2_f.p3d","a3\structures_f_epa\items\tools\fireextinguisher_f.p3d","a3\structures_f\items\electronics\fmradio_f.p3d","a3\structures_f\civ\infoboards\mapboard_f.p3d","a3\structures_f_epa\mil\scrapyard\paperbox_closed_f.p3d","a3\structures_f_epa\items\food\canteen_f.p3d","a3\structures_f_epa\mil\scrapyard\paperbox_open_empty_f.p3d","a3\structures_f_epa\items\tools\metalwire_f.p3d","a3\structures_f_epb\civ\dead\grave_dirt_f.p3d","a3\structures_f_epa\civ\constructions\pallets_stack_f.p3d","a3\structures_f\research\dome_b_cargo_entrance_f.p3d","a3\structures_f\research\dome_b_person_entrance_f.p3d","a3\structures_f\civ\infoboards\billboard_f.p3d","a3\structures_f_epc\civ\accessories\bench_01_f.p3d","a3\structures_f_epa\civ\camping\woodentable_small_f.p3d","a3\structures_f_epa\items\tools\gascanister_f.p3d","a3\structures_f\items\tools\meter3m_f.p3d","a3\structures_f_epb\items\vessels\barrelsand_grey_f.p3d","a3\structures_f_epa\items\vessels\tincontainer_f.p3d","a3\structures_f_epa\items\food\bakedbeans_f.p3d","a3\structures_f_epa\items\medical\heatpack_f.p3d","a3\structures_f\walls\cncbarrier_stripes_f.p3d","a3\structures_f\walls\cncbarriermedium4_f.p3d","a3\structures_f\mil\flags\mast_f.p3d","a3\structures_f_epa\mil\scrapyard\scrap_mrap_01_f.p3d","a3\structures_f\wrecks\wreck_uaz_f.p3d","a3\structures_f\civ\lamps\lampsolar_f.p3d","a3\structures_f\ind\cargo\cargo40_color_v2_ruins_f.p3d","a3\structures_f\households\addons\metal_shed_ruins_f.p3d","a3\structures_f\mil\bagfence\bagfence_round_f.p3d","a3\structures_f\mil\bagfence\bagfence_short_f.p3d","a3\structures_f\items\tools\drillaku_f.p3d","a3\structures_f\items\electronics\extensioncord_f.p3d","a3\structures_f\civ\camping\sleeping_bag_blue_f.p3d","a3\structures_f\items\tools\hammer_f.p3d","a3\structures_f\items\tools\pliers_f.p3d","a3\structures_f\items\electronics\portable_generator_f.p3d","a3\structures_f_epa\items\medical\painkillers_f.p3d","a3\structures_f_epa\mil\scrapyard\scrapheap_2_f.p3d","a3\structures_f_epa\items\food\cerealsbox_f.p3d","a3\structures_f\items\vessels\canisterfuel_f.p3d","a3\structures_f\items\documents\map_f.p3d","a3\structures_f\items\electronics\portablelongrangeradio_f.p3d","a3\structures_f\walls\rampart_f.p3d","a3\structures_f\ind\windpowerplant\wpp_turbine_v2_f.p3d","a3\structures_f_epa\civ\constructions\portablelight_single_f.p3d","a3\structures_f\civ\market\marketshelter_f.p3d","a3\structures_f\walls\cncshelter_f.p3d","a3\structures_f\mil\fortification\hbarrier_3_f.p3d","a3\structures_f_epb\items\vessels\barrelempty_grey_f.p3d","a3\structures_f_epb\items\vessels\barrelwater_grey_f.p3d","a3\structures_f\items\tools\axe_f.p3d","a3\structures_f\civ\camping\sleeping_bag_f.p3d","a3\structures_f\items\food\can_v1_f.p3d","a3\structures_f\items\food\can_v2_f.p3d","a3\structures_f\items\tools\gloves_f.p3d","a3\structures_f\civ\camping\sleeping_bag_brown_f.p3d","a3\structures_f_epa\items\tools\shovel_f.p3d","a3\structures_f_epa\civ\camping\woodenlog_f.p3d","a3\structures_f_epa\items\tools\gascooker_f.p3d","a3\structures_f\items\vessels\barrelempty_f.p3d","a3\structures_f\wrecks\wreck_bmp2_f.p3d","a3\structures_f_epa\items\tools\butanetorch_f.p3d","a3\structures_f_epb\items\luggage\luggageheap_02_f.p3d","a3\structures_f_epb\items\luggage\luggageheap_04_f.p3d","a3\structures_f_epc\civ\camping\sunshade_04_f.p3d","a3\structures_f\walls\indfnc_corner_f.p3d","a3\structures_f\furniture\tabledesk_f.p3d","a3\structures_f_epb\furniture\shelveswooden_f.p3d","a3\structures_f\furniture\chairwood_f.p3d","a3\structures_f_epa\mil\scrapyard\scrapheap_1_f.p3d","a3\structures_f_epb\furniture\shelveswooden_khaki_f.p3d","a3\structures_f\items\tools\dustmask_f.p3d","a3\structures_f_epc\civ\accessories\tableplastic_01_f.p3d","a3\structures_f\civ\ancient\ancientpillar_damaged_f.p3d","a3\structures_f\items\vessels\barreltrash_f.p3d","rspn_assets\models\cover_bluntstone.p3d","a3\structures_f\wrecks\wreck_t72_turret_f.p3d","rspn_assets\models\cover_dirt_inset.p3d","rspn_assets\models\cover_grass_inset.p3d","a3\structures_f\mil\bagfence\bagfence_corner_f.p3d","a3\structures_f\mil\bagfence\bagfence_end_f.p3d","a3\structures_f\civ\accessories\water_source_f.p3d","a3\structures_f_epc\civ\camping\sunshade_01_f.p3d","a3\structures_f_epa\items\tools\butanecanister_f.p3d","a3\structures_f_epa\items\tools\canopener_f.p3d","a3\structures_f\walls\wired_fence_4md_f.p3d","a3\structures_f_epb\civ\graffiti\graffiti_03_f.p3d","a3\structures_f_epb\items\documents\poster_05_f.p3d","a3\structures_f\civ\camping\camping_light_off_f.p3d","a3\structures_f\civ\camping\pillow_old_f.p3d","a3\structures_f\civ\camping\sleeping_bag_blue_folded_f.p3d","a3\structures_f_epa\items\medical\waterpurificationtablets_f.p3d","a3\structures_f\civ\camping\ground_sheet_blue_f.p3d","a3\structures_f\civ\camping\ground_sheet_f.p3d","a3\structures_f\civ\camping\ground_sheet_opfor_f.p3d","a3\structures_f\civ\camping\pillow_camouflage_f.p3d","a3\structures_f\civ\camping\pillow_f.p3d","a3\structures_f\items\vessels\canisteroil_f.p3d","a3\structures_f\civ\camping\pillow_grey_f.p3d","a3\structures_f\civ\camping\sleeping_bag_brown_folded_f.p3d","a3\structures_f_epb\items\luggage\luggageheap_03_f.p3d","a3\structures_f\items\documents\map_unfolded_f.p3d","a3\structures_f\research\dome_small_plates_f.p3d"];
        ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["a3\structures_f\walls\ancient_wall_8m_f.p3d","a3\structures_f\walls\ancient_wall_4m_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\research\research_house_v1_f.p3d","jbad_misc\misc_com\jbad_com_tower.p3d","jbad_structures\mil\jbad_mil_controltower.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\bagbunker\bagbunker_tower_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d","a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\shelters\camonet_open_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\mil\cargo\medevac_house_v1_f.p3d","a3\structures_f_epc\items\electronics\device_disassembled_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d","a3\structures_f\mil\shelters\camonet_big_f.p3d","a3\structures_f\mil\radar\radar_small_f.p3d","a3\structures_f\mil\shelters\camonet_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","rspn_assets\models\cb_long.p3d","rspn_assets\models\cb_entrance02.p3d","rspn_assets\models\cb_h45.p3d","rspn_assets\models\cb_h90.p3d","rspn_assets\models\cb_intersect02.p3d","god_various\hut\hlidac_budka.p3d","rspn_assets\models\cb_intersect01.p3d","rspn_assets\models\cb_end01.p3d","a3\structures_f\mil\radar\radar_f.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f_epc\items\electronics\device_assembled_f.p3d","a3\structures_f\training\target_popup_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\mil\fortification\hbarriertower_f.p3d","jbad_structures\mil\hanger\jbad_hanger_withdoor.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_1.p3d","a3\structures_f\mil\bunker\bunker_f.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_3.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_4.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_2.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no2_f.p3d","a3\structures_f\training\shoot_house_tunnel_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","a3\structures_f\dominants\castle\castle_01_wall_11_f.p3d","a3\structures_f\dominants\castle\castle_01_tower_f.p3d","a3\structures_f\dominants\castle\castle_01_church_b_ruin_f.p3d","a3\structures_f\dominants\castle\castle_01_church_ruin_f.p3d","a3\structures_f\dominants\castle\castle_01_church_a_ruin_f.p3d","a3\structures_f\dominants\castle\castle_01_wall_08_f.p3d","a3\structures_f\dominants\castle\castle_01_house_ruin_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d","mbg\mbg_killhouses_a3\m\mbg_warehouse.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_ruins_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d","rspn_assets\models\cb_entrance01.p3d","a3\structures_f\ind\airport\hangar_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_5.p3d","mbg\mbg_killhouses_a3\m\mbg_shoothouse_1.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_right_proxy_f.p3d","a3\structures_f\ind\airport\airport_right_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","a3\structures_f\mil\cargo\cargo_house_v2_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f_epc\dominants\stadium\stadium_p9_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no5_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no4_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no3_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_dam_f.p3d","a3\structures_f\civ\camping\tentdome_f.p3d","a3\structures_f\civ\camping\tenta_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d","a3\structures_f\ind\cargo\cargo20_blue_f.p3d","a3\structures_f\ind\cargo\cargo20_military_green_f.p3d","a3\structures_f\ind\cargo\cargo20_brick_red_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d","a3\structures_f\ind\cargo\cargo40_light_green_f.p3d","a3\structures_f\ind\cargo\cargo40_military_green_f.p3d"];
        ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\bagbunker\bagbunker_tower_f.p3d","a3\structures_f\mil\shelters\camonet_open_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\shelters\camonet_big_f.p3d","a3\structures_f\mil\shelters\camonet_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","a3\structures_f\research\research_hq_f.p3d","jbad_structures\mil\hanger\jbad_hanger_withdoor.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no2_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","a3\structures_f\dominants\castle\castle_01_tower_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d"];
        ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\shelters\camonet_open_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\shelters\camonet_big_f.p3d","a3\structures_f\mil\shelters\camonet_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","rspn_assets\models\cb_intersect02.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","a3\structures_f\dominants\castle\castle_01_tower_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d","rspn_assets\models\cb_entrance01.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d"];
        ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no2_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","mbg\mbg_killhouses_a3\m\mbg_warehouse.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\ind\airport\hangar_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no5_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no3_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_dam_f.p3d"];
        ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["a3\roads_f\runway\runway_right_secondary_end22_f.p3d","a3\roads_f\runway\runway_left_end22_f.p3d","a3\roads_f\runway\runway_left_secondary_end04_f.p3d","a3\roads_f\runway\runway_right_end04_f.p3d","a3\roads_f\runway\runway_end02_f.p3d","a3\roads_f\runway\runway_main_40_f.p3d"];
        ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + ["a3\structures_f\ind\airport\airport_tower_f.p3d","a3\structures_f\ind\airport\hangar_f.p3d"];
        ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + ["a3\structures_f\ind\airport\airport_left_f.p3d","a3\structures_f\ind\airport\airport_right_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d"];
        ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d","a3\structures_f\mil\helipads\jumptarget_f.p3d"];
        ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d"];
        ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + ["a3\structures_f\mil\helipads\helipadrescue_f.p3d"];
        ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["a3\structures_f_epc\civ\tourism\touristshelter_01_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d","a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\slum\cargo_house_slum_f.p3d","a3\structures_f\households\slum\slum_house02_f.p3d","a3\structures_f\ind\windmill\i_windmill01_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d","a3\structures_f\households\addons\i_garage_v2_f.p3d","a3\structures_f\households\addons\metal_shed_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_dam_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v3_dam_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d","a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d","a3\structures_f\ind\windmill\d_windmill01_f.p3d","a3\structures_f\civ\chapels\chapel_v1_f.p3d","a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d","a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d","a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d","a3\structures_f\households\house_small01\d_house_small_01_v1_f.p3d","a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d","a3\structures_f\households\addons\i_addon_02_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d","a3\structures_f\households\addons\i_garage_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d","a3\structures_f\households\wip\unfinished_building_02_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d","a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d","a3\structures_f\households\wip\unfinished_building_01_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_11.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d","a3\structures_f\dominants\amphitheater\amphitheater_f.p3d","a3\structures_f\civ\chapels\chapel_small_v1_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d","a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d","a3\structures_f\households\slum\cargo_addon02_v1_f.p3d","a3\structures_f\households\slum\cargo_addon02_v2_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d","a3\structures_f\households\stone_shed\stone_shed_v1_ruins_f.p3d","a3\structures_f\households\addons\addon_04_v1_ruins_f.p3d","a3\structures_f\households\addons\addon_01_v1_ruins_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d","a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d","a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d","god_various\hut\barn_w_02.p3d","a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d","a3\structures_f\households\house_small02\u_house_small_02_v1_dam_f.p3d","a3\structures_f\households\stone_shed\d_stone_shed_v1_f.p3d","a3\structures_f\households\slum\slum_house03_ruins_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d","a3\structures_f\civ\chapels\chapel_small_v2_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_1_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_2_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_2.p3d","jbad_structures\afghan_houses_c\jbad_house_c_12.p3d","jbad_structures\afghan_houses_c\jbad_house_c_3.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","jbad_structures\afghan_houses_c\jbad_house_c_10.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1.p3d","a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_dam_f.p3d","a3\structures_f\households\house_big02\u_house_big_02_v1_dam_f.p3d","a3\structures_f\households\house_big01\u_house_big_01_v1_dam_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","jbad_structures\afghan_houses\jbad_house5.p3d","jbad_structures\afghan_houses\jbad_house3.p3d","jbad_structures\afghan_houses\jbad_house6.p3d","jbad_structures\afghan_houses\jbad_terrace.p3d","jbad_structures\afghan_houses\jbad_house8.p3d","jbad_structures\afghan_houses\jbad_house_1.p3d","a3\structures_f\households\house_shop02\d_shop_02_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_dam_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_dam_f.p3d","a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d","jbad_structures\afghan_houses_old\jbad_house_6_old.p3d","jbad_structures\afghan_houses\jbad_house7.p3d","jbad_structures\afghan_houses_c\jbad_house_c_4.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5.p3d","jbad_structures\afghan_houses_c\jbad_house_c_9.p3d","jbad_structures\afghan_houses\jbad_house2_basehide.p3d","jbad_structures\afghan_houses_old\jbad_house_3_old.p3d","jbad_structures\afghan_houses_old\jbad_house_8_old.p3d","jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon01.p3d","jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon02.p3d","a3\structures_f\households\house_shop01\i_shop_01_v2_dam_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","jbad_structures\generalstore\jbad_a_generalstore_01.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\households\house_small01\i_house_small_01_v2_dam_f.p3d","a3\structures_f\civ\chapels\chapel_v2_f.p3d","a3\structures_f\dominants\church\church_01_v1_f.p3d","a3\structures_f\households\house_small01\u_house_small_01_v1_dam_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v1_dam_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d","jbad_structures\afghan_houses_old\jbad_house_1_old.p3d","jbad_structures\afghan_houses_old\jbad_house_4_old.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\generalstore\jbad_a_generalstore_01a.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\households\house_shop02\i_shop_02_v3_dam_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_dam_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v3_dam_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v2_dam_f.p3d","a3\structures_f\households\house_shop01\u_shop_01_v1_dam_f.p3d","jbad_structures\afghan_houses_old\jbad_house_7_old.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","jbad_structures\walls\wall_l\jbad_wall_l1_5m.p3d","a3\structures_f\walls\city2_8md_f"];
        ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d","a3\structures_f\ind\windmill\d_windmill01_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d","a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\generalstore\jbad_a_generalstore_01a.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_dam_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","god_various\hut\barn_w_01.p3d"];
        ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d","a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d","a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d","a3\structures_f\households\wip\unfinished_building_02_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d","a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_1_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_2_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_2.p3d","jbad_structures\afghan_houses_c\jbad_house_c_12.p3d","jbad_structures\afghan_houses_c\jbad_house_c_3.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1.p3d","a3\structures_f\dominants\wip\wip_f.p3d","jbad_structures\afghan_houses\jbad_house5.p3d","jbad_structures\afghan_houses\jbad_house3.p3d","jbad_structures\afghan_houses\jbad_house8.p3d","jbad_structures\afghan_houses\jbad_house7.p3d","jbad_structures\afghan_houses_c\jbad_house_c_4.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5.p3d","jbad_structures\afghan_houses_c\jbad_house_c_9.p3d","jbad_structures\afghan_houses\jbad_house2_basehide.p3d","jbad_structures\afghan_houses_old\jbad_house_8_old.p3d","jbad_structures\generalstore\jbad_a_generalstore_01.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\generalstore\jbad_a_generalstore_01a.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_dam_f.p3d","jbad_structures\afghan_houses_old\jbad_house_7_old.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","jbad_structures\afghan_houses_old\jbad_house_4_old.p3d","jbad_structures\afghan_houses\jbad_house6.p3d","a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d"];
        ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["a3\structures_f\ind\windpowerplant\wpp_turbine_v1_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d","a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d","a3\structures_f\ind\transmitter_tower\tbox_f.p3d","a3\structures_f\ind\windpowerplant\powergenerator_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d","a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d","a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d","a3\structures_f\ind\powerlines\powlines_transformer_f.p3d","jbad_structures\ind\ind_powerstation\jbad_ind_powerstation.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d","a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d","a3\structures_f\ind\powerlines\highvoltagecolumn_f.p3d","a3\structures_f\ind\powerlines\highvoltagetower_f.p3d"];
        ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + ["a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d","jbad_misc\misc_com\jbad_com_tower.p3d","jbad_structures\mil\jbad_mil_controltower.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_1_ruins_f.p3d","a3\structures_f\ind\transmitter_tower\communication_f.p3d","a3\structures_f\mil\radar\radar_f.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d"];
        ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["a3\structures_f\naval\piers\pier_wall_f.p3d","a3\structures_f\naval\piers\pier_doubleside_f.p3d","a3\structures_f\dominants\lighthouse\lighthouse_f.p3d"];
        ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + ["jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail_end.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail.p3d","jbad_structures\ind\ind_coltan_mine\jbad_misc_tram.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail_switch.p3d"];
        ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","a3\structures_f\ind\carservice\carservice_f.p3d","a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d","a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d","a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtank_rust_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d","jbad_structures\ind\ind_garage01\jbad_ind_garage01.p3d","a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d","a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtank_v1_f.p3d"];
        ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["a3\structures_f\ind\windmill\i_windmill01_f.p3d","a3\structures_f\ind\shed\shed_big_f.p3d","a3\structures_f\ind\shed\u_shed_ind_f.p3d","a3\structures_f\ind\crane\crane_f.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d","a3\structures_f\households\wip\unfinished_building_01_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_hopper_f.p3d","a3\structures_f\ind\factory\factory_tunnel_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_2.p3d","a3\structures_f\dominants\wip\wip_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_10.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_hopper.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_main.p3d","jbad_structures\ind\ind_shed\jbad_ind_shed_01.p3d","a3\structures_f\ind\factory\factory_conv1_main_f.p3d","a3\structures_f\ind\factory\factory_main_f.p3d","a3\structures_f\ind\factory\factory_conv2_f.p3d","a3\structures_f\ind\factory\factory_hopper_f.p3d","a3\structures_f\ind\factory\factory_conv1_10_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_mainfactory_addon1_f.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_end.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv2.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_tunnel.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d"];
    };

    if (count ALIVE_civilianPopulationBuildingTypes == 0) then { // if no buildings try loading from file
        ["MAP NOT INDEXED OR DEDI SERVER FILE LOAD... ALiVE LOADING MAP DATA: %1",_worldName] call ALIVE_fnc_dump;
        _file = format["x\alive\addons\main\static\%1_staticData.sqf", toLower(worldName)];
        call compile preprocessFileLineNumbers _file;
    };
};
// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: prei_khmaoch_luong (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-08", "web", true];

ALIVE_Indexing_Blacklist = [];
ALIVE_militaryBuildingTypes = [];
ALIVE_militaryParkingBuildingTypes = [];
ALIVE_militarySupplyBuildingTypes = [];
ALIVE_militaryHQBuildingTypes = [];
ALIVE_militaryFieldworkBuildingTypes = [];
ALIVE_airBuildingTypes = [];
ALIVE_militaryAirBuildingTypes = [];
ALIVE_civilianAirBuildingTypes = [];
ALiVE_HeliBuildingTypes = [];
ALIVE_militaryHeliBuildingTypes = [];
ALIVE_civilianHeliBuildingTypes = [];
ALIVE_civilianSettlementBuildingTypes = [];
ALIVE_civilianHQBuildingTypes = [];
ALIVE_civilianPopulationBuildingTypes = [];
ALIVE_civilianPowerBuildingTypes = [];
ALIVE_civilianCommsBuildingTypes = [];
ALIVE_civilianMarineBuildingTypes = [];
ALIVE_civilianRailBuildingTypes = [];
ALIVE_civilianFuelBuildingTypes = [];
ALIVE_civilianConstructionBuildingTypes = [];

ALiVE_mapCompositionType = "Pacific";

 if (tolower(_worldName) == "prei_khmaoch_luong") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_front_water_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_rear_water_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_03_f.p3d",
        "a3\structures_f\furniture\shelvesmetal_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_ruins_f.p3d",
        "a3\structures_f_exp\commercial\market\woodenshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\cultural\cemeteries\mausoleum_01_ruins_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_mossy_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_corner_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_long_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_round_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_short_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_3m_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_3m_round_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_round_f.p3d",
        "a3\structures_f_exp\military\trenches\trench_01_grass_f.p3d",
        "a3\structures_f_exp\military\trenches\trenchframe_01_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gap_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_8m_f.p3d",
        "a3\structures_f_exp\walls\bamboo\bamboofence_01_s_d_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_6m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_10m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_d_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_pole_f.p3d",
        "blud_cords\blud_bergveggen.p3d",
        "blud_cords\blud_elvis_01.p3d",
        "blud_cords\blud_minipytt_01.p3d",
        "blud_cords\blud_minipytt_02.p3d",
        "blud_cords\blud_minipytt_03.p3d",
        "blud_cords\blud_minipytt_04.p3d",
        "blud_cords\blud_pytt_01.p3d",
        "blud_cords\blud_pytt_01_splash_big.p3d",
        "blud_cords\blud_pytt_02.p3d",
        "blud_cords\blud_pytt_03.p3d",
        "blud_cords\blud_ris_01.p3d",
        "blud_cords\blud_rut_01.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_d_mossy_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",
        "blud_huts\blud_bridge1.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadempty_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadempty_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\chapels\chapel_small_v1_ruins_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_ruins_f.p3d",
        "a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_dam_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_ruins_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_ruins_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_ruins_f.p3d",
        "blud_huts\blud_bridge1.p3d",
        "blud_huts\blud_hut1.p3d",
        "blud_huts\blud_hut2.p3d",
        "blud_huts\blud_hut3.p3d",
        "blud_huts\blud_hut4.p3d",
        "blud_huts\blud_hut5.p3d",
        "blud_huts\blud_hut6.p3d",
        "blud_huts\blud_hut7.p3d",
        "blud_huts\blud_hut8.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "blud_huts\blud_hut2.p3d",
        "blud_huts\blud_hut3.p3d",
        "blud_huts\blud_hut4.p3d",
        "blud_huts\blud_hut6.p3d",
        "blud_huts\blud_hut7.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "blud_huts\blud_hut1.p3d",
        "blud_huts\blud_hut2.p3d",
        "blud_huts\blud_hut3.p3d",
        "blud_huts\blud_hut4.p3d",
        "blud_huts\blud_hut5.p3d",
        "blud_huts\blud_hut6.p3d",
        "blud_huts\blud_hut7.p3d",
        "blud_huts\blud_hut8.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_30deg_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_hut_f.p3d"
    ];

};

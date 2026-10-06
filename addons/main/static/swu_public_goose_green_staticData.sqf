// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: swu_public_goose_green (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-06", "web", true];

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

ALiVE_mapCompositionType = "Woodland";

 if (tolower(_worldName) == "swu_public_goose_green") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_small_ransacked_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_messy_pine_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_pine_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_gate_f.p3d",
        "ca\roads2\runwayold_40_main.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_white_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_b_raw_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_1.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dumruina_mini.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse_ruins.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\dum_mesto_in.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_white_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_b_raw_f.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\structures\barn_w\barn_w_02.p3d"
    ];

};

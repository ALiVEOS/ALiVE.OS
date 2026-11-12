// ALiVE 3 index v3.1, made 2026-11-12 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: vn_khe_sanh (ALiVE 3 index v3.1, 2026-11-12)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-12", "web", true];

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

ALiVE_mapCompositionType = "Jungle";

 if (tolower(_worldName) == "vn_khe_sanh") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "vn\objects_f_vietnam\pavn\r311\vn_o_prop_r311_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_cross_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_cross_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_end_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_revetment_90_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_tee_01.p3d",
        "vn\weapons_v_f_vietnam\bomb\vn_bomb_blu82_he_proxy.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_01_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_02_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_03_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_04_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_04.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_06.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_04_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_guardhouse_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_11.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_12.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_13.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_02_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_02_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_02_11.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_latrine_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_shower_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_foxhole_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_gunpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_mortarpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_tower_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_05.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_small_01.p3d",
        "vn\vn_structures_f\mil\barracks\vn_i_barracks_v1_f.p3d",
        "vn\vn_structures_f_enoch\industrial\sheds\vn_i_shed_ind_old_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_barracks_02_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_barracks_03_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_barracks_04_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_barracks_05_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_barracks_06_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_controltower_01_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_guardhouse_02_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_guardhouse_02_grey_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_guardhouse_03_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_guardtower_04_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_mobileradar_01_radar_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_radar_01_hq_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_radar_01_kitchen_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_01_big_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_01_hex_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_01_rectangle_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_02_hex_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_01.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_barracks_06_f.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_guardhouse_03_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_mobileradar_01_radar_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_radar_01_hq_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_05.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_04_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_01_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_mash_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_02.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_mobileradar_01_radar_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_radar_01_hq_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_barracks_04_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_02.p3d",
        "vn\vn_structures_f\mil\barracks\vn_i_barracks_v1_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_mobileradar_01_radar_f.p3d",
        "vn\vn_structures_f_enoch\military\radar\vn_radar_01_hq_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_01_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_02_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_03_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_04_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_04.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_06.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_foxhole_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_gunpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_mortarpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_tower_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_cross_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_cross_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_end_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_05.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_revetment_90_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_tee_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_big_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_bunker_small_01.p3d",
        "vn\vn_structures_f_enoch\military\barracks\vn_guardtower_04_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_01_big_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_01_hex_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_01_rectangle_f.p3d",
        "vn\vn_structures_f_exp_03\military\pillboxes\vn_pillboxbunker_02_hex_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_helipad_01.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_helipad_01.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_01.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_03.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_pagoda_01.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_pagoda_02.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_pagoda_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_01_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_02_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_03_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_04.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_04_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_05.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_06.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_07.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_08.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_01_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_02_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_04.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_05.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_01_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_02_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_03_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_01_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_01_tall.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_village_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_village_02.p3d",
        "vn\structures_f_vietnam\civ\temple\vn_temple_base_01.p3d",
        "vn\structures_f_vietnam\civ\temple\vn_temple_ruin_03_02.p3d",
        "vn\structures_f_vietnam\civ\temple\vn_temple_shrine_01.p3d",
        "vn\vn_buildings\vn_hut_old02.p3d",
        "vn\vn_structures_e\housec\vn_house_c_11_ep1.p3d",
        "vn\vn_structures_e\housec\vn_house_c_12_ep1.p3d",
        "vn\vn_structures_e\housec\vn_house_c_1_v2_ep1.p3d",
        "vn\vn_structures_e\housec\vn_house_c_3_ep1.p3d",
        "vn\vn_structures_e\housec\vn_house_c_9_ep1.p3d",
        "vn\vn_structures_f\households\slum\vn_cargo_house_slum_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house01_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house02_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house03_f.p3d",
        "vn\vn_structures_f_enoch\industrial\houses\vn_workshop_02_f.p3d",
        "vn\vn_structures_f_enoch\industrial\houses\vn_workshop_03_grey_f.p3d",
        "vn\vn_structures_f_enoch\industrial\houses\vn_workshop_05_grey_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_big_01\vn_house_big_01_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_small_01\vn_house_small_01_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_small_02\vn_house_small_02_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_small_04\vn_house_small_04_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_02_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_03_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_05_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_07_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_01\vn_slum_01_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_02\vn_slum_02_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_03\vn_slum_03_01_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_03\vn_slum_03_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_04\vn_slum_04_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_01.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_03.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_pagoda_01.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_pagoda_02.p3d",
        "vn\structures_f_vietnam\civ\hue_gate\vn_hue_gate_pagoda_03.p3d",
        "vn\vn_structures_e\housec\vn_house_c_9_ep1.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_03\vn_slum_03_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "vn\structures_f_vietnam\civ\hut\vn_hut_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_04.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_05.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_06.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_07.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_08.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_04.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_mont_05.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_village_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_village_02.p3d",
        "vn\structures_f_vietnam\civ\temple\vn_temple_shrine_01.p3d",
        "vn\vn_structures_e\housec\vn_house_c_11_ep1.p3d",
        "vn\vn_structures_e\housec\vn_house_c_1_v2_ep1.p3d",
        "vn\vn_structures_e\housec\vn_house_c_3_ep1.p3d",
        "vn\vn_structures_e\housec\vn_house_c_9_ep1.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house01_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house02_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house03_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_big_01\vn_house_big_01_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_small_01\vn_house_small_01_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_small_02\vn_house_small_02_f.p3d",
        "vn\vn_structures_f_exp_02\civilian\house_small_04\vn_house_small_04_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_05_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_01\vn_slum_01_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_02\vn_slum_02_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_03\vn_slum_03_01_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_03\vn_slum_03_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "vn\vn_structures_f\ind\transmitter_tower\vn_ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_01_10m_norails_f.p3d",
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_01_16m_f.p3d",
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_01_dock_f.p3d",
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_01_hut_f.p3d",
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_01_platform_f.p3d",
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_02_16m_f.p3d",
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_02_30deg_f.p3d",
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_02_hut_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "vn\vn_structures_f\ind\fuelstation\vn_fuelstation_build_02_f.p3d",
        "vn\vn_structures_f\ind\fuelstation\vn_fuelstation_build_f.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-11-12 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: vn_the_bra (ALiVE 3 index v3.1, 2026-11-12)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "vn_the_bra") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "vn\env_assets_f_vietnam\tunnels\proxy\vn_tunnel_01_support_02.p3d",
        "vn\env_assets_f_vietnam\tunnels\proxy\vn_tunnel_arrow_01.p3d",
        "vn\env_assets_f_vietnam\tunnels\proxy\vn_tunnel_arrow_02.p3d",
        "vn\env_assets_f_vietnam\tunnels\proxy\vn_tunnel_arrow_03.p3d",
        "vn\env_assets_f_vietnam\tunnels\proxy\vn_tunnel_arrow_04.p3d",
        "vn\env_assets_f_vietnam\tunnels\proxy\vn_tunnel_roots_02.p3d",
        "vn\objects_f_vietnam\supply\a2_ammo\pavn\vn_pavn_30_can.p3d",
        "vn\objects_f_vietnam\supply\a2_ammo\pavn\vn_pavn_50_can.p3d",
        "vn\objects_f_vietnam\supply\a2_ammo\pavn\vn_pavn_can.p3d",
        "vn\objects_f_vietnam\supply\a2_ammo\pavn\vn_pavn_pouch.p3d",
        "vn\objects_f_vietnam\usarmy\furniture\vn_us_fort_common_metal_pole_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_02.p3d",
        "vn\vn_structures_f_enoch\furniture\school_equipment\vn_anatomy_poster_2.p3d",
        "vn\weapons_f_vietnam\items\firstaidkit\vn_b_firstaidkit.p3d",
        "vn\weapons_f_vietnam\items\toolkit\vn_toolkit.p3d",
        "vn\weapons_f_vietnam\items\trapkit\vn_trapkit.p3d",
        "vn\weapons_f_vietnam\k50\vn_k50m.p3d",
        "vn\weapons_f_vietnam\m1895\vn_m1895.p3d",
        "vn\weapons_f_vietnam\mat49\vn_mat49.p3d",
        "vn\weapons_f_vietnam\melee\machete\vn_m_machete_01.p3d",
        "vn\weapons_f_vietnam\melee\vc_knife\vn_m_vc_knife_01.p3d",
        "vn\weapons_f_vietnam\ppsh41\vn_ppsh41.p3d",
        "vn\weapons_f_vietnam\ppsh41\vn_ppsh41_35_mag.p3d",
        "vn\weapons_f_vietnam\ppsh41\vn_ppsh41_71_mag.p3d",
        "vn\weapons_f_vietnam\rpd\vn_rpd_prop.p3d",
        "vn\weapons_f_vietnam\rpg7\vn_rpg7_mag.p3d",
        "vn\weapons_f_vietnam\throw\mag\vn_chicom.p3d",
        "vn\weapons_f_vietnam\throw\mag\vn_molotov.p3d",
        "vn\weapons_f_vietnam\throw\mag\vn_rgd33.p3d",
        "vn\weapons_f_vietnam\tt33\vn_tt33.p3d",
        "vn\weapons_f_vietnam\type56\vn_type56.p3d",
        "vn\weapons_f_vietnam\type56\vn_type56_mag.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_01_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_02_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_03_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_04_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_06.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_guardhouse_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_11.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_12.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_02_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_02_11.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_latrine_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_shower_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_gunpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_mortarpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_tower_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_05.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_05.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_04.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "vn\structures_f_vietnam_02\usarmy\building\vn_hootch_01_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\building\vn_tent_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_01_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_02_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_03_05.p3d",
        "vn\env_assets_f_vietnam\tunnels\vn_tunnel_01_building_04_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_bunker_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_platform_06.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_01.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_shelter_05.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_02.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_tower_03.p3d",
        "vn\structures_f_vietnam\pavn\fort\vn_o_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_gunpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_mortarpit_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_tower_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_05_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_20_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_45_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_90_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_01_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_02_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_03_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_04_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_05_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_bunker_06_02.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_01.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_03.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_04.p3d",
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_trench_firing_05.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_helipad_01.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "vn\structures_f_vietnam_02\usarmy\fort\vn_b_helipad_01.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
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
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_02_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_river_03_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_01_ruin.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_02.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_tower_03.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_village_01.p3d",
        "vn\structures_f_vietnam\civ\hut\vn_hut_village_02.p3d",
        "vn\structures_f_vietnam\civ\temple\vn_temple_shrine_01.p3d",
        "vn\vn_structures_f\households\slum\vn_cargo_house_slum_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house01_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house02_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house03_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_02_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_03_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_05_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_07_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_01\vn_slum_01_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_02\vn_slum_02_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_04\vn_slum_04_f.p3d"
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
        "vn\vn_structures_f\households\slum\vn_slum_house01_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house02_f.p3d",
        "vn\vn_structures_f\households\slum\vn_slum_house03_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\sheds\vn_shed_05_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_01\vn_slum_01_f.p3d",
        "vn\vn_structures_f_exp_05\civilian\slum_02\vn_slum_02_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "vn\vn_structures_f\ind\transmitter_tower\vn_ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "vn\vn_structures_f_exp\naval\piers\vn_pierwooden_01_10m_norails_f.p3d"
    ];

};

// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: swu_public_novogorsk_map (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Urban";

 if (tolower(_worldName) == "swu_public_novogorsk_map") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\animals_f\cl_feathers2.p3d",
        "a3\animals_f\cl_leaf.p3d",
        "a3\animals_f\cl_leaf2.p3d",
        "a3\data_f\cl_paper1.p3d",
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_enoch\civilian\forest\woodenlog_02_f.p3d",
        "a3\props_f_enoch\industrial\supplies\woodenbox_02_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\combineharvester_01_wreck_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_4m_f.p3d",
        "a3\structures_f_argo\military\fortifications\czechhedgehog_01_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_half_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_hole_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_08_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_09_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_10_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_01_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_02_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_03_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_04_f.p3d",
        "a3\structures_f_enoch\cultural\statues\statue_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirtpatch_05_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\manurepile_01_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_conveyor_f.p3d",
        "a3\structures_f_enoch\industrial\farms\watertower_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_conveyor_begin_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_conveyor_end_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_heap_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_hopper_silo_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\shed_ind_old_ruins_f.p3d",
        "a3\structures_f_enoch\military\training\craterlong_02_f.p3d",
        "a3\structures_f_enoch\military\training\craterlong_02_small_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_01_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_debris_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_decal_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_extralarge_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_large_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_small_f.p3d",
        "a3\structures_f_enoch\military\training\shootingpos_roof_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_02_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_door_01_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_d_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_9m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_pole_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_04_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_04_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_05_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_05_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_end_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound04_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\stonewall_02_s_10m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_d_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_d_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_d_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_pole_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_d_4m_f.p3d",
        "a3\structures_f_enoch\wrecks\mi8_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\commercial\market\woodenshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_long_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_round_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_short_green_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_4m_f.p3d",
        "a3\structures_f_heli\items\sport\football_01_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\airfield\controltower_02_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\controltower_01_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_ruins_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w05_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w05_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w06_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w06_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_01\chapel_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_lightblue_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_small_white_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_loadinghouse_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dpp_01_mainfactory_old_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_warehouse_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_factory_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "ca\structures\house\housev\housev_3i3.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "cup\terrains\cup_terrains_buildings\tenement\tenement_01.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w05_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w06_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_lightblue_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_small_white_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "cup\terrains\cup_terrains_buildings\tenement\tenement_01.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\substation_01_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dpp_01_mainfactory_old_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_01_factory_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d"
    ];

};

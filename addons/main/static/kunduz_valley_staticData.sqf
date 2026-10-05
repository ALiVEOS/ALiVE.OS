// ALiVE 3 index v3.1, made 2026-10-05 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: kunduz_valley (ALiVE 3 index v3.1, 2026-10-05)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-05", "web", true];

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

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "kunduz_valley") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\industrial\supplies\woodenbox_02_f.p3d",
        "a3\props_f_enoch\infrastructure\traffic\roadbarrier_01_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_wreck_f.p3d",
        "a3\props_f_exp\naval\boats\boat_05_wreck_f.p3d",
        "a3\props_f_orange\furniture\rug_01_f.p3d",
        "a3\soft_f_orange\van_02\van_02_rimless_tire_f.p3d",
        "a3\structures_f\bridges\bridge_01_f.p3d",
        "a3\structures_f\bridges\bridge_asphalt_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_04_blank_f.p3d",
        "a3\structures_f_argo\decals\horizontal\dirtpatch_01_4x4_f.p3d",
        "a3\structures_f_argo\decals\horizontal\dirtpatch_01_6x8_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_4x4_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_6x2_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_ruins_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_brown_ruins_f.p3d",
        "a3\structures_f_argo\infrastructure\watersupply\reservoirtank_01_military_f.p3d",
        "a3\structures_f_argo\military\domes\domedebris_01_hex_damaged_green_f.p3d",
        "a3\structures_f_argo\military\domes\domedebris_01_struts_large_green_f.p3d",
        "a3\structures_f_argo\military\domes\domedebris_01_struts_small_green_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_10m_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_4m_f.p3d",
        "a3\structures_f_argo\military\fortifications\czechhedgehog_01_old_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_half_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_hole_f.p3d",
        "a3\structures_f_argo\walls\military\mil_wallbig_4m_damaged_center_f.p3d",
        "a3\structures_f_argo\walls\military\mil_wallbig_4m_damaged_left_f.p3d",
        "a3\structures_f_argo\walls\military\mil_wallbig_4m_damaged_right_f.p3d",
        "a3\structures_f_argo\walls\military\mil_wallbig_debris_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_medium1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirtpatch_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_06_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_07_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_09_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_11_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_12_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_right_v1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_end_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_start_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_v1_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\feedstorage_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\manurepile_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\strawstack_01_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_ground1_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_ground2_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_support_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_bigl_l_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_bigl_r_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\shed_ind_old_ruins_f.p3d",
        "a3\structures_f_enoch\military\domes\domeparts_01_struts_stack_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_airshaft_f.p3d",
        "a3\structures_f_enoch\military\training\craterlong_02_f.p3d",
        "a3\structures_f_enoch\military\training\disturbedsoil_02_decal_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_debris_f.p3d",
        "a3\structures_f_enoch\military\training\shootingpos_roof_01_f.p3d",
        "a3\structures_f_enoch\military\training\target_line_01_f.p3d",
        "a3\structures_f_enoch\military\training\target_line_papertargets_01_f.p3d",
        "a3\structures_f_enoch\military\training\target_pistol_01_f.p3d",
        "a3\structures_f_enoch\military\training\target_single_01_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_d_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_9m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_pole_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_03_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_03_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_04_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_04_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_05_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_05_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_06_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_06_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_end_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound04_8m_f.p3d",
        "a3\structures_f_enoch\wrecks\mi8_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\powergenerator_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_ruins_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_wide_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\infrastructure\watersupply\watertower_01_ruins_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_1m_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gap_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_d_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_heli\furniture\rattantable_01_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_brick_red_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_military_green_f.p3d",
        "a3\structures_f_heli\items\airport\portablehelipadlight_01_f.p3d",
        "a3\structures_f_kart\civ\sportsgrounds\oil_spill.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_01_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_02_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_03_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_04_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_05_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_08_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_10_f.p3d",
        "a3\structures_f_oldman\decals\decal_scorchmark_01_large_f.p3d",
        "a3\structures_f_oldman\decals\decal_scorchmark_01_small_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_long_d_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_long_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_pole_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_short_d_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_short_f.p3d",
        "a3\structures_f_tank\decals\horizontal\dirtpatch_02_f.p3d",
        "a3\structures_f_tank\decals\horizontal\dirtpatch_03_f.p3d",
        "a3\structures_f_tank\decals\horizontal\dirtpatch_04_f.p3d",
        "a3\structures_f_tank\military\fortifications\dragonsteeth_01_1x1_old_f.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1g.p3d",
        "ca\buildings\furniture\dkamna_bila.p3d",
        "ca\buildings\furniture\hromada_beden_dekorativnix.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\misc\zed_desert.p3d",
        "ca\buildings\misc\zed_dira_civil.p3d",
        "ca\buildings\misc\zed_dira_desert.p3d",
        "ca\buildings\misc\zed_podplaz_civil.p3d",
        "ca\buildings\misc\zed_podplaz_desert.p3d",
        "ca\buildings\podesta_10.p3d",
        "ca\buildings\podesta_5.p3d",
        "ca\buildings\ruins\watertower1_ruins.p3d",
        "ca\data\particleeffects\craterlong\craterlong.p3d",
        "ca\misc2\hbarrier1.p3d",
        "ca\misc2\hbarrier3.p3d",
        "ca\misc2\hbarrier5.p3d",
        "ca\structures\misc\armory\pneu\pneu.p3d",
        "ca\structures\nav_pier\nav_pier_pneu.p3d",
        "ca\structures_e\housek\house_k_1_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ruins_ep1.p3d",
        "ca\structures_e\misc\misc_cables\misc_cable_ep1.p3d",
        "ca\structures_e\misc\misc_interier\table_small_ep1.p3d",
        "ca\structures_e\misc\misc_interier\teapot_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\wheeled\skodovka_wrecked.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_radar_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_cooler_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "ca\buildings\bouda_plech_open.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\misc_e\camonet_east_ep1.p3d",
        "ca\misc_e\camonet_east_var1_ep1.p3d",
        "ca\misc_e\fort_artillery_nest_ep1.p3d",
        "ca\misc_e\fort_watchtower_ep1.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_dam_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_dam_ep1.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "ca\misc_e\fort_artillery_nest_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_dam_ep1.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_dam_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_grey_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\highway\highway_pillar_01_garage_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "ca\buildings\misc\stanek_1.p3d",
        "ca\buildings\misc\stanek_1b.p3d",
        "ca\buildings\misc\stanek_1c.p3d",
        "ca\structures_e\housea\a_citygate1\a_citygate1_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_corner_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_gate_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_dam_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_dam_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_2_basehide_ep1.p3d",
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_h_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_2_basehide_ep1.p3d",
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_h_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_generator_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_30deg_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_smallfactory_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "ca\buildings\misc\leseni2x.p3d"
    ];

};

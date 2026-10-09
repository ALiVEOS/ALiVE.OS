// ALiVE 3 index v3.1, made 2026-10-09 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: juju_sahatra (ALiVE 3 index v3.1, 2026-10-09)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-09", "web", true];

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

 if (tolower(_worldName) == "juju_sahatra") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\roads_f\runway\runway_end22_f.p3d",
        "a3\roads_f\runway\runway_main_f.p3d",
        "a3\roads_f\runway\runway_secondary_40_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_3_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall6_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall_corner_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall_corridor_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_ion_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_03_pills_f.p3d",
        "a3\structures_f_argo\decals\horizontal\dirtpatch_01_6x8_f.p3d",
        "a3\structures_f_argo\decals\horizontal\pedestriancrossing_01_6m_6str_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_2x2_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_4x4_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_6x2_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\vineyardfence_01_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_10m_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_half_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_grey_f.p3d",
        "a3\structures_f_argo\walls\net\netfence_02_m_gate_v2_closed_f.p3d",
        "a3\structures_f_argo\walls\tin\tinwall_01_m_gate_v2_closed_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\hutch_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirtpatch_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_left_v1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_right_v1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_end_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_start_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_v1_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\drainage_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\benchmarks\surveymarker_01_post_f.p3d",
        "a3\structures_f_enoch\infrastructure\lamps\lampindustrial_01_f.p3d",
        "a3\structures_f_enoch\military\training\craterlong_02_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_debris_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_05_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_04_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_d_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_d_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_9m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_pole_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_06_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\stone\stonewall_02_s_10m_f.p3d",
        "a3\structures_f_enoch\wrecks\mi8_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_curve_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_end_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_pillar_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_f.p3d",
        "a3\structures_f_exp\naval\piers\breakwater_01_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_4m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_8m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_l_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_r_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_8m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\stone\stonewall_01_s_d_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_16m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_8m_f.p3d",
        "a3\structures_f_oldman\decals\brokencarglass_01_4x4_f.p3d",
        "a3\structures_f_oldman\decals\brokencarglass_01_6x2_f.p3d",
        "a3\structures_f_oldman\decals\decal_bulletholes_big_01_f.p3d",
        "a3\structures_f_oldman\decals\decal_bulletholes_big_02_f.p3d",
        "a3\structures_f_oldman\decals\decal_bulletholes_small_01_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadcrack_grass_03_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_02_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_04_f.p3d",
        "a3\structures_f_oldman\decals\decal_roadedge_dirt_05_f.p3d",
        "a3\structures_f_oldman\decals\decal_scorchmark_01_large_f.p3d",
        "a3\structures_f_oldman\decals\decal_scorchmark_01_small_f.p3d",
        "ca\misc_e\misc_cargo4b_ep1.p3d",
        "ca\misc_e\misc_cargo4d_ep1.p3d",
        "ca\misc_e\misc_cargo4e_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ruins_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ruins_ep1.p3d",
        "ca\structures_e\housea\a_statue\a_statue_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ruins_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_r_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_2_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_3_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_4_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_a_ep1.p3d",
        "ca\structures_e\misc\misc_cables\misc_cable_ep1.p3d",
        "juju\juju_sahartra_struc\opx_misc\def\juju_opx2_jersey2.p3d",
        "juju\juju_sahartra_struc\opx_misc\gate\juju_opx2_double_arch_gate.p3d",
        "juju\juju_sahartra_struc\opx_misc\market\juju_opx2_marketstand1.p3d",
        "juju\juju_sahartra_struc\opx_misc\market\juju_opx2_marketstand1_b.p3d",
        "juju\juju_sahartra_struc\opx_misc\market\juju_opx2_marketstand2.p3d",
        "juju\juju_sahartra_struc\opx_misc\market\juju_opx2_marketstand2_b.p3d",
        "juju\juju_sahartra_struc\opx_misc\mural\juju_opx2_mural11.p3d",
        "juju\juju_sahartra_struc\opx_misc\mural\juju_opx2_mural12.p3d",
        "juju\juju_sahartra_struc\opx_misc\mural\juju_opx2_mural13.p3d",
        "juju\juju_sahartra_struc\opx_misc\mural\juju_opx2_mural4.p3d",
        "juju\juju_sahartra_struc\opx_misc\stuff\juju_opx2_barrel_blue.p3d",
        "juju\juju_sahartra_struc\opx_misc\stuff\juju_opx2_barrel_red.p3d",
        "juju\juju_sahartra_struc\opx_misc\stuff\juju_opx2_boxes.p3d",
        "juju\juju_sahartra_struc\opx_misc\stuff\juju_opx2_cart3.p3d",
        "juju\juju_sahartra_struc\opx_misc\stuff\juju_opx2_trashcan.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_fence2.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_fence2_pillar.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall1.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall11_1.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall11_end.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall12.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall12_pillar.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall3.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall3pillar.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall4.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall4_pillar.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall5.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall5pillar.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall6.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall6_pillar.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall7.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall7_broken.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall7_pillar.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall8.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall9.p3d",
        "juju\juju_sahartra_struc\opx_misc\wall\juju_opx2_wall9_pillar.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_arch.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_construct4_ruins.p3d",
        "juju\juju_sahartra_struc\sah_banner.p3d",
        "juju\juju_sahartra_struc\sah_cables.p3d",
        "juju\juju_sahartra_struc\sah_fountain.p3d",
        "juju\juju_sahartra_struc\sah_graffiti_01.p3d",
        "juju\juju_sahartra_struc\sah_graffiti_02.p3d",
        "juju\juju_sahartra_struc\sah_graffiti_03.p3d",
        "juju\juju_sahartra_struc\sah_graffiti_04.p3d",
        "juju\juju_sahartra_struc\sah_graffiti_05.p3d",
        "juju\juju_sahartra_struc\sah_swords.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\roads_f\runway\runway_end04_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\camps\connectortent_01_floor_dark_f.p3d",
        "a3\structures_f_enoch\military\camps\connectortent_01_floor_light_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\misc_e\camonet_east_var1_ep1.p3d",
        "ca\misc_e\fort_watchtower_ep1.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "ca\misc_e\tent_east_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\structures_e\mil\mil_repair_center_ep1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_vcp1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_bigtank_old_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_grey_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\i_shed_ind_old_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_04_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\structures_e\housea\a_citygate1\a_citygate1_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_corner_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_gate_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_h_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "juju\juju_sahartra_struc\juju_x_barley_5m.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_big.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_big_b.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_big_c.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_big_d.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_big_e.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_big_f.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex4_ruins.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex5.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex5_ruins.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex6.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex7.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex8.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex9.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_cornershop1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_garage1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_garages.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_garages_ruins.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut1_ruins.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut_invert1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_policestation.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_store1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_stores.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_stores2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_tower1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_guardtower.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h06.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h11.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h11_b.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h15.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h16.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h18.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h19.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h20.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h21.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_pharmacy.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop3b.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_stores3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_vcp_tower1.p3d",
        "juju\juju_sahartra_struc\sah_cables_02.p3d",
        "juju\juju_sahartra_struc\sah_puddle_01.p3d",
        "juju\juju_sahartra_struc\sah_puddle_02.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_big_e.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex8.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex9.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_policestation.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_04_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_h_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "juju\juju_sahartra_struc\juju_x_barley_5m.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex5.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex6.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex7.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex8.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex9.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_policestation.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_store1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_stores2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h11.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h18.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h19.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h20.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop3b.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_stores3.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "ca\structures_e\misc\misc_powerline\powlines_transformer1_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",
        "ca\structures_e\misc\com_tower_ep1.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_bigtank_old_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_shed_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_construct2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_construct3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_construct4.p3d"
    ];

};

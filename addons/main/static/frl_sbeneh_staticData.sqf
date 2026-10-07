// ALiVE 3 index v3.1, made 2026-10-07 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: frl_sbeneh (ALiVE 3 index v3.1, 2026-10-07)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-07", "web", true];

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

 if (tolower(_worldName) == "frl_sbeneh") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_abandoned_f.p3d",
        "a3\props_f_exp\military\camps\portablegenerator_01_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_3_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall4_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall6_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall_corridor_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_10m_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_4m_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_blue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_grey_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_02_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_8m_high_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_1m_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gap_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_4m_nolc_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_8m_nolc_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_16m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_4m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_khaki_f.p3d",
        "a3\structures_f_heli\furniture\rattantable_01_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_light_green_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_sand_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_02.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1f.p3d",
        "ca\buildings\kasna.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\podesta_1_cube_long.p3d",
        "ca\buildings\podesta_5.p3d",
        "ca\data\library\humps_dirt.p3d",
        "ca\data\particleeffects\craterlong\craterlong.p3d",
        "ca\structures\rail\rail_misc\rail_najazdovarampa.p3d",
        "ca\structures\rail\rail_wagon\wagon_flat.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ruins_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ruins_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ruins_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_i_ruins_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_2_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_3_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_4_ep1.p3d",
        "ca\structures_e\misc\misc_interier\teapot_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\wheeled\skodovka_wrecked.p3d",
        "ca\wheeled\uaz_wreck.p3d",
        "frl\frl_terrainobjects\frl_walls_cinder\frl_cinder_6m.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "ca\buildings\army_hut2.p3d",
        "ca\buildings\army_hut3_long_int.p3d",
        "ca\buildings\army_hut_storrage.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\misc3\fortified_nest_small.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "ca\buildings\hangar_2.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "ca\buildings\hangar_2.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc3\fortified_nest_small.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\belltowers\belltower_02_v2_ruins_f.p3d",
        "a3\structures_f\households\addons\i_garage_v1_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_shed_ruins_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\house_big_01_b_blue_ruins_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\house_big_01_b_yellow_ruins_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\house_big_02_b_blue_ruins_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\house_small_02_b_brown_ruins_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a2_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a3_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c1_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c5_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d1_ruins.p3d",
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin_ruins.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\bouda_plech.p3d",
        "ca\buildings\dum01.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan2_01.p3d",
        "ca\buildings\dum_istan2_02.p3d",
        "ca\buildings\dum_istan2_03.p3d",
        "ca\buildings\dum_istan2_03a.p3d",
        "ca\buildings\dum_istan2_04a.p3d",
        "ca\buildings\dum_istan3.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_istan4.p3d",
        "ca\buildings\dum_istan4_big.p3d",
        "ca\buildings\dum_mesto3_istan.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\garaz_long_open.p3d",
        "ca\buildings\garaz_mala.p3d",
        "ca\buildings\hospital.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\komin.p3d",
        "ca\buildings\podesta_1_stairs4.p3d",
        "ca\buildings\ruins\dum_zboreny_ruins.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital_dam.p3d",
        "ca\structures\house\a_hospital\a_hospital_ruins.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\structures_e\housea\a_citygate1\a_citygate1_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ruins_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_10_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ruins_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1_big.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1_big_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2_big.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2_big_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3_big.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3_big_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3_inverse.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_dam_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\podesta_1_stairs4.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_10_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1_big.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1_big_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_1_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2_big.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2_big_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_2_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3_big.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3_big_inverse.p3d",
        "frl\frl_terrainobjects\frl_buildings_cinder\istan_4_3_inverse.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d",
        "ca\structures_e\ind\ind_powerstation\ind_powerstation_ruins_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\industrial\port\containerline_02_f.p3d",
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\buildings\podesta_1_stairs.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_pmc\ind\fuelstation\fuelstation_build_pmc.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d"
    ];

};

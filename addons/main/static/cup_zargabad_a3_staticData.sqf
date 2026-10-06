// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: cup_zargabad_a3 (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "cup_zargabad_a3") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsack_01_full_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_large_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_small_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_open_boxes_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_small_closed_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_small_open_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\waterbottle_01_stack_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\chickencoop_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\hutch_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_left_v1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_left_v2_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_right_v2_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_end_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_start_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_v1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_v2_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_04_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_prices_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_1m_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_4m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_8m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_l_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_r_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_gate_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_2m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_d_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_2m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_heli\civ\market\pallettrolley_01_khaki_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d",
        "ca\roads2\dam\dam_conc\dam_concp_20.p3d",
        "ca\roads_e\runway\runway_poj_l_1_end_ep1.p3d",
        "ca\roads_e\sidewalks\sw_c_crosst_ep1.p3d",
        "ca\structures_e\housea\a_statue\a_statue_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ruins_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_r_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_pipes\indpipe2_bigbuild2_r_ep1.p3d",
        "ca\structures_e\ind\ind_pipes\indpipe2_smallbuild2_l_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_2_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_3_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_4_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_a_ep1.p3d",
        "ca\structures_e\misc\misc_cables\misc_cable_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_a_left_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_a_right_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_ab_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlineb_ep1.p3d",
        "ca\structures_e\misc\misc_water\zr_dam_01_ep1.p3d",
        "ca\structures_e\misc\misc_water\zr_dam_02_ep1.p3d",
        "ca\structures_e\misc\misc_water\zr_dam_05_ep1.p3d",
        "ca\structures_e\misc\misc_water\zr_dam_06_ep1.p3d",
        "ca\structures_e\misc\misc_water\zr_dam_07_ep1.p3d",
        "ca\structures_e\misc\misc_water\zr_dam_08_ep1.p3d",
        "ca\structures_e\misc\misc_water\zr_dam_09_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\wheeled\skodovka_wrecked.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_a.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_b.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_c.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_end_10m.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_end_10m_corner.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_end_15m.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_end_5m.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerline_end_5m_corner.p3d",
        "cup\terrains\cup_terrains_opx_structures\infrastructure\cup_opx_powerpole_small.p3d",
        "cup\terrains\cup_terrains_opx_structures\military\cup_opx_vcp_wall_octogon.p3d",
        "cup\terrains\cup_terrains_opx_structures\military\cup_opx_vcp_wall_square.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_01_5m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_01_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_01_pillar.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_02_4m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_02_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_02_pillar.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_4m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_8m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_pillar.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_04_5m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_04_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_04_pillar.p3d",
        "cup\terrains\cup_terrains_structures_e\housek\terrace_k_stairs_1_ep1.p3d",
        "cup\terrains\cup_terrains_structures_e\housek\terrace_k_stairs_ep1.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\misc2\barrack2\barrack2.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\structures_e\mil\mil_repair_center_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\military\cup_opx_vcp_tower.p3d"
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
        "cup\terrains\cup_terrains_opx_structures\military\cup_opx_vcp_tower.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\roads_e\runway\runway_end00_ep1.p3d",
        "ca\roads_e\runway\runway_end18_ep1.p3d",
        "ca\roads_e\runway\runway_main_40_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\roads_e\runway\runway_poj_l_1_ep1.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\roads_e\runway\runway_end00_ep1.p3d",
        "ca\roads_e\runway\runway_end18_ep1.p3d",
        "ca\roads_e\runway\runway_main_40_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\roads_e\runway\runway_poj_l_1_ep1.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\infrastructure\clinic\cup_opx_helipad.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "cup\terrains\cup_terrains_opx_structures_complex\infrastructure\clinic\cup_opx_helipad.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures_e\housea\a_citygate1\a_citygate1_ep1.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_corner_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_gate_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ruins_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ruins_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
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
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_h_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ruins_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_01.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_02.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_03.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_04.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_05.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_06.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h1.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h10.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h2.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h3.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h4.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h5.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h6.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h7.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h8.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h9.p3d",
        "cup\terrains\cup_terrains_opx_structures\industrial\cup_opx_garage_01.p3d",
        "cup\terrains\cup_terrains_opx_structures\industrial\cup_opx_garage_02.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_01.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_02.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_03.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_04.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_05.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_06.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\infrastructure\clinic\cup_opx_clinic.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_10.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_11.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_12.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_13.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_14.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_02.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_04.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_01.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_02.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_03.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_04.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_06.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\infrastructure\clinic\cup_opx_clinic.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ruins_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
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
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_h_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_01.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_02.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_03.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_04.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_05.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_06.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h1.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h10.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h2.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h3.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h4.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h5.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h6.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h7.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h8.p3d",
        "cup\terrains\cup_terrains_opx_structures\house\cup_opx_h9.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_01.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_02.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_03.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_04.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_05.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_06.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\infrastructure\clinic\cup_opx_clinic.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_10.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_11.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_12.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_13.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_14.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlinea_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlines_transformer1_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\structures_e\misc\com_tower_ep1.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\industrial\port\mobilecrane_01_hook_f.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d",
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_shed_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d",
        "ca\structures_e\ind\ind_pipes\indpipe1_ur_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d",
        "ca\structures_e\ind\ind_pipes\indpipe1_ur_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\construction\cup_opx_construction01.p3d",
        "cup\terrains\cup_terrains_opx_structures\construction\cup_opx_construction02.p3d",
        "cup\terrains\cup_terrains_opx_structures\construction\cup_opx_construction03.p3d",
        "cup\terrains\cup_terrains_opx_structures\construction\cup_opx_construction04.p3d"
    ];

};

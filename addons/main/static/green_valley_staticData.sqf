// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: green_valley (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "green_valley") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerskeleton_damaged_01_f.p3d",
        "a3\props_f_enoch\industrial\supplies\woodenbox_02_f.p3d",
        "a3\props_f_enoch\infrastructure\traffic\roadbarrier_01_f.p3d",
        "a3\props_f_enoch\items\documents\book_01_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_tank_f.p3d",
        "a3\props_f_orange\civilian\constructions\cinderblock_01_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsack_01_destroyed_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsack_01_empty_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_cargonet_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_large_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_small_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\orange_01_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_small_closed_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\pumpkin_01_f.p3d",
        "a3\roads_f\runway\runway_end22_f.p3d",
        "a3\structures_f\data\doorlocks\planks_1.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f_argo\decals\horizontal\puddle_01_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\vineyardfence_01_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_messy_pine_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_pine_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_4m_f.p3d",
        "a3\structures_f_argo\military\fortifications\czechhedgehog_01_old_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_whiteblue_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_grey_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\chickencoop_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\hutch_01_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_05_f.p3d",
        "a3\structures_f_enoch\furniture\lighting\hangar_lamp\hangar_lamp.p3d",
        "a3\structures_f_enoch\furniture\school_equipment\radiator.p3d",
        "a3\structures_f_enoch\furniture\various\debris_small_house.p3d",
        "a3\structures_f_enoch\furniture\various\dirtpile_small_house.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\military\domes\domeparts_01_struts_stack_f.p3d",
        "a3\structures_f_enoch\military\training\craterlong_02_small_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_01_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_debris_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_3m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_3m_v2_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound04_8m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_5m_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_centerline_20m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_4m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_8m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_l_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_r_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_4m_nolc_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_nolc_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_d_nolc_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_2m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_d_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_16m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d",
        "a3\structures_f_heli\items\sport\football_01_f.p3d",
        "a3\weapons_f\ammoboxes\ammobox.p3d",
        "a3\weapons_f_orange\ammo\leaflet_05_new_f.p3d",
        "a3\weapons_f_orange\ammo\leaflet_05_old_f.p3d",
        "ca\structures_e\misc\misc_interier\teapot_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_01_5m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_01_pillar.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_02_4m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_02_pillar.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_04_5m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_04_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_04_pillar.p3d",
        "opxmisc\wall1.p3d",
        "opxmisc\wall3.p3d",
        "opxmisc\wall3pillar.p3d",
        "opxmisc\wall5.p3d",
        "opxmisc\wall8.p3d",
        "opxmisc\wall8b.p3d",
        "opxmisc\wall8bpillar.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\roads_f\runway\runway_end04_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_radar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\structures_e\mil\mil_repair_center_ep1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_clay_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "ca\buildings\dum_istan3.p3d",
        "ca\buildings\dum_istan4_inverse.p3d",
        "ca\buildings\dum_mesto3_istan.p3d",
        "ca\buildings\hut06.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housec\house_c_10_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_01.p3d",
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
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_10.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_11.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_12.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_13.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_14.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex8.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex9.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_garage1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_garages.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h11.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h11_b.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h18.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h19.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_h20.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_shop3b.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx_stores3.p3d",
        "opxbuildings\longcat.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_01.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_02.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_03.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_04.p3d",
        "cup\terrains\cup_terrains_opx_structures_complex\complex\cup_opx_complex_06.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex8.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex9.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_clay_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housec\house_c_10_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "cup\terrains\cup_terrains_opx_structures\commercial\cup_opx_shop_01.p3d",
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
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_10.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_11.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_12.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_13.p3d",
        "cup\terrains\cup_terrains_structures_e\housel\cup_terrains_house_l_14.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex4.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex8.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_complex9.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_corner1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_h3.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut1.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut2.p3d",
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_hut3.p3d",
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
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_generator_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\industrial\port\containerline_03_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d",
        "ca\buildings\fuelstation.p3d"
    ];

};

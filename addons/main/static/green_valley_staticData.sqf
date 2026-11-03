// ALiVE 3 index v3.1, made 2026-11-03 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: green_valley (ALiVE 3 index v3.1, 2026-11-03)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-03", "web", true];

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
        "a3\structures_f_enoch\furniture\school_equipment\class_case_b_closed.p3d",
        "a3\weapons_f_orange\ammo\leaflet_05_new_f.p3d",
        "ca\misc2\table\table.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_01_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_02_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_4m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_8m.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_dam.p3d",
        "cup\terrains\cup_terrains_opx_structures\walls\cup_opx_city_wall_03_pillar.p3d",
        "opxmisc\cart2.p3d",
        "opxmisc\wall1.p3d",
        "opxmisc\wall3.p3d",
        "opxmisc\wall5.p3d",
        "opxmisc\wall8.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\roads_f\runway\runway_end04_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_radar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\structures_e\mil\mil_repair_center_ep1.p3d",
        "opxbuildings\watertower.p3d"
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
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_clay_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings\dum_istan3.p3d",
        "ca\buildings\dum_istan4_inverse.p3d",
        "ca\buildings\dum_mesto3_istan.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\misc\stanek_1b.p3d",
        "ca\buildings\podesta_1_stairs4.p3d",
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
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
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
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_store1.p3d",
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
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_clay_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "ca\buildings\podesta_1_stairs4.p3d",
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
        "juju\juju_sahartra_struc\opx_structures\juju_opx2_store1.p3d",
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

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "cup\terrains\cup_terrains_opx_structures\construction\cup_opx_construction01.p3d",
        "cup\terrains\cup_terrains_opx_structures\construction\cup_opx_construction04.p3d"
    ];

};

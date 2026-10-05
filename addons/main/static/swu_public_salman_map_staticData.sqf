// ALiVE 3 index v3.1, made 2026-10-05 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: swu_public_salman_map (ALiVE 3 index v3.1, 2026-10-05)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "swu_public_salman_map") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\data_f\krater.p3d",
        "a3\data_f\particleeffects\craterlong\craterlong.p3d",
        "a3\data_f\particleeffects\craterlong\craterlong_small.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\orange_01_f.p3d",
        "a3\roads_f\runway\track_north01_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_4x4_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_ruins_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_08_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_01_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_02_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_03_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_04_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_big_ground1_f.p3d",
        "a3\structures_f_enoch\wrecks\mi8_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\powergenerator_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgesea_01_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_1m_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_l_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_heli\furniture\officetable_01_f.p3d",
        "ca\buildings\furniture\bed_husbands.p3d",
        "ca\buildings\furniture\case_bedroom_b.p3d",
        "ca\buildings\furniture\case_wooden_b.p3d",
        "ca\buildings\furniture\skrin_opalena.p3d",
        "ca\misc\betonl_maly.p3d",
        "ca\misc\container.p3d",
        "ca\misc\container2.p3d",
        "ca\roads2\runwayold_40_main.p3d",
        "ca\structures\furniture\cases\case_bedroom_a\case_bedroom_a.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ruins_ep1.p3d",
        "ca\structures_e\misc\misc_cables\misc_cable_ep1.p3d",
        "ca\structures_e\misc\misc_interier\cabinet_ep1.p3d",
        "ca\structures_e\misc\misc_interier\table_small_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlineb_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\wheeled\hmmwv_wrecked.p3d",
        "opxbuildings\block4.p3d",
        "opxmisc\cart.p3d",
        "opxmisc\cart3.p3d",
        "opxmisc\container3.p3d",
        "opxmisc\gateturquoiseopen.p3d",
        "opxmisc\grave.p3d",
        "opxmisc\grave4.p3d",
        "opxmisc\loam\loam_wall1_arch.p3d",
        "opxmisc\monument.p3d",
        "opxmisc\mural3.p3d",
        "opxmisc\mural5.p3d",
        "opxmisc\mural6.p3d",
        "opxmisc\mural9.p3d",
        "opxmisc\obelisk.p3d",
        "opxmisc\pallets.p3d",
        "opxmisc\shrine.p3d",
        "opxmisc\trash.p3d",
        "opxmisc\trash2.p3d",
        "opxmisc\trash3.p3d",
        "opxmisc\trash4.p3d",
        "opxmisc\trash5.p3d",
        "swu_public_salman_data\models\swu_saddam_large_mural.p3d",
        "swu_public_salman_data\models\swu_saddam_mural_1.p3d",
        "swu_public_salman_data\models\swu_saddam_poster_1.p3d",
        "swu_public_salman_data\models\swu_saddam_poster_2.p3d",
        "swu_public_salman_data\models\swu_saddam_poster_3.p3d",
        "swu_public_salman_data\models\swu_saddam_poster_4.p3d",
        "swu_public_salman_data\models\swu_saddam_wall_painting.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "ca\buildings\tents\fortress_02.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "opxmisc\guardtower.p3d"
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
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\addons\i_garage_v1_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_grey_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings\bouda_plech.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan2_04a.p3d",
        "ca\buildings\dum_istan2b.p3d",
        "ca\buildings\dum_istan3.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_istan4.p3d",
        "ca\buildings\dum_istan4_big.p3d",
        "ca\buildings\dum_istan4_big_inverse.p3d",
        "ca\buildings\dum_istan4_detaily1.p3d",
        "ca\buildings\dum_istan4_inverse.p3d",
        "ca\buildings\dum_mesto3_istan.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_olez_istan2.p3d",
        "ca\buildings\dum_olez_istan2_maly.p3d",
        "ca\buildings\dum_olez_istan2_maly2.p3d",
        "ca\buildings\dum_olez_istan2_maly_open.p3d",
        "ca\structures_e\housea\a_citygate1\a_citygate1_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_dam_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ruins_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_2_basehide_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "opxbuildings\10str.p3d",
        "opxbuildings\14str.p3d",
        "opxbuildings\16str.p3d",
        "opxbuildings\17str.p3d",
        "opxbuildings\17strb.p3d",
        "opxbuildings\18str.p3d",
        "opxbuildings\19str.p3d",
        "opxbuildings\21str.p3d",
        "opxbuildings\21str_c.p3d",
        "opxbuildings\21str_d.p3d",
        "opxbuildings\22str.p3d",
        "opxbuildings\23str.p3d",
        "opxbuildings\5str.p3d",
        "opxbuildings\6str.p3d",
        "opxbuildings\7str.p3d",
        "opxbuildings\block.p3d",
        "opxbuildings\block10.p3d",
        "opxbuildings\block2.p3d",
        "opxbuildings\block3.p3d",
        "opxbuildings\block7.p3d",
        "opxbuildings\block7_b.p3d",
        "opxbuildings\block8.p3d",
        "opxbuildings\block8_b.p3d",
        "opxbuildings\block8_c.p3d",
        "opxbuildings\block9_b.p3d",
        "opxbuildings\hut1.p3d",
        "opxbuildings\hut10.p3d",
        "opxbuildings\hut11.p3d",
        "opxbuildings\hut12.p3d",
        "opxbuildings\hut2.p3d",
        "opxbuildings\hut4.p3d",
        "opxbuildings\hut5.p3d",
        "opxbuildings\hut7.p3d",
        "opxbuildings\hut9.p3d",
        "opxbuildings\hut9_c.p3d",
        "opxbuildings\long_house1.p3d",
        "opxbuildings\long_house2.p3d",
        "opxbuildings\policestation.p3d",
        "opxbuildings\small_house.p3d",
        "opxbuildings\small_iraqib.p3d",
        "opxbuildings\villa.p3d",
        "opxbuildings\villa2.p3d",
        "opxbuildings\villa3.p3d",
        "opxbuildings\villa_b.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "opxbuildings\policestation.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan2b.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_olez_istan2_maly.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_2_basehide_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "opxbuildings\block10.p3d",
        "opxbuildings\hut6.p3d",
        "opxbuildings\hut7.p3d",
        "opxbuildings\policestation.p3d",
        "opxbuildings\villa.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "ca\structures_e\misc\misc_powerline\powlinea_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_shed_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\ind\crane\crane_f.p3d"
    ];

};

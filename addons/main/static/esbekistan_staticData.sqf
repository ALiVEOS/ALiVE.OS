// ALiVE 3 index v3.1, made 2026-11-12 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: esbekistan (ALiVE 3 index v3.1, 2026-11-12)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "esbekistan") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\air\70mmrocket.p3d",
        "ca\air\ah1zwreck.p3d",
        "ca\air\av8b_litening.p3d",
        "ca\buildings2\ind_pipeline\indpipe1\indpipe1_ul.p3d",
        "ca\buildings2\ind_pipeline\indpipe1\indpipe1_ur.p3d",
        "ca\buildings2\ind_pipeline\indpipe2\indpipe2_bigbuild2_r.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\shed_small\shed_m02.p3d",
        "ca\buildings\furniture\dhangar_whiteskrin.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\data\libraryicons.p3d",
        "ca\misc2\bagfencecorner.p3d",
        "ca\misc2\explosive\explosive.p3d",
        "ca\misc2\table\table.p3d",
        "ca\misc\empty.p3d",
        "ca\misc_e\nastenkax_ep1.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pier_ruins.p3d",
        "ca\structures_e\mil\mil_barracks_l_ruins_ep1.p3d",
        "ca\wheeled2\ikarus\ikarus.p3d",
        "ca\wheeled2\lada\lada.p3d",
        "ca\wheeled2\towingtractor\towingtractor.p3d",
        "ca\wheeled\car_sedan.p3d",
        "ca\wheeled\datsun1_civil_2_covered.p3d",
        "ca\wheeled\hilux1_civil_1_open.p3d",
        "ca\wheeled\hilux1_civil_2_covered.p3d",
        "ca\wheeled\hilux_armed\hilux_spg9.p3d",
        "ca\wheeled\skodovka.p3d",
        "ca\wheeled\skodovka_red.p3d",
        "ca\wheeled\tractor.p3d",
        "ca\wheeled\tractor_2.p3d",
        "opxbuildings\ruin.p3d",
        "opxbuildings\shack.p3d",
        "opxmisc\bigwall1.p3d",
        "opxmisc\bigwall1_arch.p3d",
        "opxmisc\bigwall1_broken.p3d",
        "opxmisc\bigwall1_broken3.p3d",
        "opxmisc\bigwall1_door.p3d",
        "opxmisc\cart.p3d",
        "opxmisc\cart2.p3d",
        "opxmisc\cart3.p3d",
        "opxmisc\container.p3d",
        "opxmisc\loam\tower.p3d",
        "opxmisc\marketstand2.p3d",
        "opxmisc\shrine.p3d",
        "opxmisc\trash.p3d",
        "opxmisc\wall15.p3d",
        "opxmisc\wall15_arch.p3d",
        "opxmisc\wall4.p3d",
        "opxmisc\wall8.p3d",
        "opxmisc\wall9.p3d",
        "opxmisc\well.p3d",
        "razmisc\bigwall1d_raz.p3d",
        "razmisc\clutter_grass_brown.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\budova1.p3d",
        "ca\buildings\budova4.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\buildings\tents\mash.p3d",
        "ca\buildings\tents\stan_east.p3d",
        "ca\misc3\fortified_nest_big.p3d",
        "ca\misc3\wf\wf_depot.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\misc_e\camonet_east_var1_ep1.p3d",
        "ca\misc_e\camonetb_east_ep1.p3d",
        "ca\misc_e\fort_artillery_nest_ep1.p3d",
        "ca\misc_e\fort_watchtower_ep1.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "ca\misc_e\wf\wf_anti_radar_west_ep1.p3d",
        "ca\misc_e\wf\wf_hq_m1130_cv_ep1.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\structures\mil\mil_house_dam.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\structures_e\mil\mil_repair_center_ep1.p3d",
        "opxbuildings\watertower.p3d",
        "razmisc\bigwall1_widearch.p3d",
        "razmisc\tower2_raz.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\budova1.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\tents\stan_east.p3d",
        "ca\misc_e\fort_artillery_nest_ep1.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "razmisc\bigwall1_widearch.p3d",
        "razmisc\tower2_raz.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\misc_e\wf\wf_hq_m1130_cv_ep1.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "razmisc\bigwall1_widearch.p3d",
        "razmisc\tower2_raz.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc3\fortified_nest_big.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads_e\runway\runway_end22_ep1.p3d",
        "ca\roads_e\runway\runway_end24_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\roads_e\runway\runway_poj_t_2_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads_e\runway\runway_end22_ep1.p3d",
        "ca\roads_e\runway\runway_end24_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\roads_e\runway\runway_poj_t_2_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a2_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a3_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b2_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b3_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b4_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b5_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c1_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c5_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d1_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d2_ruins.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\buildings\bouda_plech.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_olez_istan2.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\garaz_mala.p3d",
        "ca\buildings\hospital.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\ruins\bouda3_ruins.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_ruins.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures\shed_ind\shed_ind02_dam.p3d",
        "ca\structures_e\housea\a_citygate1\a_citygate1_ep1.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_corner_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_gate_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ruins_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
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
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_6_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "opxbuildings\10str.p3d",
        "opxbuildings\14str.p3d",
        "opxbuildings\15str.p3d",
        "opxbuildings\16str.p3d",
        "opxbuildings\17str.p3d",
        "opxbuildings\18str.p3d",
        "opxbuildings\21str.p3d",
        "opxbuildings\21str_b.p3d",
        "opxbuildings\21str_c.p3d",
        "opxbuildings\21str_d.p3d",
        "opxbuildings\22str.p3d",
        "opxbuildings\23str.p3d",
        "opxbuildings\5str.p3d",
        "opxbuildings\6str.p3d",
        "opxbuildings\7str.p3d",
        "opxbuildings\block.p3d",
        "opxbuildings\hut10.p3d",
        "opxbuildings\hut3_b.p3d",
        "opxbuildings\hut3_b_2.p3d",
        "opxbuildings\hut5.p3d",
        "opxbuildings\hut7.p3d",
        "opxbuildings\hut9.p3d",
        "opxbuildings\hut9_b.p3d",
        "opxbuildings\hut9_c.p3d",
        "opxbuildings\little mosque.p3d",
        "opxbuildings\long_house1.p3d",
        "opxbuildings\long_house2.p3d",
        "opxbuildings\mosque3.p3d",
        "razmisc\6str_raz.p3d",
        "razmisc\bigwall1_widearch.p3d",
        "razmisc\tower2_raz.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "razmisc\bigwall1_widearch.p3d",
        "razmisc\tower2_raz.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
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
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "opxbuildings\hut7.p3d",
        "razmisc\bigwall1_widearch.p3d",
        "razmisc\tower2_raz.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\misc3\powergenerator\powergenerator.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "ca\misc_e\wf\wf_anti_radar_west_ep1.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\structures\nav_boathouse\nav_boathouse_pier.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_shed_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings\misc\leseni2x.p3d",
        "ca\buildings\misc\leseni4x.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d"
    ];

};

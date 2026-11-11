// ALiVE 3 index v3.1, made 2026-11-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: clafghan (ALiVE 3 index v3.1, 2026-11-11)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-11", "web", true];

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

 if (tolower(_worldName) == "clafghan") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\tents\pristresek_mensi.p3d",
        "ca\misc3\wf\wf_hesco_big_10x.p3d",
        "ca\misc\snow.p3d",
        "ca\structures_pmc\buildings\ruins\farm_cowshed\ruin_cowshed_a_ruins_pmc.p3d",
        "ca\structures_pmc\buildings\ruins\farm_cowshed\ruin_cowshed_c_ruins_pmc.p3d",
        "opxbuildings\ruin.p3d",
        "opxbuildings\shack.p3d",
        "opxmisc\barrier_small.p3d",
        "opxmisc\bigwall1_arch.p3d",
        "opxmisc\bigwall1_door.p3d",
        "opxmisc\bigwall1_short.p3d",
        "opxmisc\cart.p3d",
        "opxmisc\cart2.p3d",
        "opxmisc\cart3.p3d",
        "opxmisc\carton.p3d",
        "opxmisc\carton2.p3d",
        "opxmisc\carton_flipped.p3d",
        "opxmisc\container.p3d",
        "opxmisc\gate_arch.p3d",
        "opxmisc\grave3.p3d",
        "opxmisc\hesco1_a.p3d",
        "opxmisc\hesco1_b.p3d",
        "opxmisc\hesco1_d.p3d",
        "opxmisc\hesco2.p3d",
        "opxmisc\hesco3.p3d",
        "opxmisc\hesco4.p3d",
        "opxmisc\hesco_stack.p3d",
        "opxmisc\hesco_triple.p3d",
        "opxmisc\marketstand2.p3d",
        "opxmisc\minaret.p3d",
        "opxmisc\mural7.p3d",
        "opxmisc\shrine.p3d",
        "opxmisc\trash.p3d",
        "opxmisc\wall10.p3d",
        "opxmisc\wall10_arch.p3d",
        "opxmisc\wall14.p3d",
        "opxmisc\wall3.p3d",
        "opxmisc\wall4.p3d",
        "opxmisc\wall5.p3d",
        "opxmisc\wall8.p3d",
        "opxmisc\wall9.p3d",
        "opxmisc\well.p3d",
        "opxroads\asf25.p3d",
        "opxroads\asf6_ped.p3d",
        "opxroads\bridge.p3d",
        "opxroads\road12.p3d",
        "razmisc\bigwall1d_door_raz.p3d",
        "razmisc\bigwall1d_widearch.p3d",
        "razmisc\wall3_plaster ll.p3d",
        "razmisc\wall3_plaster_long.p3d",
        "razmisc\wall_plaster.p3d",
        "razmisc\wall_z_01.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\tents\camo_box.p3d",
        "ca\buildings\tents\fortress_01.p3d",
        "ca\buildings\tents\fortress_02.p3d",
        "ca\buildings\tents\pristresek.p3d",
        "ca\misc3\wf\wf_bunker.p3d",
        "ca\misc3\wf\wf_depot.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
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
        "opxbuildings\tower2.p3d",
        "opxbuildings\watertower.p3d",
        "opxmisc\guardtower.p3d",
        "razmisc\hut7_raz.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "opxmisc\guardtower.p3d",
        "razmisc\hut7_raz.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "razmisc\hut7_raz.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads_e\runway\runway_end15_ep1.p3d",
        "ca\roads_e\runway\runway_end33_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads_e\runway\runway_end15_ep1.p3d",
        "ca\roads_e\runway\runway_end33_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_interier_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
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
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "opxbuildings\10str.p3d",
        "opxbuildings\15str.p3d",
        "opxbuildings\16str.p3d",
        "opxbuildings\17str.p3d",
        "opxbuildings\17strb.p3d",
        "opxbuildings\18str.p3d",
        "opxbuildings\19str.p3d",
        "opxbuildings\21str.p3d",
        "opxbuildings\21str_b.p3d",
        "opxbuildings\21str_c.p3d",
        "opxbuildings\21str_d.p3d",
        "opxbuildings\22str.p3d",
        "opxbuildings\23str.p3d",
        "opxbuildings\5str.p3d",
        "opxbuildings\6str.p3d",
        "opxbuildings\block2.p3d",
        "opxbuildings\block3.p3d",
        "opxbuildings\block7.p3d",
        "opxbuildings\block7_b.p3d",
        "opxbuildings\block8_b.p3d",
        "opxbuildings\block8_c.p3d",
        "opxbuildings\garage.p3d",
        "opxbuildings\hut1.p3d",
        "opxbuildings\hut10.p3d",
        "opxbuildings\hut11.p3d",
        "opxbuildings\hut12.p3d",
        "opxbuildings\hut1_2.p3d",
        "opxbuildings\hut2.p3d",
        "opxbuildings\hut3.p3d",
        "opxbuildings\hut3_2.p3d",
        "opxbuildings\hut3_b.p3d",
        "opxbuildings\hut3_b_2.p3d",
        "opxbuildings\hut4_2.p3d",
        "opxbuildings\hut7.p3d",
        "opxbuildings\little mosque.p3d",
        "opxbuildings\long_house1.p3d",
        "opxbuildings\long_house2.p3d",
        "opxbuildings\meh_sak.p3d",
        "opxbuildings\minaret2.p3d",
        "opxbuildings\mosque2.p3d",
        "opxbuildings\mosque3.p3d",
        "opxbuildings\office.p3d",
        "opxbuildings\small_house.p3d",
        "opxbuildings\small_iraqi.p3d",
        "opxbuildings\small_iraqib.p3d",
        "opxbuildings\villa2.p3d",
        "opxbuildings\villa3.p3d",
        "opxbuildings\villa_b.p3d",
        "razmisc\19str_raz.p3d",
        "razmisc\6str_raz.p3d",
        "razmisc\7str_raz.p3d",
        "razmisc\hut10_raz.p3d",
        "razmisc\hut10nb_raz.p3d",
        "razmisc\hut12_raz.p3d",
        "razmisc\hut13nb_raz.p3d",
        "razmisc\hut1_raz.p3d",
        "razmisc\hut2_raz.p3d",
        "razmisc\hut2nb.p3d",
        "razmisc\hut32_raz.p3d",
        "razmisc\hut3_raz.p3d",
        "razmisc\hut3b_raz.p3d",
        "razmisc\hut4_2_raz.p3d",
        "razmisc\hut4_raz.p3d",
        "razmisc\hut4nb_raz.p3d",
        "razmisc\hut6_raz.p3d",
        "razmisc\hut9_raz.p3d",
        "razmisc\hut9b_raz.p3d",
        "razmisc\hut9nb_raz.p3d",
        "razmisc\razhut5.p3d",
        "razmisc\razhut6.p3d",
        "razmisc\shack_raz.p3d",
        "razmisc\small_iraqi_raz.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_interier_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
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
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "opxbuildings\hut7.p3d",
        "razmisc\hut9_raz.p3d",
        "razmisc\razhut5.p3d"
    ];

};

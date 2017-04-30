private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: clafghan"] call ALIVE_fnc_dump;

ALIVE_Indexing_Blacklist = [];
ALIVE_airBuildingTypes = [];
ALIVE_militaryParkingBuildingTypes = [];
ALIVE_militarySupplyBuildingTypes = [];
ALIVE_militaryHQBuildingTypes = [];
ALIVE_militaryAirBuildingTypes = [];
ALIVE_civilianAirBuildingTypes = [];
ALiVE_HeliBuildingTypes = [];
ALIVE_militaryHeliBuildingTypes = [];
ALIVE_civilianHeliBuildingTypes = [];
ALIVE_militaryBuildingTypes = [];
ALIVE_civilianPopulationBuildingTypes = [];
ALIVE_civilianHQBuildingTypes = [];
ALIVE_civilianPowerBuildingTypes = [];
ALIVE_civilianCommsBuildingTypes = [];
ALIVE_civilianMarineBuildingTypes = [];
ALIVE_civilianRailBuildingTypes = [];
ALIVE_civilianFuelBuildingTypes = [];
ALIVE_civilianConstructionBuildingTypes = [];
ALIVE_civilianSettlementBuildingTypes = [];

ALiVE_mapCompositionType = "Desert";

if (tolower(_worldName) == "clafghan") then {
    [ALIVE_mapBounds, worldName, 20000] call ALIVE_fnc_hashSet;

    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\misc\snow.p3d",
        "ca\misc\snowman.p3d",
        "opxmisc\hesco_stack.p3d",
        "ca\buildings\tents\camo_box.p3d",
        "opxmisc\conslab.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "opxmisc\hesco_triple.p3d",
        "opxmisc\hesco4.p3d",
        "opxmisc\hesco2.p3d",
        "opxmisc\conslabfallen.p3d",
        "opxmisc\hesco1_d.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\misc\zed_podplaz_civil.p3d",
        "opxbuildings\large shed.p3d",
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\buildings\misc\zed_dira_civil.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\misc3\wf\wf_hesco_big_10x.p3d",
        "ca\misc2\hbarrier5.p3d",
        "ca\structures\misc\armory\woodenramp\woodenramp.p3d",
        "ca\misc3\toilet.p3d",
        "ca\misc2\hbarrier1.p3d",
        "ca\misc2\bighbarrier.p3d",
        "ca\structures_e\misc\misc_market\covering_hut_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "opxmisc\sandwall1_d.p3d",
        "opxmisc\sandwall1_b.p3d",
        "opxmisc\bigwall1_arch.p3d",
        "opxmisc\bigwall1b_long.p3d",
        "opxbuildings\ruin.p3d",
        "opxmisc\bigwall1b.p3d",
        "opxmisc\bigwall1_broken2.p3d",
        "opxmisc\farmwall.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ruins_ep1.p3d",
        "ca\structures_e\misc\shed_m03_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ruins_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_3_ep1.p3d",
        "ca\roads2\asf2_10 25.p3d",
        "opxmisc\powerpole.p3d",
        "ca\roads2\asf2_10 75.p3d",
        "ca\roads2\asf2_10 50.p3d",
        "ca\structures_e\housec\house_c_10_ruins_ep1.p3d",
        "opxmisc\wall12.p3d",
        "razmisc\wall1pillar_raz.p3d",
        "opxmisc\wall11_2.p3d",
        "opxmisc\wall11_end.p3d",
        "opxmisc\well.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_2_ep1.p3d",
        "opxmisc\trash7.p3d",
        "opxmisc\farmwallend.p3d",
        "opxroads\bridge.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_a_ep1.p3d",
        "razmisc\wall3_plaster ll.p3d",
        "razmisc\wall3_plaster_long.p3d",
        "opxmisc\trash6.p3d",
        "opxmisc\bigwall1b_short.p3d",
        "opxmisc\trash3.p3d",
        "razmisc\wall10pillar_raz.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_4_ep1.p3d",
        "opxmisc\trash2.p3d",
        "ca\structures_e\misc\shed_m01_ruins_ep1.p3d",
        "opxmisc\trash5.p3d",
        "opxmisc\trash.p3d",
        "opxmisc\container2.p3d",
        "ca\structures_e\misc\misc_construction\misc_concoutlet_ep1.p3d",
        "opxmisc\carton_flipped.p3d",
        "razmisc\wall12_raz.p3d",
        "opxmisc\wall14.p3d",
        "opxroads\road12.p3d",
        "opxbuildings\shack.p3d",
        "razmisc\razcart2.p3d",
        "razmisc\wall_plaster_long.p3d",
        "razmisc\wall_plaster.p3d",
        "opxmisc\wall10.p3d",
        "opxmisc\wall10pillar.p3d",
        "opxmisc\bigwall1_door.p3d",
        "razmisc\razcart.p3d",
        "opxmisc\trash4.p3d",
        "opxmisc\gateredopen.p3d",
        "opxmisc\sandwall1.p3d",
        "ca\structures_e\misc\misc_market\covering_hut_big_ep1.p3d",
        "opxmisc\pallets.p3d",
        "razmisc\razcart3.p3d",
        "opxmisc\ruins\bigwall1_ruin.p3d",
        "opxmisc\gateturquoiseopen.p3d",
        "opxmisc\gateblueopen.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "opxmisc\wall10_arch.p3d",
        "razmisc\bigwall1d_short_raz.p3d",
        "razmisc\bigwall1_long_raz.p3d",
        "razmisc\bigwall1d_door_raz.p3d",
        "razmisc\bigwall1d_widearch.p3d",
        "opxmisc\obelisk.p3d",
        "opxmisc\marketstand1.p3d",
        "opxmisc\marketstand1_b.p3d",
        "opxmisc\gategreenopen.p3d",
        "opxmisc\marketstand2_b.p3d",
        "opxmisc\wall9.p3d",
        "opxmisc\wall9pillar.p3d",
        "razmisc\hut7_raz.p3d",
        "opxmisc\fence1.p3d",
        "opxmisc\fence1_pillar.p3d",
        "opxmisc\wall8b.p3d",
        "opxmisc\wall8bpillar.p3d",
        "opxmisc\wall4pillar.p3d",
        "opxmisc\road_attrib\avgani1.p3d",
        "opxmisc\wall5.p3d",
        "ca\structures_e\housek\house_k_7_ruins_ep1.p3d",
        "opxroads\asf25.p3d",
        "ca\roads_e\sidewalks\sw_c_crosst_ep1.p3d",
        "razmisc\wall_z_02.p3d",
        "razmisc\wall_z_01.p3d",
        "opxmisc\cart.p3d",
        "opxmisc\marketstand2.p3d",
        "opxmisc\container3.p3d",
        "opxmisc\cart3.p3d",
        "opxmisc\cart2.p3d",
        "opxmisc\carton.p3d",
        "opxmisc\carton2.p3d",
        "opxmisc\container.p3d",
        "opxmisc\sidewalks\sidewalk1.p3d",
        "opxmisc\sidewalks\sidewalk2.p3d",
        "opxmisc\wall3.p3d",
        "opxmisc\mural7.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "opxmisc\bigwall1_short.p3d",
        "opxmisc\shrine_2.p3d",
        "ca\misc2\sr_border.p3d",
        "opxmisc\fence2_pillar.p3d",
        "ca\structures_pmc\buildings\ruins\farm_cowshed\ruin_cowshed_a_ruins_pmc.p3d",
        "opxmisc\ruins\bigwall1_ruin2.p3d",
        "ca\structures_pmc\buildings\ruins\farm_cowshed\ruin_cowshed_c_ruins_pmc.p3d",
        "ca\structures_pmc\buildings\ruins\farm_cowshed\ruin_cowshed_b_ruins_pmc.p3d",
        "opxmisc\road_attrib\avgani1_b.p3d",
        "opxbuildings\hut7.p3d",
        "opxmisc\wall8.p3d",
        "opxmisc\mural9.p3d",
        "opxmisc\wall4.p3d",
        "opxbuildings\block4.p3d",
        "ca\structures_e\housea\a_statue\a_statue_ep1.p3d",
        "opxmisc\grave3.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "opxmisc\double_arch_gate.p3d",
        "opxmisc\shrine.p3d",
        "opxmisc\wall11_pillar.p3d",
        "opxroads\asf6konec.p3d",
        "opxmisc\barrier_small.p3d",
        "opxmisc\hesco3.p3d",
        "opxmisc\hesco1_b.p3d",
        "opxmisc\hesco1_a.p3d",
        "razmisc\ruins\bigwall1_ruin2_raz.p3d",
        "opxmisc\minaret.p3d",
        "opxbuildings\minaret2.p3d",
        "opxmisc\gate_arch.p3d",
        "opxbuildings\minaret3.p3d",
        "opxmisc\sidewalks\sidewalk3.p3d",
        "opxroads\asf6_ped.p3d",
        "razmisc\hut11_raz.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\buildings\tents\fortress_01.p3d",
        "ca\buildings\tents\pristresek_mensi.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\buildings\tents\pristresek.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\buildings\tents\fortress_02.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d",
        "ca\misc_e\fort_watchtower_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "ca\misc3\wf\wf_depot.p3d",
        "ca\misc3\wf\wf_bunker.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "opxbuildings\watertower.p3d",
        "opxbuildings\tower2.p3d",
        "opxmisc\guardtower.p3d",
        "ca\misc_e\tent_east_ep1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\roads_e\runway\runway_end15_ep1.p3d",
        "ca\roads_e\runway\runway_end33_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\roads_e\runway\runway_end15_ep1.p3d",
        "ca\roads_e\runway\runway_end33_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [
        "ca\misc\heli_h_civil.p3d",
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\misc\heli_h_civil.p3d",
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "razmisc\hut9_raz.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housel\house_l_6_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "razmisc\razhut5.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housel\house_l_8_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_interier_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "razmisc\hut9_raz.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "razmisc\shack_raz.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "opxbuildings\hut1.p3d",
        "opxbuildings\hut3_b.p3d",
        "opxbuildings\hut3_2.p3d",
        "razmisc\hut3_raz.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "opxbuildings\garage.p3d",
        "ca\structures_e\housek\house_k_3_dam_ep1.p3d",
        "razmisc\hut2_raz.p3d",
        "razmisc\hut12_raz.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "razmisc\hut1_raz.p3d",
        "razmisc\hut4_2_raz.p3d",
        "opxbuildings\hut1_2.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "razmisc\hut4_raz.p3d",
        "opxbuildings\16str.p3d",
        "ca\structures_e\housel\house_l_6_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "razmisc\razhut5.p3d",
        "razmisc\razhut6.p3d",
        "opxbuildings\10str.p3d",
        "razmisc\hut13nb_raz.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "razmisc\7str_raz.p3d",
        "razmisc\hut3b_raz.p3d",
        "ca\structures_e\housel\house_l_8_dam_ep1.p3d",
        "opxbuildings\23str.p3d",
        "opxbuildings\5str.p3d",
        "opxbuildings\small_house.p3d",
        "razmisc\6str_raz.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "opxbuildings\mosque3.p3d",
        "razmisc\hut9b_raz.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "razmisc\hut2nb.p3d",
        "razmisc\hut9nb_raz.p3d",
        "razmisc\small_iraqi_raz.p3d",
        "razmisc\hut10nb_raz.p3d",
        "razmisc\hut6_raz.p3d",
        "opxbuildings\hut3_b_2.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "razmisc\hut32_raz.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "opxbuildings\hut11.p3d",
        "razmisc\19str_raz.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_3_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_2_dam_ep1.p3d",
        "opxbuildings\small_iraqi.p3d",
        "opxbuildings\small_iraqib.p3d",
        "opxbuildings\21str_c.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "opxbuildings\block8_b.p3d",
        "opxbuildings\21str_b.p3d",
        "opxbuildings\17strb.p3d",
        "opxbuildings\villa2.p3d",
        "opxbuildings\villa_b.p3d",
        "opxbuildings\block2.p3d",
        "opxbuildings\villa3.p3d",
        "opxbuildings\block3.p3d",
        "opxbuildings\17str.p3d",
        "opxbuildings\block7.p3d",
        "opxbuildings\18str.p3d",
        "opxbuildings\little mosque.p3d",
        "opxbuildings\21str_d.p3d",
        "opxbuildings\21str.p3d",
        "opxbuildings\meh_sak.p3d",
        "opxbuildings\long_house1.p3d",
        "opxbuildings\block8_c.p3d",
        "razmisc\hut10_raz.p3d",
        "opxbuildings\hut10.p3d",
        "opxbuildings\15str.p3d",
        "opxbuildings\hut12.p3d",
        "opxbuildings\6str.p3d",
        "opxbuildings\block7_b.p3d",
        "opxbuildings\office.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_interier_ep1.p3d",
        "opxbuildings\hut3.p3d",
        "opxbuildings\hut2.p3d",
        "opxbuildings\mosque2.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "opxbuildings\hut4_2.p3d",
        "opxbuildings\19str.p3d",
        "razmisc\hut4nb_raz.p3d",
        "opxbuildings\long_house2.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "opxbuildings\22str.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [];
};

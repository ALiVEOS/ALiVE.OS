private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: pja308"] call ALIVE_fnc_dump;

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

ALiVE_mapCompositionType = "Urban";

if (tolower(_worldName) == "pja308") then {
    [ALIVE_mapBounds, worldName, 21000] call ALIVE_fnc_hashSet;

    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_2_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l1_pillar_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l2_5m_end_ep1.p3d",
        "ca\structures_e\misc\misc_market\covering_hut_big_ep1.p3d",
        "ca\roads_e\roads\dirt2_02000.p3d",
        "ca\structures_e\housel\house_l_3_ruins_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\roads_e\sidewalks\sw_c_end_l_ep1.p3d",
        "ca\roads_e\sidewalks\sw_c_body_6m_ep1.p3d",
        "ca\roads_e\sidewalks\sw_c_turn_ep1.p3d",
        "ca\roads_e\sidewalks\sw_c_end_r_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_4_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ruins_ep1.p3d",
        "ca\misc\ural_wrecked.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "ca\roads_e\sidewalks\sw_a_end_l_ep1.p3d",
        "ca\roads_e\sidewalks\sw_a_body_6m_ep1.p3d",
        "ca\roads_e\sidewalks\sw_a_end_r_ep1.p3d",
        "ca\roads_e\sidewalks\sw_a_turn_ep1.p3d",
        "ca\misc2\barbgate.p3d",
        "ca\structures_e\misc\misc_construction\misc_concoutlet_ep1.p3d",
        "ca\roads_e\roads\dirt1_25.p3d",
        "ca\roads_e\roads\dirt1_11000.p3d",
        "ca\roads_e\roads\dirt1_02000.p3d",
        "ca\roads_e\roads\dirt1_6.p3d",
        "ca\roads_e\roads\dirt1_7100.p3d",
        "ca\roads_e\roads\dirt1_6konec.p3d",
        "ca\roads_e\roads\dirt1_12.p3d",
        "ca\roads_e\roads\dirt1_3025.p3d",
        "ca\roads_e\roads\dirt1_6010.p3d",
        "ca\roads_e\roads\dirt1_1575.p3d",
        "ca\roads_e\roads\dirt1_2250.p3d",
        "ca\structures_e\ind\ind_pipes\indpipe1_ul_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_pipes\indpipe1_ur_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ruins_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_a_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_01_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_switch_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ruins_ep1.p3d",
        "ca\misc\fort_razorwire.p3d",
        "ca\buildings\misc\lavicka_2.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_gate_ep1.p3d",
        "ca\misc\misc_tyreheap.p3d",
        "ca\buildings2\ind_cementworks\ind_dopravnik\d_mlyn_vys.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\misc3\fortified_nest_big.p3d",
        "ca\roads_e\runway\runway_end06_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\roads_e\runway\runway_main_40_ep1.p3d",
        "ca\buildings\vysilac_fm.p3d",
        "ca\roads_e\runway\runway_end24_ep1.p3d",
        "ca\buildings\army_hut2_int.p3d",
        "ca\misc2\barrack2\barrack2.p3d",
        "ca\buildings\army_hut_storrage.p3d",
        "ca\buildings\army_hut3_long_int.p3d",
        "ca\buildings\budova2.p3d",
        "ca\structures\mil\mil_barracks_l.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d",
        "ca\buildings\army_hut_int.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\misc3\fort_artillery_nest.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\structures\mil\mil_barracks_l.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\army_hut_storrage.p3d",
        "ca\structures\mil\mil_barracks_l.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\misc_market\covering_hut_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\budova4.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\misc\water_tank.p3d",
        "ca\buildings\tovarna1.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_box.p3d",
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings\komin.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\buildings2\shed_small\shed_m02.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d",
        "ca\structures\shed_ind\shed_ind02_dam.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\structures\house\housev\housev_3i3.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_end.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_main.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_olez_istan2.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan2b.p3d",
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_cementworks\ind_silomale\ind_silomale.p3d",
        "ca\buildings\dum_olez_istan2_maly2.p3d",
        "ca\structures_e\proxy_buildingparts\house_c\house_c_5_addon02_ep1.p3d",
        "ca\buildings\dum_olez_istan2_maly.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ruins_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan2b.p3d",
        "ca\structures_e\proxy_buildingparts\house_c\house_c_5_addon02_ep1.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlines_transformer1_ep1.p3d",
        "ca\buildings\trafostanica_velka.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_shed_ep1.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall2.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\structures_e\misc\misc_construction\misc_concbox_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_part2_ep1.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d"
    ];
};

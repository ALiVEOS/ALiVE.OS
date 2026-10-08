// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: reshmaan (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "reshmaan") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings\misc\zed_civil.p3d",
        "ca\misc_e\misc_cargo4c_ep1.p3d",
        "ca\misc_e\misc_cargo4d_ep1.p3d",
        "ca\roads2\dam\dam_conc\dam_concp_20.p3d",
        "ca\roads_e\runway\runway_end27_ep1.p3d",
        "ca\roads_e\sidewalks\sw_c_crosst_ep1.p3d",
        "ca\structures_e\housea\a_statue\a_statue_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_tunnel_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_2_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_3_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_4_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_a_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_a_left_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_ab_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlineb_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\wheeled\skodovka_wrecked.p3d",
        "fogu\mad_roads\mad_asf2_10 25.p3d",
        "fogu\mad_roads\mad_asf2_10 50.p3d",
        "fogu\mad_roads\mad_asf2_10 75.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\misc_e\barrack2_ep1.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "ca\roads_e\runway\runway_end09_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "ca\structures_e\mil\mil_repair_center_ep1.p3d",
        "ca\structures_pmc\ind\hopper_old_pmc.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures_e\mil\mil_controltower_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads_e\runway\runway_end00_ep1.p3d",
        "ca\roads_e\runway\runway_end09_ep1.p3d",
        "ca\roads_e\runway\runway_end18_ep1.p3d",
        "ca\roads_e\runway\runway_main_ep1.p3d",
        "ca\roads_e\runway\runway_poj_t_2_ep1.p3d",
        "ca\structures_e\mil\mil_hangar_ep1.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads_e\runway\runway_end00_ep1.p3d",
        "ca\roads_e\runway\runway_end09_ep1.p3d",
        "ca\roads_e\runway\runway_end18_ep1.p3d",
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
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings\hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\ind\ind_stack_big.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_corner_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_gate_ep1.p3d",
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
        "ca\structures_e\housec\house_c_5_v1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
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
        "ca\structures_pmc\misc\shed\shed_w02_pmc.p3d",
        "ca\structures_pmc\misc\shed\shed_w03_pmc.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
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
        "ca\structures_e\housec\house_c_5_v1_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlinea_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\structures_e\misc\com_tower_ep1.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_shed_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_part2_ep1.p3d"
    ];

};

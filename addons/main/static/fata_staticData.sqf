// ALiVE 3 index v3.1, made 2026-10-09 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: fata (ALiVE 3 index v3.1, 2026-10-09)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-09", "web", true];

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

 if (tolower(_worldName) == "fata") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\misc_cargo\seacrate.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings2\shed_small\shed_m02.p3d",
        "ca\buildings\furniture\case_wooden_b.p3d",
        "ca\buildings\furniture\conference_table_a.p3d",
        "ca\buildings\furniture\skrin_opalena.p3d",
        "ca\buildings\misc\zavora_2.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\data\krater.p3d",
        "ca\misc2\bighbarrier.p3d",
        "ca\misc2\hbarrier1.p3d",
        "ca\misc2\hbarrier3.p3d",
        "ca\misc2\hbarrier5.p3d",
        "ca\misc\mutt_vysilacka.p3d",
        "ca\misc_e\powergenerator.p3d",
        "ca\misc_e\wreck_c130j.p3d",
        "ca\misc_e\wreck_c130j_ep1_dirt.p3d",
        "ca\roads_e\sidewalks\sw_c_crosst_ep1.p3d",
        "ca\structures\misc\armory\conelight\conelight.p3d",
        "ca\structures\misc\armory\woodenramp\woodenramp.p3d",
        "ca\structures\ruins\glass_cullet_01.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_1_ruins_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ruins_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_switch_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_tunnel_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ep1.p3d",
        "ca\structures_e\misc\misc_cables\misc_cable_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_ab_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlineb_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_pillar_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ruins_ep1.p3d",
        "ca\wheeled\hmmwv_wrecked.p3d",
        "praa\praa_roads\bridges\praa_bridge_foot_none.p3d",
        "praa\praa_roads\bridges\praa_bridge_foot_start.p3d",
        "praa\praa_roads\roads\praa_map.road.p3d",
        "praa\praa_statics\furniture\barrel_empty.p3d",
        "praa\praa_statics\furniture\mapboard.p3d",
        "praa\praa_statics\furniture\mapimage.p3d",
        "praa\praa_statics\furniture\rubbishbox.p3d",
        "praa\praa_statics\furniture\trash.p3d",
        "praa\praa_statics\furniture\trash2.p3d",
        "praa\praa_statics\furniture\trash3.p3d",
        "praa\praa_statics\furniture\trash4.p3d",
        "praa\praa_statics\furniture\trash5.p3d",
        "praa\praa_statics\furniture\trash6.p3d",
        "praa\praa_statics\furniture\trash7.p3d",
        "praa\praa_statics\hoses\hose_ground.p3d",
        "praa\praa_statics\hoses\hose_wall.p3d",
        "praa\praa_statics\mil\barrier_long.p3d",
        "praa\praa_statics\mil\boom_gate.p3d",
        "praa\praa_statics\mil\hesco1_a.p3d",
        "praa\praa_statics\mil\hesco1_c.p3d",
        "praa\praa_statics\mil\hesco1_d.p3d",
        "praa\praa_statics\mil\hesco_stack.p3d",
        "praa\praa_statics\mil\hesco_triple.p3d",
        "praa\praa_statics\mil\road_barrier_med_a.p3d",
        "praa\praa_statics\mil\road_barrier_med_b.p3d",
        "praa\praa_statics\mil\road_barrier_med_c.p3d",
        "praa\praa_statics\mil\road_speedbump.p3d",
        "praa\praa_statics\mil\road_trafficcone.p3d",
        "praa\praa_statics\mil\t_barrier.p3d",
        "praa\praa_statics\mil\tx_barrier.p3d",
        "praa\praa_statics\mil\tx_barrier_2.p3d",
        "praa\praa_statics\mil\tx_barrier_4.p3d",
        "praa\praa_statics\mil\tx_barrier_b.p3d",
        "praa\praa_statics\mil\tx_barrier_curve.p3d",
        "praa\praa_statics\mil\tx_barrier_curve90.p3d",
        "praa\praa_statics\mil\tx_barrier_x1a.p3d",
        "praa\praa_statics\mil\tx_barrier_x1b.p3d",
        "praa\praa_statics\mil\tx_barrier_x2.p3d",
        "praa\praa_statics\mil\tx_barrier_x4.p3d",
        "praa\praa_statics\poles\pole3m0.p3d",
        "praa\praa_statics\poles\pole5m0.p3d",
        "praa\praa_statics\poles\pole6m0.p3d",
        "praa\praa_statics\poles\pole7m0.p3d",
        "praa\praa_statics\poles\pole8m0.p3d",
        "praa\praa_statics\poles\stake2m.p3d",
        "praa\praa_statics\ramps\woodenramp1x3m90.p3d",
        "praa\praa_statics\steps\sidewalk.p3d",
        "praa\praa_statics\steps\stairs_timber_1_5x2m.p3d",
        "praa\praa_statics\steps\stairs_timber_1x2m.p3d",
        "praa\praa_statics\steps\stairs_timber_2x2m.p3d",
        "praa\praa_statics\steps\step1.p3d",
        "praa\praa_statics\steps\step2.p3d",
        "praa\praa_statics\steps\step3.p3d",
        "praa\praa_statics\steps\step4.p3d",
        "praa\praa_statics\walls\muro+webiao.p3d",
        "praa\praa_statics\walls\muro.p3d",
        "praa\praa_statics\walls\muroladrillo.p3d",
        "praa\praa_statics\walls\muropilar.p3d",
        "praa\praa_statics\walls\murorampa.p3d",
        "praa\praa_statics\walls\murowebiao.p3d",
        "praa\praa_statics\walls\muroypilar.p3d",
        "praa\praa_tunnels\cable_ground.p3d",
        "praa\praa_tunnels\cable_hanging.p3d",
        "praa\praa_tunnels\floor_sandy.p3d",
        "praa\praa_tunnels\wood_beam.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\budova4.p3d",
        "ca\buildings\budova5.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\misc_e\fort_watchtower_ep1.p3d",
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d",
        "ca\misc_e\tent_east_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_i_ep1.p3d",
        "ca\structures_e\mil\mil_barracks_l_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d",
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "praa\praa_buildings\qalat.p3d",
        "praa\praa_buildings\qfort.p3d",
        "praa\praa_statics\mil\c_bar1.p3d",
        "praa\praa_statics\mil\hesco2.p3d",
        "praa\praa_statics\mil\hesco3.p3d",
        "praa\praa_statics\mil\hesco4.p3d",
        "praa\praa_statics\mil\hesco_pillbox.p3d",
        "praa\praa_tunnels\poster2.p3d",
        "praa\praa_tunnels\poster4.p3d",
        "praa\praa_tunnels\tunnel_large_bend.p3d",
        "praa\praa_tunnels\tunnel_large_room_1door.p3d",
        "praa\praa_tunnels\tunnel_large_room_2doors.p3d",
        "praa\praa_tunnels\tunnel_large_room_4doors.p3d",
        "praa\praa_tunnels\tunnel_large_s_bend.p3d",
        "praa\praa_tunnels\tunnel_small_bend.p3d",
        "praa\praa_tunnels\tunnel_small_long_deadend.p3d",
        "praa\praa_tunnels\tunnel_small_ramp.p3d",
        "praa\praa_tunnels\tunnel_small_t_junction.p3d",
        "praa\praa_tunnels\wood_beams.p3d",
        "praa\praa_tunnels\wood_beams_h.p3d",
        "praa\praa_tunnels\wood_beams_h_join.p3d",
        "praa\praa_tunnels\wood_beams_h_sloped.p3d",
        "praa\praa_tunnels\wood_beams_t.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "praa\praa_tunnels\tunnel_large_bend.p3d",
        "praa\praa_tunnels\tunnel_large_room_1door.p3d",
        "praa\praa_tunnels\tunnel_large_room_2doors.p3d",
        "praa\praa_tunnels\tunnel_large_room_4doors.p3d",
        "praa\praa_tunnels\tunnel_large_s_bend.p3d",
        "praa\praa_tunnels\tunnel_small_ramp.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures_e\mil\mil_house_ep1.p3d",
        "praa\praa_buildings\qalat.p3d",
        "praa\praa_tunnels\tunnel_large_room_1door.p3d",
        "praa\praa_tunnels\tunnel_large_room_2doors.p3d",
        "praa\praa_tunnels\tunnel_large_room_4doors.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc_e\fortified_nest_big_ep1.p3d",
        "ca\misc_e\fortified_nest_small_ep1.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\ruins\hut06_ruins.p3d",
        "ca\buildings\ruins\hut_old02_ruins.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ruins_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ruins_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_dam_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
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
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
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
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
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
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\structures_e\misc\misc_powerline\powlinea_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlines_transformer1_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\structures_e\misc\com_tower_ep1.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_end_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d",
        "ca\structures_pmc\ind\fuelstation\fuelstation_shed_pmc.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings\misc\leseni2x.p3d",
        "ca\buildings\misc\leseni4x.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_part2_ep1.p3d"
    ];

};

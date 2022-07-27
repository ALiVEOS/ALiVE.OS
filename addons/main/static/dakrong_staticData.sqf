private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: dakrong"] call ALiVE_fnc_dump;

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

if(tolower(_worldName) == "dakrong") then {

    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "csj_seaobj\csj_rockgod.p3d",
        "raz_nam_obj\clutter\cluttercutter.p3d",
        "raz_nam_obj\clutter\cluttercutterbig.p3d",
        "raz_nam_obj\m\aboxes\usvehicleammo.p3d",
        "raz_nam_obj\m\antenna\antenna.p3d",
        "raz_nam_obj\m\bag_wall\abox_2.p3d",
        "raz_nam_obj\m\bag_wall\abox_4.p3d",
        "raz_nam_obj\m\bag_wall\abox_n_4.p3d",
        "raz_nam_obj\m\bag_wall\bagfencecorner.p3d",
        "raz_nam_obj\m\bag_wall\bagfenceend.p3d",
        "raz_nam_obj\m\cong_cage\congcage.p3d",
        "raz_nam_obj\m\cot\cot_vc.p3d",
        "raz_nam_obj\m\crater\crater.p3d",
        "raz_nam_obj\m\fence\w_fence_small.p3d",
        "raz_nam_obj\m\flags\flag_nva.p3d",
        "raz_nam_obj\m\hut\raz_stairs.p3d",
        "raz_nam_obj\m\map\flag.p3d",
        "raz_nam_obj\m\map\map.p3d",
        "raz_nam_obj\m\map\map_ao.p3d",
        "raz_nam_obj\m\map\map_nam.p3d",
        "raz_nam_obj\m\map\map_op.p3d",
        "raz_nam_obj\m\misc\misc_fallenspruce.p3d",
        "raz_nam_obj\m\misc\misc_trunk_water.p3d",
        "raz_nam_obj\m\paddy\paddy_1.p3d",
        "raz_nam_obj\m\paddy\paddy_2.p3d",
        "raz_nam_obj\m\pier\pier1_clutter.p3d",
        "raz_nam_obj\m\pier\pier1_tyres.p3d",
        "raz_nam_obj\m\radio\radio.p3d",
        "raz_nam_obj\m\water_pipe\water_pipe.p3d",
        "raz_nam_obj\m\well\vill_well.p3d",
        "raz_nam_obj\m\wood_floor\wood_floor.p3d",
        "raz_nam_obj\m\wood_floor\wood_floor_b.p3d",
        "raz_nam_obj\m\wood_tower\vil_tower.p3d",
        "raz_nam_obj\m\wood_tower\wood_tower.p3d",
        "raz_nam_obj\m\wood_tower\wood_tower2.p3d",
        "raz_nam_obj\m\wrecks\uh1wreck.p3d",
        "raz_nam_obj\m\wrecks\uh1wreckinv.p3d",
        "uns_a1j\uns_a1j_wreck.p3d",
        "uns_a4\skyhawk_wreck.p3d",
        "uns_a6\uns_a6_wreck.p3d",
        "uns_a7\uns_a7_wreck.p3d",
        "uns_ah1g\uns_ah1g_wreck.p3d",
        "uns_buildings\civilian_objects\fish_trap.p3d",
        "uns_buildings\civilian_objects\ganh_hang_rong.p3d",
        "uns_buildings\civilian_objects\pen_sty.p3d",
        "uns_buildings\civilian_objects\pen_sty2.p3d",
        "uns_buildings\civilian_objects\plough.p3d",
        "uns_buildings\civilian_objects\rice_plough.p3d",
        "uns_buildings\civilian_objects\uns_crate_old.p3d",
        "uns_buildings\civilian_objects\uns_crate_old2.p3d",
        "uns_buildings\civilian_objects\uns_skull_con.p3d",
        "uns_buildings\civilian_objects\uns_skull_gi.p3d",
        "uns_buildings\east_objects\nva_60mmbox_2.p3d",
        "uns_buildings\east_objects\nva_ammobox.p3d",
        "uns_buildings\west_objects\105_projectile_stack.p3d",
        "uns_buildings\west_objects\105_shell_crates.p3d",
        "uns_buildings\west_objects\105_shell_stack.p3d",
        "uns_buildings\west_objects\csj_bunk.p3d",
        "uns_buildings\west_objects\csj_centerfold.p3d",
        "uns_buildings\west_objects\csj_footlocker.p3d",
        "uns_buildings\west_objects\csj_gunpit.p3d",
        "uns_buildings\west_objects\csj_locker.p3d",
        "uns_buildings\west_objects\csj_lspkr.p3d",
        "uns_buildings\west_objects\csj_poster.p3d",
        "uns_buildings\west_objects\mortarshellsbox.p3d",
        "uns_buildings\west_objects\revetment_5.p3d",
        "uns_buildings\west_objects\sb_revetment.p3d",
        "uns_buildings\west_objects\sboard.p3d",
        "uns_buildings\west_objects\t_sb_20_half.p3d",
        "uns_buildings\west_objects\t_sb_45.p3d",
        "uns_buildings\west_objects\t_sb_45_half.p3d",
        "uns_buildings\west_objects\t_sb_5_covered.p3d",
        "uns_buildings\west_objects\t_sb_5_half.p3d",
        "uns_buildings\west_objects\t_sb_cross_half.p3d",
        "uns_buildings\west_objects\t_sb_end.p3d",
        "uns_buildings\west_objects\t_sb_pit1.p3d",
        "uns_buildings\west_objects\t_sb_pit2.p3d",
        "uns_buildings\west_objects\t_sb_tee.p3d",
        "uns_buildings\west_objects\table.p3d",
        "uns_buildings\west_objects\uns_clipboard.p3d",
        "uns_buildings\west_objects\uns_clipboard_confid.p3d",
        "uns_buildings\west_objects\uns_clipboard_papers.p3d",
        "uns_buildings\west_objects\uns_evac_pad.p3d",
        "uns_buildings\west_objects\uns_lantern.p3d",
        "uns_ch47a\proxy\uns_ch47a_wreck.p3d",
        "uns_f100\uns_f100_wreck.p3d",
        "uns_firebase\uns_beer1.p3d",
        "uns_firebase\uns_cabinet1.p3d",
        "uns_firebase\uns_generator1.p3d",
        "uns_firebase\uns_medical1.p3d",
        "uns_firebase\uns_water1.p3d",
        "uns_firebase\uns_water2.p3d",
        "uns_village\basket\uns_ricebasket1.p3d",
        "uns_village\basket\uns_ricebasket2.p3d",
        "uns_village\bridge\uns_villbridge1.p3d",
        "uns_village\misc\uns_hut1.p3d",
        "uns_village\misc\uns_ricebowl1.p3d",
        "wx_objects\flag_us01.p3d",
        "wx_objects\wx_baileybridge_01.p3d",
        "wx_objects\wx_bunker_roof01.p3d",
        "wx_objects\wx_defenceposition_01.p3d",
        "wx_objects\wx_logbunker01.p3d",
        "wx_objects\wx_logbunker02.p3d",
        "wx_objects\wx_radio.p3d",
        "wx_objects\wx_sakebottle.p3d",
        "wx_objects\wx_trench02.p3d",
        "wx_objects\wx_woodencrate.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagfence_01_long_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",
        "raz_nam_obj\m\helipad\heli_h.p3d",
        "raz_nam_obj\m\helipad\heli_h2.p3d",
        "raz_nam_obj\m\razorwire\razorwire.p3d",
        "raz_nam_obj\m\tent\tent_east.p3d",
        "raz_nam_obj\m\tent\tent_east_m.p3d",
        "raz_nam_obj\m\tent\tent_east_o.p3d",
        "raz_nam_obj\m\tunnel\cage_wall.p3d",
        "raz_nam_obj\m\tunnel\tunnel_1.p3d",
        "raz_nam_obj\m\tunnel\tunnel_2.p3d",
        "raz_nam_obj\m\tunnel\tunnel_4.p3d",
        "raz_nam_obj\m\tunnel\tunnel_6.p3d",
        "raz_nam_obj\m\tunnel\tunnel_6a.p3d",
        "raz_nam_obj\m\tunnel\tunnel_roof.p3d",
        "raz_nam_obj\m\tunnel\tunnel_sup_1.p3d",
        "raz_nam_obj\m\tunnel\tunnel_sup_2.p3d",
        "raz_nam_obj\m\tunnel\tunnel_sup_2a.p3d",
        "raz_nam_obj\m\tunnel\tunnel_sup_2b.p3d",
        "raz_nam_obj\m\tunnel\tunnel_sup_3.p3d",
        "raz_nam_obj\m\tunnel\tunnel_sup_4.p3d",
        "raz_nam_obj\m\tunnel\tunnel_sup_5.p3d",
        "raz_nam_obj\m\tunnel\tunnel_wall.p3d",
        "uns_buildings\west_buildings\csjpet8_pump.p3d",
        "uns_buildings\west_buildings\mortarpit_sb.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_main02.p3d",
        "uns_buildings\west_buildings\tarp_1.p3d",
        "uns_buildings\west_buildings\uns_army_med.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop2.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop3.p3d",
        "uns_buildings\west_buildings\uns_congcage.p3d",
        "uns_buildings\west_buildings\uns_guardhouse.p3d",
        "uns_buildings\west_buildings\uns_hootch.p3d",
        "uns_buildings\west_buildings\uns_hootche.p3d",
        "uns_buildings\west_buildings\uns_hootche1.p3d",
        "uns_buildings\west_buildings\uns_latrine.p3d",
        "uns_buildings\west_buildings\uns_om.p3d",
        "uns_buildings\west_buildings\uns_showers.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["uns_buildings\west_buildings\uns_hootche1.p3d","uns_buildings\west_buildings\uns_army_med.p3d","uns_buildings\west_buildings\uns_bunker_troop.p3d","uns_buildings\west_buildings\uns_hootche.p3d","uns_buildings\west_buildings\uns_guardhouse.p3d","a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d","a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d","uns_buildings\west_buildings\sb_bunker_main.p3d","uns_buildings\west_buildings\sb_bunker_main02.p3d","a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d","raz_nam_obj\m\tent\tent_east.p3d","raz_nam_obj\m\tent\tent_east_m.p3d","raz_nam_obj\m\tent\tent_east_o.p3d"];
    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["uns_buildings\west_buildings\uns_hootche1.p3d","uns_buildings\west_buildings\uns_army_med.p3d","a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d","a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d","uns_buildings\west_buildings\sb_bunker_main.p3d","uns_buildings\west_buildings\sb_bunker_main02.p3d","a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d","a3\structures_f_exp\military\fortifications\bagbunker_01_small_green_f.p3d","a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d","raz_nam_obj\m\tent\tent_east.p3d","raz_nam_obj\m\tent\tent_east_m.p3d","raz_nam_obj\m\tent\tent_east_o.p3d","uns_buildings\west_objects\sb_revetment.p3d","uns_buildings\west_buildings\tarp_1.p3d","wx_objects\wx_defenceposition_01.p3d"];
    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];
    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["raz_nam_obj\m\helipad\heli_h.p3d","raz_nam_obj\m\helipad\heli_h2.p3d","a3\structures_f\mil\helipads\helipadempty_f.p3d"];
    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["raz_nam_obj\m\helipad\heli_h.p3d","raz_nam_obj\m\helipad\heli_h2.p3d","a3\structures_f\mil\helipads\helipadempty_f.p3d"];
    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_pile_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_platform_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_4m_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_8m_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_d_left_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_d_right_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_gate_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "indo_building\indo_hut_1.p3d",
        "indo_building\indo_hut_2.p3d",
        "raz_nam_obj\m\bridge\mbg_footbridge_40m.p3d",
        "raz_nam_obj\m\bridge\sbridge.p3d",
        "raz_nam_obj\m\hut\raz_hut01.p3d",
        "raz_nam_obj\m\hut\raz_hut02.p3d",
        "raz_nam_obj\m\hut\raz_hut03.p3d",
        "raz_nam_obj\m\hut\raz_hut04.p3d",
        "raz_nam_obj\m\hut\raz_hut05.p3d",
        "raz_nam_obj\m\hut\raz_hut06.p3d",
        "raz_nam_obj\m\hut\raz_hut07.p3d",
        "raz_nam_obj\m\hut\raz_hut08.p3d",
        "uns_buildings\civilian_buildings\csj_hut01.p3d",
        "uns_buildings\civilian_buildings\csj_hut02.p3d",
        "uns_buildings\civilian_buildings\csj_hut05.p3d",
        "uns_buildings\civilian_buildings\csj_hut07.p3d",
        "uns_buildings\civilian_buildings\uns_hut08.p3d",
        "uns_buildings\civilian_buildings\uns_leanto1.p3d",
        "uns_buildings\civilian_buildings\uns_leanto2.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "uns_buildings\civilian_buildings\csj_hut01.p3d",
        "uns_buildings\civilian_buildings\csj_hut02.p3d",
        "uns_buildings\civilian_buildings\csj_hut05.p3d",
        "uns_buildings\civilian_buildings\csj_hut07.p3d",
        "uns_buildings\civilian_buildings\uns_hut08.p3d",
        "uns_buildings\civilian_buildings\uns_leanto1.p3d",
        "uns_buildings\civilian_buildings\uns_leanto2.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_pile_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_platform_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_4m_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_8m_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_d_left_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_d_right_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_gate_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "indo_building\indo_hut_1.p3d",
        "indo_building\indo_hut_2.p3d",
        "raz_nam_obj\m\bridge\mbg_footbridge_40m.p3d",
        "raz_nam_obj\m\bridge\sbridge.p3d",
        "raz_nam_obj\m\hut\raz_hut01.p3d",
        "raz_nam_obj\m\hut\raz_hut02.p3d",
        "raz_nam_obj\m\hut\raz_hut03.p3d",
        "raz_nam_obj\m\hut\raz_hut04.p3d",
        "raz_nam_obj\m\hut\raz_hut05.p3d",
        "raz_nam_obj\m\hut\raz_hut06.p3d",
        "raz_nam_obj\m\hut\raz_hut07.p3d",
        "raz_nam_obj\m\hut\raz_hut08.p3d",
        "uns_buildings\civilian_buildings\csj_hut01.p3d",
        "uns_buildings\civilian_buildings\csj_hut02.p3d",
        "uns_buildings\civilian_buildings\csj_hut05.p3d",
        "uns_buildings\civilian_buildings\csj_hut07.p3d",
        "uns_buildings\civilian_buildings\uns_hut08.p3d",
        "uns_buildings\civilian_buildings\uns_leanto1.p3d",
        "uns_buildings\civilian_buildings\uns_leanto2.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [];
    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];
    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["raz_nam_obj\m\pier\pier2.p3d","raz_nam_obj\m\pier\pier2.p3d"];
    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [];
    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [];
};
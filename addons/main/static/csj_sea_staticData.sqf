// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: csj_sea (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-06", "web", true];

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

ALiVE_mapCompositionType = "Pacific";

 if (tolower(_worldName) == "csj_sea") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "csj_heli\w\csj_ah1_g_cobra_wrk.p3d",
        "csj_heli\w\csj_c_wrk.p3d",
        "csj_heli\w\csj_oh6wrk.p3d",
        "csj_heli\w\csj_uh1_d2_wrk.p3d",
        "csj_heli\w\csj_uh1_d_wrk.p3d",
        "csj_roads\csj_bridge1.p3d",
        "csj_roads\csj_bridge2.p3d",
        "csj_roads\csj_ces25.p3d",
        "csj_roads\csj_ces6.p3d",
        "csj_roads\csj_ces6konec.p3d",
        "csj_seaobj\csj_culvert.p3d",
        "csj_village\csj_bridge1.p3d",
        "csj_village\csj_bridge2.p3d",
        "uc\misc\empty.p3d",
        "uns_buildings\civilian_objects\baskete.p3d",
        "uns_buildings\civilian_objects\cabinet.p3d",
        "uns_buildings\civilian_objects\crop_earth.p3d",
        "uns_buildings\civilian_objects\csj_pot.p3d",
        "uns_buildings\civilian_objects\csj_pot2.p3d",
        "uns_buildings\civilian_objects\csj_pot3.p3d",
        "uns_buildings\civilian_objects\csjcartempty.p3d",
        "uns_buildings\civilian_objects\drum_rusty.p3d",
        "uns_buildings\civilian_objects\fish_trap.p3d",
        "uns_buildings\civilian_objects\pen_sty.p3d",
        "uns_buildings\civilian_objects\pen_sty2.p3d",
        "uns_buildings\civilian_objects\plough.p3d",
        "uns_buildings\civilian_objects\sack.p3d",
        "uns_buildings\civilian_objects\small_pot.p3d",
        "uns_buildings\civilian_objects\table_small.p3d",
        "uns_buildings\civilian_objects\tool_1.p3d",
        "uns_buildings\civilian_objects\tool_2.p3d",
        "uns_buildings\civilian_objects\tool_3.p3d",
        "uns_buildings\civilian_objects\uns_candle.p3d",
        "uns_buildings\civilian_objects\uns_conical.p3d",
        "uns_buildings\civilian_objects\uns_crate_old.p3d",
        "uns_buildings\civilian_objects\uns_crate_old2.p3d",
        "uns_buildings\civilian_objects\uns_pot_incense.p3d",
        "uns_buildings\civilian_objects\uns_veg_garden.p3d",
        "uns_buildings\civilian_objects\washing.p3d",
        "uns_buildings\civilian_objects\wok_pan.p3d",
        "uns_buildings\uns_fence\uns_fence01.p3d",
        "uns_buildings\uns_fence\uns_fence02.p3d",
        "uns_buildings\west_objects\105_shell_crate.p3d",
        "uns_buildings\west_objects\105_shell_crates.p3d",
        "uns_buildings\west_objects\csj_lspkr.p3d",
        "uns_buildings\west_objects\csj_punji.p3d",
        "uns_buildings\west_objects\csjjcan.p3d",
        "uns_buildings\west_objects\gbage.p3d",
        "uns_buildings\west_objects\p_wire1.p3d",
        "uns_buildings\west_objects\p_wire1a.p3d",
        "uns_buildings\west_objects\p_wire2.p3d",
        "uns_buildings\west_objects\revetment_5.p3d",
        "uns_buildings\west_objects\sboard.p3d",
        "uns_buildings\west_objects\uns_sandbag.p3d",
        "uns_buildings\west_objects\uns_sandbag_detail.p3d",
        "uns_village\basket\uns_ricebasket2.p3d",
        "uns_village\fence\uns_fence5.p3d",
        "uns_village\misc\uns_barrel.p3d",
        "uns_village\misc\uns_barrel_side.p3d",
        "uns_village\misc\uns_haystack1.p3d",
        "uns_village\pot\uns_pot1.p3d",
        "uns_village\pot\uns_pot2.p3d",
        "uns_village\table\uns_bench2.p3d",
        "uns_village\table\uns_seat1.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "uc\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "uns_buildings\west_buildings\csj_fueldepot.p3d",
        "uns_buildings\west_buildings\csjpet8_pump.p3d",
        "uns_buildings\west_buildings\fort2.p3d",
        "uns_buildings\west_buildings\mortarpit_sb.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_main02.p3d",
        "uns_buildings\west_buildings\sb_bunker_small.p3d",
        "uns_buildings\west_buildings\scntr_open.p3d",
        "uns_buildings\west_buildings\t_2_fop2.p3d",
        "uns_buildings\west_buildings\tarp_1.p3d",
        "uns_buildings\west_buildings\tower_1.p3d",
        "uns_buildings\west_buildings\uns_army_med.p3d",
        "uns_buildings\west_buildings\uns_armyhut2.p3d",
        "uns_buildings\west_buildings\uns_armyhut3.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop2.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop3.p3d",
        "uns_buildings\west_buildings\uns_congcage.p3d",
        "uns_buildings\west_buildings\uns_guardhouse.p3d",
        "uns_buildings\west_buildings\uns_hanger1.p3d",
        "uns_buildings\west_buildings\uns_hootch.p3d",
        "uns_buildings\west_buildings\uns_hootche.p3d",
        "uns_buildings\west_buildings\uns_hootche1.p3d",
        "uns_buildings\west_buildings\uns_latrine.p3d",
        "uns_buildings\west_buildings\uns_motorpool1.p3d",
        "uns_buildings\west_buildings\uns_om.p3d",
        "uns_buildings\west_buildings\uns_showers.p3d",
        "uns_buildings\west_buildings\uns_weapon_pit.p3d",
        "uns_buildings\west_objects\csj_gunpit.p3d",
        "uns_buildings\west_objects\csj_walkplanks.p3d",
        "uns_buildings\west_objects\csj_walkway.p3d",
        "uns_buildings\west_objects\sb_revetment.p3d",
        "uns_buildings\west_objects\scntr.p3d",
        "uns_buildings\west_objects\t_sb_20_half.p3d",
        "uns_buildings\west_objects\t_sb_45.p3d",
        "uns_buildings\west_objects\t_sb_45_half.p3d",
        "uns_buildings\west_objects\t_sb_5.p3d",
        "uns_buildings\west_objects\t_sb_5_half.p3d",
        "uns_buildings\west_objects\t_sb_cnr_half.p3d",
        "uns_buildings\west_objects\t_sb_cross.p3d",
        "uns_buildings\west_objects\t_sb_pit1.p3d",
        "uns_buildings\west_objects\t_sb_pit2.p3d",
        "uns_buildings\west_objects\t_sb_pit3.p3d",
        "uns_buildings\west_objects\t_sb_tee.p3d",
        "uns_village\misc\uns_vcplatform.p3d",
        "uns_village\platform\uns_platform1shelter1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "uns_buildings\west_buildings\uns_motorpool1.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "uc\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "uns_buildings\west_buildings\fort2.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_main02.p3d",
        "uns_buildings\west_buildings\tarp_1.p3d",
        "uns_buildings\west_buildings\uns_army_med.p3d",
        "uns_buildings\west_buildings\uns_hanger1.p3d",
        "uns_buildings\west_buildings\uns_hootche1.p3d",
        "uns_buildings\west_buildings\uns_motorpool1.p3d",
        "uns_buildings\west_objects\csj_gunpit.p3d",
        "uns_buildings\west_objects\sb_revetment.p3d",
        "uns_village\misc\uns_vcplatform.p3d",
        "uns_village\platform\uns_platform1shelter1.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "uns_buildings\west_buildings\fort2.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_main02.p3d",
        "uns_buildings\west_buildings\uns_army_med.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop.p3d",
        "uns_buildings\west_buildings\uns_guardhouse.p3d",
        "uns_buildings\west_buildings\uns_hootche.p3d",
        "uns_buildings\west_buildings\uns_hootche1.p3d",
        "uns_buildings\west_buildings\uns_motorpool1.p3d",
        "uns_buildings\west_buildings\uns_om.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_small.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop2.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop3.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "uns_buildings\west_objects\uns_evac_pad.p3d",
        "uns_buildings\west_objects\uns_heli_pad.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "uns_buildings\west_objects\uns_evac_pad.p3d",
        "uns_buildings\west_objects\uns_heli_pad.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "csj_seaobj\csj_shelter01.p3d",
        "csj_seaobj\csj_temple1.p3d",
        "csj_village\csj_pagoda.p3d",
        "csj_village\csj_pagoda2.p3d",
        "csj_village\csj_village1.p3d",
        "csj_village\csj_village2.p3d",
        "csj_village\csj_village3.p3d",
        "csj_village\csj_village4.p3d",
        "csj_village\csj_village5.p3d",
        "csj_village\csj_village6.p3d",
        "csj_village\csj_village7.p3d",
        "csj_village\csj_yard1.p3d",
        "csj_village\csj_yard2.p3d",
        "csj_village\csj_yard3.p3d",
        "csj_village\csj_yard4.p3d",
        "csj_village\csj_yard5.p3d",
        "csj_village\csj_yard_pen1.p3d",
        "uc\buildings2\farm_cowshed\farm_cowshed_a_dam.p3d",
        "uc\buildings2\farm_cowshed\farm_cowshed_b_ruins.p3d",
        "uc\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "uc\buildings2\ind_garage01\ind_garage01.p3d",
        "uc\buildings2\ind_garage01\ind_garage01_ruins.p3d",
        "uc\buildings2\shed_small\shed_m01.p3d",
        "uc\buildings2\shed_small\shed_m01_ruins.p3d",
        "uc\buildings2\shed_small\shed_m03.p3d",
        "uc\buildings2\shed_small\shed_m03_ruins.p3d",
        "uc\buildings2\shed_small\shed_w01.p3d",
        "uc\buildings2\shed_small\shed_w01_ruins.p3d",
        "uc\buildings2\shed_small\shed_w02.p3d",
        "uc\buildings2\shed_small\shed_w03.p3d",
        "uc\buildings2\shed_small\shed_w03_ruins.p3d",
        "uc\buildings2\shed_wooden\shed_wooden.p3d",
        "uc\buildings2\shed_wooden\shed_wooden_ruins.p3d",
        "uc\buildings\kulna.p3d",
        "uc\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "uns_buildings\civilian_buildings\csj_bar.p3d",
        "uns_buildings\civilian_buildings\csj_hut01.p3d",
        "uns_buildings\civilian_buildings\csj_hut02.p3d",
        "uns_buildings\civilian_buildings\csj_hut05.p3d",
        "uns_buildings\civilian_buildings\csj_hut06.p3d",
        "uns_buildings\civilian_buildings\csj_hut07.p3d",
        "uns_buildings\civilian_buildings\uns_hut08.p3d",
        "uns_buildings\civilian_buildings\uns_leanto1.p3d",
        "uns_buildings\civilian_buildings\uns_leanto2.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_01.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_02.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_03.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_04.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_05.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_06.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_07.p3d",
        "uns_buildings\civilian_objects\paddy_sect01.p3d",
        "uns_buildings\civilian_objects\paddy_sect03.p3d",
        "uns_buildings\civilian_objects\paddy_sect04.p3d",
        "uns_village\misc\uns_vcplatform.p3d",
        "uns_village\platform\uns_platform1shelter1.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "csj_seaobj\csj_temple1.p3d",
        "csj_village\csj_pagoda.p3d",
        "csj_village\csj_village1.p3d",
        "csj_village\csj_village2.p3d",
        "csj_village\csj_village3.p3d",
        "csj_village\csj_village4.p3d",
        "csj_village\csj_village5.p3d",
        "csj_village\csj_village6.p3d",
        "csj_village\csj_village7.p3d",
        "csj_village\csj_yard1.p3d",
        "csj_village\csj_yard2.p3d",
        "csj_village\csj_yard3.p3d",
        "csj_village\csj_yard5.p3d",
        "csj_village\csj_yard_pen1.p3d",
        "uc\buildings2\farm_cowshed\farm_cowshed_a_dam.p3d",
        "uc\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "uns_buildings\civilian_buildings\csj_hut01.p3d",
        "uns_buildings\civilian_buildings\csj_hut02.p3d",
        "uns_buildings\civilian_buildings\csj_hut05.p3d",
        "uns_buildings\civilian_buildings\csj_hut06.p3d",
        "uns_buildings\civilian_buildings\csj_hut07.p3d",
        "uns_buildings\civilian_buildings\uns_hut08.p3d",
        "uns_buildings\civilian_buildings\uns_leanto2.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "csj_seaobj\csj_temple1.p3d",
        "csj_village\csj_pagoda.p3d",
        "csj_village\csj_pagoda2.p3d",
        "csj_village\csj_village1.p3d",
        "csj_village\csj_village2.p3d",
        "csj_village\csj_village3.p3d",
        "csj_village\csj_village4.p3d",
        "csj_village\csj_village5.p3d",
        "csj_village\csj_village6.p3d",
        "csj_village\csj_village7.p3d",
        "csj_village\csj_yard1.p3d",
        "csj_village\csj_yard2.p3d",
        "csj_village\csj_yard3.p3d",
        "csj_village\csj_yard4.p3d",
        "csj_village\csj_yard5.p3d",
        "csj_village\csj_yard_pen1.p3d",
        "uc\buildings2\farm_cowshed\farm_cowshed_a_dam.p3d",
        "uc\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "uc\buildings2\ind_garage01\ind_garage01.p3d",
        "uc\buildings2\shed_small\shed_w01.p3d",
        "uc\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "uns_buildings\civilian_buildings\csj_bar.p3d",
        "uns_buildings\civilian_buildings\csj_hut01.p3d",
        "uns_buildings\civilian_buildings\csj_hut02.p3d",
        "uns_buildings\civilian_buildings\csj_hut05.p3d",
        "uns_buildings\civilian_buildings\csj_hut06.p3d",
        "uns_buildings\civilian_buildings\csj_hut07.p3d",
        "uns_buildings\civilian_buildings\uns_hut08.p3d",
        "uns_buildings\civilian_buildings\uns_leanto2.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_01.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_02.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_03.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_04.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_05.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_07.p3d",
        "uns_buildings\civilian_objects\paddy_sect01.p3d",
        "uns_buildings\civilian_objects\paddy_sect03.p3d",
        "uns_buildings\civilian_objects\paddy_sect04.p3d",
        "uns_village\misc\uns_vcplatform.p3d",
        "uns_village\platform\uns_platform1shelter1.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "csj_village\csj_riverhut1.p3d",
        "csj_village\csj_riverhut2.p3d",
        "csj_village\csj_riverhut3.p3d",
        "csj_village\csj_riverhut4.p3d",
        "uc\structures\nav_boathouse\nav_boathouse.p3d",
        "uc\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "uc\structures\nav_boathouse\nav_boathouse_piert.p3d",
        "uns_village\bridge\uns_dock1.p3d",
        "uns_village\platform\uns_platform1.p3d",
        "uns_village\platform\uns_platform1shelter1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "uns_village\platform\uns_platform1shelter1.p3d"
    ];

};

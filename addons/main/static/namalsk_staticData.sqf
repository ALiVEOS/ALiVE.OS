// ALiVE 3 index v3.1, made 2026-11-16 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: namalsk (ALiVE 3 index v3.1, 2026-11-16)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-16", "web", true];

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

ALiVE_mapCompositionType = "Woodland";
[ALIVE_mapBounds, worldName, 12800] call ALIVE_fnc_hashSet;

 if (tolower(_worldName) == "namalsk") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "nst\ns_a2\bagfencecorner.p3d",
        "nst\ns_a2\komin.p3d",
        "nst\ns_a2\light_kitchen_03.p3d",
        "nst\ns_a2\misc_trunk_water.p3d",
        "nst\ns_a2\shed_m02.p3d",
        "nst\ns_structures\bm_container.p3d",
        "nst\ns_structures\dulni_box.p3d",
        "nst\ns_structures\fence2.p3d",
        "nst\ns_structures\hlidac.p3d",
        "nst\ns_structures\kamaz_zniceny.p3d",
        "nst\ns_structures\most_blok.p3d",
        "nst\ns_structures\most_prehrada.p3d",
        "nst\ns_structures\najezd.p3d",
        "nst\ns_structures\nam_container.p3d",
        "nst\ns_structures\ob.p3d",
        "nst\ns_structures\ob_panylek.p3d",
        "nst\ns_structures\s_mines.p3d",
        "nst\ns_structures\seb_mine_near_bordel.p3d",
        "nst\ns_structures\seb_trubice_beton.p3d",
        "nst\ns_structures\traktor.p3d",
        "nst\ns_structures\vys_draty.p3d",
        "nst\ns_structures\vys_draty3.p3d",
        "nst\ns_structures\wall_fence_prov.p3d",
        "nst\ns_structures\zed_dlouha.p3d",
        "nst\ns_structures\zed_dlouha_bezost.p3d",
        "nst\ns_structures\zed_dlouha_zzima.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "nst\ns_a2\budova4_ruins.p3d",
        "nst\ns_a2\camonet_east.p3d",
        "nst\ns_a2\hlidac_budka.p3d",
        "nst\ns_a2\mil_barracks_i.p3d",
        "nst\ns_a2\mil_barracks_l.p3d",
        "nst\ns_a2\repair_center.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_barracks.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_controltower.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_guardhouse.p3d",
        "nst\ns_jbad\winter\ns_jbad_mil_guardhouse_winter.p3d",
        "nst\ns_structures\ai_entrance.p3d",
        "nst\ns_structures\aii_entrance.p3d",
        "nst\ns_structures\aii_middle_floor.p3d",
        "nst\ns_structures\aii_upper_part.p3d",
        "nst\ns_structures\budova1_winter.p3d",
        "nst\ns_structures\budova4_winter.p3d",
        "nst\ns_structures\hlaska.p3d",
        "nst\ns_structures\tanl_entrance.p3d",
        "nst\ns_structures\tanl_entrance_n.p3d",
        "nst\ns_structures\vys_budova_p1.p3d",
        "nst\ns_structures\x_skladiste_low_tex.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "nst\ns_a2\mil_barracks_l.p3d",
        "nst\ns_a2\repair_center.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_barracks.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "nst\ns_a2\camonet_east.p3d",
        "nst\ns_a2\mil_barracks_i.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_barracks.p3d",
        "nst\ns_structures\aii_upper_part.p3d",
        "nst\ns_structures\budova1_winter.p3d",
        "nst\ns_structures\x_skladiste_low_tex.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "nst\ns_a2\mil_barracks_i.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_barracks.p3d",
        "nst\ns_structures\aii_middle_floor.p3d",
        "nst\ns_structures\vys_budova_p1.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "nst\ns_jbad\ind\hangar_2\ns_jbad_hangar_2.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_controltower.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "nst\ns_jbad\mil\ns_jbad_mil_controltower.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "nst\ns_jbad\ind\hangar_2\ns_jbad_hangar_2.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "nst\ns_a2\heli_h_army.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "nst\ns_a2\heli_h_army.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "nst\ns_a2\a_hospital\a_hospital.p3d",
        "nst\ns_a2\a_office01.p3d",
        "nst\ns_a2\a_office02\a_office02.p3d",
        "nst\ns_a2\barn_metal.p3d",
        "nst\ns_a2\barn_w_01.p3d",
        "nst\ns_a2\bouda2_vnitrek.p3d",
        "nst\ns_a2\c_grassdrylong.p3d",
        "nst\ns_a2\dulni_bs.p3d",
        "nst\ns_a2\dum_zboreny.p3d",
        "nst\ns_a2\dum_zboreny_total.p3d",
        "nst\ns_a2\farm_wtower.p3d",
        "nst\ns_a2\housev2_01b.p3d",
        "nst\ns_a2\housev2_03.p3d",
        "nst\ns_a2\housev2_04_interier.p3d",
        "nst\ns_a2\housev2_05.p3d",
        "nst\ns_a2\housev_1i1.p3d",
        "nst\ns_a2\housev_1i2.p3d",
        "nst\ns_a2\housev_1i4.p3d",
        "nst\ns_a2\housev_2t1.p3d",
        "nst\ns_a2\housev_2t2.p3d",
        "nst\ns_a2\housev_3i1.p3d",
        "nst\ns_a2\housev_3i2.p3d",
        "nst\ns_a2\housev_3i3.p3d",
        "nst\ns_a2\housev_3i4.p3d",
        "nst\ns_a2\hruzdum_ruins.p3d",
        "nst\ns_a2\hut06.p3d",
        "nst\ns_a2\ind_illuminanttower.p3d",
        "nst\ns_a2\ind_pec_03a.p3d",
        "nst\ns_a2\ind_quarry.p3d",
        "nst\ns_a2\ind_sawmill.p3d",
        "nst\ns_a2\ind_sawmillpen.p3d",
        "nst\ns_a2\ind_workshop01_01.p3d",
        "nst\ns_a2\ind_workshop01_02.p3d",
        "nst\ns_a2\ind_workshop01_03.p3d",
        "nst\ns_a2\ind_workshop01_04.p3d",
        "nst\ns_a2\kulna.p3d",
        "nst\ns_a2\misc_stub1.p3d",
        "nst\ns_a2\nav_pier_c2.p3d",
        "nst\ns_a2\r2_rock1.p3d",
        "nst\ns_a2\r2_rock2.p3d",
        "nst\ns_a2\r2_rocktower.p3d",
        "nst\ns_a2\r2_stone.p3d",
        "nst\ns_a2\sara_domek_ruina.p3d",
        "nst\ns_a2\shed_ind02.p3d",
        "nst\ns_a2\shed_w01.p3d",
        "nst\ns_a2\shed_w4.p3d",
        "nst\ns_a2\snow.p3d",
        "nst\ns_a2\statek_kulna.p3d",
        "nst\ns_jbad\a_stationhouse\ns_jbad_a_stationhouse.p3d",
        "nst\ns_jbad\generalstore\ns_jbad_a_generalstore_01.p3d",
        "nst\ns_jbad\ind\hangar_2\ns_jbad_hangar_2.p3d",
        "nst\ns_jbad\ind\ind_garage01\ns_jbad_ind_garage01.p3d",
        "nst\ns_jbad\mil\ns_jbad_mil_house.p3d",
        "nst\ns_structures\1.p3d",
        "nst\ns_structures\2.p3d",
        "nst\ns_structures\ai.p3d",
        "nst\ns_structures\aii_last_floor.p3d",
        "nst\ns_structures\antena_mala.p3d",
        "nst\ns_structures\antena_vetsi.p3d",
        "nst\ns_structures\b_small1.p3d",
        "nst\ns_structures\boyka.p3d",
        "nst\ns_structures\bspawn.p3d",
        "nst\ns_structures\bud2.p3d",
        "nst\ns_structures\budova1_norinsk.p3d",
        "nst\ns_structures\budova2_norinsk.p3d",
        "nst\ns_structures\budova2_winter.p3d",
        "nst\ns_structures\budova3.p3d",
        "nst\ns_structures\budova3_winter.p3d",
        "nst\ns_structures\bunka.p3d",
        "nst\ns_structures\cast1.p3d",
        "nst\ns_structures\cast2.p3d",
        "nst\ns_structures\chat_tr.p3d",
        "nst\ns_structures\dlouhy1.p3d",
        "nst\ns_structures\dlouhy3.p3d",
        "nst\ns_structures\domek_podhradi_1.p3d",
        "nst\ns_structures\dr_1.p3d",
        "nst\ns_structures\dr_2.p3d",
        "nst\ns_structures\dum_ras.p3d",
        "nst\ns_structures\espawn.p3d",
        "nst\ns_structures\f_b1.p3d",
        "nst\ns_structures\f_b2.p3d",
        "nst\ns_structures\fence21.p3d",
        "nst\ns_structures\fence22.p3d",
        "nst\ns_structures\fence23.p3d",
        "nst\ns_structures\fuelstation_w.p3d",
        "nst\ns_structures\garaze.p3d",
        "nst\ns_structures\hala1.p3d",
        "nst\ns_structures\heliport.p3d",
        "nst\ns_structures\hut_old01.p3d",
        "nst\ns_structures\in_skrin1.p3d",
        "nst\ns_structures\in_skrin2.p3d",
        "nst\ns_structures\in_sporak.p3d",
        "nst\ns_structures\in_zidle.p3d",
        "nst\ns_structures\jerab.p3d",
        "nst\ns_structures\jzd_4silka.p3d",
        "nst\ns_structures\jzd_bezstrechy.p3d",
        "nst\ns_structures\jzd_hala1.p3d",
        "nst\ns_structures\jzd_korytka.p3d",
        "nst\ns_structures\jzd_kr1.p3d",
        "nst\ns_structures\jzd_kr2.p3d",
        "nst\ns_structures\jzd_silo_tes.p3d",
        "nst\ns_structures\jzd_stodola1.p3d",
        "nst\ns_structures\jzd_stodola2.p3d",
        "nst\ns_structures\jzd_vodojem.p3d",
        "nst\ns_structures\kont1.p3d",
        "nst\ns_structures\kont2.p3d",
        "nst\ns_structures\kont3.p3d",
        "nst\ns_structures\kostelik_final_2122.p3d",
        "nst\ns_structures\kriz.p3d",
        "nst\ns_structures\kupa1.p3d",
        "nst\ns_structures\kupa2.p3d",
        "nst\ns_structures\kupa3.p3d",
        "nst\ns_structures\l_velkakupa.p3d",
        "nst\ns_structures\lodenice.p3d",
        "nst\ns_structures\marsh1.p3d",
        "nst\ns_structures\marsh2.p3d",
        "nst\ns_structures\megaa.p3d",
        "nst\ns_structures\molo.p3d",
        "nst\ns_structures\molo2.p3d",
        "nst\ns_structures\molovabud1.p3d",
        "nst\ns_structures\nadrazi_nastupiste.p3d",
        "nst\ns_structures\naklad.p3d",
        "nst\ns_structures\p1_v1.p3d",
        "nst\ns_structures\p1_v2.p3d",
        "nst\ns_structures\panelova2.p3d",
        "nst\ns_structures\panelova3.p3d",
        "nst\ns_structures\panely.p3d",
        "nst\ns_structures\panely_roz.p3d",
        "nst\ns_structures\panely_srov.p3d",
        "nst\ns_structures\panylek.p3d",
        "nst\ns_structures\part1.p3d",
        "nst\ns_structures\part2.p3d",
        "nst\ns_structures\part3.p3d",
        "nst\ns_structures\plynom.p3d",
        "nst\ns_structures\pozorovatelna.p3d",
        "nst\ns_structures\pres.p3d",
        "nst\ns_structures\prkna.p3d",
        "nst\ns_structures\prkna_nahoru.p3d",
        "nst\ns_structures\provoz1.p3d",
        "nst\ns_structures\provoz2.p3d",
        "nst\ns_structures\rozvodna.p3d",
        "nst\ns_structures\s_radiation.p3d",
        "nst\ns_structures\s_runway.p3d",
        "nst\ns_structures\s_vorkuta_b.p3d",
        "nst\ns_structures\s_vorkuta_e.p3d",
        "nst\ns_structures\seb_bouda1.p3d",
        "nst\ns_structures\seb_bouda3.p3d",
        "nst\ns_structures\seb_bouda_plech.p3d",
        "nst\ns_structures\seb_main_fac.p3d",
        "nst\ns_structures\seb_mine.p3d",
        "nst\ns_structures\seb_mine_maringotka.p3d",
        "nst\ns_structures\seb_mine_near.p3d",
        "nst\ns_structures\seb_nadrze.p3d",
        "nst\ns_structures\seb_near_fac.p3d",
        "nst\ns_structures\seb_residental.p3d",
        "nst\ns_structures\seb_rozvodna.p3d",
        "nst\ns_structures\seb_spadly_stozar.p3d",
        "nst\ns_structures\senik.p3d",
        "nst\ns_structures\seno_b.p3d",
        "nst\ns_structures\skl1.p3d",
        "nst\ns_structures\skl3.p3d",
        "nst\ns_structures\sklad2.p3d",
        "nst\ns_structures\stozar_vn1.p3d",
        "nst\ns_structures\stozar_vn1_spadly.p3d",
        "nst\ns_structures\syp_r.p3d",
        "nst\ns_structures\terain_base_a.p3d",
        "nst\ns_structures\terain_panely_kratke.p3d",
        "nst\ns_structures\terain_panely_slope.p3d",
        "nst\ns_structures\terain_velke_panely.p3d",
        "nst\ns_structures\tlampac.p3d",
        "nst\ns_structures\tovarna1.p3d",
        "nst\ns_structures\tr_horni.p3d",
        "nst\ns_structures\tr_konec.p3d",
        "nst\ns_structures\tr_nahoru.p3d",
        "nst\ns_structures\tr_rovne.p3d",
        "nst\ns_structures\tr_stojan.p3d",
        "nst\ns_structures\tr_zatacka.p3d",
        "nst\ns_structures\trubice.p3d",
        "nst\ns_structures\trubky1.p3d",
        "nst\ns_structures\trubky2.p3d",
        "nst\ns_structures\v_zed1_dlouha.p3d",
        "nst\ns_structures\v_zed1_nej.p3d",
        "nst\ns_structures\v_zed1_sloup.p3d",
        "nst\ns_structures\v_zed1_spadla.p3d",
        "nst\ns_structures\vag_masina.p3d",
        "nst\ns_structures\vag_polozeny.p3d",
        "nst\ns_structures\vag_zbozi1.p3d",
        "nst\ns_structures\velkakupa.p3d",
        "nst\ns_structures\vetrani.p3d",
        "nst\ns_structures\vn1_draty.p3d",
        "nst\ns_structures\vstup.p3d",
        "nst\ns_structures\vysoky1.p3d",
        "nst\ns_structures\vysoky2.p3d",
        "nst\ns_structures\x_nadrz.p3d",
        "nst\ns_structures\x_vetraci_komin.p3d",
        "nst\ns_structures\zas_zniceny1.p3d",
        "nst\ns_structures\zasob1.p3d",
        "nst\ns_structures\zasob2.p3d",
        "nst\ns_structures\zasob3_dam.p3d",
        "nst\ns_structures\zd_1.p3d",
        "nst\ns_structures\zd_2.p3d",
        "nst\ns_structures\zed1.p3d",
        "nst\ns_structures\zelezne_truby.p3d",
        "nst\ns_structures\zspawn.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "nst\ns_a2\housev_2t2.p3d",
        "nst\ns_structures\budova3_winter.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "nst\ns_a2\ind_stack_big.p3d",
        "nst\ns_a2\misc_powerstation.p3d",
        "nst\ns_jbad\ind\ind_powerstation\ns_jbad_ind_powerstation.p3d",
        "nst\ns_structures\trafostanica_mala_rozbita.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "nst\ns_a2\vysilac_fm.p3d",
        "nst\ns_structures\vys_antena.p3d",
        "nst\ns_structures\vys_budova_p1.p3d",
        "nst\ns_structures\vys_budova_p2.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "nst\ns_a2\a_crane_02a.p3d",
        "nst\ns_a2\a_crane_02b.p3d",
        "nst\ns_a2\molo_beton.p3d",
        "nst\ns_a2\nav_boathouse.p3d",
        "nst\ns_a2\nav_boathouse_pierl.p3d",
        "nst\ns_a2\nav_boathouse_pierr.p3d",
        "nst\ns_a2\nav_lighthouse.p3d",
        "nst\ns_a2\nav_pier_c.p3d",
        "nst\ns_a2\nav_pier_c2_end.p3d",
        "nst\ns_a2\nav_pier_c_90.p3d",
        "nst\ns_a2\nav_pier_c_big.p3d",
        "nst\ns_a2\nav_pier_m_2.p3d",
        "nst\ns_a2\nav_pier_m_end.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "nst\ns_a2\ind_malykomin.p3d",
        "nst\ns_a2\leseni2x.p3d",
        "nst\ns_a2\leseni4x.p3d",
        "nst\ns_structures\seb_mine_main_opt.p3d"
    ];

};

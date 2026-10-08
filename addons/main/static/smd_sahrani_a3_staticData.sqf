// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: smd_sahrani_a3 (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";

 if (tolower(_worldName) == "smd_sahrani_a3") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings\dum_istan4_zidka.p3d",
        "ca\buildings\dum_zboreny_lidice.p3d",
        "ca\buildings\misc\hrobecek.p3d",
        "ca\buildings\misc\hrobecek_krizek1.p3d",
        "ca\buildings\misc\hrobecek_krizek2.p3d",
        "ca\buildings\misc\plot_rust_vrat_o.p3d",
        "ca\buildings\misc\plutek.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\misc\zed_dira_civil.p3d",
        "ca\misc\sloupyeli.p3d",
        "smd_sahrani_artif_obj\buildings\castle\smd_helfenburk_zed.p3d",
        "smd_sahrani_artif_obj\buildings\misc\lampa_vysoka.p3d",
        "smd_sahrani_artif_obj\buildings\misc\pletivo.p3d",
        "smd_sahrani_artif_obj\buildings\misc\pletivo_dira.p3d",
        "smd_sahrani_artif_obj\buildings\misc\plot_istan2.p3d",
        "smd_sahrani_artif_obj\buildings\misc\smd_dumpster_glass.p3d",
        "smd_sahrani_artif_obj\buildings\misc\smd_dumpster_paper.p3d",
        "smd_sahrani_artif_obj\buildings\misc\smd_dumpster_plastic.p3d",
        "smd_sahrani_artif_obj\buildings\misc\smd_dumpster_trash.p3d",
        "smd_sahrani_artif_obj\buildings\misc\smd_gate.p3d",
        "smd_sahrani_artif_obj\buildings\misc\smd_water_pump.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_1.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_1b.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_2.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_2b.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_2c.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_4.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_4b.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_4c.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zavora.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zavora_sloupek.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zed.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zed_desert.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zed_dira.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zed_podplaz.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zed_podplaz_civil.p3d",
        "smd_sahrani_artif_obj\buildings\misc\zed_podplaz_desert.p3d",
        "smd_sahrani_artif_obj\buildings\smd_bordel_zidka.p3d",
        "smd_sahrani_artif_obj\buildings\smd_bozi_muka.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kap02.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_10.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_stairs4.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_5.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_s5.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop1_double.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop2_double.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop2_short.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop3_short.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop4.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop5_double.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop5_short.p3d",
        "smd_sahrani_artif_obj\buildings\smd_zvonice.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_ada.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_che.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_hellmart.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_nopassarao.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_pivo_small.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_revolucion.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_revolucion_bez_noh.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_test.p3d",
        "smd_sahrani_artif_obj\misc\bilboard_traidores.p3d",
        "smd_sahrani_artif_obj\misc\dc.p3d",
        "smd_sahrani_artif_obj\misc\sidewalks\sidewalk6shortend.p3d",
        "smd_sahrani_artif_obj\misc\sidewalks\sidewalk6turn10deg.p3d",
        "smd_sahrani_artif_obj\misc\sidewalks\sidewalk6turn5deg.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\budova1.p3d",
        "ca\buildings\budova5.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "smd_sahrani_artif_obj\buildings\smd_ammostore2_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut2_int.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut3_long.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut3_long_int.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut_int.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut_storrage.p3d",
        "smd_sahrani_artif_obj\buildings\smd_budova4_in.p3d",
        "smd_sahrani_artif_obj\buildings\smd_fuelstation_army.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_bez_tanku.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_s_tankem.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hlaska.p3d",
        "smd_sahrani_artif_obj\buildings\smd_posed.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_bez_tanku.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_s_tankem.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\budova1.p3d",
        "ca\buildings\hangar_2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_ammostore2_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut3_long_int.p3d",
        "smd_sahrani_artif_obj\buildings\smd_army_hut_storrage.p3d",
        "smd_sahrani_artif_obj\buildings\smd_fuelstation_army.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "smd_sahrani_artif_obj\buildings\smd_army_hut_int.p3d",
        "smd_sahrani_artif_obj\buildings\smd_budova4_in.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "smd_sahrani_artif_obj\buildings\smd_hlaska.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "smd_sahrani_artif_obj\buildings\smd_letistni_hala.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "smd_sahrani_artif_obj\buildings\smd_letistni_hala.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings\afbarabizna.p3d",
        "ca\buildings\afdum_mesto2.p3d",
        "ca\buildings\afdum_mesto2l.p3d",
        "ca\buildings\afdum_mesto3.p3d",
        "ca\buildings\afhospoda_mesto.p3d",
        "ca\buildings\bouda1.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\bouda3.p3d",
        "ca\buildings\cihlovej_dum.p3d",
        "ca\buildings\deutshe.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dulni_bs.p3d",
        "ca\buildings\dum01.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_mesto.p3d",
        "ca\buildings\dum_mesto2l.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_olez_istan2.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\dum_zboreny.p3d",
        "ca\buildings\dum_zboreny_total.p3d",
        "ca\buildings\dumruina_mini.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\hospital.p3d",
        "ca\buildings\hruzdum.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\komin.p3d",
        "ca\buildings\kostel.p3d",
        "ca\buildings\kostel3.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\sara_domek_hospoda.p3d",
        "ca\buildings\sara_domek_kovarna.p3d",
        "ca\buildings\sara_domek_podhradi_1.p3d",
        "ca\buildings\sara_domek_ruina.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_hasic_zbroj.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\buildings\sara_stodola3.p3d",
        "ca\buildings\stanice.p3d",
        "ca\buildings\statek_hl_bud.p3d",
        "ca\buildings\statek_kulna.p3d",
        "ca\buildings\zalchata.p3d",
        "smd_sahrani_artif_obj\buildings\castle\smd_helfenburk.p3d",
        "smd_sahrani_artif_obj\buildings\castle\smd_helfenburk_budova2.p3d",
        "smd_sahrani_artif_obj\buildings\castle\smd_helfenburk_cimburi.p3d",
        "smd_sahrani_artif_obj\buildings\misc\stanek_1c.p3d",
        "smd_sahrani_artif_obj\buildings\smd_bouda_plech_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_budova2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_budova3_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_cihlovej_dum_mini.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum02.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2_01.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2_02.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2_03.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2_03a.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2_04a.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2b.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan3.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan3_hromada.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan4.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan4_big.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan4_big_inverse.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan4_chodnik.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan4_detaily1.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan4_inverse.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_mesto3.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_mesto3_istan.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_mesto_in_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan1_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan1_open2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan2_maly_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan2_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan2_open2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olezlina_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dumruina.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_long_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_mala_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hospoda_mesto.p3d",
        "smd_sahrani_artif_obj\buildings\smd_house_y_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hut01.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hut02.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hut03.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hut04.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kasarna.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kasarna_prujezd.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kasarna_rohova.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kostel_mexico.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kostel_trosky.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kostelik.p3d",
        "smd_sahrani_artif_obj\buildings\smd_orlhot.p3d",
        "smd_sahrani_artif_obj\buildings\smd_sara_stodola2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_sara_zluty_statek_in.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop1.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop3.p3d",
        "smd_sahrani_artif_obj\buildings\smd_shop5.p3d",
        "smd_sahrani_artif_obj\buildings\smd_watertower1.p3d",
        "smd_sahrani_artif_obj\buildings\smd_zastavka_jih.p3d",
        "smd_sahrani_artif_obj\buildings\smd_zastavka_sever.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\hospital.p3d",
        "smd_sahrani_artif_obj\buildings\castle\smd_helfenburk.p3d",
        "smd_sahrani_artif_obj\buildings\castle\smd_helfenburk_budova2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_mesto3.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan1_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kasarna_prujezd.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings\afdum_mesto3.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\hruzdum.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_stodola.p3d",
        "smd_sahrani_artif_obj\buildings\smd_budova3_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_cihlovej_dum_mini.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2_02.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan2b.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan3_hromada.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_istan4_inverse.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_mesto3.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan1_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_dum_olez_istan2_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_long_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_mala_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_garaz_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_house_y_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hut01.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hut02.p3d",
        "smd_sahrani_artif_obj\buildings\smd_hut04.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kasarna_prujezd.p3d",
        "smd_sahrani_artif_obj\buildings\smd_kostel_mexico.p3d",
        "smd_sahrani_artif_obj\buildings\smd_sara_stodola2.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\buildings\trafostanica_velka_draty.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "ca\buildings\vysilac_fm.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings\majak.p3d",
        "ca\buildings\majak2.p3d",
        "ca\buildings\majak_podesta.p3d",
        "smd_sahrani_artif_obj\buildings\smd_majak_v_celku.p3d",
        "smd_sahrani_artif_obj\buildings\smd_molo_beton.p3d",
        "smd_sahrani_artif_obj\buildings\smd_molo_krychle.p3d",
        "smd_sahrani_artif_obj\buildings\smd_molo_krychle2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_nabrezi.p3d",
        "smd_sahrani_artif_obj\buildings\smd_nabrezi_najezd.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_cornl.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_cornp.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_cube.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_cube_long.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_mid.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_mid_cornl.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_mid_cornp.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_stairs.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_stairs2.p3d",
        "smd_sahrani_artif_obj\buildings\smd_podesta_1_stairs3.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "smd_sahrani_artif_obj\buildings\smd_benzina_schnell_open.p3d",
        "smd_sahrani_artif_obj\buildings\smd_fuelstation_army.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings\misc\leseni2x.p3d",
        "ca\buildings\misc\leseni4x.p3d"
    ];

};

private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: noe"] call ALIVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";

if (tolower(_worldName) == "noe") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zed_dr.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zed_02.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zed_03.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hrdb01.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_roh_kamen.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zed_ker.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_roh_sml.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zed_01.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zed_hr.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_25.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_12.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_10 100.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_lampa_cut.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_6konec.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_10 75.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_6.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zidka03.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zidka04.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zidka02.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_10 50.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_old_10 25.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_stozarvn_1.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zidka01.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zidka_branka.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_bordel_zidka.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_aut_z_st.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zed_04.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zedcl.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zedvn.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ruiny_3_prasklina.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ruiny_3_roh.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ruiny_3_dvere.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_6.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_6konec.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\nameplates\mbg_nameplate_kochanova.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_25.p3d",
        "ca\misc\patnik.p3d",
        "ca\misc\patniky.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hrob1.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kr_new_kos.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos25.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\nameplates\mbg_nameplate_heleny_malirove.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\nameplates\mbg_nameplate_lhotecka.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos12.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zavora_sloupek.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos6.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\nameplates\mbg_nameplate_shlikova.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\nameplates\mbg_nameplate_u_dvora.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nam_okruzi.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_vo_stara1.p3d",
        "cup\terrains\cup_terrains_cwa_roads\road_cwa_invisibled.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\nameplates\mbg_nameplate_eliashova.p3d",
        "cup\terrains\cup_terrains_cwa_roads\road_cwa_invisible.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_runway_straight.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_taxiway_short.p3d",
        "cup\terrains\cup_terrains_cwa_roads\road_cwa_invisibleb.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_taxiway_corner.p3d",
        "cup\terrains\cup_terrains_cwa_roads\road_cwa_invisiblec.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_taxiway_straight.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hangar_2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dd_pletivo.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_stozarvn_3.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dd_pletivo_sl.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zedpr.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zedlv.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ruiny_obvod_3.p3d",
        "cup\terrains\cup_terrains_cwa_misc\pozor_zakrutap.p3d",
        "cup\terrains\cup_terrains_cwa_misc\pozor_zakrutal.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_12.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_10 100.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_10 75.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_10 50.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos6konec.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos10 25.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos10 50.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kr_new_kos_kos_t.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_stozarvn_2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ohrada_sama.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ohrada_end.p3d",
        "cup\terrains\cup_terrains_cwa_furniture\tables\stul_hospodax.p3d",
        "cup\terrains\cup_terrains_cwa_misc\nastenka1.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_noe_road_new_10 25.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_most_stred30_nosupport.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_most_stred30.p3d",
        "cup\terrains\cup_terrains_cwa_noe_roads\cwa_tricktheaiintogoingoverthebridge_25.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos10 100.p3d",
        "cup\terrains\cup_terrains_cwa_roads\kos10 75.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dd_pletivo_dira.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hrad01.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\posed.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zavora.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_domek_radnice.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_hlidac_budka.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ammostore2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_fuelstation_army.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_repair_center.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hangar_2.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_ammostore2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_fuelstation_army.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hangar_2.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_domek_radnice.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hangar_2.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek03.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek02.p3d",
        "ca\buildings\sara_stodola3.p3d",
        "ca\buildings\sara_stodola.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_rosa.p3d",
        "ca\buildings\bouda_plech.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_orlhot.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_zluty.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_podhradi_1.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dum_patrovy05.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek04.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_vilka.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_kovarna.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_stodola2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek05.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zluty_statek_in.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dum_patrovy04.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zalchata.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_sedy.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_hospoda.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hasic_zbroj.p3d",
        "ca\buildings\kostel.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_ruina.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_aut_zast.p3d",
        "ca\buildings\kostel_trosky.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dum_patrovy02.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nahrobek1.p3d",
        "ca\buildings\kostel3.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_hrob2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nahrobek5.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nahrobek2.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01prujezd.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patr_nizky_prujezd.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01c.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dum_patrovy03.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_skola.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dum_patrovy06.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi03klaster.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_nam_dlazba.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_domek_radnice.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01d.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek01.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nahrobek4.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nahrobek3.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_chata6.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_kapl.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_bozi_muka.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi03magicland.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_kostelin.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\sara_stodola.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_zluty.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_stodola2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek05.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zluty_statek_in.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_sedy.p3d",
        "ca\buildings\kostel_trosky.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01prujezd.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patr_nizky_prujezd.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01c.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi03klaster.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01d.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi03magicland.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings\sara_stodola.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_zluty.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_stodola2.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek05.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_zluty_statek_in.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_domek_sedy.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_aut_zast.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_dum_patrovy02.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01prujezd.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patr_nizky_prujezd.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01c.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi03klaster.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_domek_radnice.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_patrovy01d.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_dum_podloubi03magicland.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\vysilac_fm.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_majak_v_celku.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nabrezi_najezd.p3d",
        "cup\terrains\cup_terrains_cwa_buildings\cwa_nabrezi.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "cup\terrains\cup_terrains_cwa_buildings\cwa_benzina.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings\misc\leseni4x.p3d",
        "ca\buildings\misc\leseni2x.p3d",
        "cup\terrains\cup_terrains_cwa_noe_buildings\mbg_tovarna1.p3d"
    ];
};

private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: taviana"] call ALIVE_fnc_dump;

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

if (tolower(_worldName) == "taviana") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [];
    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\hlidac_budka.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ori\buildings\garaz_bez_tanku.p3d",
        "ori\buildings\tav_guardhouse.p3d",
        "ca\buildings\tents\stan.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\buildings\tents\stan_east.p3d",
        "ori\structures\budova4_in_ori\budova4_in_ori.p3d",
        "ca\buildings\tents\astan.p3d",
        "ori\structures\bratislav\kasa.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_guardhouse.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ori\buildings\garaz_bez_tanku.p3d",
        "ori\buildings\garaz_velka.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_guardhouse.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ori\buildings\garaz_bez_tanku.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [
        "ca\structures\mil\mil_house.p3d",
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "ori\buildings\casino_1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_1t.p3d",
        "ori\buildings\domek_zluty_bez.p3d",
        "ori\buildings\domek03.p3d",
        "ori\buildings\domek02.p3d",
        "ori\buildings\domek_vilka.p3d",
        "ca\buildings\sara_hasic_zbroj.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ori\buildings\hotel.p3d",
        "ori\buildings\domek05.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ori\buildings\domek04.p3d",
        "ca\structures\house\housev2\housev2_03.p3d",
        "ca\buildings\komin.p3d",
        "ori\buildings\domek01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\buildings\garaz_mala.p3d",
        "ca\buildings\statek_kulna.p3d",
        "ca\buildings\statek_hl_bud.p3d",
        "ori\buildings\tav_housev_2l.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ori\buildings\hotel_riviera2.p3d",
        "ori\buildings\hotel_riviera1.p3d",
        "ori\buildings\domek_hospoda.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\dumruina_mini.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\buildings\dum_mesto2.p3d",
        "ori\buildings\bliny.p3d",
        "ori\buildings\zachytka.p3d",
        "ori\buildings\konecna.p3d",
        "ori\buildings\flowershop.p3d",
        "ori\buildings\tav_ind_pec_03.p3d",
        "ca\structures\ind\ind_stack_big.p3d",
        "ori\buildings\posta.p3d",
        "ori\buildings\kura.p3d",
        "ori\buildings\hrusevka.p3d",
        "ca\buildings\garaz.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_3i4.p3d",
        "ca\buildings\dum_mesto3.p3d",
        "ca\buildings\domek_rosa.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\buildings\dum_mesto.p3d",
        "ca\buildings\bouda1.p3d",
        "ori\buildings\hospoda.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ori\buildings\kasarna.p3d",
        "ori\buildings\kasarna_rohova.p3d",
        "ori\buildings\kasarna_prujezd.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\a_municipaloffice\a_municipaloffice.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d",
        "ca\buildings\sara_domek_kovarna.p3d",
        "ori\buildings\tav_ind_sawmill.p3d",
        "ca\structures\house\housev\housev_3i3.p3d",
        "ori\buildings\tav_housev2_01b.p3d",
        "ca\structures\house\housev\housev_1i1.p3d",
        "ori\buildings\dum_patrovy02.p3d",
        "ori\buildings\dum_patrovy03.p3d",
        "ca\structures\house\church_02\church_02.p3d",
        "ca\structures\house\housev2\housev2_05.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\structures\barn_w\barn_w_01_dam.p3d",
        "ca\buildings\sara_domek_podhradi_1.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\house\housev2\housev2_04_interier_dam.p3d",
        "ori\buildings\tav_hut_old02.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\buildings\dum_mesto2l.p3d",
        "ca\structures\rail\rail_station_big\rail_station_big.p3d",
        "ca\buildings\dum_olezlina.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ori\buildings\tav_synagoga.p3d",
        "ori\buildings\tav_cernja_basnja.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pier.p3d",
        "ori\buildings\dum_patrovy06.p3d",
        "ori\buildings\malboro.p3d",
        "ori\buildings\dum_patrovy01c.p3d",
        "ori\buildings\cinzak_long_double.p3d",
        "ori\buildings\tav_cinzak_long_centr.p3d",
        "ori\buildings\cinzak_long.p3d",
        "ori\buildings\cinzak_corner.p3d",
        "ori\buildings\parlament.p3d",
        "ori\buildings\parlament_geo1.p3d",
        "ori\buildings\parlament_geo2.p3d",
        "ori\buildings\parlament_geo3.p3d",
        "ori\buildings\cinzak_corner2.p3d",
        "ori\buildings\stojan_bus.p3d",
        "ori\buildings\bus_stojan_bud.p3d",
        "ori\buildings\galerie.p3d",
        "ori\buildings\podloubi_end_low_2.p3d",
        "ori\buildings\podloubi_double_low.p3d",
        "ori\buildings\podloubi_end_low_1.p3d",
        "ori\buildings\univerzita.p3d",
        "ori\buildings\univerzita_geo2.p3d",
        "ori\buildings\univerzita_geo1.p3d",
        "ori\buildings\muzeum.p3d",
        "ori\buildings\cinzak_long_centr.p3d",
        "ori\buildings\cinzak_roh2.p3d",
        "ori\buildings\cinzak_trojuhlenik.p3d",
        "ori\buildings\cinzak_roh3.p3d",
        "ori\buildings\council_house\domek_radnice.p3d",
        "ori\buildings\bus_depo_geo2.p3d",
        "ori\buildings\bus_depo_geo1.p3d",
        "ori\buildings\bus_depo.p3d",
        "ori\buildings\bank\banka.p3d",
        "ori\buildings\autosalon.p3d",
        "ori\buildings\tav_sabina_nad_4.p3d",
        "ori\buildings\tav_sabina_nad_station.p3d",
        "ori\buildings\tav_sabina_nad_3.p3d",
        "ori\buildings\tav_sabina_nad_2.p3d",
        "ori\buildings\tav_sabina_nad_1.p3d",
        "ori\buildings\hotel_marcomio.p3d",
        "ori\buildings\garaz_velka.p3d",
        "ori\buildings\bufet.p3d",
        "ori\buildings\big_church.p3d",
        "ori\buildings\spital_geo.p3d",
        "ori\buildings\spital.p3d",
        "ori\buildings\castle\ctirglav.p3d",
        "ori\buildings\tav_ind_pec_03_nov.p3d",
        "ori\buildings\pan_big_novi.p3d",
        "ori\buildings\zachytka_nov.p3d",
        "ori\buildings\train_st1.p3d",
        "ori\buildings\train_st2_bezzdi.p3d",
        "ori\buildings\vokzal_big.p3d",
        "ori\buildings\train_st2.p3d",
        "ori\buildings\riga_tower\bulding_r.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures\house\housev2\housev2_03_dam.p3d",
        "ca\structures\house\housev2\housev2_02_interier_dam.p3d",
        "ca\structures\house\housev\housev_1i1_dam.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\structures\house\housev2\housev2_03b_dam.p3d",
        "ca\structures\shed_ind\shed_ind02_dam.p3d",
        "ori\buildings\housev_2i_snow.p3d",
        "ori\buildings\bouda1_zima.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ori\buildings\hotel.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ori\buildings\parlament.p3d",
        "ori\buildings\parlament_geo1.p3d",
        "ori\buildings\parlament_geo2.p3d",
        "ori\buildings\parlament_geo3.p3d",
        "ori\buildings\council_house\domek_radnice.p3d",
        "ori\buildings\spital.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_1t.p3d",
        "ori\buildings\domek_zluty_bez.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ori\buildings\hotel.p3d",
        "ori\buildings\domek05.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ori\buildings\hotel_riviera2.p3d",
        "ori\buildings\hotel_riviera1.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ori\buildings\posta.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ori\buildings\hospoda.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ori\buildings\tav_cinzak_long_centr.p3d",
        "ori\buildings\parlament.p3d",
        "ori\buildings\parlament_geo1.p3d",
        "ori\buildings\parlament_geo2.p3d",
        "ori\buildings\parlament_geo3.p3d",
        "ori\buildings\stojan_bus.p3d",
        "ori\buildings\bus_stojan_bud.p3d",
        "ori\buildings\galerie.p3d",
        "ori\buildings\casino_1.p3d",
        "ori\buildings\council_house\domek_radnice.p3d",
        "ori\buildings\spital.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings\trafostanica_velka.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ori\buildings\tv_tower_base.p3d",
        "ori\buildings\tv_towoer_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d",
        "ori\buildings\tv_bud.p3d",
        "ori\buildings\tv_tower.p3d",
        "ori\buildings\avtovokzal.p3d",
        "ca\buildings\vysilac_fm.p3d",
        "ori\buildings\tav_rozhledna.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings\majak.p3d",
        "ca\buildings\majak_podesta.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "ca\structures\rail\rail_station_big\rail_station_big.p3d",
        "ori\buildings\train_st1.p3d",
        "ori\buildings\train_st2_bezzdi.p3d",
        "ori\buildings\vokzal_big.p3d",
        "ori\buildings\train_st2.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d",
        "ori\buildings\fuelstation_novi.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\a_buildingwip\a_buildingwip.p3d",
        "ca\structures\a_cranecon\a_cranecon.p3d"
    ];
};

private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: %1", _worldName] call ALiVE_fnc_dump;

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

if (_worldName == "australia") then {
    [ALIVE_mapBounds, worldName, 40960] call ALIVE_fnc_hashSet;

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\army_hut2_int.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "mm_bank\commonwealthbank.p3d",
        "mm_buildings2\police_station\policestation.p3d",
        "a3\structures_f\dominants\hospital\hospital_f.p3d",
        "mm_buildings\prison\gaol_main.p3d",
        "mm_buildings\prison\mapobject\gaol_tower.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\army_hut3_long.p3d",
        "ca\buildings\army_hut_int.p3d",
        "ca\buildings\army_hut3_long_int.p3d",
        "ca\buildings\hlaska.p3d",
        "ca\buildings\tents\fortress_01.p3d",
        "ca\buildings\army_hut_storrage.p3d",
        "mm_buildings\prison\proxy\mainsection.p3d",
        "ca\buildings\garaz_bez_tanku.p3d",
        "ca\buildings\garaz_s_tankem.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\army_hut2.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "ca\buildings\ammostore2.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "ca\misc_e\guardshed_ep1.p3d",
        "ausextras\objects\ausbunker.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "ca\misc3\fortified_nest_small.p3d",
        "ca\buildings\budova1.p3d",
        "ca\misc2\barrack2\barrack2.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "mm_buildings2\police_station\policestation.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\army_hut3_long.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "mm_bank\commonwealthbank.p3d",
        "mm_buildings2\police_station\policestation.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\buildings\budova4_in.p3d",
        "mm_buildings\prison\proxy\mainsection.p3d",
        "ca\buildings\garaz_bez_tanku.p3d",
        "ca\buildings\garaz_s_tankem.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "mm_bank\commonwealthbank.p3d",
        "mm_buildings2\police_station\policestation.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "mm_buildings\prison\proxy\mainsection.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "ca\misc2\barrack2\barrack2.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\roads\runway_pojdraha.p3d",
        "a3\roads_f\runway\runway_end02_f.p3d",
        "a3\roads_f\runway\runway_main_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "ca\roads\runway_end0.p3d",
        "ca\roads\runway_poj_end9.p3d",
        "ca\roads\runway_poj_tcross.p3d",
        "ca\roads\runway_main.p3d",
        "ca\roads\runway_end27.p3d",
        "ca\roads\runway_poj_end27.p3d",
        "ca\roads2\runway_end33.p3d",
        "ca\roads\runway_dirt.p3d",
        "ca\buildings\letistni_hala.p3d",
        "ca\roads\runway_end9.p3d",
        "ca\misc\heli_h_civil.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "a3\structures_f\ind\airport\airport_left_f.p3d",
        "a3\structures_f\ind\airport\airport_right_f.p3d",
        "a3\structures_f\ind\airport\airport_center_f.p3d",
        "ca\misc\heli_h_civil.p3d"
    ];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [
        "ca\misc\heli_h_army.p3d",
        "mm_buildings\prison\mapobject\helipad\helipad.p3d",
        "ca\misc\heli_h_rescue.p3d",
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d",
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "ca\misc\heli_h_rescue.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "ca\buildings\hangar_2.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "ca\buildings\hut_old02.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "e76_buildings\shops\e76_shop_multi1.p3d",
        "mm_buildings3\pub_c\pub_c.p3d",
        "mm_post\build2\postb.p3d",
        "mm_bank\commonwealthbank.p3d",
        "mm_residential\residential_a\houseb.p3d",
        "mm_residential\residential_a\housea.p3d",
        "mm_residential\residential_a\houseb1.p3d",
        "ausextras\a_generalstore_01\iga_generalstore.p3d",
        "ca\buildings\kulna.p3d",
        "mm_residential\residential_a\housea1.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "mm_buildings3\pub_a\pub_a.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "mm_residential2\housedoubleal2.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_gyros_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_redburger_f.p3d",
        "ausextras\a_generalstore_01\iga_generalstore2.p3d",
        "mm_residential\residential_a\house_l\housec1_l.p3d",
        "mm_residential\residential_a\housec_r.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p3_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p2_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p9_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p4_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p1_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p5_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p8_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p6_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p7_f.p3d",
        "mm_buildings4\centrelink.p3d",
        "ca\buildings\dum_istan4.p3d",
        "a3\structures_f\dominants\hospital\hospital_f.p3d",
        "e76_buildings\shops\e76_shop_single1.p3d",
        "ca\buildings\hotel.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "mm_residential2\housedoubleal.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\misc\water_tank.p3d",
        "ca\structures\furniture\cases\skrin_bar\skrin_bar.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_papers_f.p3d",
        "ca\buildings\shop2.p3d",
        "ca\buildings\shop3.p3d",
        "ca\buildings\shop1.p3d",
        "ca\buildings\shop1_double.p3d",
        "ca\buildings\shop2_double.p3d",
        "ca\buildings\shop4.p3d",
        "ca\buildings\shop5_double.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "ca\buildings\hut04.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_gazebo_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_blueking_f.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "mm_residential\residential_a\house_l\housea1_l.p3d",
        "ca\buildings\dum_istan4_big.p3d",
        "ca\buildings\dum_mesto3_istan.p3d",
        "ca\buildings\dum_istan4_big_inverse.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\a_municipaloffice\a_municipaloffice.p3d",
        "ca\buildings\shop5.p3d",
        "ca\buildings\dum_istan2_01.p3d",
        "ca\buildings\dum_istan2b.p3d",
        "ca\buildings\dum_istan4_inverse.p3d",
        "ca\buildings\dum_istan4_detaily1.p3d",
        "e76_buildings\tower\e76_tower7.p3d",
        "ca\buildings\dum_istan2_03.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\buildings\dum_istan2_02.p3d",
        "ca\buildings\dum_istan2_04a.p3d",
        "ausextras\shops\shopelectricsdouble.p3d",
        "ca\buildings\kostel2.p3d",
        "ca\buildings\hotel_riviera1.p3d",
        "ca\buildings\hotel_riviera2.p3d",
        "ca\buildings\statek_kulna.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\structures\house\a_office01\data\proxy\doorinterier.p3d",
        "mm_residential\residential_a\house_l\houseb1_l.p3d",
        "ca\buildings\budova3.p3d",
        "plp_beachobjects\plp_bo_beachbar.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\buildings\hut02.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "ca\buildings\hut_old02.p3d",
        "mm_buildings3\pub_c\pub_c.p3d",
        "mm_post\build2\postb.p3d",
        "mm_bank\commonwealthbank.p3d",
        "mm_residential\residential_a\houseb.p3d",
        "mm_residential\residential_a\housea.p3d",
        "mm_residential\residential_a\houseb1.p3d",
        "mm_residential\residential_a\housea1.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "mm_residential2\housedoubleal2.p3d",
        "mm_residential\residential_a\house_l\housec1_l.p3d",
        "mm_residential\residential_a\housec_r.p3d",
        "mm_buildings4\centrelink.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\buildings\hotel.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "mm_residential2\housedoubleal.p3d",
        "mm_apartment\a_office02c.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "mm_residential\residential_a\house_l\housea1_l.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "mm_residential\residential_a\house_l\houseb1_l.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\buildings\hut02.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "mm_buildings3\pub_c\pub_c.p3d",
        "mm_residential\residential_a\houseb.p3d",
        "mm_residential\residential_a\housea.p3d",
        "mm_residential\residential_a\houseb1.p3d",
        "mm_residential\residential_a\housea1.p3d",
        "mm_buildings3\pub_a\pub_a.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "mm_residential2\housedoubleal2.p3d",
        "mm_residential\residential_a\house_l\housec1_l.p3d",
        "mm_residential\residential_a\housec_r.p3d",
        "ca\buildings\hotel.p3d",
        "mm_residential2\housedoubleal.p3d",
        "mm_residential\residential_a\house_l\housea1_l.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "mm_residential\residential_a\house_l\houseb1_l.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\buildings\hut02.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f\ind\powerlines\highvoltagecolumn_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\powerlines\powerline_distributor_f.p3d",
        "a3\structures_f\civ\lamps\lampsolar_f.p3d",
        "a3\structures_f\items\electronics\portable_generator_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "a3\structures_f\ind\windpowerplant\wpp_turbine_v2_f.p3d",
        "ca\buildings\misc\stozarvn_1.p3d",
        "a3\structures_f\ind\powerlines\highvoltageend_f.p3d",
        "ca\misc_e\powgen_big_ep1.p3d",
        "a3\structures_f\ind\windpowerplant\wpp_turbine_v1_f.p3d",
        "a3\structures_f\ind\windpowerplant\powergenerator_f.p3d",
        "ca\misc_e\powgen_big.p3d",
        "ca\misc2\samsite\powgen_big.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d",
        "ca\buildings\watertower1.p3d",
        "ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d",
        "a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "ca\buildings\vysilac_fm.p3d",
        "dbe1\models_dbe1\vysilac\vysilac_budova.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "ca\buildings\telek1.p3d",
        "ca\structures\proxy_buildingparts\roof\antennabigroof\antenna_big_roof.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "ca\structures_e\misc\com_tower_ep1.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",
        "ca\buildings\vysilac_fm2.p3d",
        "ca\misc_e\76n6_clamshell_ep1.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings\molo_krychle.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\naval\piers\pier_wall_f.p3d",
        "ca\buildings\molo_beton.p3d",
        "ca\buildings\nabrezi.p3d",
        "ca\buildings\nabrezi_najezd.p3d",
        "ca\structures\nav_pier\nav_pier_f_17.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "ca\buildings\hut01.p3d",
        "ca\structures\nav_pier\nav_pier_m_end.p3d",
        "ca\structures\nav_pier\nav_pier_m_2.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_pier\nav_pier_c.p3d",
        "ca\structures\nav_pier\nav_pier_c2.p3d",
        "ca\structures\nav_pier\nav_pier_c_90.p3d",
        "ca\structures\nav_pier\nav_pier_m_1.p3d",
        "a3\structures_f\naval\piers\pillar_pier_f.p3d",
        "ca\structures\nav_pier\nav_pier_c_r.p3d",
        "ca\structures\nav_pier\nav_pier_c_r30.p3d",
        "ca\structures\nav_pier\nav_pier_c_l.p3d",
        "ca\structures\nav_pier\nav_pier_c_big.p3d",
        "ca\structures\nav_pier\nav_pier_c_t20.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings\fuelstation_army.p3d",
        "ca\misc\fuel_tank_small.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d",
        "ca\buildings2\ind_pipeline\indpipe2\indpipe2_smallbuild2_l.p3d",
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall2.p3d",
        "ca\buildings\fuelstation.p3d",
        "a3\structures_f\ind\tank\tank_rust_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "ca\structures\a_buildingwip\a_buildingwip.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_box.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings\komin.p3d",
        "ca\structures_e\housea\a_buildingwip\a_buildingwip_ep1.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\addons\metal_shed_f.p3d",
        "ca\structures\a_cranecon\a_cranecon.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\misc3\toilet.p3d",
        "mm_residential2\studs\studstage1.p3d",
        "mm_residential2\studs\studstage3.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_cementworks\ind_silomale\ind_silomale.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "a3\structures_f\ind\factory\factory_conv1_10_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_main_f.p3d",
        "a3\structures_f\ind\factory\factory_hopper_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_end_f.p3d",
        "a3\structures_f\ind\factory\factory_conv2_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "mm_civilengineering\crane\cranebase.p3d",
        "mm_civilengineering\crane\cranemid.p3d",
        "mm_civilengineering\crane\cranetop.p3d",
        "mm_residential2\studs\studstage2.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\army_hut2.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_hopper_f.p3d",
        "ca\structures\ind_quarry\ind_hammermill.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "ausextras\objects\crane.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_end_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_switch_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d"
    ];
};

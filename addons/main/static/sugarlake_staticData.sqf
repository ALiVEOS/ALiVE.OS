private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: sugarlake"] call ALiVE_fnc_dump;

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

if (tolower(_worldName) == "sugarlake") then {
    [ALIVE_mapBounds, worldName, 9000] call ALIVE_fnc_hashSet;

    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\structures\nav_pier\nav_pier_f_23.p3d",
        "a3\structures_f\ind\factory\factory_conv2_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_10_ruins_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_ruins_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_shed_ruins_f.p3d",
        "a3\structures_f\ind\shed\shed_ind_ruins_f.p3d",
        "a3\structures_f\ind\shed\shed_small_ruins_f.p3d",
        "ca\structures\misc\armory\woodenramp\woodenramp.p3d",
        "ca\buildings\misc\leseni4x.p3d",
        "ca\desert2\data\plant\bush1.p3d",
        "ca\buildings\ruins\statek_kulna_ruins.p3d",
        "ca\buildings2\shed_small\shed_w01_ruins.p3d",
        "ca\buildings2\shed_small\shed_m02_ruins.p3d",
        "ca\structures_e\misc\shed_m01_ruins_ep1.p3d",
        "ca\buildings\ruins\hotel_riviera1_ruins.p3d",
        "ca\buildings\ruins\trafostanica_velka_ruins.p3d",
        "ca\buildings\ruins\sara_stodola2_ruins.p3d",
        "ca\buildings\ruins\statek_kulna_old_ruins.p3d",
        "ca\buildings\ruins\nabrezi_najezd_ruins.p3d",
        "ca\buildings\ruins\hut_old02_ruins.p3d",
        "ca\buildings\ruins\dum_mesto3_ruins.p3d",
        "ca\buildings\ruins\garaz_ruins.p3d",
        "ca\buildings\ruins\trafostanica_mala_ruins.p3d",
        "ca\buildings\ruins\dum_istan2_02_ruins.p3d",
        "ca\buildings\ruins\dum_istan2_01_ruins.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l_ruins.p3d",
        "ca\buildings\ruins\garaz_s_tankem_ruins.p3d",
        "ca\buildings\ruins\kostel_trosky_ruins.p3d",
        "ca\buildings\ruins\dum_istan3_hromada_ruins.p3d",
        "ca\buildings\ruins\domek_rosa_ruins.p3d",
        "ca\buildings2\shed_small\shed_w03_ruins.p3d",
        "ca\buildings\ruins\majak_v_celku_ruins.p3d",
        "ca\buildings\ruins\leseni4x_ruins.p3d",
        "ca\buildings\ruins\leseni2x_ruins.p3d",
        "ca\buildings\ruins\sara_dum_podloubi03rovny_ruins.p3d",
        "ca\buildings2\shed_small\shed_m01_ruins.p3d",
        "ca\buildings\ruins\sara_stodola_ruins.p3d",
        "ca\buildings\ruins\majak_ruins.p3d",
        "ca\buildings\ruins\hotel_riviera2_ruins.p3d",
        "ca\buildings\ruins\komin_ruins.p3d",
        "ca\buildings\ruins\sara_domek_sedy_bez_ruins.p3d",
        "ca\buildings\ruins\kasarna_prujezd_ruins.p3d",
        "a3\structures_f\naval\buoys\buoybig_f.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ruins_ep1.p3d",
        "a3\structures_f\ind\powerlines\highvoltagecolumn_f.p3d",
        "a3\structures_f\ind\powerlines\highvoltagecolumnwire_f.p3d",
        "ca\buildings\ruins\garaz_bez_tanku_ruins.p3d",
        "a3\structures_f\households\slum\cargo_addon02_v1_f.p3d",
        "ca\buildings\ruins\budova1_ruins.p3d",
        "ca\buildings\ruins\budova2_ruins.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall_ruins.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_mirror_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_conv1_main_ruins_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_ruins_f.p3d",
        "a3\structures_f\ind\factory\factory_hopper_ruins_f.p3d",
        "ca\structures\ind_sawmill\ind_sawmill_ruins.p3d",
        "ca\buildings\ruins\dum_zboreny_total_ruins.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_ruins_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_tower_ruins_f.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_main_ruins.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ruins_ep1.p3d",
        "a3\structures_f\ind\airport\landmark_f.p3d",
        "a3\roads_f\runway\runway_end04_f.p3d",
        "a3\roads_f\runway\runway_main_f.p3d",
        "ca\structures\proxy_buildingparts\gasmeterext\gasmeterext.p3d",
        "ca\structures\proxy_buildingparts\aircondition\aircond_big.p3d",
        "a3\structures_f\households\house_small02\house_small_02_v1_ruins_f.p3d",
        "ca\buildings\furniture\stul_hospoda.p3d",
        "ca\buildings\misc\hrob2.p3d",
        "a3\structures_f\households\slum\slum_house03_ruins_f.p3d",
        "ca\buildings\misc\nahrobek3.p3d",
        "ca\buildings\misc\nahrobek1.p3d",
        "ca\buildings\misc\hrobecek2.p3d",
        "ca\buildings\misc\plot_wood.p3d",
        "ca\buildings\furniture\stul_kuch1.p3d",
        "ca\buildings\podesta_1_cube_long.p3d",
        "ca\buildings\misc\plot_istan1_rovny_gate.p3d",
        "ca\buildings\misc\dd_pletivo.p3d",
        "ca\buildings\misc\plot_provizorni.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_price_f.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d",
        "ca\buildings\podesta_1_cornp.p3d",
        "ca\buildings\misc\plot_wood_sloupek.p3d",
        "a3\structures_f\households\house_small03\house_small_03_v1_ruins_f.p3d",
        "a3\structures_f\households\house_small01\house_small_01_v1_ruins_f.p3d",
        "ca\buildings\kopa_1.p3d",
        "ca\structures\wall\gate_indvar2_5.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_gate_ep1.p3d",
        "ca\buildings\misc\plot_wood1.p3d",
        "a3\structures_f\households\house_big01\house_big_01_v1_ruins_f.p3d",
        "ca\structures_pmc\ind\fuelstation\fuelstation_build_ruins_pmc.p3d",
        "a3\structures_f\mil\barracks\barracks_ruins_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_ruins_f.p3d",
        "ca\buildings\misc\plot_wood_door.p3d",
        "a3\structures_f\ind\airport\airport_tower_ruins_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\army_hut2_int.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_5_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "ca\buildings\army_hut_storrage.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_1_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_3_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "ca\buildings\army_hut3_long.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1e.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "ca\buildings\hangar_2.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "ca\buildings\army_hut_int.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\army_hut_storrage.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\ind\airport\airport_right_f.p3d",
        "a3\structures_f\ind\airport\airport_left_f.p3d",
        "a3\roads_f\runway\runway_main_40_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "a3\structures_f\ind\shed\shed_small_f.p3d",
        "ca\structures\ind\ind_stack_big.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\structures\ind_quarry\ind_quarry.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "a3\structures_f\households\slum\slum_house01_ruins_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_v1_f.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings2\a_crane_02\crane_rails.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_ruins_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_ruins_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\buildings\house_y.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "ca\buildings\garaz_bez_tanku.p3d",
        "ca\buildings\vysilac_fm.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "a3\structures_f\households\slum\slum_house02_ruins_f.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\sara_zluty_statek_in.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\dulni_bs.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "a3\structures_f_epc\dominants\ghosthotel\gh_house_1_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_papers_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "ca\buildings\podesta_1_mid.p3d",
        "ca\buildings\podesta_1_mid_cornp.p3d",
        "ca\buildings\podesta_1_cube.p3d",
        "ca\buildings\podesta_1_cornl.p3d",
        "ca\buildings\hotel.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\bridges\bridge_asphalt_f.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\structures\shed_ind\shed_ind02_dam.p3d",
        "ca\buildings\afbarabizna.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_blueking_f.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\buildings\misc\nam_okruzi.p3d",
        "ca\buildings\budova3.p3d",
        "ca\buildings\misc\plot_wood1b.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\sara_stodola.p3d",
        "a3\structures_f_epc\civ\kiosks\kiosk_redburger_f.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\buildings\dum_olezlina.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v1_f.p3d",
        "a3\structures_f\civ\belltowers\belltower_02_v1_f.p3d",
        "ca\buildings\garaz.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\d_house_small_01_v1_f.p3d",
        "ca\buildings\misc\lavicka_2.p3d",
        "ca\structures\barn_w\barn_w_02.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\hotel.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\buildings\house_y.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "ca\buildings\hotel.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\d_house_small_01_v1_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\powerlines\powlines_transformer_f.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "a3\structures_f\ind\wavepowerplant\wavepowerplantbroken_f.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\buildings\trafostanica_mala.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_f.p3d",
        "ca\structures\nav_pier\nav_pier_m_end.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "a3\structures_f\naval\piers\pillar_pier_f.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_ruins.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_small_f.p3d",
        "ca\structures\nav_pier\nav_pier_m_2.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings\fuelstation.p3d",
        "a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_ruins_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_ruins_f.p3d"
    ];
};

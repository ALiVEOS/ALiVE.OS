private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: beketov"] call ALIVE_fnc_dump;

[ALIVE_mapBounds, worldName, 21000] call ALIVE_fnc_hashSet;
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

if (tolower(_worldName) == "beketov") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "rus\les\les_10 100.p3d",
        "fmod\fmod_obj\bush\ker pichlavej.p3d",
        "rusland\beketov_ob\bush\str trnka.p3d",
        "rusland\beketov_ob\bush\krovi2.p3d",
        "fmod\fmod_obj\bush\ker deravej.p3d",
        "fmod\fmod_obj\bush\ker deravej_big.3d.p3d",
        "rusland\beketov_ob\bush\krovi_bigest.p3d",
        "rusland\beketov_ob\bush\str_liskac.p3d",
        "fmod\fmod_obj\bush\ker buxus.p3d",
        "rus\les\les_25.p3d",
        "rus\les\les_10 50.p3d",
        "rus\les\les_10 25.p3d",
        "rus\les\les_10 75.p3d",
        "beketov_br\t_larix3f.p3d",
        "rus\les\les_6konec.p3d",
        "rus\les\les_6.p3d",
        "beketov_br\t_larix3s.p3d",
        "rus\dor\b\asf1_10 100.p3d",
        "rus\les\les_12.p3d",
        "ca\structures\furniture\chairs\postel_manz_kov\postel_manz_kov.p3d",
        "rusland\beketov_ob\pale_wood2_5.p3d",
        "ca\structures\misc\armory\pneu\pneu.p3d",
        "rusland\beketov_ob\pale_wood1_5.p3d",
        "rusland\beketov_ob\gradka\moddelss\pale_greenhouse.p3d",
        "rus\clutt\p_phragmites.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d",
        "rus\dor\b\asf1_10 50.p3d",
        "ca\structures\misc\armory\dirthump\dirthump01.p3d",
        "ca\roads2\path_25.p3d",
        "ca\roads2\path_10 25.p3d",
        "ca\roads2\path_10 50.p3d",
        "rus\dor\b\asf1_10 75.p3d",
        "ca\roads2\path_12.p3d",
        "ca\structures\furniture\chairs\vojenska_palanda\vojenska_palanda.p3d",
        "ca\structures\misc\armory\dirthump\dirthump02.p3d",
        "ca\roads2\path_10 100.p3d",
        "ca\roads2\path_10 75.p3d",
        "ca\buildings\misc\zavora_2.p3d",
        "ca\structures\ruins\rubble_bricks_04.p3d",
        "ca\structures\ruins\rubble_bricks_02.p3d",
        "ca\buildings2\a_advertisingcolumn\a_advertcolumn.p3d",
        "vtn_bdg_ads\decals\kino.p3d",
        "vtn_bdg_ads\decals\kino_votme.p3d",
        "vtn_bdg_ads\decals\kino_deniska.p3d",
        "vtn_bdg_ads\decals\kino_serafima.p3d",
        "ca\structures\furniture\chairs\church_chair\church_chair.p3d",
        "ca\structures\house\church_cross\church_cross_1.p3d",
        "ca\structures\house\church_cross\church_cross_1a.p3d",
        "vtn_bdg_ads\decals\tablo_ifns.p3d",
        "ca\structures\misc\armory\woodenramp\woodenramp.p3d",
        "ca\structures\furniture\chairs\ch_mod_c\ch_mod_c.p3d",
        "rusland\beketov_ob\pale_stolbte.p3d",
        "rusland\beketov_ob\stolb\stolb.p3d",
        "rusland\vtn_beketov_h\wall\wall_11_01b.p3d",
        "ca\roads_e\sidewalks\sw_a_body_6m_ep1.p3d",
        "ca\roads_e\sidewalks\sw_a_turn_ep1.p3d",
        "ca\roads_e\sidewalks\sw_b_body_6m_ep1.p3d",
        "ca\roads_e\sidewalks\sw_a_end_l_ep1.p3d",
        "ca\roads_e\sidewalks\sw_a_end_r_ep1.p3d",
        "ca\structures\ruins\rubble_bricks_03.p3d",
        "ca\misc\svodidla.p3d",
        "rusland\beketov_ob\clutter\vasilek.p3d",
        "rusland\beketov_ob\clutter\clutter_flower_mix.p3d",
        "rusland\beketov_ob\clutter\clutter_grass_flowers.p3d",
        "rusland\vtn_beketov_h\welcome\welcome.p3d",
        "ca\misc\kolotoc.p3d",
        "a3\structures_f\bridges\bridge_asphalt_f.p3d",
        "rusland\beketov_ob\clutter\clutter_white_flower.p3d",
        "rusland\beketov_ob\clutter\clutter_blue_flower.p3d",
        "vtn_bdg_ads\decals\zabor_jurchik.p3d",
        "vtn_bdg_ads\decals\zabor_dmb91.p3d",
        "ca\structures\nav_pier\nav_pier_c.p3d"
    ];
    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\structures_pmc\buildings\bunker\bunker_pmc.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\structures\mil\mil_barracks_i.p3d"
    ];
    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];
    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\structures\mil\mil_barracks_i.p3d"
    ];
    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\structures\mil\mil_barracks_i.p3d"
    ];
    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];
    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];
    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];
    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];
    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\kulna.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\buildings\sara_domek_podhradi_1.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\structures\a_buildingwip\a_buildingwip.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\church_02\church_02.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "vtn_bdg_postoffice\vtn_postoffice.p3d",
        "ca\structures_pmc\ind\fuelstation\fuelstation_build_pmc.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "vtn_bdg_post_md\beketov_post.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\hospital.p3d",
        "ca\buildings\dum_zboreny.p3d"
    ];
    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d"
    ];
    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\structures\house\housev\housev_1i2.p3d",
        "ca\structures\house\housev\housev_3i3.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\structures\house\housev\housev_3i1.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\structures\house\housev\housev_1l2.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "ca\structures\house\housev\housev_3i2.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\structures\house\housev\housev_2t1.p3d",
        "rusland\vtn_beketov_h\roztower\roztower_rust.p3d",
        "ca\structures\house\housev\housev_3i4.p3d",
        "ca\structures\house\housev\housev_1l1.p3d",
        "ca\buildings\kulna.p3d",
        "ca\structures\house\housev\housev_1i1.p3d",
        "ca\structures\house\housev\housev_1t.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\church_05r\church_05r.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_pmc\misc\shed\shed_w02_pmc.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\sara_domek_podhradi_1.p3d",
        "ca\buildings\dum01.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_mesto.p3d",
        "ca\buildings\dum_zboreny_lidice.p3d",
        "ca\buildings\dum_zboreny_total.p3d",
        "ca\buildings\bouda1.p3d",
        "ca\structures\house\housev2\housev2_01a.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\buildings\telek1.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_03b.p3d",
        "ca\structures\house\housev2\housev2_03.p3d",
        "ca\structures\house\housev2\housev2_01b.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\buildings2\shed_small\shed_m02.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\buildings\komin.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\budova1.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "ca\roads2\dam\dam_conc\dam_concp_20.p3d",
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall2.p3d",
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\structures\ind\ind_stack_big.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\buildings\vysilac_fm.p3d",
        "ca\buildings\budova5.p3d",
        "ca\structures\a_buildingwip\a_buildingwip.p3d",
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\buildings\dum_mesto3.p3d",
        "ca\buildings\dum_mesto3test.p3d",
        "ca\structures\house\housev2\housev2_02.p3d",
        "ca\buildings\dum_mesto2l.p3d",
        "ca\structures\house\housev2\housev2_05.p3d",
        "rusland\vtn_beketov_h\kiosk\kiosk.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "rusland\vtn_beketov_h\adma\adma_2.p3d",
        "ca\structures\house\church_02\church_02.p3d",
        "ca\roads2\dam\dam_conc\dam_conc_20.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p8_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p8_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p7_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p1_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p2_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p3_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p6_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p5_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p9_f.p3d",
        "a3\structures_f_epc\dominants\stadium\stadium_p4_f.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\farm_wtower\farm_wtower.p3d",
        "ca\structures\house\housev2\housev2_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\misc\water_tank.p3d",
        "vtn_bdg_postoffice\vtn_postoffice.p3d",
        "ca\structures_pmc\ind\fuelstation\fuelstation_build_pmc.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "vtn_bdg_post_md\beketov_post.p3d",
        "ca\buildings\garaz_mala.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_box.p3d",
        "rusland\vtn_beketov_h\roztower\roztower_new.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "rusland\vtn_beketov_h\roztower\roztower_blu.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_02.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_01_ep1.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings\sara_domek_ruina.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\hospital.p3d",
        "ca\structures\ind_quarry\ind_quarry.p3d",
        "ca\buildings\bouda3.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "ca\buildings\dum_zboreny.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f\ind\factory\factory_main_part2_f.p3d",
        "ca\buildings\bouda_plech.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\buildings\sara_stodola.p3d"
    ];
    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_velka.p3d"
    ];
    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d"
    ];
    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];
    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\structures_pmc\ind\fuelstation\fuelstation_build_pmc.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d"
    ];
    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\structures\a_buildingwip\a_buildingwip.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d"
    ];
};

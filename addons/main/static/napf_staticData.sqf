// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: napf (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "napf") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "aif_napfobjects\aif_arma1buildings\aif_billboard_chuckiemike.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_billboard_konzert_wallmount.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_billboard_mirek.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_billboard_perpedes.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_fence_chmelnice.p3d",
        "ca\buildings2\a_advertisingcolumn\a_advertcolumn.p3d",
        "ca\buildings2\a_crane_02\crane_rails.p3d",
        "ca\buildings2\a_crane_02\crane_rails_end.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_02.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1e.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1f.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1g.p3d",
        "ca\buildings2\misc_cargo\seacrate.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings2\shed_small\shed_m02.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\misc\zed_dira_civil.p3d",
        "ca\buildings\misc\zed_podplaz_civil.p3d",
        "ca\buildings\sara_domek_vilka.p3d",
        "ca\misc2\baseball\baseball.p3d",
        "ca\misc\drevtank.p3d",
        "ca\misc\svodidla.p3d",
        "ca\misc_e\wreck_c130j.p3d",
        "ca\misc_e\wreck_c130j_ep1_ruins.p3d",
        "ca\roads2\dam\dam_barrier_40\dam_barrier_40.p3d",
        "ca\roads2\dam\dam_conc\dam_concp_20.p3d",
        "ca\roads2\runway_main_40.p3d",
        "ca\roads2\runway_poj_l_1.p3d",
        "ca\roads2\runway_poj_l_1_end.p3d",
        "ca\roads2\runwayold_40_main.p3d",
        "ca\structures\ind_quarry\ind_hammermill.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_ruins.p3d",
        "ca\structures\nav_pier\nav_pier_c_270.p3d",
        "ca\structures\nav_pier\nav_pier_c_l.p3d",
        "ca\structures\nav_pier\nav_pier_c_l10.p3d",
        "ca\structures\nav_pier\nav_pier_c_l30.p3d",
        "ca\structures\nav_pier\nav_pier_c_r10.p3d",
        "ca\structures\nav_pier\nav_pier_c_r30.p3d",
        "ca\structures\wall\wall_woodvil_pole.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_a_left_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_a_right_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powline_wire_ab_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlineb_ep1.p3d",
        "fixes\buildings\misc\zavora_2.p3d",
        "mbg_buildings_3\m\garden\mbg_outdoortable.p3d",
        "mbg_buildings_3\m\misc\mbg_garage_single_b.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "aif_napfobjects\aif_arma1buildings\aif_hlaska.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\misc2\barrack2\barrack2.p3d",
        "ca\misc3\fort_watchtower.p3d",
        "ca\misc3\wf\wf_depot.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_barracks_l.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "ca\structures\mil\mil_house.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_shoothouse_1.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_warehouse.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_base.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_tower.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\buildings\budova4_in.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_warehouse.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_base.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "aif_napfobjects\aif_arma1buildings\aif_hlaska.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\roads2\runway_end15.p3d",
        "ca\roads2\runway_end33.p3d",
        "ca\roads2\runway_main.p3d",
        "ca\roads2\runway_poj_t_2.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_base.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_tower.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\roads2\runway_end15.p3d",
        "ca\roads2\runway_end33.p3d",
        "ca\roads2\runway_main.p3d",
        "ca\roads2\runway_poj_t_2.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_base.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_tower.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "aif_napfobjects\aif_arma1buildings\aif_heavyf.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_kasarna.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_kasarna_prujezd.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_kasarna_rohova.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_ryb_domek.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_tovarna1.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_watertower1.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_zluty_statek_in.p3d",
        "aif_napfobjects\aif_arma1buildings\shouse.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\church_01\church_01.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\farm_wtower\farm_wtower.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_1.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_2.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a2.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a2_1.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a3.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b1.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b2.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b3.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b5.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b6.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c1.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c2.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c3.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c4.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c5.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d1.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d2.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_end.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_main.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\buildings\afbarabizna.p3d",
        "ca\buildings\bouda1.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\bouda3.p3d",
        "ca\buildings\bouda_plech.p3d",
        "ca\buildings\cihlovej_dum_in.p3d",
        "ca\buildings\deutshe.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\domek_rosa.p3d",
        "ca\buildings\dulni_bs.p3d",
        "ca\buildings\dum_mesto2.p3d",
        "ca\buildings\dum_mesto2l.p3d",
        "ca\buildings\dum_mesto3.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_olezlina.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\dum_zboreny.p3d",
        "ca\buildings\dum_zboreny_total.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\hruzdum.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\komin.p3d",
        "ca\buildings\kostel.p3d",
        "ca\buildings\kostel3.p3d",
        "ca\buildings\kostel_trosky.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\sara_domek_kovarna.p3d",
        "ca\buildings\sara_domek_podhradi_1.p3d",
        "ca\buildings\sara_domek_ruina.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_vilka.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_hasic_zbroj.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\buildings\statek_hl_bud.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures\a_municipaloffice\a_municipaloffice.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\church_05r\church_05r.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\house\housev2\housev2_01a.p3d",
        "ca\structures\house\housev2\housev2_01a_dam.p3d",
        "ca\structures\house\housev2\housev2_01b.p3d",
        "ca\structures\house\housev2\housev2_01b_dam.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_03.p3d",
        "ca\structures\house\housev2\housev2_03_dam.p3d",
        "ca\structures\house\housev2\housev2_03_ruins.p3d",
        "ca\structures\house\housev2\housev2_03b.p3d",
        "ca\structures\house\housev2\housev2_03b_dam.p3d",
        "ca\structures\house\housev2\housev2_03b_ruins.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev2\housev2_04_interier_dam.p3d",
        "ca\structures\house\housev2\housev2_04_ruins.p3d",
        "ca\structures\house\housev2\housev2_05.p3d",
        "ca\structures\house\housev2\housev2_05_ruins.p3d",
        "ca\structures\house\housev\housev_1i1.p3d",
        "ca\structures\house\housev\housev_1i2.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_1l1.p3d",
        "ca\structures\house\housev\housev_1t.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures\house\housev\housev_2l_dam.p3d",
        "ca\structures\house\housev\housev_2l_dam_ruins.p3d",
        "ca\structures\house\housev\housev_2t1.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "ca\structures\house\housev\housev_3i1.p3d",
        "ca\structures\house\housev\housev_3i2.p3d",
        "ca\structures\house\housev\housev_3i3.p3d",
        "ca\structures\house\housev\housev_3i4.p3d",
        "ca\structures\ind\ind_stack_big.p3d",
        "ca\structures\ind_quarry\ind_quarry.p3d",
        "ca\structures\nav_pier\nav_pier_m.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_apartments_big_01.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_apartments_big_04.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_brickhouse_01.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_brickhouse_03.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_1.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_2.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_3.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_4.p3d",
        "mbg_buildings_2\m\buildings\mbg_radiotelescope.p3d",
        "mbg_buildings_3\m\airport\mbg_atc_segment.p3d",
        "mbg_buildings_3\m\commercial\mbg_ger_pub_2.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_estate_2.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_hus_4.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_rhus_1.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_rhus_2.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_rhus_5.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "aif_napfobjects\aif_arma1buildings\aif_heavyf.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_tovarna1.p3d",
        "aif_napfobjects\aif_arma1buildings\aif_zluty_statek_in.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\church_01\church_01.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\cihlovej_dum_in.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\hruzdum.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\house\housev2\housev2_01a_dam.p3d",
        "ca\structures\house\housev2\housev2_01b_dam.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev2\housev2_04_interier_dam.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housek\terrace_k_1_ep1.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_apartments_big_01.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_apartments_big_04.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_brickhouse_01.p3d",
        "mbg\mbg_generic_african_buildings\house\mbg_brickhouse_03.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_1.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_2.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_3.p3d",
        "mbg\mbg_killhouses_a3\m\mbg_killhouse_4.p3d",
        "mbg_buildings_3\m\commercial\mbg_ger_pub_2.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_hus_4.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_rhus_1.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_rhus_2.p3d",
        "mbg_buildings_3\m\housing\mbg_ger_rhus_5.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\buildings\trafostanica_velka_draty.p3d",
        "ca\misc3\powergenerator\powergenerator.p3d",
        "ca\structures_e\misc\misc_powerline\powlinea_ep1.p3d",
        "ca\structures_e\misc\misc_powerline\powlines_transformer1_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\structures\nav\nav_lighthouse.p3d",
        "ca\structures\nav\nav_lighthouse2.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d",
        "ca\structures\nav_pier\nav_pier_c.p3d",
        "ca\structures\nav_pier\nav_pier_c2.p3d",
        "ca\structures\nav_pier\nav_pier_c2_end.p3d",
        "ca\structures\nav_pier\nav_pier_c_90.p3d",
        "ca\structures\nav_pier\nav_pier_c_r.p3d",
        "ca\structures\nav_pier\nav_pier_c_t15.p3d",
        "ca\structures\nav_pier\nav_pier_f_23.p3d",
        "ca\structures\nav_pier\nav_pier_m.p3d",
        "ca\structures\nav_pier\nav_pier_m_1.p3d",
        "ca\structures\nav_pier\nav_pier_m_end.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d",
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "ca\buildings\misc\leseni2x.p3d",
        "ca\buildings\misc\leseni4x.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d"
    ];

};

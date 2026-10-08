// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: sfp_sturko (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "sfp_sturko") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings2\shed_small\shed_m02.p3d",
        "ca\buildings\molo_krychle.p3d",
        "ca\buildings\sara_domek_vilka.p3d",
        "ca\misc\danger!.p3d",
        "ca\roads2\asf1_10 100.p3d",
        "ca\roads2\asf1_10 50.p3d",
        "ca\roads2\asf1_10 75.p3d",
        "ca\roads2\asf2_10 25.p3d",
        "ca\roads2\asf2_10 50.p3d",
        "ca\roads2\asf2_10 75.p3d",
        "ca\roads2\path_10 25.p3d",
        "ca\roads2\path_10 50.p3d",
        "ca\structures\misc\armory\checkered_flag\checkered_flag.p3d",
        "ca\structures\nav_pier\nav_pier_pneu.p3d",
        "ca\structures\nav_pier\nav_wave_breaker.p3d",
        "ca\structures\wall\wall_woodvil_pole.p3d",
        "sfp_bas90\gate_low_l_twy.p3d",
        "sfp_bas90\gate_low_r_twy.p3d",
        "sfp_bas90\main_rwy.p3d",
        "sfp_bas90\main_rwy_2stripes.p3d",
        "sfp_bas90\main_rwy_3stripes.p3d",
        "sfp_bas90\main_rwy_block.p3d",
        "sfp_bas90\main_rwy_end.p3d",
        "sfp_bas90\main_rwy_h.p3d",
        "sfp_bas90\rwy_end2.p3d",
        "sfp_bas90\rwy_end2_mirror.p3d",
        "sfp_bas90\twy_1.p3d",
        "sfp_bas90\twy_1_curve.p3d",
        "sfp_bas90\twy_1_curve2.p3d",
        "sfp_bas90\twy_1_curve3.p3d",
        "sfp_bas90\twy_1_wide.p3d",
        "sfp_bas90\twy_1_wide_x.p3d",
        "sfp_bas90\twy_1_wide_x_2.p3d",
        "sfp_bas90\twy_1_y_crossing.p3d",
        "sfp_bas90\twy_1_y_crossing_2.p3d",
        "sfp_bas90\twy_1_y_crossing_3.p3d",
        "sfp_bas90\twy_1_y_crossing_4.p3d",
        "sfp_bas90\twy_1_y_crossing_mirror.p3d",
        "sfp_bas90\twy_hangar_detour_pt1.p3d",
        "sfp_bas90\twy_hangar_detour_pt2.p3d",
        "sfp_bas90\twy_hangar_detour_pt3.p3d",
        "sfp_bas90\twy_hangar_detour_pt4.p3d",
        "sfp_bas90\twy_split.p3d",
        "sfp_bas90\twy_split_mirror.p3d",
        "sfp_objects\gasefjarden\sfp_bridgememorial.p3d",
        "sfp_objects\gasefjarden\sfp_football_goal.p3d",
        "sfp_objects\gasefjarden\sfp_parking_asfalt_3x6.p3d",
        "sfp_objects\houses\outhouse\sfp_outhouse.p3d",
        "sfp_objects\houses\shed\sfp_shed1.p3d",
        "sfp_objects\houses\shed\sfp_shed2.p3d",
        "sfp_objects\houses\shed\sfp_shed3.p3d",
        "sfp_objects\military\airbase\vroad_rvy_25.p3d",
        "sfp_objects\military\sfp_gate.p3d",
        "sfp_objects\military\sfp_kassun.p3d",
        "sfp_objects\misc\basketball_basket.p3d",
        "sfp_objects\misc\sfp_3_arches.p3d",
        "sfp_objects\misc\sfp_altan_open.p3d",
        "sfp_objects\misc\sfp_bench1.p3d",
        "sfp_objects\misc\sfp_bench2.p3d",
        "sfp_objects\misc\sfp_dustbin1.p3d",
        "sfp_objects\misc\sfp_electric_cabinet1.p3d",
        "sfp_objects\misc\sfp_grill1.p3d",
        "sfp_objects\misc\sfp_hammock.p3d",
        "sfp_objects\misc\sfp_life_buoy1.p3d",
        "sfp_objects\misc\sfp_lightpole_cone.p3d",
        "sfp_objects\misc\sfp_post_box_arch.p3d",
        "sfp_objects\misc\sfp_post_box_finarvas.p3d",
        "sfp_objects\misc\sfp_post_box_granq.p3d",
        "sfp_objects\misc\sfp_post_box_grip.p3d",
        "sfp_objects\misc\sfp_post_box_joel.p3d",
        "sfp_objects\misc\sfp_post_box_julvort.p3d",
        "sfp_objects\misc\sfp_post_box_kent.p3d",
        "sfp_objects\misc\sfp_post_box_mossa.p3d",
        "sfp_objects\misc\sfp_post_box_shadow.p3d",
        "sfp_objects\misc\sfp_post_box_steelrat.p3d",
        "sfp_objects\misc\sfp_post_box_subroc.p3d",
        "sfp_objects\misc\sfp_post_box_villa_3_row.p3d",
        "sfp_objects\misc\sfp_post_box_villa_metal1.p3d",
        "sfp_objects\misc\sfp_post_box_villa_plastic1.p3d",
        "sfp_objects\misc\sfp_post_box_woop.p3d",
        "sfp_objects\misc\sfp_semi_trailer.p3d",
        "sfp_objects\misc\sfp_sundial.p3d",
        "sfp_objects\misc\sfp_swingset.p3d",
        "sfp_objects\misc\sfp_toy_excavator.p3d",
        "sfp_objects\misc\sfp_villa_fence1_end.p3d",
        "sfp_objects\misc\sfp_villa_fence1_str.p3d",
        "sfp_objects\misc\sfp_wooden_barrier.p3d",
        "sfp_objects\roads\asphalt_gas_stn_2.p3d",
        "sfp_objects\roads\asphalt_str_5x30m.p3d",
        "sfp_objects\roads\gravel_x_3x4m.p3d",
        "sfp_objects\roads\sfp_bridge1_flat.p3d",
        "sfp_objects\roads\sfp_bridge1_middle2.p3d",
        "sfp_objects\roads\sfp_bridge1_up_down.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\buildings\budova1.p3d",
        "ca\buildings\budova4.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "sfp_bas90\park_l.p3d",
        "sfp_bas90\park_tp.p3d",
        "sfp_objects\military\ammo_depot\sfp_ammo_depot.p3d",
        "sfp_objects\military\barracks\sfp_barracks.p3d",
        "sfp_objects\military\bullet_catcher\sfp_bullet_catcher.p3d",
        "sfp_objects\military\coastal_artillery\sfp_12cm_gun.p3d",
        "sfp_objects\military\diner\sfp_mil_diner.p3d",
        "sfp_objects\military\fuel_depot\sfp_burried_fuel_depot.p3d",
        "sfp_objects\military\hangar\sfp_torebodahangar.p3d",
        "sfp_objects\military\mil_shed\sfp_mil_shed.p3d",
        "sfp_objects\military\mine_station\sfp_mine_station.p3d",
        "sfp_objects\military\mob_storage\sfp_mob_storage.p3d",
        "sfp_objects\military\radar\sfp_ps870.p3d",
        "sfp_objects\military\sfp_firingrange.p3d",
        "sfp_objects\military\telemetry_tower\sfp_telemetry_tower.p3d",
        "sfp_objects\military\wet_room\sfp_wet_room.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\buildings\hangar_2.p3d",
        "sfp_bas90\park_l.p3d",
        "sfp_bas90\park_tp.p3d",
        "sfp_objects\military\mil_shed\sfp_mil_shed.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "ca\buildings\budova1.p3d",
        "ca\buildings\hangar_2.p3d",
        "sfp_objects\military\ammo_depot\sfp_ammo_depot.p3d",
        "sfp_objects\military\mil_shed\sfp_mil_shed.p3d",
        "sfp_objects\military\mob_storage\sfp_mob_storage.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "sfp_objects\military\barracks\sfp_barracks.p3d",
        "sfp_objects\military\diner\sfp_mil_diner.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "sfp_bas90\park_l.p3d",
        "sfp_bas90\park_tp.p3d",
        "sfp_objects\military\airbase\main_rvy_25.p3d",
        "sfp_objects\military\hangar\sfp_torebodahangar.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "sfp_bas90\park_l.p3d",
        "sfp_bas90\park_tp.p3d",
        "sfp_objects\military\airbase\main_rvy_25.p3d",
        "sfp_objects\military\hangar\sfp_torebodahangar.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_1.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
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
        "ca\buildings\budova2.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\domek_rosa.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\garaz_mala.p3d",
        "ca\buildings\komin.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\molo_beton.p3d",
        "ca\buildings\sara_domek_kovarna.p3d",
        "ca\buildings\sara_domek_ruina.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_vilka.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_hasic_zbroj.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\buildings\sara_stodola3.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\housev2\housev2_01a.p3d",
        "ca\structures\house\housev2\housev2_01b.p3d",
        "ca\structures\house\housev2\housev2_02.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_03.p3d",
        "ca\structures\house\housev2\housev2_03b.p3d",
        "ca\structures\house\housev2\housev2_04.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev2\housev2_05.p3d",
        "ca\structures\house\housev\housev_1i1.p3d",
        "ca\structures\house\housev\housev_1i2.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_1l1.p3d",
        "ca\structures\house\housev\housev_1t.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "ca\structures\house\housev\housev_3i2.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "sfp_objects\houses\apartment\sfp_2tr_apartment_2.p3d",
        "sfp_objects\houses\bank\sfp_bank.p3d",
        "sfp_objects\houses\brickhouse\sfp_brickhouse.p3d",
        "sfp_objects\houses\cabins\sfp_cabin.p3d",
        "sfp_objects\houses\cabins\sfp_cabin_yellow.p3d",
        "sfp_objects\houses\church\sfp_church.p3d",
        "sfp_objects\houses\cowhouse\sfp_cow_house_1.p3d",
        "sfp_objects\houses\cowhouse\sfp_cow_house_1_2.p3d",
        "sfp_objects\houses\cowhouse\sfp_cow_house_2.p3d",
        "sfp_objects\houses\cowhouse\sfp_cow_house_3.p3d",
        "sfp_objects\houses\cowhouse\sfp_cow_house_3_2.p3d",
        "sfp_objects\houses\garages\sfp_garage_house02.p3d",
        "sfp_objects\houses\garages\sfp_garage_house02_red.p3d",
        "sfp_objects\houses\garages\sfp_garage_house02_white.p3d",
        "sfp_objects\houses\house01\sfp_house01.p3d",
        "sfp_objects\houses\mill\sfp_mill.p3d",
        "sfp_objects\houses\policestation\sfp_policestation.p3d",
        "sfp_objects\houses\school\sfp_school.p3d",
        "sfp_objects\houses\sfp_camping_reception.p3d",
        "sfp_objects\houses\sfp_farmhouse_2.p3d",
        "sfp_objects\houses\shop01\sfp_shop01.p3d",
        "sfp_objects\houses\stable\sfp_stable.p3d",
        "sfp_objects\houses\subylla\sfp_subylla.p3d",
        "sfp_objects\houses\summerhouse\sfp_summerhouse1.p3d",
        "sfp_objects\houses\summerhouse\sfp_summerhouse2.p3d",
        "sfp_objects\houses\townhouse\sfp_townhouse_center1.p3d",
        "sfp_objects\houses\townhouse\sfp_townhouse_left1.p3d",
        "sfp_objects\houses\townhouse\sfp_townhouse_right1.p3d",
        "sfp_objects\houses\wooden_house01\sfp_wooden_house01.p3d",
        "sfp_objects\houses\wooden_house01\sfp_wooden_house01_red.p3d",
        "sfp_objects\houses\wooden_house01\sfp_wooden_house01_white.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_red.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_w_garage.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_w_garage_x.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_white.p3d",
        "sfp_objects\houses\wooden_house03\sfp_wooden_house03.p3d",
        "sfp_objects\houses\wooden_house04\sfp_wooden_house04.p3d",
        "sfp_objects\industry\gasstation\sfp_gasstation_building.p3d",
        "sfp_objects\industry\truck_garage\sfp_truck_garage.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\structures\house\a_office01\a_office01.p3d",
        "sfp_objects\houses\apartment\sfp_2tr_apartment_2.p3d",
        "sfp_objects\houses\bank\sfp_bank.p3d",
        "sfp_objects\houses\policestation\sfp_policestation.p3d",
        "sfp_objects\houses\school\sfp_school.p3d",
        "sfp_objects\houses\sfp_camping_reception.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\structures\barn_w\barn_w_01.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\housev2\housev2_02.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_04.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "sfp_objects\houses\bank\sfp_bank.p3d",
        "sfp_objects\houses\sfp_farmhouse_2.p3d",
        "sfp_objects\houses\shop01\sfp_shop01.p3d",
        "sfp_objects\houses\townhouse\sfp_townhouse_center1.p3d",
        "sfp_objects\houses\townhouse\sfp_townhouse_left1.p3d",
        "sfp_objects\houses\townhouse\sfp_townhouse_right1.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_red.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_w_garage.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_w_garage_x.p3d",
        "sfp_objects\houses\wooden_house02\sfp_wooden_house02_white.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "sfp_objects\misc\sfp_transformer_station.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "sfp_objects\military\radar\sfp_ps870.p3d",
        "sfp_objects\military\telemetry_tower\sfp_telemetry_tower.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\structures\nav\nav_lighthouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d",
        "ca\structures\nav_pier\nav_pier_c.p3d",
        "sfp_objects\houses\boathouse\sfp_boathouse.p3d",
        "sfp_objects\military\mine_station\sfp_mine_station.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "sfp_objects\industry\gasstation\sfp_gasstation_building.p3d",
        "sfp_objects\industry\gasstation\sfp_gasstation_pumps.p3d",
        "sfp_objects\military\fuel_depot\sfp_burried_fuel_depot.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d"
    ];

};

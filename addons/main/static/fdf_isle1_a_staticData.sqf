// ALiVE 3 index v3.1, made 2026-10-09 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: fdf_isle1_a (ALiVE 3 index v3.1, 2026-10-09)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-09", "web", true];

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

 if (tolower(_worldName) == "fdf_isle1_a") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings2\a_advertisingcolumn\a_advertcolumn.p3d",
        "ca\buildings2\a_crane_02\crane_rails.p3d",
        "ca\buildings2\a_crane_02\crane_rails_end.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1e.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1f.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1g.p3d",
        "ca\buildings2\misc_cargo\seacrate.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings2\shed_small\shed_m02.p3d",
        "ca\buildings\misc\hrobecek.p3d",
        "ca\buildings\misc\zavora_2.p3d",
        "ca\buildings\molo_krychle.p3d",
        "ca\characters2\other\doctor_hanged.p3d",
        "ca\characters2\other\hanged.p3d",
        "ca\characters2\other\massgrave.p3d",
        "ca\data\krater.p3d",
        "ca\fdf_obj_a\misc\misc_1.p3d",
        "ca\fdf_obj_a\misc\misc_2.p3d",
        "ca\misc2\bagfenceround.p3d",
        "ca\misc2\bighbarrier.p3d",
        "ca\misc2\samsite\76n6_clamshell.p3d",
        "ca\misc\snowman.p3d",
        "ca\roads2\asf1_10 100.p3d",
        "ca\roads2\asf1_10 50.p3d",
        "ca\roads2\asf1_10 75.p3d",
        "ca\roads2\asf2_10 25.p3d",
        "ca\roads2\asf2_10 50.p3d",
        "ca\roads2\asf2_10 75.p3d",
        "ca\roads2\dam\dam_conc\dam_concp_20.p3d",
        "ca\roads2\path_10 100.p3d",
        "ca\roads2\path_10 25.p3d",
        "ca\roads2\path_10 50.p3d",
        "ca\roads2\path_10 75.p3d",
        "ca\roads2\runwayold_40_main.p3d",
        "ca\structures\house\church_cross\church_cross_1.p3d",
        "ca\structures\house\church_cross\church_cross_1a.p3d",
        "ca\structures\ind_quarry\ind_hammermill.p3d",
        "ca\structures\nav_pier\nav_pier_c_l30.p3d",
        "ca\structures\nav_pier\nav_pier_c_r10.p3d",
        "ca\structures\nav_pier\nav_pier_c_r30.p3d",
        "ca\structures\rail\rail_loco\loco_742_blue.p3d",
        "ca\structures\rail\rail_loco\loco_742_red.p3d",
        "ca\structures\rail\rail_misc\rail_najazdovarampa.p3d",
        "ca\structures\rail\rail_platform\rail_platform_cross.p3d",
        "ca\structures\rail\rail_platform\rail_platform_segment.p3d",
        "ca\structures\rail\rail_platform\rail_platform_start.p3d",
        "ca\structures\rail\rail_wagon\wagon_box.p3d",
        "ca\structures\rail\rail_wagon\wagon_flat.p3d",
        "ca\structures\rail\rail_wagon\wagon_tanker.p3d",
        "ca\structures\wall\walls_end_half.p3d",
        "ca\water2\fregata\fregata.p3d",
        "ca\water2\lhd\lhd_1.p3d",
        "ca\water2\lhd\lhd_2.p3d",
        "ca\water2\lhd\lhd_3.p3d",
        "ca\water2\lhd\lhd_4.p3d",
        "ca\water2\lhd\lhd_5.p3d",
        "ca\water2\lhd\lhd_6.p3d",
        "ca\water2\lhd\lhd_house_1.p3d",
        "ca\water2\lhd\lhd_house_2.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\misc2\barrack2\barrack2.p3d",
        "ca\misc2\samsite\76n6_clamshell_lower.p3d",
        "ca\misc3\camonetb_east.p3d",
        "ca\misc3\fort_artillery_nest.p3d",
        "ca\misc3\fort_watchtower.p3d",
        "ca\misc3\fortified_nest_big.p3d",
        "ca\misc3\wf\wf_heliport_east.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_barracks_l.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\water2\destroyer\destroyer.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc3\fortified_nest_big.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
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
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b2.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b3.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b4.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b5.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b6.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c1.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c2.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c3.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c4.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c5.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d1.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_box.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\molo_beton.p3d",
        "ca\structures\a_municipaloffice\a_municipaloffice.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital_ruins.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\church_02\church_02.p3d",
        "ca\structures\house\church_02\church_02_ruins.p3d",
        "ca\structures\house\church_02\church_02a.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\church_05r\church_05r.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\house\housev2\housev2_01a.p3d",
        "ca\structures\house\housev2\housev2_01b.p3d",
        "ca\structures\house\housev2\housev2_02.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_02_ruins.p3d",
        "ca\structures\house\housev2\housev2_03.p3d",
        "ca\structures\house\housev2\housev2_03b.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev2\housev2_05.p3d",
        "ca\structures\house\housev\housev_1i1.p3d",
        "ca\structures\house\housev\housev_1i2.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_1l1.p3d",
        "ca\structures\house\housev\housev_1t.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures\house\housev\housev_2l_ruins.p3d",
        "ca\structures\house\housev\housev_2t1.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "ca\structures\house\housev\housev_3i1.p3d",
        "ca\structures\house\housev\housev_3i2.p3d",
        "ca\structures\house\housev\housev_3i3.p3d",
        "ca\structures\house\housev\housev_3i4.p3d",
        "ca\structures\house\housev\housev_3i4_ruins.p3d",
        "ca\structures\ind\ind_stack_big.p3d",
        "ca\structures\ind_quarry\ind_quarry.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\structures\shed\shed_small\shed_w4_ruins.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\church_02\church_02a.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
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
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\church_02\church_02a.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\house\housev2\housev2_02.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev\housev_1i3.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures\house\housev\housev_2t2.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\buildings\trafostanica_velka_draty.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "ca\buildings\vysilac_fm.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\structures\nav\nav_lighthouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d",
        "ca\structures\nav_pier\nav_pier_c.p3d",
        "ca\structures\nav_pier\nav_pier_c2.p3d",
        "ca\structures\nav_pier\nav_pier_c_big.p3d",
        "ca\structures\nav_pier\nav_pier_c_t15.p3d",
        "ca\structures\nav_pier\nav_pier_c_t20.p3d",
        "ca\structures\nav_pier\nav_pier_m_1.p3d",
        "ca\structures\nav_pier\nav_pier_m_end.p3d",
        "ca\water2\destroyer\destroyer.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "ca\buildings2\rail_house_01\rail_house_01.p3d",
        "ca\structures\rail\rail_station_big\rail_station_big.p3d",
        "ca\structures\rail\railway\rails_bridge_40.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "ca\buildings\misc\leseni2x.p3d",
        "ca\buildings\misc\leseni4x.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d"
    ];

};

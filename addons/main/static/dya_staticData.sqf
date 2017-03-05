private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: dya"] call ALIVE_fnc_dump;

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

ALiVE_mapCompositionType = "Desert";

if (tolower(_worldName) == "dya") then {
    [ALIVE_mapBounds, worldName, 9000] call ALIVE_fnc_hashSet;

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "jbad_structures\mil\jbad_mil_guardhouse.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "jbad_structures\mil\jbad_mil_house.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "cype_dya\misc\cype_illuminanttower.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_dam_f.p3d",
        "cype_dya\buildings\cype_policestation.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "jbad_structures\mil\jbad_mil_house.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "jbad_structures\mil\jbad_mil_house.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "cype_dya\buildings\cype_policestation.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_dam_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_dam_f.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "jbad_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v1.p3d",
        "a3\structures_f\households\addons\metal_shed_f.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v3.p3d",
        "jbad_structures\afghan_houses\jbad_house2_basehide.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\ind\ind_garage01\jbad_ind_garage01.p3d",
        "cype_dya\buildings\cype_pec_03.p3d",
        "jbad_structures\ind\ind_powerstation\jbad_ind_powerstation.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_feed.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v3_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_dam.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "jbad_structures\afghan_house_a\a_minaret\jbad_a_minaret.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "cype_dya\rope_bridge\bridge_rope_40m.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_dam.p3d",
        "jbad_structures\afghan_house_a\a_villa\jbad_a_villa.p3d",
        "cype_dya\buildings\cype_shed_wooden.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_dam_f.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "a3\structures_f\households\house_big02\house_big_02_v1_ruins_f.p3d",
        "jbad_structures\generalstore\jbad_a_generalstore_01a_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11_dam.p3d",
        "jbad_structures\ind\ind_shed\jbad_ind_shed_02.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12_ruins.p3d",
        "jbad_structures\generalstore\jbad_a_generalstore_01.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_2.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_hq.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\generalstore\jbad_a_generalstore_01a.p3d",
        "cype_dya\buildings\cype_policestation.p3d",
        "jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_ruins_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5_dam.p3d",
        "cype_dya\misc\cype_oil_tower.p3d",
        "a3\structures_f\ind\shed\shed_small_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\households\addons\i_garage_v1_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_dam_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f\ind\concretemixingplant\cmp_shed_dam_f.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_main.p3d",
        "cype_dya\buildings\cype_pec_02.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_house_a\a_villa\jbad_a_villa.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_hq.p3d",
        "cype_dya\buildings\cype_policestation.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "jbad_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v1.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v3.p3d",
        "jbad_structures\afghan_houses\jbad_house2_basehide.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v3_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_dam.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_dam.p3d",
        "jbad_structures\afghan_house_a\a_villa\jbad_a_villa.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\generalstore\jbad_a_generalstore_01a_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\generalstore\jbad_a_generalstore_01.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_hq.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\generalstore\jbad_a_generalstore_01a.p3d",
        "cype_dya\buildings\cype_policestation.p3d",
        "jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5_dam.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_dam_f.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\powerlines\highvoltageend_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_panel_broken_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",
        "jbad_misc\misc_com\jbad_com_tower.p3d",
        "a3\structures_f\ind\powerlines\highvoltagetower_f.p3d",
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_shed.p3d",
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_build.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_rust_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "jbad_structures\ind\ind_shed\jbad_ind_shed_01.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d",
        "cype_dya\excavator\cype_excavator.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\shed\shed_small_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d"
    ];
};

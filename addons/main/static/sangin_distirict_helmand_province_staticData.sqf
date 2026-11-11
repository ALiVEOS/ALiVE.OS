// ALiVE 3 index v3.1, made 2026-11-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: sangin_distirict_helmand_province (ALiVE 3 index v3.1, 2026-11-11)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-11", "web", true];

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

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "sangin_distirict_helmand_province") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\military\decontamination\powercable_01_corner_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_black_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_green_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_red_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_small_black_f.p3d",
        "a3\props_f_tank\military\tankacc\torquewrench_01_f.p3d",
        "a3\structures_f\training\invisibletarget\center.p3d",
        "hesco\controlcentre.p3d",
        "hesco\enginer.p3d",
        "hesco\hesco tower.p3d",
        "hesco\hesco1x6.p3d",
        "hesco\hesco2x2x6.p3d",
        "hesco\hesco3x3x6.p3d",
        "hesco\hesco3x3x6f.p3d",
        "hesco\hesco3x3x6ramp.p3d",
        "hesco\hesco3x3x6rampf.p3d",
        "hesco\hescobase.p3d",
        "hesco\hescoop.p3d",
        "hesco\livingarea.p3d",
        "hesco\medic.p3d",
        "hesco\reme.p3d",
        "hesco\sangernoroof.p3d",
        "hesco\unloadingbay1.p3d",
        "jbad_misc\billboards\jbad_board6.p3d",
        "jbad_misc\billboards\jbad_poste3.p3d",
        "jbad_misc\misc_dead\jbad_dead.p3d",
        "jbad_misc\misc_opium\jbad_rawopium.p3d",
        "jbad_misc\misc_powerline\jbad_pole_speaker.p3d",
        "jbad_structures\afghan_houses_old\damageproxies\jbad_house_9_stuff.p3d",
        "jbad_structures\walls\wall_l\jbad_wallwin.p3d",
        "smoke\billboards\hellskitchen_billboard1.p3d",
        "smoke\billboards\hellskitchen_billboard2.p3d",
        "smoke\billboards\hellskitchen_billboard3.p3d",
        "smoke\billboards\hellskitchen_billboard4.p3d",
        "smoke\billboards\hellskitchen_billboard5.p3d",
        "smoke\billboards\hellskitchen_billboard6.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_orange\humanitarian\camps\medicaltent_01_f.p3d",
        "a3\structures_f_orange\humanitarian\camps\medicaltent_01_floor_dark_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_cargo_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_medevac_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_repair_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "jbad_structures\mil\jbad_mil_guardhouse.p3d",
        "jbad_structures\mil\jbad_mil_house.p3d",
        "jbad_structures\mil\jbad_mil_repair_center.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_policestation.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_repair_center.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_medevac_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "jbad_structures\mil\jbad_mil_repair_center.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\addons\i_garage_v1_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "jbad_structures\afghan_house_a\a_minaret\jbad_a_minaret.p3d",
        "jbad_structures\afghan_house_a\a_minaret_porto\jbad_a_minaret_porto.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "jbad_structures\afghan_houses\jbad_fp1.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house3_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house5_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house6_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house6_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses\jbad_house7_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house7_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses\jbad_house8_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house8_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses\jbad_terrace.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_h.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_01.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_02.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_03.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_04.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_l.p3d",
        "jbad_structures\shops\jbad_grainstore.p3d",
        "jbad_structures\shops\jbad_grainstore2.p3d",
        "jbad_structures\shops\jbad_grainstore3.p3d",
        "jbad_structures\shops\jbad_shop_01.p3d",
        "jbad_structures\shops\jbad_shop_02.p3d",
        "jbad_structures\shops\jbad_shop_03.p3d",
        "jbad_structures\shops\jbad_shop_04.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "jbad_structures\afghan_house_a\a_minaret_porto\jbad_a_minaret_porto.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_houses\jbad_fp1.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house5_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house6_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses\jbad_house7_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses\jbad_house8_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses\jbad_terrace.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_h.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\shops\jbad_grainstore3.p3d",
        "jbad_structures\shops\jbad_shop_01.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "jbad_structures\ind\ind_powerstation\jbad_ind_powerstation.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_build.p3d",
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_shed.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d"
    ];

};

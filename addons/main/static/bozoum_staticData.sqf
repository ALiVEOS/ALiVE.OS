// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: bozoum (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-06", "web", true];

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

 if (tolower(_worldName) == "bozoum") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_wreck_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_tank_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_small_f.p3d",
        "a3\structures_f\civ\belltowers\belltower_01_v2_f.p3d",
        "a3\structures_f_argo\decals\horizontal\puddle_01_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_4m_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_plain_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_yellow_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_plain_dmg_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_plain_dmg_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_yellow_f.p3d",
        "a3\structures_f_argo\walls\net\netfence_02_m_gate_v2_closed_f.p3d",
        "a3\structures_f_argo\walls\pipe\pipefence_01_m_gate_v2_closed_f.p3d",
        "a3\structures_f_argo\walls\tin\tinwall_01_m_gate_v2_closed_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\chickencoop_01_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_pump_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirtpatch_05_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_04_f.p3d",
        "a3\structures_f_enoch\military\training\shootingpos_roof_01_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_03_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_04_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_end_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_gate_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_d_4m_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\commercial\market\woodenshelter_01_ruins_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_02_l_1m_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_gate_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_pole_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_3m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_gate_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_pole_f.p3d",
        "a3\structures_f_heli\civ\constructions\tooltrolley_01_f.p3d",
        "a3\structures_f_heli\civ\constructions\tooltrolley_02_f.p3d",
        "a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d",
        "a3\structures_f_kart\civ\sportsgrounds\oil_spill.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\i_shed_ind_old_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_ruins_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_generator_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d"
    ];

};

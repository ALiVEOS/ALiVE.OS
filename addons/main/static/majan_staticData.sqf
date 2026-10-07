// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: majan (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "majan") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\haultruck_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\miningshovel_01_abandoned_f.p3d",
        "a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_03_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d",
        "a3\structures_f_argo\commercial\fuelstation_01\fuelstation_01_prices_malevil_f.p3d",
        "a3\structures_f_argo\commercial\fuelstation_01\fuelstation_01_roof_malevil_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_blocks_3_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\railings\guardrailing_01_f.p3d",
        "a3\structures_f_kart\civ\sportsgrounds\oil_spill.p3d",
        "ca\buildings2\houseruins\r_shed_ind02.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\podesta_1_cube.p3d",
        "ca\buildings\podesta_s5.p3d",
        "ca\roads2\dam\dam_conc\dam_concp_20.p3d",
        "ca\roads2\runwayold_40_main.p3d",
        "ca\roads_e\sidewalks\sw_c_crosst_ep1.p3d",
        "ca\roads_pmc\sidewalks\sw_c_end_l_pmc.p3d",
        "ca\roads_pmc\sidewalks\sw_c_end_r_pmc.p3d",
        "ca\roads_pmc\sidewalks\sw_c_turn_pmc.p3d",
        "ca\structures\furniture\cases\case_bedroom_a\case_bedroom_a.p3d",
        "ca\structures\ind_quarry\ind_hammermill.p3d",
        "ca\structures\misc\armory\conelight\conelight.p3d",
        "ca\structures\nav_pier\nav_pier_pneu.p3d",
        "ca\structures\rail\rail_misc\rail_najazdovarampa.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ruins_ep1.p3d",
        "ca\structures_e\proxy_buildingparts\house_a\a_villa_ep1_column.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_5m_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l3_pillar_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_1_ruins_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ep1.p3d",
        "ca\structures_e\wall\wall_l\wall_l_mosque_2_ruins_ep1.p3d",
        "ffaa_casas_af\ffaa_cubierto_madera.p3d",
        "majan_obj\aizdihar.p3d",
        "majan_obj\alabjadia.p3d",
        "majan_obj\alaishab.p3d",
        "majan_obj\alikhwa.p3d",
        "majan_obj\alkun.p3d",
        "majan_obj\almaladh.p3d",
        "majan_obj\alnufus.p3d",
        "majan_obj\alqabalat.p3d",
        "majan_obj\anyrjia.p3d",
        "majan_obj\bank.p3d",
        "majan_obj\bashri.p3d",
        "majan_obj\eahira.p3d",
        "majan_obj\haya.p3d",
        "majan_obj\hilal.p3d",
        "majan_obj\industrial.p3d",
        "majan_obj\insurance.p3d",
        "majan_obj\m_flag.p3d",
        "majan_obj\malevil_1.p3d",
        "majan_obj\malevil_2.p3d",
        "majan_obj\malevil_3.p3d",
        "majan_obj\mihna.p3d",
        "majan_obj\muraqib.p3d",
        "majan_obj\royal.p3d",
        "majan_obj\sadiq.p3d",
        "majan_obj\shams.p3d",
        "majan_obj\suq.p3d",
        "majan_obj\tijara.p3d",
        "majan_obj\toyota.p3d",
        "majan_obj\up.p3d",
        "majan_obj\wasia.p3d",
        "majan_obj\welcome.p3d",
        "majan_obj\zizaf.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\misc_e\tent_east_ep1.p3d",
        "ca\structures_e\mil\mil_guardhouse_ep1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "ca\buildings\hangar_2.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "ca\buildings\hangar_2.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_dam_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings2\shed_small\shed_m02_ruins.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\buildings\dum_istan3.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\podesta_1_stairs2.p3d",
        "ca\buildings\ruins\hut_old02_ruins.p3d",
        "ca\buildings\watertower1.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures\shed_ind\shed_ind02_dam.p3d",
        "ca\structures_e\housea\a_citygate1\a_citygate1_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d",
        "ca\structures_e\housea\a_minaret\a_minaret_ruins_ep1.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_dam_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_dam_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ruins_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_dam_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ruins_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_6_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_8_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "ca\structures_pmc\buildings\generalstore\generalstore_01a_pmc.p3d",
        "ca\structures_pmc\ind\hopper_old_ruins_pmc.p3d",
        "ca\structures_pmc\misc\shed\shed_w02_pmc.p3d",
        "ffaa_casas_af\ffaa_casa_af_1.p3d",
        "ffaa_casas_af\ffaa_casa_af_10.p3d",
        "ffaa_casas_af\ffaa_casa_af_10_a.p3d",
        "ffaa_casas_af\ffaa_casa_af_11.p3d",
        "ffaa_casas_af\ffaa_casa_af_2.p3d",
        "ffaa_casas_af\ffaa_casa_af_3.p3d",
        "ffaa_casas_af\ffaa_casa_af_3_a.p3d",
        "ffaa_casas_af\ffaa_casa_af_4.p3d",
        "ffaa_casas_af\ffaa_casa_af_4_a.p3d",
        "ffaa_casas_af\ffaa_casa_af_5.p3d",
        "ffaa_casas_af\ffaa_casa_af_6.p3d",
        "ffaa_casas_af\ffaa_casa_af_7.p3d",
        "ffaa_casas_af\ffaa_casa_af_8.p3d",
        "ffaa_casas_af\ffaa_casa_af_9.p3d",
        "ffaa_casas_af\ffaa_casa_barracon_2.p3d",
        "ffaa_casas_af\ffaa_casa_hangar_2.p3d",
        "ffaa_casas_af\ffaa_casa_sha_1.p3d",
        "ffaa_casas_af\ffaa_casa_sha_2.p3d",
        "ffaa_casas_af\ffaa_casa_sha_3.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_1.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_2.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_3.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_4.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_5.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_7.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_7_a.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_8.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ffaa_casas_af\ffaa_casa_af_1.p3d",
        "ffaa_casas_af\ffaa_casa_af_10.p3d",
        "ffaa_casas_af\ffaa_casa_af_5.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_dam_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ruins_ep1.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_10_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_dam_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "ca\structures_e\housek\house_k_5_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_6_dam_ep1.p3d",
        "ca\structures_e\housek\house_k_8_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_4_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_8_dam_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_pmc\buildings\generalstore\generalstore_01a_pmc.p3d",
        "ffaa_casas_af\ffaa_casa_af_1.p3d",
        "ffaa_casas_af\ffaa_casa_af_10.p3d",
        "ffaa_casas_af\ffaa_casa_af_10_a.p3d",
        "ffaa_casas_af\ffaa_casa_af_11.p3d",
        "ffaa_casas_af\ffaa_casa_af_2.p3d",
        "ffaa_casas_af\ffaa_casa_af_3.p3d",
        "ffaa_casas_af\ffaa_casa_af_3_a.p3d",
        "ffaa_casas_af\ffaa_casa_af_4.p3d",
        "ffaa_casas_af\ffaa_casa_af_4_a.p3d",
        "ffaa_casas_af\ffaa_casa_af_5.p3d",
        "ffaa_casas_af\ffaa_casa_af_6.p3d",
        "ffaa_casas_af\ffaa_casa_af_7.p3d",
        "ffaa_casas_af\ffaa_casa_af_8.p3d",
        "ffaa_casas_af\ffaa_casa_af_9.p3d",
        "ffaa_casas_af\ffaa_casa_barracon_2.p3d",
        "ffaa_casas_af\ffaa_casa_hangar_2.p3d",
        "ffaa_casas_af\ffaa_casa_sha_1.p3d",
        "ffaa_casas_af\ffaa_casa_sha_2.p3d",
        "ffaa_casas_af\ffaa_casa_sha_3.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_1.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_2.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_3.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_4.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_5.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_7.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_7_a.p3d",
        "ffaa_casas_af\ffaa_casa_urbana_8.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_chimney_f.p3d",
        "ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "ca\buildings\telek1.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f_argo\commercial\fuelstation_01\fuelstation_01_pump_malevil_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_small_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_medium_f.p3d",
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d",
        "ca\buildings\fuelstation.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_clarifier_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "ca\buildings\misc\leseni2x.p3d",
        "ca\buildings\misc\leseni4x.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d"
    ];

};

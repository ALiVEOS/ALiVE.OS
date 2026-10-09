// ALiVE 3 index v3.1, made 2026-10-09 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: hindukush (ALiVE 3 index v3.1, 2026-10-09)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "hindukush") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_rust_ruins_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_3_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall4_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall6_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall_corner_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall_corridor_f.p3d",
        "a3\structures_f\walls\mil_wallbig_gate_f.p3d",
        "a3\structures_f_bootcamp\items\food\foodcontainer_01_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_blue_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_khaki_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_yellow_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_02_f.p3d",
        "a3\structures_f_heli\civ\constructions\mobilescafolding_01_f.p3d",
        "a3\structures_f_heli\civ\constructions\tooltrolley_01_f.p3d",
        "a3\structures_f_heli\civ\constructions\tooltrolley_02_f.p3d",
        "a3\structures_f_heli\civ\constructions\weldingtrolley_01_f.p3d",
        "a3\structures_f_heli\civ\market\pallettrolley_01_khaki_f.p3d",
        "a3\structures_f_heli\ind\airport\mobilelandingplatform_01_f.p3d",
        "a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d",
        "a3\structures_f_heli\items\airport\airintakeplug_01_f.p3d",
        "a3\structures_f_heli\items\airport\airintakeplug_03_f.p3d",
        "a3\structures_f_heli\items\airport\airintakeplug_05_f.p3d",
        "a3\structures_f_heli\items\airport\helicopterwheels_01_disassembled_f.p3d",
        "a3\structures_f_heli\items\airport\portablehelipadlight_01_f.p3d",
        "a3\structures_f_heli\items\airport\rotorcoversbag_01_f.p3d",
        "a3\structures_f_heli\items\food\ketchup_01_f.p3d",
        "a3\structures_f_heli\items\food\mustard_01_f.p3d",
        "a3\structures_f_heli\items\food\tableware_01_cup_f.p3d",
        "a3\structures_f_heli\items\food\tableware_01_stackofnapkins_f.p3d",
        "a3\structures_f_heli\items\tools\rope_01_f.p3d",
        "a3\structures_f_heli\items\tools\wheelchock_01_f.p3d",
        "a3\supplies_f_heli\cargonets\cargonet_01_box_f.p3d",
        "a3\supplies_f_heli\fuel\flexibletank_01_f.p3d",
        "jbad_misc\misc_furniture\jbad_dkamna_bila.p3d",
        "jbad_misc\misc_interier\jbad_cabinet.p3d",
        "jbad_misc\misc_interier\jbad_carpet.p3d",
        "jbad_misc\misc_interier\jbad_carpet_2.p3d",
        "jbad_misc\misc_interier\jbad_carpet_wall.p3d",
        "jbad_misc\misc_interier\jbad_carpet_wallv2.p3d",
        "jbad_misc\misc_interier\jbad_carpetv2.p3d",
        "jbad_misc\misc_interier\jbad_chest.p3d",
        "jbad_misc\misc_interier\jbad_cloth.p3d",
        "jbad_misc\misc_interier\jbad_curtain.p3d",
        "jbad_misc\misc_interier\jbad_pillow.p3d",
        "jbad_misc\misc_interier\jbad_pillowv2.p3d",
        "jbad_misc\misc_interier\jbad_rack.p3d",
        "jbad_misc\misc_market\jbad_counter.p3d",
        "jbad_misc\misc_market\jbad_sunshade.p3d",
        "jbad_misc\misc_rivers\riverwide.p3d",
        "jbad_misc\misc_rivers\stream6wide_dirt.p3d",
        "jbad_structures\afghan_house_a\a_villa\proxies\a_villa_unhide1_ep1.p3d",
        "jbad_structures\afghan_house_a\a_villa\proxies\a_villa_unhide2_ep1.p3d",
        "jbad_structures\afghan_house_a\a_villa\proxies\a_villa_unhide3_ep1.p3d",
        "jbad_structures\afghan_houses_old\damageproxies\jbad_house_4_dam1.p3d",
        "jbad_structures\afghan_houses_old\damageproxies\jbad_house_7_dam1.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_10.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_end.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_main.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv2.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_hopper.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_main_part2.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail_switch.p3d",
        "jbad_structures\ind\ind_coltan_mine\proxies\jbad_ind_coltan_conv1_end_add.p3d",
        "jbad_structures\ind\ind_coltan_mine\proxies\jbad_ind_coltan_conv2_add.p3d",
        "jbad_structures\ind\ind_shed\jbad_ind_shed_01.p3d",
        "jbad_structures\ind\ind_shed\jbad_ind_shed_02.p3d",
        "jbad_structures\mil\proxies\mil_house_room_01_proxy.p3d",
        "jbad_structures\mosque_big\damageproxies\jbad_mosque_small_1_dam_roadway_unhide1.p3d",
        "jbad_structures\mosque_big\damageproxies\jbad_mosque_small_1_dam_roadway_unhide2.p3d",
        "jbad_structures\mosque_big\damageproxies\jbad_mosque_small_1_dam_roadway_unhide3.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_mosque_1.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_mosque_1_dam.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_mosque_1_ruins.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_mosque_2.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_tower_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_dam_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_dam_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_ruins_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "jbad_structures\mil\jbad_mil_controltower_dam.p3d",
        "jbad_structures\mil\jbad_mil_controltower_ruins.p3d",
        "jbad_structures\mil\jbad_mil_guardhouse.p3d",
        "jbad_structures\mil\jbad_mil_guardhouse_ruins.p3d",
        "jbad_structures\mil\jbad_mil_house.p3d",
        "jbad_structures\mil\jbad_mil_house_dam.p3d",
        "jbad_structures\mil\jbad_mil_house_ruins.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "jbad_structures\mil\jbad_mil_controltower_dam.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\jbad_mil_controltower_dam.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\jbad_mil_controltower_dam.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_v1_ruins_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "jbad_structures\afghan_house_a\a_minaret\jbad_a_minaret.p3d",
        "jbad_structures\afghan_house_a\a_minaret\jbad_a_minaret_ruins.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1_ruins.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2_ruins.p3d",
        "jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d",
        "jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house2_basehide.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house3_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
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
        "jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon01.p3d",
        "jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon02.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12_ruins.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2_ruins.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3_ruins.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4_ruins.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_ruins.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_9_old_ruins.p3d",
        "jbad_structures\ind\ind_garage01\jbad_ind_garage01.p3d",
        "jbad_structures\ind\ind_garage01\jbad_ind_garage01_ruins.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_addon.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_addon_ruins.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_hq.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_hq_interier.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_1.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_1_dam.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_2.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_2_dam.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_wall.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_wall_corner.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_wall_gate.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_wall_ruins.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d",
        "jbad_structures\afghan_houses\jbad_house2_basehide.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house6_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses\jbad_house7_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses\jbad_house8_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses\jbad_terrace.p3d",
        "jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon01.p3d",
        "jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon02.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12_dam.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old_dam.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_addon.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_hq.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_hq_interier.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_1.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_2.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_2_dam.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_wall_gate.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "jbad_misc\misc_powerline\jbad_powlines_transformer1.p3d",
        "jbad_structures\ind\ind_powerstation\jbad_ind_powerstation.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail_end.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_build.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_main.p3d"
    ];

};

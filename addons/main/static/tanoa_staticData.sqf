private["_worldName"];
_worldName = tolower(worldName);
["ALiVE SETTING UP MAP: tanoa"] call ALIVE_fnc_dump;
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

ALiVE_mapCompositionType = "Pacific";

 if(tolower(_worldName) == "tanoa") then {
ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + ["a3\structures_f_exp\industrial\port\walkover_01_f.p3d",

"a3\structures_f_exp\civilian\sheds\shed_04_f.p3d",

"a3\props_f_exp\infrastructure\traffic\vergerock_01_f.p3d",

"a3\roads_f\runway\invisibleroadway_square_cluteron_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_01_f.p3d",

"a3\structures_f_exp\military\trenches\trench_01_forest_f.p3d",

"a3\structures_f_exp\military\pillboxes\pillboxwall_01_3m_f.p3d",

"a3\props_f_exp\commercial\market\woodencrate_01_f.p3d",

"a3\structures_f_exp\civilian\accessories\bench_03_f.p3d",

"a3\structures_f_exp\civilian\accessories\bench_05_f.p3d",

"a3\structures_f_exp\civilian\accessories\clothesline_01_short_f.p3d",

"a3\structures_f_exp\infrastructure\watersupply\watertank_03_f.p3d",

"a3\props_f_exp\commercial\market\woodencrate_01_stack_x3_f.p3d",

"a3\structures_f_exp\infrastructure\watersupply\watertank_04_f.p3d",

"a3\props_f_exp\commercial\market\woodencrate_01_stack_x5_f.p3d",

"a3\structures_f_exp\industrial\materials\cinderblocks_01_f.p3d",

"a3\props_f_exp\naval\boats\boat_03_abandoned_cover_f.p3d",

"a3\structures_f_exp\civilian\accessories\clothesline_01_full_f.p3d",

"a3\structures_f_exp\civilian\accessories\picnictable_01_f.p3d",

"a3\structures_f_exp\infrastructure\watersupply\watertank_02_f.p3d",

"a3\structures_f_exp\military\trenches\trench_01_grass_f.p3d",

"a3\structures_f_exp\infrastructure\watersupply\watertower_01_f.p3d",

"a3\props_f_exp\naval\boats\boat_02_abandoned_f.p3d",

"a3\structures_f_exp\infrastructure\watersupply\watertank_01_f.p3d",

"a3\structures_f_exp\industrial\materials\woodenplanks_01_f.p3d",

"a3\structures_f_exp\civilian\accessories\concreteblock_01_f.p3d",

"a3\structures_f_exp\civilian\accessories\bench_04_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_01_8m_f.p3d",

"a3\structures_f_exp\infrastructure\roads\sewercover_02_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_01_corner_f.p3d",

"a3\structures_f_exp\civilian\accessories\pot_02_f.p3d",

"a3\structures_f_exp\civilian\accessories\pot_01_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_01_4m_f.p3d",

"a3\structures_f_exp\infrastructure\roads\sewercover_01_f.p3d",

"a3\props_f_exp\commercial\market\woodencounter_01_f.p3d",

"a3\structures_f_exp\commercial\market\woodenshelter_01_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\tombstone_02_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\tombstone_01_f.p3d",

"a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_2m_d_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\grave_04_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\tombstone_03_f.p3d",

"a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_2m_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\grave_03_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\grave_06_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\grave_07_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\grave_05_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\grave_02_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\gardenpavement_01_f.p3d",

"a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_4m_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\grave_01_f.p3d",

"a3\structures_f_exp\commercial\market\clothshelter_02_f.p3d",

"a3\structures_f_exp\commercial\market\clothshelter_01_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\tomb_01_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\kerbisland_01_start_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_03_by_short_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\kerbisland_01_end_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_03_by_long_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_03_bw_long_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_01_narrow_4m_f.p3d",

"a3\props_f_exp\infrastructure\traffic\roadcone_01_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_01_narrow_8m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_03_bw_short_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\gardenpavement_02_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_02_barrel_f.p3d",

"a3\props_f_exp\naval\boats\boat_01_abandoned_blue_f.p3d",

"a3\structures_f_exp\civilian\sportsgrounds\rugbygoal_01_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_01_4m_f.p3d",

"a3\structures_f_exp\infrastructure\roads\sewercover_03_f.p3d",

"a3\props_f_exp\naval\boats\boat_03_abandoned_f.p3d",

"a3\props_f_exp\naval\boats\boat_01_abandoned_red_f.p3d",

"a3\structures_f_exp\industrial\materials\timberpile_01_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_01_narrow_2m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_01_2m_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_front_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_rear_f.p3d",

"a3\structures_f_exp\cultural\cemeteries\mausoleum_01_f.p3d",

"a3\map_tanoabuka\data\roaddecals\rd_busstop.p3d",

"a3\structures_f_exp\civilian\accessories\fireescape_01_tall_f.p3d",

"a3\structures_f_exp\civilian\accessories\plank_01_8m_f.p3d",

"a3\map_tanoabuka\data\roaddecals\road_crossing.p3d",

"a3\structures_f_exp\civilian\accessories\plank_01_4m_f.p3d",

"a3\structures_f_exp\civilian\accessories\fireescape_01_short_f.p3d",

"a3\map_tanoabuka\data\roaddecals\rd_line_10m.p3d",

"a3\map_tanoabuka\data\roaddecals\giveway.p3d",

"a3\map_tanoabuka\data\roaddecals\rd_line_5m.p3d",

"a3\map_tanoabuka\data\roaddecals\rd_keepclear.p3d",

"a3\map_tanoabuka\data\roaddecals\rd_line_2m.p3d",

"a3\props_f_exp\naval\boats\boat_04_wreck_f.p3d",

"a3\structures_f_exp\industrial\materials\woodenplanks_01_messy_f.p3d",

"a3\props_f_exp\naval\boats\boat_06_wreck_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_02_4m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_02_8m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_02_corner_f.p3d",

"a3\map_tanoabuka\data\roaddecals\rd_stop.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanedebris_01_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanedebris_02_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_wing_left_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanedebris_04_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanedebris_03_f.p3d",

"a3\props_f_exp\military\oldplanewrecks\historicalplanewreck_02_wing_right_f.p3d",

"a3\map_tanoabuka\data\roaddecals\rd_taxi.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_02_8m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_02_4m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_02_2m_f.p3d",

"a3\structures_f_exp\naval\canals\canal_dutch_01_15m_f.p3d",

"a3\structures_f_exp\naval\canals\canal_dutch_01_plate_f.p3d",

"a3\structures_f_exp\naval\canals\canal_dutch_01_stairs_f.p3d",

"a3\structures_f_exp\naval\canals\canal_dutch_01_bridge_f.p3d",

"a3\structures_f_exp\naval\canals\canal_dutch_01_corner_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_outtercorner_80_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_02_narrow_8m_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_cannon_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_10m_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_outtercorner_50_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_outtercorner_90_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_innercorner_70_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_5m_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_innercorner_90_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_d_r_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_d_l_f.p3d",

"a3\structures_f_exp\cultural\fortress_01\fortress_01_innercorner_110_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_02_narrow_4m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\sidewalk_02_narrow_2m_f.p3d",

"a3\structures_f_exp\infrastructure\pavements\concretekerb_02_1m_f.p3d"];
ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
"a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",

"a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",

"a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_f.p3d",

"a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",

"a3\structures_f_exp\military\emplacements\emplacementgun_01_d_mossy_f.p3d",

"a3\structures_f_exp\military\emplacements\emplacementgun_01_mossy_f.p3d",

"a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",

"a3\structures_f_exp\military\trenches\trenchframe_01_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d",

"a3\structures_f\mil\offices\miloffices_v1_f.p3d",

"a3\structures_f\mil\bunker\bunker_f.p3d",

"a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",

"a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",

"a3\structures_f\mil\radar\radar_f.p3d",

"a3\structures_f\mil\radar\radar_small_f.p3d",
"fortress"];
ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",

"a3\structures_f\mil\offices\miloffices_v1_f.p3d",

"a3\structures_f\mil\bunker\bunker_f.p3d",

"a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",

"a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"];
ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",

"a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",

"a3\structures_f_exp\military\trenches\trenchframe_01_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",

"a3\structures_f\mil\offices\miloffices_v1_f.p3d",

"a3\structures_f\mil\bunker\bunker_f.p3d",

"a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",

"a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"];
ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["guardhouse_01_f.p3d",
"pillboxbunker_01_rectangle_f.p3d",
"pillboxbunker_01_hex_f.p3d",
"pillboxbunker_01_big_f.p3d",
"airport_01_terminal_f.p3d",
"airport_01_hangar_f.p3d",
"airport_02_hangar_left_f.p3d",
"airport_02_hangar_right_f.p3d",
"miloffices_v1_f.p3d",
"barracks_01_camo_f.p3d",
"barracks_01_grey_f.p3d",
"radar_f.p3d"];
ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_controltower_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airstripplatform_01_footer_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airstripplatform_01_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runway_01_30m_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runway_01_threshold_20m_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runway_01_30m_end_f.p3d",

"a3\structures_f_exp\infrastructure\runways\taxiway_01_edgeline_90deg_f.p3d",

"a3\structures_f_exp\infrastructure\runways\taxiway_01_edgeline_45deg_f.p3d",

"a3\structures_f_exp\infrastructure\runways\taxiway_01_edgeline_10m_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runwayholdmark_23_f.p3d",

"a3\structures_f_exp\infrastructure\runways\taxiway_01_holdline_15m_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runwayholdmark_23-05_f.p3d",

"a3\structures_f_exp\infrastructure\runways\taxiway_01_holdline_10m_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runwayholdmark_05_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runway_01_40m_end_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runway_01_40m_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runwayholdmark_17_f.p3d",

"a3\structures_f_exp\infrastructure\runways\taxiway_01_edgeline_5m_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runwayholdmark_17-35_f.p3d",

"a3\structures_f_exp\infrastructure\runways\runwayholdmark_35_f.p3d",

"a3\structures_f_exp\infrastructure\runways\taxiway_01_holdline_20m_f.p3d"];
ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + ["a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d","airport_01_hangar_f.p3d"];
ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + ["a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",

"a3\structures_f_exp\infrastructure\airports\airport_02_controltower_f.p3d",

"a3\structures_f\ind\airport\hangar_f.p3d"];
ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["helipads"];
ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["helipads"];
ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["a3\structures_f\civ\offices\offices_01_v1_f.p3d",
"a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
"a3\structures_f\ind\shed\i_shed_ind_f.p3d",
"a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
"a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
"a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
"a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
"a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
"a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
"a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
"a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
"a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
"a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
"a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
"a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
"a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
"a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
"a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
"a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
"a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
"a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
"a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
"a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_01_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_02_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_03_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
"a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
"a3\structures_f_exp\commercial\hotel_01\hotel_01_f.p3d",
"a3\structures_f_exp\commercial\hotel_02\hotel_02_f.p3d",
"a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
"a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
"a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
"a3\structures_f_exp\commercial\multistorybuilding_03\multistorybuilding_03_f.p3d",
"a3\structures_f_exp\commercial\multistorybuilding_04\multistorybuilding_04_f.p3d",
"a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
"a3\structures_f_exp\commercial\shop_city_02\shop_city_02_f.p3d",
"a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
"a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
"a3\structures_f_exp\commercial\shop_city_05\shop_city_05_f.p3d",
"a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
"a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
"a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
"a3\structures_f_exp\commercial\shop_town_02\shop_town_02_f.p3d",
"a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
"a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
"a3\structures_f_exp\commercial\shop_town_05\shop_town_05_addon_f.p3d",
"a3\structures_f_exp\commercial\shop_town_05\shop_town_05_f.p3d",
"a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
"a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
"a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
"a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
"a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
"a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
"a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
"a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgeconcrete_01_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgesea_01_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_up_f.p3d",
"a3\structures_f_exp\infrastructure\watersupply\windmillpump_01_f.p3d"];
ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["addon_04_f.p3d",
"cathedral_01_f.p3d",
"hotel_01_f.p3d",
"hotel_02_f.p3d",
"house_big_01_f.p3d",
"house_big_02_f.p3d",
"house_big_03_f.p3d",
"house_big_04_f.p3d",
"house_native_01_f.p3d",
"house_native_02_f.p3d",
"house_small_01_f.p3d",
"house_small_02_f.p3d",
"house_small_03_f.p3d",
"house_small_04_f.p3d",
"house_small_05_f.p3d",
"house_small_06_f.p3d",
"multistorybuilding_01_f.p3d",
"offices_01_v1_f.p3d",
"scf_01_generalbuilding_f.p3d",
"shop_city_01_f.p3d",
"shop_city_02_f.p3d",
"shop_city_04_f.p3d",
"shop_city_05_f.p3d",
"shop_city_06_f.p3d",
"shop_city_07_f.p3d",
"shop_town_01_f.p3d",
"shop_town_02_f.p3d",
"shop_town_03_f.p3d",
"shop_town_05_f.p3d",
"slum_01_f.p3d",
"slum_02_f.p3d",
"slum_03_f.p3d",
"warehouse_03_f.p3d",
"a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"];
ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
"a3\structures_f\civ\offices\offices_01_v1_f.p3d",
"a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
"a3\structures_f\ind\shed\i_shed_ind_f.p3d",
"a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
"a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
"a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
"a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
"a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
"a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
"a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
"a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
"a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
"a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
"a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
"a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
"a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
"a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
"a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
"a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
"a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
"a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
"a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
"a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
"a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_01_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_02_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_03_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
"a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
"a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
"a3\structures_f_exp\commercial\hotel_01\hotel_01_f.p3d",
"a3\structures_f_exp\commercial\hotel_02\hotel_02_f.p3d",
"a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",
"a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
"a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
"a3\structures_f_exp\commercial\multistorybuilding_03\multistorybuilding_03_f.p3d",
"a3\structures_f_exp\commercial\multistorybuilding_04\multistorybuilding_04_f.p3d",
"a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
"a3\structures_f_exp\commercial\shop_city_02\shop_city_02_f.p3d",
"a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
"a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
"a3\structures_f_exp\commercial\shop_city_05\shop_city_05_f.p3d",
"a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
"a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
"a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
"a3\structures_f_exp\commercial\shop_town_02\shop_town_02_f.p3d",
"a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
"a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
"a3\structures_f_exp\commercial\shop_town_05\shop_town_05_addon_f.p3d",
"a3\structures_f_exp\commercial\shop_town_05\shop_town_05_f.p3d",
"a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
"a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
"a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
"a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
"a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
"a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
"a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
"a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgeconcrete_01_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgesea_01_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_f.p3d",
"a3\structures_f_exp\infrastructure\bridges\bridgesea_01_ramp_up_f.p3d",
"a3\structures_f_exp\infrastructure\watersupply\windmillpump_01_f.p3d"];
ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",

"a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",

"a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",

"a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_smallfactory_f.p3d",

"a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",

"a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_transformer_f.p3d",

"a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_watercooler_f.p3d"];
ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + ["a3\structures_f\ind\transmitter_tower\tbox_f.p3d",

"a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",

"a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",

"a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",

"a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",

"a3\structures_f\ind\transmitter_tower\communication_f.p3d"];
ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",

"a3\structures_f_exp\naval\piers\pierconcrete_01_steps_f.p3d",

"a3\structures_f_exp\naval\piers\pierconcrete_01_16m_f.p3d",

"a3\structures_f_exp\naval\piers\quayconcrete_01_20m_f.p3d",

"a3\structures_f_exp\naval\piers\quayconcrete_01_pier_f.p3d",

"a3\structures_f_exp\naval\piers\pierconcrete_01_end_f.p3d",

"a3\structures_f_exp\naval\piers\quayconcrete_01_outtercorner_f.p3d",

"a3\structures_f_exp\naval\piers\pierconcrete_01_30deg_f.p3d",

"a3\structures_f_exp\naval\piers\pierconcrete_01_4m_ladders_f.p3d",

"a3\structures_f_exp\naval\piers\quayconcrete_01_innercorner_f.p3d",

"a3\structures_f_exp\naval\piers\quayconcrete_01_5m_ladder_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_02_ladder_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_02_hut_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_02_barrel_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_02_30deg_f.p3d",

"a3\structures_f_exp\naval\piers\breakwater_01_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_01_16m_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_01_dock_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_01_ladder_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",

"a3\structures_f_exp\naval\piers\quayconcrete_01_20m_wall_f.p3d",

"a3\structures_f_exp\naval\piers\pierwooden_01_platform_f.p3d",

"a3\structures_f_exp\industrial\port\warehouse_01_f.p3d",

"a3\structures_f_exp\industrial\port\warehouse_02_f.p3d",

"a3\structures_f_exp\industrial\port\mobilecrane_01_f.p3d",

"a3\structures_f_exp\industrial\port\gantrycrane_01_f.p3d",

"a3\structures_f_exp\industrial\port\storagetank_01_small_f.p3d",

"a3\structures_f_exp\industrial\port\cranerail_01_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_shiploader_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_tripper_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_shiploader_arm_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_short_f.p3d",

"a3\structures_f_exp\industrial\port\containercrane_01_arm_f.p3d",

"a3\structures_f_exp\industrial\port\containercrane_01_f.p3d",

"a3\structures_f_exp\industrial\port\containerline_01_f.p3d",

"a3\structures_f_exp\industrial\port\containerline_02_f.p3d",

"a3\structures_f_exp\industrial\port\containercrane_01_arm_lowered_f.p3d",

"a3\structures_f_exp\industrial\port\containerline_03_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_slope_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_stockpile_02_f.p3d",

"a3\structures_f_exp\industrial\port\storagetank_01_large_f.p3d",

"a3\structures_f_exp\industrial\port\drydock_01_end_f.p3d",

"a3\structures_f_exp\industrial\port\drydock_01_middle_f.p3d",

"a3\boat_f_gamma\boat_civil_04\boat_civil_04_f.p3d",

"a3\structures_f_exp\industrial\port\mobilecrane_01_hook_f.p3d"];
ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + ["a3\props_f_exp\infrastructure\railways\locomotive_01_v2_f.p3d",

"a3\structures_f_exp\infrastructure\railways\track_01_bumper_f.p3d",

"a3\props_f_exp\infrastructure\railways\railwaycar_01_tank_f.p3d",

"a3\props_f_exp\infrastructure\railways\railwaycar_01_passenger_f.p3d",

"a3\props_f_exp\infrastructure\railways\locomotive_01_v1_f.p3d",

"a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_empty_f.p3d",

"a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_f.p3d",

"a3\props_f_exp\infrastructure\railways\locomotive_01_v3_f.p3d",

"a3\structures_f_exp\infrastructure\railways\track_01_bridge_f.p3d"];
ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_prices_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_arrow_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_pump_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_prices_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_roof_f.p3d",

"a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d"];
ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_8m_high_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_16m_high_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_16m_slope_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_hole_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_big_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_end_high_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_8m_high_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_high_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_curve_high_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_up_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_8m_f.p3d",

"a3\structures_f\ind\shed\shed_big_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_curve_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_clarifier_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_chimney_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_shed_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_diffuser_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_end_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_shredder_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_washer_f.p3d",

"a3\structures_f\ind\shed\shed_small_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_feeder_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_medium_f.p3d",

"a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",

"a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",

"a3\props_f_exp\industrial\heavyequipment\bulldozer_01_abandoned_f.p3d",

"a3\props_f_exp\industrial\heavyequipment\miningshovel_01_abandoned_f.p3d",

"a3\props_f_exp\industrial\heavyequipment\haultruck_01_abandoned_f.p3d",

"a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",

"a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",

"a3\structures_f_exp\industrial\surfacemine_01\sm_01_reservoirtower_f.p3d",

"a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_wide_f.p3d",

"a3\props_f_exp\industrial\heavyequipment\excavator_01_wreck_f.p3d",

"a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",

"a3\structures_f\ind\shed\i_shed_ind_f.p3d",

"a3\structures_f_exp\commercial\market\metalshelter_01_f.p3d",

"a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",

"a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_chute_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_long_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_end_f.p3d",

"a3\structures_f_exp\industrial\port\warehouseshelter_01_f.p3d",

"a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",

"a3\structures_f\ind\crane\crane_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_junction_f.p3d",

"a3\structures_f_exp\industrial\stockyard_01\sy_01_crusher_f.p3d",

"a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_f.p3d",

"a3\props_f_exp\industrial\heavyequipment\combineharvester_01_wreck_f.p3d"];
};

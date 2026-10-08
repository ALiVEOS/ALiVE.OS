// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: pandora (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "pandora") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d",
        "a3\structures_f\research\dome_b_cargo_entrance_f.p3d",
        "a3\structures_f\research\dome_b_person_entrance_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_khaki_f.p3d",
        "a3\structures_f_heli\ind\airport\mobilelandingplatform_01_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_military_green_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_white_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_yellow_f.p3d",
        "a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d",
        "a3\structures_f_heli\items\airport\portablehelipadlight_01_f.p3d",
        "pandoracustom\cablecar.p3d",
        "pandoracustom\connector.p3d",
        "pandoracustom\connectordome.p3d",
        "pandoracustom\console.p3d",
        "pandoracustom\console2.p3d",
        "pandoracustom\console3.p3d",
        "pandoracustom\digramp.p3d",
        "pandoracustom\digwall.p3d",
        "pandoracustom\foil.p3d",
        "pandoracustom\glasswall.p3d",
        "pandoracustom\habitatgroundwalk.p3d",
        "pandoracustom\hardwall.p3d",
        "pandoracustom\milbarrier.p3d",
        "pandoracustom\milconnector.p3d",
        "pandoracustom\milwall.p3d",
        "pandoracustom\milwallgate.p3d",
        "pandoracustom\monolith.p3d",
        "pandoracustom\pool.p3d",
        "pandoracustom\sifiwall.p3d",
        "pandoracustom\skywalk.p3d",
        "pandoracustom\skywalk3.p3d",
        "pandoracustom\sphere2.p3d",
        "pandoracustom\walkplatform.p3d",
        "pandoracustom\whitewall.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\research\dome_b_cage_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\dome_small_plates_f.p3d",
        "a3\structures_f\research\research_house_v1_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "pandoracustom\hangarhadley.p3d",
        "pandoracustom\mildish.p3d",
        "pandoracustom\milhab2.p3d",
        "pandoracustom\milhabitat.p3d",
        "pandoracustom\milhabitat4.p3d",
        "pandoracustom\milhangarground.p3d",
        "pandoracustom\milhangarsky.p3d",
        "pandoracustom\milhangarsky2.p3d",
        "pandoracustom\militaryb1.p3d",
        "pandoracustom\militarytower.p3d",
        "pandoracustom\milseabase.p3d",
        "pandoracustom\milseabase2.p3d",
        "pandoracustom\milseabase3.p3d",
        "pandoracustom\sphereoutpost.p3d",
        "pandoracustom\sulaco.p3d",
        "pandoracustom\sulaco1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\research\dome_b_cage_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "pandoracustom\milhab2.p3d",
        "pandoracustom\milhabitat4.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\research\dome_b_cage_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "pandoracustom\milhab2.p3d",
        "pandoracustom\militaryb1.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d",
        "a3\structures_f\research\dome_b_cage_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "pandoracustom\milhabitat.p3d",
        "pandoracustom\militarytower.p3d",
        "pandoracustom\sphereoutpost.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "pandoracustom\hangarhadley.p3d",
        "pandoracustom\hangarlarge.p3d",
        "pandoracustom\milhangarground.p3d",
        "pandoracustom\milhangarsky.p3d",
        "pandoracustom\milhangarsky2.p3d",
        "pandoracustom\runwaysifi.p3d",
        "pandoracustom\sulaco.p3d",
        "pandoracustom\sulaco1.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "pandoracustom\hangarhadley.p3d",
        "pandoracustom\milhangarground.p3d",
        "pandoracustom\milhangarsky.p3d",
        "pandoracustom\milhangarsky2.p3d",
        "pandoracustom\sulaco.p3d",
        "pandoracustom\sulaco1.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "pandoracustom\hangarlarge.p3d",
        "pandoracustom\runwaysifi.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d",
        "pandoracustom\conelanding.p3d",
        "pandoracustom\landingpad.p3d",
        "pandoracustom\landingpad2.p3d",
        "pandoracustom\skywalkheli.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
        "pandoracustom\conelanding.p3d",
        "pandoracustom\landingpad.p3d",
        "pandoracustom\landingpad2.p3d",
        "pandoracustom\skywalkheli.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f_exp\industrial\port\warehouse_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "pandoracustom\greenhouse.p3d",
        "pandoracustom\greenhouse2.p3d",
        "pandoracustom\greenhouse3.p3d",
        "pandoracustom\habitat.p3d",
        "pandoracustom\habitat2.p3d",
        "pandoracustom\habitat3.p3d",
        "pandoracustom\habitat4x.p3d",
        "pandoracustom\habitatground1.p3d",
        "pandoracustom\habitatground2.p3d",
        "pandoracustom\skyhouse.p3d",
        "pandoracustom\skyhouse2.p3d",
        "pandoracustom\skyhouse3.p3d",
        "pandoracustom\skyhouse4.p3d",
        "pandoracustom\skyhousebase.p3d",
        "pandoracustom\sphere.p3d",
        "pandoracustom\tubehabitat1.p3d",
        "pandoracustom\tubehabitat2.p3d",
        "pandoracustom\tubehabitat4.p3d",
        "pandoracustom\undwaterhab1.p3d",
        "pandoracustom\undwaterhab2.p3d",
        "pandoracustom\waterhabitat.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "pandoracustom\habitat.p3d",
        "pandoracustom\habitat2.p3d",
        "pandoracustom\skyhouse4.p3d",
        "pandoracustom\skyhousebase.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_chimney_f.p3d",
        "pandoracustom\aircleaner.p3d",
        "pandoracustom\aprocesor.p3d",
        "pandoracustom\procesor.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "pandoracustom\beacon.p3d",
        "pandoracustom\mildish.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_small_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_02_f.p3d",
        "pandoracustom\milseabase.p3d",
        "pandoracustom\milseabase2.p3d",
        "pandoracustom\milseabase3.p3d",
        "pandoracustom\seafarm.p3d",
        "pandoracustom\undwaterhab1.p3d",
        "pandoracustom\undwaterhab2.p3d",
        "pandoracustom\waterbase.p3d",
        "pandoracustom\waterbasewalk.p3d",
        "pandoracustom\waterdock.p3d",
        "pandoracustom\waterhabitat.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "pandoracustom\cablecarbase.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_v1_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "pandoracustom\minetanks.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",
        "pandoracustom\minedeadspace.p3d",
        "pandoracustom\minedeadspace2.p3d",
        "pandoracustom\minedeadspace3.p3d",
        "pandoracustom\minerings.p3d",
        "pandoracustom\minetop.p3d",
        "pandoracustom\tn1.p3d",
        "pandoracustom\tn2.p3d",
        "pandoracustom\tn3.p3d"
    ];

};

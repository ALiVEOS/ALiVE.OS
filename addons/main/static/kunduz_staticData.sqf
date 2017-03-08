private["_worldName"];

_worldName = tolower(worldName);

["ALiVE SETTING UP MAP: %1", _worldName] call ALIVE_fnc_dump;

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

if (_worldName == "kunduz") then {
    [ALIVE_mapBounds, worldName, 6000] call ALIVE_fnc_hashSet;

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "pra3\pra3_tunnels\floor_sandy.p3d",
        "pra3\pra3_tunnels\tunnel_small_ramp.p3d",
        "pra3\pra3_tunnels\wood_beams_h_join.p3d",
        "pra3\pra3_tunnels\wood_beams_h_sloped.p3d",
        "pra3\pra3_tunnels\tunnel_large_winding.p3d",
        "pra3\pra3_tunnels\tunnel_small_bend.p3d",
        "pra3\pra3_tunnels\tunnel_large_s_bend.p3d",
        "pra3\pra3_tunnels\tunnel_large_room_1door.p3d",
        "pra3\pra3_tunnels\wood_beams_t.p3d",
        "pra3\pra3_tunnels\wood_beams.p3d",
        "pra3\pra3_tunnels\tunnel_large_room_4doors.p3d",
        "pra3\pra3_tunnels\wood_beams_h.p3d",
        "pra3\pra3_tunnels\cable_hanging.p3d",
        "pra3\pra3_tunnels\cable_ground.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "pra3\pra3_tunnels\floor_sandy.p3d",
        "pra3\pra3_tunnels\tunnel_small_ramp.p3d",
        "pra3\pra3_tunnels\tunnel_large_winding.p3d",
        "pra3\pra3_tunnels\tunnel_small_bend.p3d",
        "pra3\pra3_tunnels\tunnel_large_room_1door.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "pra3\pra3_tunnels\tunnel_large_winding.p3d",
        "pra3\pra3_tunnels\tunnel_large_room_1door.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];

    ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l_5m.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5_corner.p3d",
        "pra3\pra3_misc\misc_market\jbad_stand_water.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_9_stuff.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5_gate.p3d",
        "pra3\pra3_misc\misc_market\jbad_market_stalls_01.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_reservoir.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "pra3\pra3_misc\misc_market\jbad_market_shelter.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l_5m_dam.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l_mosque_2.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "pra3\pra3_misc\misc_market\jbad_covering_hut_big.p3d",
        "pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l1_pillar.p3d",
        "pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house5.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house_1.p3d",
        "a3\structures_f\walls\net_fence_gate_f.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_terrace.p3d",
        "pra3\pra3_misc\misc_well\jbad_misc_well_c.p3d",
        "pra3\pra3_misc\misc_market\jbad_covering_hut.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l1_5m.p3d",
        "pra3\pra3_misc\misc_market\jbad_stand_meat.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d",
        "pra3\pra3_misc\misc_construction\jbad_misc_concbox.p3d",
        "a3\structures_f\ind\tank\tank_rust_f.p3d",
        "pra3\pra3_tunnels\tunnel_large_winding.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house6.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house8.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house3.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house7.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "pra3\pra3_structures\fata\qalat.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l2_5m.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l2_5m_end.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l3_gate.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l3_5m.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "pra3\pra3_misc\misc_market\jbad_kiosk.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d",
        "pra3\pra3_structures\walls\walls_l\jbad_wall_l1_gate.p3d",
        "pra3\pra3_structures\afghan_houses_a\a_minaret\jbad_a_minaret.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house5.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house_1.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d",
        "pra3\pra3_tunnels\floor_sandy.p3d",
        "pra3\pra3_tunnels\tunnel_large_winding.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house6.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house8.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house3.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house7.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_9_stuff.p3d",
        "pra3\pra3_misc\misc_market\jbad_market_stalls_01.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "pra3\pra3_misc\misc_well\jbad_misc_well_l.p3d",
        "pra3\pra3_misc\misc_market\jbad_market_shelter.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "pra3\pra3_misc\misc_market\jbad_covering_hut_big.p3d",
        "pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d",
        "pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house5.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house_1.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_terrace.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d",
        "pra3\pra3_tunnels\tunnel_large_winding.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house6.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house8.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house3.p3d",
        "pra3\pra3_structures\afghan_houses\jbad_house7.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "pra3\pra3_misc\misc_market\jbad_kiosk.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\powerlines\powercable_submarine_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "pra3\pra3_misc\misc_construction\jbad_misc_ironpipes.p3d",
        "pra3\pra3_misc\misc_ruins\jbad_rubble_concrete_01.p3d",
        "pra3\pra3_misc\misc_construction\jbad_misc_concpipeline.p3d",
        "pra3\pra3_misc\misc_construction\jbad_misc_concbox.p3d",
        "a3\structures_f\ind\tank\tank_rust_f.p3d",
        "pra3\pra3_tunnels\wood_beam.p3d",
        "pra3\pra3_misc\bridge\ic_002_bridge.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "pra3\pra3_structures\walls\walls\jbad_wall_indcnc_4_d.p3d",
        "pra3\pra3_structures\walls\walls\jbad_wall_indcnc_4.p3d",
        "pra3\pra3_structures\walls\walls\jbad_wall_indcnc_end_3.p3d",
        "pra3\pra3_structures\walls\walls\jbad_wall_indcnc_end_2.p3d"
    ];
};

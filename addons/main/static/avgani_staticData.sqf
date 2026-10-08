// ALiVE 3 index v3.1, made 2026-10-07 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: avgani (ALiVE 3 index v3.1, 2026-10-07)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-07", "web", true];

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

 if (tolower(_worldName) == "avgani") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "avgani\roads2\asf10 100.p3d",
        "avgani\roads2\asf10 25.p3d",
        "avgani\roads2\asf10 50.p3d",
        "avgani\roads2\asf10 75.p3d",
        "avgani\roads2\asf12.p3d",
        "avgani\roads2\asf25.p3d",
        "avgani\roads2\asf6.p3d",
        "avgani\roads2\asf6_ped.p3d",
        "avgani\roads2\asf6konec.p3d",
        "avgani\roads2\sil10 100.p3d",
        "avgani\roads2\sil10 25.p3d",
        "avgani\roads2\sil10 75.p3d",
        "avgani\roads2\sil12.p3d",
        "avgani\roads2\sil6.p3d",
        "avgani\roads2\sil6konec.p3d",
        "ca\buildings\bordel_zidka.p3d",
        "ca\buildings\misc\pletivo.p3d",
        "ca\buildings\misc\pletivo_dira.p3d",
        "ca\cti_buildings\cti_barracks.p3d",
        "ca\cti_buildings\cti_bunker.p3d",
        "ca\cti_buildings\cti_factory_light.p3d",
        "ca\cti_buildings\cti_hesco_10x.p3d",
        "ca\cti_buildings\cti_hesco_5x.p3d",
        "ca\cti_buildings\cti_sandbags_site.p3d",
        "ca\misc\betonl_velky.p3d",
        "ca\misc\container.p3d",
        "ca\misc\container2.p3d",
        "ca\misc\danger!.p3d",
        "opxbuildings\minaret3.p3d",
        "opxbuildings\ruin.p3d",
        "opxbuildings\shack.p3d",
        "opxmisc\cart.p3d",
        "opxmisc\cart2.p3d",
        "opxmisc\cart3.p3d",
        "opxmisc\conslab.p3d",
        "opxmisc\container.p3d",
        "opxmisc\container2.p3d",
        "opxmisc\container3.p3d",
        "opxmisc\double_arch_gate.p3d",
        "opxmisc\farmwall.p3d",
        "opxmisc\farmwallend.p3d",
        "opxmisc\fence1.p3d",
        "opxmisc\fence1_pillar.p3d",
        "opxmisc\fence2.p3d",
        "opxmisc\fence2_pillar.p3d",
        "opxmisc\gate1.p3d",
        "opxmisc\gate2.p3d",
        "opxmisc\gate_wood.p3d",
        "opxmisc\gateblueopen.p3d",
        "opxmisc\gategreenopen.p3d",
        "opxmisc\gateredclosed.p3d",
        "opxmisc\gateturquoiseopen.p3d",
        "opxmisc\hiddenpath_long.p3d",
        "opxmisc\loam\loam_stall.p3d",
        "opxmisc\loam\loam_wall1.p3d",
        "opxmisc\loam\loam_wall1_arch.p3d",
        "opxmisc\loam\loam_wall1_arch2.p3d",
        "opxmisc\loam\loam_wall1_box.p3d",
        "opxmisc\loam\loam_wall1_curve.p3d",
        "opxmisc\loam\loam_wall1_small.p3d",
        "opxmisc\loam\tower.p3d",
        "opxmisc\marketstand1.p3d",
        "opxmisc\marketstand1_b.p3d",
        "opxmisc\marketstand2.p3d",
        "opxmisc\marketstand2_b.p3d",
        "opxmisc\mural11.p3d",
        "opxmisc\mural3.p3d",
        "opxmisc\mural4.p3d",
        "opxmisc\mural5.p3d",
        "opxmisc\mural8.p3d",
        "opxmisc\mural9.p3d",
        "opxmisc\pallets.p3d",
        "opxmisc\powerpole.p3d",
        "opxmisc\powerpoleb.p3d",
        "opxmisc\powerpolec.p3d",
        "opxmisc\powerpoled.p3d",
        "opxmisc\powerpolee.p3d",
        "opxmisc\road_attrib\avgani1.p3d",
        "opxmisc\road_attrib\avgani1_b.p3d",
        "opxmisc\sandwall1.p3d",
        "opxmisc\sandwall1_b.p3d",
        "opxmisc\sandwall1_c.p3d",
        "opxmisc\sandwall1_d.p3d",
        "opxmisc\shrine_2.p3d",
        "opxmisc\sidewalks\sidewalk1.p3d",
        "opxmisc\sidewalks\sidewalk2.p3d",
        "opxmisc\sidewalks\sidewalk3.p3d",
        "opxmisc\sidewalks\sidewalk4.p3d",
        "opxmisc\sidewalks\sidewalk5.p3d",
        "opxmisc\trash.p3d",
        "opxmisc\trash2.p3d",
        "opxmisc\trash3.p3d",
        "opxmisc\trash4.p3d",
        "opxmisc\trash5.p3d",
        "opxmisc\trash6.p3d",
        "opxmisc\trash7.p3d",
        "opxmisc\wall1.p3d",
        "opxmisc\wall11.p3d",
        "opxmisc\wall11_end.p3d",
        "opxmisc\wall11_pillar.p3d",
        "opxmisc\wall12.p3d",
        "opxmisc\wall12_pillar.p3d",
        "opxmisc\wall1pillar.p3d",
        "opxmisc\wall3.p3d",
        "opxmisc\wall3pillar.p3d",
        "opxmisc\wall4.p3d",
        "opxmisc\wall4pillar.p3d",
        "opxmisc\wall5.p3d",
        "opxmisc\wall5pillar.p3d",
        "opxmisc\wall8.p3d",
        "opxmisc\wall8b.p3d",
        "opxmisc\wall8bpillar.p3d",
        "opxmisc\wall8pillar.p3d",
        "opxmisc\wall9.p3d",
        "opxmisc\wall9pillar.p3d",
        "opxmisc\well.p3d",
        "opxmisc\wireb.p3d",
        "opxmisc\wirec.p3d",
        "opxmisc\wired.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\army_hut2.p3d",
        "ca\buildings\army_hut_storrage.p3d",
        "ca\buildings\budova5.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\posed.p3d",
        "ca\buildings\ruins\army_hut2_ruins.p3d",
        "ca\cti_buildings\cti_heliport.p3d",
        "ca\roads\ces_d10 100.p3d",
        "ca\roads\ces_d10 25.p3d",
        "ca\roads\ces_d10 50.p3d",
        "ca\roads\ces_d10 75.p3d",
        "ca\roads\ces_d25.p3d",
        "ca\roads\ces_d6.p3d",
        "opxbuildings\watertower.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads\ces_d10 100.p3d",
        "ca\roads\ces_d10 25.p3d",
        "ca\roads\ces_d10 50.p3d",
        "ca\roads\ces_d10 75.p3d",
        "ca\roads\ces_d25.p3d",
        "ca\roads\ces_d6.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "opxmisc\guardtower.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "opxmisc\guardtower.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "ca\cti_buildings\cti_heliport.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\cti_buildings\cti_heliport.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "avgani\data\layers\a\asylum.p3d",
        "ca\buildings\bouda_garaz.p3d",
        "ca\buildings\bouda_plech.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan2_01.p3d",
        "ca\buildings\dum_istan2_03.p3d",
        "ca\buildings\dum_istan2_04a.p3d",
        "ca\buildings\dum_istan3.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_mesto3_istan.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_olez_istan2.p3d",
        "ca\buildings\dum_olez_istan2_maly.p3d",
        "ca\buildings\garaz.p3d",
        "ca\buildings\house_y.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\podesta_1_stairs4.p3d",
        "ca\buildings\ruins\budova3_ruins.p3d",
        "ca\buildings\tovarna1.p3d",
        "ca\buildings\zastavka_sever.p3d",
        "ca\roads\ces_d10 100.p3d",
        "ca\roads\ces_d10 25.p3d",
        "ca\roads\ces_d10 50.p3d",
        "ca\roads\ces_d10 75.p3d",
        "ca\roads\ces_d25.p3d",
        "ca\roads\ces_d6.p3d",
        "opxbuildings\10str.p3d",
        "opxbuildings\14str.p3d",
        "opxbuildings\15str.p3d",
        "opxbuildings\16str.p3d",
        "opxbuildings\17str.p3d",
        "opxbuildings\17strb.p3d",
        "opxbuildings\18str.p3d",
        "opxbuildings\19str.p3d",
        "opxbuildings\21str.p3d",
        "opxbuildings\21str_b.p3d",
        "opxbuildings\21str_c.p3d",
        "opxbuildings\21str_d.p3d",
        "opxbuildings\22str.p3d",
        "opxbuildings\23str.p3d",
        "opxbuildings\5str.p3d",
        "opxbuildings\6str.p3d",
        "opxbuildings\7str.p3d",
        "opxbuildings\block.p3d",
        "opxbuildings\block10.p3d",
        "opxbuildings\block2.p3d",
        "opxbuildings\block3.p3d",
        "opxbuildings\block7.p3d",
        "opxbuildings\block7_b.p3d",
        "opxbuildings\block8.p3d",
        "opxbuildings\block8_c.p3d",
        "opxbuildings\block9.p3d",
        "opxbuildings\block9_b.p3d",
        "opxbuildings\garage.p3d",
        "opxbuildings\hut1.p3d",
        "opxbuildings\hut11.p3d",
        "opxbuildings\hut2.p3d",
        "opxbuildings\hut2_2.p3d",
        "opxbuildings\hut3.p3d",
        "opxbuildings\hut3_2.p3d",
        "opxbuildings\hut3_b.p3d",
        "opxbuildings\hut3_b_2.p3d",
        "opxbuildings\hut4.p3d",
        "opxbuildings\hut5.p3d",
        "opxbuildings\hut7.p3d",
        "opxbuildings\hut9_c.p3d",
        "opxbuildings\long_house1.p3d",
        "opxbuildings\long_house2.p3d",
        "opxbuildings\meh_sak.p3d",
        "opxbuildings\mosque2.p3d",
        "opxbuildings\office.p3d",
        "opxbuildings\policestation.p3d",
        "opxbuildings\small_house.p3d",
        "opxbuildings\small_iraqi.p3d",
        "opxbuildings\small_iraqib.p3d",
        "opxbuildings\villa.p3d",
        "opxbuildings\villa3.p3d",
        "opxbuildings\villa_b.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "avgani\data\layers\a\asylum.p3d",
        "opxbuildings\policestation.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "avgani\data\layers\a\asylum.p3d",
        "ca\buildings\bouda_garaz.p3d",
        "ca\buildings\dum_istan2.p3d",
        "ca\buildings\dum_istan3_hromada.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_olez_istan2_maly.p3d",
        "ca\buildings\house_y.p3d",
        "ca\buildings\podesta_1_stairs4.p3d",
        "ca\roads\ces_d10 100.p3d",
        "ca\roads\ces_d10 25.p3d",
        "ca\roads\ces_d10 50.p3d",
        "ca\roads\ces_d10 75.p3d",
        "ca\roads\ces_d25.p3d",
        "ca\roads\ces_d6.p3d",
        "opxbuildings\block10.p3d",
        "opxbuildings\hut7.p3d",
        "opxbuildings\policestation.p3d",
        "opxbuildings\villa.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings\misc\leseni2x.p3d"
    ];

};

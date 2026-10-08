// ALiVE 3 index v3.1, made 2026-10-07 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: afghan_village (ALiVE 3 index v3.1, 2026-10-07)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "afghan_village") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "opxbuildings\minaret3.p3d",
        "opxbuildings\ruin.p3d",
        "opxbuildings\shack.p3d",
        "opxmisc\bigwall1.p3d",
        "opxmisc\bigwall1_arch.p3d",
        "opxmisc\bigwall1_door.p3d",
        "opxmisc\bigwall1_long.p3d",
        "opxmisc\bigwall1_short.p3d",
        "opxmisc\bigwall1b.p3d",
        "opxmisc\bigwall1b_long.p3d",
        "opxmisc\bigwall1b_short.p3d",
        "opxmisc\cart.p3d",
        "opxmisc\cart2.p3d",
        "opxmisc\cart3.p3d",
        "opxmisc\container2.p3d",
        "opxmisc\container3.p3d",
        "opxmisc\farmwall.p3d",
        "opxmisc\farmwallend.p3d",
        "opxmisc\gateblueopen.p3d",
        "opxmisc\gategreenopen.p3d",
        "opxmisc\gateredopen.p3d",
        "opxmisc\gateturquoiseopen.p3d",
        "opxmisc\hiddenpath.p3d",
        "opxmisc\hiddenpath_long.p3d",
        "opxmisc\obelisk.p3d",
        "opxmisc\pallets.p3d",
        "opxmisc\sandwall1.p3d",
        "opxmisc\sandwall1_b.p3d",
        "opxmisc\sandwall1_c.p3d",
        "opxmisc\sandwall1_d.p3d",
        "opxmisc\shrine.p3d",
        "opxmisc\shrine_2.p3d",
        "opxmisc\trash.p3d",
        "opxmisc\trash2.p3d",
        "opxmisc\trash3.p3d",
        "opxmisc\trash4.p3d",
        "opxmisc\trash5.p3d",
        "opxmisc\trash6.p3d",
        "opxmisc\wall1.p3d",
        "opxmisc\wall10.p3d",
        "opxmisc\wall10pillar.p3d",
        "opxmisc\wall1pillar.p3d",
        "opxmisc\wall8.p3d",
        "opxmisc\wall8pillar.p3d",
        "opxmisc\well.p3d",
        "opxroads\asf10 100.p3d",
        "opxroads\asf10 25.p3d",
        "opxroads\asf10 50.p3d",
        "opxroads\asf10 75.p3d",
        "opxroads\asf12.p3d",
        "opxroads\asf25.p3d",
        "opxroads\asf6.p3d",
        "opxroads\asf6konec.p3d",
        "opxroads\ces25.p3d",
        "opxroads\ces6.p3d",
        "opxroads\ces6konec.p3d",
        "opxroads\road2_25.p3d",
        "opxroads\road2_6konec.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "opxbuildings\tower2.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings\bouda_plech.p3d",
        "opxbuildings\15str.p3d",
        "opxbuildings\16str.p3d",
        "opxbuildings\hut1.p3d",
        "opxbuildings\hut10.p3d",
        "opxbuildings\hut11.p3d",
        "opxbuildings\hut12.p3d",
        "opxbuildings\hut1_2.p3d",
        "opxbuildings\hut2.p3d",
        "opxbuildings\hut2_2.p3d",
        "opxbuildings\hut3.p3d",
        "opxbuildings\hut3_2.p3d",
        "opxbuildings\hut3_b.p3d",
        "opxbuildings\hut3_b_2.p3d",
        "opxbuildings\hut4.p3d",
        "opxbuildings\hut4_2.p3d",
        "opxbuildings\hut5.p3d",
        "opxbuildings\hut6.p3d",
        "opxbuildings\hut7.p3d",
        "opxbuildings\hut9.p3d",
        "opxbuildings\hut9_b.p3d",
        "opxbuildings\hut9_c.p3d",
        "opxbuildings\little mosque.p3d",
        "opxbuildings\minaret2.p3d",
        "opxbuildings\mosque3.p3d",
        "opxbuildings\small_iraqib.p3d",
        "opxbuildings\tower1.p3d",
        "opxbuildings\tower3.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "opxbuildings\hut6.p3d",
        "opxbuildings\hut7.p3d"
    ];

};

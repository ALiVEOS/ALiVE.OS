/*
 * Defaults
 */

if (isnil "ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES") then {ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES = []};
if (isnil "ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST") then {ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST = []};
if (isnil "ALiVE_PLACEMENT_CUSTOM_UNITBLACKLIST") then {ALiVE_PLACEMENT_CUSTOM_UNITBLACKLIST = []};
if (isnil "ALiVE_PLACEMENT_CUSTOM_VEHICLEBLACKLIST") then {ALiVE_PLACEMENT_CUSTOM_VEHICLEBLACKLIST = []};
if (isnil "ALiVE_PLACEMENT_CUSTOM_GROUPBLACKLIST") then {ALiVE_PLACEMENT_CUSTOM_GROUPBLACKLIST = []};
if (isnil "ALiVE_PR_CUSTOM_BLACKLIST") then {ALiVE_PR_CUSTOM_BLACKLIST = []};
if (isnil "ALiVE_PR_CUSTOM_WHITELIST") then {ALiVE_PR_CUSTOM_WHITELIST = []};

/*
 * CQB houses
 */

ALiVE_MIL_CQB_STRATEGICHOUSES = ALiVE_MIL_CQB_CUSTOM_STRATEGICHOUSES +
[
	//A3
	"Land_Cargo_Patrol_V1_F",
	"Land_Cargo_Patrol_V2_F",
	"Land_Cargo_House_V1_F",
	"Land_Cargo_House_V2_F",
	"Land_Cargo_Tower_V3_F",
	"Land_Airport_Tower_F",
	"Land_Cargo_HQ_V1_F",
	"Land_Cargo_HQ_V2_F",
	"Land_MilOffices_V1_F",
	"Land_Offices_01_V1_F",
	"Land_Research_HQ_F",
	"Land_CarService_F",
	"Land_Hospital_main_F",
	"Land_dp_smallFactory_F",
	"Land_Radar_F",
	"Land_TentHangar_V1_F",

	//A2
	"Land_A_TVTower_Base",
	"Land_Dam_ConcP_20",
	"Land_Ind_Expedice_1",
	"Land_Ind_SiloVelke_02",
	"Land_Mil_Barracks",
	"Land_Mil_Barracks_i",
	"Land_Mil_Barracks_L",
	"Land_Mil_Guardhouse",
	"Land_Mil_House",
	"Land_Fort_Watchtower",
	"Land_Vysilac_FM",
	"Land_SS_hangar",
	"Land_telek1",
	"Land_vez",
	"Land_A_FuelStation_Shed",
	"Land_watertower1",
	"Land_trafostanica_velka",
	"Land_Ind_Oil_Tower_EP1",
	"Land_A_Villa_EP1",
	"Land_fortified_nest_small_EP1",
	"Land_Mil_Barracks_i_EP1",
	"Land_fortified_nest_big_EP1",
	"Land_Fort_Watchtower_EP1",
	"Land_Ind_PowerStation_EP1",
	"Land_Ind_PowerStation"
];

/*
 * CQB unit blacklist
 */

ALiVE_MIL_CQB_UNITBLACKLIST = ALiVE_MIL_CQB_CUSTOM_UNITBLACKLIST +
[
	//A3
	"B_Helipilot_F",
	"B_diver_F",
	"B_diver_TL_F",
	"B_diver_exp_F",
	"B_RangeMaster_F",
	"B_crew_F",
	"B_Pilot_F",
	"B_helicrew_F",

	"O_helipilot_F",
	"O_diver_F",
	"O_diver_TL_F",
	"O_diver_exp_F",
	"O_crew_F",
	"O_Pilot_F",
	"O_helicrew_F",
	"O_UAV_AI",

	"I_crew_F",
	"I_helipilot_F",
	"I_helicrew_F",
	"I_diver_F",
	"I_diver_exp_F",
	"I_diver_TL_F",
	"I_pilot_F",
	"I_Story_Colonel_F",

	"B_Soldier_VR_F",
    "O_Soldier_VR_F",
    "I_Soldier_VR_F",
    "C_Soldier_VR_F",
    "B_Protagonist_VR_F",
    "O_Protagonist_VR_F",
    "I_Protagonist_VR_F",

    "C_Driver_1_black_F",
	"C_Driver_1_blue_F",
	"C_Driver_1_F",
	"C_Driver_1_green_F",
	"C_Driver_1_orange_F",
	"C_Driver_1_random_base_F",
	"C_Driver_1_red_F",
	"C_Driver_1_white_F",
	"C_Driver_1_yellow_F",
	"C_Driver_2_F",
	"C_Driver_3_F",
	"C_Driver_4_F",
	"C_Marshal_F",
    "C_man_pilot_F"
];

/*
 * Mil placement / Ambient civilians / Mil logistics vehicle blacklist
 */

ALiVE_PLACEMENT_UNITBLACKLIST = ALiVE_PLACEMENT_CUSTOM_UNITBLACKLIST +
[
	"O_UAV_AI",
	"B_UAV_AI",
	"C_Driver_1_black_F",
	"C_Driver_1_blue_F",
	"C_Driver_1_F",
	"C_Driver_1_green_F",
	"C_Driver_1_orange_F",
	"C_Driver_1_random_base_F",
	"C_Driver_1_red_F",
	"C_Driver_1_white_F",
	"C_Driver_1_yellow_F",
	"C_Driver_2_F",
	"C_Driver_3_F",
	"C_Driver_4_F",
	"B_Soldier_VR_F",
	"O_Soldier_VR_F",
	"I_Soldier_VR_F",
	"C_Soldier_VR_F",
	"B_Protagonist_VR_F",
	"O_Protagonist_VR_F",
	"I_Protagonist_VR_F",
	"C_Marshal_F",
	"C_man_pilot_F"
];

/*
 * Mil placement / Ambient civilians / Mil logistics vehicle blacklist
 */

ALiVE_PLACEMENT_VEHICLEBLACKLIST = ALiVE_PLACEMENT_CUSTOM_VEHICLEBLACKLIST +
[
	"O_UAV_02_F",
	"O_UAV_02_CAS_F",
	"O_UAV_01_F",
	"O_UGV_01_F",
	"O_UGV_01_rcws_F",
	"O_Parachute_02_F",
	"B_UAV_01_F",
	"B_UAV_02_F",
	"B_UAV_02_CAS_F",
	"B_UGV_01_F",
	"B_UGV_01_rcws_F",
	"B_Parachute_02_F",
	"I_UAV_02_F",
	"I_UAV_02_CAS_F",
	"I_UAV_01_F",
	"I_UGV_01_F",
	"I_UGV_01_rcws_F",
	"I_Parachute_02_F",
	"Parachute",
	"Parachute_02_base_F",
	"ParachuteBase",
	"ParachuteEast",
	"ParachuteG",
	"ParachuteWest",
	"C_Kart_01_Blu_F",
	"C_Kart_01_F",
	"C_Kart_01_F_Base",
	"C_Kart_01_Fuel_F",
	"C_Kart_01_Red_F",
	"C_Kart_01_Vrana_F",
	"C_Kart_01_black_F",
	"C_Kart_01_white_F",
	"C_Kart_01_orange_F",
	"C_Kart_01_yellow_F",
	"C_Kart_01_green_F"
];

/*
 * Mil placement group blacklist
 */

ALiVE_PLACEMENT_GROUPBLACKLIST = ALiVE_PLACEMENT_CUSTOM_GROUPBLACKLIST +
[
	"HAF_AttackTeam_UAV",
	"HAF_ReconTeam_UAV",
	"HAF_AttackTeam_UGV",
	"HAF_ReconTeam_UGV",
	"HAF_SmallTeam_UAV",
	"HAF_DiverTeam",
	"HAF_DiverTeam_Boat",
	"HAF_DiverTeam_SDV",
	"BUS_AttackTeam_UAV",
	"BUS_ReconTeam_UAV",
	"BUS_AttackTeam_UGV",
	"BUS_ReconTeam_UGV",
	"BUS_SmallTeam_UAV",
	"BUS_DiverTeam",
	"BUS_DiverTeam_Boat",
	"BUS_DiverTeam_SDV",
	"OI_AttackTeam_UAV",
	"OI_ReconTeam_UAV",
	"OI_AttackTeam_UGV",
	"OI_ReconTeam_UGV",
	"OI_SmallTeam_UAV",
	"OI_diverTeam",
	"OI_diverTeam_Boat",
	"OI_diverTeam_SDV",
	"BUS_TankPlatoon_AA", // BUG in CfgGroups vehicle name wrong
	"BUS_MechInf_AA" // BUG in CfgGroups vehicle name wrong
];

/*
 * Player resupply custom lists
 */

ALiVE_PR_BLACKLIST = ALiVE_PR_CUSTOM_BLACKLIST + [
	// empty for now
];

ALiVE_PR_WHITELIST = ALiVE_PR_CUSTOM_WHITELIST + [
	// empty for now
];


/*
 * Custom transport,support, and ammo classes for factions
 * Used by MP,MCP,ML to place support vehicles and ammo boxes
 * If no faction specific settings are found will fall back to side
 */

/*
 * Mil placement ambient vehicles for sides
 */

ALIVE_sideDefaultSupports = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultSupports, "EAST", ["O_Truck_02_Ammo_F","O_Truck_02_box_F","O_Truck_02_fuel_F","O_Truck_02_medical_F","O_Truck_02_transport_F","O_Truck_02_covered_F"]] call ALIVE_fnc_hashSet; // ,"Box_East_AmmoVeh_F"
[ALIVE_sideDefaultSupports, "WEST", ["B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_medical_F","B_Truck_01_Repair_F","B_Truck_01_transport_F","B_Truck_01_covered_F"]] call ALIVE_fnc_hashSet; // ,"Box_IND_AmmoVeh_F"
[ALIVE_sideDefaultSupports, "GUER", ["I_Truck_02_ammo_F","I_Truck_02_box_F","I_Truck_02_fuel_F","I_Truck_02_medical_F","I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultSupports, "CIV", ["C_Van_01_box_F","C_Van_01_transport_F","C_Van_01_fuel_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes for sides
 */

ALIVE_sideDefaultSupplies = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultSupplies, "EAST", ["Box_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Grenades_F","Box_East_Support_F","Box_East_Wps_F","Box_East_WpsLaunch_F","Box_East_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultSupplies, "WEST", ["Box_NATO_Ammo_F","Box_NATO_AmmoOrd_F","Box_NATO_Grenades_F","Box_NATO_Support_F","Box_NATO_Wps_F","Box_NATO_WpsLaunch_F","Box_NATO_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultSupplies, "GUER", ["Box_IND_Ammo_F","Box_IND_AmmoOrd_F","Box_IND_Grenades_F","Box_IND_Support_F","Box_IND_Wps_F","Box_IND_WpsLaunch_F","Box_IND_WpsSpecial_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles fallback for sides
 */

ALIVE_sideDefaultTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultTransport, "EAST", ["O_Truck_02_transport_F","O_Truck_02_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "WEST", ["B_Truck_01_transport_F","B_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "GUER", ["I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "CIV", ["C_Van_01_transport_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles fallback for sides
 */

ALIVE_sideDefaultAirTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultAirTransport, "EAST", ["O_Heli_Attack_02_F","O_Heli_Light_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "WEST", ["B_Heli_Transport_01_camo_F","B_Heli_Transport_01_camo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "GUER", ["I_Heli_light_03_unarmed_F","I_Heli_Transport_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "CIV", []] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers fallback for sides
 */

ALIVE_sideDefaultContainers = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultContainers, "EAST", ["ALIVE_O_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "WEST", ["ALIVE_B_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "GUER", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "CIV", []] call ALIVE_fnc_hashSet;

/*
 * Mil placement ambient vehicles per faction
 */

ALIVE_factionDefaultSupports = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultSupports, "OPF_F", ["O_Truck_03_repair_F","O_Truck_03_ammo_F","O_Truck_03_fuel_F","O_Truck_03_medical_F","O_Truck_02_box_F","O_Truck_02_medical_F","O_Truck_02_Ammo_F","O_Truck_02_fuel_F","O_Truck_02_covered_F","O_Truck_02_transport_F","O_Truck_03_transport_F","O_Truck_03_covered_F","O_Truck_03_device_F"]] call ALIVE_fnc_hashSet; // ,"Box_East_AmmoVeh_F"
[ALIVE_factionDefaultSupports, "OPF_G_F", ["O_G_Offroad_01_armed_F","O_G_Van_01_fuel_F","O_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "IND_F", ["I_Truck_02_ammo_F","I_Truck_02_box_F","I_Truck_02_fuel_F","I_Truck_02_medical_F","I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet; // ,"Box_IND_AmmoVeh_F"
[ALIVE_factionDefaultSupports, "BLU_F", ["B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_medical_F","B_Truck_01_Repair_F","B_Truck_01_transport_F","B_Truck_01_covered_F","B_APC_Tracked_01_CRV_F","B_Truck_01_mover_F"]] call ALIVE_fnc_hashSet; // ,"Box_NATO_AmmoVeh_F"
[ALIVE_factionDefaultSupports, "BLU_G_F", ["B_G_Van_01_fuel_F","B_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "CIV_F", ["C_Van_01_box_F","C_Van_01_transport_F","C_Van_01_fuel_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil placement random supply boxes per faction
 */

ALIVE_factionDefaultSupplies = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultSupplies, "OPF_F", ["Box_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Grenades_F","Box_East_Support_F","Box_East_Wps_F","Box_East_WpsLaunch_F","Box_East_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "OPF_G_F", ["Box_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Grenades_F","Box_East_Support_F","Box_East_Wps_F","Box_East_WpsLaunch_F","Box_East_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "IND_F", ["Box_IND_Ammo_F","Box_IND_AmmoOrd_F","Box_IND_Grenades_F","Box_IND_Support_F","Box_IND_Wps_F","Box_IND_WpsLaunch_F","Box_IND_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "BLU_F", ["Box_NATO_Ammo_F","Box_NATO_AmmoOrd_F","Box_NATO_Grenades_F","Box_NATO_Support_F","Box_NATO_Wps_F","Box_NATO_WpsLaunch_F","Box_NATO_WpsSpecial_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "BLU_G_F", ["Box_IND_Ammo_F","Box_IND_AmmoOrd_F","Box_IND_Grenades_F","Box_IND_Support_F","Box_IND_Wps_F","Box_IND_WpsLaunch_F","Box_IND_WpsSpecial_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */

ALIVE_factionDefaultTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultTransport, "OPF_F", ["O_Truck_02_transport_F","O_Truck_02_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "OPF_G_F", ["O_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "IND_F", ["I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_F", ["B_Truck_01_transport_F","B_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_G_F", ["B_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "CIV_F", ["C_Van_01_transport_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */

ALIVE_factionDefaultAirTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultAirTransport, "OPF_F", ["O_Heli_Attack_02_F","O_Heli_Light_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "OPF_G_F", ["I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "IND_F", ["I_Heli_light_03_unarmed_F","I_Heli_Transport_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_F", ["B_Heli_Transport_01_camo_F","B_Heli_Transport_01_camo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_G_F", ["I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "CIV_F", []] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */

ALIVE_factionDefaultContainers = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultContainers, "OPF_F", ["ALIVE_O_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "OPF_G_F", ["ALIVE_O_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "IND_F", ["ALIVE_I_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_F", ["ALIVE_B_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_G_F", ["ALIVE_B_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "CIV_F", []] call ALIVE_fnc_hashSet;

/*
 * Player resupply
 */

ALIVE_globalDefaultResupplyVehicleOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyVehicleOptions, "PR_AIRDROP", [["<< Back","Car","Ship"],["<< Back","Car","Ship"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyVehicleOptions, "PR_HELI_INSERT", [["<< Back","Air"],["<< Back","Air"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyVehicleOptions, "PR_STANDARD", [["<< Back","Car","Armored","Support"],["<< Back","Car","Armored","Support"]]] call ALIVE_fnc_hashSet;

ALIVE_sideDefaultResupplyVehicleOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_sideDefaultResupplyVehicleOptions, "EAST", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyVehicleOptions, "WEST", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyVehicleOptions, "GUER", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyVehicleOptions, "CIV", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;

ALIVE_factionDefaultResupplyVehicleOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_factionDefaultResupplyVehicleOptions, "OPF_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "OPF_G_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "IND_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "BLU_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "BLU_G_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "CIV_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;



ALIVE_globalDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyDefenceStoreOptions, "PR_AIRDROP", [["<< Back","Static","Fortifications","Tents","Military"],["<< Back","Static","Fortifications","Tents","Structures_Military"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyDefenceStoreOptions, "PR_HELI_INSERT", [["<< Back","Static","Fortifications","Tents","Military"],["<< Back","Static","Fortifications","Tents","Structures_Military"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyDefenceStoreOptions, "PR_STANDARD", [["<< Back","Static","Fortifications","Tents","Military"],["<< Back","Static","Fortifications","Tents","Structures_Military"]]] call ALIVE_fnc_hashSet;

ALIVE_sideDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_sideDefaultResupplyDefenceStoreOptions, "EAST", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyDefenceStoreOptions, "WEST", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyDefenceStoreOptions, "GUER", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyDefenceStoreOptions, "CIV", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;

ALIVE_factionDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_factionDefaultResupplyDefenceStoreOptions, "OPF_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "OPF_G_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "IND_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "BLU_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "BLU_G_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "CIV_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;



ALIVE_globalDefaultResupplyCombatSuppliesOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyCombatSuppliesOptions, "PR_AIRDROP", [["<< Back","Ammo"],["<< Back","Ammo"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyCombatSuppliesOptions, "PR_HELI_INSERT", [["<< Back","Ammo"],["<< Back","Ammo"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyCombatSuppliesOptions, "PR_STANDARD", [["<< Back","Ammo"],["<< Back","Ammo"]]] call ALIVE_fnc_hashSet;

ALIVE_sideDefaultResupplyCombatSuppliesOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_sideDefaultResupplyCombatSuppliesOptions, "EAST", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyCombatSuppliesOptions, "WEST", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyCombatSuppliesOptions, "GUER", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyCombatSuppliesOptions, "CIV", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;

ALIVE_factionDefaultResupplyCombatSuppliesOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "OPF_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "OPF_G_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "IND_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "BLU_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "BLU_G_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "CIV_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;



ALIVE_globalDefaultResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyIndividualOptions, "PR_AIRDROP", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyIndividualOptions, "PR_HELI_INSERT", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyIndividualOptions, "PR_STANDARD", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;

ALIVE_sideDefaultResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_sideDefaultResupplyIndividualOptions, "EAST", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyIndividualOptions, "WEST", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyIndividualOptions, "GUER", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyIndividualOptions, "CIV", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;

ALIVE_factionDefaultResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_factionDefaultResupplyIndividualOptions, "OPF_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "OPF_G_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "IND_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "BLU_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "BLU_G_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "CIV_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;



ALIVE_globalDefaultResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyGroupOptions, "PR_AIRDROP", ["Armored","Support"]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyGroupOptions, "PR_HELI_INSERT", ["Armored","Mechanized","Motorized","Motorized_MTP","SpecOps","Support"]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyGroupOptions, "PR_STANDARD", ["Support"]] call ALIVE_fnc_hashSet;

ALIVE_sideDefaultResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_sideDefaultResupplyGroupOptions, "EAST", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyGroupOptions, "WEST", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyGroupOptions, "GUER", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultResupplyGroupOptions, "CIV", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;

ALIVE_factionDefaultResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_factionDefaultResupplyGroupOptions, "OPF_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "OPF_G_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "IND_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "BLU_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "BLU_G_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "CIV_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;

/*
 * Garrison building defaults
 */

ALIVE_garrisonPositions = [] call ALIVE_fnc_hashCreate;
[ALIVE_garrisonPositions, "Land_Cargo_HQ_V1_F", [6,7,8]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_HQ_V2_F", [6,7,8]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_HQ_V3_F", [6,7,8]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Medevac_HQ_V1_F", [6,7,8]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_Tower_V3_F", [15,12,8]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_Tower_V2_F", [15,12,8]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_Tower_V1_F", [15,12,8]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_Patrol_V1_F", [1]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_Patrol_V2_F", [1]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_Cargo_Patrol_V3_F", [1]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_CarService_F", [2,5]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_u_Barracks_V2_F", [36,37,35,34,32,33,40,44]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_i_Barracks_V1_F", [36,37,35,34,32,33,40,44]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_i_Barracks_V2_F", [36,37,35,34,32,33,40,44]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_BagBunker_Small_F", [2,3]] call ALIVE_fnc_hashSet;
[ALIVE_garrisonPositions, "Land_BagFence_Round_F", [1]] call ALIVE_fnc_hashSet;

/*
 * Compositions
 */

ALIVE_compositions = [] call ALIVE_fnc_hashCreate;
[ALIVE_compositions, "HQ", ["smallHQOutpost1","largeMedicalHQ1"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "camps", ["smallConvoyCamp1","smallMilitaryCamp1","smallMortarCamp1","mediumAACamp1","mediumMilitaryCamp1","mediumMGCamp1","mediumMGCamp2","mediumMGCamp3"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "communications", ["communicationCamp1"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "fuel", ["smallFuelStation1","mediumFuelSilo1"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "constructionSupplies", ["bagFenceKit1","hbarrierKit1","hbarrierKit2","hbarrierWallKit1","hbarrierWallKit2"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "crashsites", ["smallOspreyCrashsite1","smallAH99Crashsite1","mediumc192Crash1"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "objectives", ["largeMilitaryOutpost1","mediumMilitaryOutpost1","hugeSupplyOutpost1","hugeMilitaryOutpost1"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "other", ["smallATNest1","smallMGNest1","smallCheckpoint1","smallRoadblock1","mediumCheckpoint1","largeGarbageCamp1"]] call ALIVE_fnc_hashSet;
[ALIVE_compositions, "roadblocks", ["smallCheckpoint1","smallCheckpoint2","smallCheckpoint3","mediumCheckpoint2","smallroadblock1","smallroadblock2"]] call ALIVE_fnc_hashSet;

/*
 * Task Objects
 */

ALIVE_taskObjects = [] call ALIVE_fnc_hashCreate;
[ALIVE_taskObjects, "chairs", ["Land_CampingChair_V1_F","Land_CampingChair_V2_F","Land_ChairPlastic_F","Land_ChairWood_F"]] call ALIVE_fnc_hashSet;
[ALIVE_taskObjects, "tables", ["Land_CampingTable_F","Land_TableDesk_F","Land_WoodenTable_large_F","Land_WoodenTable_small_F"]] call ALIVE_fnc_hashSet;
[ALIVE_taskObjects, "documents", ["Land_Document_01_F","Land_File1_F","Land_FilePhotos_F","Land_File2_F","Land_File_research_F","Land_Photos_V1_F","Land_Photos_V2_F","Land_Photos_V3_F"]] call ALIVE_fnc_hashSet;
[ALIVE_taskObjects, "treasure", ["Land_Money_F"]] call ALIVE_fnc_hashSet;
[ALIVE_taskObjects, "medical", ["Land_Antibiotic_F","Land_Bandage_F","Land_BloodBag_F","Land_Defibrillator_F","Land_DisinfectantSpray_F","Land_HeatPack_F","Land_PainKillers_F","Land_VitaminBottle_F","Land_WaterPurificationTablets_F"]] call ALIVE_fnc_hashSet;
[ALIVE_taskObjects, "electronics", ["Land_SatellitePhone_F","Land_PortableLongRangeRadio_F","Land_MobilePhone_smart_F","Land_MobilePhone_old_F","Land_HandyCam_F","Land_Laptop_F","Land_Laptop_device_F","Land_Laptop_unfolded_F","Land_FMradio_F","Land_SurvivalRadio_F"]] call ALIVE_fnc_hashSet;

/*
 * Genrated Tasks
 */

private["_options","_tasksData","_taskData","_taskData"];

ALIVE_generatedTasks = [] call ALIVE_fnc_hashCreate;

ALIVE_autoGeneratedTasks = ["MilAssault","MilDefence","CivAssault","Assassination","TransportInsertion","DestroyVehicles","DestroyInfantry","SabotageBuilding","InsurgencyPatrol","InsurgencyDestroyAssets"];

// Military Objective Assault Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Assault Objective"] call ALIVE_fnc_hashSet;
[_taskData,"description","Assault the objective, neutralising all enemy and denying any weapons and materiel."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Establish Overwatch"] call ALIVE_fnc_hashSet;
[_taskData,"description","Proceed to an overwatch position near %1 in order to confirm enemy dispositions prior to assaulting the objective."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","Establish overwatch at position near %1 and prepare to assault the objective, Over"],["PLAYERS","Roger Out"]]] call ALIVE_fnc_hashSet;
[_tasksData,"Travel",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Neutralise Enemy"] call ALIVE_fnc_hashSet;
[_taskData,"description","Neutralise all enemy in the vicinity in order to secure the objective"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["PLAYERS","My callsign established in overwatch position, Over"],["HQ","Assault Objective"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","All enemy area have been neutralised, objective is secure, Over"],["HQ","Roger, send SITREP and standby for further tasking, Out."]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Attack Emplacement"] call ALIVE_fnc_hashSet;
[_taskData,"description","Attack the enemy held position in order to deny mission critical assets."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Move to Forming Up Point"] call ALIVE_fnc_hashSet;
[_taskData,"description","Move to an FUP near %1 in preparation for conducting an assault on the enemy held emplacement."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","Move to an FUP near %1 and prepare to assault the emplacement, Over"],["PLAYERS","Roger Out"]]] call ALIVE_fnc_hashSet;
[_tasksData,"Travel",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Attack Objective"] call ALIVE_fnc_hashSet;
[_taskData,"description","Attack the objective and neutralise all enemy forces in the vicinity."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["PLAYERS","Am at FUP standing by, over."],["HQ","Attack Emplacement"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","Objective secure, standing by for further orders, over"],["HQ","Roger, send SITREP and await taskings, Out."]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "MilAssault", ["Military Objective Assault",_options]] call ALIVE_fnc_hashSet;

// Military Objective Defence Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Defend Objective"] call ALIVE_fnc_hashSet;
[_taskData,"description","Defend the friendly objective."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Proceed to the objective"] call ALIVE_fnc_hashSet;
[_taskData,"description","Move to the objective near %1, establish a defensive position and prepare for incoming enemy forces"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","Move to the objective near %1, establish a defensive position and prepare for incoming enemy forces"],["PLAYERS","Roger Out"]]] call ALIVE_fnc_hashSet;
[_tasksData,"Travel",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Hold the objective"] call ALIVE_fnc_hashSet;
[_taskData,"description","Hold position and defeat the incoming enemy attack."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["PLAYERS","My callsign established in defence at objective location, Over"],["HQ","Hold the objective"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","Enemy forces have been defeated in detail, objective is secure, Over"],["HQ","Roger, send SITREP and standby for further tasking, Out."]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_missile_strike",[["HQ","Critical information: suspected missile strike inbound your location, take cover, Over"],["PLAYERS","Roger, Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",20]] call ALIVE_fnc_hashSet;
[_tasksData,"DefenceWave",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "MilDefence", ["Military Objective Defence",_options]] call ALIVE_fnc_hashSet;

// Civilian Objective Assault Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Attack the civilian objective"] call ALIVE_fnc_hashSet;
[_taskData,"description","Attack the enemy held civlian objective."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Clear the town"] call ALIVE_fnc_hashSet;
[_taskData,"description","Clear all enemy forces from the town near %1."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","Clear all enemy forces from the town near %1"],["PLAYERS","Roger Out."]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","Town cleared of enemy forces, objective secure, over"],["HQ","Roger, reorg and send STIREP. Standby for further orders, Out."]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "CivAssault", ["Civilian Objective Assault",_options]] call ALIVE_fnc_hashSet;

// HVT Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Kill the HVT"] call ALIVE_fnc_hashSet;
[_taskData,"description","Kill the high value target."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Eliminate the target"] call ALIVE_fnc_hashSet;
[_taskData,"description","We received HUMINT of an High Value Target (HVT) near %1! Eliminate the target as quickly as possible!"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","We received HUMINT of an High Value Target (HVT) near %1! Eliminate the target as quickly as possible!"],["PLAYERS","Roger that"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","High Value Target neutralised, Over"],["HQ","Roger, well done, Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_failed",[["PLAYERS","Mission aborted, HVT has escaped, Over"],["HQ","Roger, better luck next time, Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_cancelled",[["PLAYERS","Callsign compromised, mission aborted, Over"],["HQ","Roger, break contact and withdraw. Send SITREP when ready, Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "Assassination", ["HVT Assassination",_options]] call ALIVE_fnc_hashSet;

// Troop Insertion Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Troop Transport Insertion"] call ALIVE_fnc_hashSet;
[_taskData,"description","Provide insertion for troops."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Pick up the troops"] call ALIVE_fnc_hashSet;
[_taskData,"description","Move to the Pick Up Point near %1."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","Move to the Pick Up Point near %1"],["PLAYERS","Roger that"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_failed",[["HQ","Local commander reports insufficient load capacity, RTB and standby for further tasking"],["PLAYERS","Roger Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_cancelled",[["HQ","Contact lost with ground forces, assume location is compromised. RTB immediately, Over"],["PLAYERS","Roger Out"]]] call ALIVE_fnc_hashSet;
[_tasksData,"Pickup",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Insert the troops"] call ALIVE_fnc_hashSet;
[_taskData,"description","Travel to the Drop Off Point near %1."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","Travel to the Drop Off Point near %1"],["PLAYERS","Roger, moving now, Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_failed",[["HQ","Too many casualties sustained, abort mission and RTB immediately, Over"],["PLAYERS","Roger Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","Units inserted at Drop Off Point"],["HQ","Roger, well done, Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Insertion",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "TransportInsertion", ["Transport Insertion",_options]] call ALIVE_fnc_hashSet;

// Destroy Vehicles Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Search and Destroy Vehicles"] call ALIVE_fnc_hashSet;
[_taskData,"description","Int indicates an enemy group of %1 in the vicinity of %2."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Destroy the vehicles"] call ALIVE_fnc_hashSet;
[_taskData,"description","We have reliable intelligence of a %1 vehicle group operating in the area near %2.  Find, fix and destroy the vehicles before they leave the area."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","We have reliable intelligence of a %1 vehicle group operating in the area near %2.  Find, fix and destroy the vehicles before they leave the area, Over!"],["PLAYERS","Roger, moving to location now, Out"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","Enemy vehicles confirmed neutralised, Over"],["HQ","Roger, well done.  Standby for further taskings, Out!"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "DestroyVehicles", ["Destroy the Vehicles",_options]] call ALIVE_fnc_hashSet;

// Destroy Infantry Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Destroy the infantry"] call ALIVE_fnc_hashSet;
[_taskData,"description","Intelligence suggests a group of infantry in the area near %1."] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Destroy the infantry"] call ALIVE_fnc_hashSet;
[_taskData,"description","We received intelligence about infantry units near %1! Destroy the infantry!"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","We received intelligence about infantry units near %1! Destroy the infantry!"],["PLAYERS","Roger that"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","Infantry units have been destroyed"],["HQ","Roger that, well done!"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "DestroyInfantry", ["Destroy the Infantry Units",_options]] call ALIVE_fnc_hashSet;

// Sabotage Building Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Sabotage in %1"] call ALIVE_fnc_hashSet;
[_taskData,"description","Destroy the %2 in %1!"] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Destroy %1"] call ALIVE_fnc_hashSet;
[_taskData,"description","We received intelligence about a strategically important %3 near %1! Destroy the %2!"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","We received intelligence about a strategically relevant position near %1! Destroy the objective!"],["PLAYERS","Roger that"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","The objective has been destroyed!"],["HQ","Roger that, well done!"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "SabotageBuilding", ["Sabotage Installation",_options]] call ALIVE_fnc_hashSet;

// Insurgency Patrol Task

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Insurgent Patrol"] call ALIVE_fnc_hashSet;
[_taskData,"description","Patrol the area for suspected insurgency activity"] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Proceed to patrol staging area"] call ALIVE_fnc_hashSet;
[_taskData,"description","Proceed to the patrol staging area."] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","Proceed to the staging area, Over"],["PLAYERS","Roger Out"]]] call ALIVE_fnc_hashSet;
[_tasksData,"Travel",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Patrol %1"] call ALIVE_fnc_hashSet;
[_taskData,"description","We received intelligence about a insurgents near %1! Patrol the Area!"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","We received intelligence about insurgent activity near %1! Patrol the area!"],["PLAYERS","Roger that"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","The patrol has been completed!"],["HQ","Roger that, well done!"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Patrol",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "InsurgencyPatrol", ["Insurgency Patrol",_options]] call ALIVE_fnc_hashSet;

// Insurgency Destroy Assets

_options = [];

_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Insurgent %1 Located"] call ALIVE_fnc_hashSet;
[_taskData,"description","Destroy the %1 near %2"] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Destroy the %1"] call ALIVE_fnc_hashSet;
[_taskData,"description","We received intelligence about a insurgents %1 near %2! Destroy the building!"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","We received intelligence about a insurgent %1 near %2! Destory the building!"],["PLAYERS","Roger that"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","The building has been destroyed!"],["HQ","Roger that, well done!"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "InsurgencyDestroyAssets", ["Insurgency Destroy Assets",_options]] call ALIVE_fnc_hashSet;

/*
 * Civ Pop Defaults
 */

ALIVE_civilianWeapons = [] call ALIVE_fnc_hashCreate;
[ALIVE_civilianWeapons, "CIV", [["hgun_Pistol_heavy_01_F","11Rnd_45ACP_Mag"],["hgun_PDW2000_F","30Rnd_9x21_Mag"],["SMG_02_ARCO_pointg_F","30Rnd_9x21_Mag"],["arifle_TRG21_F","30Rnd_556x45_Stanag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "CIV_F", [["hgun_Pistol_heavy_01_F","11Rnd_45ACP_Mag"],["hgun_PDW2000_F","30Rnd_9x21_Mag"],["SMG_02_ARCO_pointg_F","30Rnd_9x21_Mag"],["arifle_TRG21_F","30Rnd_556x45_Stanag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "mas_afr_civ", [["arifle_mas_ak_74m","30Rnd_mas_545x39_mag"],["arifle_mas_aks74u","30Rnd_mas_545x39_mag"],["arifle_mas_akm","30Rnd_mas_762x39_mag"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "caf_ag_afr_civ", [["caf_AK47","CAF_30Rnd_762x39_AK"],["caf_AK74","CAF_30Rnd_545x39_AK"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "caf_ag_me_civ", [["caf_AK47","CAF_30Rnd_762x39_AK"],["caf_AK74","CAF_30Rnd_545x39_AK"]]] call ALIVE_fnc_hashSet;
[ALIVE_civilianWeapons, "drirregularsC", [["arifle_mas_ak_74m","30Rnd_mas_545x39_mag"],["arifle_mas_aks74u","30Rnd_mas_545x39_mag"],["arifle_mas_akm","30Rnd_mas_762x39_mag"]]] call ALIVE_fnc_hashSet;

ALIVE_civilianHouseTracks = [] call ALIVE_fnc_hashCreate;
[ALIVE_civilianHouseTracks, "Track1", 180] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track2", 188] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track3", 199] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track4", 246] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track5", 335] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track6", 199] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track7", 177] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track8", 235] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track9", 246] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track10", 292] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track11", 189] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track12", 203] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track13", 16] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track14", 128] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track15", 14] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track16", 7] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track17", 19] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track18", 4] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track19", 22] call ALIVE_fnc_hashSet;
[ALIVE_civilianHouseTracks, "Track20", 2] call ALIVE_fnc_hashSet;

/*
 * Map bounds for analysis grid, this is for when the map bounds function is faulty
 * due to incorrect map size values from config.
 */
ALIVE_mapBounds = [] call ALIVE_fnc_hashCreate;
[ALIVE_mapBounds, "utes", 5000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "fallujah", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Thirsk", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "ThirskW", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Chernarus", 16000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Chernarus_Summer", 16000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "FDF_Isle1_a", 21000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Takistan", 13000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "IsolaDiCapraia", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "fata", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "hellskitchen", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "hellskitchens", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "pja305", 21000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Celle", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Takistan", 13000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "praa_av", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "tavi", 26000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Woodland_ACR", 8000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Imrali", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "wake", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Colleville", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Panthera3", 10000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "anim_helvantis_v2", 10200] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "smd_sahrani_a3", 20480] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Esseker", 13000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Mog", 11000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Pandora", 21000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "mske", 26000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "Kunduz", 6000] call ALIVE_fnc_hashSet;
[ALIVE_mapBounds, "australia", 40960] call ALIVE_fnc_hashSet;

/*
 * CP MP building types for cluster generation
 */

private["_worldName","_fileExists"];

_worldName = worldName;

// Load map static data
// check file exists, if not then load hardcoded
_fileExists = [format["x\alive\addons\main\static\%1_staticData.sqf", worldName]] call ALiVE_fnc_fileExists;

If (_fileExists) then {
	["ALiVE LOADING MAP DATA: %1",_worldName] call ALIVE_fnc_dump;
	_file = format["x\alive\addons\main\static\%1_staticData.sqf", worldName];
	call compile preprocessFileLineNumbers _file;
} else {
	["ALiVE SETTING UP MAP (HARD CODED): %1",_worldName] call ALIVE_fnc_dump;

	ALIVE_airBuildingTypes = [];
	ALIVE_militaryParkingBuildingTypes = [];
	ALIVE_militarySupplyBuildingTypes = [];
	ALIVE_militaryHQBuildingTypes = [];
	ALIVE_militaryAirBuildingTypes = [];
	ALIVE_civilianAirBuildingTypes = [];
	ALIVE_militaryHeliBuildingTypes = [];
	ALIVE_civilianHeliBuildingTypes = [];
	ALIVE_militaryBuildingTypes = [];
	ALIVE_heliBuildingTypes = [];
	ALIVE_civilianPopulationBuildingTypes = [];
	ALIVE_civilianHQBuildingTypes = [];
	ALIVE_civilianPowerBuildingTypes = [];
	ALIVE_civilianCommsBuildingTypes = [];
	ALIVE_civilianMarineBuildingTypes = [];
	ALIVE_civilianRailBuildingTypes = [];
	ALIVE_civilianFuelBuildingTypes = [];
	ALIVE_civilianConstructionBuildingTypes = [];
	ALIVE_civilianSettlementBuildingTypes = [];
	// Altis Stratis
	if(_worldName == "Altis" || _worldName == "Stratis" || _worldName == "Koplic" || _worldName == "sfp_wamako" || _worldName == "Imrali" || _worldName == "wake" || _worldName == "gorgona") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    	"hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_tower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
	    	"tenthangar"
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    	"hangar",
	    	"runway_beton",
	    	"runway_main",
	    	"runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"airport_tower",
	    	"radar",
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"mil_wall",
	    	"fortification",
	    	"razorwire",
	    	"dome"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
	        "house_",
	        "shop_",
	        "garage_",
	        "stone_"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"offices"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dp_main",
	    	"spp_t"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    	"communication_f",
	    	"ttowerbig_"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    	"crane",
	    	"lighthouse",
	    	"nav_pier",
	    	"pier_"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [

	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    	"fuelstation",
	    	"dp_bigtank"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    	"wip",
	    	"bridge_highway"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "church",
	    	"hospital",
	    	"amphitheater",
	    	"chapel_v",
	    	"households"
	    ];

	};

	// Esseker
	if(_worldName == "Esseker") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    	"hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"barrack",
	        "airport",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand",
	        "u_barracks_v2_f"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"posed",
	        "mil_controltower",
	        "fuelstation_army",
	        "mil_house"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_tower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
	    	"tenthangar"
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	    	"hangar",
	    	"runway_beton",
	    	"runway_end",
	    	"runway_main",
	    	"runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"airport_tower",
	    	"radar",
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"mil_wall",
	    	"fortification",
	    	"razorwire",
	    	"airport_tower",
	        "bunker",
	        "cargo_patrol_",
	        "research",
	        "army_hut",
	        "mil_wall",
	        "fortification",
	        "dome",
	        "deerstand",
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand",
	        "hospital"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
	        "house_",
	        "shop_",
	        "garage_",
	        "stone_",
	        "House",
	        "domek",
	        "sara"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"offices"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dp_main",
	    	"spp_t",
	    	"pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    	"communication_f",
	    	"ttowerbig_",
	    	"communication_f",
	        "telek",
	        "telek1",
	        "transmitter_tower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    	"crane",
	    	"lighthouse",
	    	"nav_pier",
	    	"pier_",
	    	"pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [

	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    	"fuelstation",
	    	"dp_bigtank",
	    	"indpipe",
	        "komin",
	        "ind_tankbig"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    	"wip",
	    	"bridge_highway",
	    	"sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "church",
	    	"hospital",
	    	"amphitheater",
	    	"chapel_v",
	    	"households",
	    	"generalstore",
	        "house",
	        "domek",
	        "dum_",
	        "kulna",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "dum_mesto_in",
	        "dum_mesto2",
	        "hotel"
	    ];

	};

	// Mogadishu, Nam (Pandora)
	if(_worldName == "Mog" || _worldName == "Pandora") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    	"hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"barrack",
	        "airport",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand",
	        "u_barracks_v2_f"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"posed",
	        "mil_controltower",
	        "fuelstation_army",
	        "mil_house"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_tower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
	    	"tenthangar"
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	    	"hangar",
	    	"runway_beton",
	    	"runway_end",
	    	"runway_main",
	    	"runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"airport_tower",
	    	"radar",
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"mil_wall",
	    	"fortification",
	    	"razorwire",
	    	"airport_tower",
	        "bunker",
	        "cargo_patrol_",
	        "research",
	        "army_hut",
	        "mil_wall",
	        "fortification",
	        "dome",
	        "deerstand",
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand",
	        "hospital"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
	        "house_",
	        "shop_",
	        "garage_",
	        "stone_",
	        "House",
	        "domek",
	        "sara",
	        "jbad_house_",
	        "jbad_house2_",
	        "jbad_house3",
	        "jbad_house5",
	        "jbad_house6",
	        "jbad_house7",
	        "jbad_house8",
	        "jbad_a_mosque_",
	        "jbad_a_minaret",
	        "jbad_mosque_",
	        "jbad_market_",
	        "qualat",
	        "slum",
	        "shed",
	        "garage",
	        "stone_housebig",
	        "stone_housesmall"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"offices",
	    	"jbad_house2_",
	        "jbad_mosque_"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dp_main",
	    	"spp_t",
	    	"pec_",
	        "powerstation",
	        "trafostanica",
	        "dieselpowerplant",
	        "solarpowerplant",
	        "windpowerplant",
	        "wavepowerplant",
	        "powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    	"communication_f",
	    	"ttowerbig_",
	    	"communication_f",
	        "telek",
	        "telek1",
	        "transmitter_tower",
	        "jbad_tv_",
	        "jbad_antenna"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    	"crane",
	    	"lighthouse",
	    	"nav_pier",
	    	"pier_",
	    	"pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "jbad_a_stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    	"fuelstation",
	    	"dp_bigtank",
	    	"indpipe",
	        "komin",
	        "ind_tankbig",
	        "jbad_ind_garage01"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    	"wip",
	    	"bridge_highway",
	    	"sawmillpen",
	        "workshop",
	        "jbad_bedna",
	        "jbad_cihly1",
	        "jbad_cihly2",
	        "jbad_cihly3",
	        "jbad_cihly4",
	        "jbad_koz",
	        "jbad_ind_coltan",
	        "jbad_ind_shed"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "church",
	    	"hospital",
	    	"amphitheater",
	    	"chapel_v",
	    	"households",
	    	"generalstore",
	        "house",
	        "domek",
	        "dum_",
	        "kulna",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "dum_mesto_in",
	        "dum_mesto2",
	        "hotel"
	    ];

	};

	// Iron Front
	if(_worldName == "Baranow" || _worldName == "Staszow" || _worldName == "ivachev" || _worldName == "Panovo" || _worldName == "Colleville") then {

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "Land_lib_Mil_Barracks",
	        "lib_posed",
	        "blockhouse",
	        "barrier_p1",
	        "ZalChata",
	        "lib_Mil_Barracks_L",
	        "dum01",
	        "lib_m3",
	        "lib_m2",
	        "fort_bagfence_round",
	        "lib_bunker_mg",
	        "lib_bunker_gun_l",
	        "lib_bunker_gun_r"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "Land_lib_Mil_Barracks",
	        "lib_posed",
	        "blockhouse",
	        "barrier_p1",
	        "ZalChata",
	        "lib_Mil_Barracks_L",
	        "dum01",
	        "lib_m3",
	        "lib_m2",
	        "fort_bagfence_round",
	        "lib_bunker_mg",
	        "lib_bunker_gun_l",
	        "lib_bunker_gun_r"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"Land_lib_Mil_Barracks",
	    	"lib_Mil_Barracks_L",
	        "dum01"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"Land_lib_Mil_Barracks",
	        "lib_posed",
	        "blockhouse",
	        "barrier_p1",
	        "ZalChata",
	        "lib_Mil_Barracks_L",
	        "dum01",
	        "lib_m3",
	        "lib_m2",
	        "fort_bagfence_round",
	        "lib_bunker_mg",
	        "lib_bunker_gun_l",
	        "lib_bunker_gun_r"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"lib_admin",
	    	"lib_kostel_1",
	    	"lib_church"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "kulna",
	        "lib_dom",
	        "lib_cr",
	        "lib_sarai",
	        "lib_Kladovka",
	        "lib_hata",
	        "lib_apteka",
	        "lib_city_shop",
	        "lib_kirpich",
	        "lib_banya",
	        "lib_dlc1_corner_house",
	        "lib_dlc1_apteka",
	        "lib_dlc1_city_house",
	        "lib_dlc1_kirpich",
	        "lib_french_stone_house",
	        "lib_dlc1_house_1floor_pol"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Kunduz
	if(tolower(_worldName) == "kunduz") then {
		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["pra3\pra3_tunnels\floor_sandy.p3d","pra3\pra3_tunnels\tunnel_small_ramp.p3d","pra3\pra3_tunnels\wood_beams_h_join.p3d","pra3\pra3_tunnels\wood_beams_h_sloped.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_tunnels\tunnel_small_bend.p3d","pra3\pra3_tunnels\tunnel_large_s_bend.p3d","pra3\pra3_tunnels\tunnel_large_room_1door.p3d","pra3\pra3_tunnels\wood_beams_t.p3d","pra3\pra3_tunnels\wood_beams.p3d","pra3\pra3_tunnels\tunnel_large_room_4doors.p3d","pra3\pra3_tunnels\wood_beams_h.p3d","pra3\pra3_tunnels\cable_hanging.p3d","pra3\pra3_tunnels\cable_ground.p3d"];
		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];
		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["pra3\pra3_tunnels\floor_sandy.p3d","pra3\pra3_tunnels\tunnel_small_ramp.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_tunnels\tunnel_small_bend.p3d","pra3\pra3_tunnels\tunnel_large_room_1door.p3d"];
		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_tunnels\tunnel_large_room_1door.p3d"];
		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];
		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];
		ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];
		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];
		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["pra3\pra3_structures\walls\walls_l\jbad_wall_l_5m.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5_corner.p3d","pra3\pra3_misc\misc_market\jbad_stand_water.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_stuff.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_2m5_gate.p3d","pra3\pra3_misc\misc_market\jbad_market_stalls_01.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_reservoir.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d","pra3\pra3_misc\misc_market\jbad_market_shelter.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_5m_dam.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l_mosque_2.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d","pra3\pra3_misc\misc_market\jbad_covering_hut_big.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l1_pillar.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d","pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d","pra3\pra3_structures\afghan_houses\jbad_house5.p3d","pra3\pra3_structures\afghan_houses\jbad_house_1.p3d","a3\structures_f\walls\net_fence_gate_f.p3d","pra3\pra3_structures\afghan_houses\jbad_terrace.p3d","pra3\pra3_misc\misc_well\jbad_misc_well_c.p3d","pra3\pra3_misc\misc_market\jbad_covering_hut.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l1_5m.p3d","pra3\pra3_misc\misc_market\jbad_stand_meat.p3d","pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d","pra3\pra3_misc\misc_construction\jbad_misc_concbox.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","pra3\pra3_structures\afghan_houses\jbad_house6.p3d","pra3\pra3_structures\afghan_houses\jbad_house8.p3d","pra3\pra3_structures\afghan_houses\jbad_house3.p3d","pra3\pra3_structures\afghan_houses\jbad_house7.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d","pra3\pra3_structures\fata\qalat.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l2_5m.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l2_5m_end.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l3_gate.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l3_5m.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d","pra3\pra3_misc\misc_market\jbad_kiosk.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d","pra3\pra3_structures\walls\walls_l\jbad_wall_l1_gate.p3d","pra3\pra3_structures\afghan_houses_a\a_minaret\jbad_a_minaret.p3d"];
		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d","pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d","pra3\pra3_structures\afghan_houses\jbad_house5.p3d","pra3\pra3_structures\afghan_houses\jbad_house_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d","pra3\pra3_tunnels\floor_sandy.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_structures\afghan_houses\jbad_house6.p3d","pra3\pra3_structures\afghan_houses\jbad_house8.p3d","pra3\pra3_structures\afghan_houses\jbad_house3.p3d","pra3\pra3_structures\afghan_houses\jbad_house7.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d"];
		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["pra3\pra3_structures\afghan_houses_old\jbad_house_3_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_1_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_old.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_9_stuff.p3d","pra3\pra3_misc\misc_market\jbad_market_stalls_01.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_8_old.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_11.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_4_old.p3d","pra3\pra3_misc\misc_well\jbad_misc_well_l.p3d","pra3\pra3_misc\misc_market\jbad_market_shelter.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_6_old.p3d","pra3\pra3_misc\misc_market\jbad_covering_hut_big.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_1.p3d","pra3\pra3_structures\afghan_houses_a\a_mosque_small\jbad_a_mosque_small_2.p3d","pra3\pra3_structures\afghan_houses\jbad_house2_basehide.p3d","pra3\pra3_structures\afghan_houses_old\jbad_house_7_old.p3d","pra3\pra3_structures\afghan_houses\jbad_house5.p3d","pra3\pra3_structures\afghan_houses\jbad_house_1.p3d","pra3\pra3_structures\afghan_houses\jbad_terrace.p3d","pra3\pra3_structures\afghan_houses_c\jbad_boots.p3d","pra3\pra3_tunnels\tunnel_large_winding.p3d","pra3\pra3_structures\afghan_houses\jbad_house6.p3d","pra3\pra3_structures\afghan_houses\jbad_house8.p3d","pra3\pra3_structures\afghan_houses\jbad_house3.p3d","pra3\pra3_structures\afghan_houses\jbad_house7.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_2.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_3.p3d","pra3\pra3_misc\misc_market\jbad_kiosk.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_4.p3d","pra3\pra3_structures\afghan_houses_c\jbad_house_c_5_v2.p3d"];
		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["a3\structures_f\ind\powerlines\powercable_submarine_f.p3d"];
		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];
		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];
		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [];
		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["pra3\pra3_misc\misc_construction\jbad_misc_ironpipes.p3d","pra3\pra3_misc\misc_ruins\jbad_rubble_concrete_01.p3d","pra3\pra3_misc\misc_construction\jbad_misc_concpipeline.p3d","pra3\pra3_misc\misc_construction\jbad_misc_concbox.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","pra3\pra3_tunnels\wood_beam.p3d","pra3\pra3_misc\bridge\ic_002_bridge.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_4_d.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_4.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_end_3.p3d","pra3\pra3_structures\walls\walls\jbad_wall_indcnc_end_2.p3d"];
	};

	// Hindu Kush
	if(_worldName == "HinduKush") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
			"hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
			"bunker"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
			"barracks"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
			"barracks",
			"jbad_mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
			"jbad_hangar_"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
			"helipads"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
			"helipads"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
			"hbarrier",
			"tenthangar",
			"jbad_mil_"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
			"jbad_house_",
			"jbad_house2_",
			"jbad_house3",
			"jbad_house5",
			"jbad_house6",
			"jbad_house7",
			"jbad_house8",
			"jbad_a_mosque_",
			"jbad_a_minaret",
			"jbad_mosque_",
			"jbad_market_",
			"qualat",
			"slum",
			"shed",
			"garage",
			"stone_housebig",
			"stone_housesmall"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
			"jbad_house2_",
			"jbad_mosque_"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dieselpowerplant",
			"solarpowerplant",
			"windpowerplant",
			"wavepowerplant",
			"powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
			"jbad_tv_",
			"jbad_antenna"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
			"jbad_a_stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
			"fuelstation",
			"jbad_ind_garage01",
			"indpipe"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
			"concretemixingplant",
			"scrapyard",
			"wip",
			"jbad_bedna",
			"jbad_cihly1",
			"jbad_cihly2",
			"jbad_cihly3",
			"jbad_cihly4",
			"jbad_koz",
			"jbad_ind_coltan",
			"jbad_ind_shed"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
	    ];

	};

	// Bornholm
	if(_worldName == "Bornholm") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    	"hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_tower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
	    	"tenthangar"
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    	"hangar",
	    	"runway_beton",
	    	"runway_main",
	    	"runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    	"helipads"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"airport_tower",
	    	"radar",
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"mil_wall",
	    	"fortification",
	    	"razorwire",
	    	"dome_"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
	        "house_",
	        "shop_",
	        "garage_",
	        "stone_",
	        "olezlina",
	        "domek",
	        "dum",
	        "kulna",
	        "statek",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "mesto",
	        "hotel",
	        "deutshe",
	        "house"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"offices"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dp_main",
	    	"spp_t"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    	"communication_f",
	    	"ttowerbig",
	    	"tvtower",
	    	"illuminanttower",
	        "vysilac_fm",
	        "telek"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    	"crane",
	    	"lighthouse",
	    	"nav_pier",
	    	"pier_"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [

	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    	"fuelstation",
	    	"dp_bigtank",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    	"wip",
	    	"bridge_highway",
	    	"ind_mlyn_01",
	        "ind_pec_01",
	        "sawmill",
	        "workshop",
	        "ind_timbers"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "church",
	    	"hospital",
	    	"amphitheater",
	    	"chapel_v",
	    	"households",
	    	"church",
	        "olezlina",
	        "domek",
	        "dum",
	        "kulna",
	        "statek",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "mesto",
	        "hotel",
	        "deutshe",
	        "house"
	    ];

	};

	// Panthera A3
	if(_worldName == "panthera3") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    	"hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    	"bunker",
	    	"cargo_patrol_",
	    	"research",
	    	"barrack",
	    	"airport",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand",
	        "u_barracks_v2_f"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"cargo_patrol_",
	    	"research",
	    	"posed",
	    	"mil_controltower",
	    	"fuelstation_army",
	    	"mil_house"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"barrack",
	        "mil_house"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    	"ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [

	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    	"heli_h_civil"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"airport_tower",
	    	"bunker",
	    	"cargo_patrol_",
	    	"research",
	    	"army_hut",
	    	"mil_wall",
	    	"fortification",
	    	"dome",
	    	"deerstand",
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand",
	        "hospital"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
	        "house_",
	        "shop_",
	        "garage_",
	        "stone_"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"offices",
	    	"a_office01"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dp_main",
	    	"spp_t",
	    	"pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    	"communication_f",
	        "telek",
	        "telek1",
	        "transmitter_tower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    	"crane",
	    	"lighthouse",
	    	"nav_pier",
	    	"pier_",
	    	"pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [

	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    	"fuelstation",
	    	"dp_bigtank",
	        "indpipe",
	        "komin",
	        "ind_tankbig"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    	"wip",
	    	"bridge_highway",
	    	"sawmillpen",
	    	"workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "church",
	    	"hospital",
	    	"amphitheater",
	    	"chapel_v",
	    	"households",
	    	"generalstore",
	        "house",
	        "domek",
	        "dum_",
	        "kulna",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "dum_mesto_in",
	        "dum_mesto2",
	        "hotel"
	    ];
	};

	// Isla Duala A3 v3.33
	if(_worldName == "isladuala3") then {

		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
			"hangar"
		];

		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
			"barrack",
			"mil_house",
			"fort_",
			"mil_",
			"mil_controltower",
			"mil_guardhouse",
			"misc_deerstand",
			"deerstand"
		];

		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
			"barrack",
			"mil_house",
			"mil_controltower",
			"mil_guardhouse"
		];

		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
			"barrack",
			"barracks",
			"tent_",
			"mil_house",
			"mil_controltower"
		];

		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
		];

		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
			"ss_hangar",
			"airport",
			"hangar",
			"runway_beton",
			"runway_end",
			"runway_",
			"runway_main",
			"runway_secondary"
		];

		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
		];

		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
		];

		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
			"deerstand",
			"vez",
			"army_hut",
			"tents",
			"fort_",
			"barrack",
			"mil_",
			"mil_house",
			"mil_controltower",
			"mil_guardhouse",
			"misc_deerstand",
			"deerstand"
		];

		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
			"a_office01"
		];

		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
			"pec_",
			"powerstation",
			"trafostanica"
		];

		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
			"illuminanttower",
			"vysilac_fm",
			"telek",
			"telek1",
			"tvtower"
		];

		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
			"crane",
			"lighthouse",
			"nav_",
			"nav_pier",
			"pier_",
			"pier"
		];

		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
			 "rail_loco"
		];

		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
			"fuelstation",
			"expedice",
			"indpipe",
			"komin",
			"ind_tankbig"
		];

		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
			"wip",
			"ind_",
			"a_cranecon",
			"a_buildingwip",
			"sawmillpen",
			"workshop"
		];

		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
			"generalstore",
			"budova",
			"shed_",
			"chapels",
			"house",
			"plot_",
			"households",
			"housea",
			"housebt",
			"housec",
			"housek",
			"housel",
			"housev",
			"domek",
			"slums",
			"a_castle_",
			"dum_",
			"hut0",
			"misc_market",
			"barn_",
			"hut_"
		];

		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
			];
	};

	// Lingor A3
	if(_worldName == "lingor3") then {

		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
			"hangar"
		];

		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
			"barrack",
			"mil_house",
			"fort_",
			"mil_",
			"mil_controltower",
			"mil_guardhouse",
			"misc_deerstand",
			"deerstand"
		];

		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
			"barrack",
			"mil_house",
			"mil_controltower",
			"mil_guardhouse"
		];

		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
			"barrack",
			"barracks",
			"tent_",
			"mil_house",
			"mil_controltower"
		];

		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
		];

		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
			"ss_hangar",
			"airport",
			"hangar",
			"runway_beton",
			"runway_end",
			"runway_",
			"runway_main",
			"runway_secondary"
		];

		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
		];

		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
		];

		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
			"deerstand",
			"vez",
			"army_hut",
			"tents",
			"fort_",
			"barrack",
			"mil_",
			"mil_house",
			"mil_controltower",
			"mil_guardhouse",
			"misc_deerstand",
			"deerstand"
		];

		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
			"a_office01",
			"police_station"
		];

		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
			"pec_",
			"powerstation",
			"trafostanica"
		];

		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
			"illuminanttower",
			"vysilac_fm",
			"telek",
			"telek1",
			"tvtower",
			"radiotelescope"
		];

		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
			"crane",
			"lighthouse",
			"nav_",
			"nav_pier",
			"pier_",
			"pier"
		];

		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
			 "rail_loco"
		];

		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
			"fuelstation",
			"expedice",
			"indpipe",
			"komin",
			"ind_tankbig"
		];

		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
			"wip",
			"ind_",
			"a_cranecon",
			"a_buildingwip",
			"sawmillpen",
			"workshop"
		];

		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
			"generalstore",
			"budova",
			"shed_",
			"chapels",
			"house",
			"plot_",
			"households",
			"housea",
			"housebt",
			"housec",
			"housek",
			"housel",
			"housev",
			"domek",
			"slums",
			"a_castle_",
			"dum_",
			"hut0",
			"misc_market",
			"barn_",
			"hut_",
			"flats",
			"shanties"
		];

		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
			];
	};

	// Fallujah
	if(_worldName == "fallujah") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "airport",
	        "bunker",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "miloffices"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	        "heli_h_rescue"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "radar",
	        "bunker",
	        "deerstand",
	        "hbarrier",
	        "razorwire",
	        "vez",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "wtower"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_01",
	        "wip",
	        "bridge_highway",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "fallujah_hou",
	        "hospital"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// everon2014
	if(_worldName == "everon2014") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    	"hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
			"airport",
	        "bunker",
	        "watchtower",
	        "fortified",
			"army",
	        "vez",
	        "budova",
			"mesto3"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
			"barrack",
	        "mil_house",
	        "mil_controltower",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"barrack",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_tower",
			"barrack",
	        "mil_house",
	        "mil_controltower",
	        "miloffices"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
	    	"tenthangar"
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    	"hangar",
	    	"runway_beton",
	    	"runway_main",
	    	"runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    	"helipads",
			"heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    	"helipads",
			"heli_h_rescue"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"airport_tower",
	    	"radar",
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"mil_wall",
	    	"fortification",
	    	"razorwire",
	    	"dome",
	        "deerstand",
	        "hbarrier",
	        "vez",
	        "watchtower",
	        "fortified",
			"vez",
	        "hlaska",
	        "budova",
	        "posed",
	        "hospital"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
	        "house_",
	        "shop_",
	        "garage_",
	        "stone_"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"offices"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dp_main",
	    	"spp_t",
			"pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    	"communication_f",
	    	"ttowerbig_",
			"illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    	"crane",
	    	"lighthouse",
	    	"nav_pier",
	    	"pier_",
			"najezd",
	        "cargo",
	        "nabrezi",
	        "podesta"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
			"stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    	"fuelstation",
	    	"dp_bigtank",
			"fuelstation",
	        "expedice",
	        "komin",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    	"wip",
	    	"bridge_highway"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "church",
	    	"hospital",
	    	"amphitheater",
	    	"chapel_v",
	    	"households",
			"olezlina",
	        "domek",
	        "dum",
	        "kulna",
	        "statek",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "mesto",
	        "hotel"
	    ];

	};


	// Namalsk
	if(_worldName == "Namalsk") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [

	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	        "heli_h_civil"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "razorwire",
	        "vez",
	        "hlaska"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "vysilac_fm"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "Crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "wtower"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "komin",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// smd sahrani a3
	if(_worldName == "smd_sahrani_a3") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "smd_ss_hangard_"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
			"army",
	        "vez",
	        "budova"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
			"army"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
			"mesto3"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [

	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
			"vez",
	        "hlaska",
	        "budova",
	        "posed",
	        "hospital"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
			"rohova"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [

	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [

	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "najezd",
	        "cargo",
	        "nabrezi",
	        "podesta"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [

	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house",
			"plot_",
	        "dum_",
	        "hut0",
			"olezlina",
	        "domek",
	        "dum",
	        "kulna",
	        "statek",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "mesto",
	        "hotel",
			"jezek_kov"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [

		];
	};

	// SMD Sahrani
	if(_worldName == "smd_sahrani_a2" || _worldName == "Sara" || _worldName == "SaraLite" || _worldName == "Sara_dbe1") then {

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "army",
	        "vez",
	        "budova"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "army"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "mesto3"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
	        "hlaska",
	        "budova",
	        "posed",
	        "hospital"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "rohova"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "olezlina",
	        "domek",
	        "dum",
	        "kulna",
	        "statek",
	        "afbar",
	        "panelak",
	        "deutshe",
	        "mesto",
	        "hotel"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "najezd",
	        "cargo",
	        "nabrezi",
	        "podesta"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Thirsk
	if(_worldName == "thirsk" || _worldName == "thirskw" ) then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "airport"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar",
	        "runway_end",
	        "runway_main"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [

	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	        "heli_h_civil"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "razorwire",
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "wtower"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "indpipe",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Chernarus
	if(_worldName == "Chernarus" || _worldName == "Chernarus_Summer" || _worldName == "sfp_sturko" || _worldName == "tavi") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02",
	        "a_municipaloffice"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "rail_house",
	        "rail_station",
	        "rail_platform",
	        "rails_bridge",
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_01",
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "houseblock",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Chernarus Winter
	if(tolower(_worldName) == "chernarus_winter") then {
		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["airport_tower","radar","bunker","cargo_house_v","cargo_patrol_","research","mil_wall","fortification","razorwire","dome","deerstand","vez"];
		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["bunker","cargo_house_v","cargo_patrol_","research","bunker"];
		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["barrack","cargo_hq_","miloffices","cargo_house_v","cargo_patrol_","research","barrack","mil_house","mil_controltower"];
		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["barrack","cargo_hq_","miloffices","cargo_tower","barrack","mil_house","mil_controltower"];
		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["hangar","hangar"];
		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + ["tenthangar"];
		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + ["hangar","runway_beton","runway_main","runway_secondary","ss_hangar","hangar_2","hangar","runway_beton","runway_end","runway_main","runway_secondary"];
		ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["helipads"];
		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["helipads"];
		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + ["helipads"];
		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["church","hospital","amphitheater","chapel_v","households","hospital","houseblock","generalstore","house"];
		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["offices","a_office01","a_office02","a_municipaloffice"];
		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["church","hospital","amphitheater","chapel_v","households","hospital","houseblock","generalstore","house"];
		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["dp_main","spp_t","pec_","powerstation","trafostanica"];
		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + ["communication_f","ttowerbig_","illuminanttower","vysilac_fm","telek","tvtower"];
		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["crane","lighthouse","nav_pier","pier_","crane","lighthouse","nav_pier","pier_","pier"];
		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + ["rail_house","rail_station","rail_platform","rails_bridge","stationhouse"];
		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["fuelstation","dp_bigtank","fuelstation","expedice","indpipe","komin","ind_stack_big","ind_tankbig","fuel_tank_big"];
		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["wip","bridge_highway","ind_mlyn_01","ind_pec_01","wip","sawmillpen","workshop"];
	};

	// Helvantis
	if(_worldName == "anim_helvantis_v2") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
			"ss_hangar",
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
			"wf_",
			"wf_depot",
			"wf_field_hospital_west",
			"wf_field_hospital_east",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
			"tents",
			"tent_",
			"tent_east",
			"tent_west",
			"mil_",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
			"airport_center_f",
			"airport_left_f",
			"airport_right_f",
			"airport_tower_f",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
			"misc3",
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02",
	        "a_municipaloffice"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
			"solarpowerplant",
	        "trafostanica",
			"dieselpowerplant"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
			"transmitter_tower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "rail_house",
	        "rail_station",
			"rail_station_big",
	        "rail_platform",
	        "rails_bridge",
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
			"ind_oil_mine",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
			"ind_quarry",
			"cmp_",
			"ind_sawmill",
			"factory",
	        "ind_pec_01",
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
			"a_castle_",
			"barn_",
			"barn_w",
	        "houseblock",
			"houseblocks",
	        "generalstore",
			"ghosthotel",
			"households",
			"sara_",
			"domek",
			"dum_",
			"panelaky",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Podagorsk
	if(_worldName == "fdf_isle1_a") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02",
	        "a_municipaloffice"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "rail_house",
	        "rail_station",
	        "rail_platform",
	        "rails_bridge",
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_01",
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "houseblock",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// MBG Celle 2
	if(_worldName == "mbg_celle2" || _worldName == "Celle") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02",
	        "a_municipaloffice"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "rail_house",
	        "rail_station",
	        "rail_platform",
	        "rails_bridge",
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_01",
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "houseblock",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Shapur
	if(_worldName == "Shapur_BAF") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "indpipe",
	        "komin",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Takistan
	if(_worldName == "Takistan") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "airport",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "miloffices"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "razorwire",
	        "vez",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "indpipe",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "coltan"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Zargabad
	if(_worldName == "Zargabad") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker",
	        "barrack"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "indpipe",
	        "komin",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "houseblock",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// CLAfghan
	if(_worldName == "CLAfghan") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker",
	        "barrack",
	        "guardhouse"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
	        "guardtower",
	        "tents",
	        "fortified",
	        "bunker",
	        "guardhouse",
	        "fortress"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "indpipe",
	        "komin",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_sawmill"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "houseblock",
	        "house",
	        "opxbuildings"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// MCN Hazarkot
	if(_worldName == "MCN_HazarKot") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_coltan_mine"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Isola Di Capraia
	if(_worldName == "isoladicapraia" || _worldName == "napf") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02",
	        "a_municipaloffice"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "rail_house",
	        "rail_station",
	        "rail_platform",
	        "rails_bridge",
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_01",
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "houseblock",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Caribou
	if(_worldName == "caribou") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "bunker"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "vez"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02",
	        "a_municipaloffice"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "rail_house",
	        "rail_station",
	        "rail_platform",
	        "rails_bridge",
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_01",
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "houseblock",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Tigeria
	if(_worldName == "tigeria") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "vez",
	        "army_hut",
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "mil_guardhouse",
	        "deerstand"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "lighthouse",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_tankbig"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "wip",
	        "sawmillpen",
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "generalstore",
	        "house",
	        "domek",
	        "dum_",
	        "hut0"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Fata
	if(_worldName == "fata") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_guardhouse",
	        "deerstand"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_guardhouse",
	        "deerstand"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand",
	        "vez",
	        "barrack",
	        "mil_house",
	        "mil_guardhouse",
	        "deerstand",
	        "barrier",
	        "hlaska",
	        "watchtower",
	        "hbarrier"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation",
	        "trafostanica",
	        "ind_coltan_mine"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "vysilac_fm"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "ind_tankbig"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "wip",
	        "ind_coltan_mine"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Afghan Village
	if(_worldName == "praa_av") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "mil"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "mil"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
	        "mil"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation",
	        "ind_coltan_mine",
	        "ind_pipes"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "ind_tankbig"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "wip",
	        "ind_coltan_mine"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Sangin
	if(_worldName == "hellskitchen" || _worldName == "hellskitchens") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "barrack",
	        "mil_controltower",
	        "guardtower",
	        "killhouse",
	        "watchtower"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_controltower",
	        "guardtower",
	        "killhouse"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [

	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "barrack",
	        "mil_controltower",
	        "hesco",
	        "guardtower",
	        "killhouse",
	        "watchtower",
	        "nest"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "indpipe",
	        "ind_tankbig"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "wip",
	        "sawmillpen",
	        "workshop",
	        "cementworks"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "generalstore",
	        "house",
	        "dum_",
	        "hut"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Torabora
	if(_worldName == "torabora") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "construction"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// TUP Qom
	if(_worldName == "tup_qom") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "barrack"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "guardhouse"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main",
	        "runway_secondary"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "guardhouse"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica",
	        "powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "wip",
	        "workshop",
	        "ind_coltan_mine"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;
	};

	// Utes
	if(_worldName == "utes") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "barrack"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "guardhouse"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "guardhouse"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "nav_"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// FSF - Nziwasogo (5), Dariyah (7), Gunkizli(8)
	if(_worldName == "pja305" || _worldName == "pja307" || _worldName == "pja308") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "fortified"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "fortified"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
			"mil_guardhouse",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [

	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [

	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "wtower",
	        "najezd",
	        "cargo"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_01",
	        "wip",
	        "sawmillpen",
	        "workshop",
			"coltan"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "dum",
	        "shed",
	        "hut",
	        "house",
			"minaret",
			"mosque"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	//Kalu Khan (6)
	if(tolower(_worldName) == "pja306") then {
		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["ca\misc_e\fortified_nest_small_ep1.p3d","ca\structures_e\mil\mil_barracks_l_ep1.p3d","ca\buildings2\ind_tank\ind_tankbig.p3d","ca\structures_e\mil\mil_barracks_i_ep1.p3d","ca\misc_e\fortified_nest_big_ep1.p3d","ca\structures_e\mil\mil_house_ep1.p3d","ca\structures_e\mil\mil_guardhouse_ep1.p3d"];
		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [];
		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["ca\structures_e\mil\mil_barracks_l_ep1.p3d"];
		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["ca\structures_e\mil\mil_house_ep1.p3d"];
		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["ca\roads_e\runway\runway_main_ep1.p3d","ca\roads_e\runway\runway_main_40_ep1.p3d"];
		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + ["ca\roads_e\runway\runway_main_ep1.p3d","ca\roads_e\runway\runway_main_40_ep1.p3d"];
		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];
		ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];
		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];
		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housec\house_c_5_v1_ep1.p3d","ca\structures_e\housec\house_c_5_v2_ep1.p3d","ca\structures_e\housel\house_l_3_ruins_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures\shed_ind\shed_ind02.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d","ca\structures_e\misc\shed_m01_ep1.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d","ca\structures_e\housec\house_c_3_ep1.p3d","ca\structures_e\housel\house_l_7_ruins_ep1.p3d","ca\structures_e\housel\house_l_8_ruins_ep1.p3d","ca\structures_e\housek\house_k_1_ruins_ep1.p3d","ca\structures_e\housec\house_c_12_ruins_ep1.p3d","ca\structures_e\housec\house_c_4_ruins_ep1.p3d","ca\structures_e\housek\house_k_6_ruins_ep1.p3d","ca\structures_e\housek\house_k_5_ruins_ep1.p3d","ca\structures_e\housec\house_c_2_ruins_ep1.p3d","ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housec\house_c_5_v3_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d"];
		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d"];
		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housec\house_c_5_v1_ep1.p3d","ca\structures_e\housec\house_c_5_v2_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_3_ep1.p3d","ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housec\house_c_5_v3_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d"];
		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [];
		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];
		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];
		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + ["ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_end_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_switch_ep1.p3d"];
		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d"];
		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["ca\structures_e\misc\misc_construction\misc_concbox_ep1.p3d","ca\structures_e\misc\misc_construction\misc_concoutlet_ep1.p3d"];
	};

	// FSF - Al Rayak (pja310)
	if(_worldName == "pja310") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "fortified",
			"budova",
			"mil_guardhouse"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "fortified"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "ss_hangar",
	        "hangar_2",
	        "hangar"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [

	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [

	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
			"army_hut",
	        "watchtower",
			"mil_guardhouse",
	        "fortified"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
			"misc_powerline",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "illuminanttower",
	        "vysilac_fm",
	        "telek"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
			"lighthouse",
			"nav_boathouse",
			"nav_pier",
	        "wtower",
	        "najezd",
	        "cargo"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "a_stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_mlyn_01",
	        "ind_pec_",
	        "wip",
	        "sawmillpen",
	        "workshop",
			"ind_coltan_mine",
			"a_buildingwip"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "dum_",
	        "shed",
	        "hut",
	        "house",
			"a_castle_",
			"kasna",
			"majak",
			"repair_center",
			"statek",
			"garage",
			"a_mosque",
			"a_minaret",
			"a_villa",
			"generalstore",
			"barn_"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Reshmaan
	if(_worldName == "reshmaan") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "watchtower",
	        "fortified"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower",
	        "fortified"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "hangar",
	        "runway_beton",
	        "runway_end",
	        "runway_main"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	        "heli_h_army",
	        "heli_h_rescue"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "vez",
	        "fortified"
	    ];

	   ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	       "a_office01",
	       "a_office02"
	   ];

	   ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	       "pec_",
	       "powerstation",
	       "trafostanica"
	   ];

	   ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	       "vysilac_fm"
	   ];

	   ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	       "crane",
	       "cargo"
	   ];

	   ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	       "stationhouse"
	   ];

	   ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	       "fuelstation"
	   ];

	   ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	       "wip",
	       "ind_coltan_mine"
	   ];

	   ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	       "hospital",
	       "dum",
	       "shed",
	       "house"
	   ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// MCN Aliabad
	if(_worldName == "MCN_Aliabad") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "misc_powerline"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "ind_coltan_mine"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Bystrica
	if(_worldName == "woodland_acr") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "mil"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "mil"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	        "pec_",
	        "powerstation",
	        "trafostanica"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "vysilac_fm",
	        "telek"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane",
	        "nav_pier",
	        "pier_",
	        "pier"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "rail_house",
	        "rail_station",
	        "rail_platform",
	        "rails_bridge",
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "expedice",
	        "indpipe",
	        "komin",
	        "ind_stack_big",
	        "ind_tankbig",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "hospital",
	        "houseblock",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Bukovina
	if(_worldName == "bootcamp_acr") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	        "mil"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	        "mil"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	        "barrack",
	        "mil_house",
	        "mil_controltower"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	        "hangar"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	        "deerstand"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	        "a_office01",
	        "a_office02"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	        "vysilac_fm"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	        "crane"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
	        "stationhouse"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	        "fuelstation",
	        "komin",
	        "fuel_tank_big"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	        "workshop"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
	        "houseblock",
	        "generalstore",
	        "house"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;

	};

	// Australia down under shrimps on the barbie mate - not Austria!
	if(tolower(_worldName) == "australia") then {
		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d","a3\structures_f\mil\offices\miloffices_v1_f.p3d","ca\buildings\hangar_2.p3d","ca\buildings\army_hut2_int.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","ca\buildings\hlidac_budka.p3d","mm_bank\commonwealthbank.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","mm_buildings\prison\gaol_main.p3d","mm_buildings\prison\mapobject\gaol_tower.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","ca\buildings\budova4_in.p3d","ca\buildings\army_hut3_long.p3d","ca\buildings\army_hut_int.p3d","ca\buildings\army_hut3_long_int.p3d","ca\buildings\hlaska.p3d","ca\buildings\tents\fortress_01.p3d","ca\buildings\army_hut_storrage.p3d","mm_buildings\prison\proxy\mainsection.p3d","ca\buildings\garaz_bez_tanku.p3d","ca\buildings\garaz_s_tankem.p3d","ca\buildings\budova2.p3d","ca\buildings\army_hut2.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","ca\buildings\ammostore2.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","ca\misc_e\guardshed_ep1.p3d","ausextras\objects\ausbunker.p3d","a3\structures_f\research\dome_big_f.p3d","ca\misc3\fortified_nest_small.p3d","ca\buildings\budova1.p3d","ca\misc2\barrack2\barrack2.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d","a3\structures_f\mil\cargo\medevac_house_v1_f.p3d"];
		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","ca\buildings\budova4_in.p3d","ca\buildings\army_hut3_long.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d"];
		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","mm_bank\commonwealthbank.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","ca\buildings\budova4_in.p3d","mm_buildings\prison\proxy\mainsection.p3d","ca\buildings\garaz_bez_tanku.p3d","ca\buildings\garaz_s_tankem.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","a3\structures_f\research\dome_big_f.p3d"];
		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","mm_bank\commonwealthbank.p3d","mm_buildings2\police_station\policestation.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","mm_buildings\prison\proxy\mainsection.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","ca\misc2\barrack2\barrack2.p3d"];
		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["ca\roads\runway_pojdraha.p3d","a3\roads_f\runway\runway_end02_f.p3d","a3\roads_f\runway\runway_main_f.p3d","a3\structures_f\ind\airport\hangar_f.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d","ca\roads\runway_end0.p3d","ca\roads\runway_poj_end9.p3d","ca\roads\runway_poj_tcross.p3d","ca\roads\runway_main.p3d","ca\roads\runway_end27.p3d","ca\roads\runway_poj_end27.p3d","ca\roads2\runway_end33.p3d","ca\roads\runway_dirt.p3d","ca\buildings\letistni_hala.p3d","ca\roads\runway_end9.p3d","ca\misc\heli_h_civil.p3d"];
		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + ["a3\structures_f\ind\airport\airport_left_f.p3d","a3\structures_f\ind\airport\airport_right_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","ca\misc\heli_h_civil.p3d"];
		ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["ca\misc\heli_h_army.p3d","mm_buildings\prison\mapobject\helipad\helipad.p3d","ca\misc\heli_h_rescue.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d","a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"];
		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["ca\misc\heli_h_army.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d","a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"];
		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + ["ca\misc\heli_h_rescue.p3d"];
		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","ca\buildings\hangar_2.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","ca\buildings\hut_old02.p3d","a3\structures_f\households\slum\cargo_house_slum_f.p3d","e76_buildings\shops\e76_shop_multi1.p3d","mm_buildings3\pub_c\pub_c.p3d","mm_post\build2\postb.p3d","mm_bank\commonwealthbank.p3d","mm_residential\residential_a\houseb.p3d","mm_residential\residential_a\housea.p3d","mm_residential\residential_a\houseb1.p3d","ausextras\a_generalstore_01\iga_generalstore.p3d","ca\buildings\kulna.p3d","mm_residential\residential_a\housea1.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","mm_buildings3\pub_a\pub_a.p3d","a3\structures_f\dominants\hospital\hospital_side1_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\ind\carservice\carservice_f.p3d","a3\structures_f\households\slum\slum_house02_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","mm_residential2\housedoubleal2.p3d","a3\structures_f_epc\civ\kiosks\kiosk_gyros_f.p3d","a3\structures_f_epc\civ\kiosks\kiosk_redburger_f.p3d","ausextras\a_generalstore_01\iga_generalstore2.p3d","mm_residential\residential_a\house_l\housec1_l.p3d","mm_residential\residential_a\housec_r.p3d","a3\structures_f_epc\dominants\stadium\stadium_p3_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p2_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p9_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p4_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p1_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p5_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p8_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p6_f.p3d","a3\structures_f_epc\dominants\stadium\stadium_p7_f.p3d","mm_buildings4\centrelink.p3d","ca\buildings\dum_istan4.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","e76_buildings\shops\e76_shop_single1.p3d","ca\buildings\hotel.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d","mm_residential2\housedoubleal.p3d","ca\structures_e\housec\house_c_10_ep1.p3d","ca\misc\water_tank.p3d","ca\structures\furniture\cases\skrin_bar\skrin_bar.p3d","a3\structures_f_epc\civ\kiosks\kiosk_papers_f.p3d","ca\buildings\shop2.p3d","ca\buildings\shop3.p3d","ca\buildings\shop1.p3d","ca\buildings\shop1_double.p3d","ca\buildings\shop2_double.p3d","ca\buildings\shop4.p3d","ca\buildings\shop5_double.p3d","ca\buildings\dum_istan3_hromada2.p3d","a3\structures_f\dominants\church\church_01_v1_f.p3d","ca\buildings\hut04.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_gazebo_f.p3d","a3\structures_f_epc\civ\kiosks\kiosk_blueking_f.p3d","ca\structures\house\a_stationhouse\a_stationhouse.p3d","ca\structures\barn_w\barn_w_02.p3d","mm_residential\residential_a\house_l\housea1_l.p3d","ca\buildings\dum_istan4_big.p3d","ca\buildings\dum_mesto3_istan.p3d","ca\buildings\dum_istan4_big_inverse.p3d","ca\structures\house\housebt\houseb_tenement.p3d","ca\structures\a_municipaloffice\a_municipaloffice.p3d","ca\buildings\shop5.p3d","ca\buildings\dum_istan2_01.p3d","ca\buildings\dum_istan2b.p3d","ca\buildings\dum_istan4_inverse.p3d","ca\buildings\dum_istan4_detaily1.p3d","e76_buildings\tower\e76_tower7.p3d","ca\buildings\dum_istan2_03.p3d","ca\buildings\garaz.p3d","ca\buildings\dum_istan3_hromada.p3d","ca\buildings\dum_istan2_02.p3d","ca\buildings\dum_istan2_04a.p3d","ausextras\shops\shopelectricsdouble.p3d","ca\buildings\kostel2.p3d","ca\buildings\hotel_riviera1.p3d","ca\buildings\hotel_riviera2.p3d","ca\buildings\statek_kulna.p3d","ca\structures\house\housev\housev_1i4.p3d","ca\buildings\bouda2_vnitrek.p3d","ca\structures\house\a_office01\data\proxy\doorinterier.p3d","mm_residential\residential_a\house_l\houseb1_l.p3d","ca\buildings\budova3.p3d","plp_beachobjects\plp_bo_beachbar.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\buildings\hut02.p3d"];
		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","ca\buildings\hut_old02.p3d","mm_buildings3\pub_c\pub_c.p3d","mm_post\build2\postb.p3d","mm_bank\commonwealthbank.p3d","mm_residential\residential_a\houseb.p3d","mm_residential\residential_a\housea.p3d","mm_residential\residential_a\houseb1.p3d","mm_residential\residential_a\housea1.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","mm_residential2\housedoubleal2.p3d","mm_residential\residential_a\house_l\housec1_l.p3d","mm_residential\residential_a\housec_r.p3d","mm_buildings4\centrelink.p3d","ca\structures\house\a_office02\a_office02.p3d","ca\buildings\hotel.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","mm_residential2\housedoubleal.p3d","mm_apartment\a_office02c.p3d","ca\structures\barn_w\barn_w_02.p3d","mm_residential\residential_a\house_l\housea1_l.p3d","ca\structures\house\housebt\houseb_tenement.p3d","mm_residential\residential_a\house_l\houseb1_l.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\buildings\hut02.p3d"];
		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["a3\structures_f\households\slum\cargo_house_slum_f.p3d","mm_buildings3\pub_c\pub_c.p3d","mm_residential\residential_a\houseb.p3d","mm_residential\residential_a\housea.p3d","mm_residential\residential_a\houseb1.p3d","mm_residential\residential_a\housea1.p3d","mm_buildings3\pub_a\pub_a.p3d","a3\structures_f\households\slum\slum_house02_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","mm_residential2\housedoubleal2.p3d","mm_residential\residential_a\house_l\housec1_l.p3d","mm_residential\residential_a\housec_r.p3d","ca\buildings\hotel.p3d","mm_residential2\housedoubleal.p3d","mm_residential\residential_a\house_l\housea1_l.p3d","ca\structures\house\housebt\houseb_tenement.p3d","mm_residential\residential_a\house_l\houseb1_l.p3d","ca\structures_e\housec\house_c_4_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\buildings\hut02.p3d"];
		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d","a3\structures_f\ind\powerlines\highvoltagecolumn_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d","a3\structures_f\ind\powerlines\powerline_distributor_f.p3d","a3\structures_f\civ\lamps\lampsolar_f.p3d","a3\structures_f\items\electronics\portable_generator_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d","a3\structures_f\ind\transmitter_tower\tbox_f.p3d","a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d","ca\buildings\trafostanica_mala.p3d","a3\structures_f\ind\windpowerplant\wpp_turbine_v2_f.p3d","ca\buildings\misc\stozarvn_1.p3d","a3\structures_f\ind\powerlines\highvoltageend_f.p3d","ca\misc_e\powgen_big_ep1.p3d","a3\structures_f\ind\windpowerplant\wpp_turbine_v1_f.p3d","a3\structures_f\ind\windpowerplant\powergenerator_f.p3d","ca\misc_e\powgen_big.p3d","ca\misc2\samsite\powgen_big.p3d","a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d","a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d","ca\buildings\watertower1.p3d","ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d","a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d"];
		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + ["a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d","ca\buildings\vysilac_fm.p3d","dbe1\models_dbe1\vysilac\vysilac_budova.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d","ca\buildings\telek1.p3d","ca\structures\proxy_buildingparts\roof\antennabigroof\antenna_big_roof.p3d","ca\structures\a_tvtower\a_tvtower_mid.p3d","ca\structures\a_tvtower\a_tvtower_top.p3d","ca\structures\a_tvtower\a_tvtower_base.p3d","a3\structures_f\ind\transmitter_tower\communication_f.p3d","ca\structures_e\misc\com_tower_ep1.p3d","a3\structures_f\mil\radar\radar_f.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d","ca\buildings\vysilac_fm2.p3d","ca\misc_e\76n6_clamshell_ep1.p3d","a3\structures_f\mil\radar\radar_small_f.p3d"];
		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["ca\buildings\molo_krychle.p3d","a3\structures_f\naval\piers\pier_f.p3d","ca\buildings2\a_crane_02\a_crane_02b.p3d","ca\buildings2\a_crane_02\a_crane_02a.p3d","a3\structures_f\dominants\lighthouse\lighthouse_f.p3d","a3\structures_f\naval\piers\pier_wall_f.p3d","ca\buildings\molo_beton.p3d","ca\buildings\nabrezi.p3d","ca\buildings\nabrezi_najezd.p3d","ca\structures\nav_pier\nav_pier_f_17.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","ca\buildings\hut01.p3d","ca\structures\nav_pier\nav_pier_m_end.p3d","ca\structures\nav_pier\nav_pier_m_2.p3d","ca\structures\nav_boathouse\nav_boathouse_pierr.p3d","ca\structures\nav_boathouse\nav_boathouse_pierl.p3d","ca\structures\nav_boathouse\nav_boathouse.p3d","ca\structures\nav_pier\nav_pier_c.p3d","ca\structures\nav_pier\nav_pier_c2.p3d","ca\structures\nav_pier\nav_pier_c_90.p3d","ca\structures\nav_pier\nav_pier_m_1.p3d","a3\structures_f\naval\piers\pillar_pier_f.p3d","ca\structures\nav_pier\nav_pier_c_r.p3d","ca\structures\nav_pier\nav_pier_c_r30.p3d","ca\structures\nav_pier\nav_pier_c_l.p3d","ca\structures\nav_pier\nav_pier_c_big.p3d","ca\structures\nav_pier\nav_pier_c_t20.p3d"];
		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["ca\buildings\fuelstation_army.p3d","ca\misc\fuel_tank_small.p3d","a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d","a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d","ca\buildings2\ind_pipeline\indpipe2\indpipe2_smallbuild2_l.p3d","ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d","ca\structures_e\ind\ind_fuelstation\ind_fuelstation_feed_ep1.p3d","a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d","ca\structures_e\ind\ind_fuelstation\ind_fuelstation_build_ep1.p3d","ca\buildings2\ind_tank\ind_tanksmall.p3d","ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d","ca\buildings2\ind_tank\ind_tanksmall2.p3d","ca\buildings\fuelstation.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d"];
		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d","ca\structures\a_buildingwip\a_buildingwip.p3d","ca\buildings2\ind_workshop01\ind_workshop01_box.p3d","ca\buildings2\ind_workshop01\ind_workshop01_01.p3d","ca\buildings2\ind_workshop01\ind_workshop01_03.p3d","ca\buildings2\ind_workshop01\ind_workshop01_l.p3d","ca\buildings2\ind_workshop01\ind_workshop01_02.p3d","ca\buildings2\ind_workshop01\ind_workshop01_04.p3d","ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d","ca\structures\ind_sawmill\ind_sawmillpen.p3d","ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d","ca\buildings\komin.p3d","ca\structures_e\housea\a_buildingwip\a_buildingwip_ep1.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d","ca\structures\shed_ind\shed_ind02.p3d","a3\structures_f\households\wip\unfinished_building_01_f.p3d","a3\structures_f\households\addons\metal_shed_f.p3d","ca\structures\a_cranecon\a_cranecon.p3d","ca\buildings\repair_center.p3d","ca\misc3\toilet.p3d","mm_residential2\studs\studstage1.p3d","mm_residential2\studs\studstage3.p3d","ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d","ca\buildings2\ind_cementworks\ind_silomale\ind_silomale.p3d","ca\buildings2\barn_metal\barn_metal.p3d","a3\structures_f\ind\factory\factory_conv1_10_f.p3d","a3\structures_f\ind\factory\factory_conv1_main_f.p3d","a3\structures_f\ind\factory\factory_hopper_f.p3d","a3\structures_f\ind\factory\factory_main_f.p3d","a3\structures_f\ind\factory\factory_conv1_end_f.p3d","a3\structures_f\ind\factory\factory_conv2_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d","a3\structures_f\households\wip\unfinished_building_02_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","mm_civilengineering\crane\cranebase.p3d","mm_civilengineering\crane\cranemid.p3d","mm_civilengineering\crane\cranetop.p3d","mm_residential2\studs\studstage2.p3d","ca\buildings\budova2.p3d","ca\buildings\army_hut2.p3d","ca\structures\ind_sawmill\ind_sawmill.p3d","a3\structures_f\ind\concretemixingplant\cmp_hopper_f.p3d","ca\structures\ind_quarry\ind_hammermill.p3d","a3\structures_f\ind\shed\u_shed_ind_f.p3d","ausextras\objects\crane.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_end_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_rail_switch_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_main_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d","ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d"];
	};

	// MSKE
	if(_worldName == "mske") then {

	    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
	    	"ss_hangar",
			"hangar",
			"tenthangar"
	    ];

	    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
	    	"bunker",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
			"airport",
	        "fortified",
			"army"
	    ];

	    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
	    	"barracks",
	    	"cargo_hq_",
	    	"miloffices",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	        "fortified",
			"fuelstation_army"
	    ];

	    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
	    	"cargo_hq_",
	    	"miloffices"
	    ];

	    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
			"ss_hangar",
			"tenthangar"
	    ];

	    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
	    	"ss_hangar",
			"hangar_f",
	    	"runway_"
	    ];

	    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
	    	"helipads",
			"helipadcircle",
			"heli_h_army"
	    ];

	    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
	    	"helipads",
			"heli_h_civil",
			"heli_h_cross",
			"heli_h_rescue"
	    ];

	    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
	    	"airport_tower",
			"army_hut",
			"ammostore2",
			"bagfence",
	    	"radar",
	    	"cargo_house_v",
	    	"cargo_patrol_",
	    	"research",
	    	"mil_wall",
	    	"fortification",
	    	"razorwire",
	    	"dome",
	        "hbarrier",
			"bighbarrier",
	        "fortified",
	        "hlaska",
	        "posed",
			"shooting_range"
	    ];

	    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
			"budova",
			"shop",
	        "shop_",
	        "stone_",
			"pub",
			"residential",
			"housedoubleal",
			"market",
			"garaz",
			"letistni_hala",
			"hospital"
	    ];

	    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
	    	"offices",
			"a_office",
			"a_municipaloffice"
	    ];

	    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
	    	"dieselpowerplant",
			"wpp_",
	    	"spp_t",
			"pec_",
	        "trafostanica",
			"ind_coltan_mine",
			"ind_pipeline",
			"ind_pipes",
			"ind_powerstation"
	    ];

	    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
	    	"communication_f",
			"com_tower",
	    	"transmitter_tower",
	        "vysilac_fm",
	        "telek",
	        "tvtower"
	    ];

	    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
	    	"crane",
	    	"lighthouse",
	    	"piers",
			"molo_",
	    	"nav_pier",
			"sea_wall_",
			"najezd",
	        "cargo",
	        "nabrezi",
	        "podesta",
			"nav_boathouse"
	    ];

	    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
			"rail_najazdovarampa"
	    ];

	    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
	    	"fuelstation",
			"indpipe",
	    	"dp_bigtank",
	        "expedice",
	        "komin",
	        "fuel_tank_big",
			"ind_tank"
	    ];

	    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
	    	"wip",
			"ind_coltan_mine",
			"concretemixingplant",
			"factory",
			"torvana",
			"ind_workshop",
			"ind_quarry",
			"ind_sawmill",
			"ind_cementworks",
			"civilengineering",
			"vez"
	    ];

	    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
			"barrack",
			"barn",
			"bouda",
			"bozi",
			"budova",
			"carservice",
			"church",
			"commonwealthbank",
			"deutshe",
			"dum",
			"garaz",
			"generalstore",
			"ghosthotel",
			"hangar_2",
			"helfenburk",
			"hlidac_budka",
			"hospital",
			"hotel",
			"housedoubleal",
			"households",
			"house",
			"hut",
			"kasna",
			"kiosk",
			"kostel2",
			"kostelik",
			"kulna",
			"market",
			"panelak",
			"policestation",
			"postb",
			"prison",
			"pub",
			"repair_center",
			"residential_a",
			"shed",
			"shop",
			"shops",
			"stadium",
			"stanek",
			"statek",
			"watertower"
	    ];

	};

	//Kunar Region
	if(tolower(_worldName) == "kunar_region") then {
		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["ca\misc3\fort_watchtower.p3d","ca\misc\fort_razorwire.p3d","ca\misc3\camonetb_nato.p3d","ca\misc2\barrack2\barrack2.p3d","ca\misc3\antenna.p3d","ca\misc3\fort_bagfence_round.p3d","ca\misc2\guardshed.p3d","ca\misc3\fort_bagfence_long.p3d","ca\misc2\hbarrier5_round15.p3d","ca\misc3\fort_bagfence_corner.p3d","ca\misc3\tent2_west.p3d","ca\misc3\fort_rampart.p3d","ca\misc3\fortified_nest_big.p3d","ca\misc3\fortified_nest_small.p3d","ca\misc3\wf\wf_hesco_big_10x.p3d","ca\misc3\camonet_nato_var1.p3d","ca\structures_e\mil\mil_guardhouse_ep1.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d","ca\structures_e\mil\mil_repair_center_ep1.p3d","ca\structures_e\mil\mil_barracks_i_ep1.p3d","ca\structures_e\mil\mil_barracks_l_ep1.p3d","ca\misc3\fort_artillery_nest.p3d"];
		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["ca\misc2\barrack2\barrack2.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d","ca\structures_e\mil\mil_repair_center_ep1.p3d"];
		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["ca\misc2\barrack2\barrack2.p3d","ca\misc3\tent_west.p3d","ca\misc3\tent2_west.p3d","ca\structures_e\mil\mil_guardhouse_ep1.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d"];
		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["ca\misc2\barrack2\barrack2.p3d","ca\structures_e\mil\mil_barracks_ep1.p3d"];
		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [];
		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [];
		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [];
		ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + [];
		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [];
		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [];
		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d","ca\structures_e\misc\misc_market\kiosk_ep1.p3d","ca\structures_e\misc\misc_market\covering_hut_big_ep1.p3d","ca\structures_e\misc\shed_w02_ep1.p3d","ca\structures_e\misc\shed_m01_ep1.p3d","opxbuildings\hut6.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d","ca\structures_e\housec\house_c_1_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d","ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d"];
		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d"];
		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["ca\structures_e\housek\terrace_k_1_ep1.p3d","ca\structures_e\housek\house_k_7_ep1.p3d","ca\structures_e\housek\house_k_5_ep1.p3d","ca\structures_e\housek\house_k_1_ep1.p3d","ca\structures_e\housek\house_k_6_ep1.p3d","ca\structures_e\housek\house_k_3_ep1.p3d","ca\structures_e\housel\house_l_1_ep1.p3d","ca\structures_e\housel\house_l_6_ep1.p3d","ca\structures_e\housek\house_k_8_ep1.p3d","ca\structures_e\housel\house_l_7_ep1.p3d","ca\structures_e\housel\house_l_4_ep1.p3d","ca\structures_e\housel\house_l_3_ep1.p3d","ca\structures_e\housel\house_l_8_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_2_ep1.p3d","ca\structures_e\housel\house_l_9_ep1.p3d","ca\structures_e\housec\house_c_11_ep1.p3d","ca\structures_e\housec\house_c_5_ep1.p3d","ca\structures_e\housea\a_mosque_small\a_mosque_small_1_ep1.p3d","ca\structures_e\housea\a_minaret\a_minaret_ep1.p3d","ca\structures_e\housec\house_c_1_ep1.p3d","ca\structures_e\housec\house_c_1_v2_ep1.p3d"];
		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["ca\misc3\powergenerator\powergenerator.p3d"];
		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [];
		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [];
		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [];
		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["ca\misc\fuel_tank_small.p3d"];
		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["ca\structures_e\misc\misc_construction\misc_concbox_ep1.p3d","opxbuildings\ruin.p3d"];
	};
	
	//Kapaulio - index by psvialli
	if(tolower(_worldName) == "kapaulio") then {
		ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + ["a3\structures_f_epa\civ\constructions\portablelight_double_f.p3d","a3\structures_f\naval\piers\pier_small_f.p3d","a3\structures_f_epb\naval\fishing\fishinggear_01_f.p3d","a3\structures_f\walls\cncwall4_f.p3d","a3\structures_f_epa\items\medical\defibrillator_f.p3d","a3\structures_f_epa\items\medical\disinfectantspray_f.p3d","a3\structures_f_epa\items\tools\ducttape_f.p3d","a3\structures_f_bootcamp\items\food\foodcontainer_01_f.p3d","a3\structures_f_epa\items\medical\antibiotic_f.p3d","a3\structures_f_epa\items\medical\bandage_f.p3d","a3\roads_f\runway\runwaylights\flush_light_red_f.p3d","a3\structures_f\wrecks\wreck_hunter_f.p3d","a3\structures_f\mil\bagfence\bagfence_long_f.p3d","a3\structures_f_epb\naval\fishing\fishinggear_02_f.p3d","a3\structures_f\ind\wavepowerplant\wavepowerplant_f.p3d","a3\structures_f\ind\wavepowerplant\wavepowerplantbroken_f.p3d","jbad_misc\misc_market\jbad_crates.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_stairs_f.p3d","a3\structures_f\training\rampconcrete_f.p3d","a3\structures_f\training\rampconcretehigh_f.p3d","a3\structures_f\wrecks\wreck_ural_f.p3d","a3\structures_f\items\electronics\survivalradio_f.p3d","a3\structures_f\items\food\tacticalbacon_f.p3d","a3\structures_f_epa\mil\scrapyard\pallet_milboxes_f.p3d","a3\structures_f_epa\items\medical\vitaminbottle_f.p3d","a3\structures_f_epa\items\food\ricebox_f.p3d","a3\structures_f_epa\civ\camping\woodentable_large_f.p3d","a3\structures_f\walls\cncwall1_f.p3d","a3\structures_f_epa\mil\scrapyard\paperbox_open_full_f.p3d","a3\structures_f\items\food\bottleplastic_v1_f.p3d","a3\structures_f_epa\items\food\bottleplastic_v2_f.p3d","a3\structures_f_epa\items\tools\fireextinguisher_f.p3d","a3\structures_f\items\electronics\fmradio_f.p3d","a3\structures_f\civ\infoboards\mapboard_f.p3d","a3\structures_f_epa\mil\scrapyard\paperbox_closed_f.p3d","a3\structures_f_epa\items\food\canteen_f.p3d","a3\structures_f_epa\mil\scrapyard\paperbox_open_empty_f.p3d","a3\structures_f_epa\items\tools\metalwire_f.p3d","a3\structures_f_epb\civ\dead\grave_dirt_f.p3d","a3\structures_f_epa\civ\constructions\pallets_stack_f.p3d","a3\structures_f\research\dome_b_cargo_entrance_f.p3d","a3\structures_f\research\dome_b_person_entrance_f.p3d","a3\structures_f\civ\infoboards\billboard_f.p3d","a3\structures_f_epc\civ\accessories\bench_01_f.p3d","a3\structures_f_epa\civ\camping\woodentable_small_f.p3d","a3\structures_f_epa\items\tools\gascanister_f.p3d","a3\structures_f\items\tools\meter3m_f.p3d","a3\structures_f_epb\items\vessels\barrelsand_grey_f.p3d","a3\structures_f_epa\items\vessels\tincontainer_f.p3d","a3\structures_f_epa\items\food\bakedbeans_f.p3d","a3\structures_f_epa\items\medical\heatpack_f.p3d","a3\structures_f\walls\cncbarrier_stripes_f.p3d","a3\structures_f\walls\cncbarriermedium4_f.p3d","a3\structures_f\mil\flags\mast_f.p3d","a3\structures_f_epa\mil\scrapyard\scrap_mrap_01_f.p3d","a3\structures_f\wrecks\wreck_uaz_f.p3d","a3\structures_f\civ\lamps\lampsolar_f.p3d","a3\structures_f\ind\cargo\cargo40_color_v2_ruins_f.p3d","a3\structures_f\households\addons\metal_shed_ruins_f.p3d","a3\structures_f\mil\bagfence\bagfence_round_f.p3d","a3\structures_f\mil\bagfence\bagfence_short_f.p3d","a3\structures_f\items\tools\drillaku_f.p3d","a3\structures_f\items\electronics\extensioncord_f.p3d","a3\structures_f\civ\camping\sleeping_bag_blue_f.p3d","a3\structures_f\items\tools\hammer_f.p3d","a3\structures_f\items\tools\pliers_f.p3d","a3\structures_f\items\electronics\portable_generator_f.p3d","a3\structures_f_epa\items\medical\painkillers_f.p3d","a3\structures_f_epa\mil\scrapyard\scrapheap_2_f.p3d","a3\structures_f_epa\items\food\cerealsbox_f.p3d","a3\structures_f\items\vessels\canisterfuel_f.p3d","a3\structures_f\items\documents\map_f.p3d","a3\structures_f\items\electronics\portablelongrangeradio_f.p3d","a3\structures_f\walls\rampart_f.p3d","a3\structures_f\ind\windpowerplant\wpp_turbine_v2_f.p3d","a3\structures_f_epa\civ\constructions\portablelight_single_f.p3d","a3\structures_f\civ\market\marketshelter_f.p3d","a3\structures_f\walls\cncshelter_f.p3d","a3\structures_f\mil\fortification\hbarrier_3_f.p3d","a3\structures_f_epb\items\vessels\barrelempty_grey_f.p3d","a3\structures_f_epb\items\vessels\barrelwater_grey_f.p3d","a3\structures_f\items\tools\axe_f.p3d","a3\structures_f\civ\camping\sleeping_bag_f.p3d","a3\structures_f\items\food\can_v1_f.p3d","a3\structures_f\items\food\can_v2_f.p3d","a3\structures_f\items\tools\gloves_f.p3d","a3\structures_f\civ\camping\sleeping_bag_brown_f.p3d","a3\structures_f_epa\items\tools\shovel_f.p3d","a3\structures_f_epa\civ\camping\woodenlog_f.p3d","a3\structures_f_epa\items\tools\gascooker_f.p3d","a3\structures_f\items\vessels\barrelempty_f.p3d","a3\structures_f\wrecks\wreck_bmp2_f.p3d","a3\structures_f_epa\items\tools\butanetorch_f.p3d","a3\structures_f_epb\items\luggage\luggageheap_02_f.p3d","a3\structures_f_epb\items\luggage\luggageheap_04_f.p3d","a3\structures_f_epc\civ\camping\sunshade_04_f.p3d","a3\structures_f\walls\indfnc_corner_f.p3d","a3\structures_f\furniture\tabledesk_f.p3d","a3\structures_f_epb\furniture\shelveswooden_f.p3d","a3\structures_f\furniture\chairwood_f.p3d","a3\structures_f_epa\mil\scrapyard\scrapheap_1_f.p3d","a3\structures_f_epb\furniture\shelveswooden_khaki_f.p3d","a3\structures_f\items\tools\dustmask_f.p3d","a3\structures_f_epc\civ\accessories\tableplastic_01_f.p3d","a3\structures_f\civ\ancient\ancientpillar_damaged_f.p3d","a3\structures_f\items\vessels\barreltrash_f.p3d","rspn_assets\models\cover_bluntstone.p3d","a3\structures_f\wrecks\wreck_t72_turret_f.p3d","rspn_assets\models\cover_dirt_inset.p3d","rspn_assets\models\cover_grass_inset.p3d","a3\structures_f\mil\bagfence\bagfence_corner_f.p3d","a3\structures_f\mil\bagfence\bagfence_end_f.p3d","a3\structures_f\civ\accessories\water_source_f.p3d","a3\structures_f_epc\civ\camping\sunshade_01_f.p3d","a3\structures_f_epa\items\tools\butanecanister_f.p3d","a3\structures_f_epa\items\tools\canopener_f.p3d","a3\structures_f\walls\wired_fence_4md_f.p3d","a3\structures_f_epb\civ\graffiti\graffiti_03_f.p3d","a3\structures_f_epb\items\documents\poster_05_f.p3d","a3\structures_f\civ\camping\camping_light_off_f.p3d","a3\structures_f\civ\camping\pillow_old_f.p3d","a3\structures_f\civ\camping\sleeping_bag_blue_folded_f.p3d","a3\structures_f_epa\items\medical\waterpurificationtablets_f.p3d","a3\structures_f\civ\camping\ground_sheet_blue_f.p3d","a3\structures_f\civ\camping\ground_sheet_f.p3d","a3\structures_f\civ\camping\ground_sheet_opfor_f.p3d","a3\structures_f\civ\camping\pillow_camouflage_f.p3d","a3\structures_f\civ\camping\pillow_f.p3d","a3\structures_f\items\vessels\canisteroil_f.p3d","a3\structures_f\civ\camping\pillow_grey_f.p3d","a3\structures_f\civ\camping\sleeping_bag_brown_folded_f.p3d","a3\structures_f_epb\items\luggage\luggageheap_03_f.p3d","a3\structures_f\items\documents\map_unfolded_f.p3d","a3\structures_f\research\dome_small_plates_f.p3d"];
		ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + ["a3\structures_f\walls\ancient_wall_8m_f.p3d","a3\structures_f\walls\ancient_wall_4m_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","a3\structures_f\research\research_house_v1_f.p3d","jbad_misc\misc_com\jbad_com_tower.p3d","jbad_structures\mil\jbad_mil_controltower.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\bagbunker\bagbunker_tower_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d","a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\shelters\camonet_open_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\mil\cargo\medevac_house_v1_f.p3d","a3\structures_f_epc\items\electronics\device_disassembled_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d","a3\structures_f\mil\shelters\camonet_big_f.p3d","a3\structures_f\mil\radar\radar_small_f.p3d","a3\structures_f\mil\shelters\camonet_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d","a3\structures_f\mil\cargo\cargo_house_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","rspn_assets\models\cb_long.p3d","rspn_assets\models\cb_entrance02.p3d","rspn_assets\models\cb_h45.p3d","rspn_assets\models\cb_h90.p3d","rspn_assets\models\cb_intersect02.p3d","god_various\hut\hlidac_budka.p3d","rspn_assets\models\cb_intersect01.p3d","rspn_assets\models\cb_end01.p3d","a3\structures_f\mil\radar\radar_f.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f_epc\items\electronics\device_assembled_f.p3d","a3\structures_f\training\target_popup_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\mil\fortification\hbarriertower_f.p3d","jbad_structures\mil\hanger\jbad_hanger_withdoor.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_1.p3d","a3\structures_f\mil\bunker\bunker_f.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_3.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_4.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_2.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no2_f.p3d","a3\structures_f\training\shoot_house_tunnel_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","a3\structures_f\dominants\castle\castle_01_wall_11_f.p3d","a3\structures_f\dominants\castle\castle_01_tower_f.p3d","a3\structures_f\dominants\castle\castle_01_church_b_ruin_f.p3d","a3\structures_f\dominants\castle\castle_01_church_ruin_f.p3d","a3\structures_f\dominants\castle\castle_01_church_a_ruin_f.p3d","a3\structures_f\dominants\castle\castle_01_wall_08_f.p3d","a3\structures_f\dominants\castle\castle_01_house_ruin_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d","mbg\mbg_killhouses_a3\m\mbg_warehouse.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_ruins_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d","rspn_assets\models\cb_entrance01.p3d","a3\structures_f\ind\airport\hangar_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d","mbg\mbg_killhouses_a3\m\mbg_killhouse_5.p3d","mbg\mbg_killhouses_a3\m\mbg_shoothouse_1.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_right_proxy_f.p3d","a3\structures_f\ind\airport\airport_right_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","a3\structures_f\mil\cargo\cargo_house_v2_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f_epc\dominants\stadium\stadium_p9_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no5_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no4_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no3_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_dam_f.p3d","a3\structures_f\civ\camping\tentdome_f.p3d","a3\structures_f\civ\camping\tenta_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d","a3\structures_f\ind\cargo\cargo20_blue_f.p3d","a3\structures_f\ind\cargo\cargo20_military_green_f.p3d","a3\structures_f\ind\cargo\cargo20_brick_red_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d","a3\structures_f\ind\cargo\cargo40_light_green_f.p3d","a3\structures_f\ind\cargo\cargo40_military_green_f.p3d"];
		ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","a3\structures_f\mil\cargo\cargo_house_v1_f.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\bagbunker\bagbunker_tower_f.p3d","a3\structures_f\mil\shelters\camonet_open_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\shelters\camonet_big_f.p3d","a3\structures_f\mil\shelters\camonet_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","a3\structures_f\research\research_hq_f.p3d","jbad_structures\mil\hanger\jbad_hanger_withdoor.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no2_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","a3\structures_f\dominants\castle\castle_01_tower_f.p3d","a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d"];
		ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\shelters\camonet_open_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\shelters\camonet_big_f.p3d","a3\structures_f\mil\shelters\camonet_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","rspn_assets\models\cb_intersect02.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","a3\structures_f\dominants\castle\castle_01_tower_f.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d","rspn_assets\models\cb_entrance01.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d"];
		ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + ["a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v1_f.p3d","jbad_structures\mil\jbad_mil_guardhouse.p3d","jbad_structures\mil\jbad_mil_barracks.p3d","a3\structures_f\mil\offices\miloffices_v1_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_f.p3d","a3\structures_f\research\dome_big_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d","a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","a3\structures_f\research\research_hq_f.p3d","a3\structures_f\research\dome_small_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no2_f.p3d","a3\structures_f\mil\barracks\u_barracks_v2_f.p3d","mbg\mbg_killhouses_a3\m\mbg_warehouse.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d","a3\structures_f\ind\airport\hangar_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no7_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no5_f.p3d","a3\structures_f\mil\cargo\cargo_tower_v1_no3_f.p3d","a3\structures_f\mil\barracks\i_barracks_v2_dam_f.p3d"];
		ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + ["a3\roads_f\runway\runway_right_secondary_end22_f.p3d","a3\roads_f\runway\runway_left_end22_f.p3d","a3\roads_f\runway\runway_left_secondary_end04_f.p3d","a3\roads_f\runway\runway_right_end04_f.p3d","a3\roads_f\runway\runway_end02_f.p3d","a3\roads_f\runway\runway_main_40_f.p3d"];
		ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + ["a3\structures_f\ind\airport\airport_tower_f.p3d","a3\structures_f\ind\airport\hangar_f.p3d"];
		ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + ["a3\structures_f\ind\airport\airport_left_f.p3d","a3\structures_f\ind\airport\airport_right_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d"];
		ALIVE_heliBuildingTypes = ALIVE_heliBuildingTypes + ["a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d","a3\structures_f\mil\helipads\jumptarget_f.p3d"];
		ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + ["a3\structures_f\mil\helipads\helipadsquare_f.p3d","a3\structures_f\mil\helipads\helipadcircle_f.p3d"];
		ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + ["a3\structures_f\mil\helipads\helipadrescue_f.p3d"];
		ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + ["a3\structures_f_epc\civ\tourism\touristshelter_01_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d","a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\slum\cargo_house_slum_f.p3d","a3\structures_f\households\slum\slum_house02_f.p3d","a3\structures_f\ind\windmill\i_windmill01_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d","a3\structures_f\households\addons\i_garage_v2_f.p3d","a3\structures_f\households\addons\metal_shed_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_dam_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v3_dam_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d","a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d","a3\structures_f\ind\windmill\d_windmill01_f.p3d","a3\structures_f\civ\chapels\chapel_v1_f.p3d","a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d","a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d","a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d","a3\structures_f\households\house_small01\d_house_small_01_v1_f.p3d","a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d","a3\structures_f\households\addons\i_addon_02_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d","a3\structures_f\households\addons\i_garage_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v2_dam_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d","a3\structures_f\households\wip\unfinished_building_02_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d","a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d","a3\structures_f\households\wip\unfinished_building_01_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_11.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d","a3\structures_f\dominants\amphitheater\amphitheater_f.p3d","a3\structures_f\civ\chapels\chapel_small_v1_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d","a3\structures_f\households\slum\slum_house03_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d","a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d","a3\structures_f\households\slum\cargo_addon02_v1_f.p3d","a3\structures_f\households\slum\cargo_addon02_v2_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d","a3\structures_f\households\stone_shed\stone_shed_v1_ruins_f.p3d","a3\structures_f\households\addons\addon_04_v1_ruins_f.p3d","a3\structures_f\households\addons\addon_01_v1_ruins_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d","a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d","a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v2_dam_f.p3d","god_various\hut\barn_w_02.p3d","a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d","a3\structures_f\households\house_small02\u_house_small_02_v1_dam_f.p3d","a3\structures_f\households\stone_shed\d_stone_shed_v1_f.p3d","a3\structures_f\households\slum\slum_house03_ruins_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d","a3\structures_f\civ\chapels\chapel_small_v2_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_1_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_2_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_2.p3d","jbad_structures\afghan_houses_c\jbad_house_c_12.p3d","jbad_structures\afghan_houses_c\jbad_house_c_3.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","jbad_structures\afghan_houses_c\jbad_house_c_10.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1.p3d","a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_dam_f.p3d","a3\structures_f\households\house_big02\u_house_big_02_v1_dam_f.p3d","a3\structures_f\households\house_big01\u_house_big_01_v1_dam_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v1_dam_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","jbad_structures\afghan_houses\jbad_house5.p3d","jbad_structures\afghan_houses\jbad_house3.p3d","jbad_structures\afghan_houses\jbad_house6.p3d","jbad_structures\afghan_houses\jbad_terrace.p3d","jbad_structures\afghan_houses\jbad_house8.p3d","jbad_structures\afghan_houses\jbad_house_1.p3d","a3\structures_f\households\house_shop02\d_shop_02_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_dam_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_dam_f.p3d","a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d","jbad_structures\afghan_houses_old\jbad_house_6_old.p3d","jbad_structures\afghan_houses\jbad_house7.p3d","jbad_structures\afghan_houses_c\jbad_house_c_4.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5.p3d","jbad_structures\afghan_houses_c\jbad_house_c_9.p3d","jbad_structures\afghan_houses\jbad_house2_basehide.p3d","jbad_structures\afghan_houses_old\jbad_house_3_old.p3d","jbad_structures\afghan_houses_old\jbad_house_8_old.p3d","jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon01.p3d","jbad_structures\afghan_houses_c\damageproxies\jbad_house_c_5_addon02.p3d","a3\structures_f\households\house_shop01\i_shop_01_v2_dam_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5_v3.p3d","jbad_structures\generalstore\jbad_a_generalstore_01.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\households\house_small01\i_house_small_01_v2_dam_f.p3d","a3\structures_f\civ\chapels\chapel_v2_f.p3d","a3\structures_f\dominants\church\church_01_v1_f.p3d","a3\structures_f\households\house_small01\u_house_small_01_v1_dam_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v1_dam_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d","jbad_structures\afghan_houses_old\jbad_house_1_old.p3d","jbad_structures\afghan_houses_old\jbad_house_4_old.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\generalstore\jbad_a_generalstore_01a.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\households\house_shop02\i_shop_02_v3_dam_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_dam_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v3_dam_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v2_dam_f.p3d","a3\structures_f\households\house_shop01\u_shop_01_v1_dam_f.p3d","jbad_structures\afghan_houses_old\jbad_house_7_old.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5_v1.p3d","jbad_structures\walls\wall_l\jbad_wall_l1_5m.p3d","a3\structures_f\walls\city2_8md_f"];
		ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + ["a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d","a3\structures_f\ind\windmill\d_windmill01_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d","a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","a3\structures_f\dominants\wip\wip_f.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\generalstore\jbad_a_generalstore_01a.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_dam_f.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","god_various\hut\barn_w_01.p3d"];
		ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + ["a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d","a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d","a3\structures_f\households\slum\slum_house01_f.p3d","a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d","a3\structures_f\civ\offices\offices_01_v1_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_f.p3d","a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d","a3\structures_f\households\house_small01\u_house_small_01_v1_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d","a3\structures_f\households\house_big01\i_house_big_01_v3_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d","a3\structures_f\households\wip\unfinished_building_02_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v1_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v3_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d","a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d","a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d","a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d","a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d","a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v3_dam_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_1_f.p3d","a3\structures_f_epc\dominants\ghosthotel\gh_house_2_f.p3d","a3\structures_f\dominants\hospital\hospital_main_proxy_f.p3d","a3\structures_f\dominants\hospital\hospital_main_f.p3d","a3\structures_f\dominants\hospital\hospital_side2_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_2.p3d","jbad_structures\afghan_houses_c\jbad_house_c_12.p3d","jbad_structures\afghan_houses_c\jbad_house_c_3.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d","a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_1.p3d","a3\structures_f\dominants\wip\wip_f.p3d","jbad_structures\afghan_houses\jbad_house5.p3d","jbad_structures\afghan_houses\jbad_house3.p3d","jbad_structures\afghan_houses\jbad_house8.p3d","jbad_structures\afghan_houses\jbad_house7.p3d","jbad_structures\afghan_houses_c\jbad_house_c_4.p3d","jbad_structures\afghan_houses_c\jbad_house_c_5.p3d","jbad_structures\afghan_houses_c\jbad_house_c_9.p3d","jbad_structures\afghan_houses\jbad_house2_basehide.p3d","jbad_structures\afghan_houses_old\jbad_house_8_old.p3d","jbad_structures\generalstore\jbad_a_generalstore_01.p3d","jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d","a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d","a3\structures_f\ind\airport\airport_center_f.p3d","a3\structures_f\ind\airport\airport_left_f.p3d","jbad_structures\generalstore\jbad_a_generalstore_01a.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d","a3\structures_f\households\house_shop02\i_shop_02_v1_dam_f.p3d","jbad_structures\afghan_houses_old\jbad_house_7_old.p3d","a3\structures_f\dominants\hospital\hospital_f.p3d","jbad_structures\afghan_houses_old\jbad_house_4_old.p3d","jbad_structures\afghan_houses\jbad_house6.p3d","a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d"];
		ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + ["a3\structures_f\ind\windpowerplant\wpp_turbine_v1_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d","a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d","a3\structures_f\ind\transmitter_tower\tbox_f.p3d","a3\structures_f\ind\windpowerplant\powergenerator_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d","a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_3_f.p3d","a3\structures_f\ind\solarpowerplant\spp_panel_f.p3d","a3\structures_f\ind\powerlines\powlines_transformer_f.p3d","jbad_structures\ind\ind_powerstation\jbad_ind_powerstation.p3d","a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d","a3\structures_f\ind\solarpowerplant\spp_mirror_f.p3d","a3\structures_f\ind\powerlines\highvoltagecolumn_f.p3d","a3\structures_f\ind\powerlines\highvoltagetower_f.p3d"];
		ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + ["a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d","jbad_misc\misc_com\jbad_com_tower.p3d","jbad_structures\mil\jbad_mil_controltower.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d","a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d","a3\structures_f\ind\transmitter_tower\ttowerbig_1_ruins_f.p3d","a3\structures_f\ind\transmitter_tower\communication_f.p3d","a3\structures_f\mil\radar\radar_f.p3d","a3\structures_f\ind\airport\airport_tower_f.p3d"];
		ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + ["a3\structures_f\naval\piers\pier_wall_f.p3d","a3\structures_f\naval\piers\pier_doubleside_f.p3d","a3\structures_f\dominants\lighthouse\lighthouse_f.p3d"];
		ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + ["jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail_end.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail.p3d","jbad_structures\ind\ind_coltan_mine\jbad_misc_tram.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_rail_switch.p3d"];
		ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + ["a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d","a3\structures_f\ind\tank\tank_rust_f.p3d","a3\structures_f\ind\carservice\carservice_f.p3d","a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d","a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d","a3\structures_f\ind\fuelstation_small\fs_feed_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtank_rust_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d","jbad_structures\ind\ind_garage01\jbad_ind_garage01.p3d","a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d","a3\structures_f\ind\fuelstation_small\fs_roof_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtank_v1_f.p3d"];
		ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + ["a3\structures_f\ind\windmill\i_windmill01_f.p3d","a3\structures_f\ind\shed\shed_big_f.p3d","a3\structures_f\ind\shed\u_shed_ind_f.p3d","a3\structures_f\ind\crane\crane_f.p3d","a3\structures_f\ind\shed\i_shed_ind_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_shed_f.p3d","a3\structures_f\households\wip\unfinished_building_01_f.p3d","jbad_structures\ind\hangar_2\jbad_hangar_2.p3d","a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_tower_f.p3d","a3\structures_f\ind\concretemixingplant\cmp_hopper_f.p3d","a3\structures_f\ind\factory\factory_tunnel_f.p3d","jbad_structures\afghan_houses_c\jbad_house_c_2.p3d","a3\structures_f\dominants\wip\wip_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d","a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_10.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_hopper.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_main.p3d","jbad_structures\ind\ind_shed\jbad_ind_shed_01.p3d","a3\structures_f\ind\factory\factory_conv1_main_f.p3d","a3\structures_f\ind\factory\factory_main_f.p3d","a3\structures_f\ind\factory\factory_conv2_f.p3d","a3\structures_f\ind\factory\factory_hopper_f.p3d","a3\structures_f\ind\factory\factory_conv1_10_f.p3d","a3\structures_f\ind\dieselpowerplant\dp_mainfactory_addon1_f.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv1_end.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_conv2.p3d","jbad_structures\ind\ind_coltan_mine\jbad_ind_coltan_tunnel.p3d","jbad_structures\afghan_house_a\a_buildingwip\jbad_a_buildingwip.p3d"];
		};
};
/*
 * Custom mappings for unit mods
 * Use these mappings to override difficult unit mod CfgGroup configs
 */


ALIVE_factionCustomMappings = [] call ALIVE_fnc_hashCreate;

// EXAMPLE BLU_F_G CUSTOM CONFIG MAPPING
// ---------------------------------------------------------------------------------------------------------------------
BLU_G_F_mappings = [] call ALIVE_fnc_hashCreate;
[BLU_G_F_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[BLU_G_F_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[BLU_G_F_mappings, "FactionName", "BLU_G_F"] call ALIVE_fnc_hashSet;
[BLU_G_F_mappings, "GroupFactionName", "Guerilla"] call ALIVE_fnc_hashSet;

BLU_G_F_typeMappings = [] call ALIVE_fnc_hashCreate;
[BLU_G_F_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[BLU_G_F_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[BLU_G_F_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[BLU_G_F_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[BLU_G_F_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[BLU_G_F_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[BLU_G_F_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[BLU_G_F_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[BLU_G_F_mappings, "GroupFactionTypes", BLU_G_F_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "BLU_G_F", BLU_G_F_mappings] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------


// African
// ---------------------------------------------------------------------------------------------------------------------
mas_afr_rebl_o_mappings = [] call ALIVE_fnc_hashCreate;
[mas_afr_rebl_o_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_mappings, "FactionName", "mas_afr_rebl_o"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_mappings, "GroupFactionName", "OPF_mas_afr_F_o"] call ALIVE_fnc_hashSet;

mas_afr_rebl_o_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_afr_rebl_o_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_typeMappings, "Infantry", "Infantry_mas_afr_o"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_typeMappings, "Motorized", "Motorized_mas_afr_o"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_typeMappings, "SpecOps", "Recon_mas_afr_o"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_o_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[mas_afr_rebl_o_mappings, "GroupFactionTypes", mas_afr_rebl_o_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_afr_rebl_o", mas_afr_rebl_o_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_afr_rebl_o", ["Box_mas_ru_rifle_Wps_F"]] call ALIVE_fnc_hashSet;


mas_afr_rebl_i_mappings = [] call ALIVE_fnc_hashCreate;
[mas_afr_rebl_i_mappings, "Side", "INDEP"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_mappings, "GroupSideName", "INDEP"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_mappings, "FactionName", "mas_afr_rebl_i"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_mappings, "GroupFactionName", "IND_mas_afr_F_i"] call ALIVE_fnc_hashSet;

mas_afr_rebl_i_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_afr_rebl_i_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_typeMappings, "Infantry", "Infantry_mas_afr_i"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_typeMappings, "Motorized", "Motorized_mas_afr_i"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_typeMappings, "SpecOps", "Recon_mas_afr_i"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_i_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[mas_afr_rebl_i_mappings, "GroupFactionTypes", mas_afr_rebl_i_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_afr_rebl_i", mas_afr_rebl_i_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_afr_rebl_i", ["Box_mas_us_rifle_Wps_F"]] call ALIVE_fnc_hashSet;


mas_afr_rebl_b_mappings = [] call ALIVE_fnc_hashCreate;
[mas_afr_rebl_b_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_mappings, "FactionName", "mas_afr_rebl_b"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_mappings, "GroupFactionName", "BLU_mas_afr_F_b"] call ALIVE_fnc_hashSet;

mas_afr_rebl_b_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_afr_rebl_b_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_typeMappings, "Infantry", "Infantry_mas_afr_b"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_typeMappings, "Motorized", "Motorized_mas_afr_b"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_typeMappings, "SpecOps", "Recon_mas_afr_b"] call ALIVE_fnc_hashSet;
[mas_afr_rebl_b_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[mas_afr_rebl_b_mappings, "GroupFactionTypes", mas_afr_rebl_b_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_afr_rebl_b", mas_afr_rebl_b_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_afr_rebl_b", ["Box_mas_us_rifle_Wps_F"]] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------


// uksf
// ---------------------------------------------------------------------------------------------------------------------
mas_ukf_sftg_mappings = [] call ALIVE_fnc_hashCreate;
[mas_ukf_sftg_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_mappings, "FactionName", "mas_ukf_sftg"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_mappings, "GroupFactionName", "BLU_mas_uk_sof_F"] call ALIVE_fnc_hashSet;

mas_ukf_sftg_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_ukf_sftg_typeMappings, "Air", "Infantry_mas_uk_d"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_typeMappings, "Armored", "Infantry_mas_uk_g"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_typeMappings, "Infantry", "Infantry_mas_uk"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_typeMappings, "Mechanized", "Infantry_mas_uk_w"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_typeMappings, "Motorized_MTP", "Motorized_mas_uk"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_typeMappings, "SpecOps", "Infantry_mas_uk_v"] call ALIVE_fnc_hashSet;
[mas_ukf_sftg_typeMappings, "Support", "Support_mas_uk"] call ALIVE_fnc_hashSet;

[mas_ukf_sftg_mappings, "GroupFactionTypes", mas_ukf_sftg_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_ukf_sftg", mas_ukf_sftg_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_ukf_sftg", ["Box_mas_us_rifle_Wps_F"]] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------


// ussf
// ---------------------------------------------------------------------------------------------------------------------
mas_usa_delta_mappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_delta_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_delta_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_delta_mappings, "FactionName", "mas_usa_delta"] call ALIVE_fnc_hashSet;
[mas_usa_delta_mappings, "GroupFactionName", "BLU_mas_usd_delta_F"] call ALIVE_fnc_hashSet;

mas_usa_delta_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_delta_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[mas_usa_delta_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[mas_usa_delta_typeMappings, "Infantry", "Infantry_mas_usd"] call ALIVE_fnc_hashSet;
[mas_usa_delta_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[mas_usa_delta_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[mas_usa_delta_typeMappings, "Motorized_MTP", "Infantry_mas_usd_g"] call ALIVE_fnc_hashSet;
[mas_usa_delta_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[mas_usa_delta_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[mas_usa_delta_mappings, "GroupFactionTypes", mas_usa_delta_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_usa_delta", mas_usa_delta_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_usa_delta", ["Box_mas_us_rifle_Wps_F"]] call ALIVE_fnc_hashSet;


mas_usa_devg_mappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_devg_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_devg_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_devg_mappings, "FactionName", "mas_usa_devg"] call ALIVE_fnc_hashSet;
[mas_usa_devg_mappings, "GroupFactionName", "BLU_mas_usn_seal_F"] call ALIVE_fnc_hashSet;

mas_usa_devg_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_devg_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[mas_usa_devg_typeMappings, "Armored", "Infantry_mas_usn_v"] call ALIVE_fnc_hashSet;
[mas_usa_devg_typeMappings, "Infantry", "Infantry_mas_usn"] call ALIVE_fnc_hashSet;
[mas_usa_devg_typeMappings, "Mechanized", "Infantry_mas_usn_d"] call ALIVE_fnc_hashSet;
[mas_usa_devg_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[mas_usa_devg_typeMappings, "Motorized_MTP", "Infantry_mas_usn_g"] call ALIVE_fnc_hashSet;
[mas_usa_devg_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[mas_usa_devg_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[mas_usa_devg_mappings, "GroupFactionTypes", mas_usa_devg_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_usa_devg", mas_usa_devg_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_usa_devg", ["Box_mas_us_rifle_Wps_F"]] call ALIVE_fnc_hashSet;


mas_usa_rang_mappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_rang_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_rang_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_rang_mappings, "FactionName", "mas_usa_rang"] call ALIVE_fnc_hashSet;
[mas_usa_rang_mappings, "GroupFactionName", "BLU_mas_usr_rang_F"] call ALIVE_fnc_hashSet;

mas_usa_rang_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_rang_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[mas_usa_rang_typeMappings, "Armored", "Infantry_mas_usr_v"] call ALIVE_fnc_hashSet;
[mas_usa_rang_typeMappings, "Infantry", "Infantry_mas_usr"] call ALIVE_fnc_hashSet;
[mas_usa_rang_typeMappings, "Mechanized", "Infantry_mas_usr_g"] call ALIVE_fnc_hashSet;
[mas_usa_rang_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[mas_usa_rang_typeMappings, "Motorized_MTP", "Infantry_mas_usr_d"] call ALIVE_fnc_hashSet;
[mas_usa_rang_typeMappings, "SpecOps", "Infantry_mas_usr_m"] call ALIVE_fnc_hashSet;
[mas_usa_rang_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[mas_usa_rang_mappings, "GroupFactionTypes", mas_usa_rang_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_usa_rang", mas_usa_rang_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_usa_rang", ["Box_mas_us_rifle_Wps_F"]] call ALIVE_fnc_hashSet;


mas_usa_usoc_mappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_usoc_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_mappings, "FactionName", "mas_usa_usoc"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_mappings, "GroupFactionName", "BLU_mas_usr_supp_F"] call ALIVE_fnc_hashSet;

mas_usa_usoc_typeMappings = [] call ALIVE_fnc_hashCreate;
[mas_usa_usoc_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_typeMappings, "Infantry", "Infantry_mas_usn_w"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_typeMappings, "Motorized_MTP", "Motorized_mas_usr"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[mas_usa_usoc_typeMappings, "Support", "Support_mas_usr"] call ALIVE_fnc_hashSet;

[mas_usa_usoc_mappings, "GroupFactionTypes", mas_usa_usoc_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "mas_usa_usoc", mas_usa_usoc_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "mas_usa_usoc", ["Box_mas_us_rifle_Wps_F"]] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------


// PMC POMI
// ---------------------------------------------------------------------------------------------------------------------
PMC_POMI_mappings = [] call ALIVE_fnc_hashCreate;
[PMC_POMI_mappings, "Side", "INDEP"] call ALIVE_fnc_hashSet;
[PMC_POMI_mappings, "GroupSideName", "INDEP"] call ALIVE_fnc_hashSet;
[PMC_POMI_mappings, "FactionName", "PMC_POMI"] call ALIVE_fnc_hashSet;
[PMC_POMI_mappings, "GroupFactionName", "PMC_POMI"] call ALIVE_fnc_hashSet;

PMC_POMI_typeMappings = [] call ALIVE_fnc_hashCreate;
[PMC_POMI_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[PMC_POMI_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[PMC_POMI_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[PMC_POMI_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[PMC_POMI_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[PMC_POMI_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[PMC_POMI_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[PMC_POMI_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[PMC_POMI_mappings, "GroupFactionTypes", PMC_POMI_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "PMC_POMI", PMC_POMI_mappings] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------


// SUD RU
// ---------------------------------------------------------------------------------------------------------------------
SUD_RU_mappings = [] call ALIVE_fnc_hashCreate;
[SUD_RU_mappings, "Side", "INDEP"] call ALIVE_fnc_hashSet;
[SUD_RU_mappings, "GroupSideName", "INDEP"] call ALIVE_fnc_hashSet;
[SUD_RU_mappings, "FactionName", "SUD_RU"] call ALIVE_fnc_hashSet;
[SUD_RU_mappings, "GroupFactionName", "SUD_RU"] call ALIVE_fnc_hashSet;

SUD_RU_typeMappings = [] call ALIVE_fnc_hashCreate;
[SUD_RU_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[SUD_RU_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[SUD_RU_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[SUD_RU_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[SUD_RU_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[SUD_RU_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[SUD_RU_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[SUD_RU_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[SUD_RU_mappings, "GroupFactionTypes", SUD_RU_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "SUD_RU", SUD_RU_mappings] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------


// SUD EVW
// ---------------------------------------------------------------------------------------------------------------------
[ALIVE_factionDefaultSupports, "SUD_NATO", ["SUD_HMMWV_M2","SUD_HMMWV","SUD_truck5t"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupports, "SUD_USSR", ["SUD_UAZ","SUD_Ural"]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultTransport, "SUD_NATO", ["SUD_truck5t"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SUD_USSR", ["SUD_Ural"]] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultAirTransport, "SUD_NATO", ["SUD_UH60"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "SUD_USSR", ["SUD_MI8"]] call ALIVE_fnc_hashSet;

// ---------------------------------------------------------------------------------------------------------------------


// CUP
// ---------------------------------------------------------------------------------------------------------------------

// CUP_B_USMC

CUP_B_USMC_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_USMC_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_mappings, "FactionName", "CUP_B_USMC"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_mappings, "GroupFactionName", "CUP_B_USMC"] call ALIVE_fnc_hashSet;

CUP_B_USMC_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_USMC_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_B_USMC_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_B_USMC_mappings, "GroupFactionTypes", CUP_B_USMC_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_B_USMC", CUP_B_USMC_mappings] call ALIVE_fnc_hashSet;


// CUP_B_US_Army

CUP_B_US_Army_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_US_Army_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_mappings, "FactionName", "CUP_B_US_Army"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_mappings, "GroupFactionName", "CUP_B_US_Army"] call ALIVE_fnc_hashSet;

CUP_B_US_Army_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_US_Army_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_B_US_Army_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_B_US_Army_mappings, "GroupFactionTypes", CUP_B_US_Army_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_B_US_Army", CUP_B_US_Army_mappings] call ALIVE_fnc_hashSet;


// CUP_B_CDF

CUP_B_CDF_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_CDF_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_mappings, "FactionName", "CUP_B_CDF"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_mappings, "GroupFactionName", "CUP_B_CDF"] call ALIVE_fnc_hashSet;

CUP_B_CDF_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_CDF_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_B_CDF_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_B_CDF_mappings, "GroupFactionTypes", CUP_B_CDF_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_B_CDF", CUP_B_CDF_mappings] call ALIVE_fnc_hashSet;


// CUP_O_RU

CUP_O_RU_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_RU_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_RU_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_RU_mappings, "FactionName", "CUP_O_RU"] call ALIVE_fnc_hashSet;
[CUP_O_RU_mappings, "GroupFactionName", "CUP_O_RU"] call ALIVE_fnc_hashSet;

CUP_O_RU_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_RU_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_O_RU_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_O_RU_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_O_RU_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_O_RU_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_O_RU_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_O_RU_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_O_RU_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_O_RU_mappings, "GroupFactionTypes", CUP_O_RU_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_O_RU", CUP_O_RU_mappings] call ALIVE_fnc_hashSet;


// CUP_O_ChDKZ

CUP_O_ChDKZ_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_ChDKZ_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_mappings, "FactionName", "CUP_O_ChDKZ"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_mappings, "GroupFactionName", "CUP_O_ChDKZ"] call ALIVE_fnc_hashSet;

CUP_O_ChDKZ_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_ChDKZ_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_O_ChDKZ_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_O_ChDKZ_mappings, "GroupFactionTypes", CUP_O_ChDKZ_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_O_ChDKZ", CUP_O_ChDKZ_mappings] call ALIVE_fnc_hashSet;


// CUP_I_NAPA

CUP_I_NAPA_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_NAPA_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_mappings, "FactionName", "CUP_I_NAPA"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_mappings, "GroupFactionName", "CUP_I_NAPA"] call ALIVE_fnc_hashSet;

CUP_I_NAPA_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_NAPA_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_I_NAPA_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_I_NAPA_mappings, "GroupFactionTypes", CUP_I_NAPA_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_I_NAPA", CUP_I_NAPA_mappings] call ALIVE_fnc_hashSet;


// CUP_O_TK

CUP_O_TK_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_TK_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_TK_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_TK_mappings, "FactionName", "CUP_O_TK"] call ALIVE_fnc_hashSet;
[CUP_O_TK_mappings, "GroupFactionName", "CUP_O_TK"] call ALIVE_fnc_hashSet;

CUP_O_TK_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_TK_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_O_TK_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_O_TK_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_O_TK_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_O_TK_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_O_TK_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_O_TK_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_O_TK_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_O_TK_mappings, "GroupFactionTypes", CUP_O_TK_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_O_TK", CUP_O_TK_mappings] call ALIVE_fnc_hashSet;


// CUP_O_TK_MILITIA

CUP_O_TK_MILITIA_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_TK_MILITIA_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_mappings, "FactionName", "CUP_O_TK_MILITIA"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_mappings, "GroupFactionName", "CUP_O_TK_MILITIA"] call ALIVE_fnc_hashSet;

CUP_O_TK_MILITIA_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_TK_MILITIA_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_O_TK_MILITIA_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_O_TK_MILITIA_mappings, "GroupFactionTypes", CUP_O_TK_MILITIA_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_O_TK_MILITIA", CUP_O_TK_MILITIA_mappings] call ALIVE_fnc_hashSet;


// CUP_B_US

CUP_B_US_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_US_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_US_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_US_mappings, "FactionName", "CUP_B_US"] call ALIVE_fnc_hashSet;
[CUP_B_US_mappings, "GroupFactionName", "CUP_B_US"] call ALIVE_fnc_hashSet;

CUP_B_US_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_US_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_B_US_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_B_US_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_B_US_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_B_US_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_B_US_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_B_US_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_B_US_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_B_US_mappings, "GroupFactionTypes", CUP_B_US_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_B_US", CUP_B_US_mappings] call ALIVE_fnc_hashSet;


// CUP_B_CZ

CUP_B_CZ_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_CZ_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_mappings, "FactionName", "CUP_B_CZ"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_mappings, "GroupFactionName", "CUP_B_CZ"] call ALIVE_fnc_hashSet;

CUP_B_CZ_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_CZ_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_B_CZ_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_B_CZ_mappings, "GroupFactionTypes", CUP_B_CZ_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_B_CZ", CUP_B_CZ_mappings] call ALIVE_fnc_hashSet;


// CUP_B_GER

CUP_B_GER_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_GER_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_GER_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_GER_mappings, "FactionName", "CUP_B_GER"] call ALIVE_fnc_hashSet;
[CUP_B_GER_mappings, "GroupFactionName", "CUP_B_GER"] call ALIVE_fnc_hashSet;

CUP_B_GER_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_GER_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_B_GER_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_B_GER_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_B_GER_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_B_GER_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_B_GER_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_B_GER_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_B_GER_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_B_GER_mappings, "GroupFactionTypes", CUP_B_GER_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_B_GER", CUP_B_GER_mappings] call ALIVE_fnc_hashSet;


// CUP_I_TK_GUE

CUP_I_TK_GUE_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_TK_GUE_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_mappings, "FactionName", "CUP_I_TK_GUE"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_mappings, "GroupFactionName", "CUP_I_TK_GUE"] call ALIVE_fnc_hashSet;

CUP_I_TK_GUE_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_TK_GUE_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_I_TK_GUE_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_I_TK_GUE_mappings, "GroupFactionTypes", CUP_I_TK_GUE_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_I_TK_GUE", CUP_I_TK_GUE_mappings] call ALIVE_fnc_hashSet;


// CUP_I_UN

CUP_I_UN_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_UN_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_UN_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_UN_mappings, "FactionName", "CUP_I_UN"] call ALIVE_fnc_hashSet;
[CUP_I_UN_mappings, "GroupFactionName", "CUP_I_UN"] call ALIVE_fnc_hashSet;

CUP_I_UN_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_UN_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_I_UN_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_I_UN_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_I_UN_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_I_UN_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_I_UN_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_I_UN_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_I_UN_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_I_UN_mappings, "GroupFactionTypes", CUP_I_UN_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_I_UN", CUP_I_UN_mappings] call ALIVE_fnc_hashSet;


// CUP_O_SLA

CUP_O_SLA_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_SLA_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_mappings, "FactionName", "CUP_I_SLA"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_mappings, "GroupFactionName", "CUP_I_SLA"] call ALIVE_fnc_hashSet;

CUP_O_SLA_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_O_SLA_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_O_SLA_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_O_SLA_mappings, "GroupFactionTypes", CUP_O_SLA_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_I_SLA", CUP_O_SLA_mappings] call ALIVE_fnc_hashSet;


// CUP_I_RACS

CUP_I_RACS_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_RACS_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_mappings, "FactionName", "CUP_I_RACS"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_mappings, "GroupFactionName", "CUP_I_RACS"] call ALIVE_fnc_hashSet;

CUP_I_RACS_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_RACS_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_I_RACS_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_I_RACS_mappings, "GroupFactionTypes", CUP_I_RACS_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_I_RACS", CUP_I_RACS_mappings] call ALIVE_fnc_hashSet;


// CUP_B_GB

CUP_B_GB_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_GB_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_GB_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[CUP_B_GB_mappings, "FactionName", "CUP_B_GB"] call ALIVE_fnc_hashSet;
[CUP_B_GB_mappings, "GroupFactionName", "CUP_B_GB"] call ALIVE_fnc_hashSet;

CUP_B_GB_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_B_GB_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_B_GB_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_B_GB_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_B_GB_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_B_GB_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_B_GB_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_B_GB_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_B_GB_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_B_GB_mappings, "GroupFactionTypes", CUP_B_GB_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_B_GB", CUP_B_GB_mappings] call ALIVE_fnc_hashSet;


// CUP_I_PMC_ION

CUP_I_PMC_ION_mappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_PMC_ION_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_mappings, "FactionName", "CUP_I_PMC_ION"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_mappings, "GroupFactionName", "CUP_I_PMC_ION"] call ALIVE_fnc_hashSet;

CUP_I_PMC_ION_typeMappings = [] call ALIVE_fnc_hashCreate;
[CUP_I_PMC_ION_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[CUP_I_PMC_ION_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[CUP_I_PMC_ION_mappings, "GroupFactionTypes", CUP_I_PMC_ION_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "CUP_I_PMC_ION", CUP_I_PMC_ION_mappings] call ALIVE_fnc_hashSet;



// Ryanzombies
// ---------------------------------------------------------------------------------------------------------------------

// Ryanzombiesfaction

Ryanzombiesfaction_mappings = [] call ALIVE_fnc_hashCreate;

Ryanzombiesfaction_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[Ryanzombiesfaction_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[Ryanzombiesfaction_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[Ryanzombiesfaction_mappings, "FactionName", "Ryanzombiesfaction"] call ALIVE_fnc_hashSet;
[Ryanzombiesfaction_mappings, "GroupFactionName", "Ryanzombiesfaction"] call ALIVE_fnc_hashSet;

Ryanzombiesfaction_typeMappings = [] call ALIVE_fnc_hashCreate;

[Ryanzombiesfaction_mappings, "GroupFactionTypes", Ryanzombiesfaction_typeMappings] call ALIVE_fnc_hashSet;

[Ryanzombiesfaction_factionCustomGroups, "Infantry", ["Ryanzombiesgroupfast1","Ryanzombiesgroupfast2","Ryanzombiesgroupmedium1","Ryanzombiesgroupmedium2","Ryanzombiesgroupslow1","Ryanzombiesgroupslow2","Ryanzombiesgroupdemon1","Ryanzombiesgroupspider1"]] call ALIVE_fnc_hashSet;

[Ryanzombiesfaction_mappings, "Groups", Ryanzombiesfaction_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "Ryanzombiesfaction", Ryanzombiesfaction_mappings] call ALIVE_fnc_hashSet;


// Ryanzombiesfactionopfor

Ryanzombiesfactionopfor_mappings = [] call ALIVE_fnc_hashCreate;

Ryanzombiesfactionopfor_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[Ryanzombiesfactionopfor_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[Ryanzombiesfactionopfor_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[Ryanzombiesfactionopfor_mappings, "FactionName", "Ryanzombiesfactionopfor"] call ALIVE_fnc_hashSet;
[Ryanzombiesfactionopfor_mappings, "GroupFactionName", "Ryanzombiesfactionopfor"] call ALIVE_fnc_hashSet;

Ryanzombiesfactionopfor_typeMappings = [] call ALIVE_fnc_hashCreate;

[Ryanzombiesfactionopfor_mappings, "GroupFactionTypes", Ryanzombiesfactionopfor_typeMappings] call ALIVE_fnc_hashSet;

[Ryanzombiesfactionopfor_factionCustomGroups, "Infantry", ["Ryanzombiesgroupspider1opfor","Ryanzombiesgroupdemon1opfor","Ryanzombiesgroupslow1opfor","Ryanzombiesgroupslow2opfor","Ryanzombiesgroupmedium1opfor","Ryanzombiesgroupmedium2opfor","Ryanzombiesgroupfast1opfor","Ryanzombiesgroupfast2opfor"]] call ALIVE_fnc_hashSet;

[Ryanzombiesfactionopfor_mappings, "Groups", Ryanzombiesfactionopfor_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "Ryanzombiesfactionopfor", Ryanzombiesfactionopfor_mappings] call ALIVE_fnc_hashSet;



// RHS
// ---------------------------------------------------------------------------------------------------------------------

ALIVE_RHSResupplyVehicleOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_RHSResupplyVehicleOptions, "PR_AIRDROP", [["<< Back","Car","Ship","RHS Car","RHS Truck"],["<< Back","Car","Ship","rhs_vehclass_car","rhs_vehclass_truck"]]] call ALIVE_fnc_hashSet;
[ALIVE_RHSResupplyVehicleOptions, "PR_HELI_INSERT", [["<< Back","Air","RHS Helicopter"],["<< Back","Air","rhs_vehclass_helicopter"]]] call ALIVE_fnc_hashSet;
[ALIVE_RHSResupplyVehicleOptions, "PR_STANDARD", [["<< Back","Car","Armored","Support","RHS Car","RHS Truck","RHS MRAP","RHS IFV","RHS APC","RHS Tank","RHS AA","RHS Artillery"],["<< Back","Car","Armored","Support","rhs_vehclass_car","rhs_vehclass_truck","rhs_vehclass_MRAP","rhs_vehclass_ifv","rhs_vehclass_apc","rhs_vehclass_tank","rhs_vehclass_aa","rhs_vehclass_artillery"]]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_usarmy_wd", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_usarmy_d", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_usmc_wd", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_usmc_d", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_usaf", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_usn", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_socom", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_msv", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_vdv", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_vmf", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_vv", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_tv", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_vpvo", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_vvs", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_vvs_c", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_rva", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhs_faction_insurgents", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;



ALIVE_RHSResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_RHSResupplyIndividualOptions, "PR_AIRDROP", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport","RHS Infantry"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport","rhs_vehclass_infantry"]]] call ALIVE_fnc_hashSet;
[ALIVE_RHSResupplyIndividualOptions, "PR_HELI_INSERT", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport","RHS Infantry"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport","rhs_vehclass_infantry"]]] call ALIVE_fnc_hashSet;
[ALIVE_RHSResupplyIndividualOptions, "PR_STANDARD", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport","RHS Infantry"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport","rhs_vehclass_infantry"]]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_usarmy_wd", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_usarmy_d", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_usmc_wd", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_usmc_d", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_usaf", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_usn", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_socom", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_msv", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_vdv", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_vmf", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_vv", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_tv", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_vpvo", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_vvs", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_vvs_c", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_rva", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhs_faction_insurgents", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;



ALIVE_RHSResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_RHSResupplyGroupOptions, "PR_AIRDROP", [
	"Armored",
	"Support",
	"rhs_group_nato_usarmy_wd_m1a1",
	"rhs_group_nato_usarmy_wd_M1A2",
	"rhs_group_nato_usarmy_wd_M109",
	"rhs_group_nato_usarmy_d_m1a1",
	"rhs_group_nato_usarmy_d_M1A2",
	"rhs_group_nato_usarmy_d_M109",
	"rhs_group_nato_usmc_d_m1a1",
	"rhs_group_nato_usmc_wd_m1a1",
	"rhs_group_rus_msv_bm21",
	"rhs_group_rus_vdv_mi8",
	"rhs_group_rus_vdv_mi24",
	"rhs_group_rus_vdv_bm21",
	"rhs_group_rus_tv_72",
	"rhs_group_rus_tv_80",
	"rhs_group_rus_tv_90",
	"rhs_group_rus_tv_2s3",
	"rhs_group_indp_ins_bm21",
	"rhs_group_indp_ins_72"
]] call ALIVE_fnc_hashSet;
[ALIVE_RHSResupplyGroupOptions, "PR_HELI_INSERT", [
	"Armored",
	"Mechanized",
	"Motorized",
	"Motorized_MTP",
	"SpecOps",
	"Support",
	"Motorized_MTP",
	"SpecOps",
	"Support",
	"rhs_group_nato_usarmy_wd_RG33",
	"rhs_group_nato_usarmy_wd_FMTV",
	"rhs_group_nato_usarmy_wd_HMMWV",
	"rhs_group_nato_usarmy_wd_M113",
	"rhs_group_nato_usarmy_wd_bradley",
	"rhs_group_nato_usarmy_wd_bradleyA3",
	"rhs_group_nato_usarmy_wd_m1a1",
	"rhs_group_nato_usarmy_wd_M1A2",
	"rhs_group_nato_usarmy_wd_M109",
	"rhs_group_nato_usarmy_d_RG33",
	"rhs_group_nato_usarmy_d_FMTV",
	"rhs_group_nato_usarmy_d_HMMWV",
	"rhs_group_nato_usarmy_d_M113",
	"rhs_group_nato_usarmy_d_bradley",
	"rhs_group_nato_usarmy_d_bradleyA3",
	"rhs_group_nato_usarmy_d_m1a1",
	"rhs_group_nato_usarmy_d_M1A2",
	"rhs_group_nato_usarmy_d_M109",
	"rhs_group_nato_usmc_wd_HMMWV",
	"rhs_group_nato_usmc_wd_RG33",
	"rhs_group_nato_usmc_wd_m1a1",
	"rhs_group_nato_usmc_d_RG33",
	"rhs_group_nato_usmc_d_HMMWV",
	"rhs_group_nato_usmc_d_m1a1",
	"rhs_group_rus_msv_Ural",
	"rhs_group_rus_msv_gaz66",
	"rhs_group_rus_msv_btr70",
	"rhs_group_rus_msv_BTR80",
	"rhs_group_rus_msv_BTR80a",
	"rhs_group_rus_msv_bmp1",
	"rhs_group_rus_msv_bmp2",
	"rhs_group_rus_MSV_BMP3",
	"rhs_group_rus_msv_bm21",
	"rhs_group_rus_vdv_Ural",
	"rhs_group_rus_vdv_gaz66",
	"rhs_group_rus_vdv_btr60",
	"rhs_group_rus_vdv_btr70",
	"rhs_group_rus_vdv_BTR80",
	"rhs_group_rus_vdv_BTR80a",
	"rhs_group_rus_vdv_bmp1",
	"rhs_group_rus_vdv_bmp2",
	"rhs_group_rus_vdv_bmd1",
	"rhs_group_rus_vdv_bmd2",
	"rhs_group_rus_vdv_bmd4",
	"rhs_group_rus_vdv_bmd4m",
	"rhs_group_rus_vdv_bmd4ma",
	"rhs_group_rus_vdv_2s25",
	"rhs_group_rus_vdv_mi8",
	"rhs_group_rus_vdv_mi24",
	"rhs_group_rus_vdv_bm21",
	"rhs_group_rus_tv_72",
	"rhs_group_rus_tv_80",
	"rhs_group_rus_tv_90",
	"rhs_group_rus_tv_2s3",
	"rhs_group_indp_ins_uaz",
	"rhs_group_indp_ins_ural",
	"rhs_group_indp_ins_btr60",
	"rhs_group_indp_ins_btr70",
	"rhs_group_indp_ins_bmp1",
	"rhs_group_indp_ins_bmp2",
	"rhs_group_indp_ins_bmd1",
	"rhs_group_indp_ins_bmd2",
	"rhs_group_indp_ins_bm21",
	"rhs_group_indp_ins_72"
]] call ALIVE_fnc_hashSet;
[ALIVE_RHSResupplyGroupOptions, "PR_STANDARD", ["Support"]] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_usarmy_wd", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_usarmy_d", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_usmc_wd", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_usmc_d", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_usaf", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_usn", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_socom", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_msv", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_vdv", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_tv", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_vmf", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_vv", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_vpvo", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_vvs", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_vvs_c", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_rva", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhs_faction_insurgents", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;



// RHS USAF ----------------------------------------------------------------------------------------------------------------

// rhs_faction_usarmy_wd

rhs_faction_usarmy_wd_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_usarmy_wd_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usarmy_wd_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings, "FactionName", "rhs_faction_usarmy_wd"] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings, "GroupFactionName", "rhs_faction_usarmy_wd"] call ALIVE_fnc_hashSet;

rhs_faction_usarmy_wd_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usarmy_wd_mappings, "GroupFactionTypes", rhs_faction_usarmy_wd_typeMappings] call ALIVE_fnc_hashSet;

[rhs_faction_usarmy_wd_factionCustomGroups, "Infantry", ["rhs_group_nato_usarmy_wd_infantry_squad","rhs_group_nato_usarmy_wd_infantry_weaponsquad","rhs_group_nato_usarmy_wd_infantry_squad_sniper","rhs_group_nato_usarmy_wd_infantry_team","rhs_group_nato_usarmy_wd_infantry_team_MG","rhs_group_nato_usarmy_wd_infantry_team_AA","rhs_group_nato_usarmy_wd_infantry_team_support","rhs_group_nato_usarmy_wd_infantry_team_heavy_AT"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups, "Motorized", ["rhs_group_nato_usarmy_wd_FMTV_1078_squad","rhs_group_nato_usarmy_wd_FMTV_1078_squad_2mg","rhs_group_nato_usarmy_wd_FMTV_1078_squad_sniper","rhs_group_nato_usarmy_wd_FMTV_1078_squad_mg_sniper","rhs_group_nato_usarmy_wd_FMTV_1083_squad","rhs_group_nato_usarmy_wd_FMTV_1083_squad_2mg","rhs_group_nato_usarmy_wd_FMTV_1083_squad_sniper","rhs_group_nato_usarmy_wd_FMTV_1083_squad_mg_sniper","rhs_group_nato_usarmy_wd_RG33_squad","rhs_group_nato_usarmy_wd_RG33_squad_2mg","rhs_group_nato_usarmy_wd_RG33_squad_sniper","rhs_group_nato_usarmy_wd_RG33_squad_mg_sniper","rhs_group_nato_usarmy_wd_RG33_m2_squad","rhs_group_nato_usarmy_wd_RG33_m2_squad_2mg","rhs_group_nato_usarmy_wd_RG33_m2_squad_sniper","rhs_group_nato_usarmy_wd_RG33_m2_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups, "Mechanized", ["rhs_group_nato_usarmy_wd_bradleyA3_squad","rhs_group_nato_usarmy_wd_bradleyA3_squad_2mg","rhs_group_nato_usarmy_wd_bradleyA3_squad_sniper","rhs_group_nato_usarmy_wd_bradleyA3_squad_mg_sniper","rhs_group_nato_usarmy_d_bradleyA3_aa","rhs_group_nato_usarmy_wd_bradley_squad","rhs_group_nato_usarmy_wd_bradley_squad_2mg","rhs_group_nato_usarmy_wd_bradley_squad_sniper","rhs_group_nato_usarmy_wd_bradley_squad_mg_sniper","rhs_group_nato_usarmy_d_bradley_aa","rhs_group_nato_usarmy_wd_M113_squad","rhs_group_nato_usarmy_wd_M113_squad_2mg","rhs_group_nato_usarmy_wd_M113_squad_sniper","rhs_group_nato_usarmy_wd_M113_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups, "Armored", ["RHS_M1A2SEP_wd_Platoon","RHS_M1A2SEP_wd_Platoon_AA","RHS_M1A2SEP_wd_Section","RHS_M1A2SEP_wd_TUSK_Platoon","RHS_M1A2SEP_wd_TUSK_Platoon_AA","RHS_M1A2SEP_wd_TUSK_Section","RHS_M1A2SEP_wd_TUSK2_Platoon","RHS_M1A2SEP_wd_TUSK2_Platoon_AA","RHS_M1A2SEP_wd_TUSK2_Section","RHS_M1A1AIM_wd_Platoon","RHS_M1A1AIM_wd_Platoon_AA","RHS_M1A1AIM_wd_Section","RHS_M1A1AIM_wd_TUSK_Platoon","RHS_M1A1AIM_wd_TUSK_Platoon_AA","RHS_M1A1AIM_wd_TUSK_Section"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups, "Artillery", ["RHS_M109_wd_Platoon","RHS_M109_wd_Section"]] call ALIVE_fnc_hashSet;

[rhs_faction_usarmy_wd_mappings, "Groups", rhs_faction_usarmy_wd_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_usarmy_wd", rhs_faction_usarmy_wd_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd","rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19","rhsusf_rg33_wd","rhsusf_rg33_m2_wd","rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19","rhsusf_m109_usarmy","RHS_M6_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["RHS_CH_47F","RHS_UH60M","RHS_UH60M_MEV","RHS_UH60M_MEV2"]] call ALIVE_fnc_hashSet;

/*
// rhs_vehclass_truck
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd","rhsusf_M978A2_usarmy_wd","rhsusf_M978A2_CPK_usarmy_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd","rhsusf_M978A2_usarmy_wd","rhsusf_M978A2_CPK_usarmy_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd","rhsusf_M978A2_usarmy_wd","rhsusf_M978A2_CPK_usarmy_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd","rhsusf_M978A2_usarmy_wd","rhsusf_M978A2_CPK_usarmy_wd"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_MRAP
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_rg33_wd","rhsusf_rg33_m2_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["rhsusf_rg33_wd","rhsusf_rg33_m2_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_rg33_wd","rhsusf_rg33_m2_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["rhsusf_rg33_wd","rhsusf_rg33_m2_wd"]] call ALIVE_fnc_hashSet;
// Static
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["RHS_Stinger_AA_pod_WD","RHS_M2StaticMG_WD","RHS_M2StaticMG_MiniTripod_WD","RHS_TOW_TriPod_WD","RHS_MK19_TriPod_WD"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["RHS_Stinger_AA_pod_WD","RHS_M2StaticMG_WD","RHS_M2StaticMG_MiniTripod_WD","RHS_TOW_TriPod_WD","RHS_MK19_TriPod_WD"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["RHS_Stinger_AA_pod_WD","RHS_M2StaticMG_WD","RHS_M2StaticMG_MiniTripod_WD","RHS_TOW_TriPod_WD","RHS_MK19_TriPod_WD"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["RHS_Stinger_AA_pod_WD","RHS_M2StaticMG_WD","RHS_M2StaticMG_MiniTripod_WD","RHS_TOW_TriPod_WD","RHS_MK19_TriPod_WD"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_artillery
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_m109_usarmy","RHS_M119_WD","RHS_M252_WD"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["rhsusf_m109_usarmy","RHS_M119_WD","RHS_M252_WD"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_m109_usarmy","RHS_M119_WD","RHS_M252_WD"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["rhsusf_m109_usarmy","RHS_M119_WD","RHS_M252_WD"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_apc
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_m113_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["rhsusf_m113_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_m113_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["rhsusf_m113_usarmy"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_tank
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_m1a1aimwd_usarmy","rhsusf_m1a1aim_tuski_wd","rhsusf_m1a2sep1wd_usarmy","rhsusf_m1a2sep1tuskiwd_usarmy","rhsusf_m1a2sep1tuskiiwd_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["rhsusf_m1a1aimwd_usarmy","rhsusf_m1a1aim_tuski_wd","rhsusf_m1a2sep1wd_usarmy","rhsusf_m1a2sep1tuskiwd_usarmy","rhsusf_m1a2sep1tuskiiwd_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_m1a1aimwd_usarmy","rhsusf_m1a1aim_tuski_wd","rhsusf_m1a2sep1wd_usarmy","rhsusf_m1a2sep1tuskiwd_usarmy","rhsusf_m1a2sep1tuskiiwd_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["rhsusf_m1a1aimwd_usarmy","rhsusf_m1a1aim_tuski_wd","rhsusf_m1a2sep1wd_usarmy","rhsusf_m1a2sep1tuskiwd_usarmy","rhsusf_m1a2sep1tuskiiwd_usarmy"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_helicopter
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["RHS_AH64D_wd","RHS_AH64D_wd_GS","RHS_AH64D_wd_CS","RHS_CH_47F","RHS_UH60M","RHS_UH60M_MEV","RHS_UH60M_MEV2"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["RHS_AH64D_wd","RHS_AH64D_wd_GS","RHS_AH64D_wd_CS","RHS_CH_47F","RHS_UH60M","RHS_UH60M_MEV","RHS_UH60M_MEV2"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["RHS_AH64D_wd","RHS_AH64D_wd_GS","RHS_AH64D_wd_CS","RHS_CH_47F","RHS_UH60M","RHS_UH60M_MEV","RHS_UH60M_MEV2"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["RHS_AH64D_wd","RHS_AH64D_wd_GS","RHS_AH64D_wd_CS","RHS_CH_47F","RHS_UH60M","RHS_UH60M_MEV","RHS_UH60M_MEV2"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["RHS_M2A3_BUSKIII_wd","RHS_M2A2_wd","RHS_M2A2_BUSKI_WD","RHS_M2A3_BUSKI_wd","RHS_M2A3_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["RHS_M2A3_BUSKIII_wd","RHS_M2A2_wd","RHS_M2A2_BUSKI_WD","RHS_M2A3_BUSKI_wd","RHS_M2A3_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["RHS_M2A3_BUSKIII_wd","RHS_M2A2_wd","RHS_M2A2_BUSKI_WD","RHS_M2A3_BUSKI_wd","RHS_M2A3_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["RHS_M2A3_BUSKIII_wd","RHS_M2A2_wd","RHS_M2A2_BUSKI_WD","RHS_M2A3_BUSKI_wd","RHS_M2A3_wd"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_aa
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["RHS_M6_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_wd", ["RHS_M6_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["RHS_M6_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["RHS_M6_wd"]] call ALIVE_fnc_hashSet;
*/


// rhs_faction_usarmy_d

rhs_faction_usarmy_d_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_usarmy_d_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usarmy_d_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings, "FactionName", "rhs_faction_usarmy_d"] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings, "GroupFactionName", "rhs_faction_usarmy_d"] call ALIVE_fnc_hashSet;

rhs_faction_usarmy_d_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usarmy_d_mappings, "GroupFactionTypes", rhs_faction_usarmy_d_typeMappings] call ALIVE_fnc_hashSet;

[rhs_faction_usarmy_d_factionCustomGroups, "Infantry", ["rhs_group_nato_usarmy_d_infantry_squad","rhs_group_nato_usarmy_d_infantry_weaponsquad","rhs_group_nato_usarmy_d_infantry_squad_sniper","rhs_group_nato_usarmy_d_infantry_team","rhs_group_nato_usarmy_d_infantry_team_MG","rhs_group_nato_usarmy_d_infantry_team_AA","rhs_group_nato_usarmy_d_infantry_team_AT","rhs_group_nato_usarmy_d_infantry_team_support"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups, "Motorized", ["rhs_group_nato_usarmy_d_FMTV_1078_squad","rhs_group_nato_usarmy_d_FMTV_1078_squad_2mg","rhs_group_nato_usarmy_d_FMTV_1078_squad_sniper","rhs_group_nato_usarmy_d_FMTV_1078_squad_mg_sniper","rhs_group_nato_usarmy_d_FMTV_1083_squad","rhs_group_nato_usarmy_d_FMTV_1083_squad_2mg","rhs_group_nato_usarmy_d_FMTV_1083_squad_sniper","rhs_group_nato_usarmy_d_FMTV_1083_squad_mg_sniper","rhs_group_nato_usarmy_d_RG33_squad","rhs_group_nato_usarmy_d_RG33_squad_2mg","rhs_group_nato_usarmy_d_RG33_squad_sniper","rhs_group_nato_usarmy_d_RG33_squad_mg_sniper","rhs_group_nato_usarmy_d_RG33_m2_squad","rhs_group_nato_usarmy_d_RG33_m2_squad_2mg","rhs_group_nato_usarmy_d_RG33_m2_squad_sniper","rhs_group_nato_usarmy_d_RG33_m2_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups, "Mechanized", ["rhs_group_nato_usarmy_d_bradleyA3_squad","rhs_group_nato_usarmy_d_bradleyA3_squad_2mg","rhs_group_nato_usarmy_d_bradleyA3_squad_sniper","rhs_group_nato_usarmy_d_bradleyA3_squad_mg_sniper","rhs_group_nato_usarmy_d_bradleyA3_aa","rhs_group_nato_usarmy_d_bradley_squad","rhs_group_nato_usarmy_d_bradley_squad_2mg","rhs_group_nato_usarmy_d_bradley_squad_sniper","rhs_group_nato_usarmy_d_bradley_squad_mg_sniper","rhs_group_nato_usarmy_d_bradley_aa","rhs_group_nato_usarmy_d_M113_squad","rhs_group_nato_usarmy_d_M113_squad_2mg","rhs_group_nato_usarmy_d_M113_squad_sniper","rhs_group_nato_usarmy_d_M113_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups, "Armored", ["RHS_M1A2SEP_Platoon","RHS_M1A2SEP_Platoon_AA","RHS_M1A2SEP_Section","RHS_M1A2SEP_TUSK_Platoon","RHS_M1A2SEP_TUSK_Platoon_AA","RHS_M1A2SEP_TUSK_Section","RHS_M1A2SEP_d_TUSK2_Platoon","RHS_M1A2SEP_d_TUSK2_Platoon_AA","RHS_M1A2SEP_d_TUSK2_Section","RHS_M1A1AIM_Platoon","RHS_M1A1AIM_Platoon_AA","RHS_M1A1AIM_Section","RHS_M1A1AIM_TUSK_Platoon","RHS_M1A1AIM_TUSK_Platoon_AA","RHS_M1A1AIM_TUSK_Section"]] call ALIVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups, "Artillery", ["RHS_M109_Platoon","RHS_M109_Section"]] call ALIVE_fnc_hashSet;

[rhs_faction_usarmy_d_mappings, "Groups", rhs_faction_usarmy_d_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_usarmy_d", rhs_faction_usarmy_d_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19","rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d","RHS_M6","rhsusf_m109d_usarmy","rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19","rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy","rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["RHS_CH_47F_light","RHS_UH60M_d","RHS_UH60M_MEV_d","RHS_UH60M_MEV2_d"]] call ALIVE_fnc_hashSet;

/*
// rhs_vehclass_truck
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_MRAP
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
// Static
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["RHS_Stinger_AA_pod_D","RHS_M2StaticMG_D","RHS_M2StaticMG_MiniTripod_D","RHS_TOW_TriPod_D","RHS_MK19_TriPod_D"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["RHS_Stinger_AA_pod_D","RHS_M2StaticMG_D","RHS_M2StaticMG_MiniTripod_D","RHS_TOW_TriPod_D","RHS_MK19_TriPod_D"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["RHS_Stinger_AA_pod_D","RHS_M2StaticMG_D","RHS_M2StaticMG_MiniTripod_D","RHS_TOW_TriPod_D","RHS_MK19_TriPod_D"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["RHS_Stinger_AA_pod_D","RHS_M2StaticMG_D","RHS_M2StaticMG_MiniTripod_D","RHS_TOW_TriPod_D","RHS_MK19_TriPod_D"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_artillery
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_m109d_usarmy","RHS_M119_D","RHS_M252_D"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["rhsusf_m109d_usarmy","RHS_M119_D","RHS_M252_D"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_m109d_usarmy","RHS_M119_D","RHS_M252_D"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["rhsusf_m109d_usarmy","RHS_M119_D","RHS_M252_D"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_apc
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_m113d_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["rhsusf_m113d_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_m113d_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["rhsusf_m113d_usarmy"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_tank
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_m1a1aimd_usarmy","rhsusf_m1a1aim_tuski_d","rhsusf_m1a2sep1d_usarmy","rhsusf_m1a2sep1tuskid_usarmy","rhsusf_m1a2sep1tuskiid_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["rhsusf_m1a1aimd_usarmy","rhsusf_m1a1aim_tuski_d","rhsusf_m1a2sep1d_usarmy","rhsusf_m1a2sep1tuskid_usarmy","rhsusf_m1a2sep1tuskiid_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_m1a1aimd_usarmy","rhsusf_m1a1aim_tuski_d","rhsusf_m1a2sep1d_usarmy","rhsusf_m1a2sep1tuskid_usarmy","rhsusf_m1a2sep1tuskiid_usarmy"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["rhsusf_m1a1aimd_usarmy","rhsusf_m1a1aim_tuski_d","rhsusf_m1a2sep1d_usarmy","rhsusf_m1a2sep1tuskid_usarmy","rhsusf_m1a2sep1tuskiid_usarmy"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_helicopter
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["RHS_AH64D","RHS_AH64D_GS","RHS_AH64D_CS","RHS_AH64DGrey","RHS_CH_47F_light","RHS_UH60M_d","RHS_UH60M_MEV_d","RHS_UH60M_MEV2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["RHS_AH64D","RHS_AH64D_GS","RHS_AH64D_CS","RHS_AH64DGrey","RHS_CH_47F_light","RHS_UH60M_d","RHS_UH60M_MEV_d","RHS_UH60M_MEV2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["RHS_AH64D","RHS_AH64D_GS","RHS_AH64D_CS","RHS_AH64DGrey","RHS_CH_47F_light","RHS_UH60M_d","RHS_UH60M_MEV_d","RHS_UH60M_MEV2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["RHS_AH64D","RHS_AH64D_GS","RHS_AH64D_CS","RHS_AH64DGrey","RHS_CH_47F_light","RHS_UH60M_d","RHS_UH60M_MEV_d","RHS_UH60M_MEV2_d"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["RHS_M2A2","RHS_M2A2_BUSKI","RHS_M2A3","RHS_M2A3_BUSKI","RHS_M2A3_BUSKIII"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["RHS_M2A2","RHS_M2A2_BUSKI","RHS_M2A3","RHS_M2A3_BUSKI","RHS_M2A3_BUSKIII"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["RHS_M2A2","RHS_M2A2_BUSKI","RHS_M2A3","RHS_M2A3_BUSKI","RHS_M2A3_BUSKIII"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["RHS_M2A2","RHS_M2A2_BUSKI","RHS_M2A3","RHS_M2A3_BUSKI","RHS_M2A3_BUSKIII"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_aa
[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["RHS_M6"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usarmy_d", ["RHS_M6"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["RHS_M6"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["RHS_M6"]] call ALIVE_fnc_hashSet;
*/


// rhs_faction_usmc_wd

rhs_faction_usmc_wd_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_usmc_wd_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usmc_wd_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings, "FactionName", "rhs_faction_usmc_wd"] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings, "GroupFactionName", "rhs_faction_usmc_wd"] call ALIVE_fnc_hashSet;

rhs_faction_usmc_wd_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usmc_wd_mappings, "GroupFactionTypes", rhs_faction_usmc_wd_typeMappings] call ALIVE_fnc_hashSet;

[rhs_faction_usmc_wd_factionCustomGroups, "Infantry", ["rhs_group_nato_usmc_wd_infantry_squad","rhs_group_nato_usmc_wd_infantry_weaponsquad","rhs_group_nato_usmc_wd_infantry_squad_sniper","rhs_group_nato_usmc_wd_infantry_team","rhs_group_nato_usmc_wd_infantry_team_MG","rhs_group_nato_usmc_wd_infantry_team_AA","rhs_group_nato_usmc_wd_infantry_team_support","rhs_group_nato_usmc_wd_infantry_team_heavy_AT"]] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups, "Motorized", ["rhs_group_nato_usmc_wd_RG33_squad","rhs_group_nato_usmc_wd_RG33_squad_2mg","rhs_group_nato_usmc_wd_RG33_squad_sniper","rhs_group_nato_usmc_wd_RG33_squad_mg_sniper","rhs_group_nato_usmc_wd_RG33_m2_squad","rhs_group_nato_usmc_wd_RG33_m2_squad_2mg","rhs_group_nato_usmc_wd_RG33_m2_squad_sniper","rhs_group_nato_usmc_wd_RG33_m2_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups, "Armored", ["RHS_M1A1AIM_wd_Platoon","RHS_M1A1FEP_wd_Section"]] call ALIVE_fnc_hashSet;

[rhs_faction_usmc_wd_mappings, "Groups", rhs_faction_usmc_wd_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_usmc_wd", rhs_faction_usmc_wd_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_usmc_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd","rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19","rhsusf_rg33_wd","rhsusf_rg33_m2_wd","rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19","rhsusf_m109_usarmy","RHS_M6_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd","rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_wd", ["RHS_CH_47F","rhsusf_CH53E_USMC","RHS_UH60M","RHS_UH60M_MEV","RHS_UH60M_MEV2"]] call ALIVE_fnc_hashSet;

/*
// rhs_vehclass_MRAP
[ALIVE_factionDefaultSupports, "rhs_faction_usmc_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usmc_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_usmc_wd", ["rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usmc_wd", ["rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_wd", ["rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_wd", ["rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_tank
[ALIVE_factionDefaultSupports, "rhs_faction_usmc_wd", ["rhsusf_m1a1fep_wd","rhsusf_m1a1fep_od"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usmc_wd", ["rhsusf_m1a1fep_wd","rhsusf_m1a1fep_od"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_wd", ["rhsusf_m1a1fep_wd","rhsusf_m1a1fep_od"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_wd", ["rhsusf_m1a1fep_wd","rhsusf_m1a1fep_od"]] call ALIVE_fnc_hashSet;
*/


// rhs_faction_usmc_d

rhs_faction_usmc_d_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_usmc_d_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usmc_d_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings, "FactionName", "rhs_faction_usmc_d"] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings, "GroupFactionName", "rhs_faction_usmc_d"] call ALIVE_fnc_hashSet;

rhs_faction_usmc_d_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_usmc_d_mappings, "GroupFactionTypes", rhs_faction_usmc_d_typeMappings] call ALIVE_fnc_hashSet;

[rhs_faction_usmc_d_factionCustomGroups, "Infantry", ["rhs_group_nato_usmc_d_infantry_squad","rhs_group_nato_usmc_d_infantry_weaponsquad","rhs_group_nato_usmc_d_infantry_squad_sniper","rhs_group_nato_usmc_d_infantry_team","rhs_group_nato_usmc_d_infantry_team_MG","rhs_group_nato_usmc_d_infantry_team_AA","rhs_group_nato_usmc_d_infantry_team_support","rhs_group_nato_usmc_d_infantry_team_heavy_AT"]] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups, "Motorized", ["rhs_group_nato_usmc_d_RG33_squad","rhs_group_nato_usmc_d_RG33_squad_2mg","rhs_group_nato_usmc_d_RG33_squad_sniper","rhs_group_nato_usmc_d_RG33_squad_mg_sniper","rhs_group_nato_usmc_d_RG33_m2_squad","rhs_group_nato_usmc_d_RG33_m2_squad_2mg","rhs_group_nato_usmc_d_RG33_m2_squad_sniper","rhs_group_nato_usmc_d_RG33_m2_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups, "Armored", ["RHS_M1A1AIM_d_Platoon","RHS_M1A1FEP_d_Section"]] call ALIVE_fnc_hashSet;

[rhs_faction_usmc_d_mappings, "Groups", rhs_faction_usmc_d_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_usmc_d", rhs_faction_usmc_d_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_usmc_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19","rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d","RHS_M6","rhsusf_m109d_usarmy","rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19","rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy","rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_d", ["RHS_CH_47F_light","rhsusf_CH53E_USMC_D","RHS_UH60M_d","RHS_UH60M_MEV_d","RHS_UH60M_MEV2_d"]] call ALIVE_fnc_hashSet;

/*
// rhs_vehclass_MRAP
[ALIVE_factionDefaultSupports, "rhs_faction_usmc_d", ["rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usmc_d", ["rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_d", ["rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_d", ["rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_usmc_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usmc_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_tank
[ALIVE_factionDefaultSupports, "rhs_faction_usmc_d", ["rhsusf_m1a1fep_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usmc_d", ["rhsusf_m1a1fep_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_d", ["rhsusf_m1a1fep_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_d", ["rhsusf_m1a1fep_d"]] call ALIVE_fnc_hashSet;
*/


/*
// rhs_faction_usaf
rhs_faction_usaf_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_usaf_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_usaf_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usaf_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usaf_mappings, "FactionName", "rhs_faction_usaf"] call ALIVE_fnc_hashSet;
[rhs_faction_usaf_mappings, "GroupFactionName", "rhs_faction_usaf"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_usaf_mappings, "GroupFactionTypes", rhs_faction_usaf_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_usaf_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_usaf_mappings, "Groups", rhs_faction_usaf_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_usaf", rhs_faction_usaf_mappings] call ALIVE_fnc_hashSet;
// rhs_vehclass_aircraft
[ALIVE_factionDefaultSupports, "rhs_faction_usaf", ["RHS_C130J","RHS_A10","rhsusf_f22"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_usaf", ["RHS_C130J","RHS_A10","rhsusf_f22"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usaf", ["RHS_C130J","RHS_A10","rhsusf_f22"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usaf", ["RHS_C130J","RHS_A10","rhsusf_f22"]] call ALIVE_fnc_hashSet;
// rhs_faction_usn
rhs_faction_usn_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_usn_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_usn_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usn_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_usn_mappings, "FactionName", "rhs_faction_usn"] call ALIVE_fnc_hashSet;
[rhs_faction_usn_mappings, "GroupFactionName", "rhs_faction_usn"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_usn_mappings, "GroupFactionTypes", rhs_faction_usn_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_usn_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_usn_mappings, "Groups", rhs_faction_usn_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_usn", rhs_faction_usn_mappings] call ALIVE_fnc_hashSet;
// rhs_faction_socom
rhs_faction_socom_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_socom_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_socom_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_socom_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhs_faction_socom_mappings, "FactionName", "rhs_faction_socom"] call ALIVE_fnc_hashSet;
[rhs_faction_socom_mappings, "GroupFactionName", "rhs_faction_socom"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_socom_mappings, "GroupFactionTypes", rhs_faction_socom_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_socom_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_socom_mappings, "Groups", rhs_faction_socom_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_socom", rhs_faction_socom_mappings] call ALIVE_fnc_hashSet;
*/

// ------------------------------------------------------------------------------------------------------



// RHS AFRF ----------------------------------------------------------------------------------------------------------------

// rhs_faction_msv

rhs_faction_msv_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_msv_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_msv_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_msv_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_msv_mappings, "FactionName", "rhs_faction_msv"] call ALIVE_fnc_hashSet;
[rhs_faction_msv_mappings, "GroupFactionName", "rhs_faction_msv"] call ALIVE_fnc_hashSet;

rhs_faction_msv_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_msv_mappings, "GroupFactionTypes", rhs_faction_msv_typeMappings] call ALIVE_fnc_hashSet;

[rhs_faction_msv_factionCustomGroups, "Infantry", ["rhs_group_rus_msv_infantry_emr_chq","rhs_group_rus_msv_infantry_emr_squad","rhs_group_rus_msv_infantry_emr_squad_2mg","rhs_group_rus_msv_infantry_emr_squad_sniper","rhs_group_rus_msv_infantry_emr_squad_mg_sniper","rhs_group_rus_msv_infantry_emr_section_mg","rhs_group_rus_msv_infantry_emr_section_marksman","rhs_group_rus_msv_infantry_emr_section_AT","rhs_group_rus_msv_infantry_emr_section_AA","rhs_group_rus_msv_infantry_emr_fireteam","rhs_group_rus_msv_infantry_emr_MANEUVER","rhs_group_rus_msv_infantry_chq","rhs_group_rus_msv_infantry_squad","rhs_group_rus_msv_infantry_squad_2mg","rhs_group_rus_msv_infantry_squad_sniper","rhs_group_rus_msv_infantry_squad_mg_sniper","rhs_group_rus_msv_infantry_section_mg","rhs_group_rus_msv_infantry_section_marksman","rhs_group_rus_msv_infantry_section_AT","rhs_group_rus_msv_infantry_section_AA","rhs_group_rus_msv_infantry_fireteam","rhs_group_rus_msv_infantry_MANEUVER"]] call ALIVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups, "Motorized", ["rhs_group_rus_msv_gaz66_chq","rhs_group_rus_msv_gaz66_squad","rhs_group_rus_msv_gaz66_squad_2mg","rhs_group_rus_msv_gaz66_squad_sniper","rhs_group_rus_msv_gaz66_squad_mg_sniper","rhs_group_rus_msv_gaz66_squad_aa","rhs_group_rus_msv_Ural_chq","rhs_group_rus_msv_Ural_squad","rhs_group_rus_msv_Ural_squad_2mg","rhs_group_rus_msv_Ural_squad_sniper","rhs_group_rus_msv_Ural_squad_mg_sniper","rhs_group_rus_msv_Ural_squad_aa"]] call ALIVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups, "Mechanized", ["rhs_group_rus_MSV_BMP3_chq","rhs_group_rus_MSV_BMP3_squad","rhs_group_rus_MSV_BMP3_squad_2mg","rhs_group_rus_MSV_BMP3_squad_sniper","rhs_group_rus_MSV_BMP3_squad_mg_sniper","rhs_group_rus_MSV_BMP3_squad_aa","rhs_group_rus_msv_bmp2_chq","rhs_group_rus_msv_bmp2_squad","rhs_group_rus_msv_bmp2_squad_2mg","rhs_group_rus_msv_bmp2_squad_sniper","rhs_group_rus_msv_bmp2_squad_mg_sniper","rhs_group_rus_msv_bmp2_squad_aa","rhs_group_rus_msv_bmp1_chq","rhs_group_rus_msv_bmp1_squad","rhs_group_rus_msv_bmp1_squad_2mg","rhs_group_rus_msv_bmp1_squad_sniper","rhs_group_rus_msv_bmp1_squad_mg_sniper","rhs_group_rus_msv_bmp1_squad_aa","rhs_group_rus_msv_BTR80a_chq","rhs_group_rus_msv_BTR80a_squad","rhs_group_rus_msv_BTR80a_squad_2mg","rhs_group_rus_msv_BTR80a_squad_sniper","rhs_group_rus_msv_BTR80a_squad_mg_sniper","rhs_group_rus_msv_BTR80a_squad_aa","rhs_group_rus_msv_BTR80_chq","rhs_group_rus_msv_BTR80_squad","rhs_group_rus_msv_BTR80_squad_2mg","rhs_group_rus_msv_BTR80_squad_sniper","rhs_group_rus_msv_BTR80_squad_mg_sniper","rhs_group_rus_msv_BTR80_squad_aa","rhs_group_rus_msv_btr70_chq","rhs_group_rus_msv_btr70_squad","rhs_group_rus_msv_btr70_squad_2mg","rhs_group_rus_msv_btr70_squad_sniper","rhs_group_rus_msv_btr70_squad_mg_sniper","rhs_group_rus_msv_btr70_squad_aa"]] call ALIVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_msv_bm21","RHS_SPGSection_msv_bm21"]] call ALIVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups, "Armored", ["RHS_T80Platoon","RHS_T80Platoon_AA","RHS_T80Section","RHS_T80BPlatoon","RHS_T80BPlatoon_AA","RHS_T80BSection","RHS_T80BVPlatoon","RHS_T80BVPlatoon_AA","RHS_T80BVSection","RHS_T80APlatoon","RHS_T80APlatoon_AA","RHS_T80ASection","RHS_T80UPlatoon","RHS_T80UPlatoon_AA","RHS_T80USection","RHS_T72BAPlatoon","RHS_T72BAPlatoon_AA","RHS_T72BASection","RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection","RHS_T72BCPlatoon","RHS_T72BCPlatoon_AA","RHS_T72BCSection","RHS_T72BDPlatoon","RHS_T72BDPlatoon_AA","RHS_T72BDSection"]] call ALIVE_fnc_hashSet;

[rhs_faction_msv_mappings, "Groups", rhs_faction_msv_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_msv", rhs_faction_msv_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3","rhs_9k79","rhs_9k79_K","rhs_9k79_B","rhs_2s3_tv","rhs_zsu234_aa","RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf","rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_tigr_sts_vmf","rhs_tigr_sts_3camo_vmf","rhs_tigr_m_vmf","rhs_tigr_m_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf","rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv","rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01","RHS_Ural_MSV_01","RHS_Ural_Open_MSV_01","RHS_Ural_Fuel_MSV_01","RHS_BM21_MSV_01","rhs_gaz66_msv","rhs_gaz66o_msv","rhs_gaz66_r142_msv","rhs_gaz66_repair_msv","rhs_gaz66_ap2_msv","rhs_gaz66_ammo_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01","rhs_uaz_vdv","rhs_uaz_open_vdv","rhs_gaz66_vmf","rhs_gaz66o_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["RHS_Mi24P_vvsc","RHS_Mi24P_CAS_vvsc","RHS_Mi24P_AT_vvsc","RHS_Mi24V_vvsc","RHS_Mi24V_FAB_vvsc","RHS_Mi24V_UPK23_vvsc","RHS_Mi24V_AT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8MTV3_UPK23_vvsc","RHS_Mi8MTV3_FAB_vvsc","RHS_Mi8AMT_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8AMTSh_UPK23_vvsc","RHS_Mi8AMTSh_FAB_vvsc","rhs_ka60_c","RHS_Mi24P_vvs","RHS_Mi24P_CAS_vvs","RHS_Mi24P_AT_vvs","RHS_Mi24V_vvs","RHS_Mi24V_FAB_vvs","RHS_Mi24V_UPK23_vvs","RHS_Mi24V_AT_vvs","RHS_Mi24Vt_vvs","RHS_Mi8mt_vvs","RHS_Mi8mt_Cargo_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8MTV3_UPK23_vvs","RHS_Mi8MTV3_FAB_vvs","RHS_Mi8AMT_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8AMTSh_UPK23_vvs","RHS_Mi8AMTSh_FAB_vvs","rhs_ka60_grey","RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv","RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;

/*
// Static
[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["rhs_Metis_9k115_2_msv","rhs_Igla_AA_pod_msv","RHS_AGS30_TriPod_MSV","rhs_KORD_MSV","rhs_KORD_high_MSV","RHS_NSV_TriPod_MSV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_msv", ["rhs_Metis_9k115_2_msv","rhs_Igla_AA_pod_msv","RHS_AGS30_TriPod_MSV","rhs_KORD_MSV","rhs_KORD_high_MSV","RHS_NSV_TriPod_MSV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["rhs_Metis_9k115_2_msv","rhs_Igla_AA_pod_msv","RHS_AGS30_TriPod_MSV","rhs_KORD_MSV","rhs_KORD_high_MSV","RHS_NSV_TriPod_MSV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["rhs_Metis_9k115_2_msv","rhs_Igla_AA_pod_msv","RHS_AGS30_TriPod_MSV","rhs_KORD_MSV","rhs_KORD_high_MSV","RHS_NSV_TriPod_MSV"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_msv", ["rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_artillery
[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["rhs_D30_msv","rhs_D30_at_msv","rhs_2b14_82mm_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_msv", ["rhs_D30_msv","rhs_D30_at_msv","rhs_2b14_82mm_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["rhs_D30_msv","rhs_D30_at_msv","rhs_2b14_82mm_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["rhs_D30_msv","rhs_D30_at_msv","rhs_2b14_82mm_msv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_truck
[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["RHS_Ural_MSV_01","RHS_Ural_Open_MSV_01","RHS_Ural_Fuel_MSV_01","RHS_BM21_MSV_01","rhs_gaz66_msv","rhs_gaz66o_msv","rhs_gaz66_r142_msv","rhs_gaz66_repair_msv","rhs_gaz66_ap2_msv","rhs_gaz66_ammo_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_msv", ["RHS_Ural_MSV_01","RHS_Ural_Open_MSV_01","RHS_Ural_Fuel_MSV_01","RHS_BM21_MSV_01","rhs_gaz66_msv","rhs_gaz66o_msv","rhs_gaz66_r142_msv","rhs_gaz66_repair_msv","rhs_gaz66_ap2_msv","rhs_gaz66_ammo_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["RHS_Ural_MSV_01","RHS_Ural_Open_MSV_01","RHS_Ural_Fuel_MSV_01","RHS_BM21_MSV_01","rhs_gaz66_msv","rhs_gaz66o_msv","rhs_gaz66_r142_msv","rhs_gaz66_repair_msv","rhs_gaz66_ap2_msv","rhs_gaz66_ammo_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["RHS_Ural_MSV_01","RHS_Ural_Open_MSV_01","RHS_Ural_Fuel_MSV_01","RHS_BM21_MSV_01","rhs_gaz66_msv","rhs_gaz66o_msv","rhs_gaz66_r142_msv","rhs_gaz66_repair_msv","rhs_gaz66_ap2_msv","rhs_gaz66_ammo_msv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["rhs_bmp3_msv","rhs_bmp3_late_msv","rhs_bmp3m_msv","rhs_bmp3mera_msv","rhs_bmp1_msv","rhs_bmp1p_msv","rhs_bmp1k_msv","rhs_bmp1d_msv","rhs_prp3_msv","rhs_bmp2e_msv","rhs_bmp2_msv","rhs_bmp2k_msv","rhs_bmp2d_msv","rhs_brm1k_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_msv", ["rhs_bmp3_msv","rhs_bmp3_late_msv","rhs_bmp3m_msv","rhs_bmp3mera_msv","rhs_bmp1_msv","rhs_bmp1p_msv","rhs_bmp1k_msv","rhs_bmp1d_msv","rhs_prp3_msv","rhs_bmp2e_msv","rhs_bmp2_msv","rhs_bmp2k_msv","rhs_bmp2d_msv","rhs_brm1k_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["rhs_bmp3_msv","rhs_bmp3_late_msv","rhs_bmp3m_msv","rhs_bmp3mera_msv","rhs_bmp1_msv","rhs_bmp1p_msv","rhs_bmp1k_msv","rhs_bmp1d_msv","rhs_prp3_msv","rhs_bmp2e_msv","rhs_bmp2_msv","rhs_bmp2k_msv","rhs_bmp2d_msv","rhs_brm1k_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["rhs_bmp3_msv","rhs_bmp3_late_msv","rhs_bmp3m_msv","rhs_bmp3mera_msv","rhs_bmp1_msv","rhs_bmp1p_msv","rhs_bmp1k_msv","rhs_bmp1d_msv","rhs_prp3_msv","rhs_bmp2e_msv","rhs_bmp2_msv","rhs_bmp2k_msv","rhs_bmp2d_msv","rhs_brm1k_msv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_apc
[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["rhs_btr70_msv","rhs_btr80_msv","rhs_btr80a_msv","rhs_btr60_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_msv", ["rhs_btr70_msv","rhs_btr80_msv","rhs_btr80a_msv","rhs_btr60_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["rhs_btr70_msv","rhs_btr80_msv","rhs_btr80a_msv","rhs_btr60_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["rhs_btr70_msv","rhs_btr80_msv","rhs_btr80a_msv","rhs_btr60_msv"]] call ALIVE_fnc_hashSet;
*/


// rhs_faction_vdv

rhs_faction_vdv_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_vdv_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_vdv_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_mappings, "FactionName", "rhs_faction_vdv"] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_mappings, "GroupFactionName", "rhs_faction_vdv"] call ALIVE_fnc_hashSet;

rhs_faction_vdv_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_vdv_mappings, "GroupFactionTypes", rhs_faction_vdv_typeMappings] call ALIVE_fnc_hashSet;

[rhs_faction_vdv_factionCustomGroups, "Infantry", ["rhs_group_rus_vdv_infantry_mflora_chq","rhs_group_rus_vdv_infantry_mflora_squad","rhs_group_rus_vdv_infantry_mflora_squad_2mg","rhs_group_rus_vdv_infantry_mflora_squad_sniper","rhs_group_rus_vdv_infantry_mflora_squad_mg_sniper","rhs_group_rus_vdv_infantry_mflora_section_mg","rhs_group_rus_vdv_infantry_mflora_section_marksman","rhs_group_rus_vdv_infantry_mflora_section_AT","rhs_group_rus_vdv_infantry_mflora_section_AA","rhs_group_rus_vdv_infantry_mflora_fireteam","rhs_group_rus_vdv_infantry_mflora_MANEUVER","rhs_group_rus_vdv_infantry_flora_chq","rhs_group_rus_vdv_infantry_flora_squad","rhs_group_rus_vdv_infantry_flora_squad_2mg","rhs_group_rus_vdv_infantry_flora_squad_sniper","rhs_group_rus_vdv_infantry_flora_squad_mg_sniper","rhs_group_rus_vdv_infantry_flora_section_mg","rhs_group_rus_vdv_infantry_flora_section_marksman","rhs_group_rus_vdv_infantry_flora_section_AT","rhs_group_rus_vdv_infantry_flora_section_AA","rhs_group_rus_vdv_infantry_flora_fireteam","rhs_group_rus_vdv_infantry_flora_MANEUVER","rhs_group_rus_vdv_infantry_chq","rhs_group_rus_vdv_infantry_squad","rhs_group_rus_vdv_infantry_squad_2mg","rhs_group_rus_vdv_infantry_squad_sniper","rhs_group_rus_vdv_infantry_squad_mg_sniper","rhs_group_rus_vdv_infantry_section_mg","rhs_group_rus_vdv_infantry_section_marksman","rhs_group_rus_vdv_infantry_section_AT","rhs_group_rus_vdv_infantry_section_AA","rhs_group_rus_vdv_infantry_fireteam","rhs_group_rus_vdv_infantry_MANEUVER","rhs_group_rus_vdv_recon_infantry_squad"]] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups, "Motorized", ["rhs_group_rus_vdv_gaz66_chq","rhs_group_rus_vdv_gaz66_squad","rhs_group_rus_vdv_gaz66_squad_2mg","rhs_group_rus_vdv_gaz66_squad_sniper","rhs_group_rus_vdv_gaz66_squad_mg_sniper","rhs_group_rus_vdv_gaz66_squad_aa","rhs_group_rus_vdv_Ural_chq","rhs_group_rus_vdv_Ural_squad","rhs_group_rus_vdv_Ural_squad_2mg","rhs_group_rus_vdv_Ural_squad_sniper","rhs_group_rus_vdv_Ural_squad_mg_sniper","rhs_group_rus_vdv_Ural_squad_aa"]] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups, "Mechanized", ["rhs_group_rus_vdv_bmd4ma_chq","rhs_group_rus_vdv_bmd4ma_squad","rhs_group_rus_vdv_bmd4ma_squad_2mg","rhs_group_rus_vdv_bmd4ma_squad_sniper","rhs_group_rus_vdv_bmd4ma_squad_mg_sniper","rhs_group_rus_vdv_bmd4ma_squad_aa","rhs_group_rus_vdv_bmd4m_chq","rhs_group_rus_vdv_bmd4m_squad","rhs_group_rus_vdv_bmd4m_squad_2mg","rhs_group_rus_vdv_bmd4m_squad_sniper","rhs_group_rus_vdv_bmd4m_squad_mg_sniper","rhs_group_rus_vdv_bmd4m_squad_aa","rhs_group_rus_vdv_bmd4_chq","rhs_group_rus_vdv_bmd4_squad","rhs_group_rus_vdv_bmd4_squad_2mg","rhs_group_rus_vdv_bmd4_squad_sniper","rhs_group_rus_vdv_bmd4_squad_mg_sniper","rhs_group_rus_vdv_bmd4_squad_aa","rhs_group_rus_vdv_bmd2_chq","rhs_group_rus_vdv_bmd2_squad","rhs_group_rus_vdv_bmd2_squad_2mg","rhs_group_rus_vdv_bmd2_squad_sniper","rhs_group_rus_vdv_bmd2_squad_mg_sniper","rhs_group_rus_vdv_bmd2_squad_aa","rhs_group_rus_vdv_bmd1_chq","rhs_group_rus_vdv_bmd1_squad","rhs_group_rus_vdv_bmd1_squad_2mg","rhs_group_rus_vdv_bmd1_squad_sniper","rhs_group_rus_vdv_bmd1_squad_mg_sniper","rhs_group_rus_vdv_bmd1_squad_aa","rhs_group_rus_vdv_bmp2_chq","rhs_group_rus_vdv_bmp2_squad","rhs_group_rus_vdv_bmp2_squad_2mg","rhs_group_rus_vdv_bmp2_squad_sniper","rhs_group_rus_vdv_bmp2_squad_mg_sniper","rhs_group_rus_vdv_bmp2_squad_aa","rhs_group_rus_vdv_bmp1_chq","rhs_group_rus_vdv_bmp1_squad","rhs_group_rus_vdv_bmp1_squad_2mg","rhs_group_rus_vdv_bmp1_squad_sniper","rhs_group_rus_vdv_bmp1_squad_mg_sniper","rhs_group_rus_vdv_bmp1_squad_aa","rhs_group_rus_vdv_BTR80a_chq","rhs_group_rus_vdv_BTR80a_squad","rhs_group_rus_vdv_BTR80a_squad_2mg","rhs_group_rus_vdv_BTR80a_squad_sniper","rhs_group_rus_vdv_BTR80a_squad_mg_sniper","rhs_group_rus_vdv_BTR80a_squad_aa","rhs_group_rus_vdv_BTR80_chq","rhs_group_rus_vdv_BTR80_squad","rhs_group_rus_vdv_BTR80_squad_2mg","rhs_group_rus_vdv_BTR80_squad_sniper","rhs_group_rus_vdv_BTR80_squad_mg_sniper","rhs_group_rus_vdv_BTR80_squad_aa","rhs_group_rus_vdv_btr70_chq","rhs_group_rus_vdv_btr70_squad","rhs_group_rus_vdv_btr70_squad_2mg","rhs_group_rus_vdv_btr70_squad_sniper","rhs_group_rus_vdv_btr70_squad_mg_sniper","rhs_group_rus_vdv_btr70_squad_aa","rhs_group_rus_vdv_btr60_chq","rhs_group_rus_vdv_btr60_squad","rhs_group_rus_vdv_btr60_squad_2mg","rhs_group_rus_vdv_btr60_squad_sniper","rhs_group_rus_vdv_btr60_squad_mg_sniper","rhs_group_rus_vdv_btr60_squad_aa"]] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups, "Airborne", ["rhs_group_rus_vdv_mi24_chq","rhs_group_rus_vdv_mi24_squad","rhs_group_rus_vdv_mi24_squad_2mg","rhs_group_rus_vdv_mi24_squad_sniper","rhs_group_rus_vdv_mi24_squad_mg_sniper","rhs_group_rus_vdv_mi8_chq","rhs_group_rus_vdv_mi8_squad","rhs_group_rus_vdv_mi8_squad_2mg","rhs_group_rus_vdv_mi8_squad_sniper","rhs_group_rus_vdv_mi8_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_vdv_bm21","RHS_SPGSection_vdv_bm21","RHS_SPGPlatoon_tv_2s3","RHS_SPGSection_tv_2s3"]] call ALIVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups, "Armored", ["RHS_2S25Platoon","RHS_2S25Platoon_AA","RHS_2S25Section","RHS_T80Platoon","RHS_T80Platoon_AA","RHS_T80Section","RHS_T80BPlatoon","RHS_T80BPlatoon_AA","RHS_T80BSection","RHS_T80BVPlatoon","RHS_T80BVPlatoon_AA","RHS_T80BVSection","RHS_T80APlatoon","RHS_T80APlatoon_AA","RHS_T80ASection","RHS_T80UPlatoon","RHS_T80UPlatoon_AA","RHS_T80USection","RHS_T72BAPlatoon","RHS_T72BAPlatoon_AA","RHS_T72BASection","RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection","RHS_T72BCPlatoon","RHS_T72BCPlatoon_AA","RHS_T72BCSection","RHS_T72BDPlatoon","RHS_T72BDPlatoon_AA","RHS_T72BDSection"]] call ALIVE_fnc_hashSet;

[rhs_faction_vdv_mappings, "Groups", rhs_faction_vdv_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_vdv", rhs_faction_vdv_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3","rhs_9k79","rhs_9k79_K","rhs_9k79_B","rhs_2s3_tv","rhs_zsu234_aa","RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf","rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf","rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["RHS_Ural_VDV_01","RHS_Ural_Open_VDV_01","rhs_gaz66_vdv","rhs_gaz66o_vdv","rhs_gaz66_ap2_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;

/*
// Static
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_Metis_9k115_2_vdv","rhs_Igla_AA_pod_vdv","RHS_AGS30_TriPod_VDV","rhs_KORD_VDV","rhs_KORD_high_VDV","RHS_NSV_TriPod_VDV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["rhs_Metis_9k115_2_vdv","rhs_Igla_AA_pod_vdv","RHS_AGS30_TriPod_VDV","rhs_KORD_VDV","rhs_KORD_high_VDV","RHS_NSV_TriPod_VDV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["rhs_Metis_9k115_2_vdv","rhs_Igla_AA_pod_vdv","RHS_AGS30_TriPod_VDV","rhs_KORD_VDV","rhs_KORD_high_VDV","RHS_NSV_TriPod_VDV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["rhs_Metis_9k115_2_vdv","rhs_Igla_AA_pod_vdv","RHS_AGS30_TriPod_VDV","rhs_KORD_VDV","rhs_KORD_high_VDV","RHS_NSV_TriPod_VDV"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_artillery
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_D30_vdv","rhs_D30_at_vdv","rhs_2b14_82mm_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["rhs_D30_vdv","rhs_D30_at_vdv","rhs_2b14_82mm_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["rhs_D30_vdv","rhs_D30_at_vdv","rhs_2b14_82mm_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["rhs_D30_vdv","rhs_D30_at_vdv","rhs_2b14_82mm_vdv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_helicopter
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_truck
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["RHS_Ural_VDV_01","RHS_Ural_Open_VDV_01","RHS_Ural_Fuel_VDV_01","RHS_BM21_VDV_01","rhs_typhoon_vdv","rhs_gaz66_vdv","rhs_gaz66o_vdv","rhs_gaz66_r142_vdv","rhs_gaz66_repair_vdv","rhs_gaz66_ap2_vdv","rhs_gaz66_ammo_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["RHS_Ural_VDV_01","RHS_Ural_Open_VDV_01","RHS_Ural_Fuel_VDV_01","RHS_BM21_VDV_01","rhs_typhoon_vdv","rhs_gaz66_vdv","rhs_gaz66o_vdv","rhs_gaz66_r142_vdv","rhs_gaz66_repair_vdv","rhs_gaz66_ap2_vdv","rhs_gaz66_ammo_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["RHS_Ural_VDV_01","RHS_Ural_Open_VDV_01","RHS_Ural_Fuel_VDV_01","RHS_BM21_VDV_01","rhs_typhoon_vdv","rhs_gaz66_vdv","rhs_gaz66o_vdv","rhs_gaz66_r142_vdv","rhs_gaz66_repair_vdv","rhs_gaz66_ap2_vdv","rhs_gaz66_ammo_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["RHS_Ural_VDV_01","RHS_Ural_Open_VDV_01","RHS_Ural_Fuel_VDV_01","RHS_BM21_VDV_01","rhs_typhoon_vdv","rhs_gaz66_vdv","rhs_gaz66o_vdv","rhs_gaz66_r142_vdv","rhs_gaz66_repair_vdv","rhs_gaz66_ap2_vdv","rhs_gaz66_ammo_vdv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_bmd1","rhs_bmd1k","rhs_bmd1p","rhs_bmd1pk","rhs_bmd1r","rhs_bmd2","rhs_bmd2m","rhs_bmd2k","rhs_bmp1_vdv","rhs_bmp1p_vdv","rhs_bmp1k_vdv","rhs_bmp1d_vdv","rhs_prp3_vdv","rhs_bmp2e_vdv","rhs_bmp2_vdv","rhs_bmp2k_vdv","rhs_bmp2d_vdv","rhs_brm1k_vdv","rhs_bmd4_vdv","rhs_bmd4m_vdv","rhs_bmd4ma_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["rhs_bmd1","rhs_bmd1k","rhs_bmd1p","rhs_bmd1pk","rhs_bmd1r","rhs_bmd2","rhs_bmd2m","rhs_bmd2k","rhs_bmp1_vdv","rhs_bmp1p_vdv","rhs_bmp1k_vdv","rhs_bmp1d_vdv","rhs_prp3_vdv","rhs_bmp2e_vdv","rhs_bmp2_vdv","rhs_bmp2k_vdv","rhs_bmp2d_vdv","rhs_brm1k_vdv","rhs_bmd4_vdv","rhs_bmd4m_vdv","rhs_bmd4ma_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["rhs_bmd1","rhs_bmd1k","rhs_bmd1p","rhs_bmd1pk","rhs_bmd1r","rhs_bmd2","rhs_bmd2m","rhs_bmd2k","rhs_bmp1_vdv","rhs_bmp1p_vdv","rhs_bmp1k_vdv","rhs_bmp1d_vdv","rhs_prp3_vdv","rhs_bmp2e_vdv","rhs_bmp2_vdv","rhs_bmp2k_vdv","rhs_bmp2d_vdv","rhs_brm1k_vdv","rhs_bmd4_vdv","rhs_bmd4m_vdv","rhs_bmd4ma_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["rhs_bmd1","rhs_bmd1k","rhs_bmd1p","rhs_bmd1pk","rhs_bmd1r","rhs_bmd2","rhs_bmd2m","rhs_bmd2k","rhs_bmp1_vdv","rhs_bmp1p_vdv","rhs_bmp1k_vdv","rhs_bmp1d_vdv","rhs_prp3_vdv","rhs_bmp2e_vdv","rhs_bmp2_vdv","rhs_bmp2k_vdv","rhs_bmp2d_vdv","rhs_brm1k_vdv","rhs_bmd4_vdv","rhs_bmd4m_vdv","rhs_bmd4ma_vdv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_apc
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_btr70_vdv","rhs_btr80_vdv","rhs_btr80a_vdv","rhs_btr60_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["rhs_btr70_vdv","rhs_btr80_vdv","rhs_btr80a_vdv","rhs_btr60_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["rhs_btr70_vdv","rhs_btr80_vdv","rhs_btr80a_vdv","rhs_btr60_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["rhs_btr70_vdv","rhs_btr80_vdv","rhs_btr80a_vdv","rhs_btr60_vdv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_tank
[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_sprut_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vdv", ["rhs_sprut_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["rhs_sprut_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["rhs_sprut_vdv"]] call ALIVE_fnc_hashSet;
*/


// rhs_faction_tv

rhs_faction_tv_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_tv_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_tv_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_tv_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_tv_mappings, "FactionName", "rhs_faction_tv"] call ALIVE_fnc_hashSet;
[rhs_faction_tv_mappings, "GroupFactionName", "rhs_faction_tv"] call ALIVE_fnc_hashSet;

rhs_faction_tv_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_tv_mappings, "GroupFactionTypes", rhs_faction_tv_typeMappings] call ALIVE_fnc_hashSet;

[rhs_faction_tv_factionCustomGroups, "Armored", ["RHS_T90Platoon","RHS_T90Platoon_AA","RHS_T90Section","RHS_T90APlatoon","RHS_T90APlatoon_AA","RHS_T90ASection","RHS_T80Platoon","RHS_T80Platoon_AA","RHS_T80Section","RHS_T80BPlatoon","RHS_T80BPlatoon_AA","RHS_T80BSection","RHS_T80BVPlatoon","RHS_T80BVPlatoon_AA","RHS_T80BVSection","RHS_T80APlatoon","RHS_T80APlatoon_AA","RHS_T80ASection","RHS_T80UPlatoon","RHS_T80UPlatoon_AA","RHS_T80USection","RHS_T72BAPlatoon","RHS_T72BAPlatoon_AA","RHS_T72BASection","RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection","RHS_T72BCPlatoon","RHS_T72BCPlatoon_AA","RHS_T72BCSection","RHS_T72BDPlatoon","RHS_T72BDPlatoon_AA","RHS_T72BDSection"]] call ALIVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_tv_2s3","RHS_SPGSection_tv_2s3"]] call ALIVE_fnc_hashSet;

[rhs_faction_tv_mappings, "Groups", rhs_faction_tv_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_tv", rhs_faction_tv_mappings] call ALIVE_fnc_hashSet;

/*
// rhs_vehclass_artillery
[ALIVE_factionDefaultSupports, "rhs_faction_tv", ["rhs_2s3_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_tv", ["rhs_2s3_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_tv", ["rhs_2s3_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_tv", ["rhs_2s3_tv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_tv", ["rhs_bmp1_tv","rhs_bmp1p_tv","rhs_bmp1k_tv","rhs_bmp1d_tv","rhs_prp3_tv","rhs_bmp2e_tv","rhs_bmp2_tv","rhs_bmp2k_tv","rhs_bmp2d_tv","rhs_brm1k_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_tv", ["rhs_bmp1_tv","rhs_bmp1p_tv","rhs_bmp1k_tv","rhs_bmp1d_tv","rhs_prp3_tv","rhs_bmp2e_tv","rhs_bmp2_tv","rhs_bmp2k_tv","rhs_bmp2d_tv","rhs_brm1k_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_tv", ["rhs_bmp1_tv","rhs_bmp1p_tv","rhs_bmp1k_tv","rhs_bmp1d_tv","rhs_prp3_tv","rhs_bmp2e_tv","rhs_bmp2_tv","rhs_bmp2k_tv","rhs_bmp2d_tv","rhs_brm1k_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_tv", ["rhs_bmp1_tv","rhs_bmp1p_tv","rhs_bmp1k_tv","rhs_bmp1d_tv","rhs_prp3_tv","rhs_bmp2e_tv","rhs_bmp2_tv","rhs_bmp2k_tv","rhs_bmp2d_tv","rhs_brm1k_tv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_tank
[ALIVE_factionDefaultSupports, "rhs_faction_tv", ["rhs_t72ba_tv","rhs_t72bb_tv","rhs_t72bc_tv","rhs_t72bd_tv","rhs_t80b","rhs_t80bk","rhs_t80bv","rhs_t80bvk","rhs_t80","rhs_t80a","rhs_t80u","rhs_t80u45m","rhs_t80ue1","rhs_t80um","rhs_t90_tv","rhs_t90a_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_tv", ["rhs_t72ba_tv","rhs_t72bb_tv","rhs_t72bc_tv","rhs_t72bd_tv","rhs_t80b","rhs_t80bk","rhs_t80bv","rhs_t80bvk","rhs_t80","rhs_t80a","rhs_t80u","rhs_t80u45m","rhs_t80ue1","rhs_t80um","rhs_t90_tv","rhs_t90a_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_tv", ["rhs_t72ba_tv","rhs_t72bb_tv","rhs_t72bc_tv","rhs_t72bd_tv","rhs_t80b","rhs_t80bk","rhs_t80bv","rhs_t80bvk","rhs_t80","rhs_t80a","rhs_t80u","rhs_t80u45m","rhs_t80ue1","rhs_t80um","rhs_t90_tv","rhs_t90a_tv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_tv", ["rhs_t72ba_tv","rhs_t72bb_tv","rhs_t72bc_tv","rhs_t72bd_tv","rhs_t80b","rhs_t80bk","rhs_t80bv","rhs_t80bvk","rhs_t80","rhs_t80a","rhs_t80u","rhs_t80u45m","rhs_t80ue1","rhs_t80um","rhs_t90_tv","rhs_t90a_tv"]] call ALIVE_fnc_hashSet;
*/


/*
// rhs_faction_vmf
rhs_faction_vmf_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_vmf_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vmf_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vmf_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vmf_mappings, "FactionName", "rhs_faction_vmf"] call ALIVE_fnc_hashSet;
[rhs_faction_vmf_mappings, "GroupFactionName", "rhs_faction_vmf"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vmf_mappings, "GroupFactionTypes", rhs_faction_vmf_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_vmf_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_vmf_mappings, "Groups", rhs_faction_vmf_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_vmf", rhs_faction_vmf_mappings] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_vmf", ["rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_tigr_sts_vmf","rhs_tigr_sts_3camo_vmf","rhs_tigr_m_vmf","rhs_tigr_m_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vmf", ["rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_tigr_sts_vmf","rhs_tigr_sts_3camo_vmf","rhs_tigr_m_vmf","rhs_tigr_m_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vmf", ["rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_tigr_sts_vmf","rhs_tigr_sts_3camo_vmf","rhs_tigr_m_vmf","rhs_tigr_m_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vmf", ["rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_tigr_sts_vmf","rhs_tigr_sts_3camo_vmf","rhs_tigr_m_vmf","rhs_tigr_m_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_truck
[ALIVE_factionDefaultSupports, "rhs_faction_vmf", ["RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vmf", ["RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vmf", ["RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vmf", ["RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_vmf", ["rhs_bmp1_vmf","rhs_bmp1p_vmf","rhs_bmp1k_vmf","rhs_bmp1d_vmf","rhs_prp3_vmf","rhs_bmp2e_vmf","rhs_bmp2_vmf","rhs_bmp2k_vmf","rhs_bmp2d_vmf","rhs_brm1k_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vmf", ["rhs_bmp1_vmf","rhs_bmp1p_vmf","rhs_bmp1k_vmf","rhs_bmp1d_vmf","rhs_prp3_vmf","rhs_bmp2e_vmf","rhs_bmp2_vmf","rhs_bmp2k_vmf","rhs_bmp2d_vmf","rhs_brm1k_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vmf", ["rhs_bmp1_vmf","rhs_bmp1p_vmf","rhs_bmp1k_vmf","rhs_bmp1d_vmf","rhs_prp3_vmf","rhs_bmp2e_vmf","rhs_bmp2_vmf","rhs_bmp2k_vmf","rhs_bmp2d_vmf","rhs_brm1k_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vmf", ["rhs_bmp1_vmf","rhs_bmp1p_vmf","rhs_bmp1k_vmf","rhs_bmp1d_vmf","rhs_prp3_vmf","rhs_bmp2e_vmf","rhs_bmp2_vmf","rhs_bmp2k_vmf","rhs_bmp2d_vmf","rhs_brm1k_vmf"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_apc
[ALIVE_factionDefaultSupports, "rhs_faction_vmf", ["rhs_btr70_vmf","rhs_btr80_vmf","rhs_btr80a_vmf","rhs_btr60_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vmf", ["rhs_btr70_vmf","rhs_btr80_vmf","rhs_btr80a_vmf","rhs_btr60_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vmf", ["rhs_btr70_vmf","rhs_btr80_vmf","rhs_btr80a_vmf","rhs_btr60_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vmf", ["rhs_btr70_vmf","rhs_btr80_vmf","rhs_btr80a_vmf","rhs_btr60_vmf"]] call ALIVE_fnc_hashSet;
// rhs_faction_vv
rhs_faction_vv_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_vv_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vv_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vv_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vv_mappings, "FactionName", "rhs_faction_vv"] call ALIVE_fnc_hashSet;
[rhs_faction_vv_mappings, "GroupFactionName", "rhs_faction_vv"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vv_mappings, "GroupFactionTypes", rhs_faction_vv_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_vv_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_vv_mappings, "Groups", rhs_faction_vv_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_vv", rhs_faction_vv_mappings] call ALIVE_fnc_hashSet;
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_vv", ["rhs_tigr_vv","rhs_tigr_3camo_vv","rhs_tigr_ffv_vv","rhs_tigr_ffv_3camo_vv","rhs_tigr_sts_vv","rhs_tigr_sts_3camo_vv","rhs_tigr_m_vv","rhs_tigr_m_3camo_vv","rhs_uaz_vv","rhs_uaz_open_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vv", ["rhs_tigr_vv","rhs_tigr_3camo_vv","rhs_tigr_ffv_vv","rhs_tigr_ffv_3camo_vv","rhs_tigr_sts_vv","rhs_tigr_sts_3camo_vv","rhs_tigr_m_vv","rhs_tigr_m_3camo_vv","rhs_uaz_vv","rhs_uaz_open_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vv", ["rhs_tigr_vv","rhs_tigr_3camo_vv","rhs_tigr_ffv_vv","rhs_tigr_ffv_3camo_vv","rhs_tigr_sts_vv","rhs_tigr_sts_3camo_vv","rhs_tigr_m_vv","rhs_tigr_m_3camo_vv","rhs_uaz_vv","rhs_uaz_open_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vv", ["rhs_tigr_vv","rhs_tigr_3camo_vv","rhs_tigr_ffv_vv","rhs_tigr_ffv_3camo_vv","rhs_tigr_sts_vv","rhs_tigr_sts_3camo_vv","rhs_tigr_m_vv","rhs_tigr_m_3camo_vv","rhs_uaz_vv","rhs_uaz_open_vv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_helicopter
[ALIVE_factionDefaultSupports, "rhs_faction_vv", ["RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vv", ["RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vv", ["RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vv", ["RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_truck
[ALIVE_factionDefaultSupports, "rhs_faction_vv", ["RHS_Ural_VV_01","RHS_Ural_Open_VV_01","RHS_Ural_Fuel_VV_01","RHS_BM21_VV_01","rhs_gaz66_vv","rhs_gaz66o_vv","rhs_gaz66_r142_vv","rhs_gaz66_repair_vv","rhs_gaz66_ap2_vv","rhs_gaz66_ammo_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vv", ["RHS_Ural_VV_01","RHS_Ural_Open_VV_01","RHS_Ural_Fuel_VV_01","RHS_BM21_VV_01","rhs_gaz66_vv","rhs_gaz66o_vv","rhs_gaz66_r142_vv","rhs_gaz66_repair_vv","rhs_gaz66_ap2_vv","rhs_gaz66_ammo_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vv", ["RHS_Ural_VV_01","RHS_Ural_Open_VV_01","RHS_Ural_Fuel_VV_01","RHS_BM21_VV_01","rhs_gaz66_vv","rhs_gaz66o_vv","rhs_gaz66_r142_vv","rhs_gaz66_repair_vv","rhs_gaz66_ap2_vv","rhs_gaz66_ammo_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vv", ["RHS_Ural_VV_01","RHS_Ural_Open_VV_01","RHS_Ural_Fuel_VV_01","RHS_BM21_VV_01","rhs_gaz66_vv","rhs_gaz66o_vv","rhs_gaz66_r142_vv","rhs_gaz66_repair_vv","rhs_gaz66_ap2_vv","rhs_gaz66_ammo_vv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_vv", ["rhs_bmp1_vv","rhs_bmp1p_vv","rhs_bmp1k_vv","rhs_bmp1d_vv","rhs_prp3_vv","rhs_bmp2e_vv","rhs_bmp2_vv","rhs_bmp2k_vv","rhs_bmp2d_vv","rhs_brm1k_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vv", ["rhs_bmp1_vv","rhs_bmp1p_vv","rhs_bmp1k_vv","rhs_bmp1d_vv","rhs_prp3_vv","rhs_bmp2e_vv","rhs_bmp2_vv","rhs_bmp2k_vv","rhs_bmp2d_vv","rhs_brm1k_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vv", ["rhs_bmp1_vv","rhs_bmp1p_vv","rhs_bmp1k_vv","rhs_bmp1d_vv","rhs_prp3_vv","rhs_bmp2e_vv","rhs_bmp2_vv","rhs_bmp2k_vv","rhs_bmp2d_vv","rhs_brm1k_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vv", ["rhs_bmp1_vv","rhs_bmp1p_vv","rhs_bmp1k_vv","rhs_bmp1d_vv","rhs_prp3_vv","rhs_bmp2e_vv","rhs_bmp2_vv","rhs_bmp2k_vv","rhs_bmp2d_vv","rhs_brm1k_vv"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_apc
[ALIVE_factionDefaultSupports, "rhs_faction_vv", ["rhs_btr70_vv","rhs_btr80_vv","rhs_btr80a_vv","rhs_btr60_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vv", ["rhs_btr70_vv","rhs_btr80_vv","rhs_btr80a_vv","rhs_btr60_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vv", ["rhs_btr70_vv","rhs_btr80_vv","rhs_btr80a_vv","rhs_btr60_vv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vv", ["rhs_btr70_vv","rhs_btr80_vv","rhs_btr80a_vv","rhs_btr60_vv"]] call ALIVE_fnc_hashSet;
// rhs_faction_vpvo
rhs_faction_vpvo_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_vpvo_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vpvo_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vpvo_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vpvo_mappings, "FactionName", "rhs_faction_vpvo"] call ALIVE_fnc_hashSet;
[rhs_faction_vpvo_mappings, "GroupFactionName", "rhs_faction_vpvo"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vpvo_mappings, "GroupFactionTypes", rhs_faction_vpvo_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_vpvo_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_vpvo_mappings, "Groups", rhs_faction_vpvo_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_vpvo", rhs_faction_vpvo_mappings] call ALIVE_fnc_hashSet;
// rhs_vehclass_radar
[ALIVE_factionDefaultSupports, "rhs_faction_vpvo", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vpvo", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vpvo", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vpvo", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_aa
[ALIVE_factionDefaultSupports, "rhs_faction_vpvo", ["rhs_zsu234_aa"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vpvo", ["rhs_zsu234_aa"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vpvo", ["rhs_zsu234_aa"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vpvo", ["rhs_zsu234_aa"]] call ALIVE_fnc_hashSet;
// rhs_faction_vvs
rhs_faction_vvs_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_vvs_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vvs_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_mappings, "FactionName", "rhs_faction_vvs"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_mappings, "GroupFactionName", "rhs_faction_vvs"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vvs_mappings, "GroupFactionTypes", rhs_faction_vvs_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_mappings, "Groups", rhs_faction_vvs_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_vvs", rhs_faction_vvs_mappings] call ALIVE_fnc_hashSet;
// rhs_vehclass_helicopter
[ALIVE_factionDefaultSupports, "rhs_faction_vvs", ["RHS_Mi24P_vvs","RHS_Mi24P_CAS_vvs","RHS_Mi24P_AT_vvs","RHS_Mi24V_vvs","RHS_Mi24V_FAB_vvs","RHS_Mi24V_UPK23_vvs","RHS_Mi24V_AT_vvs","RHS_Mi24Vt_vvs","RHS_Mi8mt_vvs","RHS_Mi8mt_Cargo_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8MTV3_UPK23_vvs","RHS_Mi8MTV3_FAB_vvs","RHS_Mi8AMT_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8AMTSh_UPK23_vvs","RHS_Mi8AMTSh_FAB_vvs","RHS_Ka52_vvs","RHS_Ka52_UPK23_vvs","rhs_ka60_grey"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vvs", ["RHS_Mi24P_vvs","RHS_Mi24P_CAS_vvs","RHS_Mi24P_AT_vvs","RHS_Mi24V_vvs","RHS_Mi24V_FAB_vvs","RHS_Mi24V_UPK23_vvs","RHS_Mi24V_AT_vvs","RHS_Mi24Vt_vvs","RHS_Mi8mt_vvs","RHS_Mi8mt_Cargo_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8MTV3_UPK23_vvs","RHS_Mi8MTV3_FAB_vvs","RHS_Mi8AMT_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8AMTSh_UPK23_vvs","RHS_Mi8AMTSh_FAB_vvs","RHS_Ka52_vvs","RHS_Ka52_UPK23_vvs","rhs_ka60_grey"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vvs", ["RHS_Mi24P_vvs","RHS_Mi24P_CAS_vvs","RHS_Mi24P_AT_vvs","RHS_Mi24V_vvs","RHS_Mi24V_FAB_vvs","RHS_Mi24V_UPK23_vvs","RHS_Mi24V_AT_vvs","RHS_Mi24Vt_vvs","RHS_Mi8mt_vvs","RHS_Mi8mt_Cargo_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8MTV3_UPK23_vvs","RHS_Mi8MTV3_FAB_vvs","RHS_Mi8AMT_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8AMTSh_UPK23_vvs","RHS_Mi8AMTSh_FAB_vvs","RHS_Ka52_vvs","RHS_Ka52_UPK23_vvs","rhs_ka60_grey"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vvs", ["RHS_Mi24P_vvs","RHS_Mi24P_CAS_vvs","RHS_Mi24P_AT_vvs","RHS_Mi24V_vvs","RHS_Mi24V_FAB_vvs","RHS_Mi24V_UPK23_vvs","RHS_Mi24V_AT_vvs","RHS_Mi24Vt_vvs","RHS_Mi8mt_vvs","RHS_Mi8mt_Cargo_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8MTV3_UPK23_vvs","RHS_Mi8MTV3_FAB_vvs","RHS_Mi8AMT_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8AMTSh_UPK23_vvs","RHS_Mi8AMTSh_FAB_vvs","RHS_Ka52_vvs","RHS_Ka52_UPK23_vvs","rhs_ka60_grey"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_aircraft
[ALIVE_factionDefaultSupports, "rhs_faction_vvs", ["RHS_Su25SM_vvs","RHS_Su25SM_KH29_vvs","RHS_T50_vvs_generic","RHS_T50_vvs_051","RHS_T50_vvs_052","RHS_T50_vvs_053","RHS_T50_vvs_054","RHS_T50_vvs_055"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vvs", ["RHS_Su25SM_vvs","RHS_Su25SM_KH29_vvs","RHS_T50_vvs_generic","RHS_T50_vvs_051","RHS_T50_vvs_052","RHS_T50_vvs_053","RHS_T50_vvs_054","RHS_T50_vvs_055"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vvs", ["RHS_Su25SM_vvs","RHS_Su25SM_KH29_vvs","RHS_T50_vvs_generic","RHS_T50_vvs_051","RHS_T50_vvs_052","RHS_T50_vvs_053","RHS_T50_vvs_054","RHS_T50_vvs_055"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vvs", ["RHS_Su25SM_vvs","RHS_Su25SM_KH29_vvs","RHS_T50_vvs_generic","RHS_T50_vvs_051","RHS_T50_vvs_052","RHS_T50_vvs_053","RHS_T50_vvs_054","RHS_T50_vvs_055"]] call ALIVE_fnc_hashSet;
// Autonomous
[ALIVE_factionDefaultSupports, "rhs_faction_vvs", ["rhs_pchela1t_vvs"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vvs", ["rhs_pchela1t_vvs"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vvs", ["rhs_pchela1t_vvs"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vvs", ["rhs_pchela1t_vvs"]] call ALIVE_fnc_hashSet;
// rhs_faction_vvs_c
rhs_faction_vvs_c_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_vvs_c_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vvs_c_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_c_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_c_mappings, "FactionName", "rhs_faction_vvs_c"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_c_mappings, "GroupFactionName", "rhs_faction_vvs_c"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_vvs_c_mappings, "GroupFactionTypes", rhs_faction_vvs_c_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_vvs_c_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_vvs_c_mappings, "Groups", rhs_faction_vvs_c_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_vvs_c", rhs_faction_vvs_c_mappings] call ALIVE_fnc_hashSet;
// rhs_vehclass_helicopter
[ALIVE_factionDefaultSupports, "rhs_faction_vvs_c", ["RHS_Mi24P_vvsc","RHS_Mi24P_CAS_vvsc","RHS_Mi24P_AT_vvsc","RHS_Mi24V_vvsc","RHS_Mi24V_FAB_vvsc","RHS_Mi24V_UPK23_vvsc","RHS_Mi24V_AT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8MTV3_UPK23_vvsc","RHS_Mi8MTV3_FAB_vvsc","RHS_Mi8AMT_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8AMTSh_UPK23_vvsc","RHS_Mi8AMTSh_FAB_vvsc","RHS_Ka52_vvsc","RHS_Ka52_UPK23_vvsc","rhs_ka60_c"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vvs_c", ["RHS_Mi24P_vvsc","RHS_Mi24P_CAS_vvsc","RHS_Mi24P_AT_vvsc","RHS_Mi24V_vvsc","RHS_Mi24V_FAB_vvsc","RHS_Mi24V_UPK23_vvsc","RHS_Mi24V_AT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8MTV3_UPK23_vvsc","RHS_Mi8MTV3_FAB_vvsc","RHS_Mi8AMT_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8AMTSh_UPK23_vvsc","RHS_Mi8AMTSh_FAB_vvsc","RHS_Ka52_vvsc","RHS_Ka52_UPK23_vvsc","rhs_ka60_c"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vvs_c", ["RHS_Mi24P_vvsc","RHS_Mi24P_CAS_vvsc","RHS_Mi24P_AT_vvsc","RHS_Mi24V_vvsc","RHS_Mi24V_FAB_vvsc","RHS_Mi24V_UPK23_vvsc","RHS_Mi24V_AT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8MTV3_UPK23_vvsc","RHS_Mi8MTV3_FAB_vvsc","RHS_Mi8AMT_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8AMTSh_UPK23_vvsc","RHS_Mi8AMTSh_FAB_vvsc","RHS_Ka52_vvsc","RHS_Ka52_UPK23_vvsc","rhs_ka60_c"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vvs_c", ["RHS_Mi24P_vvsc","RHS_Mi24P_CAS_vvsc","RHS_Mi24P_AT_vvsc","RHS_Mi24V_vvsc","RHS_Mi24V_FAB_vvsc","RHS_Mi24V_UPK23_vvsc","RHS_Mi24V_AT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8MTV3_UPK23_vvsc","RHS_Mi8MTV3_FAB_vvsc","RHS_Mi8AMT_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8AMTSh_UPK23_vvsc","RHS_Mi8AMTSh_FAB_vvsc","RHS_Ka52_vvsc","RHS_Ka52_UPK23_vvsc","rhs_ka60_c"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_aircraft
[ALIVE_factionDefaultSupports, "rhs_faction_vvs_c", ["RHS_Su25SM_vvsc","RHS_Su25SM_KH29_vvsc"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vvs_c", ["RHS_Su25SM_vvsc","RHS_Su25SM_KH29_vvsc"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vvs_c", ["RHS_Su25SM_vvsc","RHS_Su25SM_KH29_vvsc"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vvs_c", ["RHS_Su25SM_vvsc","RHS_Su25SM_KH29_vvsc"]] call ALIVE_fnc_hashSet;
// Autonomous
[ALIVE_factionDefaultSupports, "rhs_faction_vvs_c", ["rhs_pchela1t_vvsc"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_vvs_c", ["rhs_pchela1t_vvsc"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vvs_c", ["rhs_pchela1t_vvsc"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vvs_c", ["rhs_pchela1t_vvsc"]] call ALIVE_fnc_hashSet;
// rhs_faction_rva
rhs_faction_rva_mappings = [] call ALIVE_fnc_hashCreate;
rhs_faction_rva_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[rhs_faction_rva_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_rva_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhs_faction_rva_mappings, "FactionName", "rhs_faction_rva"] call ALIVE_fnc_hashSet;
[rhs_faction_rva_mappings, "GroupFactionName", "rhs_faction_rva"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings = [] call ALIVE_fnc_hashCreate;
[rhs_faction_rva_mappings, "GroupFactionTypes", rhs_faction_rva_typeMappings] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
rhs_faction_rva_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;
[rhs_faction_rva_mappings, "Groups", rhs_faction_rva_factionCustomGroups] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "rhs_faction_rva", rhs_faction_rva_mappings] call ALIVE_fnc_hashSet;
// rhs_vehclass_artillery
[ALIVE_factionDefaultSupports, "rhs_faction_rva", ["rhs_9k79","rhs_9k79_K","rhs_9k79_B"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_rva", ["rhs_9k79","rhs_9k79_K","rhs_9k79_B"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_rva", ["rhs_9k79","rhs_9k79_K","rhs_9k79_B"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_rva", ["rhs_9k79","rhs_9k79_K","rhs_9k79_B"]] call ALIVE_fnc_hashSet;
*/


// ------------------------------------------------------------------------------------------------------------------



// RHS Insurgents -----------------------------------------------------------------------------------------------------

// rhs_faction_insurgents

rhs_faction_insurgents_mappings = [] call ALIVE_fnc_hashCreate;

rhs_faction_insurgents_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhs_faction_insurgents_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhs_faction_insurgents_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhs_faction_insurgents_mappings, "FactionName", "rhs_faction_insurgents"] call ALIVE_fnc_hashSet;
[rhs_faction_insurgents_mappings, "GroupFactionName", "rhs_faction_insurgents"] call ALIVE_fnc_hashSet;

rhs_faction_insurgents_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhs_faction_insurgents_mappings, "GroupFactionTypes", rhs_faction_insurgents_typeMappings] call ALIVE_fnc_hashSet;


[rhs_faction_insurgents_factionCustomGroups, "Infantry", ["IRG_InfSquad","IRG_InfSquad_Weapons","IRG_InfTeam","IRG_InfTeam_AT","IRG_InfTeam_MG","IRG_InfSentry","IRG_ReconSentry","IRG_SniperTeam_M"]] call ALIVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups, "Motorized", ["rhs_group_chdkz_ural_chq","rhs_group_chdkz_ural_squad","rhs_group_chdkz_ural_squad_2mg","rhs_group_chdkz_ural_squad_sniper","rhs_group_chdkz_ural_squad_mg_sniper","rhs_group_chdkz_ural_squad_aa"]] call ALIVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups, "Mechanized", ["rhs_group_chdkz_btr60_chq","rhs_group_chdkz_btr60_squad","rhs_group_chdkz_btr60_squad_2mg","rhs_group_chdkz_btr60_squad_sniper","rhs_group_chdkz_btr60_squad_mg_sniper","rhs_group_chdkz_btr60_squad_aa","rhs_group_chdkz_btr70_chq","rhs_group_chdkz_btr70_squad","rhs_group_chdkz_btr70_squad_2mg","rhs_group_chdkz_btr70_squad_sniper","rhs_group_chdkz_btr70_squad_mg_sniper","rhs_group_chdkz_btr70_squad_aa","rhs_group_rus_ins_bmd1_chq","rhs_group_rus_ins_bmd1_squad","rhs_group_rus_ins_bmd1_squad_2mg","rhs_group_rus_ins_bmd1_squad_sniper","rhs_group_rus_ins_bmd1_squad_mg_sniper","rhs_group_rus_ins_bmd1_squad_aa","rhs_group_rus_ins_bmd2_chq","rhs_group_rus_ins_bmd2_squad","rhs_group_rus_ins_bmd2_squad_2mg","rhs_group_rus_ins_bmd2_squad_sniper","rhs_group_rus_ins_bmd2_squad_mg_sniper","rhs_group_rus_ins_bmd2_squad_aa"]] call ALIVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_ins_bm21","RHS_SPGSection_ins_bm21"]] call ALIVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups, "Armored", ["RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection"]] call ALIVE_fnc_hashSet;

[rhs_faction_insurgents_mappings, "Groups", rhs_faction_insurgents_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhs_faction_insurgents", rhs_faction_insurgents_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["RHS_UAZ_chdkz","rhs_uaz_open_chdkz","rhs_uaz_dshkm_chdkz","rhs_uaz_ags_chdkz","rhs_uaz_spg9_chdkz","rhs_ural_open_chdkz","rhs_ural_work_chdkz","rhs_ural_work_open_chdkz","RHS_BM21_chdkz","rhs_zsu234_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["RHS_UAZ_chdkz","rhs_uaz_open_chdkz","rhs_ural_chdkz","rhs_ural_open_chdkz","rhs_ural_work_chdkz","rhs_ural_work_open_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["RHS_Mi8amt_chdkz"]] call ALIVE_fnc_hashSet;

/*
// rhs_vehclass_car
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["RHS_UAZ_chdkz","rhs_uaz_open_chdkz","rhs_uaz_dshkm_chdkz","rhs_uaz_ags_chdkz","rhs_uaz_spg9_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["RHS_UAZ_chdkz","rhs_uaz_open_chdkz","rhs_uaz_dshkm_chdkz","rhs_uaz_ags_chdkz","rhs_uaz_spg9_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["RHS_UAZ_chdkz","rhs_uaz_open_chdkz","rhs_uaz_dshkm_chdkz","rhs_uaz_ags_chdkz","rhs_uaz_spg9_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["RHS_UAZ_chdkz","rhs_uaz_open_chdkz","rhs_uaz_dshkm_chdkz","rhs_uaz_ags_chdkz","rhs_uaz_spg9_chdkz"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_artillery
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_helicopter
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["RHS_Mi8amt_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["RHS_Mi8amt_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["RHS_Mi8amt_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["RHS_Mi8amt_chdkz"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_truck
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["rhs_ural_chdkz","rhs_ural_open_chdkz","rhs_ural_work_chdkz","rhs_ural_work_open_chdkz","RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["rhs_ural_chdkz","rhs_ural_open_chdkz","rhs_ural_work_chdkz","rhs_ural_work_open_chdkz","RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["rhs_ural_chdkz","rhs_ural_open_chdkz","rhs_ural_work_chdkz","rhs_ural_work_open_chdkz","RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["rhs_ural_chdkz","rhs_ural_open_chdkz","rhs_ural_work_chdkz","rhs_ural_work_open_chdkz","RHS_BM21_chdkz"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_aa
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["rhs_zsu234_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["rhs_zsu234_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["rhs_zsu234_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["rhs_zsu234_chdkz"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_ifv
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["rhs_bmd1_chdkz","rhs_bmd2_chdkz","rhs_bmp1_chdkz","rhs_bmp1p_chdkz","rhs_bmp1d_chdkz","rhs_bmp1k_chdkz","rhs_bmp2_chdkz","rhs_bmp2e_chdkz","rhs_bmp2k_chdkz","rhs_bmp2d_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["rhs_bmd1_chdkz","rhs_bmd2_chdkz","rhs_bmp1_chdkz","rhs_bmp1p_chdkz","rhs_bmp1d_chdkz","rhs_bmp1k_chdkz","rhs_bmp2_chdkz","rhs_bmp2e_chdkz","rhs_bmp2k_chdkz","rhs_bmp2d_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["rhs_bmd1_chdkz","rhs_bmd2_chdkz","rhs_bmp1_chdkz","rhs_bmp1p_chdkz","rhs_bmp1d_chdkz","rhs_bmp1k_chdkz","rhs_bmp2_chdkz","rhs_bmp2e_chdkz","rhs_bmp2k_chdkz","rhs_bmp2d_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["rhs_bmd1_chdkz","rhs_bmd2_chdkz","rhs_bmp1_chdkz","rhs_bmp1p_chdkz","rhs_bmp1d_chdkz","rhs_bmp1k_chdkz","rhs_bmp2_chdkz","rhs_bmp2e_chdkz","rhs_bmp2k_chdkz","rhs_bmp2d_chdkz"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_apc
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["rhs_btr60_chdkz","rhs_btr70_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["rhs_btr60_chdkz","rhs_btr70_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["rhs_btr60_chdkz","rhs_btr70_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["rhs_btr60_chdkz","rhs_btr70_chdkz"]] call ALIVE_fnc_hashSet;
// rhs_vehclass_tank
[ALIVE_factionDefaultSupports, "rhs_faction_insurgents", ["rhs_t72bb_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "rhs_faction_insurgents", ["rhs_t72bb_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_insurgents", ["rhs_t72bb_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_insurgents", ["rhs_t72bb_chdkz"]] call ALIVE_fnc_hashSet;
*/


// ---------------------------------------------------------------------------------------------------------------------


// IRON FRONT
// ---------------------------------------------------------------------------------------------------------------------


// LIB_RKKA

LIB_RKKA_mappings = [] call ALIVE_fnc_hashCreate;

LIB_RKKA_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_RKKA_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[LIB_RKKA_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[LIB_RKKA_mappings, "FactionName", "LIB_RKKA"] call ALIVE_fnc_hashSet;
[LIB_RKKA_mappings, "GroupFactionName", "LIB_RKKA"] call ALIVE_fnc_hashSet;

LIB_RKKA_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_RKKA_mappings, "GroupFactionTypes", LIB_RKKA_typeMappings] call ALIVE_fnc_hashSet;

[LIB_RKKA_factionCustomGroups, "Infantry", ["LIB_SOV_infantry_squad","LIB_SOV_smg_squad","LIB_SOV_AT_squad","LIB_SOV_scout_squad"]] call ALIVE_fnc_hashSet;
[LIB_RKKA_factionCustomGroups, "Motorized", ["LIB_SOV_motorized_infantry_squad","LIB_SOV_scout_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_RKKA_factionCustomGroups, "Mechanized", ["LIB_SOV_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_RKKA_factionCustomGroups, "Armored", ["LIB_SOV_JS2_43_Platoon","LIB_SOV_T34_76_Platoon","LIB_SOV_T34_85_Platoon","LIB_SOV_SU85_Platoon","LIB_SOV_M4A2_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_RKKA_factionCustomGroups, "Air", ["LIB_SOV_P39_Group","LIB_SOV_Pe2_Group"]] call ALIVE_fnc_hashSet;

[LIB_RKKA_mappings, "Groups", LIB_RKKA_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_RKKA", LIB_RKKA_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_RKKA", ["lib_maxim_m30_base","lib_maxim_m30_trench","lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel","SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3","lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["LIB_BasicAmmunitionBox_SU","LIB_Mine_Ammo_Box_Su","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;

/*
// lib_static_weapons
[ALIVE_factionDefaultSupports, "LIB_RKKA", ["lib_maxim_m30_base","lib_maxim_m30_trench"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["lib_maxim_m30_base","lib_maxim_m30_trench"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA", ["lib_maxim_m30_base","lib_maxim_m30_trench"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_RKKA", ["lib_maxim_m30_base","lib_maxim_m30_trench"]] call ALIVE_fnc_hashSet;

// Support
[ALIVE_factionDefaultSupports, "LIB_RKKA", ["lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA", ["lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_RKKA", ["lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel"]] call ALIVE_fnc_hashSet;

// Car
[ALIVE_factionDefaultSupports, "LIB_RKKA", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_RKKA", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;

// Static
[ALIVE_factionDefaultSupports, "LIB_RKKA", ["SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA", ["SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_RKKA", ["SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3"]] call ALIVE_fnc_hashSet;

// Ammo
[ALIVE_factionDefaultSupports, "LIB_RKKA", ["LIB_Mine_Ammo_Box_Su"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["LIB_Mine_Ammo_Box_Su"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA", ["LIB_Mine_Ammo_Box_Su"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_RKKA", ["LIB_Mine_Ammo_Box_Su"]] call ALIVE_fnc_hashSet;
*/


// LIB_USSR_TANK_TROOPS

LIB_USSR_TANK_TROOPS_mappings = [] call ALIVE_fnc_hashCreate;

LIB_USSR_TANK_TROOPS_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_USSR_TANK_TROOPS_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[LIB_USSR_TANK_TROOPS_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[LIB_USSR_TANK_TROOPS_mappings, "FactionName", "LIB_USSR_TANK_TROOPS"] call ALIVE_fnc_hashSet;
[LIB_USSR_TANK_TROOPS_mappings, "GroupFactionName", "LIB_USSR_TANK_TROOPS"] call ALIVE_fnc_hashSet;

LIB_USSR_TANK_TROOPS_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_USSR_TANK_TROOPS_mappings, "GroupFactionTypes", LIB_USSR_TANK_TROOPS_typeMappings] call ALIVE_fnc_hashSet;

[LIB_USSR_TANK_TROOPS_factionCustomGroups, "Infantry", ["LIB_SOV_infantry_squad","LIB_SOV_smg_squad","LIB_SOV_AT_squad","LIB_SOV_scout_squad"]] call ALIVE_fnc_hashSet;
[LIB_USSR_TANK_TROOPS_factionCustomGroups, "Motorized", ["LIB_SOV_motorized_infantry_squad","LIB_SOV_scout_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_USSR_TANK_TROOPS_factionCustomGroups, "Mechanized", ["LIB_SOV_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_USSR_TANK_TROOPS_factionCustomGroups, "Armored", ["LIB_SOV_JS2_43_Platoon","LIB_SOV_T34_76_Platoon","LIB_SOV_T34_85_Platoon","LIB_SOV_SU85_Platoon","LIB_SOV_M4A2_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_USSR_TANK_TROOPS_factionCustomGroups, "Air", ["LIB_SOV_P39_Group","LIB_SOV_Pe2_Group"]] call ALIVE_fnc_hashSet;

[LIB_USSR_TANK_TROOPS_mappings, "Groups", LIB_USSR_TANK_TROOPS_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_USSR_TANK_TROOPS", LIB_USSR_TANK_TROOPS_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_USSR_TANK_TROOPS", ["lib_maxim_m30_base","lib_maxim_m30_trench","lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel","SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3","lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_USSR_TANK_TROOPS", ["LIB_BasicAmmunitionBox_SU","LIB_Mine_Ammo_Box_Su","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_USSR_TANK_TROOPS", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;

/*
// LIB_Heavy_Tanks
[ALIVE_factionDefaultSupports, "LIB_USSR_TANK_TROOPS", ["LIB_JS2_43"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_USSR_TANK_TROOPS", ["LIB_JS2_43"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_USSR_TANK_TROOPS", ["LIB_JS2_43"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_USSR_TANK_TROOPS", ["LIB_JS2_43"]] call ALIVE_fnc_hashSet;

// LIB_Medium_Tanks
[ALIVE_factionDefaultSupports, "LIB_USSR_TANK_TROOPS", ["LIB_t34_76","LIB_t34_85","LIB_SU85","LIB_M4A2_SOV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_USSR_TANK_TROOPS", ["LIB_t34_76","LIB_t34_85","LIB_SU85","LIB_M4A2_SOV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_USSR_TANK_TROOPS", ["LIB_t34_76","LIB_t34_85","LIB_SU85","LIB_M4A2_SOV"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_USSR_TANK_TROOPS", ["LIB_t34_76","LIB_t34_85","LIB_SU85","LIB_M4A2_SOV"]] call ALIVE_fnc_hashSet;
*/


// LIB_USSR_AIRFORCE

LIB_USSR_AIRFORCE_mappings = [] call ALIVE_fnc_hashCreate;

LIB_USSR_AIRFORCE_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_USSR_AIRFORCE_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[LIB_USSR_AIRFORCE_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[LIB_USSR_AIRFORCE_mappings, "FactionName", "LIB_USSR_AIRFORCE"] call ALIVE_fnc_hashSet;
[LIB_USSR_AIRFORCE_mappings, "GroupFactionName", "LIB_USSR_AIRFORCE"] call ALIVE_fnc_hashSet;

LIB_USSR_AIRFORCE_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_USSR_AIRFORCE_mappings, "GroupFactionTypes", LIB_USSR_AIRFORCE_typeMappings] call ALIVE_fnc_hashSet;

[LIB_USSR_AIRFORCE_factionCustomGroups, "Infantry", ["LIB_SOV_infantry_squad","LIB_SOV_smg_squad","LIB_SOV_AT_squad","LIB_SOV_scout_squad"]] call ALIVE_fnc_hashSet;
[LIB_USSR_AIRFORCE_factionCustomGroups, "Motorized", ["LIB_SOV_motorized_infantry_squad","LIB_SOV_scout_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_USSR_AIRFORCE_factionCustomGroups, "Mechanized", ["LIB_SOV_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_USSR_AIRFORCE_factionCustomGroups, "Armored", ["LIB_SOV_JS2_43_Platoon","LIB_SOV_T34_76_Platoon","LIB_SOV_T34_85_Platoon","LIB_SOV_SU85_Platoon","LIB_SOV_M4A2_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_USSR_AIRFORCE_factionCustomGroups, "Air", ["LIB_SOV_P39_Group","LIB_SOV_Pe2_Group"]] call ALIVE_fnc_hashSet;

[LIB_USSR_AIRFORCE_mappings, "Groups", LIB_USSR_AIRFORCE_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_USSR_AIRFORCE", LIB_USSR_AIRFORCE_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_USSR_AIRFORCE", ["lib_maxim_m30_base","lib_maxim_m30_trench","lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel","SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3","lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_USSR_AIRFORCE", ["LIB_BasicAmmunitionBox_SU","LIB_Mine_Ammo_Box_Su","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_USSR_AIRFORCE", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;

/*
// Air
[ALIVE_factionDefaultSupports, "LIB_USSR_AIRFORCE", ["LIB_P39","LIB_Pe2"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_USSR_AIRFORCE", ["LIB_P39","LIB_Pe2"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_USSR_AIRFORCE", ["LIB_P39","LIB_Pe2"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_USSR_AIRFORCE", ["LIB_P39","LIB_Pe2"]] call ALIVE_fnc_hashSet;
*/




// LNRD_Luft

LNRD_Luft_mappings = [] call ALIVE_fnc_hashCreate;

LNRD_Luft_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LNRD_Luft_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[LNRD_Luft_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[LNRD_Luft_mappings, "FactionName", "LNRD_Luft"] call ALIVE_fnc_hashSet;
[LNRD_Luft_mappings, "GroupFactionName", "LNRD_Luft"] call ALIVE_fnc_hashSet;

LNRD_Luft_typeMappings = [] call ALIVE_fnc_hashCreate;

[LNRD_Luft_mappings, "GroupFactionTypes", LNRD_Luft_typeMappings] call ALIVE_fnc_hashSet;

[LNRD_Luft_factionCustomGroups, "Infantry", ["LIB_GER_infantry_squad","LIB_GER_AT_squad","LIB_GER_scout_squad","SG_GER_infantry_squad","SG_GER_AT_squad","LNRD_Luft_AT_squad","LNRD_Luft_infantry_squad"]] call ALIVE_fnc_hashSet;
[LNRD_Luft_factionCustomGroups, "Motorized", ["LIB_GER_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LNRD_Luft_factionCustomGroups, "Mechanized", ["LIB_GER_mechanized_infantry_squad","LIB_GER_scout_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LNRD_Luft_factionCustomGroups, "Armored", ["LIB_GER_PzKpfwIV_H_Platoon","LIB_GER_PzKpfwV_Platoon","LIB_GER_StuG_III_G_Platoon","LIB_GER_PzKpfwVI_B_Platoon","LIB_GER_PzKpfwVI_E_Platoon"]] call ALIVE_fnc_hashSet;
[LNRD_Luft_factionCustomGroups, "Air", ["LIB_GER_fw190f8_Group","LIB_GER_Ju87_Group"]] call ALIVE_fnc_hashSet;

[LNRD_Luft_mappings, "Groups", LNRD_Luft_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LNRD_Luft", LNRD_Luft_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LNRD_Luft", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LNRD_Luft", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LNRD_Luft", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;


// SG_STURM

SG_STURM_mappings = [] call ALIVE_fnc_hashCreate;

SG_STURM_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[SG_STURM_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[SG_STURM_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[SG_STURM_mappings, "FactionName", "SG_STURM"] call ALIVE_fnc_hashSet;
[SG_STURM_mappings, "GroupFactionName", "SG_STURM"] call ALIVE_fnc_hashSet;

SG_STURM_typeMappings = [] call ALIVE_fnc_hashCreate;

[SG_STURM_mappings, "GroupFactionTypes", SG_STURM_typeMappings] call ALIVE_fnc_hashSet;

[SG_STURM_factionCustomGroups, "Infantry", ["LIB_GER_infantry_squad","LIB_GER_AT_squad","LIB_GER_scout_squad","SG_GER_infantry_squad","SG_GER_AT_squad","LNRD_Luft_AT_squad","LNRD_Luft_infantry_squad"]] call ALIVE_fnc_hashSet;
[SG_STURM_factionCustomGroups, "Motorized", ["LIB_GER_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[SG_STURM_factionCustomGroups, "Mechanized", ["LIB_GER_mechanized_infantry_squad","LIB_GER_scout_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[SG_STURM_factionCustomGroups, "Armored", ["LIB_GER_PzKpfwIV_H_Platoon","LIB_GER_PzKpfwV_Platoon","LIB_GER_StuG_III_G_Platoon","LIB_GER_PzKpfwVI_B_Platoon","LIB_GER_PzKpfwVI_E_Platoon"]] call ALIVE_fnc_hashSet;
[SG_STURM_factionCustomGroups, "Air", ["LIB_GER_fw190f8_Group","LIB_GER_Ju87_Group"]] call ALIVE_fnc_hashSet;

[SG_STURM_mappings, "Groups", SG_STURM_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "SG_STURM", SG_STURM_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "SG_STURM", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "SG_STURM", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SG_STURM", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;


// LIB_WEHRMACHT

LIB_WEHRMACHT_mappings = [] call ALIVE_fnc_hashCreate;

LIB_WEHRMACHT_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_WEHRMACHT_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[LIB_WEHRMACHT_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[LIB_WEHRMACHT_mappings, "FactionName", "LIB_WEHRMACHT"] call ALIVE_fnc_hashSet;
[LIB_WEHRMACHT_mappings, "GroupFactionName", "LIB_WEHRMACHT"] call ALIVE_fnc_hashSet;

LIB_WEHRMACHT_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_WEHRMACHT_mappings, "GroupFactionTypes", LIB_WEHRMACHT_typeMappings] call ALIVE_fnc_hashSet;

[LIB_WEHRMACHT_factionCustomGroups, "Infantry", ["LIB_GER_infantry_squad","LIB_GER_AT_squad","LIB_GER_scout_squad","SG_GER_infantry_squad","SG_GER_AT_squad","LNRD_Luft_AT_squad","LNRD_Luft_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_WEHRMACHT_factionCustomGroups, "Motorized", ["LIB_GER_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_WEHRMACHT_factionCustomGroups, "Mechanized", ["LIB_GER_mechanized_infantry_squad","LIB_GER_scout_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_WEHRMACHT_factionCustomGroups, "Armored", ["LIB_GER_PzKpfwIV_H_Platoon","LIB_GER_PzKpfwV_Platoon","LIB_GER_StuG_III_G_Platoon","LIB_GER_PzKpfwVI_B_Platoon","LIB_GER_PzKpfwVI_E_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_WEHRMACHT_factionCustomGroups, "Air", ["LIB_GER_fw190f8_Group","LIB_GER_Ju87_Group"]] call ALIVE_fnc_hashSet;

[LIB_WEHRMACHT_mappings, "Groups", LIB_WEHRMACHT_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_WEHRMACHT", LIB_WEHRMACHT_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

/*
// lib_static_weapons
[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_WEHRMACHT", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low"]] call ALIVE_fnc_hashSet;

// Car
[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_WEHRMACHT", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

// Static
[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_WEHRMACHT", ["SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40"]] call ALIVE_fnc_hashSet;

// Support
[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_WEHRMACHT", ["LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;

// Ammo
[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["LIB_Mine_Ammo_Box_Ger"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["LIB_Mine_Ammo_Box_Ger"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["LIB_Mine_Ammo_Box_Ger"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_WEHRMACHT", ["LIB_Mine_Ammo_Box_Ger"]] call ALIVE_fnc_hashSet;
*/


// LIB_PANZERWAFFE

LIB_PANZERWAFFE_mappings = [] call ALIVE_fnc_hashCreate;

LIB_PANZERWAFFE_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_PANZERWAFFE_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[LIB_PANZERWAFFE_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[LIB_PANZERWAFFE_mappings, "FactionName", "LIB_PANZERWAFFE"] call ALIVE_fnc_hashSet;
[LIB_PANZERWAFFE_mappings, "GroupFactionName", "LIB_PANZERWAFFE"] call ALIVE_fnc_hashSet;

LIB_PANZERWAFFE_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_PANZERWAFFE_mappings, "GroupFactionTypes", LIB_PANZERWAFFE_typeMappings] call ALIVE_fnc_hashSet;

[LIB_PANZERWAFFE_factionCustomGroups, "Infantry", ["LIB_GER_infantry_squad","LIB_GER_AT_squad","LIB_GER_scout_squad","SG_GER_infantry_squad","SG_GER_AT_squad","LNRD_Luft_AT_squad","LNRD_Luft_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_PANZERWAFFE_factionCustomGroups, "Motorized", ["LIB_GER_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_PANZERWAFFE_factionCustomGroups, "Mechanized", ["LIB_GER_mechanized_infantry_squad","LIB_GER_scout_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_PANZERWAFFE_factionCustomGroups, "Armored", ["LIB_GER_PzKpfwIV_H_Platoon","LIB_GER_PzKpfwV_Platoon","LIB_GER_StuG_III_G_Platoon","LIB_GER_PzKpfwVI_B_Platoon","LIB_GER_PzKpfwVI_E_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_PANZERWAFFE_factionCustomGroups, "Air", ["LIB_GER_fw190f8_Group","LIB_GER_Ju87_Group"]] call ALIVE_fnc_hashSet;

[LIB_PANZERWAFFE_mappings, "Groups", LIB_PANZERWAFFE_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_PANZERWAFFE", LIB_PANZERWAFFE_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_PANZERWAFFE", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_PANZERWAFFE", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_PANZERWAFFE", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

/*
// LIB_Medium_Tanks
[ALIVE_factionDefaultSupports, "LIB_PANZERWAFFE", ["LIB_PzKpfwIV_H","LIB_PzKpfwV","LIB_StuG_III_G","LIB_StuG_III_G_WS"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_PANZERWAFFE", ["LIB_PzKpfwIV_H","LIB_PzKpfwV","LIB_StuG_III_G","LIB_StuG_III_G_WS"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_PANZERWAFFE", ["LIB_PzKpfwIV_H","LIB_PzKpfwV","LIB_StuG_III_G","LIB_StuG_III_G_WS"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_PANZERWAFFE", ["LIB_PzKpfwIV_H","LIB_PzKpfwV","LIB_StuG_III_G","LIB_StuG_III_G_WS"]] call ALIVE_fnc_hashSet;

// LIB_Heavy_Tanks
[ALIVE_factionDefaultSupports, "LIB_PANZERWAFFE", ["LIB_PzKpfwVI_B","LIB_PzKpfwVI_B_camo","LIB_PzKpfwVI_E"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_PANZERWAFFE", ["LIB_PzKpfwVI_B","LIB_PzKpfwVI_B_camo","LIB_PzKpfwVI_E"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_PANZERWAFFE", ["LIB_PzKpfwVI_B","LIB_PzKpfwVI_B_camo","LIB_PzKpfwVI_E"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_PANZERWAFFE", ["LIB_PzKpfwVI_B","LIB_PzKpfwVI_B_camo","LIB_PzKpfwVI_E"]] call ALIVE_fnc_hashSet;
*/


// LIB_LUFTWAFFE

LIB_LUFTWAFFE_mappings = [] call ALIVE_fnc_hashCreate;

LIB_LUFTWAFFE_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_LUFTWAFFE_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[LIB_LUFTWAFFE_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[LIB_LUFTWAFFE_mappings, "FactionName", "LIB_LUFTWAFFE"] call ALIVE_fnc_hashSet;
[LIB_LUFTWAFFE_mappings, "GroupFactionName", "LIB_LUFTWAFFE"] call ALIVE_fnc_hashSet;

LIB_LUFTWAFFE_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_LUFTWAFFE_mappings, "GroupFactionTypes", LIB_LUFTWAFFE_typeMappings] call ALIVE_fnc_hashSet;

[LIB_LUFTWAFFE_factionCustomGroups, "Infantry", ["LIB_GER_infantry_squad","LIB_GER_AT_squad","LIB_GER_scout_squad"]] call ALIVE_fnc_hashSet;
[LIB_LUFTWAFFE_factionCustomGroups, "Motorized", ["LIB_GER_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_LUFTWAFFE_factionCustomGroups, "Mechanized", ["LIB_GER_mechanized_infantry_squad","LIB_GER_scout_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_LUFTWAFFE_factionCustomGroups, "Armored", ["LIB_GER_PzKpfwIV_H_Platoon","LIB_GER_PzKpfwV_Platoon","LIB_GER_StuG_III_G_Platoon","LIB_GER_PzKpfwVI_B_Platoon","LIB_GER_PzKpfwVI_E_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_LUFTWAFFE_factionCustomGroups, "Air", ["LIB_GER_fw190f8_Group","LIB_GER_Ju87_Group"]] call ALIVE_fnc_hashSet;

[LIB_LUFTWAFFE_mappings, "Groups", LIB_LUFTWAFFE_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_LUFTWAFFE", LIB_LUFTWAFFE_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_LUFTWAFFE", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_LUFTWAFFE", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_LUFTWAFFE", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

/*
// Air
[ALIVE_factionDefaultSupports, "LIB_LUFTWAFFE", ["LIB_FW190F8","LIB_Ju87"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_LUFTWAFFE", ["LIB_FW190F8","LIB_Ju87"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_LUFTWAFFE", ["LIB_FW190F8","LIB_Ju87"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_LUFTWAFFE", ["LIB_FW190F8","LIB_Ju87"]] call ALIVE_fnc_hashSet;
*/



// LIB_GUER

LIB_GUER_mappings = [] call ALIVE_fnc_hashCreate;

LIB_GUER_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_GUER_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[LIB_GUER_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[LIB_GUER_mappings, "FactionName", "LIB_GUER"] call ALIVE_fnc_hashSet;
[LIB_GUER_mappings, "GroupFactionName", "LIB_GUER"] call ALIVE_fnc_hashSet;

LIB_GUER_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_GUER_mappings, "GroupFactionTypes", LIB_GUER_typeMappings] call ALIVE_fnc_hashSet;

[LIB_GUER_mappings, "Infantry", ["Lib_GUER_infantry_squad"]] call ALIVE_fnc_hashSet;

[LIB_GUER_mappings, "Groups", LIB_GUER_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_GUER", LIB_GUER_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_GUER", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_GUER", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_GUER", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;


// LIB_US_ARMY

LIB_US_ARMY_mappings = [] call ALIVE_fnc_hashCreate;

LIB_US_ARMY_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_US_ARMY_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[LIB_US_ARMY_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[LIB_US_ARMY_mappings, "FactionName", "LIB_US_ARMY"] call ALIVE_fnc_hashSet;
[LIB_US_ARMY_mappings, "GroupFactionName", "LIB_US_ARMY"] call ALIVE_fnc_hashSet;

LIB_US_ARMY_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_US_ARMY_mappings, "GroupFactionTypes", LIB_US_ARMY_typeMappings] call ALIVE_fnc_hashSet;

[LIB_US_ARMY_factionCustomGroups, "Infantry", ["LIB_US_AT_squad","LIB_US_infantry_squad","LIB_US_scout_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_ARMY_factionCustomGroups, "Motorized", ["LIB_US_motorized_infantry_squad","LIB_US_scout_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_ARMY_factionCustomGroups, "Mechanized", ["LIB_US_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_ARMY_factionCustomGroups, "Armored", ["LIB_M4A3_75_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_US_ARMY_factionCustomGroups, "Air", ["LIB_US_P47_Group"]] call ALIVE_fnc_hashSet;

[LIB_US_ARMY_mappings, "Groups", LIB_US_ARMY_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_US_ARMY", LIB_US_ARMY_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_ARMY", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;


/*
// Car
[ALIVE_factionDefaultSupports, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;

// Support
[ALIVE_factionDefaultSupports, "LIB_US_ARMY", ["LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_ARMY", ["LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_ARMY", ["LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_ARMY", ["LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;

// Ship
[ALIVE_factionDefaultSupports, "LIB_US_ARMY", ["LIB_LCVP"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_ARMY", ["LIB_LCVP"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_ARMY", ["LIB_LCVP"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_ARMY", ["LIB_LCVP"]] call ALIVE_fnc_hashSet;
*/


// LIB_US_TANK_TROOPS

LIB_US_TANK_TROOPS_mappings = [] call ALIVE_fnc_hashCreate;

LIB_US_TANK_TROOPS_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_US_TANK_TROOPS_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[LIB_US_TANK_TROOPS_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[LIB_US_TANK_TROOPS_mappings, "FactionName", "LIB_US_TANK_TROOPS"] call ALIVE_fnc_hashSet;
[LIB_US_TANK_TROOPS_mappings, "GroupFactionName", "LIB_US_TANK_TROOPS"] call ALIVE_fnc_hashSet;

LIB_US_TANK_TROOPS_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_US_TANK_TROOPS_mappings, "GroupFactionTypes", LIB_US_TANK_TROOPS_typeMappings] call ALIVE_fnc_hashSet;

[LIB_US_TANK_TROOPS_factionCustomGroups, "Infantry", ["LIB_US_AT_squad","LIB_US_infantry_squad","LIB_US_scout_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_TANK_TROOPS_factionCustomGroups, "Motorized", ["LIB_US_motorized_infantry_squad","LIB_US_scout_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_TANK_TROOPS_factionCustomGroups, "Mechanized", ["LIB_US_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_TANK_TROOPS_factionCustomGroups, "Armored", ["LIB_M4A3_75_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_US_TANK_TROOPS_factionCustomGroups, "Air", ["LIB_US_P47_Group"]] call ALIVE_fnc_hashSet;

[LIB_US_TANK_TROOPS_mappings, "Groups", LIB_US_TANK_TROOPS_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_US_TANK_TROOPS", LIB_US_TANK_TROOPS_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_US_TANK_TROOPS", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_TANK_TROOPS", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_TANK_TROOPS", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;

/*
// LIB_Medium_Tanks
[ALIVE_factionDefaultSupports, "LIB_US_TANK_TROOPS", ["LIB_M4A3_75","LIB_M4A3_75_Tubes"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_TANK_TROOPS", ["LIB_M4A3_75","LIB_M4A3_75_Tubes"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_TANK_TROOPS", ["LIB_M4A3_75","LIB_M4A3_75_Tubes"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_TANK_TROOPS", ["LIB_M4A3_75","LIB_M4A3_75_Tubes"]] call ALIVE_fnc_hashSet;
*/


// LIB_US_AIRFORCE

LIB_US_AIRFORCE_mappings = [] call ALIVE_fnc_hashCreate;

LIB_US_AIRFORCE_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[LIB_US_AIRFORCE_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[LIB_US_AIRFORCE_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[LIB_US_AIRFORCE_mappings, "FactionName", "LIB_US_AIRFORCE"] call ALIVE_fnc_hashSet;
[LIB_US_AIRFORCE_mappings, "GroupFactionName", "LIB_US_AIRFORCE"] call ALIVE_fnc_hashSet;

LIB_US_AIRFORCE_typeMappings = [] call ALIVE_fnc_hashCreate;

[LIB_US_AIRFORCE_mappings, "GroupFactionTypes", LIB_US_AIRFORCE_typeMappings] call ALIVE_fnc_hashSet;

[LIB_US_AIRFORCE_factionCustomGroups, "Infantry", ["LIB_US_AT_squad","LIB_US_infantry_squad","LIB_US_scout_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_AIRFORCE_factionCustomGroups, "Motorized", ["LIB_US_motorized_infantry_squad","LIB_US_scout_motorized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_AIRFORCE_factionCustomGroups, "Mechanized", ["LIB_US_mechanized_infantry_squad"]] call ALIVE_fnc_hashSet;
[LIB_US_AIRFORCE_factionCustomGroups, "Armored", ["LIB_M4A3_75_Platoon"]] call ALIVE_fnc_hashSet;
[LIB_US_AIRFORCE_factionCustomGroups, "Air", ["LIB_US_P47_Group"]] call ALIVE_fnc_hashSet;

[LIB_US_AIRFORCE_mappings, "Groups", LIB_US_AIRFORCE_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "LIB_US_AIRFORCE", LIB_US_AIRFORCE_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "LIB_US_AIRFORCE", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_AIRFORCE", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_AIRFORCE", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;

/*
// Air
[ALIVE_factionDefaultSupports, "LIB_US_AIRFORCE", ["LIB_P47"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_AIRFORCE", ["LIB_P47"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_AIRFORCE", ["LIB_P47"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "LIB_US_AIRFORCE", ["LIB_P47"]] call ALIVE_fnc_hashSet;
*/

// ---------------------------------------------------------------------------------------------------------------------

ALiVE_STATIC_DATA_LOADED = true;

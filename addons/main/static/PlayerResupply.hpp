/*
 * Player resupply
 */

if (isnil "ALiVE_PR_CUSTOM_BLACKLIST") then {ALiVE_PR_CUSTOM_BLACKLIST = []};
if (isnil "ALiVE_PR_CUSTOM_WHITELIST") then {ALiVE_PR_CUSTOM_WHITELIST = []};

ALiVE_PR_BLACKLIST = ALiVE_PR_CUSTOM_BLACKLIST + [
    // empty for now
];

ALiVE_PR_WHITELIST = ALiVE_PR_CUSTOM_WHITELIST + [
    // empty for now
];

ALIVE_globalDefaultResupplyVehicleOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyVehicleOptions, "PR_AIRDROP", [["<< Back","Car","Ship"],["<< Back","Car","Ship"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyVehicleOptions, "PR_HELI_INSERT", [["<< Back","Air","Car","Ship"],["<< Back","Air","Car","Ship"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyVehicleOptions, "PR_STANDARD", [["<< Back","Armored","Car"],["<< Back","Armored","Car"]]] call ALIVE_fnc_hashSet;

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


// THE FOLLOWING IS A BLACKLIST

ALIVE_globalDefaultResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyGroupOptions, "PR_AIRDROP", ["Armored","Mechanized"]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyGroupOptions, "PR_HELI_INSERT", ["Armored","Mechanized"]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyGroupOptions, "PR_STANDARD", []] call ALIVE_fnc_hashSet;

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

// OVER
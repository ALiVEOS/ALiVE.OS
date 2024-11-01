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

// APEX
[ALIVE_factionDefaultResupplyVehicleOptions, "OPF_T_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "IND_C_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "BLU_T_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "BLU_CTRG_F", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "Gendarmerie", ALIVE_globalDefaultResupplyVehicleOptions] call ALIVE_fnc_hashSet;


ALIVE_globalDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyDefenceStoreOptions, "PR_AIRDROP", [["<< Back","Static","Fortifications","Tents","Military"],["<< Back","Static","Fortifications","Tents","Structures_Military"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyDefenceStoreOptions, "PR_HELI_INSERT", [["<< Back","Static","Fortifications","Tents","Military"],["<< Back","Static","Fortifications","Tents","Structures_Military"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyDefenceStoreOptions, "PR_STANDARD", [["<< Back","Static","Fortifications","Tents","Military"],["<< Back","Static","Fortifications","Tents","Structures_Military"]]] call ALIVE_fnc_hashSet;


// VN - CDLC S.O.G Prairie Fire 1.3
ALIVE_VNDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_VNDefaultResupplyDefenceStoreOptions, "PR_AIRDROP", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;
[ALIVE_VNDefaultResupplyDefenceStoreOptions, "PR_HELI_INSERT", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;
[ALIVE_VNDefaultResupplyDefenceStoreOptions, "PR_STANDARD", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;

// SPE - CDLC Spearhead 1944 1.1
ALIVE_SPEDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_SPEDefaultResupplyDefenceStoreOptions, "PR_STANDARD", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;

// GM - CDLC Global Mobilization 1.5
ALIVE_GMDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_GMDefaultResupplyDefenceStoreOptions, "PR_AIRDROP", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;
[ALIVE_GMDefaultResupplyDefenceStoreOptions, "PR_HELI_INSERT", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;
[ALIVE_GMDefaultResupplyDefenceStoreOptions, "PR_STANDARD", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;



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

// APEX
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "OPF_T_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "IND_C_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "BLU_T_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "BLU_CTRG_F", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "Gendarmerie", ALIVE_globalDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;

// VN - CDLC S.O.G Prairie Fire 1.3
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "O_PAVN", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "O_VC", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "O_PL", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "O_CAM", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "I_ARVN", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "I_LAO", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "I_CAM", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "B_MACV", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "B_AUS", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "B_NZ", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "B_ROK", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "B_CIA", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "C_VIET", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;

// SPE - CDLC Spearhead 1944 1.1
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "SPE_STURM", ALIVE_SPEDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "SPE_WEHRMACHT", ALIVE_SPEDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "SPE_US_ARMY", ALIVE_SPEDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "SPE_FR_ARMY", ALIVE_SPEDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "SPE_FFI", ALIVE_SPEDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "SPE_MILICE", ALIVE_SPEDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;



// GM - CDLC Global Mobilization 1.5
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_gc_army", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_gc_army_win", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_gc_army_bgs", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_pl_army", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_pl_army_win", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_ge_army", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_ge_army_win", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_ge_army_bgs", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_dk_army", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_dk_army_win", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "gm_xx_army", ALIVE_GMDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;


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

// APEX
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "OPF_T_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "IND_C_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "BLU_T_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "BLU_CTRG_F", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "Gendarmerie", ALIVE_globalDefaultResupplyCombatSuppliesOptions] call ALIVE_fnc_hashSet;

ALIVE_globalDefaultResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalDefaultResupplyIndividualOptions, "PR_AIRDROP", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyIndividualOptions, "PR_HELI_INSERT", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalDefaultResupplyIndividualOptions, "PR_STANDARD", [["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"],["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;

// VN - CDLC S.O.G Prairie Fire 1.3
ALIVE_globalVNResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalVNResupplyIndividualOptions, "PR_AIRDROP", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalVNResupplyIndividualOptions, "PR_HELI_INSERT", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalVNResupplyIndividualOptions, "PR_STANDARD", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;

// SPE - CDLC Spearhead 1944 1.1
ALIVE_globalSPEResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalSPEResupplyIndividualOptions, "PR_STANDARD", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;

// GM - CDLC Global Mobilization 1.5
ALIVE_globalGMResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalGMResupplyIndividualOptions, "PR_AIRDROP", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalGMResupplyIndividualOptions, "PR_HELI_INSERT", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalGMResupplyIndividualOptions, "PR_STANDARD", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;



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

// APEX
[ALIVE_factionDefaultResupplyIndividualOptions, "OPF_T_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "IND_C_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "BLU_T_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "BLU_CTRG_F", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "Gendarmerie", ALIVE_globalDefaultResupplyIndividualOptions] call ALIVE_fnc_hashSet;

// VN - CDLC S.O.G Prairie Fire 1.3
[ALIVE_factionDefaultResupplyIndividualOptions, "O_PAVN", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "O_VC", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "O_PL", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "O_CAM", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "I_ARVN", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "I_LAO", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "I_CAM", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_MACV", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_AUS", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_NZ", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_ROK", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_CIA", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "C_VIET", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;

// SPE - CDLC Spearhead 1944 1.1
[ALIVE_factionDefaultResupplyIndividualOptions, "SPE_STURM", ALIVE_globalSPEResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "SPE_WEHRMACHT", ALIVE_globalSPEResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "SPE_US_ARMY", ALIVE_globalSPEResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "SPE_FR_ARMY", ALIVE_globalSPEResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "SPE_FFI", ALIVE_globalSPEResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "SPE_MILICE", ALIVE_globalSPEResupplyIndividualOptions] call ALIVE_fnc_hashSet;

// GM - CDLC Global Mobilization 1.5
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_gc_army", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_gc_army_win", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_gc_army_bgs", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_pl_army", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_pl_army_win", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_ge_army", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_ge_army_win", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_ge_army_bgs", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_dk_army", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_dk_army_win", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "gm_xx_army", ALIVE_globalGMResupplyIndividualOptions] call ALIVE_fnc_hashSet;


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

//APEX
[ALIVE_factionDefaultResupplyGroupOptions, "OPF_T_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "IND_C_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "BLU_T_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "BLU_CTRG_F", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "Gendarmerie", ALIVE_globalDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;

// VN - CDLC S.O.G Prairie Fire 1.3

ALIVE_VNDefaultResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_VNDefaultResupplyGroupOptions, "PR_AIRDROP", [
"Armored",
"Mechanized",
"vn_o_group_mech_kr_75",
"vn_o_group_motor_kr_75",
"vn_o_group_boats_kr_70",
"vn_o_group_motor_vcmf",
"vn_o_group_mech_vcmf",
"vn_o_group_armor_vcmf",
"vn_o_group_motor_nva",
"vn_o_group_boats_vcmf",
"vn_o_group_mech_nva",
"vn_o_group_armor_nva",
"vn_o_group_motor_nva_65",
"vn_o_group_mech_nva_65",
"vn_o_group_armor_nva_65",
"vn_o_group_men_nva_navy",
"vn_o_group_men_vpaf",
"vn_o_group_motor_nvam",
"vn_o_group_mech_nvam",
"vn_o_group_air_army",
"vn_o_group_motor_pl",
"vn_o_group_mech_pl",
"vn_o_group_armor_pl",
"vn_i_group_men_aircrew",
"vn_i_group_motor_army",
"vn_i_group_mech_army",
"vn_i_group_motor_marines",
"vn_i_group_mech_marines",
"vn_i_group_armor_army",
"vn_i_group_air_army",
"vn_i_group_motor_rla",
"vn_i_group_mech_rla",
"vn_i_group_air_fank_71",
"vn_i_group_boats_fank_71",
"vn_i_group_men_aircrew",
"vn_i_group_mech_fank_70",
"vn_i_group_mech_fank_71",
"vn_i_group_motor_fank_70",
"vn_i_group_motor_fank_71",
"vn_b_group_motor_army",
"vn_b_group_motor_usmc",
"vn_b_group_mech_army",
"vn_b_group_mech_usmc",
"vn_b_group_armor_army",
"vn_b_group_armor_usmc",
"vn_b_group_air_army",
"vn_b_group_air_usmc",
"vn_b_group_air_navy",
"vn_b_group_air_usaf",
"vn_b_group_men_aircrew",
"vn_b_group_men_navy",
"vn_b_group_boats",
"vn_b_group_motor_aus_army",
"vn_b_group_mech_aus_army",
"vn_b_group_air_aus_army",
"vn_b_group_men_aus_raaf",
"vn_b_group_men_aus_ran",
"vn_b_group_motor_nz_army",
"vn_b_group_mech_nz_army",
"vn_b_group_mech_rok_army",
"vn_b_group_mech_rok_marines",
"vn_b_group_motor_rok_army",
"vn_b_group_motor_rok_marines",
"vn_b_group_air_cia",
"vn_b_group_air_army_10"
]] call ALIVE_fnc_hashSet;

[ALIVE_VNDefaultResupplyGroupOptions, "PR_HELI_INSERT", [
"Armored",
"Mechanized",
"vn_o_group_mech_kr_75",
"vn_o_group_motor_kr_75",
"vn_o_group_boats_kr_70",
"vn_o_group_motor_vcmf",
"vn_o_group_mech_vcmf",
"vn_o_group_armor_vcmf",
"vn_o_group_motor_nva",
"vn_o_group_boats_vcmf",
"vn_o_group_mech_nva",
"vn_o_group_armor_nva",
"vn_o_group_motor_nva_65",
"vn_o_group_mech_nva_65",
"vn_o_group_armor_nva_65",
"vn_o_group_men_nva_navy",
"vn_o_group_men_vpaf",
"vn_o_group_motor_nvam",
"vn_o_group_mech_nvam",
"vn_o_group_air_army",
"vn_o_group_motor_pl",
"vn_o_group_mech_pl",
"vn_o_group_armor_pl",
"vn_i_group_men_aircrew",
"vn_i_group_motor_army",
"vn_i_group_mech_army",
"vn_i_group_motor_marines",
"vn_i_group_mech_marines",
"vn_i_group_armor_army",
"vn_i_group_air_army",
"vn_i_group_motor_rla",
"vn_i_group_mech_rla",
"vn_i_group_air_fank_71",
"vn_i_group_boats_fank_71",
"vn_i_group_men_aircrew",
"vn_i_group_mech_fank_70",
"vn_i_group_mech_fank_71",
"vn_i_group_motor_fank_70",
"vn_i_group_motor_fank_71",
"vn_b_group_motor_army",
"vn_b_group_motor_usmc",
"vn_b_group_mech_army",
"vn_b_group_mech_usmc",
"vn_b_group_armor_army",
"vn_b_group_armor_usmc",
"vn_b_group_air_army",
"vn_b_group_air_usmc",
"vn_b_group_air_navy",
"vn_b_group_air_usaf",
"vn_b_group_men_aircrew",
"vn_b_group_men_navy",
"vn_b_group_boats",
"vn_b_group_motor_aus_army",
"vn_b_group_mech_aus_army",
"vn_b_group_air_aus_army",
"vn_b_group_men_aus_raaf",
"vn_b_group_men_aus_ran",
"vn_b_group_motor_nz_army",
"vn_b_group_mech_nz_army",
"vn_b_group_mech_rok_army",
"vn_b_group_mech_rok_marines",
"vn_b_group_motor_rok_army",
"vn_b_group_motor_rok_marines",
"vn_b_group_air_cia",
"vn_b_group_air_army_10"
]] call ALIVE_fnc_hashSet;

[ALIVE_VNDefaultResupplyGroupOptions, "PR_STANDARD", []] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyGroupOptions, "O_PAVN", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "O_VC", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "O_PL", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "O_CAM", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "I_ARVN", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "I_LAO", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "I_CAM", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_MACV", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_AUS", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_NZ", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_ROK", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_CIA", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "C_VIET", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;


// SPE - CDLC Spearhead 1944 1.1
ALIVE_SPEDefaultResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_SPEDefaultResupplyGroupOptions, "PR_STANDARD", []] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyGroupOptions, "SPE_STURM", ALIVE_SPEDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "SPE_WEHRMACHT", ALIVE_SPEDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "SPE_US_ARMY", ALIVE_SPEDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "SPE_FR_ARMY", ALIVE_SPEDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "SPE_FFI", ALIVE_SPEDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "SPE_MILICE", ALIVE_SPEDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;

// OVER
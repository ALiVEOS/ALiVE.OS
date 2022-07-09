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

ALIVE_VNDefaultResupplyDefenceStoreOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_VNDefaultResupplyDefenceStoreOptions, "PR_AIRDROP", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;
[ALIVE_VNDefaultResupplyDefenceStoreOptions, "PR_HELI_INSERT", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;
[ALIVE_VNDefaultResupplyDefenceStoreOptions, "PR_STANDARD", [["<< Back","Static","Fortifications"],["<< Back","Static","Fortifications"]]] call ALIVE_fnc_hashSet;

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

//VN
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "O_PAVN", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "O_VC", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "I_ARVN", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "B_MACV", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyDefenceStoreOptions, "C_VIET", ALIVE_VNDefaultResupplyDefenceStoreOptions] call ALIVE_fnc_hashSet;

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

//VN
ALIVE_globalVNResupplyIndividualOptions = [] call ALIVE_fnc_hashCreate;
[ALIVE_globalVNResupplyIndividualOptions, "PR_AIRDROP", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalVNResupplyIndividualOptions, "PR_HELI_INSERT", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;
[ALIVE_globalVNResupplyIndividualOptions, "PR_STANDARD", [["<< Back","Men"],["<< Back","Men"]]] call ALIVE_fnc_hashSet;

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

// VN
[ALIVE_factionDefaultResupplyIndividualOptions, "O_PAVN", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "O_VC", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "O_PL", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "I_ARVN", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "I_LAO", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_MACV", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_AUS", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_NZ", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_ROK", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "B_CIA", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "C_VIET", ALIVE_globalVNResupplyIndividualOptions] call ALIVE_fnc_hashSet;

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

// VN

ALIVE_VNDefaultResupplyGroupOptions = [] call ALIVE_fnc_hashCreate;

[ALIVE_VNDefaultResupplyGroupOptions, "PR_AIRDROP", ["Armored","Mechanized","vn_b_group_motor_army","vn_b_group_mech_army","vn_b_group_armor_army","vn_b_group_armor_usmc","vn_b_group_air_army","vn_b_group_air_usmc","vn_b_group_air_navy","vn_b_group_air_usaf","vn_b_group_men_aircrew","vn_b_group_men_navy","vn_b_group_boats",
"vn_o_group_motor_vcmf",
"vn_o_group_mech_vcmf",
"vn_o_group_armor_vcmf",
"vn_o_group_motor_nva",
"vn_o_group_mech_nva",
"vn_o_group_armor_nva",
"vn_o_group_motor_nva_65",
"vn_o_group_mech_nva_65",
"vn_o_group_armor_nva_65",
"vn_o_group_motor_nvam",
"vn_o_group_mech_nvam",
"vn_o_group_air_army",
"vn_i_group_motor_army",
"vn_i_group_mech_army",
"vn_i_group_armor_army",
"vn_i_group_air_army",
"vn_o_group_motor_pl",
"vn_o_group_mech_pl",
"vn_o_group_armor_pl",
"vn_i_group_motor_rla",
"vn_i_group_mech_rla",
"vn_b_group_motor_aus_army",
"vn_b_group_mech_aus_army",
"vn_b_group_air_aus_army",
"vn_b_group_motor_nz_army",
"vn_b_group_mech_nz_army",
"vn_b_group_mech_rok_army",
"vn_b_group_mech_rok_marines",
"vn_b_group_motor_rok_army",
"vn_b_group_motor_rok_marines",
"vn_b_group_air_cia"

]] call ALIVE_fnc_hashSet;

[ALIVE_VNDefaultResupplyGroupOptions, "PR_HELI_INSERT", ["Armored","Mechanized","vn_b_group_motor_army","vn_b_group_mech_army","vn_b_group_armor_army","vn_b_group_armor_usmc","vn_b_group_air_army","vn_b_group_air_usmc","vn_b_group_air_navy","vn_b_group_air_usaf","vn_b_group_men_aircrew","vn_b_group_men_navy","vn_b_group_boats",
"vn_o_group_motor_vcmf",
"vn_o_group_mech_vcmf",
"vn_o_group_armor_vcmf",
"vn_o_group_motor_nva",
"vn_o_group_mech_nva",
"vn_o_group_armor_nva",
"vn_o_group_motor_nva_65",
"vn_o_group_mech_nva_65",
"vn_o_group_armor_nva_65",
"vn_o_group_motor_nvam",
"vn_o_group_mech_nvam",
"vn_o_group_air_army",
"vn_i_group_motor_army",
"vn_i_group_mech_army",
"vn_i_group_armor_army",
"vn_i_group_air_army",
"vn_o_group_motor_pl",
"vn_o_group_mech_pl",
"vn_o_group_armor_pl",
"vn_i_group_motor_rla",
"vn_i_group_mech_rla",
"vn_b_group_motor_aus_army",
"vn_b_group_mech_aus_army",
"vn_b_group_air_aus_army",
"vn_b_group_motor_nz_army",
"vn_b_group_mech_nz_army",
"vn_b_group_mech_rok_army",
"vn_b_group_mech_rok_marines",
"vn_b_group_motor_rok_army",
"vn_b_group_motor_rok_marines",
"vn_b_group_air_cia"
]] call ALIVE_fnc_hashSet;

[ALIVE_VNDefaultResupplyGroupOptions, "PR_STANDARD", []] call ALIVE_fnc_hashSet;


[ALIVE_factionDefaultResupplyGroupOptions, "O_PAVN", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "O_VC", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "O_PL", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "I_LAO", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "I_ARVN", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_MACV", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_AUS", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_NZ", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_ROK", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "B_CIA", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "C_VIET", ALIVE_VNDefaultResupplyGroupOptions] call ALIVE_fnc_hashSet;

// OVER





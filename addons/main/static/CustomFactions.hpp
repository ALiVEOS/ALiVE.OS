
/*
 * Custom mappings for unit mods
 * Use these mappings to override difficult unit mod CfgGroup configs
 */


/*
 CUSTOM FACTION GROUP MAPPINGS
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

// ---------------------------------------------------------------------------------------------------------------------
BLU_GEN_F_mappings = [] call ALIVE_fnc_hashCreate;
[BLU_GEN_F_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_mappings, "FactionName", "BLU_GEN_F"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_mappings, "GroupFactionName", "Gendarmerie"] call ALIVE_fnc_hashSet;

BLU_GEN_F_typeMappings = [] call ALIVE_fnc_hashCreate;
[BLU_GEN_F_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[BLU_GEN_F_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;

[BLU_GEN_F_mappings, "GroupFactionTypes", BLU_GEN_F_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "BLU_GEN_F", BLU_GEN_F_mappings] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------


// VN CDLC ---------------------------------------------------------------------------------------------------------------------

// PAVN
O_PAVN_mappings = [] call ALIVE_fnc_hashCreate;
[O_PAVN_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[O_PAVN_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[O_PAVN_mappings, "FactionName", "O_PAVN"] call ALIVE_fnc_hashSet;
[O_PAVN_mappings, "GroupFactionName", "VN_PAVN"] call ALIVE_fnc_hashSet;

O_PAVN_typeMappings = [] call ALIVE_fnc_hashCreate;
[O_PAVN_typeMappings, "Air", "vn_o_group_air_army"] call ALIVE_fnc_hashSet;
[O_PAVN_typeMappings, "Armored", "vn_o_group_armor_nva"] call ALIVE_fnc_hashSet;
[O_PAVN_typeMappings, "Infantry", "vn_o_group_men_nva"] call ALIVE_fnc_hashSet;
[O_PAVN_typeMappings, "Mechanized", "vn_o_group_mech_nva"] call ALIVE_fnc_hashSet;
[O_PAVN_typeMappings, "Motorized", "vn_o_group_motor_nva"] call ALIVE_fnc_hashSet;
[O_PAVN_typeMappings, "Motorized_MTP", "vn_o_group_motor_nvam"] call ALIVE_fnc_hashSet;
[O_PAVN_typeMappings, "SpecOps", "vn_o_group_men_nva_dc"] call ALIVE_fnc_hashSet;
[O_PAVN_typeMappings, "Naval", "vn_o_group_boats"] call ALIVE_fnc_hashSet;


[O_PAVN_Mappings, "GroupFactionTypes", O_PAVN_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "O_PAVN", O_PAVN_Mappings] call ALIVE_fnc_hashSet;

// VC
O_VC_mappings = [] call ALIVE_fnc_hashCreate;
[O_VC_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[O_VC_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[O_VC_mappings, "FactionName", "O_VC"] call ALIVE_fnc_hashSet;
[O_VC_mappings, "GroupFactionName", "VN_VC"] call ALIVE_fnc_hashSet;

O_VC_typeMappings = [] call ALIVE_fnc_hashCreate;
[O_VC_typeMappings, "Armored", "vn_o_group_armor_vcmf"] call ALIVE_fnc_hashSet;
[O_VC_typeMappings, "Infantry", "vn_o_group_men_vc_local"] call ALIVE_fnc_hashSet;
[O_VC_typeMappings, "Mechanized", "vn_o_group_mech_vcmf"] call ALIVE_fnc_hashSet;
[O_VC_typeMappings, "Motorized", "vn_o_group_motor_vcmf"] call ALIVE_fnc_hashSet;
[O_VC_typeMappings, "SpecOps", "vn_o_group_men_vc_regional"] call ALIVE_fnc_hashSet;
[O_VC_typeMappings, "Naval", "vn_o_group_boats_vcmf"] call ALIVE_fnc_hashSet;


[O_VC_Mappings, "GroupFactionTypes", O_VC_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "O_VC", O_VC_Mappings] call ALIVE_fnc_hashSet;

// Pathet Lao
O_PL_mappings = [] call ALIVE_fnc_hashCreate;
[O_PL_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[O_PL_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[O_PL_mappings, "FactionName", "O_PL"] call ALIVE_fnc_hashSet;
[O_PL_mappings, "GroupFactionName", "VN_PL"] call ALIVE_fnc_hashSet;

O_PL_typeMappings = [] call ALIVE_fnc_hashCreate;
[O_PL_typeMappings, "Armored", "vn_o_group_armor_pl"] call ALIVE_fnc_hashSet;
[O_PL_typeMappings, "Infantry", "vn_o_group_men_pl"] call ALIVE_fnc_hashSet;
[O_PL_typeMappings, "Mechanized", "vn_o_group_mech_pl"] call ALIVE_fnc_hashSet;
[O_PL_typeMappings, "Motorized", "vn_o_group_motor_pl"] call ALIVE_fnc_hashSet;
[O_PL_typeMappings, "Naval", "vn_o_group_boats_pl"] call ALIVE_fnc_hashSet;


[O_PL_Mappings, "GroupFactionTypes", O_PL_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "O_PL", O_PL_Mappings] call ALIVE_fnc_hashSet;

// Royal Laotian Army
I_LAO_mappings = [] call ALIVE_fnc_hashCreate;
[I_LAO_mappings, "Side", "INDEP"] call ALIVE_fnc_hashSet;
[I_LAO_mappings, "GroupSideName", "INDEP"] call ALIVE_fnc_hashSet;
[I_LAO_mappings, "FactionName", "I_LAO"] call ALIVE_fnc_hashSet;
[I_LAO_mappings, "GroupFactionName", "VN_RLA"] call ALIVE_fnc_hashSet;

I_LAO_typeMappings = [] call ALIVE_fnc_hashCreate;
[I_LAO_typeMappings, "Infantry", "vn_i_group_men_rla"] call ALIVE_fnc_hashSet;
[I_LAO_typeMappings, "Mechanized", "vn_i_group_mech_rla"] call ALIVE_fnc_hashSet;
[I_LAO_typeMappings, "Motorized", "vn_i_group_motor_rla"] call ALIVE_fnc_hashSet;


[I_LAO_Mappings, "GroupFactionTypes", I_LAO_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "I_LAO", I_LAO_Mappings] call ALIVE_fnc_hashSet;

// ARVN
I_ARVN_mappings = [] call ALIVE_fnc_hashCreate;
[I_ARVN_mappings, "Side", "INDEP"] call ALIVE_fnc_hashSet;
[I_ARVN_mappings, "GroupSideName", "INDEP"] call ALIVE_fnc_hashSet;
[I_ARVN_mappings, "FactionName", "I_ARVN"] call ALIVE_fnc_hashSet;
[I_ARVN_mappings, "GroupFactionName", "VN_ARVN"] call ALIVE_fnc_hashSet;

I_ARVN_typeMappings = [] call ALIVE_fnc_hashCreate;
[O_PAVN_typeMappings, "Air", "vn_i_group_air_army"] call ALIVE_fnc_hashSet;
[I_ARVN_typeMappings, "Armored", "vn_i_group_armor_army"] call ALIVE_fnc_hashSet;
[I_ARVN_typeMappings, "Infantry", "vn_i_group_men_army"] call ALIVE_fnc_hashSet;
[I_ARVN_typeMappings, "Mechanized", "vn_i_group_mech_army"] call ALIVE_fnc_hashSet;
[I_ARVN_typeMappings, "Motorized", "vn_i_group_motor_army"] call ALIVE_fnc_hashSet;
[I_ARVN_typeMappings, "SpecOps", "vn_i_group_men_sf"] call ALIVE_fnc_hashSet;


[I_ARVN_Mappings, "GroupFactionTypes", I_ARVN_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "I_ARVN", I_ARVN_Mappings] call ALIVE_fnc_hashSet;

// MACV
B_MACV_mappings = [] call ALIVE_fnc_hashCreate;
[B_MACV_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[B_MACV_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[B_MACV_mappings, "FactionName", "B_MACV"] call ALIVE_fnc_hashSet;
[B_MACV_mappings, "GroupFactionName", "VN_MACV"] call ALIVE_fnc_hashSet;

B_MACV_typeMappings = [] call ALIVE_fnc_hashCreate;
[B_MACV_typeMappings, "Air", "vn_b_group_air_army"] call ALIVE_fnc_hashSet;
[B_MACV_typeMappings, "Armored", "vn_b_group_armor_army"] call ALIVE_fnc_hashSet;
[B_MACV_typeMappings, "Infantry", "vn_b_group_men_army"] call ALIVE_fnc_hashSet;
[B_MACV_typeMappings, "Mechanized", "vn_b_group_mech_army"] call ALIVE_fnc_hashSet;
[B_MACV_typeMappings, "Motorized", "vn_b_group_motor_army"] call ALIVE_fnc_hashSet;
[B_MACV_typeMappings, "SpecOps", "vn_b_group_men_sog"] call ALIVE_fnc_hashSet;
[B_MACV_typeMappings, "Support", "vn_b_group_men_lrrp"] call ALIVE_fnc_hashSet;
[B_MACV_typeMappings, "Naval", "vn_b_group_boats"] call ALIVE_fnc_hashSet;


[B_MACV_Mappings, "GroupFactionTypes", B_MACV_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "B_MACV", B_MACV_Mappings] call ALIVE_fnc_hashSet;

// Australian
B_AUS_mappings = [] call ALIVE_fnc_hashCreate;
[B_AUS_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[B_AUS_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[B_AUS_mappings, "FactionName", "B_AUS"] call ALIVE_fnc_hashSet;
[B_AUS_mappings, "GroupFactionName", "VN_AUS"] call ALIVE_fnc_hashSet;

B_AUS_typeMappings = [] call ALIVE_fnc_hashCreate;
[B_AUS_typeMappings, "Air", "vn_b_group_air_aus_army"] call ALIVE_fnc_hashSet;
[B_AUS_typeMappings, "Infantry", "vn_b_group_men_aus_army_68"] call ALIVE_fnc_hashSet;
[B_AUS_typeMappings, "Mechanized", "vn_b_group_mech_aus_army"] call ALIVE_fnc_hashSet;
[B_AUS_typeMappings, "Motorized", "vn_b_group_motor_aus_army"] call ALIVE_fnc_hashSet;
[B_AUS_typeMappings, "SpecOps", "vn_b_group_men_aus_sas_66"] call ALIVE_fnc_hashSet;


[B_AUS_Mappings, "GroupFactionTypes", B_AUS_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "B_AUS", B_AUS_Mappings] call ALIVE_fnc_hashSet;

// New Zealand
B_NZ_mappings = [] call ALIVE_fnc_hashCreate;
[B_NZ_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[B_NZ_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[B_NZ_mappings, "FactionName", "B_NZ"] call ALIVE_fnc_hashSet;
[B_NZ_mappings, "GroupFactionName", "VN_NZ"] call ALIVE_fnc_hashSet;

B_NZ_typeMappings = [] call ALIVE_fnc_hashCreate;
[B_NZ_typeMappings, "Infantry", "vn_b_group_men_nz_army_68"] call ALIVE_fnc_hashSet;
[B_NZ_typeMappings, "Mechanized", "vn_b_group_mech_nz_army"] call ALIVE_fnc_hashSet;
[B_NZ_typeMappings, "Motorized", "vn_b_group_motor_nz_army"] call ALIVE_fnc_hashSet;
[B_NZ_typeMappings, "SpecOps", "vn_b_group_men_nz_sas_66"] call ALIVE_fnc_hashSet;


[B_NZ_Mappings, "GroupFactionTypes", B_NZ_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "B_NZ", B_NZ_Mappings] call ALIVE_fnc_hashSet;

// Republic Of Korea
B_ROK_mappings = [] call ALIVE_fnc_hashCreate;
[B_ROK_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[B_ROK_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[B_ROK_mappings, "FactionName", "B_ROK"] call ALIVE_fnc_hashSet;
[B_ROK_mappings, "GroupFactionName", "VN_ROK"] call ALIVE_fnc_hashSet;

B_ROK_typeMappings = [] call ALIVE_fnc_hashCreate;
[B_ROK_typeMappings, "Infantry", "vn_b_group_men_rok_army_68"] call ALIVE_fnc_hashSet;
[B_ROK_typeMappings, "Mechanized", "vn_b_group_mech_rok_army"] call ALIVE_fnc_hashSet;
[B_ROK_typeMappings, "Motorized", "vn_b_group_motor_rok_army"] call ALIVE_fnc_hashSet;
[B_ROK_typeMappings, "SpecOps", "vn_b_group_men_rok_marines_68"] call ALIVE_fnc_hashSet;


[B_ROK_Mappings, "GroupFactionTypes", B_ROK_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "B_ROK", B_ROK_Mappings] call ALIVE_fnc_hashSet;

// US CIA
B_CIA_mappings = [] call ALIVE_fnc_hashCreate;
[B_CIA_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[B_CIA_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[B_CIA_mappings, "FactionName", "B_CIA"] call ALIVE_fnc_hashSet;
[B_CIA_mappings, "GroupFactionName", "B_CIA"] call ALIVE_fnc_hashSet;

B_CIA_typeMappings = [] call ALIVE_fnc_hashCreate;
[B_CIA_typeMappings, "Air", "vn_b_group_air_cia"] call ALIVE_fnc_hashSet;
[B_CIA_typeMappings, "Infantry", "vn_b_group_men_cia"] call ALIVE_fnc_hashSet;


[B_CIA_Mappings, "GroupFactionTypes", B_CIA_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "B_CIA", B_CIA_Mappings] call ALIVE_fnc_hashSet;


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


// Ryanzombies
// ---------------------------------------------------------------------------------------------------------------------

// Ryanzombiesfaction

Ryanzombiesfaction_mappings = [] call ALIVE_fnc_hashCreate;

Ryanzombiesfaction_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[Ryanzombiesfaction_mappings, "Side", "INDEP"] call ALIVE_fnc_hashSet;
[Ryanzombiesfaction_mappings, "GroupSideName", "INDEP"] call ALIVE_fnc_hashSet;
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

[ALIVE_factionDefaultResupplyVehicleOptions, "rhsgref_faction_cdf_ground", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "rhsgref_faction_nationalist", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyVehicleOptions, "rhssaf_faction_un", ALIVE_RHSResupplyVehicleOptions] call ALIVE_fnc_hashSet;



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

[ALIVE_factionDefaultResupplyIndividualOptions, "rhsgref_faction_cdf_ground", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "rhsgref_faction_nationalist", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyIndividualOptions, "rhssaf_faction_un", ALIVE_RHSResupplyIndividualOptions] call ALIVE_fnc_hashSet;



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

[ALIVE_factionDefaultResupplyGroupOptions, "rhsgref_faction_cdf_ground", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyGroupOptions, "rhsgref_faction_nationalist", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultResupplyGroupOptions, "rhssaf_faction_un", ALIVE_RHSResupplyGroupOptions] call ALIVE_fnc_hashSet;



// RHS USAF ----------------------------------------------------------------------------------------------------------------

// rhs_faction_usarmy_wd

rhs_faction_usarmy_wd_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_usarmy_wd_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usarmy_wd_factionCustomGroups,"Infantry", ["rhs_group_nato_usarmy_wd_company_hq","rhs_group_nato_usarmy_wd_platoon_hq","rhs_group_nato_usarmy_wd_infantry_squad","rhs_group_nato_usarmy_wd_infantry_weaponsquad","rhs_group_nato_usarmy_wd_infantry_squad_sniper","rhs_group_nato_usarmy_wd_infantry_team","rhs_group_nato_usarmy_wd_infantry_team_MG","rhs_group_nato_usarmy_wd_infantry_team_AA","rhs_group_nato_usarmy_wd_infantry_team_support","rhs_group_nato_usarmy_wd_infantry_team_heavy_AT"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Motorized", ["rhs_group_nato_usarmy_wd_RG33_squad","rhs_group_nato_usarmy_wd_RG33_squad_2mg","rhs_group_nato_usarmy_wd_RG33_squad_sniper","rhs_group_nato_usarmy_wd_RG33_squad_mg_sniper","rhs_group_nato_usarmy_wd_RG33_m2_squad","rhs_group_nato_usarmy_wd_RG33_m2_squad_2mg","rhs_group_nato_usarmy_wd_RG33_m2_squad_sniper","rhs_group_nato_usarmy_wd_RG33_m2_squad_mg_sniper","rhs_group_nato_usarmy_wd_FMTV_1078_squad","rhs_group_nato_usarmy_wd_FMTV_1078_squad_2mg","rhs_group_nato_usarmy_wd_FMTV_1078_squad_sniper","rhs_group_nato_usarmy_wd_FMTV_1078_squad_mg_sniper","rhs_group_nato_usarmy_wd_FMTV_1083_squad","rhs_group_nato_usarmy_wd_FMTV_1083_squad_2mg","rhs_group_nato_usarmy_wd_FMTV_1083_squad_sniper","rhs_group_nato_usarmy_wd_FMTV_1083_squad_mg_sniper"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Mechanized", ["rhs_group_nato_usarmy_wd_M113_squad","rhs_group_nato_usarmy_wd_M113_squad_2mg","rhs_group_nato_usarmy_wd_M113_squad_sniper","rhs_group_nato_usarmy_wd_M113_squad_mg_sniper","rhs_group_nato_usarmy_wd_bradley_squad","rhs_group_nato_usarmy_wd_bradleyA3_squad","rhs_group_nato_usarmy_wd_bradleyA3_squad_2mg","rhs_group_nato_usarmy_wd_bradleyA3_squad_sniper","rhs_group_nato_usarmy_wd_bradleyA3_squad_mg_sniper","rhs_group_nato_usarmy_d_bradleyA3_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Armored", ["RHS_M1A1AIM_wd_Platoon","RHS_M1A1AIM_wd_Platoon_AA","RHS_M1A1AIM_wd_Section","RHS_M1A1AIM_wd_TUSK_Platoon","RHS_M1A1AIM_wd_TUSK_Platoon_AA","RHS_M1A1AIM_wd_TUSK_Section","RHS_M1A2SEP_wd_Platoon","RHS_M1A2SEP_wd_Platoon_AA","RHS_M1A2SEP_wd_Section","RHS_M1A2SEP_wd_TUSK_Platoon","RHS_M1A2SEP_wd_TUSK_Platoon_AA","RHS_M1A2SEP_wd_TUSK_Section","RHS_M1A2SEP_wd_TUSK2_Platoon","RHS_M1A2SEP_wd_TUSK2_Platoon_AA","RHS_M1A2SEP_wd_TUSK2_Section"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Artillery", ["RHS_M109_wd_Platoon","RHS_M109_wd_Section"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_usarmy_wd_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usarmy_wd_mappings,"Side", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings,"GroupSideName", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings,"FactionName", "rhs_faction_usarmy_wd"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings,"GroupFactionName", "rhs_faction_usarmy_wd"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings,"GroupFactionTypes", rhs_faction_usarmy_wd_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_wd_mappings,"Groups", rhs_faction_usarmy_wd_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_usarmy_wd", rhs_faction_usarmy_wd_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd","rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19","rhsusf_rg33_wd","rhsusf_rg33_m2_wd","rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19","rhsusf_m109_usarmy","RHS_M6_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_wd", ["RHS_CH_47F","RHS_UH60M"]] call ALIVE_fnc_hashSet;


// rhs_faction_usarmy_d

rhs_faction_usarmy_d_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_usarmy_d_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usarmy_d_factionCustomGroups,"Infantry", ["rhs_group_nato_usarmy_d_company_hq","rhs_group_nato_usarmy_d_platoon_hq","rhs_group_nato_usarmy_d_infantry_squad","rhs_group_nato_usarmy_d_infantry_weaponsquad","rhs_group_nato_usarmy_d_infantry_squad_sniper","rhs_group_nato_usarmy_d_infantry_team","rhs_group_nato_usarmy_d_infantry_team_MG","rhs_group_nato_usarmy_d_infantry_team_AA","rhs_group_nato_usarmy_d_infantry_team_AT","rhs_group_nato_usarmy_d_infantry_team_support"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Motorized", ["rhs_group_nato_usarmy_d_RG33_squad","rhs_group_nato_usarmy_d_RG33_squad_2mg","rhs_group_nato_usarmy_d_RG33_squad_sniper","rhs_group_nato_usarmy_d_RG33_squad_mg_sniper","rhs_group_nato_usarmy_d_RG33_m2_squad","rhs_group_nato_usarmy_d_RG33_m2_squad_2mg","rhs_group_nato_usarmy_d_RG33_m2_squad_sniper","rhs_group_nato_usarmy_d_RG33_m2_squad_mg_sniper","rhs_group_nato_usarmy_d_FMTV_1078_squad","rhs_group_nato_usarmy_d_FMTV_1078_squad_2mg","rhs_group_nato_usarmy_d_FMTV_1078_squad_sniper","rhs_group_nato_usarmy_d_FMTV_1078_squad_mg_sniper","rhs_group_nato_usarmy_d_FMTV_1083_squad","rhs_group_nato_usarmy_d_FMTV_1083_squad_2mg","rhs_group_nato_usarmy_d_FMTV_1083_squad_sniper","rhs_group_nato_usarmy_d_FMTV_1083_squad_mg_sniper","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Mechanized", ["rhs_group_nato_usarmy_d_M113_squad","rhs_group_nato_usarmy_d_M113_squad_2mg","rhs_group_nato_usarmy_d_M113_squad_sniper","rhs_group_nato_usarmy_d_M113_squad_mg_sniper","rhs_group_nato_usarmy_d_bradley_squad","rhs_group_nato_usarmy_d_bradley_squad_2mg","rhs_group_nato_usarmy_d_bradley_squad_sniper","rhs_group_nato_usarmy_d_bradley_squad_mg_sniper","rhs_group_nato_usarmy_d_bradley_aa","rhs_group_nato_usarmy_d_bradleyA3_squad","rhs_group_nato_usarmy_d_bradleyA3_squad_2mg","rhs_group_nato_usarmy_d_bradleyA3_squad_sniper","rhs_group_nato_usarmy_d_bradleyA3_squad_mg_sniper","rhs_group_nato_usarmy_d_bradleyA3_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Armored", ["RHS_M1A1AIM_Platoon","RHS_M1A1AIM_Platoon_AA","RHS_M1A1AIM_Section","RHS_M1A1AIM_TUSK_Platoon","RHS_M1A1AIM_TUSK_Platoon_AA","RHS_M1A1AIM_TUSK_Section","RHS_M1A2SEP_Platoon","RHS_M1A2SEP_Platoon_AA","RHS_M1A2SEP_Section","RHS_M1A2SEP_TUSK_Platoon","RHS_M1A2SEP_TUSK_Platoon_AA","RHS_M1A2SEP_TUSK_Section","RHS_M1A2SEP_d_TUSK2_Platoon","RHS_M1A2SEP_d_TUSK2_Platoon_AA","RHS_M1A2SEP_d_TUSK2_Section"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Artillery", ["RHS_M109_Platoon","RHS_M109_Section"]] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_usarmy_d_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usarmy_d_mappings,"Side", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings,"GroupSideName", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings,"FactionName", "rhs_faction_usarmy_d"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings,"GroupFactionName", "rhs_faction_usarmy_d"] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings,"GroupFactionTypes", rhs_faction_usarmy_d_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_usarmy_d_mappings,"Groups", rhs_faction_usarmy_d_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_usarmy_d", rhs_faction_usarmy_d_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_usarmy_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19","rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d","RHS_M6","rhsusf_m109d_usarmy","rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19","rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usarmy_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy","rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usarmy_d", ["RHS_CH_47F_light","RHS_UH60M_d"]] call ALIVE_fnc_hashSet;

// rhs_faction_usmc_wd

rhs_faction_usmc_wd_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_usmc_wd_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usmc_wd_factionCustomGroups,"Infantry", ["rhs_group_nato_usmc_wd_infantry_squad","rhs_group_nato_usmc_wd_infantry_weaponsquad","rhs_group_nato_usmc_wd_infantry_squad_sniper","rhs_group_nato_usmc_wd_infantry_team","rhs_group_nato_usmc_wd_infantry_team_MG","rhs_group_nato_usmc_wd_infantry_team_AA","rhs_group_nato_usmc_wd_infantry_team_support","rhs_group_nato_usmc_wd_infantry_team_heavy_AT"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"SpecOps", ["rhs_group_nato_usmc_recon_wd_infantry_team","rhs_group_nato_usmc_recon_wd_infantry_team_MG","rhs_group_nato_usmc_recon_wd_infantry_team_support","rhs_group_nato_usmc_recon_wd_infantry_team_lite","rhs_group_nato_usmc_recon_wd_infantry_team_fast"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Motorized", ["BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA","rhs_group_nato_usmc_wd_RG33_squad","rhs_group_nato_usmc_wd_RG33_squad_2mg","rhs_group_nato_usmc_wd_RG33_squad_sniper","rhs_group_nato_usmc_wd_RG33_squad_mg_sniper","rhs_group_nato_usmc_wd_RG33_m2_squad","rhs_group_nato_usmc_wd_RG33_m2_squad_2mg","rhs_group_nato_usmc_wd_RG33_m2_squad_sniper","rhs_group_nato_usmc_wd_RG33_m2_squad_mg_sniper"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Mechanized", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Armored", ["RHS_M1A1AIM_wd_Platoon","RHS_M1A1FEP_wd_Section"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Artillery", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_usmc_wd_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usmc_wd_mappings,"Side", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings,"GroupSideName", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings,"FactionName", "rhs_faction_usmc_wd"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings,"GroupFactionName", "rhs_faction_usmc_wd"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings,"GroupFactionTypes", rhs_faction_usmc_wd_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_wd_mappings,"Groups", rhs_faction_usmc_wd_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_usmc_wd", rhs_faction_usmc_wd_mappings] call ALiVE_fnc_hashSet;


[ALIVE_factionDefaultSupports, "rhs_faction_usmc_wd", ["rhsusf_rg33_usmc_wd","rhsusf_rg33_m2_usmc_wd","rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19","rhsusf_rg33_wd","rhsusf_rg33_m2_wd","rhsusf_m998_w_2dr","rhsusf_m998_w_2dr_halftop","rhsusf_m998_w_2dr_fulltop","rhsusf_m998_w_4dr","rhsusf_m998_w_4dr_halftop","rhsusf_m998_w_4dr_fulltop","rhsusf_m1025_w","rhsusf_m1025_w_m2","rhsusf_m1025_w_mk19","rhsusf_m109_usarmy","RHS_M6_wd"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_wd", ["rhsusf_M1078A1P2_B_wd_fmtv_usarmy","rhsusf_M1078A1P2_wd_fmtv_usarmy","rhsusf_M1083A1P2_B_wd_fmtv_usarmy","rhsusf_M1083A1P2_wd_fmtv_usarmy","rhsusf_M977A2_usarmy_wd","rhsusf_M977A2_CPK_usarmy_wd","rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m1025_w_s","rhsusf_m1025_w_s_m2","rhsusf_m1025_w_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_wd", ["RHS_CH_47F","rhsusf_CH53E_USMC","RHS_UH60M"]] call ALIVE_fnc_hashSet;


// rhs_faction_usmc_d

rhs_faction_usmc_d_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_usmc_d_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usmc_d_factionCustomGroups,"Infantry", ["rhs_group_nato_usmc_d_infantry_squad","rhs_group_nato_usmc_d_infantry_weaponsquad","rhs_group_nato_usmc_d_infantry_squad_sniper","rhs_group_nato_usmc_d_infantry_team","rhs_group_nato_usmc_d_infantry_team_MG","rhs_group_nato_usmc_d_infantry_team_AA","rhs_group_nato_usmc_d_infantry_team_support","rhs_group_nato_usmc_d_infantry_team_heavy_AT"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"SpecOps", ["rhs_group_nato_usmc_recon_d_infantry_team","rhs_group_nato_usmc_recon_d_infantry_team_MG","rhs_group_nato_usmc_recon_d_infantry_team_support","rhs_group_nato_usmc_recon_d_infantry_team_lite","rhs_group_nato_usmc_recon_d_infantry_team_fast"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Motorized", ["rhs_group_nato_usmc_d_RG33_squad","rhs_group_nato_usmc_d_RG33_squad_2mg","rhs_group_nato_usmc_d_RG33_squad_sniper","rhs_group_nato_usmc_d_RG33_squad_mg_sniper","rhs_group_nato_usmc_d_RG33_m2_squad","rhs_group_nato_usmc_d_RG33_m2_squad_2mg","rhs_group_nato_usmc_d_RG33_m2_squad_sniper","rhs_group_nato_usmc_d_RG33_m2_squad_mg_sniper","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Mechanized", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Armored", ["RHS_M1A1AIM_d_Platoon","RHS_M1A1FEP_d_Section"]] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Artillery", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_usmc_d_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_usmc_d_mappings,"Side", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings,"GroupSideName", "WEST"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings,"FactionName", "rhs_faction_usmc_d"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings,"GroupFactionName", "rhs_faction_usmc_d"] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings,"GroupFactionTypes", rhs_faction_usmc_d_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_usmc_d_mappings,"Groups", rhs_faction_usmc_d_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_usmc_d", rhs_faction_usmc_d_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_usmc_d", ["rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19","rhsusf_rg33_usmc_d","rhsusf_rg33_m2_usmc_d","RHS_M6","rhsusf_m109d_usarmy","rhsusf_m998_d_2dr","rhsusf_m998_d_2dr_halftop","rhsusf_m998_d_2dr_fulltop","rhsusf_m998_d_4dr","rhsusf_m998_d_4dr_halftop","rhsusf_m998_d_4dr_fulltop","rhsusf_m1025_d","rhsusf_m1025_d_m2","rhsusf_m1025_d_Mk19","rhsusf_rg33_d","rhsusf_rg33_m2_d"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_usmc_d", ["rhsusf_M1078A1P2_B_d_fmtv_usarmy","rhsusf_M1078A1P2_d_fmtv_usarmy","rhsusf_M1083A1P2_B_d_fmtv_usarmy","rhsusf_M1083A1P2_d_fmtv_usarmy","rhsusf_m998_d_s_2dr","rhsusf_m998_d_s_2dr_halftop","rhsusf_m998_d_s_2dr_fulltop","rhsusf_m998_d_s_4dr","rhsusf_m998_d_s_4dr_halftop","rhsusf_m998_d_s_4dr_fulltop","rhsusf_m1025_d_s","rhsusf_m1025_d_s_m2","rhsusf_m1025_d_s_Mk19"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_usmc_d", ["RHS_CH_47F_light","rhsusf_CH53E_USMC_D","RHS_UH60M_d"]] call ALIVE_fnc_hashSet;

// RHS AFRF ----------------------------------------------------------------------------------------------------------------

// rhs_faction_msv

rhs_faction_msv_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_msv_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_msv_factionCustomGroups,"Infantry", ["rhs_group_rus_msv_infantry_chq","rhs_group_rus_msv_infantry_MANEUVER","rhs_group_rus_msv_infantry_squad","rhs_group_rus_msv_infantry_squad_2mg","rhs_group_rus_msv_infantry_squad_sniper","rhs_group_rus_msv_infantry_squad_mg_sniper","rhs_group_rus_msv_infantry_section_mg","rhs_group_rus_msv_infantry_section_marksman","rhs_group_rus_msv_infantry_section_AT","rhs_group_rus_msv_infantry_section_AA","rhs_group_rus_msv_infantry_fireteam","rhs_group_rus_msv_infantry_emr_chq","rhs_group_rus_msv_infantry_emr_squad","rhs_group_rus_msv_infantry_emr_squad_2mg","rhs_group_rus_msv_infantry_emr_squad_sniper","rhs_group_rus_msv_infantry_emr_squad_mg_sniper","rhs_group_rus_msv_infantry_emr_section_mg","rhs_group_rus_msv_infantry_emr_section_marksman","rhs_group_rus_msv_infantry_emr_section_AT","rhs_group_rus_msv_infantry_emr_section_AA","rhs_group_rus_msv_infantry_emr_fireteam","rhs_group_rus_msv_infantry_emr_MANEUVER"]] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Motorized", ["rhs_group_rus_msv_Ural_chq","rhs_group_rus_msv_Ural_squad","rhs_group_rus_msv_Ural_squad_2mg","rhs_group_rus_msv_Ural_squad_sniper","rhs_group_rus_msv_Ural_squad_mg_sniper","rhs_group_rus_msv_Ural_squad_aa","rhs_group_rus_msv_gaz66_chq","rhs_group_rus_msv_gaz66_squad","rhs_group_rus_msv_gaz66_squad_2mg","rhs_group_rus_msv_gaz66_squad_sniper","rhs_group_rus_msv_gaz66_squad_mg_sniper","rhs_group_rus_msv_gaz66_squad_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Mechanized", ["rhs_group_rus_msv_btr70_chq","rhs_group_rus_msv_btr70_squad","rhs_group_rus_msv_btr70_squad_2mg","rhs_group_rus_msv_btr70_squad_sniper","rhs_group_rus_msv_btr70_squad_mg_sniper","rhs_group_rus_msv_btr70_squad_aa","rhs_group_rus_msv_BTR80_chq","rhs_group_rus_msv_BTR80_squad","rhs_group_rus_msv_BTR80_squad_2mg","rhs_group_rus_msv_BTR80_squad_sniper","rhs_group_rus_msv_BTR80_squad_mg_sniper","rhs_group_rus_msv_BTR80_squad_aa","rhs_group_rus_msv_BTR80a_chq","rhs_group_rus_msv_BTR80a_squad","rhs_group_rus_msv_BTR80a_squad_2mg","rhs_group_rus_msv_BTR80a_squad_sniper","rhs_group_rus_msv_BTR80a_squad_mg_sniper","rhs_group_rus_msv_BTR80a_squad_aa","rhs_group_rus_msv_bmp1_chq","rhs_group_rus_msv_bmp1_squad","rhs_group_rus_msv_bmp1_squad_2mg","rhs_group_rus_msv_bmp1_squad_sniper","rhs_group_rus_msv_bmp1_squad_mg_sniper","rhs_group_rus_msv_bmp1_squad_aa","rhs_group_rus_msv_bmp2_chq","rhs_group_rus_msv_bmp2_squad","rhs_group_rus_msv_bmp2_squad_2mg","rhs_group_rus_msv_bmp2_squad_sniper","rhs_group_rus_msv_bmp2_squad_mg_sniper","rhs_group_rus_msv_bmp2_squad_aa","rhs_group_rus_MSV_BMP3_chq","rhs_group_rus_MSV_BMP3_squad","rhs_group_rus_MSV_BMP3_squad_2mg","rhs_group_rus_MSV_BMP3_squad_sniper","rhs_group_rus_MSV_BMP3_squad_mg_sniper","rhs_group_rus_MSV_BMP3_squad_aa","rhs_group_rus_MSV_bmp3m_chq","rhs_group_rus_MSV_bmp3m_squad","rhs_group_rus_MSV_bmp3m_squad_2mg","rhs_group_rus_MSV_bmp3m_squad_sniper","rhs_group_rus_MSV_bmp3m_squad_mg_sniper","rhs_group_rus_MSV_bmp3m_squad_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Armored", []] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Artillery", ["RHS_SPGPlatoon_msv_bm21","RHS_SPGSection_msv_bm21"]] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_msv_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_msv_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_msv_mappings,"Side", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_msv_mappings,"GroupSideName", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_msv_mappings,"FactionName", "rhs_faction_msv"] call ALiVE_fnc_hashSet;
[rhs_faction_msv_mappings,"GroupFactionName", "rhs_faction_msv"] call ALiVE_fnc_hashSet;
[rhs_faction_msv_mappings,"GroupFactionTypes", rhs_faction_msv_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_msv_mappings,"Groups", rhs_faction_msv_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_msv", rhs_faction_msv_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_msv", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3","rhs_9k79","rhs_9k79_K","rhs_9k79_B","rhs_2s3_tv","rhs_zsu234_aa","RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf","rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_tigr_sts_vmf","rhs_tigr_sts_3camo_vmf","rhs_tigr_m_vmf","rhs_tigr_m_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf","rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv","rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01","RHS_Ural_MSV_01","RHS_Ural_Open_MSV_01","RHS_Ural_Fuel_MSV_01","RHS_BM21_MSV_01","rhs_gaz66_msv","rhs_gaz66o_msv","rhs_gaz66_r142_msv","rhs_gaz66_repair_msv","rhs_gaz66_ap2_msv","rhs_gaz66_ammo_msv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_msv", ["rhs_tigr_msv","rhs_tigr_3camo_msv","rhs_tigr_ffv_msv","rhs_tigr_ffv_3camo_msv","rhs_tigr_sts_msv","rhs_tigr_sts_3camo_msv","rhs_tigr_m_msv","rhs_tigr_m_3camo_msv","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01","RHS_UAZ_MSV_01","rhs_uaz_open_MSV_01","rhs_uaz_vdv","rhs_uaz_open_vdv","rhs_gaz66_vmf","rhs_gaz66o_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_msv", ["RHS_Mi24P_vvsc","RHS_Mi24P_CAS_vvsc","RHS_Mi24P_AT_vvsc","RHS_Mi24V_vvsc","RHS_Mi24V_FAB_vvsc","RHS_Mi24V_UPK23_vvsc","RHS_Mi24V_AT_vvsc","RHS_Mi8mt_vvsc","RHS_Mi8mt_Cargo_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8MTV3_UPK23_vvsc","RHS_Mi8MTV3_FAB_vvsc","RHS_Mi8AMT_vvsc","RHS_Mi8AMTSh_vvsc","RHS_Mi8AMTSh_UPK23_vvsc","RHS_Mi8AMTSh_FAB_vvsc","rhs_ka60_c","RHS_Mi24P_vvs","RHS_Mi24P_CAS_vvs","RHS_Mi24P_AT_vvs","RHS_Mi24V_vvs","RHS_Mi24V_FAB_vvs","RHS_Mi24V_UPK23_vvs","RHS_Mi24V_AT_vvs","RHS_Mi24Vt_vvs","RHS_Mi8mt_vvs","RHS_Mi8mt_Cargo_vvs","RHS_Mi8MTV3_vvs","RHS_Mi8MTV3_UPK23_vvs","RHS_Mi8MTV3_FAB_vvs","RHS_Mi8AMT_vvs","RHS_Mi8AMTSh_vvs","RHS_Mi8AMTSh_UPK23_vvs","RHS_Mi8AMTSh_FAB_vvs","rhs_ka60_grey","RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv","RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;


// rhs_faction_vdv

rhs_faction_vdv_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_vdv_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_vdv_factionCustomGroups,"Infantry", ["rhs_group_rus_vdv_infantry_chq","rhs_group_rus_vdv_infantry_squad","rhs_group_rus_vdv_infantry_squad_2mg","rhs_group_rus_vdv_infantry_squad_sniper","rhs_group_rus_vdv_infantry_squad_mg_sniper","rhs_group_rus_vdv_infantry_section_mg","rhs_group_rus_vdv_infantry_section_marksman","rhs_group_rus_vdv_infantry_section_AT","rhs_group_rus_vdv_infantry_section_AA","rhs_group_rus_vdv_infantry_fireteam","rhs_group_rus_vdv_infantry_MANEUVER","rhs_group_rus_vdv_des_infantry_chq","rhs_group_rus_vdv_des_infantry_squad","rhs_group_rus_vdv_des_infantry_squad_2mg","rhs_group_rus_vdv_des_infantry_squad_sniper","rhs_group_rus_vdv_des_infantry_squad_mg_sniper","rhs_group_rus_vdv_des_infantry_section_mg","rhs_group_rus_vdv_des_infantry_section_marksman","rhs_group_rus_vdv_des_infantry_section_AT","rhs_group_rus_vdv_des_infantry_section_AA","rhs_group_rus_vdv_des_infantry_fireteam","rhs_group_rus_vdv_des_infantry_MANEUVER","rhs_group_rus_vdv_infantry_flora_chq","rhs_group_rus_vdv_infantry_flora_squad","rhs_group_rus_vdv_infantry_flora_squad_2mg","rhs_group_rus_vdv_infantry_flora_squad_sniper","rhs_group_rus_vdv_infantry_flora_squad_mg_sniper","rhs_group_rus_vdv_infantry_flora_section_mg","rhs_group_rus_vdv_infantry_flora_section_marksman","rhs_group_rus_vdv_infantry_flora_section_AT","rhs_group_rus_vdv_infantry_flora_section_AA","rhs_group_rus_vdv_infantry_flora_fireteam","rhs_group_rus_vdv_infantry_flora_MANEUVER","rhs_group_rus_vdv_infantry_mflora_chq","rhs_group_rus_vdv_infantry_mflora_squad","rhs_group_rus_vdv_infantry_mflora_squad_2mg","rhs_group_rus_vdv_infantry_mflora_squad_sniper","rhs_group_rus_vdv_infantry_mflora_squad_mg_sniper","rhs_group_rus_vdv_infantry_mflora_section_mg","rhs_group_rus_vdv_infantry_mflora_section_marksman","rhs_group_rus_vdv_infantry_mflora_section_AT","rhs_group_rus_vdv_infantry_mflora_section_AA","rhs_group_rus_vdv_infantry_mflora_fireteam","rhs_group_rus_vdv_infantry_mflora_MANEUVER"]] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"SpecOps", ["rhs_group_rus_vdv_infantry_recon_chq","rhs_group_rus_vdv_infantry_recon_squad","rhs_group_rus_vdv_infantry_recon_squad_2mg","rhs_group_rus_vdv_infantry_recon_squad_sniper","rhs_group_rus_vdv_infantry_recon_squad_mg_sniper","rhs_group_rus_vdv_infantry_recon_fireteam","rhs_group_rus_vdv_infantry_recon_MANEUVER"]] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Motorized", ["rhs_group_rus_vdv_Ural_chq","rhs_group_rus_vdv_Ural_squad","rhs_group_rus_vdv_Ural_squad_2mg","rhs_group_rus_vdv_Ural_squad_sniper","rhs_group_rus_vdv_Ural_squad_mg_sniper","rhs_group_rus_vdv_Ural_squad_aa","rhs_group_rus_vdv_gaz66_chq","rhs_group_rus_vdv_gaz66_squad","rhs_group_rus_vdv_gaz66_squad_2mg","rhs_group_rus_vdv_gaz66_squad_sniper","rhs_group_rus_vdv_gaz66_squad_mg_sniper","rhs_group_rus_vdv_gaz66_squad_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Mechanized", ["rhs_group_rus_vdv_btr60_chq","rhs_group_rus_vdv_btr60_squad","rhs_group_rus_vdv_btr60_squad_2mg","rhs_group_rus_vdv_btr60_squad_sniper","rhs_group_rus_vdv_btr60_squad_mg_sniper","rhs_group_rus_vdv_btr60_squad_aa","rhs_group_rus_vdv_btr70_chq","rhs_group_rus_vdv_btr70_squad","rhs_group_rus_vdv_btr70_squad_2mg","rhs_group_rus_vdv_btr70_squad_sniper","rhs_group_rus_vdv_btr70_squad_mg_sniper","rhs_group_rus_vdv_btr70_squad_aa","rhs_group_rus_vdv_BTR80_chq","rhs_group_rus_vdv_BTR80_squad","rhs_group_rus_vdv_BTR80_squad_2mg","rhs_group_rus_vdv_BTR80_squad_sniper","rhs_group_rus_vdv_BTR80_squad_mg_sniper","rhs_group_rus_vdv_BTR80_squad_aa","rhs_group_rus_vdv_BTR80a_chq","rhs_group_rus_vdv_BTR80a_squad","rhs_group_rus_vdv_BTR80a_squad_2mg","rhs_group_rus_vdv_BTR80a_squad_sniper","rhs_group_rus_vdv_BTR80a_squad_mg_sniper","rhs_group_rus_vdv_BTR80a_squad_aa","rhs_group_rus_vdv_bmp1_chq","rhs_group_rus_vdv_bmp1_squad","rhs_group_rus_vdv_bmp1_squad_2mg","rhs_group_rus_vdv_bmp1_squad_sniper","rhs_group_rus_vdv_bmp1_squad_mg_sniper","rhs_group_rus_vdv_bmp1_squad_aa","rhs_group_rus_vdv_bmp2_chq","rhs_group_rus_vdv_bmp2_squad","rhs_group_rus_vdv_bmp2_squad_2mg","rhs_group_rus_vdv_bmp2_squad_sniper","rhs_group_rus_vdv_bmp2_squad_mg_sniper","rhs_group_rus_vdv_bmp2_squad_aa","rhs_group_rus_vdv_bmd1_chq","rhs_group_rus_vdv_bmd1_squad","rhs_group_rus_vdv_bmd1_squad_2mg","rhs_group_rus_vdv_bmd1_squad_sniper","rhs_group_rus_vdv_bmd1_squad_mg_sniper","rhs_group_rus_vdv_bmd1_squad_aa","rhs_group_rus_vdv_bmd2_chq","rhs_group_rus_vdv_bmd2_squad","rhs_group_rus_vdv_bmd2_squad_2mg","rhs_group_rus_vdv_bmd2_squad_sniper","rhs_group_rus_vdv_bmd2_squad_mg_sniper","rhs_group_rus_vdv_bmd2_squad_aa","rhs_group_rus_vdv_bmd4_chq","rhs_group_rus_vdv_bmd4_squad","rhs_group_rus_vdv_bmd4_squad_2mg","rhs_group_rus_vdv_bmd4_squad_sniper","rhs_group_rus_vdv_bmd4_squad_mg_sniper","rhs_group_rus_vdv_bmd4_squad_aa","rhs_group_rus_vdv_bmd4m_chq","rhs_group_rus_vdv_bmd4m_squad","rhs_group_rus_vdv_bmd4m_squad_2mg","rhs_group_rus_vdv_bmd4m_squad_sniper","rhs_group_rus_vdv_bmd4m_squad_mg_sniper","rhs_group_rus_vdv_bmd4m_squad_aa","rhs_group_rus_vdv_bmd4ma_chq","rhs_group_rus_vdv_bmd4ma_squad","rhs_group_rus_vdv_bmd4ma_squad_2mg","rhs_group_rus_vdv_bmd4ma_squad_sniper","rhs_group_rus_vdv_bmd4ma_squad_mg_sniper","rhs_group_rus_vdv_bmd4ma_squad_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Armored", ["RHS_2S25Platoon","RHS_2S25Platoon_AA","RHS_2S25Section"]] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Artillery", ["RHS_SPGPlatoon_vdv_bm21","RHS_SPGSection_vdv_bm21"]] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Air", ["rhs_group_rus_vdv_mi8_chq","rhs_group_rus_vdv_mi8_squad","rhs_group_rus_vdv_mi8_squad_2mg","rhs_group_rus_vdv_mi8_squad_sniper","rhs_group_rus_vdv_mi8_squad_mg_sniper","rhs_group_rus_vdv_mi24_chq","rhs_group_rus_vdv_mi24_squad","rhs_group_rus_vdv_mi24_squad_2mg","rhs_group_rus_vdv_mi24_squad_sniper","rhs_group_rus_vdv_mi24_squad_mg_sniper"]] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_vdv_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_vdv_mappings,"Side", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_mappings,"GroupSideName", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_mappings,"FactionName", "rhs_faction_vdv"] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_mappings,"GroupFactionName", "rhs_faction_vdv"] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_mappings,"GroupFactionTypes", rhs_faction_vdv_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_vdv_mappings,"Groups", rhs_faction_vdv_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_vdv", rhs_faction_vdv_mappings] call ALiVE_fnc_hashSet;


[ALIVE_factionDefaultSupports, "rhs_faction_vdv", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3","rhs_9k79","rhs_9k79_K","rhs_9k79_B","rhs_2s3_tv","rhs_zsu234_aa","RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf","rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf","rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vdv", ["RHS_Ural_VDV_01","RHS_Ural_Open_VDV_01","rhs_gaz66_vdv","rhs_gaz66o_vdv","rhs_gaz66_ap2_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vdv", ["RHS_Mi24P_CAS_vdv","RHS_Mi24P_AT_vdv","RHS_Mi24P_vdv","RHS_Mi24V_FAB_vdv","RHS_Mi24V_UPK23_vdv","RHS_Mi24V_AT_vdv","RHS_Mi24V_vdv","RHS_Mi8mt_vdv","RHS_Mi8mt_Cargo_vdv","RHS_Mi8MTV3_vdv","RHS_Mi8MTV3_UPK23_vdv","RHS_Mi8MTV3_FAB_vdv","RHS_Mi8AMT_vdv"]] call ALIVE_fnc_hashSet;

// rhs_faction_vdv_des

// rhs_faction_vmf

rhs_faction_vmf_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_vmf_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_vmf_factionCustomGroups,"Infantry", ["rhs_group_rus_vmf_infantry_chq","rhs_group_rus_vmf_infantry_squad","rhs_group_rus_vmf_infantry_squad_2mg","rhs_group_rus_vmf_infantry_squad_sniper","rhs_group_rus_vmf_infantry_squad_mg_sniper","rhs_group_rus_vmf_infantry_section_mg","rhs_group_rus_vmf_infantry_section_marksman","rhs_group_rus_vmf_infantry_section_AT","rhs_group_rus_vmf_infantry_section_AA","rhs_group_rus_vmf_infantry_fireteam","rhs_group_rus_vmf_infantry_MANEUVER"]] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"SpecOps", ["rhs_group_rus_vmf_infantry_recon_chq","rhs_group_rus_vmf_infantry_recon_squad","rhs_group_rus_vmf_infantry_recon_squad_2mg","rhs_group_rus_vmf_infantry_recon_squad_sniper","rhs_group_rus_vmf_infantry_recon_squad_mg_sniper","rhs_group_rus_vmf_infantry_recon_fireteam","rhs_group_rus_vmf_infantry_recon_MANEUVER"]] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Motorized", ["rhs_group_rus_msv_bmp2_chq","rhs_group_rus_msv_bmp2_squad","rhs_group_rus_msv_bmp2_squad_2mg","rhs_group_rus_msv_bmp2_squad_sniper","rhs_group_rus_msv_bmp2_squad_mg_sniper","rhs_group_rus_msv_bmp2_squad_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Mechanized", ["rhs_group_rus_vmf_BTR80_chq","rhs_group_rus_vmf_BTR80_squad","rhs_group_rus_vmf_BTR80_squad_2mg","rhs_group_rus_vmf_BTR80_squad_sniper","rhs_group_rus_vmf_BTR80_squad_mg_sniper","rhs_group_rus_vmf_BTR80_squad_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Armored", []] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Artillery", []] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_vmf_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_vmf_mappings,"Side", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_mappings,"GroupSideName", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_mappings,"FactionName", "rhs_faction_vmf"] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_mappings,"GroupFactionName", "rhs_faction_vmf"] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_mappings,"GroupFactionTypes", rhs_faction_vmf_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_vmf_mappings,"Groups", rhs_faction_vmf_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_vmf", rhs_faction_vmf_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhs_faction_vmf", ["rhs_p37","rhs_prv13","rhs_2P3_1","rhs_2P3_2","rhs_v2","rhs_v3","rhs_9k79","rhs_9k79_K","rhs_9k79_B","rhs_2s3_tv","rhs_zsu234_aa","RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf","rhs_tigr_vmf","rhs_tigr_3camo_vmf","rhs_tigr_ffv_vmf","rhs_tigr_ffv_3camo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf","rhs_tigr_vdv","rhs_tigr_3camo_vdv","rhs_tigr_ffv_vdv","rhs_tigr_ffv_3camo_vdv","rhs_tigr_sts_vdv","rhs_tigr_sts_3camo_vdv","rhs_tigr_m_vdv","rhs_tigr_m_3camo_vdv","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhs_faction_vmf", ["RHS_Ural_VMF_01","rhs_gaz66_vmf","RHS_Ural_Open_VMF_01","rhs_gaz66o_vmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhs_faction_vmf", ["RHS_Mi8mt_Cargo_vdv"]] call ALIVE_fnc_hashSet;


// rhs_faction_tv

rhs_faction_tv_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_tv_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_tv_factionCustomGroups,"Infantry", []] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Motorized", []] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Mechanized", []] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Armored", ["RHS_T72BAPlatoon","RHS_T72BAPlatoon_AA","RHS_T72BASection","RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection","RHS_T72BCPlatoon","RHS_T72BCPlatoon_AA","RHS_T72BCSection","RHS_T72BDPlatoon","RHS_T72BDPlatoon_AA","RHS_T72BDSection","RHS_T80Platoon","RHS_T80Platoon_AA","RHS_T80Section","RHS_T80BPlatoon","RHS_T80BPlatoon_AA","RHS_T80BSection","RHS_T80BVPlatoon","RHS_T80BVPlatoon_AA","RHS_T80BVSection","RHS_T80APlatoon","RHS_T80APlatoon_AA","RHS_T80ASection","RHS_T80UPlatoon","RHS_T80UPlatoon_AA","RHS_T80USection","RHS_T80UMPlatoon","RHS_T80UMPlatoon_AA","RHS_T80UMSection","rhs_t80ue1Platoon","rhs_t80ue1Platoon_AA","rhs_t80ue1Section","rhs_t80u45mPlatoon","rhs_t80u45mPlatoon_AA","rhs_t80u45mSection","RHS_T90Platoon","RHS_T90Platoon_AA","RHS_T90Section","RHS_t90aPlatoon","RHS_t90aPlatoon_AA","RHS_t90aSection"]] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Artillery", ["RHS_SPGPlatoon_tv_2s3","RHS_SPGSection_tv_2s3"]] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_tv_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhs_faction_tv_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_tv_mappings,"Side", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_tv_mappings,"GroupSideName", "EAST"] call ALiVE_fnc_hashSet;
[rhs_faction_tv_mappings,"FactionName", "rhs_faction_tv"] call ALiVE_fnc_hashSet;
[rhs_faction_tv_mappings,"GroupFactionName", "rhs_faction_tv"] call ALiVE_fnc_hashSet;
[rhs_faction_tv_mappings,"GroupFactionTypes", rhs_faction_tv_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_tv_mappings,"Groups", rhs_faction_tv_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_tv", rhs_faction_tv_mappings] call ALiVE_fnc_hashSet;

// RHS GREF ----------------------------------------------------------------------------------------------------------------

// rhs_faction_insurgents

rhs_faction_insurgents_typeMappings = [] call ALiVE_fnc_hashCreate;

rhs_faction_insurgents_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhs_faction_insurgents_factionCustomGroups,"Infantry", ["IRG_InfSquad","IRG_InfSquad_Weapons","IRG_InfTeam","IRG_InfTeam_AT","IRG_InfTeam_MG","IRG_InfSentry","IRG_ReconSentry","IRG_SniperTeam_M"]] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Motorized", ["rhs_group_chdkz_ural_chq","rhs_group_chdkz_ural_squad","rhs_group_chdkz_ural_squad_2mg","rhs_group_chdkz_ural_squad_sniper","rhs_group_chdkz_ural_squad_mg_sniper","rhs_group_chdkz_ural_squad_aa","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Mechanized", ["rhs_group_rus_ins_bmd1_chq","rhs_group_rus_ins_bmd1_squad","rhs_group_rus_ins_bmd1_squad_2mg","rhs_group_rus_ins_bmd1_squad_sniper","rhs_group_rus_ins_bmd1_squad_mg_sniper","rhs_group_rus_ins_bmd1_squad_aa","rhs_group_rus_ins_bmd2_chq","rhs_group_rus_ins_bmd2_squad","rhs_group_rus_ins_bmd2_squad_2mg","rhs_group_rus_ins_bmd2_squad_sniper","rhs_group_rus_ins_bmd2_squad_mg_sniper","rhs_group_rus_ins_bmd2_squad_aa","rhs_group_indp_ins_bmp1_chq","rhs_group_indp_ins_bmp1_squad","rhs_group_indp_ins_bmp1_squad_2mg","rhs_group_indp_ins_bmp1_squad_sniper","rhs_group_indp_ins_bmp1_squad_mg_sniper","rhs_group_indp_ins_bmp1_squad_aa","rhs_group_indp_ins_bmp2_chq","rhs_group_indp_ins_bmp2_squad","rhs_group_indp_ins_bmp2_squad_2mg","rhs_group_indp_ins_bmp2_squad_sniper","rhs_group_indp_ins_bmp2_squad_mg_sniper","rhs_group_indp_ins_bmp2_squad_aa","rhs_group_chdkz_btr70_chq","rhs_group_chdkz_btr70_squad","rhs_group_chdkz_btr70_squad_2mg","rhs_group_chdkz_btr70_squad_sniper","rhs_group_chdkz_btr70_squad_mg_sniper","rhs_group_chdkz_btr70_squad_aa","rhs_group_chdkz_btr60_chq","rhs_group_chdkz_btr60_squad","rhs_group_chdkz_btr60_squad_2mg","rhs_group_chdkz_btr60_squad_sniper","rhs_group_chdkz_btr60_squad_mg_sniper","rhs_group_chdkz_btr60_squad_aa"]] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Armored", ["RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection"]] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Artillery", ["RHS_SPGPlatoon_ins_bm21","RHS_SPGSection_ins_bm21"]] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_factionCustomGroups,"Support", ["IRG_Support_CLS"]] call ALiVE_fnc_hashSet;

rhs_faction_insurgents_mappings = [] call ALiVE_fnc_hashCreate;
[rhs_faction_insurgents_mappings,"Side", "GUER"] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_mappings,"GroupSideName", "GUER"] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_mappings,"FactionName", "rhs_faction_insurgents"] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_mappings,"GroupFactionName", "rhs_faction_insurgents"] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_mappings,"GroupFactionTypes", rhs_faction_insurgents_typeMappings] call ALiVE_fnc_hashSet;
[rhs_faction_insurgents_mappings,"Groups", rhs_faction_insurgents_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhs_faction_insurgents", rhs_faction_insurgents_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports,"rhs_faction_insurgents", ["RHS_Ural_VMF_01","RHS_Ural_Open_VMF_01","RHS_Ural_Fuel_VMF_01","RHS_BM21_VMF_01","rhs_gaz66_vmf","rhs_gaz66o_vmf","rhs_gaz66_r142_vmf","rhs_gaz66_repair_vmf","rhs_gaz66_ap2_vmf","rhs_gaz66_ammo_vmf","rhs_uaz_vmf","rhs_uaz_open_vmf","rhs_uaz_vdv","rhs_uaz_open_vdv"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport,"rhs_faction_insurgents", ["rhs_ural_chdkz"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport,"rhs_faction_insurgents", ["RHS_Mi8mt_Cargo_vdv"]] call ALIVE_fnc_hashSet;

// ---------------------------------------------------------------------------------------------------------------------

// rhsgref_faction_cdf_ground

rhsgref_faction_cdf_ground_typeMappings = [] call ALiVE_fnc_hashCreate;

rhsgref_faction_cdf_ground_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Infantry", ["rhsgref_group_cdf_reg_infantry_squad","rhsgref_group_cdf_reg_infantry_squad_weap","rhsgref_group_cdf_para_infantry_squad","rhsgref_group_cdf_para_infantry_squad_weap"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Motorized", ["rhs_group_cdf_ural_chq","rhs_group_cdf_ural_squad","rhs_group_cdf_ural_squad_2mg","rhs_group_cdf_ural_squad_sniper","rhs_group_cdf_ural_squad_mg_sniper","rhs_group_cdf_ural_squad_aa","rhs_group_cdf_gaz66_chq","rhs_group_cdf_gaz66_squad","rhs_group_cdf_gaz66_squad_2mg","rhs_group_cdf_gaz66_squad_sniper","rhs_group_cdf_gaz66_squad_mg_sniper","rhs_group_cdf_gaz66_squad_aa","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Mechanized", ["rhs_group_cdf_bmp1_chq","rhs_group_cdf_bmp1_squad","rhs_group_cdf_bmp1_squad_2mg","rhs_group_cdf_bmp1_squad_sniper","rhs_group_cdf_bmp1_squad_mg_sniper","rhs_group_cdf_bmp1_squad_aa","rhs_group_cdf_bmp2_chq","rhs_group_cdf_bmp2_squad","rhs_group_cdf_bmp2_squad_2mg","rhs_group_cdf_bmp2_squad_sniper","rhs_group_cdf_bmp2_squad_mg_sniper","rhs_group_cdf_bmp2_squad_aa","rhs_group_cdf_btr70_chq","rhs_group_cdf_btr70_squad","rhs_group_cdf_btr70_squad_2mg","rhs_group_cdf_btr70_squad_sniper","rhs_group_cdf_btr70_squad_mg_sniper","rhs_group_cdf_btr70_squad_aa","rhs_group_cdf_btr60_chq","rhs_group_cdf_btr60_squad","rhs_group_cdf_btr60_squad_2mg","rhs_group_cdf_btr60_squad_sniper","rhs_group_cdf_btr60_squad_mg_sniper","rhs_group_cdf_btr60_squad_aa","rhs_group_cdf_bmd1_chq","rhs_group_cdf_bmd1_squad","rhs_group_cdf_bmd1_squad_2mg","rhs_group_cdf_bmd1_squad_sniper","rhs_group_cdf_bmd1_squad_mg_sniper","rhs_group_cdf_bmd1_squad_aa","rhs_group_cdf_bmd2_chq","rhs_group_cdf_bmd2_squad","rhs_group_cdf_bmd2_squad_2mg","rhs_group_cdf_bmd2_squad_sniper","rhs_group_cdf_bmd2_squad_mg_sniper","rhs_group_cdf_bmd2_squad_aa"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Armored", ["RHS_T72baPlatoon","RHS_T72baPlatoon_AA","RHS_T72baSection","RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection","RHS_T80bPlatoon","RHS_T80bPlatoon_AA","RHS_T80bSection","RHS_T80bvPlatoon","RHS_T80bvPlatoon_AA","RHS_T80bvSection"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Artillery", ["RHS_SPGPlatoon_ins_g_bm21","RHS_SPGSection_ins_g_bm21"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhsgref_faction_cdf_ground_mappings = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_cdf_ground_mappings,"Side", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings,"GroupSideName", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings,"FactionName", "rhsgref_faction_cdf_ground"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings,"GroupFactionName", "rhsgref_faction_cdf_ground"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings,"GroupFactionTypes", rhsgref_faction_cdf_ground_typeMappings] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings,"Groups", rhsgref_faction_cdf_ground_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhsgref_faction_cdf_ground", rhsgref_faction_cdf_ground_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports,"rhsgref_faction_cdf_ground", ["rhs_group_cdf_bmp1_chq","rhs_group_cdf_bmp1_squad","rhs_group_cdf_bmp1_squad_2mg","rhs_group_cdf_bmp1_squad_sniper","rhs_group_cdf_bmp1_squad_mg_sniper","rhs_group_cdf_bmp1_squad_aa","rhs_group_cdf_bmp2_chq","rhs_group_cdf_bmp2_squad","rhs_group_cdf_bmp2_squad_2mg","rhs_group_cdf_bmp2_squad_sniper","rhs_group_cdf_bmp2_squad_mg_sniper","rhs_group_cdf_bmp2_squad_aa","rhs_group_cdf_btr70_chq","rhs_group_cdf_btr70_squad","rhs_group_cdf_btr70_squad_2mg","rhs_group_cdf_btr70_squad_sniper","rhs_group_cdf_btr70_squad_mg_sniper","rhs_group_cdf_btr70_squad_aa","rhs_group_cdf_btr60_chq","rhs_group_cdf_btr60_squad","rhs_group_cdf_btr60_squad_2mg","rhs_group_cdf_btr60_squad_sniper","rhs_group_cdf_btr60_squad_mg_sniper","rhs_group_cdf_btr60_squad_aa","rhs_group_cdf_bmd1_chq","rhs_group_cdf_bmd1_squad","rhs_group_cdf_bmd1_squad_2mg","rhs_group_cdf_bmd1_squad_sniper","rhs_group_cdf_bmd1_squad_mg_sniper","rhs_group_cdf_bmd1_squad_aa","rhs_group_cdf_bmd2_chq","rhs_group_cdf_bmd2_squad","rhs_group_cdf_bmd2_squad_2mg","rhs_group_cdf_bmd2_squad_sniper","rhs_group_cdf_bmd2_squad_mg_sniper","rhs_group_cdf_bmd2_squad_aa"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport,"rhsgref_faction_cdf_ground", ["rhsgref_cdf_ural","rhsgref_cdf_ural_open","rhsgref_cdf_gaz66","rhsgref_cdf_gaz66o"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport,"rhsgref_faction_cdf_ground", ["rhsgref_cdf_reg_Mi8amt"]] call ALIVE_fnc_hashSet;

// rhsgref_faction_cdf_ng

rhsgref_faction_cdf_ng_typeMappings = [] call ALiVE_fnc_hashCreate;

rhsgref_faction_cdf_ng_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Infantry", ["rhsgref_group_cdf_ngd_infantry_squad"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Motorized", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Mechanized", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Armored", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Artillery", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhsgref_faction_cdf_ng_mappings = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_cdf_ng_mappings,"Side", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings,"GroupSideName", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings,"FactionName", "rhsgref_faction_cdf_ng"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings,"GroupFactionName", "rhsgref_faction_cdf_ng"] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings,"GroupFactionTypes", rhsgref_faction_cdf_ng_typeMappings] call ALiVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings,"Groups", rhsgref_faction_cdf_ng_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhsgref_faction_cdf_ng", rhsgref_faction_cdf_ng_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports,"rhsgref_faction_cdf_ng", ["rhs_group_cdf_bmp1_chq","rhs_group_cdf_bmp1_squad","rhs_group_cdf_bmp1_squad_2mg","rhs_group_cdf_bmp1_squad_sniper","rhs_group_cdf_bmp1_squad_mg_sniper","rhs_group_cdf_bmp1_squad_aa","rhs_group_cdf_bmp2_chq","rhs_group_cdf_bmp2_squad","rhs_group_cdf_bmp2_squad_2mg","rhs_group_cdf_bmp2_squad_sniper","rhs_group_cdf_bmp2_squad_mg_sniper","rhs_group_cdf_bmp2_squad_aa","rhs_group_cdf_btr70_chq","rhs_group_cdf_btr70_squad","rhs_group_cdf_btr70_squad_2mg","rhs_group_cdf_btr70_squad_sniper","rhs_group_cdf_btr70_squad_mg_sniper","rhs_group_cdf_btr70_squad_aa","rhs_group_cdf_btr60_chq","rhs_group_cdf_btr60_squad","rhs_group_cdf_btr60_squad_2mg","rhs_group_cdf_btr60_squad_sniper","rhs_group_cdf_btr60_squad_mg_sniper","rhs_group_cdf_btr60_squad_aa","rhs_group_cdf_bmd1_chq","rhs_group_cdf_bmd1_squad","rhs_group_cdf_bmd1_squad_2mg","rhs_group_cdf_bmd1_squad_sniper","rhs_group_cdf_bmd1_squad_mg_sniper","rhs_group_cdf_bmd1_squad_aa","rhs_group_cdf_bmd2_chq","rhs_group_cdf_bmd2_squad","rhs_group_cdf_bmd2_squad_2mg","rhs_group_cdf_bmd2_squad_sniper","rhs_group_cdf_bmd2_squad_mg_sniper","rhs_group_cdf_bmd2_squad_aa"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport,"rhsgref_faction_cdf_ng", ["rhsgref_cdf_ural","rhsgref_cdf_ural_open","rhsgref_cdf_gaz66","rhsgref_cdf_gaz66o"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport,"rhsgref_faction_cdf_ng", ["rhsgref_cdf_reg_Mi8amt"]] call ALIVE_fnc_hashSet;

// rhsgref_faction_chdkz_g

rhsgref_faction_chdkz_g_typeMappings = [] call ALiVE_fnc_hashCreate;

rhsgref_faction_chdkz_g_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Infantry", ["rhsgref_group_chdkz_ins_gurgents_squad","rhsgref_group_chdkz_infantry_patrol","rhsgref_group_chdkz_infantry_mg","rhsgref_group_chdkz_infantry_at","rhsgref_group_chdkz_infantry_aa"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Motorized", ["rhs_group_chdkz_ural_chq","rhs_group_chdkz_ural_squad","rhs_group_chdkz_ural_squad_2mg","rhs_group_chdkz_ural_squad_sniper","rhs_group_chdkz_ural_squad_mg_sniper","rhs_group_chdkz_ural_squad_aa","rhs_group_chdkz_g_gaz66_chq","rhs_group_chdkz_g_gaz66_squad","rhs_group_chdkz_g_gaz66_squad_2mg","rhs_group_chdkz_g_gaz66_squad_sniper","rhs_group_chdkz_g_gaz66_squad_mg_sniper","rhs_group_chdkz_g_gaz66_squad_aa","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Mechanized", ["rhs_group_rus_ins_g_bmd1_chq","rhs_group_rus_ins_g_bmd1_squad","rhs_group_rus_ins_g_bmd1_squad_2mg","rhs_group_rus_ins_g_bmd1_squad_sniper","rhs_group_rus_ins_g_bmd1_squad_mg_sniper","rhs_group_rus_ins_g_bmd1_squad_aa","rhs_group_rus_ins_g_bmd2_chq","rhs_group_rus_ins_g_bmd2_squad","rhs_group_rus_ins_g_bmd2_squad_2mg","rhs_group_rus_ins_g_bmd2_squad_sniper","rhs_group_rus_ins_g_bmd2_squad_mg_sniper","rhs_group_rus_ins_g_bmd2_squad_aa","rhs_group_indp_ins_g_bmp1_chq","rhs_group_indp_ins_g_bmp1_squad","rhs_group_indp_ins_g_bmp1_squad_2mg","rhs_group_indp_ins_g_bmp1_squad_sniper","rhs_group_indp_ins_g_bmp1_squad_mg_sniper","rhs_group_indp_ins_g_bmp1_squad_aa","rhs_group_indp_ins_g_bmp2_chq","rhs_group_indp_ins_g_bmp2_squad","rhs_group_indp_ins_g_bmp2_squad_2mg","rhs_group_indp_ins_g_bmp2_squad_sniper","rhs_group_indp_ins_g_bmp2_squad_mg_sniper","rhs_group_indp_ins_g_bmp2_squad_aa","rhs_group_chdkz_btr70_chq","rhs_group_chdkz_btr70_squad","rhs_group_chdkz_btr70_squad_2mg","rhs_group_chdkz_btr70_squad_sniper","rhs_group_chdkz_btr70_squad_mg_sniper","rhs_group_chdkz_btr70_squad_aa","rhs_group_chdkz_btr60_chq","rhs_group_chdkz_btr60_squad","rhs_group_chdkz_btr60_squad_2mg","rhs_group_chdkz_btr60_squad_sniper","rhs_group_chdkz_btr60_squad_mg_sniper","rhs_group_chdkz_btr60_squad_aa"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Armored", ["RHS_T72baPlatoon","RHS_T72baPlatoon_AA","RHS_T72baSection","RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection","RHS_t72bcPlatoon","RHS_t72bcPlatoon_AA","RHS_t72bcSection"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Artillery", ["RHS_SPGPlatoon_ins_g_bm21","RHS_SPGSection_ins_g_bm21"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhsgref_faction_chdkz_g_mappings = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_chdkz_g_mappings,"Side", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings,"GroupSideName", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings,"FactionName", "rhsgref_faction_chdkz_g"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings,"GroupFactionName", "rhsgref_faction_chdkz_g"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings,"GroupFactionTypes", rhsgref_faction_chdkz_g_typeMappings] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings,"Groups", rhsgref_faction_chdkz_g_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhsgref_faction_chdkz_g", rhsgref_faction_chdkz_g_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports,"rhsgref_faction_chdkz_g", ["rhs_group_chdkz_ural_chq","rhs_group_chdkz_ural_squad","rhs_group_chdkz_ural_squad_2mg","rhs_group_chdkz_ural_squad_sniper","rhs_group_chdkz_ural_squad_mg_sniper","rhs_group_chdkz_ural_squad_aa","rhs_group_chdkz_g_gaz66_chq","rhs_group_chdkz_g_gaz66_squad","rhs_group_chdkz_g_gaz66_squad_2mg","rhs_group_chdkz_g_gaz66_squad_sniper","rhs_group_chdkz_g_gaz66_squad_mg_sniper","rhs_group_chdkz_g_gaz66_squad_aa","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport,"rhsgref_faction_chdkz_g", ["rhsgref_ins_ural","rhsgref_ins_ural_open","rhsgref_ins_gaz66","rhsgref_ins_gaz66o"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport,"rhsgref_faction_chdkz_g", ["RHS_Mi8mt_Cargo_vdv"]] call ALIVE_fnc_hashSet;

// rhsgref_faction_chdkz

rhsgref_faction_chdkz_typeMappings = [] call ALiVE_fnc_hashCreate;

rhsgref_faction_chdkz_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_chdkz_factionCustomGroups,"Infantry", ["rhsgref_group_chdkz_insurgents_squad","rhsgref_group_chdkz_infantry_patrol","rhsgref_group_chdkz_infantry_mg","rhsgref_group_chdkz_infantry_at","rhsgref_group_chdkz_infantry_aa"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Motorized", ["rhs_group_chdkz_ural_chq","rhs_group_chdkz_ural_squad","rhs_group_chdkz_ural_squad_2mg","rhs_group_chdkz_ural_squad_sniper","rhs_group_chdkz_ural_squad_mg_sniper","rhs_group_chdkz_ural_squad_aa","rhs_group_chdkz_gaz66_chq","rhs_group_chdkz_gaz66_squad","rhs_group_chdkz_gaz66_squad_2mg","rhs_group_chdkz_gaz66_squad_sniper","rhs_group_chdkz_gaz66_squad_mg_sniper","rhs_group_chdkz_gaz66_squad_aa","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Mechanized", ["rhs_group_rus_ins_bmd1_chq","rhs_group_rus_ins_bmd1_squad","rhs_group_rus_ins_bmd1_squad_2mg","rhs_group_rus_ins_bmd1_squad_sniper","rhs_group_rus_ins_bmd1_squad_mg_sniper","rhs_group_rus_ins_bmd1_squad_aa","rhs_group_rus_ins_bmd2_chq","rhs_group_rus_ins_bmd2_squad","rhs_group_rus_ins_bmd2_squad_2mg","rhs_group_rus_ins_bmd2_squad_sniper","rhs_group_rus_ins_bmd2_squad_mg_sniper","rhs_group_rus_ins_bmd2_squad_aa","rhs_group_indp_ins_bmp1_chq","rhs_group_indp_ins_bmp1_squad","rhs_group_indp_ins_bmp1_squad_2mg","rhs_group_indp_ins_bmp1_squad_sniper","rhs_group_indp_ins_bmp1_squad_mg_sniper","rhs_group_indp_ins_bmp1_squad_aa","rhs_group_indp_ins_bmp2_chq","rhs_group_indp_ins_bmp2_squad","rhs_group_indp_ins_bmp2_squad_2mg","rhs_group_indp_ins_bmp2_squad_sniper","rhs_group_indp_ins_bmp2_squad_mg_sniper","rhs_group_indp_ins_bmp2_squad_aa","rhs_group_chdkz_btr70_chq","rhs_group_chdkz_btr70_squad","rhs_group_chdkz_btr70_squad_2mg","rhs_group_chdkz_btr70_squad_sniper","rhs_group_chdkz_btr70_squad_mg_sniper","rhs_group_chdkz_btr70_squad_aa","rhs_group_chdkz_btr60_chq","rhs_group_chdkz_btr60_squad","rhs_group_chdkz_btr60_squad_2mg","rhs_group_chdkz_btr60_squad_sniper","rhs_group_chdkz_btr60_squad_mg_sniper","rhs_group_chdkz_btr60_squad_aa"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Armored", ["RHS_T72baPlatoon","RHS_T72baPlatoon_AA","RHS_T72baSection","RHS_T72BBPlatoon","RHS_T72BBPlatoon_AA","RHS_T72BBSection","RHS_t72bcPlatoon","RHS_t72bcPlatoon_AA","RHS_t72bcSection"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Artillery", ["RHS_SPGPlatoon_ins_bm21","RHS_SPGSection_ins_bm21"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhsgref_faction_chdkz_mappings = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_chdkz_mappings,"Side", "EAST"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings,"GroupSideName", "EAST"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings,"FactionName", "rhsgref_faction_chdkz"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings,"GroupFactionName", "rhsgref_faction_chdkz"] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings,"GroupFactionTypes", rhsgref_faction_chdkz_typeMappings] call ALiVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings,"Groups", rhsgref_faction_chdkz_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhsgref_faction_chdkz", rhsgref_faction_chdkz_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports,"rhsgref_faction_chdkz", ["rhs_group_chdkz_ural_chq","rhs_group_chdkz_ural_squad","rhs_group_chdkz_ural_squad_2mg","rhs_group_chdkz_ural_squad_sniper","rhs_group_chdkz_ural_squad_mg_sniper","rhs_group_chdkz_ural_squad_aa","rhs_group_chdkz_g_gaz66_chq","rhs_group_chdkz_g_gaz66_squad","rhs_group_chdkz_g_gaz66_squad_2mg","rhs_group_chdkz_g_gaz66_squad_sniper","rhs_group_chdkz_g_gaz66_squad_mg_sniper","rhs_group_chdkz_g_gaz66_squad_aa","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport,"rhsgref_faction_chdkz", ["rhsgref_ins_ural","rhsgref_ins_ural_open","rhsgref_ins_gaz66","rhsgref_ins_gaz66o"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport,"rhsgref_faction_chdkz", ["RHS_Mi8mt_Cargo_vdv"]] call ALIVE_fnc_hashSet;

// rhsgref_faction_nationalist

rhsgref_faction_nationalist_typeMappings = [] call ALiVE_fnc_hashCreate;

rhsgref_faction_nationalist_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_nationalist_factionCustomGroups,"Infantry", ["rhsgref_group_national_infantry_squad","rhsgref_group_national_infantry_squad_2","rhsgref_group_national_infantry_patrol","rhsgref_group_national_infantry_mg","rhsgref_group_national_infantry_at"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Motorized", ["rhs_group_nat_ural_chq","rhs_group_nat_ural_squad","rhs_group_nat_ural_squad_2mg","rhs_group_nat_ural_squad_sniper","rhs_group_nat_ural_squad_mg_sniper","rhs_group_nat_ural_squad_aa","BUS_MotInf_Team_GMG","BUS_MotInf_Team_HMG","BUS_MotInf_AT","BUS_MotInf_AA"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Mechanized", ["rhs_group_nat_btr70_chq","rhs_group_nat_btr70_squad","rhs_group_nat_btr70_squad_2mg","rhs_group_nat_btr70_squad_sniper","rhs_group_nat_btr70_squad_mg_sniper","rhs_group_nat_btr70_squad_aa"]] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Armored", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Artillery", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhsgref_faction_nationalist_mappings = [] call ALiVE_fnc_hashCreate;
[rhsgref_faction_nationalist_mappings,"Side", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings,"GroupSideName", "GUER"] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings,"FactionName", "rhsgref_faction_nationalist"] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings,"GroupFactionName", "rhsgref_faction_nationalist"] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings,"GroupFactionTypes", rhsgref_faction_nationalist_typeMappings] call ALiVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings,"Groups", rhsgref_faction_nationalist_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhsgref_faction_nationalist", rhsgref_faction_nationalist_mappings] call ALiVE_fnc_hashSet;

// rhssaf_faction_un

rhssaf_faction_un_typeMappings = [] call ALiVE_fnc_hashCreate;

rhssaf_faction_un_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhssaf_faction_un_factionCustomGroups,"Infantry", ["rhssaf_group_un_infantry_company_hq","rhssaf_group_un_infantry_platoon_hq","rhssaf_group_un_infantry_infantry_squad","rhssaf_group_un_infantry_infantry_weaponsquad","rhssaf_group_un_infantry_infantry_squad_sniper","rhssaf_group_un_infantry_infantry_team","rhssaf_group_un_infantry_infantry_team_mg","rhssaf_group_un_infantry_infantry_team_AA","rhssaf_group_un_infantry_infantry_team_support","rhssaf_group_un_infantry_infantry_team_heavy_at"]] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"SpecOps", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Motorized", ["rhssaf_group_un_motorized_infantry_team_at","rhssaf_group_un_motorized_infantry_team_aa","rhssaf_group_un_ural_squad","rhssaf_group_un_ural_squad_mg","rhssaf_group_un_ural_squad_sniper","rhssaf_group_un_ural_squad_mg_sniper"]] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Mechanized", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Armored", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Artillery", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhssaf_faction_un_mappings = [] call ALiVE_fnc_hashCreate;
[rhssaf_faction_un_mappings,"Side", "GUER"] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_mappings,"GroupSideName", "GUER"] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_mappings,"FactionName", "rhssaf_faction_un"] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_mappings,"GroupFactionName", "rhssaf_faction_un"] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_mappings,"GroupFactionTypes", rhssaf_faction_un_typeMappings] call ALiVE_fnc_hashSet;
[rhssaf_faction_un_mappings,"Groups", rhssaf_faction_un_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhssaf_faction_un", rhssaf_faction_un_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports,"rhsgref_faction_chdkz", ["rhssaf_group_un_motorized_infantry_team_at","rhssaf_group_un_motorized_infantry_team_aa","rhssaf_group_un_ural_squad","rhssaf_group_un_ural_squad_mg","rhssaf_group_un_ural_squad_sniper","rhssaf_group_un_ural_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport,"rhsgref_faction_chdkz", ["rhssaf_un_ural"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport,"rhsgref_faction_chdkz", ["rhssaf_airforce_ht48"]] call ALIVE_fnc_hashSet;

// rhssaf_faction_army

rhssaf_faction_army_typeMappings = [] call ALiVE_fnc_hashCreate;

rhssaf_faction_army_factionCustomGroups = [] call ALiVE_fnc_hashCreate;
[rhssaf_faction_army_factionCustomGroups,"Infantry", ["rhssaf_group_army_m10_digital_company_hq","rhssaf_group_army_m10_digital_platoon_hq","rhssaf_group_army_m10_digital_infantry_squad","rhssaf_group_army_m10_digital_infantry_weaponsquad","rhssaf_group_army_m10_digital_infantry_squad_sniper","rhssaf_group_army_m10_digital_infantry_team","rhssaf_group_army_m10_digital_infantry_team_mg","rhssaf_group_army_m10_digital_infantry_team_AA","rhssaf_group_army_m10_digital_infantry_team_support","rhssaf_group_army_m10_digital_infantry_team_heavy_at"]] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"SpecOps", ["rhssaf_group_army_m10_para_company_hq","rhssaf_group_army_m10_para_platoon_hq","rhssaf_group_army_m10_para_infantry_squad","rhssaf_group_army_m10_para_infantry_weaponsquad","rhssaf_group_army_m10_para_infantry_squad_sniper","rhssaf_group_army_m10_para_infantry_team","rhssaf_group_army_m10_para_infantry_team_mg","rhssaf_group_army_m10_para_infantry_team_AA","rhssaf_group_army_m10_para_infantry_team_support","rhssaf_group_army_m10_para_infantry_team_heavy_at"]] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Motorized", ["rhssaf_group_army_motorized_infantry_team_hmg","rhssaf_group_army_motorized_infantry_team_at","rhssaf_group_army_motorized_infantry_team_aa","rhssaf_group_army_ural_squad","rhssaf_group_army_ural_squad_mg","rhssaf_group_army_ural_squad_sniper","rhssaf_group_army_ural_squad_mg_sniper"]] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Motorized_MTP", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Mechanized", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Armored", ["rhssaf_army_group_t72s_platoon","rhssaf_army_group_t72s_section"]] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Artillery", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Naval", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Air", []] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_factionCustomGroups,"Support", []] call ALiVE_fnc_hashSet;

rhssaf_faction_army_mappings = [] call ALiVE_fnc_hashCreate;
[rhssaf_faction_army_mappings,"Side", "GUER"] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_mappings,"GroupSideName", "GUER"] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_mappings,"FactionName", "rhssaf_faction_army"] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_mappings,"GroupFactionName", "rhssaf_faction_army"] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_mappings,"GroupFactionTypes", rhssaf_faction_army_typeMappings] call ALiVE_fnc_hashSet;
[rhssaf_faction_army_mappings,"Groups", rhssaf_faction_army_factionCustomGroups] call ALiVE_fnc_hashSet;

[ALiVE_factionCustomMappings,"rhssaf_faction_army", rhssaf_faction_army_mappings] call ALiVE_fnc_hashSet;

[ALIVE_factionDefaultSupports,"rhsgref_faction_chdkz", ["rhssaf_group_army_motorized_infantry_team_hmg","rhssaf_group_army_motorized_infantry_team_at","rhssaf_group_army_motorized_infantry_team_aa","rhssaf_group_army_ural_squad","rhssaf_group_army_ural_squad_mg","rhssaf_group_army_ural_squad_sniper","rhssaf_group_army_ural_squad_mg_sniper"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport,"rhsgref_faction_chdkz", ["rhssaf_army_ural","rhssaf_army_ural_open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport,"rhsgref_faction_chdkz", ["rhssaf_airforce_ht48"]] call ALIVE_fnc_hashSet;

// ---------------------------------------------------------------------------------------------------------------------


// IRON FRONT
// ---------------------------------------------------------------------------------------------------------------------


// LIB_RKKA

[ALIVE_factionDefaultSupports, "LIB_RKKA", ["lib_maxim_m30_base","lib_maxim_m30_trench","lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel","SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3","lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_RKKA", ["LIB_BasicAmmunitionBox_SU","LIB_Mine_Ammo_Box_Su","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_RKKA", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;

// LIB_USSR_TANK_TROOPS

[ALIVE_factionDefaultSupports, "LIB_USSR_TANK_TROOPS", ["lib_maxim_m30_base","lib_maxim_m30_trench","lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel","SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3","lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_USSR_TANK_TROOPS", ["LIB_BasicAmmunitionBox_SU","LIB_Mine_Ammo_Box_Su","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_USSR_TANK_TROOPS", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;


// LIB_USSR_AIRFORCE

[ALIVE_factionDefaultSupports, "LIB_USSR_AIRFORCE", ["lib_maxim_m30_base","lib_maxim_m30_trench","lib_us6_ammo","lib_zis5v_med","lib_zis6_parm","lib_zis5v_fuel","SearchLight_SU","LIB_BM37","LIB_61k","LIB_Zis3","lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_USSR_AIRFORCE", ["LIB_BasicAmmunitionBox_SU","LIB_Mine_Ammo_Box_Su","LIB_WeaponsBox_Big_SU","LIB_Lone_Big_Box","LIB_BasicWeaponsBox_SU","LIB_AmmoCrate_Mortar_SU","LIB_AmmoCrate_Arty_SU"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_USSR_AIRFORCE", ["lib_us6_open","lib_us6_tent","lib_us6_bm13","Lib_Willys_MB","LIB_Scout_m3","lib_zis5v","Lib_SdKfz251_captured","LIB_SOV_M3_Halftrack"]] call ALIVE_fnc_hashSet;

// LNRD_Luft

[ALIVE_factionDefaultSupports, "LNRD_Luft", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LNRD_Luft", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LNRD_Luft", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

// SG_STURM

[ALIVE_factionDefaultSupports, "SG_STURM", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "SG_STURM", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SG_STURM", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

// LIB_WEHRMACHT

[ALIVE_factionDefaultSupports, "LIB_WEHRMACHT", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_WEHRMACHT", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_WEHRMACHT", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

// LIB_PANZERWAFFE

[ALIVE_factionDefaultSupports, "LIB_PANZERWAFFE", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_PANZERWAFFE", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_PANZERWAFFE", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

// LIB_LUFTWAFFE

[ALIVE_factionDefaultSupports, "LIB_LUFTWAFFE", ["LIB_MG42_Lafette","LIB_MG42_Lafette_trench","LIB_MG42_Lafette_low","LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA","SearchLight_GER","LIB_GrWr34","LIB_FlaK_38","LIB_Flakvierling_38","LIB_Pak40","LIB_opelblitz_fuel","LIB_opelblitz_ambulance","LIB_opelblitz_parm","lib_opelblitz_ammo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_LUFTWAFFE", ["LIB_WeaponsBox_Big_GER","LIB_Mine_Ammo_Box_Ger","LIB_BasicAmmunitionBox_GER","LIB_BasicWeaponsBox_GER","lib_4Rnd_RPzB","LIB_AmmoCrate_Arty_GER","LIB_AmmoCrate_Mortar_GER"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_LUFTWAFFE", ["LIB_kfz1","Lib_sdkfz251","LIB_opelblitz_open_y_camo","LIB_opelblitz_tent_y_camo","LIB_SdKfz_7","LIB_SdKfz_7_AA"]] call ALIVE_fnc_hashSet;

// LIB_GUER

[ALIVE_factionDefaultSupports, "LIB_GUER", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_GUER", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_GUER", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;

// LIB_US_ARMY

[ALIVE_factionDefaultSupports, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_ARMY", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_ARMY", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;

// LIB_US_TANK_TROOPS

[ALIVE_factionDefaultSupports, "LIB_US_TANK_TROOPS", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_TANK_TROOPS", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_TANK_TROOPS", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;

// LIB_US_AIRFORCE

[ALIVE_factionDefaultSupports, "LIB_US_AIRFORCE", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent","LIB_US_GMC_Ammo","LIB_US_GMC_Ambulance","LIB_US_GMC_Parm","LIB_US_GMC_Fuel"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultSupplies, "LIB_US_AIRFORCE", ["LIB_BasicAmmunitionBox_US","LIB_BasicWeaponsBox_US","LIB_Mine_AmmoBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "LIB_US_AIRFORCE", ["LIB_US_Willys_MB","LIB_US_M3_Halftrack","LIB_US_Scout_m3","LIB_US_GMC_Open","LIB_US_GMC_Tent"]] call ALIVE_fnc_hashSet;

// ---------------------------------------------------------------------------------------------------------------------



// UNSUNG A3
// ---------------------------------------------------------------------------------------------------------------------

// UNSUNG_E

unsung_e_mappings = [] call ALIVE_fnc_hashCreate;
[unsung_e_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[unsung_e_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[unsung_e_mappings, "FactionName", "UNSUNG_E"] call ALIVE_fnc_hashSet;
[unsung_e_mappings, "GroupFactionName", "UNSUNG_E_NVA"] call ALIVE_fnc_hashSet;

unsung_e_typeMappings = [] call ALIVE_fnc_hashCreate;
[unsung_e_typeMappings, "Air", "uns_eastairplanes"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Armored", "uns_nvatrackedvehicles"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Infantry", "NVA68Infantry"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Mechanized", "uns_nvapatrolvehicles"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Motorized", "uns_nvapatrolvehicles"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Motorized_MTP", "uns_nvapatrolvehicles"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "SpecOps", "DacCongInfantry"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Support", "NVA65Infantry"] call ALIVE_fnc_hashSet;

[unsung_e_mappings, "GroupFactionTypes", unsung_e_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "UNSUNG_E", unsung_e_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "UNSUNG_E", ["uns_medcrate","uns_82mmammobox_VC","uns_AmmoBoxNVA","uns_EQPT_NVA","uns_resupply_crate_NVA"]] call ALIVE_fnc_hashSet;

// UNSUNG_W

unsung_w_mappings = [] call ALIVE_fnc_hashCreate;
[unsung_w_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[unsung_w_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[unsung_w_mappings, "FactionName", "UNSUNG_W"] call ALIVE_fnc_hashSet;
[unsung_w_mappings, "GroupFactionName", "UNSUNG_W_US"] call ALIVE_fnc_hashSet;

unsung_w_typeMappings = [] call ALIVE_fnc_hashCreate;
[unsung_w_typeMappings, "Air", "uns_UShelis"] call ALIVE_fnc_hashSet;
[unsung_w_typeMappings, "Armored", "UNS_ustrackedvehicles"] call ALIVE_fnc_hashSet;
[unsung_w_typeMappings, "Infantry", "ussfInfantry68"] call ALIVE_fnc_hashSet;
[unsung_w_typeMappings, "Mechanized", "UNS_ustrackedvehicles"] call ALIVE_fnc_hashSet;
[unsung_w_typeMappings, "Motorized", "UNS_ustrackedvehicles"] call ALIVE_fnc_hashSet;
[unsung_w_typeMappings, "Motorized_MTP", "UNS_ustrackedvehicles"] call ALIVE_fnc_hashSet;
[unsung_w_typeMappings, "SpecOps", "LRRPS_1AC"] call ALIVE_fnc_hashSet;
[unsung_w_typeMappings, "Support", "usarmyInfantry25ID"] call ALIVE_fnc_hashSet;

[unsung_w_mappings, "GroupFactionTypes", unsung_w_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "UNSUNG_W", unsung_w_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "UNSUNG_W", ["uns_medcrate","uns_82mmammobox_US","uns_AmmoBoxUS_army","uns_EQPT_US","uns_resupply_crate_US"]] call ALIVE_fnc_hashSet;

// ---------------------------------------------------------------------------------------------------------------------

// Global Mobilization
// gm_dk_army_m84 / gm_dk_army_win

gm_dk_army_m84_mappings = [] call ALIVE_fnc_hashCreate;
[gm_dk_army_m84_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[gm_dk_army_m84_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[gm_dk_army_m84_mappings, "FactionName", "gm_fc_DK"] call ALIVE_fnc_hashSet;
[gm_dk_army_m84_mappings, "GroupFactionName", "gm_fc_DK"] call ALIVE_fnc_hashSet;

gm_dk_army_m84_typeMappings = [] call ALIVE_fnc_hashCreate;
[gm_dk_army_m84_typeMappings, "Infantry", "gm_infantry"] call ALIVE_fnc_hashSet;
[gm_dk_army_m84_mappings, "GroupFactionTypes", gm_dk_army_m84_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "gm_fc_DK", gm_dk_army_m84_mappings] call ALIVE_fnc_hashSet;

gm_dk_army_win_mappings = [] call ALIVE_fnc_hashCreate;
[gm_dk_army_win_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[gm_dk_army_win_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[gm_dk_army_win_mappings, "FactionName", "gm_dk_army_win"] call ALIVE_fnc_hashSet;
[gm_dk_army_win_mappings, "GroupFactionName", "gm_dk_army_win"] call ALIVE_fnc_hashSet;

gm_dk_army_win_typeMappings = [] call ALIVE_fnc_hashCreate;
[gm_dk_army_win_typeMappings, "Infantry", "gm_infantry"] call ALIVE_fnc_hashSet;
[gm_dk_army_win_mappings, "GroupFactionTypes", gm_dk_army_win_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "gm_dk_army_win", gm_dk_army_win_mappings] call ALIVE_fnc_hashSet;

// gm_ge_army / gm_ge_army_win

gm_ge_army_mappings = [] call ALIVE_fnc_hashCreate;
[gm_ge_army_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[gm_ge_army_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[gm_ge_army_mappings, "FactionName", "gm_fc_GE"] call ALIVE_fnc_hashSet;
[gm_ge_army_mappings, "GroupFactionName", "gm_fc_GE"] call ALIVE_fnc_hashSet;

gm_ge_army_typeMappings = [] call ALIVE_fnc_hashCreate;
[gm_ge_army_typeMappings, "Air", "gm_air"] call ALIVE_fnc_hashSet;
[gm_ge_army_typeMappings, "Armored", "gm_armored"] call ALIVE_fnc_hashSet;
[gm_ge_army_typeMappings, "Infantry", "gm_infantry"] call ALIVE_fnc_hashSet;
[gm_ge_army_typeMappings, "Mechanized", "gm_mechanizedInfantry"] call ALIVE_fnc_hashSet;
[gm_ge_army_typeMappings, "Motorized", "gm_motorizedinfantry"] call ALIVE_fnc_hashSet;
[gm_ge_army_typeMappings, "Support", "gm_support"] call ALIVE_fnc_hashSet;
[gm_ge_army_mappings, "GroupFactionTypes", gm_ge_army_typeMappings] call ALIVE_fnc_hashSet;

gm_ge_army_factionCustomGroups = [] call ALIVE_fnc_hashCreate;
[gm_ge_army_factionCustomGroups, "gm_motorizedinfantry", ["gm_ge_army_mechanizedInfantry_squad_m113a1g","gm_ge_army_motorizedInfantry_squad_u1300l","gm_ge_army_mechanizedInfantry_squad_fuchs1a0_milan"]] call ALIVE_fnc_hashSet;
[gm_ge_army_factionCustomGroups, "gm_supply", ["gm_ge_army_supply_team_01"]] call ALIVE_fnc_hashSet;
[gm_ge_army_factionCustomGroups, "gm_armored", ["gm_platoon_gm_ge_army_Leopard1a1a1_wdl","gm_platoon_gm_ge_army_Leopard1a3_wdl"]] call ALIVE_fnc_hashSet;
[gm_ge_army_factionCustomGroups, "gm_mechanizedInfantry", ["gm_ge_army_mechanizedInfantry_squad_m113a1g"]] call ALIVE_fnc_hashSet;
[gm_ge_army_factionCustomGroups, "gm_recon", ["gm_platoon_gm_ge_army_iltis_cargo_wdl"]] call ALIVE_fnc_hashSet;
[gm_ge_army_factionCustomGroups, "gm_AntiTank", ["gm_platoon_gm_ge_army_iltis_milan_wdl"]] call ALIVE_fnc_hashSet;
[gm_ge_army_factionCustomGroups, "gm_infantry", ["gm_ge_army_infantry_squad_80_ols","gm_ge_army_infantry_mggroup_80_ols","gm_ge_army_infantry_atgroup_80_ols","gm_ge_army_infantry_atgmgroup_80_ols"]] call ALIVE_fnc_hashSet;
[gm_ge_army_factionCustomGroups, "gm_antiair", ["gm_platoon_gm_ge_army_fuchsa0_command_wdl_gm_ge_army_gepard1a1_wdl","gm_platoon_gm_ge_army_gepard1a1_wdl"]] call ALIVE_fnc_hashSet;
[gm_ge_army_mappings, "Groups", gm_ge_army_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "gm_fc_GE", gm_ge_army_mappings] call ALIVE_fnc_hashSet;

gm_ge_army_win_mappings = [] call ALIVE_fnc_hashCreate;
[gm_ge_army_win_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_mappings, "FactionName", "gm_ge_army_win"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_mappings, "GroupFactionName", "gm_ge_army_win"] call ALIVE_fnc_hashSet;

gm_ge_army_win_typeMappings = [] call ALIVE_fnc_hashCreate;
[gm_ge_army_win_typeMappings, "Air", "gm_air"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_typeMappings, "Armored", "gm_armored"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_typeMappings, "Infantry", "gm_infantry"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_typeMappings, "Mechanized", "gm_mechanizedInfantry"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_typeMappings, "Motorized", "gm_motorizedinfantry"] call ALIVE_fnc_hashSet;
[gm_ge_army_win_typeMappings, "Support", "gm_support"] call ALIVE_fnc_hashSet;

[gm_ge_army_win_mappings, "GroupFactionTypes", gm_ge_army_win_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "gm_ge_army_win", gm_ge_army_win_mappings] call ALIVE_fnc_hashSet;

// gm_gc_army / gm_gc_army_win

// ----------------------------------------------------------------------------------------------------------------------
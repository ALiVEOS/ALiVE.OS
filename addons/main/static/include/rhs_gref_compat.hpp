//==========================================//
// rhsgref_faction_cdf_b_ground             //
//==========================================//

rhsgref_faction_cdf_b_ground_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_cdf_b_ground_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_b_ground_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_mappings, "FactionName", "rhsgref_faction_cdf_b_ground"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_mappings, "GroupFactionName", "rhsgref_faction_cdf_b_ground"] call ALIVE_fnc_hashSet;

rhsgref_faction_cdf_b_ground_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_b_ground_mappings, "GroupFactionTypes", rhsgref_faction_cdf_b_ground_typeMappings] call ALIVE_fnc_hashSet;

// Remark: as for now, CfgGroups entries for: rhs_group_cdf_b_gaz66, rhs_group_cdf_b_gaz66_para and rhs_group_cdf_b_ural share the same group names.
// Is there a way to distinguish them?
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Infantry", ["rhsgref_group_cdf_b_reg_infantry_squad", "rhsgref_group_cdf_b_reg_infantry_squad_weap","rhsgref_group_cdf_b_para_infantry_squad", "rhsgref_group_cdf_b_para_infantry_squad_weap"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Motorized", ["rhs_group_cdf_b_btr60_chq", "rhs_group_cdf_b_btr60_squad", "rhs_group_cdf_b_btr60_squad_2mg", "rhs_group_cdf_b_btr60_squad_aa", "rhs_group_cdf_b_btr60_squad_mg_sniper", "rhs_group_cdf_b_btr60_squad_sniper", "rhs_group_cdf_b_btr70_chq", "rhs_group_cdf_b_btr70_squad", "rhs_group_cdf_b_btr70_squad_2mg", "rhs_group_cdf_b_btr70_squad_aa", "rhs_group_cdf_b_btr70_squad_mg_sniper", "rhs_group_cdf_b_btr70_squad_sniper", "rhs_group_cdf_b_ural_chq", "rhs_group_cdf_b_ural_squad", "rhs_group_cdf_b_ural_squad_2mg", "rhs_group_cdf_b_ural_squad_aa", "rhs_group_cdf_b_ural_squad_mg_sniper", "rhs_group_cdf_b_ural_squad_sniper", "BUS_MotInf_AA", "BUS_MotInf_AT", "BUS_MotInf_Team_GMG", "BUS_MotInf_Team_HMG"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Mechanized", ["rhs_group_cdf_b_bmd1_chq", "rhs_group_cdf_b_bmd1_squad", "rhs_group_cdf_b_bmd1_squad_2mg", "rhs_group_cdf_b_bmd1_squad_aa", "rhs_group_cdf_b_bmd1_squad_mg_sniper", "rhs_group_cdf_b_bmd1_squad_sniper", "rhs_group_cdf_b_bmd2_chq", "rhs_group_cdf_b_bmd2_squad", "rhs_group_cdf_b_bmd2_squad_2mg", "rhs_group_cdf_b_bmd2_squad_aa", "rhs_group_cdf_b_bmd2_squad_mg_sniper", "rhs_group_cdf_b_bmd2_squad_sniper", "rhs_group_cdf_b_bmp1_chq", "rhs_group_cdf_b_bmp1_squad", "rhs_group_cdf_b_bmp1_squad_2mg", "rhs_group_cdf_b_bmp1_squad_aa", "rhs_group_cdf_b_bmp1_squad_mg_sniper", "rhs_group_cdf_b_bmp1_squad_sniper", "rhs_group_cdf_b_bmp2_chq", "rhs_group_cdf_b_bmp2_squad", "rhs_group_cdf_b_bmp2_squad_2mg", "rhs_group_cdf_b_bmp2_squad_aa", "rhs_group_cdf_b_bmp2_squad_mg_sniper", "rhs_group_cdf_b_bmp2_squad_sniper"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Armored", ["RHS_T72baPlatoon", "RHS_T72baPlatoon_AA", "RHS_T72baSection"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_ins_g_bm21", "RHS_SPGSection_ins_g_bm21"]] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_b_ground_mappings, "Groups", rhsgref_faction_cdf_b_ground_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_cdf_b_ground", rhsgref_faction_cdf_b_ground_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_cdf_b_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_cdf_b_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_cdf_b_ground", []] call ALIVE_fnc_hashSet;

//==========================================//
// rhsgref_faction_chdkz                    //
//==========================================//

rhsgref_faction_chdkz_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_chdkz_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings, "FactionName", "rhsgref_faction_chdkz"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings, "GroupFactionName", "rhsgref_faction_chdkz"] call ALIVE_fnc_hashSet;

rhsgref_faction_chdkz_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_mappings, "GroupFactionTypes", rhsgref_faction_chdkz_typeMappings] call ALIVE_fnc_hashSet;

// Remark: as for now, CfgGroups entries for: rhs_group_indp_ins_gaz66 and rhs_group_indp_ins_ural share the same group names.
// Is there a way to distinguish them?
[rhsgref_faction_chdkz_factionCustomGroups, "Infantry", "rhsgref_group_chdkz_infantry_aa", "rhsgref_group_chdkz_infantry_at", "rhsgref_group_chdkz_infantry_mg", "rhsgref_group_chdkz_infantry_patrol", "rhsgref_group_chdkz_insurgents_squad"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Motorized", ["rhs_group_chdkz_btr60_chq", "rhs_group_chdkz_btr60_squad", "rhs_group_chdkz_btr60_squad_2mg", "rhs_group_chdkz_btr60_squad_aa", "rhs_group_chdkz_btr60_squad_mg_sniper", "rhs_group_chdkz_btr60_squad_sniper", "rhs_group_chdkz_btr70_chq", "rhs_group_chdkz_btr70_squad", "rhs_group_chdkz_btr70_squad_2mg", "rhs_group_chdkz_btr70_squad_aa", "rhs_group_chdkz_btr70_squad_mg_sniper", "rhs_group_chdkz_btr70_squad_sniper", "rhs_group_chdkz_ural_chq", "rhs_group_chdkz_ural_squad", "rhs_group_chdkz_ural_squad_2mg", "rhs_group_chdkz_ural_squad_aa", "rhs_group_chdkz_ural_squad_mg_sniper", "rhs_group_chdkz_ural_squad_sniper", "BUS_MotInf_AA", "BUS_MotInf_AT", "BUS_MotInf_Team_GMG", "BUS_MotInf_Team_HMG"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Mechanized", ["rhs_group_rus_ins_bmd1_chq", "rhs_group_rus_ins_bmd1_squad", "rhs_group_rus_ins_bmd1_squad_2mg", "rhs_group_rus_ins_bmd1_squad_aa", "rhs_group_rus_ins_bmd1_squad_mg_sniper", "rhs_group_rus_ins_bmd1_squad_sniper", "rhs_group_rus_ins_bmd2_chq", "rhs_group_rus_ins_bmd2_squad", "rhs_group_rus_ins_bmd2_squad_2mg", "rhs_group_rus_ins_bmd2_squad_aa", "rhs_group_rus_ins_bmd2_squad_mg_sniper", "rhs_group_rus_ins_bmd2_squad_sniper", "rhs_group_indp_ins_bmp1_chq", "rhs_group_indp_ins_bmp1_squad", "rhs_group_indp_ins_bmp1_squad_2mg", "rhs_group_indp_ins_bmp1_squad_aa", "rhs_group_indp_ins_bmp1_squad_mg_sniper", "rhs_group_indp_ins_bmp1_squad_sniper", "rhs_group_indp_ins_bmp2_chq", "rhs_group_indp_ins_bmp2_squad", "rhs_group_indp_ins_bmp2_squad_2mg", "rhs_group_indp_ins_bmp2_squad_aa", "rhs_group_indp_ins_bmp2_squad_mg_sniper", "rhs_group_indp_ins_bmp2_squad_sniper"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Armored", ["RHS_T72baPlatoon", "RHS_T72baPlatoon_AA", "RHS_T72baSection", "RHS_T72BBPlatoon", "RHS_T72BBPlatoon_AA", "RHS_T72BBSection", "RHS_t72bcPlatoon", "RHS_t72bcPlatoon_AA", "RHS_t72bcSection"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_ins_bm21", "RHS_SPGSection_ins_bm21"]] call ALIVE_fnc_hashSet;

[rhsgref_faction_chdkz_mappings, "Groups", rhsgref_faction_chdkz_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_chdkz", rhsgref_faction_chdkz_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_chdkz", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_chdkz", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_chdkz", []] call ALIVE_fnc_hashSet;

//==========================================//
// rhsgref_faction_cdf_ground               //
//==========================================//

rhsgref_faction_cdf_ground_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_cdf_ground_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ground_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings, "FactionName", "rhsgref_faction_cdf_ground"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings, "GroupFactionName", "rhsgref_faction_cdf_ground"] call ALIVE_fnc_hashSet;

rhsgref_faction_cdf_ground_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ground_mappings, "GroupFactionTypes", rhsgref_faction_cdf_ground_typeMappings] call ALIVE_fnc_hashSet;

// Remark: as for now, CfgGroups entries for: rhs_group_cdf_gaz66, rhs_group_cdf_gaz66_para and rhs_group_cdf_ural share the same group names.
// Is there a way to distinguish them?
[rhsgref_faction_cdf_ground_factionCustomGroups, "Infantry", ["rhsgref_group_cdf_reg_infantry_squad", "rhsgref_group_cdf_reg_infantry_squad_weap", "rhsgref_group_cdf_para_infantry_squad", "rhsgref_group_cdf_para_infantry_squad_weap"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Motorized", ["rhs_group_cdf_btr60_chq", "rhs_group_cdf_btr60_squad", "rhs_group_cdf_btr60_squad_2mg", "rhs_group_cdf_btr60_squad_aa", "rhs_group_cdf_btr60_squad_mg_sniper", "rhs_group_cdf_btr60_squad_sniper", "rhs_group_cdf_btr70_chq", "rhs_group_cdf_btr70_squad", "rhs_group_cdf_btr70_squad_2mg", "rhs_group_cdf_btr70_squad_aa", "rhs_group_cdf_btr70_squad_mg_sniper", "rhs_group_cdf_btr70_squad_sniper", "rhs_group_cdf_ural_chq", "rhs_group_cdf_ural_squad", "rhs_group_cdf_ural_squad_2mg", "rhs_group_cdf_ural_squad_aa", "rhs_group_cdf_ural_squad_mg_sniper", "rhs_group_cdf_ural_squad_sniper", "BUS_MotInf_AA", "BUS_MotInf_AT", "BUS_MotInf_Team_GMG", "BUS_MotInf_Team_HMG"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Mechanized", ["rhs_group_cdf_bmd1_chq", "rhs_group_cdf_bmd1_squad", "rhs_group_cdf_bmd1_squad_2mg", "rhs_group_cdf_bmd1_squad_aa", "rhs_group_cdf_bmd1_squad_mg_sniper", "rhs_group_cdf_bmd1_squad_sniper", "rhs_group_cdf_bmd2_chq", "rhs_group_cdf_bmd2_squad", "rhs_group_cdf_bmd2_squad_2mg", "rhs_group_cdf_bmd2_squad_aa", "rhs_group_cdf_bmd2_squad_mg_sniper", "rhs_group_cdf_bmd2_squad_sniper", "rhs_group_cdf_bmp1_chq", "rhs_group_cdf_bmp1_squad", "rhs_group_cdf_bmp1_squad_2mg", "rhs_group_cdf_bmp1_squad_aa", "rhs_group_cdf_bmp1_squad_mg_sniper", "rhs_group_cdf_bmp1_squad_sniper", "rhs_group_cdf_bmp2_chq", "rhs_group_cdf_bmp2_squad", "rhs_group_cdf_bmp2_squad_2mg", "rhs_group_cdf_bmp2_squad_aa", "rhs_group_cdf_bmp2_squad_mg_sniper", "rhs_group_cdf_bmp2_squad_sniper"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Armored", ["RHS_T72baPlatoon", "RHS_T72baPlatoon_AA", "RHS_T72baSection"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_ins_g_bm21", "RHS_SPGSection_ins_g_bm21"]] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_ground_mappings, "Groups", rhsgref_faction_cdf_ground_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_cdf_ground", rhsgref_faction_cdf_ground_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_cdf_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_cdf_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_cdf_ground", []] call ALIVE_fnc_hashSet;

//==========================================//
// rhsgref_faction_cdf_ng                   //
//==========================================//

rhsgref_faction_cdf_ng_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_cdf_ng_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ng_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings, "FactionName", "rhsgref_faction_cdf_ng"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings, "GroupFactionName", "rhsgref_faction_cdf_ng"] call ALIVE_fnc_hashSet;

rhsgref_faction_cdf_ng_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ng_mappings, "GroupFactionTypes", rhsgref_faction_cdf_ng_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_ng_factionCustomGroups, "Infantry", ["rhsgref_group_cdf_ngd_infantry_squad"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups, "Motorized", []] call ALIVE_fnc_hashSet;  // This faction has no motorized groups defined.
[rhsgref_faction_cdf_ng_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet; // This faction has no mechanized groups defined.
[rhsgref_faction_cdf_ng_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;    // This faction has no armored groups defined.
[rhsgref_faction_cdf_ng_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;  // This faction has no artillery groups defined.

[rhsgref_faction_cdf_ng_mappings, "Groups", rhsgref_faction_cdf_ng_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_cdf_ng", rhsgref_faction_cdf_ng_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_cdf_ng", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_cdf_ng", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_cdf_ng", []] call ALIVE_fnc_hashSet;

//==========================================//
// rhsgref_faction_chdkz_g                  //
//==========================================//

rhsgref_faction_chdkz_g_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_chdkz_g_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_g_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings, "FactionName", "rhsgref_faction_chdkz_g"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings, "GroupFactionName", "rhsgref_faction_chdkz_g"] call ALIVE_fnc_hashSet;

rhsgref_faction_chdkz_g_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_g_mappings, "GroupFactionTypes", rhsgref_faction_chdkz_g_typeMappings] call ALIVE_fnc_hashSet;

// Remark: as for now, CfgGroups entries for: rhs_group_indp_ins_g_gaz66 and rhs_group_indp_ins_g_ural share the same group names.
// Is there a way to distinguish them?
[rhsgref_faction_chdkz_g_factionCustomGroups, "Infantry", ["rhsgref_group_chdkz_infantry_aa", "rhsgref_group_chdkz_infantry_at", "rhsgref_group_chdkz_infantry_mg", "rhsgref_group_chdkz_infantry_patrol", "rhsgref_group_chdkz_ins_gurgents_squad"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Motorized", ["rhs_group_chdkz_btr60_chq", "rhs_group_chdkz_btr60_squad", "rhs_group_chdkz_btr60_squad_2mg", "rhs_group_chdkz_btr60_squad_aa", "rhs_group_chdkz_btr60_squad_mg_sniper", "rhs_group_chdkz_btr60_squad_sniper", "rhs_group_chdkz_btr70_chq", "rhs_group_chdkz_btr70_squad", "rhs_group_chdkz_btr70_squad_2mg", "rhs_group_chdkz_btr70_squad_aa", "rhs_group_chdkz_btr70_squad_mg_sniper", "rhs_group_chdkz_btr70_squad_sniper", "rhs_group_chdkz_ural_chq", "rhs_group_chdkz_ural_squad", "rhs_group_chdkz_ural_squad_2mg", "rhs_group_chdkz_ural_squad_aa", "rhs_group_chdkz_ural_squad_mg_sniper", "rhs_group_chdkz_ural_squad_sniper", "BUS_MotInf_AA", "BUS_MotInf_AT", "BUS_MotInf_Team_GMG", "BUS_MotInf_Team_HMG"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Mechanized", ["rhs_group_rus_ins_g_bmd1_chq", "rhs_group_rus_ins_g_bmd1_squad", "rhs_group_rus_ins_g_bmd1_squad_2mg", "rhs_group_rus_ins_g_bmd1_squad_aa", "rhs_group_rus_ins_g_bmd1_squad_mg_sniper", "rhs_group_rus_ins_g_bmd1_squad_sniper", "rhs_group_rus_ins_g_bmd2_chq", "rhs_group_rus_ins_g_bmd2_squad", "rhs_group_rus_ins_g_bmd2_squad_2mg", "rhs_group_rus_ins_g_bmd2_squad_aa", "rhs_group_rus_ins_g_bmd2_squad_mg_sniper", "rhs_group_rus_ins_g_bmd2_squad_sniper", "rhs_group_indp_ins_g_bmp1_chq", "rhs_group_indp_ins_g_bmp1_squad", "rhs_group_indp_ins_g_bmp1_squad_2mg", "rhs_group_indp_ins_g_bmp1_squad_aa", "rhs_group_indp_ins_g_bmp1_squad_mg_sniper", "rhs_group_indp_ins_g_bmp1_squad_sniper", "rhs_group_indp_ins_g_bmp2_chq", "rhs_group_indp_ins_g_bmp2_squad", "rhs_group_indp_ins_g_bmp2_squad_2mg", "rhs_group_indp_ins_g_bmp2_squad_aa", "rhs_group_indp_ins_g_bmp2_squad_mg_sniper", "rhs_group_indp_ins_g_bmp2_squad_sniper"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Armored", ["RHS_T72baPlatoon", "RHS_T72baPlatoon_AA", "RHS_T72baSection", "RHS_T72BBPlatoon", "RHS_T72BBPlatoon_AA", "RHS_T72BBSection", "RHS_t72bcPlatoon", "RHS_t72bcPlatoon_AA", "RHS_t72bcSection"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Artillery", ["RHS_SPGPlatoon_ins_g_bm21", "RHS_SPGSection_ins_g_bm21"]] call ALIVE_fnc_hashSet;

[rhsgref_faction_chdkz_g_mappings, "Groups", rhsgref_faction_chdkz_g_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_chdkz_g", rhsgref_faction_chdkz_g_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_chdkz_g", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_chdkz_g", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_chdkz_g", []] call ALIVE_fnc_hashSet;

//==========================================//
// rhsgref_faction_nationalist              //
//==========================================//

rhsgref_faction_nationalist_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_nationalist_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_nationalist_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings, "FactionName", "rhsgref_faction_nationalist"] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings, "GroupFactionName", "rhsgref_faction_nationalist"] call ALIVE_fnc_hashSet;

rhsgref_faction_nationalist_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_nationalist_mappings, "GroupFactionTypes", rhsgref_faction_nationalist_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_nationalist_factionCustomGroups, "Infantry", ["rhsgref_group_national_infantry_at", "rhsgref_group_national_infantry_mg", "rhsgref_group_national_infantry_patrol", "rhsgref_group_national_infantry_squad", "rhsgref_group_national_infantry_squad_2""rhsgref_group_national_infantry_at", "rhsgref_group_national_infantry_mg", "rhsgref_group_national_infantry_patrol", "rhsgref_group_national_infantry_squad", "rhsgref_group_national_infantry_squad_2"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups, "Motorized", ["rhs_group_nat_ural_chq", "rhs_group_nat_ural_squad", "rhs_group_nat_ural_squad_2mg", "rhs_group_nat_ural_squad_aa", "rhs_group_nat_ural_squad_mg_sniper", "rhs_group_nat_ural_squad_sniper", "BUS_MotInf_AA", "BUS_MotInf_AT", "BUS_MotInf_Team_GMG", "BUS_MotInf_Team_HMG"]] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet; // This faction has no mechanized groups defined.
[rhsgref_faction_nationalist_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;    // This faction has no armored groups defined.
[rhsgref_faction_nationalist_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;  // This faction has no artillery groups defined.

[rhsgref_faction_nationalist_mappings, "Groups", rhsgref_faction_nationalist_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_nationalist", rhsgref_faction_nationalist_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_nationalist", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_nationalist", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_nationalist", []] call ALIVE_fnc_hashSet;


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

unsung_e_mappings = [] call ALIVE_fnc_hashCreate;
[unsung_e_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[unsung_e_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[unsung_e_mappings, "FactionName", "UNSUNG_E"] call ALIVE_fnc_hashSet;
[unsung_e_mappings, "GroupFactionName", "UNSUNG_E"] call ALIVE_fnc_hashSet;

unsung_e_typeMappings = [] call ALIVE_fnc_hashCreate;
[unsung_e_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Infantry", "NVA65Infantry"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Mechanized", "uns_nvapatrolvehicles"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Motorized", "uns_nvapatrolvehicles"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Motorized_MTP", "uns_nvapatrolvehicles"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;
[unsung_e_typeMappings, "Support", "NVA65Infantry"] call ALIVE_fnc_hashSet;

[unsung_e_mappings, "GroupFactionTypes", unsung_e_typeMappings] call ALIVE_fnc_hashSet;
[ALIVE_factionCustomMappings, "UNSUNG_E", unsung_e_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupplies, "UNSUNG_E", ["uns_medcrate","uns_82mmammobox_VC","uns_AmmoBoxNVA","uns_EQPT_NVA","uns_resupply_crate_NVA"]] call ALIVE_fnc_hashSet;
// ---------------------------------------------------------------------------------------------------------------------
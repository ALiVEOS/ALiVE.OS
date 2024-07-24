/*
 * Mil logistics convoy transport vehicles fallback for sides
 */

ALIVE_sideDefaultTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultTransport, "EAST", ["O_Truck_02_transport_F","O_Truck_02_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "WEST", ["B_Truck_01_transport_F","B_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "GUER", ["I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "CIV", ["C_Van_01_transport_F"]] call ALIVE_fnc_hashSet;

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

// APEX
[ALIVE_factionDefaultTransport, "OPF_T_F", ["O_T_Truck_03_transport_ghex_F","O_T_Truck_03_covered_ghex_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "IND_C_F", ["C_Truck_02_covered_F","C_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_T_F", ["B_T_Truck_01_transport_F","B_T_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_CTRG_F", ["B_T_Truck_01_transport_F","B_T_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "Gendarmerie", ["C_Truck_02_covered_F","C_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;

// VN - CDLC S.O.G Prairie Fire 1.3
[ALIVE_factionDefaultTransport, "O_PAVN", ["vn_o_wheeled_z157_02_nva65","vn_o_wheeled_z157_01_nva65","vn_o_wheeled_z157_01","vn_o_wheeled_z157_02"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "O_VC", ["vn_o_wheeled_z157_01_vcmf","vn_o_wheeled_z157_02_vcmf"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "O_PL", ["vn_o_wheeled_z157_01_pl","vn_o_wheeled_z157_02_pl"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "O_CAM", ["vn_o_wheeled_z157_01_kr","vn_o_wheeled_z157_02_kr"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "I_ARVN", ["vn_i_wheeled_m54_01","vn_i_wheeled_m54_02"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "I_LAO", ["vn_i_wheeled_m54_01_rla","vn_i_wheeled_m54_02_rla"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "I_CAM", ["vn_i_wheeled_z157_01_fank_70","vn_i_wheeled_z157_02_fank_70"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "B_MACV", ["vn_b_wheeled_m54_01","vn_b_wheeled_m54_02"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "B_AUS", ["vn_b_wheeled_m54_01_aus_army","vn_b_wheeled_m54_02_aus_army"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "B_NZ", ["vn_b_wheeled_m54_01_nz_army","vn_b_wheeled_m54_02_nz_army"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "B_ROK", ["vn_b_wheeled_m54_01_rok_army","vn_b_wheeled_m54_02_rok_army"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "B_CIA", ["vn_b_wheeled_m54_01","vn_b_wheeled_m54_02"]] call ALIVE_fnc_hashSet;

// SPE - CDLC Spearhead 1944 1.1
[ALIVE_factionDefaultTransport, "SPE_STURM", ["SPE_ST_R200_Unarmed","SPE_ST_R200_Hood","SPE_ST_OpelBlitz","SPE_ST_OpelBlitz_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SPE_WEHRMACHT", ["SPE_GER_R200_Unarmed","SPE_GER_R200_Hood","SPE_OpelBlitz","SPE_OpelBlitz_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SPE_US_ARMY", ["SPE_US_M3_Halftrack_Unarmed","SPE_US_M3_Halftrack_Unarmed_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SPE_FR_ARMY", ["SPE_FR_M3_Halftrack_Unarmed","SPE_FR_M3_Halftrack_Unarmed_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SPE_FFI", ["SPE_FFI_R200_Unarmed","SPE_FFI_R200_Hood","SPE_FFI_OpelBlitz","SPE_FFI_OpelBlitz_Open"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "SPE_MILICE", ["SPE_Milice_R200_Unarmed","SPE_Milice_R200_Hood","SPE_OpelBlitz","SPE_OpelBlitz_Open"]] call ALIVE_fnc_hashSet;



// GM - CDLC Global Mobilization 1.5
[ALIVE_factionDefaultTransport, "gm_gc_army", ["gm_gc_army_ural4320_cargo","gm_gc_army_ural375d_cargo","gm_gc_army_uaz469_cargo","gm_gc_army_p601"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_gc_army_win", ["gm_gc_army_ural375d_cargo_win","gm_gc_army_uaz469_cargo_win","gm_gc_army_p601"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_gc_army_bgs", ["gm_gc_bgs_ural4320_cargo","gm_gc_bgs_uaz469_cargo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_pl_army", ["gm_pl_army_ural4320_cargo","gm_pl_army_uaz469_cargo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_pl_army_win", ["gm_gc_army_ural375d_cargo_win","gm_gc_army_uaz469_cargo_win","gm_gc_army_p601"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_ge_army", ["gm_ge_army_typ1200_cargo","gm_ge_army_typ247_cargo","gm_ge_army_typ253_cargo","gm_ge_army_iltis_cargo","gm_ge_army_u1300l_cargo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_ge_army_win", ["gm_ge_army_typ1200_cargo_win","gm_ge_army_typ247_cargo_win","gm_ge_army_typ253_cargo_win","gm_ge_army_iltis_cargo_win","gm_ge_army_u1300l_cargo_win"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_ge_army_bgs", ["gm_ge_bgs_k125","gm_ge_bgs_typ253_cargo","gm_ge_bgs_w123_cargo"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_dk_army", ["gm_dk_army_typ1200_cargo","gm_dk_army_typ247_cargo","gm_dk_army_typ253_cargo","gm_dk_army_u1300l_container"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_dk_army_win", ["gm_dk_army_typ1200_cargo_win","gm_dk_army_typ247_cargo_win","gm_dk_army_typ253_cargo_win","gm_dk_army_u1300l_container_win"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "gm_xx_army", ["gm_ge_civ_typ253","gm_ge_civ_typ1200"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles fallback for sides
 */

ALIVE_sideDefaultAirTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultAirTransport, "EAST", ["O_Heli_Transport_04_F","O_Heli_Transport_04_box_F","O_Heli_Attack_02_F","O_Heli_Light_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "WEST", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "GUER", ["I_Heli_Transport_02_F","I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "CIV", ["C_Heli_light_01_ion_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */

ALIVE_factionDefaultAirTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultAirTransport, "OPF_F", ["O_Heli_Transport_04_F","O_Heli_Transport_04_box_F","O_Heli_Attack_02_F","O_Heli_Light_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "OPF_G_F", ["I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "IND_F", ["I_Heli_Transport_02_F","I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_F", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_G_F", ["I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "CIV_F", ["C_Heli_light_01_ion_F"]] call ALIVE_fnc_hashSet;

// APEX
[ALIVE_factionDefaultAirTransport, "OPF_T_F", ["O_Heli_Transport_04_F","O_Heli_Transport_04_box_F","O_Heli_Attack_02_F","O_Heli_Light_02_F","O_T_VTOL_02_infantry_F","O_T_VTOL_02_vehicle_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "IND_C_F", ["I_C_Heli_Light_01_civil_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_T_F", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F","B_T_VTOL_01_armed_F","B_T_VTOL_01_infantry_F","B_T_VTOL_01_vehicle_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_CTRG_F", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F","B_T_VTOL_01_armed_F","B_T_VTOL_01_infantry_F","B_T_VTOL_01_vehicle_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "Gendarmerie", ["C_Heli_Light_01_civil_F"]] call ALIVE_fnc_hashSet;

// VN - CDLC S.O.G Prairie Fire 1.3
[ALIVE_factionDefaultAirTransport, "O_PAVN", ["vn_o_air_mi2_01_01","vn_o_air_mi2_01_03","vn_o_air_mi2_01_02"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "O_VC", ["vn_o_air_mi2_01_03"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "O_PL", ["vn_o_air_mi2_01_03"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "O_CAM", ["vn_o_air_mi2_01_03"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "I_ARVN", ["vn_i_air_uh1d_02_01","vn_i_air_ch34_02_01","vn_i_air_ch34_01_02","vn_i_air_ch34_02_02","vn_b_air_ch47_04_01","vn_b_air_ch47_03_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "I_LAO", ["vn_i_air_uh1d_02_01","vn_i_air_ch34_02_01","vn_i_air_ch34_01_02","vn_i_air_ch34_02_02","vn_b_air_ch47_04_01","vn_b_air_ch47_03_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "I_CAM", ["vn_i_air_uh1d_02_01","vn_i_air_ch34_02_01","vn_i_air_ch34_01_02","vn_i_air_ch34_02_02","vn_b_air_ch47_04_01","vn_b_air_ch47_03_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "B_MACV", ["vn_b_air_ch34_03_01","vn_b_air_ch34_01_01","vn_b_air_uh1d_02_05","vn_b_air_uh1d_02_07","vn_b_air_uh1d_02_06","vn_b_air_uh1d_02_01","vn_b_air_ch47_04_01","vn_b_air_ch47_03_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "B_AUS", ["vn_b_air_uh1b_01_06","vn_b_air_uh1c_07_06","vn_b_air_uh1d_01_06","vn_b_air_uh1d_02_06","vn_b_air_ch47_04_01","vn_b_air_ch47_03_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "B_NZ", ["vn_b_air_uh1b_01_06","vn_b_air_uh1c_07_06","vn_b_air_uh1d_01_06","vn_b_air_uh1d_02_06","vn_b_air_ch47_04_01","vn_b_air_ch47_03_01"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "B_CIA", ["vn_b_air_uh1d_04_09","vn_b_air_uh1b_01_09"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "B_ROK", ["vn_b_air_uh1d_02_01","vn_b_air_ch34_01_01","vn_b_air_ch47_04_01","vn_b_air_ch47_03_01"]] call ALIVE_fnc_hashSet;

// SPE - Currently none available
/*
[ALIVE_factionDefaultAirTransport, "SPE_STURM", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "SPE_WEHRMACHT", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "SPE_US_ARMY", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "SPE_FR_ARMY", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "SPE_FFI", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "SPE_MILICE", []] call ALIVE_fnc_hashSet;
*/

// GM - CDLC Global Mobilization 1.5
[ALIVE_factionDefaultAirTransport, "gm_gc_army", ["gm_gc_airforce_l410s_salon","gm_gc_airforce_l410t"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_gc_army_win", ["gm_gc_airforce_mi2p_un"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_gc_army_bgs", ["gm_gc_bgs_mi2p"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_pl_army", ["gm_pl_airforce_mi2ch"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_pl_army_win", ["gm_pl_airforce_mi2ch_un"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_ge_army", ["gm_ge_army_ch53g_oli","gm_ge_army_ch53gs_oli","gm_ge_army_pilot_p1_80_oli","gm_ge_airforce_do28d2","gm_ge_army_pilot_p1_80_oli"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_ge_army_win", ["gm_ge_army_ch53g_un","gm_ge_army_ch53gs_un","gm_ge_airforce_do28d2_medevac_un","gm_ge_airforce_do28d2_un","gm_ge_army_bo105m_vbh_un"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_ge_army_bgs", ["gm_gc_bgs_mi2p","gm_ge_bgs_bo105m_vbh"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_dk_army", ["gm_ge_bgs_bo105m_vbh"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_dk_army_win", ["gm_ge_army_bo105m_vbh_un"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "gm_xx_army", ["gm_ge_army_bo105m_vbh_un"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers fallback for sides
 */

ALIVE_sideDefaultContainers = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultContainers, "EAST", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "WEST", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "GUER", ["ALIVE_I_supplyCrate_F","I_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "CIV", ["CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
ALIVE_factionDefaultContainers = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultContainers, "OPF_F", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "OPF_G_F", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "IND_F", ["ALIVE_I_supplyCrate_F","I_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_G_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "CIV_F", ["CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;

// APEX
[ALIVE_factionDefaultContainers, "OPF_T_F", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "IND_C_F", ["ALIVE_I_supplyCrate_F","I_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_T_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_CTRG_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F","C_T_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "Gendarmerie", ["CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;

// VN - CDLC S.O.G Prairie Fire 1.3
[ALIVE_factionDefaultContainers, "O_PAVN", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "O_PVC", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "O_PL", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "O_CAM", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "I_ARVN", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "I_LAO", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "I_CAM", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "B_MACV", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "B_AUS", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "B_NZ", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "B_CIA", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "B_ROK", ["vn_b_ammobox_supply_05"]] call ALIVE_fnc_hashSet;

// SPE - CDLC Spearhead 1944 1.1
[ALIVE_factionDefaultContainers, "SPE_STURM", ["Land_SPE_Ammobox_German_01","Land_SPE_Ammobox_German_02","Land_SPE_Ammobox_German_03","Land_SPE_Ammobox_German_04","Land_SPE_Ammobox_German_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "SPE_WEHRMACHT", ["Land_SPE_Ammobox_German_01","Land_SPE_Ammobox_German_02","Land_SPE_Ammobox_German_03","Land_SPE_Ammobox_German_04","Land_SPE_Ammobox_German_05"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "SPE_US_ARMY", ["SPE_BasicAmmunitionBox_US","SPE_BasicWeaponsBox_US","Land_SPE_Ammocrate_US_01","Land_SPE_Ammocrate_US_02","Land_SPE_Ammocrate_US_03"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "SPE_FR_ARMY", ["SPE_BasicAmmunitionBox_US","SPE_BasicWeaponsBox_US"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "SPE_FFI", ["SPE_Hay_WeaponCache_FFI"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "SPE_MILICE", ["Land_SPE_Ammobox_German_01","Land_SPE_Ammobox_German_02","Land_SPE_Ammobox_German_03","Land_SPE_Ammobox_German_04","Land_SPE_Ammobox_German_05"]] call ALIVE_fnc_hashSet;


// GM - CDLC Global Mobilization 1.5
[ALIVE_factionDefaultContainers, "gm_gc_army", ["gm_gc_army_ammobox_smallarms_80","gm_gc_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_gc_army_win", ["gm_gc_army_ammobox_smallarms_80","gm_gc_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_gc_army_bgs", ["gm_gc_army_ammobox_smallarms_80","gm_gc_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_pl_army", ["gm_pl_army_ammobox_smallarms_80","gm_pl_army_ammobox_everything_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_pl_army_win", ["gm_pl_army_ammobox_smallarms_80","gm_pl_army_ammobox_everything_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_ge_army", ["gm_ge_army_ammobox_everything_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_ge_army_win", ["gm_ge_army_ammobox_everything_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_ge_army_bgs", ["gm_ge_army_ammobox_everything_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_dk_army", ["gm_dk_army_ammobox_everything_80","gm_dk_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_dk_army_win", ["gm_dk_army_ammobox_everything_80","gm_dk_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "gm_xx_army", ["gm_gc_army_ammobox_smallarms_80","gm_ge_army_ammobox_smallarms_80"]] call ALIVE_fnc_hashSet;

#include "logistics\3CB.hpp"
#include "logistics\RHS_AFRF.hpp"
#include "logistics\RHS_GREF.hpp"
#include "logistics\RHS_SAF.hpp"
#include "logistics\RHS_USAF.hpp"
#include "logistics\IFA3.hpp"
#include "logistics\CFP.hpp"

// load from config

private _configPath = configfile >> "ALiVE" >> "Logistics" >> "Factions";
for "_i" from 0 to (count _configPath - 1) do {
	private _entry = _configPath select _i;
	if (isclass _configPath) then {
		private _faction = configname _entry;
		private _vehiclesLandTransport = getarray (_entry >> "landTransportVehicles");
		private _vehiclesAirTransport = getarray (_entry >> "airTransportVehicles");
		private _containers = getarray (_entry >> "containers");

		[ALIVE_factionDefaultTransport, _faction, _vehiclesLandTransport] call ALIVE_fnc_hashSet;
		[ALIVE_factionDefaultAirTransport, _faction, _vehiclesAirTransport] call ALIVE_fnc_hashSet;
		[ALIVE_factionDefaultContainers, _faction, _containers] call ALIVE_fnc_hashSet;
	};
};
class CfgRoles
{
	class Recon
	{
		displayName = $STR_A3_Role_Recon;
		icon = "a3\Ui_f\data\GUI\Cfg\RespawnRoles\recon_ca.paa";
	};
	class Assault
	{
		displayName = $STR_A3_Role_Assault;
		icon = "a3\Ui_f\data\GUI\Cfg\RespawnRoles\assault_ca.paa";
	};
	class Support
	{
		displayName = $STR_A3_Role_Support;
		icon = "a3\Ui_f\data\GUI\Cfg\RespawnRoles\support_ca.paa";
	};
};


class CfgRespawnInventory
{

	class B_Grenadier
	{
		displayName = $STR_b_soldier_gl_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconMan_ca.paa";
		show = "side group _this == west";
		role = "Assault";
		weapons[] = {"vn_m79","vn_m1911","Throw","Put"};
		magazines[] = {"vn_40mm_m381_he_mag","vn_m1911_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m433_hedp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m406_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m397_ab_mag","vn_40mm_m397_ab_mag","vn_40mm_m397_ab_mag","vn_40mm_m397_ab_mag","vn_40mm_m397_ab_mag","vn_40mm_m397_ab_mag","vn_40mm_m397_ab_mag","vn_40mm_m433_hedp_mag","vn_40mm_m433_hedp_mag","vn_40mm_m433_hedp_mag","vn_40mm_m433_hedp_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m661_flare_g_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m576_buck_mag","vn_40mm_m576_buck_mag","vn_40mm_m576_buck_mag","vn_40mm_m576_buck_mag","vn_40mm_m576_buck_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_05","vn_b_helmet_m1_04_01","vn_b_aviator","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_02_01";
		backpack = "vn_b_pack_lw_01_m79_pl";
	};
	class B_Marksman
	{
		displayName = $STR_b_soldier_m_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconMan_ca.paa";
		show = "side group _this == west";
		role = "Assault";
		weapons[] = {"vn_m14","vn_m1911","Throw","Put"};
		magazines[] = {"vn_m14_t_mag","vn_m1911_mag","vn_m67_grenade_mag","vn_m67_grenade_mag","vn_m18_purple_mag","vn_m18_purple_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_08","vn_b_bandana_01","vn_b_scarf_01_01","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10","vn_o_9x_m14"};
		uniformClass = "vn_b_uniform_macv_01_01";
		backpack = "vn_b_pack_lw_01_m21_pl";
	};
	class B_Autorifleman
	{
		displayName = $STR_b_soldier_ar_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManMG_ca.paa";
		show = "side group _this == west";
		role = "Assault";
		weapons[] = {"vn_m60","vn_m1911","Throw","Put"};
		magazines[] = {"vn_m60_100_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m60_100_mag","vn_m1911_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_mine_m14_mag","vn_mine_m14_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_06","vn_b_helmet_m1_08_01","vn_b_aviator","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_05_01";
		backpack = "vn_b_pack_lw_02_m60_pl";
	};
	class B_Rifleman
	{
		displayName = $STR_A3_cfgvehicles_b_soldier_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconMan_ca.paa";
		show = "side group _this == west";
		role = "Assault";
		weapons[] = {"vn_m16","vn_m1911","Throw","Put"};
		magazines[] = {"vn_m16_20_t_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_red_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_02","vn_b_helmet_m1_07_01","vn_b_aviator","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_04_01";
		backpack = "vn_b_pack_lw_01_m16_pl";
	};
  class B_Engineer
	{
		displayName = $STR_b_engineer_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManEngineer_ca.paa";
		show = "side group _this == west";
		role = "Support";
		weapons[] = {"vn_m1897","vn_m72","vn_m1911","vn_m19_binocs_grn","Throw","Put"};
		magazines[] = {"vn_m1897_buck_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1911_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_mine_m16_mag","vn_mine_m16_mag","vn_mine_tripwire_m49_04_mag","vn_mine_tripwire_m49_04_mag","vn_mine_tripwire_m49_04_mag","vn_mine_tripwire_m49_04_mag","vn_mine_m112_remote_mag","vn_mine_m112_remote_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_toolkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_11","vn_b_helmet_m1_05_01","vn_g_spectacles_02","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_04_01";
		backpack = "vn_b_pack_lw_04_eng_m1897_pl";
	};
	  class B_RTO
	{
		displayName = "Radio Telephone Operator";
		icon = "\A3\ui_f\data\map\VehicleIcons\iconman_ca.paa";
		show = "side group _this == west";
		role = "Support";
		weapons[] = {"vn_m16","vn_m1911","vn_m19_binocs_grn","Throw","Put"};
		magazines[] = {"vn_m16_20_t_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_red_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_02","vn_b_helmet_m1_07_01","vn_b_aviator","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_04_01";
		backpack = "vn_b_pack_prc77_01";
	};
	class B_CombatLifesaver
	{
		displayName = $STR_b_medic_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManMedic_ca.paa";
		show = "side group _this == west";
		role = "Support";
		weapons[] = {"vn_m16","vn_m1911","Throw","Put"};
		magazines[] = {"vn_m16_20_t_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_red_mag","vn_m18_red_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_m18_purple_mag","vn_m18_purple_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_medikit_01","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_07","vn_b_helmet_m1_04_01","vn_g_spectacles_02","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_03_01";
		backpack = "vn_b_pack_m5_01_medic_m16_pl";
	};
	class B_ReconScout
	{
		displayName = $STR_b_recon_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManRecon_ca.paa";
		show = "side group _this == west";
		role = "Recon";
		weapons[] = {"vn_sten","vn_m1911","Throw","Put"};
		magazines[] = {"vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m14_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_sten_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m18_range_mag","vn_mine_m18_range_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_m1911_mag","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_sog_04","vn_b_boonie_02_01","vn_b_scarf_01_01","vn_b_item_map","vn_b_item_compass_sog","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_sog_02_01";
		backpack = "vn_b_pack_02_sten_pl";
	};
	class B_ReconMarksman
	{
		displayName = $STR_b_recon_m_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManRecon_ca.paa";
		show = "side group _this == west";
		role = "Recon";
		weapons[] = {"vn_m16_camo","vn_mk22","Throw","Put"};
		magazines[] = {"vn_m16_20_t_mag","vn_mk22_mag","vn_mk22_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_mine_m18_range_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_red_mag","vn_m18_red_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_m18_purple_mag","vn_m18_purple_mag","vn_mine_m112_remote_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m18_range_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_sog_04","vn_b_bandana_02","vn_b_scarf_01_01","vn_b_item_map","vn_b_item_compass_sog","vn_b_item_watch","vn_b_item_radio_urc10","vn_o_9x_m16"};
		uniformClass = "vn_b_uniform_sog_02_01";
		backpack = "vn_b_pack_01_xm177_pl";
	};
	class B_Sharpshooter
	{
		displayName = $STR_a3_cfgvehicles_b_sharpshooter_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconMan_ca.paa";
		show = "side group _this == west";
		role = "Assault";
		weapons[] = {"vn_m16_camo","vn_mk22","Throw","Put"};
		magazines[] = {"vn_m16_20_t_mag","vn_mk22_mag","vn_mk22_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_mine_m18_range_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_red_mag","vn_m18_red_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_m18_purple_mag","vn_m18_purple_mag","vn_mine_m112_remote_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m18_range_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_sog_04","vn_b_bandana_02","vn_b_scarf_01_01","vn_b_item_map","vn_b_item_compass_sog","vn_b_item_watch","vn_b_item_radio_urc10","vn_o_4x_m16"};
		uniformClass = "vn_b_uniform_sog_02_01";
		backpack = "vn_b_pack_01_xm177_pl";
	};
	class B_Sniper
	{
		displayName = $STR_b_sniper_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconMan_ca.paa";
		show = "side group _this == west";
		role = "Recon";
	  weapons[] = {"vn_m14_camo","vn_m1911","vn_mk21_binocs","Throw","Put"};
		magazines[] = {"vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_red_mag","vn_m18_red_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_m16_20_t_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_red_mag","vn_m18_red_mag","vn_m34_grenade_mag","vn_mine_m112_remote_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m18_range_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m18_range_mag","vn_m1911_mag","vn_m1911_mag","vn_m14_t_mag","vn_m14_t_mag","vn_m1911_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_sog_04","vn_b_boonie_02_01","vn_b_scarf_01_01","vn_b_item_map","vn_b_item_compass_sog","vn_b_item_watch","vn_b_item_radio_urc10_5","vn_s_m14","vn_o_9x_m14","vn_b_camo_m14"};
		uniformClass = "vn_b_uniform_sog_02_02";
		backpack = "vn_b_pack_02_xm177_pl";
	};
	class B_HeavyGunner
	{
		displayName = $STR_a3_cfgvehicles_b_heavygunner_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManMG_ca.paa";
		show = "side group _this == west";
		role = "Assault";
		weapons[] = {"vn_rpd_shorty","vn_m79_p","vn_mk21_binocs","Throw","Put"};
		magazines[] = {"vn_rpd_125_mag","vn_40mm_m381_he_mag","vn_m61_grenade_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_rpd_125_mag","vn_m61_grenade_mag","vn_40mm_m583_flare_w_mag","vn_rpd_125_mag","vn_rpd_125_mag","vn_rpd_125_mag","vn_rpd_125_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_rpd_125_mag","vn_rpd_125_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_02","vn_b_boonie_01_06","vn_b_scarf_01_01","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_05_06";
		backpack = "vn_b_pack_lw_02_rpd_pl";
	};
	class B_ExplosiveSpecialist
	{
		displayName = $STR_b_soldier_exp_f0;
		icon = "\A3\ui_f\data\map\VehicleIcons\iconManExplosive_ca.paa";
		show = "side group _this == west";
		role = "Support";
		weapons[] = {"vn_m3a1","vn_m72","Throw","Put"};
		magazines[] = {"vn_m3a1_t_mag","vn_m72_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m14_grenade_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m3a1_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_yellow_mag","vn_m18_yellow_mag","vn_mine_tripwire_m16_04_mag","vn_mine_tripwire_m16_04_mag","vn_mine_tripwire_m16_04_mag","vn_mine_tripwire_m16_04_mag","vn_mine_m112_remote_mag","vn_mine_m112_remote_mag","vn_mine_m15_mag"};
		items[] = {"vn_b_item_firstaidkit","vn_b_item_toolkit","vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		linkedItems[] = {"vn_b_vest_usarmy_03","vn_b_boonie_03_06","vn_b_scarf_01_03","vn_b_item_map","vn_b_item_compass","vn_b_item_watch","vn_b_item_radio_urc10"};
		uniformClass = "vn_b_uniform_macv_03_06";
		backpack = "vn_b_pack_trp_03_02_eng_m3a1_pl";
	};
};
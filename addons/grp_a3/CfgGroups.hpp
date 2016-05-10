class CfgGroups
{
	class East
	{
		class OPF_F
		{
			class Infantry
			{
				class OIA_InfSquad
				{
					rarityGroup = 0.5;
				};
				class OIA_InfSquad_Weapons
				{
					rarityGroup = 0.5;
				};
				class OIA_InfTeam
				{
					rarityGroup = 0.3;
				};
				class OIA_InfTeam_AT
				{
					rarityGroup = 0.1;
				};
				class OIA_InfSentry
				{
					rarityGroup = 0.5;
				};
				class OIA_InfWepTeam
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Infantry_OIA_InfWepTeam0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1 // TODO - Should be Heavy MG
					{
						side = 0;
						vehicle = "O_soldier_AR_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_soldier_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
				};
				class OIA_InfSupTeam
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Infantry_OIA_InfSupTeam0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1 // TODO - Should be Heavy AT
					{
						side = 0;
						vehicle = "O_soldier_LAT_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_medic_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_soldier_M_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
				};
				class OIA_InfHQ
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Infantry_OIA_InfHQ0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.1;
					class Unit0
					{
						side = 0;
						vehicle = "O_soldier_SL_F";
						rank = "LIEUTENANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_medic_F";
						rank = "CORPORAL";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_soldier_repair_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_soldier_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
				};
				class OIA_InfSniper
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Infantry_OIA_InfSniper0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.05;
					class Unit0
					{
						side = 0;
						vehicle = "O_sniper_F";
						rank = "LIEUTENANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_spotter_F";
						rank = "SERGEANT";
						position[] = {3,0,0};
					};
				};
			};
			class SpecOps
			{
				class OI_diverTeam
				{
					rarityGroup = 0.3;
				};
				class OI_diverTeam_Boat
				{
					rarityGroup = 0.3;
				};
			};
			class Support
			{
				class OI_support_CLS
				{
					rarityGroup = 0.1;
				};
				class OI_support_EOD
				{
					rarityGroup = 0.1;
				};
				class OI_support_ENG
				{
					rarityGroup = 0.1;
				};
			};
			class Motorized_MTP
			{
				class OIA_MotInf_Team
				{
					rarityGroup = 0.3;
				};
				class OIA_MotInf_AT
				{
					rarityGroup = 0.1;
				};
				class OIA_MotInf_Section
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Motorized_MTP_OIA_MotInfSection0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.5;
					class Unit0
					{
						side = 0;
						vehicle = "O_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle="O_MRAP_02_hmg_F";
						rank = "SERGEANT";
						position[] = {-5,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_MRAP_02_gmg_F";
						rank = "CORPORAL";
						position[] = {-5,-7,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_soldier_AR_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit4 // TODO - Should be Heavy AT
					{
						side = 0;
						vehicle = "O_soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_soldier_AR_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_soldier_F";
						rank = "PRIVATE";
						position[] = {11,0,0};
					};
				};
				class OIA_MotInf_ATV
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Motorized_MTP_OIA_MotInf_ATV0";
					faction = "OPF_F";
					side = 0;
					rarityGroup = 0.2;
					class Unit0
					{
						side = 0;
						vehicle = "O_Quadbike_ALIVE";
						rank = "SERGEANT";
						position[] = {-5,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Quadbike_ALIVE";
						rank = "CORPORAL";
						position[] = {-5,-7,0};
					};
				};
				class OIA_MotInf_HQ
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Motorized_MTP_OIA_MotInf_HQ0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.1;
					class Unit0
					{
						side = 0;
						vehicle = "O_soldier_SL_F";
						rank = "LIEUTENANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_MRAP_02_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {3,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_Medic_F";
						rank = "CORPORAL";
						position[] = {5,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_soldier_repair_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
				};
				class OIA_MotInf_Transport
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Motorized_MTP_OIA_MotInf_Transport0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.5;
					class Unit0
					{
						side = 0;
						vehicle = "O_soldier_SL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_soldier_AR_F";
						rank = "CORPORAL";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_soldier_AR_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_soldier_AAR_F";
						rank = "PRIVATE";
						position[] = {-10,-10,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_soldier_LAT_F";
						rank = "CORPORAL";
						position[] = {15,-15,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_medic_F";
						rank = "PRIVATE";
						position[] = {-15,-15,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_soldier_F";
						rank = "PRIVATE";
						position[] = {20,-20,0};
					};
					class Unit8
					{
						side = 0;
						vehicle="O_Truck_02_covered_F";
						rank = "PRIVATE";
						position[] = {-20,-20,0};
					};
				};
			};
			class Mechanized
			{
				name = "$STR_A3_CfgGroups_East_OPF_F_Mech0";
				class OIA_MechInf_Section1
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Mechanize_OIA_MechInf_Section10";
					faction = "OPF_F";
					rarityGroup = 0.9;
					class Unit0
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "LIEUTENANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_Soldier_TL_F";
						rank = "CORPORAL";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_APC_Wheeled_02_rcws_F";
						rank = "PRIVATE";
						position[] = {-5,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_Soldier_AR_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_Soldier_GL_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {11,0,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {13,0,0};
					};
					class Unit8
					{
						side = 0;
						vehicle = "O_soldier_M_F";
						rank = "PRIVATE";
						position[] = {15,0,0};
					};
				};
				class OIA_MechInf_Section2
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Mechanize_OIA_MechInf_Section20";
					faction = "OPF_F";
					rarityGroup = 0.9;
					class Unit0
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_Soldier_TL_F";
						rank = "CORPORAL";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_APC_Wheeled_02_rcws_F";
						rank = "PRIVATE";
						position[] = {-5,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_Soldier_AR_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_Soldier_GL_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {11,0,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {13,0,0};
					};
					class Unit8
					{
						side = 0;
						vehicle = "O_soldier_repair_F";
						rank = "PRIVATE";
						position[] = {15,0,0};
					};
				};
				class OIA_MechInf_Section3
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Mechanize_OIA_MechInf_Section30";
					faction = "OPF_F";
					rarityGroup = 0.9;
					class Unit0
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Soldier_TL_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_APC_Wheeled_02_rcws_F";
						rank = "PRIVATE";
						position[] = {-5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_Soldier_AR_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_Soldier_GL_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {11,0,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_medic_F";
						rank = "PRIVATE";
						position[] = {13,0,0};
					};
				};
				class OIA_MechInf_CoyHQ
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Mechanize_OIA_MechInf_CoyHQ0";
					faction = "OPF_F";
					rarityGroup = 0.1;
					class Unit0
					{
						side = 0;
						vehicle = "O_officer_F";
						rank = "CAPTAIN";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_officer_F";
						rank = "LIEUTENANT";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_APC_Wheeled_02_rcws_F";
						rank = "PRIVATE";
						position[] = {-5,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_soldier_repair_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
				};
				class OIA_MechInf_SectionAT
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Mechanize_OIA_MechInf_SectionAT0";
					faction = "OPF_F";
					rarityGroup = 0.5;
					class Unit0
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Soldier_TL_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_APC_Wheeled_02_rcws_F";
						rank = "PRIVATE";
						position[] = {-5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_Soldier_AT_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_Soldier_AT_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_Soldier_AT_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {11,0,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {13,0,0};
					};
				};
				class OIA_MechInf_SectionMG
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Mechanize_OIA_MechInf_SectionMG0";
					faction = "OPF_F";
					rarityGroup = 0.5;
					class Unit0
					{
						side = 0;
						vehicle = "O_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Soldier_TL_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_APC_Wheeled_02_rcws_F";
						rank = "PRIVATE";
						position[] = {-5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_Soldier_AR_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_Soldier_AR_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_Soldier_AR_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {11,0,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {13,0,0};
					};
				};
			};
			class Air
			{
				name = "$STR_A3_CfgGroups_East_OPF_F_Air0";
				class OIA_PO30_Squadron
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Air_OIA_PO30_Squadron0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.1;
					minAltitude = 40;
					maxAltitude = 100;
					class Unit0
					{
						side = 0;
						vehicle = "O_Heli_Attack_02_F";
						rank = "CAPTAIN";
						position[] = {0,15,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Heli_Attack_02_F";
						rank = "LIEUTENANT";
						position[] = {15,0,0};
					};
				};
				class OIA_PO30_Transport
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Air_OIA_PO30_Transport0";
					side = 0;
					faction = "OPF_F";
					rarityGroup = 0.5;
					minAltitude = 60;
					maxAltitude = 150;
					class Unit0
					{
						side = 0;
						vehicle = "O_Heli_Light_02_unarmed_F";
						rank = "CAPTAIN";
						position[] = {0,15,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Heli_Light_02_unarmed_F";
						rank = "LIEUTENANT";
						position[] = {15,0,0};
					};
				};
			};
			class Naval
			{
				name = "$STR_A3_CfgGroups_East_OPF_F_Naval";
				class OI_sentryTeam_SpeedBoat
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Naval_OIA_sentryTeam_Boat0";
					side = 0;
					faction = "OPF_F";
					icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
					class Unit0
					{
						side = 0;
						vehicle = "O_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_Boat_Armed_01_hmg_F";
						rank = "PRIVATE";
						position[] = {-32,-57,0};
					};
				};
				class OI_diverTeam
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_diverTeam0";
					side = 0;
					faction = "OPF_F";
					icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
					class Unit0
					{
						side = 0;
						vehicle = "O_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_diver_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_diver_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class OI_diverTeam_Boat
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_diverTeam_Boat0";
					side = 0;
					faction = "OPF_F";
					icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
					class Unit0
					{
						side = 0;
						vehicle = "O_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_diver_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_diver_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_Boat_Transport_01_F";
						rank = "PRIVATE";
						position[] = {-32,-57,0};
					};
				};
				class OI_diverTeam_SDV
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_diverTeam_SDV0";
					side = 0;
					faction = "OPF_F";
					icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
					class Unit0
					{
						side = 0;
						vehicle = "O_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_diver_F";
						rank = "PRIVATE";
						position[] = {-6,-6,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_diver_F";
						rank = "PRIVATE";
						position[] = {11,-11,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_SDV_01_F";
						rank = "PRIVATE";
						position[] = {-16,-16,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_SDV_01_F";
						rank = "PRIVATE";
						position[] = {21,-21,0};
					};
				};
			};
		};
		class OPF_G_F
		{
			name = "OPFIA";
			class Infantry
			{
				name = "Infantry";
				class ORG_InfSentry
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfSentry0";  // name = "Sentry";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_GL_F";
						rank = "CORPORAL";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "PRIVATE";
						position[] = {5,-5,0};
					};
				};
				class ORG_InfSquad
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfSquad0";  // name = "Rifle Squad";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "CORPORAL";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_G_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {-10,-10,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_G_medic_F";
						rank = "CORPORAL";
						position[] = {15,-15,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "PRIVATE";
						position[] = {-15,-15,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "PRIVATE";
						position[] = {20,-20,0};
					};
				};
				class ORG_InfSquad_Weapons
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfSquad_Weapons0";  // name = "Weapons Squad";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_SL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "SERGEANT";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "CORPORAL";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "SERGEANT";
						position[] = {10,-10,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "CORPORAL";
						position[] = {-10,-10,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "PRIVATE";
						position[] = {-15,-15,0};
					};
					class Unit6
					{
						side = 0;
						vehicle = "O_G_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {15,-15,0};
					};
					class Unit7
					{
						side = 0;
						vehicle = "O_G_medic_F";
						rank = "PRIVATE";
						position[] = {20,-20,0};
					};
				};
				class ORG_InfTeam
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfTeam0";  // name = "Fire Team";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Soldier_GL_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class ORG_InfTeam_AA
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfTeam_AA0";  // name = "Air-defense Team";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class ORG_InfTeam_AT
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfTeam_AT0";  // name = "Anti-armor Team";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_A_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class ORG_InfWepTeam
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfWepTeam0";  // name = "Weapons Team";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1 // TODO - Should be Heavy MG
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
				};
				class ORG_InfSupTeam
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfSupTeam0"; // name = "Support Team";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.3;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,5,0};
					};
					class Unit1 // TODO - Should be Heavy AT
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "CORPORAL";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_medic_F";
						rank = "PRIVATE";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_M_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
				};
				class ORG_InfHQ
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_InfHQ0";  // name = "Infantry HQ";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_SL_F";
						rank = "LIEUTENANT";
						position[] = {0,5,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {3,0,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_medic_F";
						rank = "CORPORAL";
						position[] = {5,0,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_engineer_F";
						rank = "PRIVATE";
						position[] = {7,0,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "PRIVATE";
						position[] = {9,0,0};
					};
				};
				class ORG_ReconSentry
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_ReconSentry0"; // name = "Recon Sentry";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "CORPORAL";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "PRIVATE";
						position[] = {5,-5,0};
					};
				};
			};
			class Motorized_MTP
			{
				name = "Motorized Infantry";
				class ORG_MotInf_Team
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Motorized_MTP_ORG_MotInf_Team0"; // name = "Motorized Patrol";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.2;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Offroad_01_F";
						rank = "SERGEANT";
						position[] = {0,-10,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_Soldier_LAT_F";
						rank = "CORPORAL";
						position[] = {-5,-5,0};
					};
					class Unit4
					{
						side = 0;
						vehicle = "O_G_medic_F";
						rank = "CORPORAL";
						position[] = {10,-10,0};
					};
					class Unit5
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "CORPORAL";
						position[] = {-10,-10,0};
					};
				};
				class ORG_Technicals
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Motorized_MTP_ORG_Technicals0"; // name = "Technicals";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.2;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Offroad_01_armed_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Offroad_01_armed_F";
						rank = "SERGEANT";
						position[] = {10,-10,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_Offroad_01_armed_F";
						rank = "CORPORAL";
						position[] = {-10,-10,0};
					};
				};
			};
			class Support
			{
				name = "Support Infantry";
				class ORG_Support_CLS
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_Support_CLS0";  // name = "Support Team (CLS)";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.1;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_AR_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_medic_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_medic_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class ORG_Support_ENG
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_Support_ENG0";  // name = "Support Team (Engineer)";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.1;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_engineer_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_engineer_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class ORG_Support_EOD
				{
					name = "$STR_A3_CfgGroups_East_OPF_G_F_Infantry_ORG_Support_EOD0";  // name = "Support Team (EOD)";
					side = 0;
					faction = "OPF_G_F";
					rarityGroup = 0.1;
					class Unit0
					{
						side = 0;
						vehicle = "O_G_Soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "O_G_Soldier_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 0;
						vehicle = "O_G_engineer_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 0;
						vehicle = "O_G_engineer_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
			};
		};
	};

	class West
	{
		class BLU_F
		{
			class Naval
			{
				name = "$STR_A3_CfgGroups_West_BLU_F_Naval";
				class BUS_sentryTeam_SpeedBoat
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Naval_OIA_sentryTeam_Boat0";
					side = 0;
					faction = "BLU_F";
					icon = "\A3\ui_f\data\map\markers\nato\b_naval.paa";
					class Unit0
					{
						side = 0;
						vehicle = "B_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "B_Boat_Armed_01_minigun_F";
						rank = "PRIVATE";
						position[] = {-32,-57,0};
					};
				};
				class BUS_DiverTeam
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_DiverTeam0";
					side = 1;
					faction = "BLU_F";
					icon = "\A3\ui_f\data\map\markers\nato\b_naval.paa";
					class Unit0
					{
						side = 1;
						vehicle = "B_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 1;
						vehicle = "B_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 1;
						vehicle = "B_diver_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 1;
						vehicle = "B_diver_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class BUS_DiverTeam_Boat
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_DiverTeam_Boat0";
					side = 1;
					faction = "BLU_F";
					icon = "\A3\ui_f\data\map\markers\nato\b_naval.paa";
					class Unit0
					{
						side = 1;
						vehicle = "B_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 1;
						vehicle = "B_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 1;
						vehicle = "B_diver_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 1;
						vehicle = "B_diver_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
					class Unit4
					{
						side = 1;
						vehicle = "B_Boat_Transport_01_F";
						rank = "PRIVATE";
						position[] = {-32,-57,0};
					};
				};
				class BUS_DiverTeam_SDV
				{
					name = "$STR_A3_cfggroups_West_BLU_F_SpecOps_BUS_DiverTeam_SDV0";
					side = 1;
					faction = "BLU_F";
					icon = "\A3\ui_f\data\map\markers\nato\b_naval.paa";
					class Unit0
					{
						side = 1;
						vehicle = "B_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 1;
						vehicle = "B_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 1;
						vehicle = "B_diver_F";
						rank = "PRIVATE";
						position[] = {-6,-6,0};
					};
					class Unit3
					{
						side = 1;
						vehicle = "B_diver_F";
						rank = "PRIVATE";
						position[] = {11,-11,0};
					};
					class Unit4
					{
						side = 1;
						vehicle = "B_SDV_01_F";
						rank = "PRIVATE";
						position[] = {-16,-16,0};
					};
					class Unit5
					{
						side = 1;
						vehicle = "B_SDV_01_F";
						rank = "PRIVATE";
						position[] = {21,-21,0};
					};
				};
			};
		};
	};
	class Indep
	{
		class IND_F
		{
			class Naval
			{
				name = "$STR_A3_CfgGroups_West_BLU_F_Naval";
				class HAF_sentryTeam_SpeedBoat
				{
					name = "$STR_A3_CfgGroups_East_OPF_F_Naval_OIA_sentryTeam_Boat0";
					side = 0;
					faction = "IND_F";
					icon = "\A3\ui_f\data\map\markers\nato\n_naval.paa";
					class Unit0
					{
						side = 0;
						vehicle = "I_soldier_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 0;
						vehicle = "I_Boat_Armed_01_minigun_F";
						rank = "PRIVATE";
						position[] = {-32,-57,0};
					};
				};
				class HAF_DiverTeam
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_DiverTeam0";
					side = 2;
					faction = "IND_F";
					icon = "\A3\ui_f\data\map\markers\nato\n_naval.paa";
					class Unit0
					{
						side = 2;
						vehicle = "I_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 2;
						vehicle = "I_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 2;
						vehicle = "I_diver_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 2;
						vehicle = "I_diver_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
				};
				class HAF_DiverTeam_Boat
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_DiverTeam_Boat0";
					side = 2;
					faction = "IND_F";
					icon = "\A3\ui_f\data\map\markers\nato\n_naval.paa";
					class Unit0
					{
						side = 2;
						vehicle = "I_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 2;
						vehicle = "I_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 2;
						vehicle = "I_diver_F";
						rank = "PRIVATE";
						position[] = {-5,-5,0};
					};
					class Unit3
					{
						side = 2;
						vehicle = "I_diver_F";
						rank = "PRIVATE";
						position[] = {10,-10,0};
					};
					class Unit4
					{
						side = 2;
						vehicle = "I_Boat_Transport_01_F";
						rank = "PRIVATE";
						position[] = {-32,-57,0};
					};
				};
				class HAF_DiverTeam_SDV
				{
					name = "$STR_A3_CfgGroups_West_BLU_F_SpecOps_BUS_DiverTeam_SDV0";
					side = 2;
					faction = "IND_F";
					icon = "\A3\ui_f\data\map\markers\nato\n_naval.paa";
					class Unit0
					{
						side = 2;
						vehicle = "I_diver_TL_F";
						rank = "SERGEANT";
						position[] = {0,0,0};
					};
					class Unit1
					{
						side = 2;
						vehicle = "I_diver_exp_F";
						rank = "CORPORAL";
						position[] = {5,-5,0};
					};
					class Unit2
					{
						side = 2;
						vehicle = "I_diver_F";
						rank = "PRIVATE";
						position[] = {-6,-6,0};
					};
					class Unit3
					{
						side = 2;
						vehicle = "I_diver_F";
						rank = "PRIVATE";
						position[] = {11,-11,0};
					};
					class Unit4
					{
						side = 2;
						vehicle = "I_SDV_01_F";
						rank = "PRIVATE";
						position[] = {-16,-16,0};
					};
					class Unit5
					{
						side = 2;
						vehicle = "I_SDV_01_F";
						rank = "PRIVATE";
						position[] = {21,-21,0};
					};
				};
			};
		};
	};
};




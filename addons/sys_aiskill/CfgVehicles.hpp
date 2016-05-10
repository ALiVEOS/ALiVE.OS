class CfgVehicles {
	class ModuleAliveBase;
	class ADDON: ModuleAliveBase {
		author = MODULE_AUTHOR;
		// Editor visibility; 2 will show it in the menu, 1 will hide it.
		scope = 2;
		// Name displayed in the menu
		displayName = "$STR_ALIVE_AISkill";
		// Map icon. Delete this entry to use the default icon
		icon = "x\alive\addons\sys_aiskill\icon_sys_AISkill.paa";
		// Name of function triggered once conditions are met
		function = "ALIVE_fnc_AISkillInit";
		// Execution priority, modules with lower number are executed first. 0 is used when the attribute is undefined
		functionPriority = 50;
		// 1 for remote execution on all clients, 0 for server only execution
		isGlobal = 0;
		// 1 for module waiting until all synced triggers are activated
		isTriggerActivated = 0;

		picture = "x\alive\addons\sys_aiskill\icon_sys_AISkill.paa";

		// Module description. Must inherit from base class, otherwise pre-defined entities won't be available
		class ModuleDescription
		{
			// Short description, will be formatted as structured text
			description = "$STR_ALIVE_AISKILL_COMMENT";
		};

		// Module arguments
		class Arguments {
			// Module specific arguments
			class debug {
				// Argument label
				displayName = "$STR_ALIVE_AISKILL_DEBUG";
				// Tooltip description
				description = "$STR_ALIVE_AISKILL_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
					};
					class No {
						name = "No";
						value = 0;
						default = 1;
					};
				};
			};
			class skillFactionsRecruit {
				displayName = "$STR_ALIVE_AISKILL_RECRUIT";
				description = "$STR_ALIVE_AISKILL_RECRUIT_COMMENT";
				defaultValue = "";
			};
			class skillFactionsRegular {
				displayName = "$STR_ALIVE_AISKILL_REGULAR";
				description = "$STR_ALIVE_AISKILL_REGULAR_COMMENT";
				defaultValue = "";
			};
			class skillFactionsVeteran {
				displayName = "$STR_ALIVE_AISKILL_VETERAN";
				description = "$STR_ALIVE_AISKILL_VETERAN_COMMENT";
				defaultValue = "";
			};
			class skillFactionsExpert {
				displayName = "$STR_ALIVE_AISKILL_EXPERT";
				description = "$STR_ALIVE_AISKILL_EXPERT_COMMENT";
				defaultValue = "";
			};
			class customSkillFactions {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM";
				description = "$STR_ALIVE_AISKILL_CUSTOM_COMMENT";
				defaultValue = "";
			};
			class customSkillAbilityMin {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MIN";
				description = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MIN_COMMENT";
				defaultValue = 0.2;
				typeName = "NUMBER";
			};
			class customSkillAbilityMax {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MAX";
				description = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MAX_COMMENT";
				defaultValue = 0.25;
				typeName = "NUMBER";
			};
			class customSkillAimAccuracy {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_AIM_ACCURACY";
				description = "$STR_ALIVE_AISKILL_CUSTOM_AIM_ACCURACY_COMMENT";
				defaultValue = 0.3;
				typeName = "NUMBER";
			};
			class customSkillAimShake {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SHAKE";
				description = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SHAKE_COMMENT";
				defaultValue = 0.9;
				typeName = "NUMBER";
			};
			class customSkillAimSpeed {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SPEED";
				description = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SPEED_COMMENT";
				defaultValue = 0.3;
				typeName = "NUMBER";
			};
			class customSkillEndurance {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_ENDURANCE";
				description = "$STR_ALIVE_AISKILL_CUSTOM_ENDURANCE_COMMENT";
				defaultValue = 0.3;
				typeName = "NUMBER";
			};
			class customSkillSpotDistance {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_DISTANCE";
				description = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_DISTANCE_COMMENT";
				defaultValue = 0.9;
				typeName = "NUMBER";
			};
			class customSkillSpotTime {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_TIME";
				description = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_TIME_COMMENT";
				defaultValue = 0.5;
				typeName = "NUMBER";
			};
			class customSkillCourage {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_COURAGE";
				description = "$STR_ALIVE_AISKILL_CUSTOM_COURAGE_COMMENT";
				defaultValue = 0.7;
				typeName = "NUMBER";
			};
			class customSkillReload {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_RELOAD";
				description = "$STR_ALIVE_AISKILL_CUSTOM_RELOAD_COMMENT";
				defaultValue = 0.3;
				typeName = "NUMBER";
			};
			class customSkillCommanding {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_COMMANDING";
				description = "$STR_ALIVE_AISKILL_CUSTOM_COMMANDING_COMMENT";
				defaultValue = 1;
				typeName = "NUMBER";
			};
			class customSkillGeneral {
				displayName = "$STR_ALIVE_AISKILL_CUSTOM_GENERAL";
				description = "$STR_ALIVE_AISKILL_CUSTOM_GENERAL_COMMENT";
				defaultValue = 0.5;
				typeName = "NUMBER";
			};
		};
	};
};

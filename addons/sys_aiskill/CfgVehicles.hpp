class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; };
        class ModuleDescription;
    };
    class ADDON: ModuleAliveBase {
        author = MODULE_AUTHOR;
        scope = 2;
        displayName = "$STR_ALIVE_AISkill";
        icon = "x\alive\addons\sys_aiskill\icon_sys_AISkill.paa";
        function = "ALIVE_fnc_AISkillInit";
        functionPriority = 50;
        isGlobal = 0;
        isTriggerActivated = 0;
        picture = "x\alive\addons\sys_aiskill\icon_sys_AISkill.paa";
        class ModuleDescription { description = "$STR_ALIVE_AISKILL_COMMENT"; };
        class Attributes : AttributesBase
        {
            // ── GENERAL ──────────────────────────────────────────────────────
            class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_HDR_GENERAL"; displayName = "GENERAL"; };
            class debug : Combo
            {
                    property = "ALiVE_sys_aiskill_debug";
                    displayName = "$STR_ALIVE_AISKILL_DEBUG";
                    tooltip = "$STR_ALIVE_AISKILL_DEBUG_COMMENT";
                    defaultValue = """0""";
                    class Values
                    {
                        class Yes { name = "Yes"; value = 1; };
                        class No { name = "No"; value = 0; default = 1; };
                    };
            };
            // ── SKILL PRESETS BY FACTION ──────────────────────────────────────
            class HDR_PRESETS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_HDR_PRESETS"; displayName = "SKILL PRESETS BY FACTION"; };
            class skillFactionsRecruit
            {
                property     = "ALiVE_sys_aiskill_skillFactionsRecruit";
                displayName  = "$STR_ALIVE_AISKILL_RECRUIT";
                tooltip      = "$STR_ALIVE_AISKILL_RECRUIT_COMMENT";
                control      = "ALiVE_FactionChoiceMulti_Military";
                typeName     = "STRING";
                expression   = "_this setVariable ['skillFactionsRecruit', _value];";
                defaultValue = """[]""";
            };
            class skillFactionsRecruitManual : Edit { property = "ALiVE_sys_aiskill_skillFactionsRecruitManual"; displayName = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL"; tooltip = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_RECRUIT : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_SPACER_RECRUIT"; displayName = " "; };
            class skillFactionsRegular
            {
                property     = "ALiVE_sys_aiskill_skillFactionsRegular";
                displayName  = "$STR_ALIVE_AISKILL_REGULAR";
                tooltip      = "$STR_ALIVE_AISKILL_REGULAR_COMMENT";
                control      = "ALiVE_FactionChoiceMulti_Military";
                typeName     = "STRING";
                expression   = "_this setVariable ['skillFactionsRegular', _value];";
                defaultValue = """[]""";
            };
            class skillFactionsRegularManual : Edit { property = "ALiVE_sys_aiskill_skillFactionsRegularManual"; displayName = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL"; tooltip = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_REGULAR : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_SPACER_REGULAR"; displayName = " "; };
            class skillFactionsVeteran
            {
                property     = "ALiVE_sys_aiskill_skillFactionsVeteran";
                displayName  = "$STR_ALIVE_AISKILL_VETERAN";
                tooltip      = "$STR_ALIVE_AISKILL_VETERAN_COMMENT";
                control      = "ALiVE_FactionChoiceMulti_Military";
                typeName     = "STRING";
                expression   = "_this setVariable ['skillFactionsVeteran', _value];";
                defaultValue = """[]""";
            };
            class skillFactionsVeteranManual : Edit { property = "ALiVE_sys_aiskill_skillFactionsVeteranManual"; displayName = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL"; tooltip = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_VETERAN : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_SPACER_VETERAN"; displayName = " "; };
            class skillFactionsExpert
            {
                property     = "ALiVE_sys_aiskill_skillFactionsExpert";
                displayName  = "$STR_ALIVE_AISKILL_EXPERT";
                tooltip      = "$STR_ALIVE_AISKILL_EXPERT_COMMENT";
                control      = "ALiVE_FactionChoiceMulti_Military";
                typeName     = "STRING";
                expression   = "_this setVariable ['skillFactionsExpert', _value];";
                defaultValue = """[]""";
            };
            class skillFactionsExpertManual : Edit { property = "ALiVE_sys_aiskill_skillFactionsExpertManual"; displayName = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL"; tooltip = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_EXPERT : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_SPACER_EXPERT"; displayName = " "; };
            // ── CUSTOM SKILL OVERRIDE ─────────────────────────────────────────
            class HDR_CUSTOM : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_HDR_CUSTOM"; displayName = "CUSTOM SKILL VALUES"; };
            class customSkillFactions
            {
                property     = "ALiVE_sys_aiskill_customSkillFactions";
                displayName  = "$STR_ALIVE_AISKILL_CUSTOM";
                tooltip      = "$STR_ALIVE_AISKILL_CUSTOM_COMMENT";
                control      = "ALiVE_FactionChoiceMulti_Military";
                typeName     = "STRING";
                expression   = "_this setVariable ['customSkillFactions', _value];";
                defaultValue = """[]""";
            };
            class customSkillFactionsManual : Edit { property = "ALiVE_sys_aiskill_customSkillFactionsManual"; displayName = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL"; tooltip = "$STR_ALIVE_AISKILL_FACTIONS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_CUSTOM_FACTIONS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_SPACER_CUSTOM_FACTIONS"; displayName = " "; };
            class customSkillAbilityMin : Edit { property = "ALiVE_sys_aiskill_customSkillAbilityMin"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MIN"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MIN_COMMENT"; defaultValue = """0.2"""; typeName = "NUMBER"; };
            class customSkillAbilityMax : Edit { property = "ALiVE_sys_aiskill_customSkillAbilityMax"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MAX"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_ABILITY_MAX_COMMENT"; defaultValue = """0.25"""; typeName = "NUMBER"; };
            class customSkillAimAccuracy : Edit { property = "ALiVE_sys_aiskill_customSkillAimAccuracy"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_AIM_ACCURACY"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_AIM_ACCURACY_COMMENT"; defaultValue = """0.3"""; typeName = "NUMBER"; };
            class customSkillAimShake : Edit { property = "ALiVE_sys_aiskill_customSkillAimShake"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SHAKE"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SHAKE_COMMENT"; defaultValue = """0.9"""; typeName = "NUMBER"; };
            class customSkillAimSpeed : Edit { property = "ALiVE_sys_aiskill_customSkillAimSpeed"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SPEED"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_AIM_SPEED_COMMENT"; defaultValue = """0.3"""; typeName = "NUMBER"; };
            class customSkillEndurance : Edit { property = "ALiVE_sys_aiskill_customSkillEndurance"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_ENDURANCE"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_ENDURANCE_COMMENT"; defaultValue = """0.3"""; typeName = "NUMBER"; };
            class customSkillSpotDistance : Edit { property = "ALiVE_sys_aiskill_customSkillSpotDistance"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_DISTANCE"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_DISTANCE_COMMENT"; defaultValue = """0.9"""; typeName = "NUMBER"; };
            class customSkillSpotTime : Edit { property = "ALiVE_sys_aiskill_customSkillSpotTime"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_TIME"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_SPOT_TIME_COMMENT"; defaultValue = """0.5"""; typeName = "NUMBER"; };
            class customSkillCourage : Edit { property = "ALiVE_sys_aiskill_customSkillCourage"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_COURAGE"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_COURAGE_COMMENT"; defaultValue = """0.7"""; typeName = "NUMBER"; };
            class customSkillFleeing : Edit { property = "ALiVE_sys_aiskill_customSkillFleeing"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_FLEEING"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_FLEEING_COMMENT"; defaultValue = """0.3"""; typeName = "NUMBER"; };
            class customSkillReload : Edit { property = "ALiVE_sys_aiskill_customSkillReload"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_RELOAD"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_RELOAD_COMMENT"; defaultValue = """0.3"""; typeName = "NUMBER"; };
            class customSkillCommanding : Edit { property = "ALiVE_sys_aiskill_customSkillCommanding"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_COMMANDING"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_COMMANDING_COMMENT"; defaultValue = """1"""; typeName = "NUMBER"; };
            class customSkillGeneral : Edit { property = "ALiVE_sys_aiskill_customSkillGeneral"; displayName = "$STR_ALIVE_AISKILL_CUSTOM_GENERAL"; tooltip = "$STR_ALIVE_AISKILL_CUSTOM_GENERAL_COMMENT"; defaultValue = """0.5"""; typeName = "NUMBER"; };
            class ModuleDescription : ModuleDescription {};
        };
    };
};

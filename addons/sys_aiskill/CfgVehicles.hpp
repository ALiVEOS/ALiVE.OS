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
            // Consolidated skill-tier picker (replaces the previous ten-
            // attribute layout: per-tier listbox + per-tier Manual edit
            // + spacer x 5). Stored in structured format
            // "recruit:Faction1;regular:Faction2,Faction3;veteran:;expert:;custom:Faction4"
            // via the ALiVE_FactionTierChoice control. The filter cycle
            // button SWAPS which tier's ticks display - rows themselves
            // stay constant. Runtime resolver in fnc_aiskill prefers
            // this attribute; legacy per-tier attrs below remain
            // defined as hidden back-compat aliases so missions saved
            // before consolidation still resolve when this key is empty.
            class skillTierFactions
            {
                property     = "ALiVE_sys_aiskill_skillTierFactions";
                displayName  = "$STR_ALIVE_AISKILL_TIER_FACTIONS";
                tooltip      = "$STR_ALIVE_AISKILL_TIER_FACTIONS_COMMENT";
                control      = "ALiVE_FactionTierChoice";
                typeName     = "STRING";
                expression   = "_this setVariable ['skillTierFactions', _value];";
                defaultValue = """""";
            };
            // Hidden legacy aliases - SQM-stored values from missions
            // saved before the consolidated picker existed are still
            // pushed onto the logic at scenario init via these
            // expressions, and the runtime resolver falls back to
            // them when skillTierFactions is empty.
            class skillFactionsRecruit         { property = "ALiVE_sys_aiskill_skillFactionsRecruit";         control = "ALiVE_HiddenAttribute"; defaultValue = """[]"""; expression = "_this setVariable ['skillFactionsRecruit', _value];";         typeName = "STRING"; displayName = ""; };
            class skillFactionsRecruitManual   { property = "ALiVE_sys_aiskill_skillFactionsRecruitManual";   control = "ALiVE_HiddenAttribute"; defaultValue = """""";   expression = "_this setVariable ['skillFactionsRecruitManual', _value];";   typeName = "STRING"; displayName = ""; };
            class skillFactionsRegular         { property = "ALiVE_sys_aiskill_skillFactionsRegular";         control = "ALiVE_HiddenAttribute"; defaultValue = """[]"""; expression = "_this setVariable ['skillFactionsRegular', _value];";         typeName = "STRING"; displayName = ""; };
            class skillFactionsRegularManual   { property = "ALiVE_sys_aiskill_skillFactionsRegularManual";   control = "ALiVE_HiddenAttribute"; defaultValue = """""";   expression = "_this setVariable ['skillFactionsRegularManual', _value];";   typeName = "STRING"; displayName = ""; };
            class skillFactionsVeteran         { property = "ALiVE_sys_aiskill_skillFactionsVeteran";         control = "ALiVE_HiddenAttribute"; defaultValue = """[]"""; expression = "_this setVariable ['skillFactionsVeteran', _value];";         typeName = "STRING"; displayName = ""; };
            class skillFactionsVeteranManual   { property = "ALiVE_sys_aiskill_skillFactionsVeteranManual";   control = "ALiVE_HiddenAttribute"; defaultValue = """""";   expression = "_this setVariable ['skillFactionsVeteranManual', _value];";   typeName = "STRING"; displayName = ""; };
            class skillFactionsExpert          { property = "ALiVE_sys_aiskill_skillFactionsExpert";          control = "ALiVE_HiddenAttribute"; defaultValue = """[]"""; expression = "_this setVariable ['skillFactionsExpert', _value];";          typeName = "STRING"; displayName = ""; };
            class skillFactionsExpertManual    { property = "ALiVE_sys_aiskill_skillFactionsExpertManual";    control = "ALiVE_HiddenAttribute"; defaultValue = """""";   expression = "_this setVariable ['skillFactionsExpertManual', _value];";    typeName = "STRING"; displayName = ""; };
            class customSkillFactions          { property = "ALiVE_sys_aiskill_customSkillFactions";          control = "ALiVE_HiddenAttribute"; defaultValue = """[]"""; expression = "_this setVariable ['customSkillFactions', _value];";          typeName = "STRING"; displayName = ""; };
            class customSkillFactionsManual    { property = "ALiVE_sys_aiskill_customSkillFactionsManual";    control = "ALiVE_HiddenAttribute"; defaultValue = """""";   expression = "_this setVariable ['customSkillFactionsManual', _value];";    typeName = "STRING"; displayName = ""; };
            // ── CUSTOM SKILL OVERRIDE ─────────────────────────────────────────
            class HDR_CUSTOM : ALiVE_ModuleSubTitle { property = "ALiVE_sys_aiskill_HDR_CUSTOM"; displayName = "CUSTOM SKILL VALUES"; };
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

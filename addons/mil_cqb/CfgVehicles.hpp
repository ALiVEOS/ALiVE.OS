class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase
        {
            class Edit;
            class Combo;
            class ModuleDescription;
        };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase
        {
            class ALiVE_ModuleSubTitle;
            class ALiVE_EditMultilineSQF;
        };
        class ModuleDescription;
    };
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_CQB";
                function = "ALIVE_fnc_CQBInit";
                author = MODULE_AUTHOR;
                functionPriority = 120;
                isGlobal = 2;
                icon = "x\alive\addons\mil_cqb\icon_mil_cqb.paa";
                picture = "x\alive\addons\mil_cqb\icon_mil_cqb.paa";
                class Attributes : AttributesBase
                {
                        // ---- General --------------------------------------------------------
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_GENERAL"; displayName = "GENERAL"; };
                        class CQB_debug_setting : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_debug_setting";
                                displayName = "$STR_ALIVE_CQB_DEBUG";
                                tooltip = "$STR_ALIVE_CQB_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class CQB_persistent : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_persistent";
                                displayName = "$STR_ALIVE_CQB_PERSISTENT";
                                tooltip = "$STR_ALIVE_CQB_PERSISTENT_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        // ---- Coverage & Density ---------------------------------------------
                        class HDR_PLACEMENT : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_PLACEMENT"; displayName = "COVERAGE & DENSITY"; };
                        class CQB_LOCATIONTYPE : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_LOCATIONTYPE";
                                displayName = "$STR_ALIVE_CQB_LOCATIONTYPE";
                                tooltip = "$STR_ALIVE_CQB_LOCATIONTYPE_COMMENT";
                                defaultValue = """all""";
                                class Values
                                {
                                    class Towns { name = "Towns"; value = "towns"; };
                                    class All { name = "Complete map"; value = "all"; default = 1; };
                                };
                        };
                        class CQB_TYPE : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_TYPE";
                                displayName = "$STR_ALIVE_CQB_TYPE";
                                tooltip = "$STR_ALIVE_CQB_TYPE_COMMENT";
                                defaultValue = """regular""";
                                class Values
                                {
                                    class MIL { name = "Strategic"; value = "strategic"; };
                                    class CIV { name = "Civilian"; value = "regular"; default = 1; };
                                };
                        };
                        class CQB_spawn_setting : Edit { property = "ALiVE_mil_cqb_CQB_spawn_setting"; displayName = "$STR_ALIVE_CQB_SPAWN"; tooltip = "$STR_ALIVE_CQB_SPAWN_COMMENT"; defaultValue = """1"""; };
                        class CQB_DENSITY : Edit
                        {
                                property = "ALiVE_mil_cqb_CQB_DENSITY";
                                displayName = "$STR_ALIVE_CQB_DENSITY";
                                tooltip = "$STR_ALIVE_CQB_DENSITY_COMMENT";
                                defaultValue = """99999""";
                                typeName = "NUMBER";
                        };
                        class CQB_amount : Edit
                        {
                                property = "ALiVE_mil_cqb_CQB_amount";
                                displayName = "$STR_ALIVE_CQB_AMOUNT";
                                tooltip = "$STR_ALIVE_CQB_AMOUNT_COMMENT";
                                defaultValue = """2""";
                                typeName = "NUMBER";
                        };
                        // ---- Filters --------------------------------------------------------
                        class HDR_FILTERS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_FILTERS"; displayName = "FILTERS"; };
                        class whitelist : Edit { property = "ALiVE_mil_cqb_whitelist"; displayName = "$STR_ALIVE_CQB_WHITELIST"; tooltip = "$STR_ALIVE_CQB_WHITELIST_COMMENT"; defaultValue = """"""; };
                        class blacklist : Edit { property = "ALiVE_mil_cqb_blacklist"; displayName = "$STR_ALIVE_CQB_BLACKLIST"; tooltip = "$STR_ALIVE_CQB_BLACKLIST_COMMENT"; defaultValue = """"""; };
                        class units_blacklist : Edit { property = "ALiVE_mil_cqb_units_blacklist"; displayName = "$STR_ALIVE_CQB_UNIT_BLACKLIST"; tooltip = "$STR_ALIVE_CQB_UNIT_BLACKLIST_COMMENT"; defaultValue = """"""; };
                        class CQB_fieldworks : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_fieldworks";
                                displayName = "$STR_ALIVE_CQB_FIELDWORKS";
                                tooltip = "$STR_ALIVE_CQB_FIELDWORKS_COMMENT";
                                defaultValue = """HOUSES""";
                                class Values
                                {
                                    class Houses { name = "$STR_ALIVE_CQB_FIELDWORKS_HOUSES"; value = "HOUSES"; default = 1; };
                                    class LeaveOut { name = "$STR_ALIVE_CQB_FIELDWORKS_LEAVEOUT"; value = "LEAVEOUT"; };
                                    class Strategic { name = "$STR_ALIVE_CQB_FIELDWORKS_STRATEGIC"; value = "STRATEGIC"; };
                                };
                        };
                        // ---- Factions -------------------------------------------------------
                        class HDR_FACTIONS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_FACTIONS"; displayName = "FACTIONS"; };
                        class CQB_UseDominantFaction : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_UseDominantFaction";
                                displayName = "$STR_ALIVE_CQB_USEDOMINANTFACTION";
                                tooltip = "$STR_ALIVE_CQB_USEDOMINANTFACTION_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Dominant"; value = "true"; default = 1; };
                                    class No { name = "Static"; value = "false"; };
                                };
                        };
                        class CQB_FACTIONS
                        {
                                property     = "ALiVE_mil_cqb_CQB_FACTIONS";
                                displayName  = "$STR_ALIVE_CQB_FACTIONS";
                                tooltip      = "$STR_ALIVE_CQB_FACTIONS_COMMENT";
                                // CQB-specific variant of FactionChoiceMulti_Military.
                                // Visible Title text "Factions:" plus the per-attribute
                                // tooltip $STR_ALIVE_CQB_FACTIONS_COMMENT are set by
                                // the LOAD handler via ctrlSetText / ctrlSetTooltip
                                // on idc 101.
                                control      = "ALiVE_FactionChoiceMulti_Military_CQB";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['CQB_FACTIONS', _value];";
                                defaultValue = """[]""";
                        };
                        class CQB_FACTIONS_manual : Edit
                        {
                                property     = "ALiVE_mil_cqb_CQB_FACTIONS_manual";
                                displayName  = "$STR_ALIVE_CQB_FACTIONS_MANUAL";
                                tooltip      = "$STR_ALIVE_CQB_FACTIONS_MANUAL_COMMENT";
                                defaultValue = """""";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['CQB_FACTIONS_manual', _value];";
                        };
                        // ---- Spawn Distances ------------------------------------------------
                        class HDR_SPAWN : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_SPAWN"; displayName = "SPAWN DISTANCES"; };
                        class CQB_spawndistance : Edit { property = "ALiVE_mil_cqb_CQB_spawndistance"; displayName = "$STR_ALIVE_CQB_SPAWNDISTANCE"; tooltip = "$STR_ALIVE_CQB_SPAWNDISTANCE_COMMENT"; defaultValue = """700"""; };
                        class CQB_spawndistanceStatic : Edit { property = "ALiVE_mil_cqb_CQB_spawndistanceStatic"; displayName = "$STR_ALIVE_CQB_SPAWNDISTANCESTATIC"; tooltip = "$STR_ALIVE_CQB_SPAWNDISTANCESTATIC_COMMENT"; defaultValue = """1200"""; };
                        class CQB_spawndistanceHeli : Edit { property = "ALiVE_mil_cqb_CQB_spawndistanceHeli"; displayName = "$STR_ALIVE_CQB_SPAWNDISTANCEHELI"; tooltip = "$STR_ALIVE_CQB_SPAWNDISTANCEHELI_COMMENT"; defaultValue = """0"""; };
                        class CQB_spawndistanceJet : Edit { property = "ALiVE_mil_cqb_CQB_spawndistanceJet"; displayName = "$STR_ALIVE_CQB_SPAWNDISTANCEJET"; tooltip = "$STR_ALIVE_CQB_SPAWNDISTANCEJET_COMMENT"; defaultValue = """0"""; };
                        // ---- Patrol Behaviour -----------------------------------------------
                        class HDR_PATROL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_PATROL"; displayName = "PATROL BEHAVIOUR"; };
                        class CQB_patrol_behaviour : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_patrol_behaviour";
                                displayName = "$STR_ALIVE_CQB_PATROLBEHAVIOUR";
                                tooltip = "$STR_ALIVE_CQB_PATROLBEHAVIOUR_COMMENT";
                                defaultValue = """SAFE""";
                                class Values
                                {
                                    class Careless { name = "Careless"; value = "CARELESS"; };
                                    class Safe { name = "Safe"; value = "SAFE"; default = 1; };
                                    class Aware { name = "Aware"; value = "AWARE"; };
                                    class Combat { name = "Combat"; value = "COMBAT"; };
                                    class Stealth { name = "Stealth"; value = "STEALTH"; };
                                };
                        };
                        class CQB_patrol_speed : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_patrol_speed";
                                displayName = "$STR_ALIVE_CQB_PATROLSPEED";
                                tooltip = "$STR_ALIVE_CQB_PATROLSPEED_COMMENT";
                                defaultValue = """LIMITED""";
                                class Values
                                {
                                    class Limited { name = "Limited (walk)"; value = "LIMITED"; default = 1; };
                                    class Normal { name = "Normal (jog)"; value = "NORMAL"; };
                                    class Full { name = "Full (run)"; value = "FULL"; };
                                };
                        };
                        class CQB_patrol_chance : Edit { property = "ALiVE_mil_cqb_CQB_patrol_chance"; displayName = "$STR_ALIVE_CQB_PATROLCHANCE"; tooltip = "$STR_ALIVE_CQB_PATROLCHANCE_COMMENT"; defaultValue = """30"""; };
                        class CQB_patrol_searchchance : Edit { property = "ALiVE_mil_cqb_CQB_patrol_searchchance"; displayName = "$STR_ALIVE_CQB_PATROLSEARCHCHANCE"; tooltip = "$STR_ALIVE_CQB_PATROLSEARCHCHANCE_COMMENT"; defaultValue = """30"""; };

                        class HDR_PATROL_TIMING : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_PATROL_TIMING"; displayName = "PATROL WAITS AND RANGE"; };
                        class CQB_patrol_minwaittime : Edit { property = "ALiVE_mil_cqb_CQB_patrol_minwaittime"; displayName = "$STR_ALIVE_CQB_MINWAITTIME"; tooltip = "$STR_ALIVE_CQB_MINWAITTIME_COMMENT"; defaultValue = """0"""; };
                        class CQB_patrol_midwaittime : Edit { property = "ALiVE_mil_cqb_CQB_patrol_midwaittime"; displayName = "$STR_ALIVE_CQB_MIDWAITTIME"; tooltip = "$STR_ALIVE_CQB_MIDWAITTIME_COMMENT"; defaultValue = """15"""; };
                        class CQB_patrol_maxwaittime : Edit { property = "ALiVE_mil_cqb_CQB_patrol_maxwaittime"; displayName = "$STR_ALIVE_CQB_MAXWAITTIME"; tooltip = "$STR_ALIVE_CQB_MAXWAITTIME_COMMENT"; defaultValue = """30"""; };
                        class CQB_patrol_mindist : Edit { property = "ALiVE_mil_cqb_CQB_patrol_mindist"; displayName = "$STR_ALIVE_CQB_MINDIST"; tooltip = "$STR_ALIVE_CQB_MINDIST_COMMENT"; defaultValue = """50"""; };
                        class CQB_patrol_maxist : Edit { property = "ALiVE_mil_cqb_CQB_patrol_maxist"; displayName = "$STR_ALIVE_CQB_MAXDIST"; tooltip = "$STR_ALIVE_CQB_MAXDIST_COMMENT"; defaultValue = """100"""; };
                        // ---- Static Weapons ------------------------------------------------
                        class HDR_STATIC : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_STATIC"; displayName = "STATIC WEAPONS"; };
                        class CQB_staticWeapons : Combo
                        {
                                property = "ALiVE_mil_cqb_CQB_staticWeapons";
                                displayName = "$STR_ALIVE_CQB_STATICWEAPONS";
                                tooltip = "$STR_ALIVE_CQB_STATICWEAPONS_COMMENT";
                                // "0" = None; an empty default compiled to nil at init and errored
                                defaultValue = """0""";
                                class Values
                                {
                                    class VeryHigh { name = "Very High"; Value = 2; };
                                    class High { name = "High"; Value = 1; };
                                    class Medium { name = "Medium"; Value = 0.5; };
                                    class Low { name = "Low"; Value = 0.25; };
                                    class None { name = "None"; Value = 0; };
                                };
                        };
                        class CQB_staticWeaponsClassnames : Edit { property = "ALiVE_mil_cqb_CQB_staticWeaponsClassnames"; displayName = "$STR_ALIVE_CQB_STATICWEAPONS_CLASSNAMES"; tooltip = "$STR_ALIVE_CQB_STATICWEAPONS_CLASSNAMES_COMMENT"; defaultValue = """B_HMG_01_high_F,O_Mortar_01_F,O_HMG_01_high_F"""; };
                        // ---- On Spawn Hook --------------------------------------------------
                        class HDR_HOOK : ALiVE_ModuleSubTitle { property = "ALiVE_mil_cqb_HDR_HOOK"; displayName = "ON SPAWN HOOK"; };
                        class onEachSpawn : ALiVE_EditMultilineSQF
                        {
                                property = "ALiVE_mil_cqb_onEachSpawn";
                                displayName = "$STR_ALIVE_CQB_ON_EACH_SPAWN";
                                tooltip = "$STR_ALIVE_CQB_ON_EACH_SPAWN_COMMENT";
                                defaultValue = """""";
                        };
                        class onEachSpawnOnce : Combo
                        {
                                property = "ALiVE_mil_cqb_onEachSpawnOnce";
                                displayName = "$STR_ALIVE_CQB_ON_EACH_SPAWN_ONCE";
                                tooltip = "$STR_ALIVE_CQB_ON_EACH_SPAWN_ONCE_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_CQB_COMMENT","","$STR_ALIVE_CQB_USAGE"};
                    // Added ALiVE_mil_OPCOM (CQB reads synced OPCOM at
                    // fnc_CQB.sqf:304 to borrow the OPCOM's faction list when
                    // its own faction is unset) and ALiVE_mil_placement_custom
                    // (symmetric with placement_custom.sync[] which already
                    // declares CQB). ALiVE_mil_placement_spe deliberately
                    // omitted - fixed-position placement module not intended
                    // to be commanded by CQB.
                    sync[] = {
                        "ALiVE_civ_placement",
                        "ALiVE_civ_placement_custom",
                        "ALiVE_mil_placement",
                        "ALiVE_mil_placement_custom",
                        "ALiVE_mil_OPCOM"
                    };
                    class ALiVE_civ_placement { description[] = {"$STR_ALIVE_CP_COMMENT","","$STR_ALIVE_CP_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_civ_placement_custom { description[] = {"$STR_ALIVE_CPC_COMMENT","","$STR_ALIVE_CPC_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_placement { description[] = {"$STR_ALIVE_MP_COMMENT","","$STR_ALIVE_MP_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_placement_custom { description[] = {"$STR_ALIVE_CMP_COMMENT","","$STR_ALIVE_CMP_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_OPCOM { description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                };
        };
};

class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; class ALiVE_EditMultilineSQF; };
        class ModuleDescription;
    };
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_SPEMP";
                function = "ALIVE_fnc_SPEMPInit";
                author = MODULE_AUTHOR;
                functionPriority = 100;
                isGlobal = 1;
                icon = "x\alive\addons\mil_placement_spe\icon_mil_SPEMP.paa";
                picture = "x\alive\addons\mil_placement_spe\icon_mil_SPEMP.paa";
                class Attributes : AttributesBase
                {
                        class debug : Combo
                        {
                                property = "ALiVE_mil_placement_spe_debug";
                                displayName = "$STR_ALIVE_SPEMP_DEBUG";
                                tooltip = "$STR_ALIVE_SPEMP_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        // Shared ALiVE_FactionChoice dropdown - see addons/main/CfgVehicles.hpp.
                        // SPE module defaults to BLU_F (Allied side, matching SPE's US-forces focus).
                        class faction
                        {
                                property     = "ALiVE_mil_placement_spe_faction";
                                displayName  = "$STR_ALIVE_SPEMP_FACTION";
                                tooltip      = "$STR_ALIVE_SPEMP_FACTION_COMMENT";
                                control      = "ALiVE_FactionChoice_Military";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction', _value];";
                                defaultValue = """BLU_F""";
                        };
                        class priority : Edit { property = "ALiVE_mil_placement_spe_priority"; displayName = "$STR_ALIVE_SPEMP_PRIORITY"; tooltip = "$STR_ALIVE_SPEMP_PRIORITY_COMMENT"; defaultValue = """50"""; };
                        class size : Edit { property = "ALiVE_mil_placement_spe_size"; displayName = "$STR_ALIVE_SPEMP_SIZE"; tooltip = "$STR_ALIVE_SPEMP_SIZE_COMMENT"; defaultValue = """50"""; };
                        class speInfantryClass : Edit { property = "ALiVE_mil_placement_spe_speInfantryClass"; displayName = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_CLASS"; tooltip = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_CLASS_COMMENT"; defaultValue = """"""; };
                        class speInfantryBehaviour : Combo
                        {
                                property = "ALiVE_mil_placement_spe_speInfantryBehaviour";
                                displayName = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_BEHAVIOUR";
                                tooltip = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_BEHAVIOUR_COMMENT";
                                defaultValue = """AWARE""";
                                class Values
                                {
                                    class AWARE { name = "Aware"; value = "AWARE"; default = 1; };
                                    class COMBAT { name = "Combat"; value = "COMBAT"; };
                                    class STEALTH { name = "Stealth"; value = "STEALTH"; };
                                    class SAFE { name = "Safe"; value = "SAFE"; };
                                    class CARELESS { name = "Careless"; value = "CARELESS"; };
                                };
                        };
                        class speVehicleClass : Edit { property = "ALiVE_mil_placement_spe_speVehicleClass"; displayName = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_CLASS"; tooltip = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_CLASS_COMMENT"; defaultValue = """"""; };
                        class speVehicleEmpty : Combo
                        {
                                property = "ALiVE_mil_placement_spe_speVehicleEmpty";
                                displayName = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_EMPTY";
                                tooltip = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_EMPTY_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class allowPlayerTasking : Combo
                        {
                                property = "ALiVE_mil_placement_spe_allowPlayerTasking";
                                displayName = "$STR_ALIVE_SPEMP_ALLOW_PLAYER_TASK";
                                tooltip = "$STR_ALIVE_SPEMP_ALLOW_PLAYER_TASK_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        // ---- On Spawn Hook --------------------------------------------------
                        class HDR_HOOK : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_spe_HDR_HOOK"; displayName = "ON SPAWN HOOK"; };
                        class onEachSpawn : ALiVE_EditMultilineSQF
                        {
                                property = "ALiVE_mil_placement_spe_onEachSpawn";
                                displayName = "$STR_ALIVE_MP_ON_EACH_SPAWN";
                                tooltip = "$STR_ALIVE_MP_ON_EACH_SPAWN_COMMENT";
                                defaultValue = """""";
                        };
                        class onEachSpawnOnce : Combo
                        {
                                property = "ALiVE_mil_placement_spe_onEachSpawnOnce";
                                displayName = "$STR_ALIVE_MP_ON_EACH_SPAWN_ONCE";
                                tooltip = "$STR_ALIVE_MP_ON_EACH_SPAWN_ONCE_COMMENT";
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
                    description[] = {"$STR_ALIVE_SPEMP_COMMENT","","$STR_ALIVE_SPEMP_USAGE"};
                    // OPCOM / CQB are intentionally NOT valid sync peers. The
                    // module places profile groups / vehicles at a fixed
                    // position (module direction drives orientation); syncing
                    // it to an OPCOM would sweep the units into its pool and
                    // redeploy them, defeating the fixed-position intent.
                    // OPCOM's runtime filter excludes this class explicitly.
                    // sys_factioncompiler IS a valid sync peer - the module
                    // resolves a synced compiler's compiled faction id at
                    // runtime via the case "faction": accessor.
                    sync[] = {"ALiVE_sys_factioncompiler"};
                    class ALiVE_sys_factioncompiler { description[] = {"Custom Faction Compiler module."}; position=0; direction=0; optional=1; duplicate=0; };
                };
        };
};

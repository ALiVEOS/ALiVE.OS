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
                displayName = "$STR_ALIVE_CP";
                function = "ALIVE_fnc_CPInit";
                author = MODULE_AUTHOR;
                functionPriority = 100;
                isGlobal = 1;
                icon = "x\alive\addons\civ_placement\icon_civ_CP.paa";
                picture = "x\alive\addons\civ_placement\icon_civ_CP.paa";
                class Attributes : AttributesBase
                {
                        // ---- General --------------------------------------------------------
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_civ_placement_HDR_GENERAL"; displayName = "GENERAL"; };
                        class debug : Combo { property = "ALiVE_civ_placement_debug"; displayName = "$STR_ALIVE_CP_DEBUG"; tooltip = "$STR_ALIVE_CP_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class taor : Edit { property = "ALiVE_civ_placement_taor"; displayName = "$STR_ALIVE_CP_TAOR"; tooltip = "$STR_ALIVE_CP_TAOR_COMMENT"; defaultValue = """"""; };
                        class blacklist : Edit { property = "ALiVE_civ_placement_blacklist"; displayName = "$STR_ALIVE_CP_BLACKLIST"; tooltip = "$STR_ALIVE_CP_BLACKLIST_COMMENT"; defaultValue = """"""; };
                        // Dynamic faction dropdown - shared control with mil_placement /
                        // civ_placement_custom. See addons/main/CfgVehicles.hpp for the
                        // ALiVE_FactionChoice control definition and the rationale. `property`
                        // unchanged (ALiVE_civ_placement_faction) so SQM storage stays
                        // backward-compatible with missions saved before this change.
                        class faction
                        {
                                property     = "ALiVE_civ_placement_faction";
                                displayName  = "$STR_ALIVE_CP_FACTION";
                                tooltip      = "$STR_ALIVE_CP_FACTION_COMMENT";
                                control      = "ALiVE_FactionChoice_Military";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction', _value];";
                                defaultValue = """BLU_F""";
                        };

                        // ---- Objective Filters ----------------------------------------------
                        class HDR_FILTERS : ALiVE_ModuleSubTitle { property = "ALiVE_civ_placement_HDR_FILTERS"; displayName = "OBJECTIVE FILTERS"; };
                        class clusterType : Combo
                        {
                                property = "ALiVE_civ_placement_clusterType";
                                displayName = "$STR_ALIVE_CP_CLUSTER_TYPE";
                                tooltip = "$STR_ALIVE_CP_CLUSTER_TYPE_COMMENT";
                                defaultValue = """All""";
                                class Values
                                {
                                    class ALL { name = "$STR_ALIVE_CP_CLUSTER_TYPE_ALL"; value = "All"; default = 1; };
                                    class HQ { name = "$STR_ALIVE_CP_CLUSTER_TYPE_HQ"; value = "HQ"; };
                                    class POWER { name = "$STR_ALIVE_CP_CLUSTER_TYPE_POWER"; value = "Power"; };
                                    class COMMS { name = "$STR_ALIVE_CP_CLUSTER_TYPE_COMMS"; value = "Comms"; };
                                    class FUEL { name = "$STR_ALIVE_CP_CLUSTER_TYPE_FUEL"; value = "Fuel"; };
                                    class MARINE { name = "$STR_ALIVE_CP_CLUSTER_TYPE_MARINE"; value = "Marine"; };
                                    class CONSTRUCTION { name = "$STR_ALIVE_CP_CLUSTER_TYPE_CONSTRUCTION"; value = "Construction"; };
                                    class SETTLEMENT { name = "$STR_ALIVE_CP_CLUSTER_TYPE_SETTLEMENT"; value = "Settlement"; };
                                };
                        };
                        class sizeFilter : Combo
                        {
                                property = "ALiVE_civ_placement_sizeFilter";
                                displayName = "$STR_ALIVE_CP_SIZE_FILTER";
                                tooltip = "$STR_ALIVE_CP_SIZE_FILTER_COMMENT";
                                defaultValue = """250""";
                                class Values
                                {
                                    class NONE { name = "$STR_ALIVE_CP_SIZE_FILTER_NONE"; value = "0"; };
                                    class VERYSMALL { name = "$STR_ALIVE_CP_SIZE_FILTER_VERYSMALL"; value = "160"; };
                                    class SMALL { name = "$STR_ALIVE_CP_SIZE_FILTER_SMALL"; value = "250"; default = 1; };
                                    class MEDIUM { name = "$STR_ALIVE_CP_SIZE_FILTER_MEDIUM"; value = "400"; };
                                    class LARGE { name = "$STR_ALIVE_CP_SIZE_FILTER_LARGE"; value = "700"; };
                                    class VERYSMALL_INVERSE { name = "$STR_ALIVE_CP_SIZE_FILTER_VERYSMALL_INVERSE"; value = "-160"; };
                                    class SMALL_INVERSE { name = "$STR_ALIVE_CP_SIZE_FILTER_SMALL_INVERSE"; value = "-250"; };
                                    class MEDIUM_INVERSE { name = "$STR_ALIVE_CP_SIZE_FILTER_MEDIUM_INVERSE"; value = "-400"; };
                                    class LARGE_INVERSE { name = "$STR_ALIVE_CP_SIZE_FILTER_LARGE_INVERSE"; value = "-700"; };
                                };
                        };
                        class priorityFilter : Combo
                        {
                                property = "ALiVE_civ_placement_priorityFilter";
                                displayName = "$STR_ALIVE_CP_PRIORITY_FILTER";
                                tooltip = "$STR_ALIVE_CP_PRIORITY_FILTER_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                    class NONE { name = "$STR_ALIVE_CP_PRIORITY_FILTER_NONE"; value = "0"; default = 1; };
                                    class LOW { name = "$STR_ALIVE_CP_PRIORITY_FILTER_LOW"; value = "10"; };
                                    class MEDIUM { name = "$STR_ALIVE_CP_PRIORITY_FILTER_MEDIUM"; value = "30"; };
                                    class HIGH { name = "$STR_ALIVE_CP_PRIORITY_FILTER_HIGH"; value = "40"; };
                                };
                        };

                        // ---- Force Composition ----------------------------------------------
                        class HDR_FORCE : ALiVE_ModuleSubTitle { property = "ALiVE_civ_placement_HDR_FORCE"; displayName = "FORCE COMPOSITION"; };
                        class withPlacement : Combo { property = "ALiVE_civ_placement_withPlacement"; displayName = "$STR_ALIVE_CP_PLACEMENT"; tooltip = "$STR_ALIVE_CP_PLACEMENT_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="$STR_ALIVE_CP_PLACEMENT_YES";value=true;default=1;}; class No{name="$STR_ALIVE_CP_PLACEMENT_NO";value=false;}; }; };
                        class size : Combo
                        {
                                property = "ALiVE_civ_placement_size";
                                displayName = "$STR_ALIVE_CP_SIZE";
                                tooltip = "$STR_ALIVE_CP_SIZE_COMMENT";
                                defaultValue = """200""";
                                class Values
                                {
                                    class BNx3 { name = "$STR_ALIVE_CP_SIZE_BNx3"; value = 1200; };
                                    class BNx2 { name = "$STR_ALIVE_CP_SIZE_BNx2"; value = 800; };
                                    class BN { name = "$STR_ALIVE_CP_SIZE_BN"; value = 400; };
                                    class CYx2 { name = "$STR_ALIVE_CP_SIZE_CYx2"; value = 200; default = 1; };
                                    class CY { name = "$STR_ALIVE_CP_SIZE_CY"; value = 100; };
                                    class PLx2 { name = "$STR_ALIVE_CP_SIZE_PLx2"; value = 60; };
                                    class PL { name = "$STR_ALIVE_CP_SIZE_PL"; value = 30; };
                                };
                        };
                        class type : Combo
                        {
                                property = "ALiVE_civ_placement_type";
                                displayName = "$STR_ALIVE_CP_TYPE";
                                tooltip = "$STR_ALIVE_CP_TYPE_COMMENT";
                                defaultValue = """Random""";
                                class Values
                                {
                                    class RANDOM { name = "$STR_ALIVE_CP_TYPE_RANDOM"; value = "Random"; default = 1; };
                                    class ARMOR { name = "$STR_ALIVE_CP_TYPE_ARMOR"; value = "Armored"; };
                                    class MECH { name = "$STR_ALIVE_CP_TYPE_MECH"; value = "Mechanized"; };
                                    class MOTOR { name = "$STR_ALIVE_CP_TYPE_MOTOR"; value = "Motorized"; };
                                    class LIGHT { name = "$STR_ALIVE_CP_TYPE_LIGHT"; value = "Infantry"; };
                                    class SPECOPS { name = "$STR_ALIVE_CP_TYPE_SPECOPS"; value = "Specops"; };
                                };
                        };
                        class readinessLevel : Combo
                        {
                                property = "ALiVE_civ_placement_readinessLevel";
                                displayName = "$STR_ALIVE_CP_READINESS_LEVEL";
                                tooltip = "$STR_ALIVE_CP_READINESS_LEVEL_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class NONE { name = "100%"; value = "1"; default = 1; };
                                    class HIGH { name = "75%"; value = "0.75"; };
                                    class MEDIUM { name = "50%"; value = "0.5"; };
                                    class LOW { name = "25%"; value = "0.25"; };
                                };
                        };
                        // Reserve-pool attributes - shared semantics with mil_placement.
                        // Stringtable keys are canonical in mil_placement (STR_ALIVE_MP_*)
                        // and cross-referenced here.
                        class HDR_RESERVE : ALiVE_ModuleSubTitle { property = "ALiVE_civ_placement_HDR_RESERVE"; displayName = "$STR_ALIVE_MP_HDR_RESERVE"; };
                        class activePatrolPercent : Combo
                        {
                                property = "ALiVE_civ_placement_activePatrolPercent"; displayName = "$STR_ALIVE_MP_ACTIVE_PATROL_PERCENT"; tooltip = "$STR_ALIVE_MP_ACTIVE_PATROL_PERCENT_COMMENT"; defaultValue = """0.75""";
                                class Values { class FULL{name="100%";value="1";}; class HIGH{name="75%";value="0.75";default=1;}; class MEDIUM{name="50%";value="0.5";}; class LOW{name="25%";value="0.25";}; class ZERO{name="0%";value="0";}; };
                        };
                        class reserveActivationThreshold : Combo
                        {
                                property = "ALiVE_civ_placement_reserveActivationThreshold"; displayName = "$STR_ALIVE_MP_RESERVE_ACTIVATION_THRESHOLD"; tooltip = "$STR_ALIVE_MP_RESERVE_ACTIVATION_THRESHOLD_COMMENT"; defaultValue = """0.5""";
                                class Values { class HEAVY{name="25%";value="0.25";}; class MEDIUM{name="50%";value="0.5";default=1;}; class EARLY{name="75%";value="0.75";}; class IMMEDIATE{name="100%";value="1";}; };
                        };
                        class reserveActivationCooldown : Edit { property = "ALiVE_civ_placement_reserveActivationCooldown"; displayName = "$STR_ALIVE_MP_RESERVE_ACTIVATION_COOLDOWN"; tooltip = "$STR_ALIVE_MP_RESERVE_ACTIVATION_COOLDOWN_COMMENT"; defaultValue = """30"""; };
                        class reserveEngagementMultiplier : Combo
                        {
                                property = "ALiVE_civ_placement_reserveEngagementMultiplier"; displayName = "$STR_ALIVE_MP_RESERVE_ENGAGEMENT_MULTIPLIER"; tooltip = "$STR_ALIVE_MP_RESERVE_ENGAGEMENT_MULTIPLIER_COMMENT"; defaultValue = """3""";
                                class Values { class CLOSE{name="1.5x cluster";value="1.5";}; class NEAR{name="2x cluster";value="2";}; class STANDARD{name="3x cluster";value="3";default=1;}; class FAR{name="4x cluster";value="4";}; class WIDE{name="6x cluster";value="6";}; };
                        };
                        class reserveLockClearedBuildings : Combo
                        {
                                property = "ALiVE_civ_placement_reserveLockClearedBuildings"; displayName = "$STR_ALIVE_MP_RESERVE_LOCK_CLEARED_BUILDINGS"; tooltip = "$STR_ALIVE_MP_RESERVE_LOCK_CLEARED_BUILDINGS_COMMENT"; defaultValue = """1""";
                                class Values { class YES{name="Yes";value="1";default=1;}; class NO{name="No";value="0";}; };
                        };
                        class reserveEmptyVehicleLocked : Combo
                        {
                                property = "ALiVE_civ_placement_reserveEmptyVehicleLocked"; displayName = "$STR_ALIVE_MP_RESERVE_EMPTY_VEHICLE_LOCKED"; tooltip = "$STR_ALIVE_MP_RESERVE_EMPTY_VEHICLE_LOCKED_COMMENT"; defaultValue = """1""";
                                class Values { class YES{name="Yes";value="1";default=1;}; class NO{name="No";value="0";}; };
                        };
                        class reserveOrphanCrewBehaviour : Combo
                        {
                                property = "ALiVE_civ_placement_reserveOrphanCrewBehaviour"; displayName = "$STR_ALIVE_MP_RESERVE_ORPHAN_CREW_BEHAVIOUR"; tooltip = "$STR_ALIVE_MP_RESERVE_ORPHAN_CREW_BEHAVIOUR_COMMENT"; defaultValue = """SpawnAsInfantry""";
                                class Values { class INFANTRY{name="Spawn as infantry";value="SpawnAsInfantry";default=1;}; class DROP{name="Drop silently";value="Drop";}; };
                        };
                        class customInfantryCount : Edit { property = "ALiVE_civ_placement_customInfantryCount"; displayName = "$STR_ALIVE_CP_CUSTOM_INFANTRY_COUNT"; tooltip = "$STR_ALIVE_CP_CUSTOM_INFANTRY_COUNT_COMMENT"; defaultValue = """"""; };
                        class customMotorisedCount : Edit { property = "ALiVE_civ_placement_customMotorisedCount"; displayName = "$STR_ALIVE_CP_CUSTOM_MOTORISED_COUNT"; tooltip = "$STR_ALIVE_CP_CUSTOM_MOTORISED_COUNT_COMMENT"; defaultValue = """"""; };
                        class customMechanisedCount : Edit { property = "ALiVE_civ_placement_customMechanisedCount"; displayName = "$STR_ALIVE_CP_CUSTOM_MECHANISED_COUNT"; tooltip = "$STR_ALIVE_CP_CUSTOM_MECHANISED_COUNT_COMMENT"; defaultValue = """"""; };
                        class customArmourCount : Edit { property = "ALiVE_civ_placement_customArmourCount"; displayName = "$STR_ALIVE_CP_CUSTOM_ARMOUR_COUNT"; tooltip = "$STR_ALIVE_CP_CUSTOM_ARMOUR_COUNT_COMMENT"; defaultValue = """"""; };
                        class customSpecOpsCount : Edit { property = "ALiVE_civ_placement_customSpecOpsCount"; displayName = "$STR_ALIVE_CP_CUSTOM_SPECOPS_COUNT"; tooltip = "$STR_ALIVE_CP_CUSTOM_SPECOPS_COUNT_COMMENT"; defaultValue = """"""; };
                        // Cross-module attribute: read at runtime by the synced mil_opcom
                        // (asymmetric mode) to override how many installations of each
                        // type get seeded on this module's objectives. Lives here for
                        // mission-maker convenience but isn't consumed by civ_placement
                        // itself.
                        class asymmetricInstallationCountOverrides : Edit { property = "ALiVE_civ_placement_asymmetricInstallationCountOverrides"; displayName = "$STR_ALIVE_CP_ASYM_INSTALLATION_COUNT_OVERRIDES"; tooltip = "$STR_ALIVE_CP_ASYM_INSTALLATION_COUNT_OVERRIDES_COMMENT"; defaultValue = """"""; };

                        // ---- Ambient Presence -----------------------------------------------
                        class HDR_AMBIENT : ALiVE_ModuleSubTitle { property = "ALiVE_civ_placement_HDR_AMBIENT"; displayName = "AMBIENT PRESENCE"; };
                        class roadblocks : Combo
                        {
                                property = "ALiVE_civ_placement_roadblocks";
                                displayName = "$STR_ALIVE_CP_ROADBLOCKS";
                                tooltip = "$STR_ALIVE_CP_ROADBLOCKS_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                    class NONE { name = "None"; value = "0"; default = 1; };
                                    class All { name = "All"; value = "100"; };
                                    class EXTREME { name = "Extreme"; value = "75"; };
                                    class HIGH { name = "High"; value = "50"; };
                                    class MEDIUM { name = "Medium"; value = "35"; };
                                    class LOW { name = "Low"; value = "15"; };
                                };
                        };
                        class placeSeaPatrols : Combo
                        {
                                property = "ALiVE_civ_placement_placeSeaPatrols";
                                displayName = "$STR_ALIVE_CP_PLACE_SEAPATROLS";
                                tooltip = "$STR_ALIVE_CP_PLACE_SEAPATROLS_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                    class NONE { name = "None"; value = 0; default = 1; };
                                    class All { name = "All"; value = 1; };
                                    class EXTREME { name = "Extreme"; value = 0.75; };
                                    class HIGH { name = "High"; value = 0.55; };
                                    class MEDIUM { name = "Medium"; value = 0.33; };
                                    class LOW { name = "Low"; value = 0.2; };
                                };
                        };
                        class guardProbability : Combo
                        {
                                property = "ALiVE_civ_placement_guardProbability";
                                displayName = "$STR_ALIVE_CP_CUSTOM_GUARD_AMOUNT";
                                tooltip = "$STR_ALIVE_CP_CUSTOM_GUARD_AMOUNT_COMMENT";
                                defaultValue = """0.2""";
                                class Values
                                {
                                    class NONE { name = "$STR_ALIVE_CP_CUSTOM_GUARD_AMOUNT_NONE"; value = "0"; };
                                    class LOW { name = "$STR_ALIVE_CP_CUSTOM_GUARD_AMOUNT_LOW"; value = "0.2"; default = 1; };
                                    class MEDIUM { name = "$STR_ALIVE_CP_CUSTOM_GUARD_AMOUNT_MEDIUM"; value = "0.6"; };
                                    class HIGH { name = "$STR_ALIVE_CP_CUSTOM_GUARD_AMOUNT_HIGH"; value = "1"; };
                                };
                        };
                        class guardRadius : Edit { property = "ALiVE_civ_placement_guardRadius"; displayName = "$STR_ALIVE_CP_CUSTOM_GUARD_RADIUS"; tooltip = "$STR_ALIVE_CP_CUSTOM_GUARD_RADIUS_COMMENT"; defaultValue = """200"""; };
                        class guardPatrolPercentage : Combo
                        {
                                property = "ALiVE_civ_placement_guardPatrolPercentage";
                                displayName = "$STR_ALIVE_CP_CUSTOM_GUARD_PATROL_PERCENT";
                                tooltip = "$STR_ALIVE_CP_CUSTOM_GUARD_PATROL_PERCENT_COMMENT";
                                defaultValue = """50""";
                                class Values
                                {
                                    class NONE { name = "$STR_ALIVE_CP_CUSTOM_PATROL_PERCENT_NONE"; value = "0"; };
                                    class LOW { name = "$STR_ALIVE_CP_CUSTOM_PATROL_PERCENT_LOW"; value = "25"; };
                                    class MEDIUM { name = "$STR_ALIVE_CP_CUSTOM_PATROL_PERCENT_MEDIUM"; value = "50"; default = 1; };
                                    class HIGH { name = "$STR_ALIVE_CP_CUSTOM_PATROL_PERCENT_HIGH"; value = "75"; };
                                    class ALL { name = "$STR_ALIVE_CP_CUSTOM_PATROL_PERCENT_ALL"; value = "100"; };
                                };
                        };

                        // ---- On Spawn Hook --------------------------------------------------
                        class HDR_HOOK : ALiVE_ModuleSubTitle { property = "ALiVE_civ_placement_HDR_HOOK"; displayName = "ON SPAWN HOOK"; };
                        class onEachSpawn : ALiVE_EditMultilineSQF
                        {
                                property = "ALiVE_civ_placement_onEachSpawn";
                                displayName = "$STR_ALIVE_CP_ON_EACH_SPAWN";
                                tooltip = "$STR_ALIVE_CP_ON_EACH_SPAWN_COMMENT";
                                defaultValue = """""";
                        };
                        class onEachSpawnOnce : Combo
                        {
                                property = "ALiVE_civ_placement_onEachSpawnOnce";
                                displayName = "$STR_ALIVE_CP_ON_EACH_SPAWN_ONCE";
                                tooltip = "$STR_ALIVE_CP_ON_EACH_SPAWN_ONCE_COMMENT";
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
                    description[] = {"$STR_ALIVE_CP_COMMENT","","$STR_ALIVE_CP_USAGE"};
                    sync[] = {"ALiVE_mil_OPCOM","ALiVE_mil_CQB","ALiVE_sys_factioncompiler"};
                    class ALiVE_mil_OPCOM { description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_CQB { description[] = {"$STR_ALIVE_CQB_COMMENT","","$STR_ALIVE_CQB_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_sys_factioncompiler { description[] = {"Custom Faction Compiler module."}; position=0; direction=0; optional=1; duplicate=0; };
                };
        };
};

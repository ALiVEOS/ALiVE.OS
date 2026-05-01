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
                displayName = "$STR_ALIVE_CMP";
                function = "ALIVE_fnc_CMPInit";
                author = MODULE_AUTHOR;
                functionPriority = 100;
                isGlobal = 1;
                icon = "x\alive\addons\mil_placement_custom\icon_mil_CMP.paa";
                picture = "x\alive\addons\mil_placement_custom\icon_mil_CMP.paa";
                class Attributes : AttributesBase
                {
                        // ---- General --------------------------------------------------------
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_custom_HDR_GENERAL"; displayName = "GENERAL"; };
                        class debug : Combo { property = "ALiVE_mil_placement_custom_debug"; displayName = "$STR_ALIVE_CMP_DEBUG"; tooltip = "$STR_ALIVE_CMP_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        // Shared ALiVE_FactionChoice dropdown - see addons/main/CfgVehicles.hpp.
                        class faction
                        {
                                property     = "ALiVE_mil_placement_custom_faction";
                                displayName  = "$STR_ALIVE_CMP_FACTION";
                                tooltip      = "$STR_ALIVE_CMP_FACTION_COMMENT";
                                control      = "ALiVE_FactionChoice_Military";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction', _value];";
                                defaultValue = """BLU_F""";
                        };
                        class priority : Edit { property = "ALiVE_mil_placement_custom_priority"; displayName = "$STR_ALIVE_CMP_PRIORITY"; tooltip = "$STR_ALIVE_CMP_PRIORITY_COMMENT"; defaultValue = """50"""; };
                        class size : Edit { property = "ALiVE_mil_placement_custom_size"; displayName = "$STR_ALIVE_CMP_SIZE"; tooltip = "$STR_ALIVE_CMP_SIZE_COMMENT"; defaultValue = """50"""; };
                        class readinessLevel : Combo
                        {
                                property = "ALiVE_mil_placement_custom_readinessLevel"; displayName = "$STR_ALIVE_CMP_READINESS_LEVEL"; tooltip = "$STR_ALIVE_CMP_READINESS_LEVEL_COMMENT"; defaultValue = """1""";
                                class Values { class NONE{name="100%";value="1";default=1;}; class HIGH{name="75%";value="0.75";}; class MEDIUM{name="50%";value="0.5";}; class LOW{name="25%";value="0.25";}; };
                        };
                        // Reserve-pool attributes - shared semantics with mil_placement.
                        // Stringtable keys are canonical in mil_placement (STR_ALIVE_MP_*)
                        // and cross-referenced here; keeps a single source of truth across
                        // the four placement modules that have a Readiness attribute.
                        class HDR_RESERVE : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_custom_HDR_RESERVE"; displayName = "$STR_ALIVE_MP_HDR_RESERVE"; };
                        class activePatrolPercent : Combo
                        {
                                property = "ALiVE_mil_placement_custom_activePatrolPercent"; displayName = "$STR_ALIVE_MP_ACTIVE_PATROL_PERCENT"; tooltip = "$STR_ALIVE_MP_ACTIVE_PATROL_PERCENT_COMMENT"; defaultValue = """0.75""";
                                class Values { class FULL{name="100%";value="1";}; class HIGH{name="75%";value="0.75";default=1;}; class MEDIUM{name="50%";value="0.5";}; class LOW{name="25%";value="0.25";}; class ZERO{name="0%";value="0";}; };
                        };
                        class reserveActivationThreshold : Combo
                        {
                                property = "ALiVE_mil_placement_custom_reserveActivationThreshold"; displayName = "$STR_ALIVE_MP_RESERVE_ACTIVATION_THRESHOLD"; tooltip = "$STR_ALIVE_MP_RESERVE_ACTIVATION_THRESHOLD_COMMENT"; defaultValue = """0.5""";
                                class Values { class HEAVY{name="25%";value="0.25";}; class MEDIUM{name="50%";value="0.5";default=1;}; class EARLY{name="75%";value="0.75";}; class IMMEDIATE{name="100%";value="1";}; };
                        };
                        class reserveActivationCooldown : Edit { property = "ALiVE_mil_placement_custom_reserveActivationCooldown"; displayName = "$STR_ALIVE_MP_RESERVE_ACTIVATION_COOLDOWN"; tooltip = "$STR_ALIVE_MP_RESERVE_ACTIVATION_COOLDOWN_COMMENT"; defaultValue = """30"""; };
                        class reserveEngagementMultiplier : Combo
                        {
                                property = "ALiVE_mil_placement_custom_reserveEngagementMultiplier"; displayName = "$STR_ALIVE_MP_RESERVE_ENGAGEMENT_MULTIPLIER"; tooltip = "$STR_ALIVE_MP_RESERVE_ENGAGEMENT_MULTIPLIER_COMMENT"; defaultValue = """3""";
                                class Values { class CLOSE{name="1.5x cluster";value="1.5";}; class NEAR{name="2x cluster";value="2";}; class STANDARD{name="3x cluster";value="3";default=1;}; class FAR{name="4x cluster";value="4";}; class WIDE{name="6x cluster";value="6";}; };
                        };
                        class reserveLockClearedBuildings : Combo
                        {
                                property = "ALiVE_mil_placement_custom_reserveLockClearedBuildings"; displayName = "$STR_ALIVE_MP_RESERVE_LOCK_CLEARED_BUILDINGS"; tooltip = "$STR_ALIVE_MP_RESERVE_LOCK_CLEARED_BUILDINGS_COMMENT"; defaultValue = """1""";
                                class Values { class YES{name="Yes";value="1";default=1;}; class NO{name="No";value="0";}; };
                        };
                        class reserveEmptyVehicleLocked : Combo
                        {
                                property = "ALiVE_mil_placement_custom_reserveEmptyVehicleLocked"; displayName = "$STR_ALIVE_MP_RESERVE_EMPTY_VEHICLE_LOCKED"; tooltip = "$STR_ALIVE_MP_RESERVE_EMPTY_VEHICLE_LOCKED_COMMENT"; defaultValue = """1""";
                                class Values { class YES{name="Yes";value="1";default=1;}; class NO{name="No";value="0";}; };
                        };
                        class reserveOrphanCrewBehaviour : Combo
                        {
                                property = "ALiVE_mil_placement_custom_reserveOrphanCrewBehaviour"; displayName = "$STR_ALIVE_MP_RESERVE_ORPHAN_CREW_BEHAVIOUR"; tooltip = "$STR_ALIVE_MP_RESERVE_ORPHAN_CREW_BEHAVIOUR_COMMENT"; defaultValue = """SpawnAsInfantry""";
                                class Values { class INFANTRY{name="Spawn as infantry";value="SpawnAsInfantry";default=1;}; class DROP{name="Drop silently";value="Drop";}; };
                        };
                        // ---- Force Composition ----------------------------------------------
                        class HDR_FORCE : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_custom_HDR_FORCE"; displayName = "FORCE COMPOSITION"; };
                        class customInfantryCount : Edit { property = "ALiVE_mil_placement_custom_customInfantryCount"; displayName = "$STR_ALIVE_CMP_CUSTOM_INFANTRY_COUNT"; tooltip = "$STR_ALIVE_CMP_CUSTOM_INFANTRY_COUNT_COMMENT"; defaultValue = """0"""; };
                        class customMotorisedCount : Edit { property = "ALiVE_mil_placement_custom_customMotorisedCount"; displayName = "$STR_ALIVE_CMP_CUSTOM_MOTORISED_COUNT"; tooltip = "$STR_ALIVE_CMP_CUSTOM_MOTORISED_COUNT_COMMENT"; defaultValue = """0"""; };
                        class customMechanisedCount : Edit { property = "ALiVE_mil_placement_custom_customMechanisedCount"; displayName = "$STR_ALIVE_CMP_CUSTOM_MECHANISED_COUNT"; tooltip = "$STR_ALIVE_CMP_CUSTOM_MECHANISED_COUNT_COMMENT"; defaultValue = """0"""; };
                        class customArmourCount : Edit { property = "ALiVE_mil_placement_custom_customArmourCount"; displayName = "$STR_ALIVE_CMP_CUSTOM_ARMOUR_COUNT"; tooltip = "$STR_ALIVE_CMP_CUSTOM_ARMOUR_COUNT_COMMENT"; defaultValue = """0"""; };
                        class customSpecOpsCount : Edit { property = "ALiVE_mil_placement_custom_customSpecOpsCount"; displayName = "$STR_ALIVE_CMP_CUSTOM_SPECOPS_COUNT"; tooltip = "$STR_ALIVE_CMP_CUSTOM_SPECOPS_COUNT_COMMENT"; defaultValue = """0"""; };
                        // ---- Ambient Presence -----------------------------------------------
                        class HDR_AMBIENT : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_custom_HDR_AMBIENT"; displayName = "AMBIENT PRESENCE"; };
                        class guardProbability : Combo
                        {
                                property = "ALiVE_mil_placement_custom_guardProbability"; displayName = "$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT"; tooltip = "$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_COMMENT"; defaultValue = """0.2""";
                                class Values { class NONE{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_NONE";value="0";}; class LOW{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_LOW";value="0.2";default=1;}; class MEDIUM{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_MEDIUM";value="0.6";}; class HIGH{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_HIGH";value="1";}; };
                        };
                        class guardRadius : Edit { property = "ALiVE_mil_placement_custom_guardRadius"; displayName = "$STR_ALIVE_MP_AMBIENT_GUARD_RADIUS"; tooltip = "$STR_ALIVE_MP_AMBIENT_GUARD_RADIUS_COMMENT"; defaultValue = """200"""; };
                        class guardPatrolPercentage : Combo
                        {
                                property = "ALiVE_mil_placement_custom_guardPatrolPercentage"; displayName = "$STR_ALIVE_MP_AMBIENT_GUARD_PATROL_PERCENT"; tooltip = "$STR_ALIVE_MP_AMBIENT_GUARD_PATROL_PERCENT_COMMENT"; defaultValue = """50""";
                                class Values { class NONE{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_NONE";value="0";}; class LOW{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_LOW";value="25";}; class MEDIUM{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_MEDIUM";value="50";default=1;}; class HIGH{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_HIGH";value="75";}; class ALL{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_ALL";value="100";}; };
                        };
                        class composition : Edit { property = "ALiVE_mil_placement_custom_composition"; displayName = "$STR_ALIVE_CMP_COMPOSITION"; tooltip = "$STR_ALIVE_CMP_COMPOSITION_COMMENT"; defaultValue = """"""; };
                        class createHQ : Combo { property = "ALiVE_mil_placement_custom_createHQ"; displayName = "$STR_ALIVE_CMP_CREATE_HQ"; tooltip = "$STR_ALIVE_CMP_CREATE_HQ_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class placeHelis : Combo { property = "ALiVE_mil_placement_custom_placeHelis"; displayName = "$STR_ALIVE_MP_PLACE_HELI"; tooltip = "$STR_ALIVE_MP_PLACE_HELI_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class placeSupplies : Combo { property = "ALiVE_mil_placement_custom_placeSupplies"; displayName = "$STR_ALIVE_MP_PLACE_SUPPLIES"; tooltip = "$STR_ALIVE_MP_PLACE_SUPPLIES_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class ambientVehicleAmount : Combo
                        {
                                property = "ALiVE_mil_placement_custom_ambientVehicleAmount"; displayName = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT"; tooltip = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_COMMENT"; defaultValue = """0""";
                                class Values { class NONE{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_NONE";value="0";default=1;}; class LOW{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_LOW";value="0.2";}; class MEDIUM{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_MEDIUM";value="0.6";}; class HIGH{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_HIGH";value="1";}; };
                        };
                        class allowPlayerTasking : Combo { property = "ALiVE_mil_placement_custom_allowPlayerTasking"; displayName = "$STR_ALIVE_CMP_ALLOW_PLAYER_TASK"; tooltip = "$STR_ALIVE_CMP_ALLOW_PLAYER_TASK_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        // ---- On Spawn Hook --------------------------------------------------
                        class HDR_HOOK : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_custom_HDR_HOOK"; displayName = "ON SPAWN HOOK"; };
                        class onEachSpawn : ALiVE_EditMultilineSQF
                        {
                                property = "ALiVE_mil_placement_custom_onEachSpawn";
                                displayName = "$STR_ALIVE_MP_ON_EACH_SPAWN";
                                tooltip = "$STR_ALIVE_MP_ON_EACH_SPAWN_COMMENT";
                                defaultValue = """""";
                        };
                        class onEachSpawnOnce : Combo
                        {
                                property = "ALiVE_mil_placement_custom_onEachSpawnOnce";
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
                    description[] = {"$STR_ALIVE_CMP_COMMENT","","$STR_ALIVE_CMP_USAGE"};
                    sync[] = {"ALiVE_mil_OPCOM","ALiVE_mil_CQB","ALiVE_sys_factioncompiler"};
                    class ALiVE_mil_OPCOM { description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_CQB { description[] = {"$STR_ALIVE_CQB_COMMENT","","$STR_ALIVE_CQB_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_sys_factioncompiler { description[] = {"Compiled custom faction override module."}; position=0; direction=0; optional=1; duplicate=0; };
                };
        };
};

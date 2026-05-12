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
                displayName = "$STR_ALIVE_MP";
                function = "ALIVE_fnc_MPInit";
                author = MODULE_AUTHOR;
                functionPriority = 90;
                isGlobal = 1;
                icon = "x\alive\addons\mil_placement\icon_mil_MP.paa";
                picture = "x\alive\addons\mil_placement\icon_mil_MP.paa";
                class Attributes : AttributesBase
                {
                        // ---- General --------------------------------------------------------
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_HDR_GENERAL"; displayName = "GENERAL"; };
                        class debug : Combo { property = "ALiVE_mil_placement_debug"; displayName = "$STR_ALIVE_MP_DEBUG"; tooltip = "$STR_ALIVE_MP_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class taor : Edit { property = "ALiVE_mil_placement_taor"; displayName = "$STR_ALIVE_MP_TAOR"; tooltip = "$STR_ALIVE_MP_TAOR_COMMENT"; defaultValue = """"""; };
                        class blacklist : Edit { property = "ALiVE_mil_placement_blacklist"; displayName = "$STR_ALIVE_MP_BLACKLIST"; tooltip = "$STR_ALIVE_MP_BLACKLIST_COMMENT"; defaultValue = """"""; };
                        // Dynamic faction dropdown - populated at Eden-panel-open time from
                        // loaded CfgFactionClasses entries (see ALiVE_FactionChoice in
                        // addons/main/CfgVehicles.hpp). Stored value is the faction classname
                        // STRING. Legacy SQMs with hand-typed faction strings preserve their
                        // value via an "(unrecognised)" dropdown entry if the stored string
                        // doesn't match any currently-loaded faction (typo, mod unloaded,
                        // custom faction). Case-insensitive matching on restore closes #651.
                        //
                        // `property` unchanged (ALiVE_mil_placement_faction) so SQM storage
                        // stays backward-compatible with missions saved before this change.
                        class faction
                        {
                                property     = "ALiVE_mil_placement_faction";
                                displayName  = "$STR_ALIVE_MP_FACTION";
                                tooltip      = "$STR_ALIVE_MP_FACTION_COMMENT";
                                control      = "ALiVE_FactionChoice_Military";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction', _value];";
                                defaultValue = """BLU_F""";
                        };
                        class sizeFilter : Combo
                        {
                                property = "ALiVE_mil_placement_sizeFilter"; displayName = "$STR_ALIVE_MP_SIZE_FILTER"; tooltip = "$STR_ALIVE_MP_SIZE_FILTER_COMMENT"; defaultValue = """0""";
                                class Values { class NONE{name="$STR_ALIVE_MP_SIZE_FILTER_NONE";value="0";default=1;}; class SMALL{name="$STR_ALIVE_MP_SIZE_FILTER_SMALL";value="100";}; class MEDIUM{name="$STR_ALIVE_MP_SIZE_FILTER_MEDIUM";value="200";}; class LARGE{name="$STR_ALIVE_MP_SIZE_FILTER_LARGE";value="300";}; class SMALL_INVERSE{name="$STR_ALIVE_MP_SIZE_FILTER_SMALL_INVERSE";value="-100";}; class MEDIUM_INVERSE{name="$STR_ALIVE_MP_SIZE_FILTER_MEDIUM_INVERSE";value="-200";}; class LARGE_INVERSE{name="$STR_ALIVE_MP_SIZE_FILTER_LARGE_INVERSE";value="-300";}; };
                        };
                        class priorityFilter : Combo
                        {
                                property = "ALiVE_mil_placement_priorityFilter"; displayName = "$STR_ALIVE_MP_PRIORITY_FILTER"; tooltip = "$STR_ALIVE_MP_PRIORITY_FILTER_COMMENT"; defaultValue = """0""";
                                class Values { class NONE{name="$STR_ALIVE_MP_PRIORITY_FILTER_NONE";value="0";default=1;}; class LOW{name="$STR_ALIVE_MP_PRIORITY_FILTER_LOW";value="10";}; class MEDIUM{name="$STR_ALIVE_MP_PRIORITY_FILTER_MEDIUM";value="30";}; class HIGH{name="$STR_ALIVE_MP_PRIORITY_FILTER_HIGH";value="40";}; };
                        };

                        // ---- Force Composition ----------------------------------------------
                        class HDR_FORCE : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_HDR_FORCE"; displayName = "FORCE COMPOSITION"; };
                        class withPlacement : Combo { property = "ALiVE_mil_placement_withPlacement"; displayName = "$STR_ALIVE_MP_PLACEMENT"; tooltip = "$STR_ALIVE_MP_PLACEMENT_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="$STR_ALIVE_MP_PLACEMENT_YES";value="true";default=1;}; class No{name="$STR_ALIVE_MP_PLACEMENT_NO";value="false";}; }; };
                        class size : Combo
                        {
                                property = "ALiVE_mil_placement_size"; displayName = "$STR_ALIVE_MP_SIZE"; tooltip = "$STR_ALIVE_MP_SIZE_COMMENT"; defaultValue = """200""";
                                class Values { class BNx3{name="$STR_ALIVE_MP_SIZE_BNx3";value=1200;}; class BNx2{name="$STR_ALIVE_MP_SIZE_BNx2";value=800;}; class BN{name="$STR_ALIVE_MP_SIZE_BN";value=400;}; class CYx2{name="$STR_ALIVE_MP_SIZE_CYx2";value=200;default=1;}; class CY{name="$STR_ALIVE_MP_SIZE_CY";value=100;}; class PLx2{name="$STR_ALIVE_MP_SIZE_PLx2";value=60;}; class PL{name="$STR_ALIVE_MP_SIZE_PL";value=30;}; };
                        };
                        class type : Combo
                        {
                                property = "ALiVE_mil_placement_type"; displayName = "$STR_ALIVE_MP_TYPE"; tooltip = "$STR_ALIVE_MP_TYPE_COMMENT"; defaultValue = """Random""";
                                class Values { class RANDOM{name="$STR_ALIVE_MP_TYPE_RANDOM";value="Random";default=1;}; class ARMOR{name="$STR_ALIVE_MP_TYPE_ARMOR";value="Armored";}; class MECH{name="$STR_ALIVE_MP_TYPE_MECH";value="Mechanized";}; class MOTOR{name="$STR_ALIVE_MP_TYPE_MOTOR";value="Motorized";}; class LIGHT{name="$STR_ALIVE_MP_TYPE_LIGHT";value="Infantry";}; class SPECOPS{name="$STR_ALIVE_MP_TYPE_SPECOPS";value="Specops";}; };
                        };
                        class readinessLevel : Combo
                        {
                                property = "ALiVE_mil_placement_readinessLevel"; displayName = "$STR_ALIVE_MP_READINESS_LEVEL"; tooltip = "$STR_ALIVE_MP_READINESS_LEVEL_COMMENT"; defaultValue = """1""";
                                class Values { class NONE{name="100%";value="1";default=1;}; class HIGH{name="75%";value="0.75";}; class MEDIUM{name="50%";value="0.5";}; class LOW{name="25%";value="0.25";}; };
                        };
                        class customInfantryCount : Edit { property = "ALiVE_mil_placement_customInfantryCount"; displayName = "$STR_ALIVE_MP_CUSTOM_INFANTRY_COUNT"; tooltip = "$STR_ALIVE_MP_CUSTOM_INFANTRY_COUNT_COMMENT"; defaultValue = """"""; };
                        class customMotorisedCount : Edit { property = "ALiVE_mil_placement_customMotorisedCount"; displayName = "$STR_ALIVE_MP_CUSTOM_MOTORISED_COUNT"; tooltip = "$STR_ALIVE_MP_CUSTOM_MOTORISED_COUNT_COMMENT"; defaultValue = """"""; };
                        class customMechanisedCount : Edit { property = "ALiVE_mil_placement_customMechanisedCount"; displayName = "$STR_ALIVE_MP_CUSTOM_MECHANISED_COUNT"; tooltip = "$STR_ALIVE_MP_CUSTOM_MECHANISED_COUNT_COMMENT"; defaultValue = """"""; };
                        class customArmourCount : Edit { property = "ALiVE_mil_placement_customArmourCount"; displayName = "$STR_ALIVE_MP_CUSTOM_ARMOUR_COUNT"; tooltip = "$STR_ALIVE_MP_CUSTOM_ARMOUR_COUNT_COMMENT"; defaultValue = """"""; };
                        class customSpecOpsCount : Edit { property = "ALiVE_mil_placement_customSpecOpsCount"; displayName = "$STR_ALIVE_MP_CUSTOM_SPECOPS_COUNT"; tooltip = "$STR_ALIVE_MP_CUSTOM_SPECOPS_COUNT_COMMENT"; defaultValue = """"""; };

                        // ---- Ambient Presence -----------------------------------------------
                        class HDR_AMBIENT : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_HDR_AMBIENT"; displayName = "AMBIENT PRESENCE"; };
                        class randomcamps : Combo
                        {
                                property = "ALiVE_mil_placement_randomcamps"; displayName = "$STR_ALIVE_MP_RANDOMCAMPS"; tooltip = "$STR_ALIVE_MP_RANDOMCAMPS_COMMENT"; defaultValue = """0""";
                                class Values { class NONE{name="None";value="0";default=1;}; class LOW{name="Low";value="2500";}; class MEDIUM{name="Medium";value="1500";}; class HIGH{name="High";value="1000";}; };
                        };
                        class guardProbability : Combo
                        {
                                property = "ALiVE_mil_placement_guardProbability"; displayName = "$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT"; tooltip = "$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_COMMENT"; defaultValue = """0.2""";
                                class Values { class NONE{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_NONE";value="0";}; class LOW{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_LOW";value="0.2";default=1;}; class MEDIUM{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_MEDIUM";value="0.6";}; class HIGH{name="$STR_ALIVE_MP_AMBIENT_GUARD_AMOUNT_HIGH";value="1";}; };
                        };
                        class guardRadius : Edit { property = "ALiVE_mil_placement_guardRadius"; displayName = "$STR_ALIVE_MP_AMBIENT_GUARD_RADIUS"; tooltip = "$STR_ALIVE_MP_AMBIENT_GUARD_RADIUS_COMMENT"; defaultValue = """200"""; };
                        class guardPatrolPercentage : Combo
                        {
                                property = "ALiVE_mil_placement_guardPatrolPercentage"; displayName = "$STR_ALIVE_MP_AMBIENT_GUARD_PATROL_PERCENT"; tooltip = "$STR_ALIVE_MP_AMBIENT_GUARD_PATROL_PERCENT_COMMENT"; defaultValue = """50""";
                                class Values { class NONE{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_NONE";value="0";}; class LOW{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_LOW";value="25";}; class MEDIUM{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_MEDIUM";value="50";default=1;}; class HIGH{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_HIGH";value="75";}; class ALL{name="$STR_ALIVE_MP_AMBIENT_PATROL_PERCENT_ALL";value="100";}; };
                        };
                        class createHQ : Combo { property = "ALiVE_mil_placement_createHQ"; displayName = "$STR_ALIVE_MP_CREATE_HQ"; tooltip = "$STR_ALIVE_MP_CREATE_HQ_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class createFieldHQ : Combo { property = "ALiVE_mil_placement_createFieldHQ"; displayName = "$STR_ALIVE_MP_CREATE_FIELDHQ"; tooltip = "$STR_ALIVE_MP_CREATE_FIELDHQ_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class placeHelis : Combo { property = "ALiVE_mil_placement_placeHelis"; displayName = "$STR_ALIVE_MP_PLACE_HELI"; tooltip = "$STR_ALIVE_MP_PLACE_HELI_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class placeSupplies : Combo { property = "ALiVE_mil_placement_placeSupplies"; displayName = "$STR_ALIVE_MP_PLACE_SUPPLIES"; tooltip = "$STR_ALIVE_MP_PLACE_SUPPLIES_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class ambientVehicleAmount : Combo
                        {
                                property = "ALiVE_mil_placement_ambientVehicleAmount"; displayName = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT"; tooltip = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_COMMENT"; defaultValue = """0""";
                                class Values { class NONE{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_NONE";value="0";default=1;}; class LOW{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_LOW";value="0.2";}; class MEDIUM{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_MEDIUM";value="0.6";}; class HIGH{name="$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_HIGH";value="1";}; };
                        };

                        // ---- On Spawn Hook --------------------------------------------------
                        class HDR_HOOK : ALiVE_ModuleSubTitle { property = "ALiVE_mil_placement_HDR_HOOK"; displayName = "ON SPAWN HOOK"; };
                        class onEachSpawn : ALiVE_EditMultilineSQF
                        {
                                property = "ALiVE_mil_placement_onEachSpawn";
                                displayName = "$STR_ALIVE_MP_ON_EACH_SPAWN";
                                tooltip = "$STR_ALIVE_MP_ON_EACH_SPAWN_COMMENT";
                                defaultValue = """""";
                        };
                        class onEachSpawnOnce : Combo
                        {
                                property = "ALiVE_mil_placement_onEachSpawnOnce";
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
                    description[] = {"$STR_ALIVE_MP_COMMENT","","$STR_ALIVE_MP_USAGE"};
                    sync[] = {"ALiVE_mil_OPCOM","ALiVE_mil_CQB","ALiVE_sys_factioncompiler"};
                    class ALiVE_mil_OPCOM { description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_CQB { description[] = {"$STR_ALIVE_CQB_COMMENT","","$STR_ALIVE_CQB_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_sys_factioncompiler { description[] = {"Compiled custom faction override module."}; position=0; direction=0; optional=1; duplicate=0; };
                };
        };
};

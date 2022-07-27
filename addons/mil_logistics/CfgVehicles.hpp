class CfgVehicles
{
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_ML";
                function = "ALIVE_fnc_MLInit";
                author = MODULE_AUTHOR;
                functionPriority = 190;
                isGlobal = 1;
                icon = "x\alive\addons\mil_logistics\icon_mil_ML.paa";
                picture = "x\alive\addons\mil_logistics\icon_mil_ML.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_ML_DEBUG";
                                description = "$STR_ALIVE_ML_DEBUG_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                                default = 1;
                                        };
                                };
                        };
                        class persistent
                        {
                                displayName = "$STR_ALIVE_ML_PERSISTENT";
                                description = "$STR_ALIVE_ML_PERSISTENT_COMMENT";
                                class Values
                                {
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                                default = 1;
                                        };
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                        };
                                };
                        };
                        class type
                        {
                                displayName = "$STR_ALIVE_ML_TYPE";
                                description = "$STR_ALIVE_ML_TYPE_COMMENT";
                                class Values
                                {
                                        class Dynamic
                                        {
                                                name = "$STR_ALIVE_ML_TYPE_DYNAMIC";
                                                value = "DYNAMIC";
                                                default = 1;
                                        };
                                        class FP1000
                                        {
                                                name = "$STR_ALIVE_ML_TYPE_STATIC";
                                                value = "STATIC";
                                        };
                                };
                        };
                        class forcePool
                        {
                                displayName = "$STR_ALIVE_ML_FORCE_POOL";
                                description = "$STR_ALIVE_ML_FORCE_POOL_COMMENT";
                                class Values
                                {
                                        class Dynamic
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_DYNAMIC";
                                                value = "10";
                                        };
                                        class FPInfinite
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_INFINITE";
                                                value = "100000";
                                        };
                                        class FP20000
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_20000";
                                                value = "20000";
                                        };
                                        class FP10000
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_10000";
                                                value = "10000";
                                        };
                                        class FP5000
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_5000";
                                                value = "5000";
                                        };
                                        class FP2500
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_2500";
                                                value = "2500";
                                        };
                                        class FP1000
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_1000";
                                                value = "1000";
                                                default = 1;
                                        };
                                        class FP500
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_500";
                                                value = "500";
                                        };
                                        class FP200
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_200";
                                                value = "200";
                                        };
                                        class FP100
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_100";
                                                value = "100";
                                        };
                                        class FP50
                                        {
                                                name = "$STR_ALIVE_ML_FORCE_POOL_50";
                                                value = "50";
                                        };
                                };
                        };
                        class allowInfantryReinforcement
                        {
                                displayName = "$STR_ALIVE_ML_ALLOW_INF";
                                description = "$STR_ALIVE_ML_ALLOW_INF_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                };
                        };
                        class allowMechanisedReinforcement
                        {
                                displayName = "$STR_ALIVE_ML_ALLOW_MECH";
                                description = "$STR_ALIVE_ML_ALLOW_MECH_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                };
                        };
                        class allowMotorisedReinforcement
                        {
                                displayName = "$STR_ALIVE_ML_ALLOW_MOT";
                                description = "$STR_ALIVE_ML_ALLOW_MOT_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                };
                        };
                        class allowArmourReinforcement
                        {
                                displayName = "$STR_ALIVE_ML_ALLOW_ARM";
                                description = "$STR_ALIVE_ML_ALLOW_ARM_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                };
                        };
                        class allowHeliReinforcement
                        {
                                displayName = "$STR_ALIVE_ML_ALLOW_HELI";
                                description = "$STR_ALIVE_ML_ALLOW_HELI_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                };
                        };
                        class allowPlaneReinforcement
                        {
                                displayName = "$STR_ALIVE_ML_ALLOW_PLANE";
                                description = "$STR_ALIVE_ML_ALLOW_PLANE_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                };
                        };
                        class enableAirTransport
                        {
                            displayName = "$STR_ALIVE_ML_ENABLE_AIR_TRANSPORT";
                            description = "$STR_ALIVE_ML_ENABLE_AIR_TRANSPORT_COMMENT";
                            class Values
                            {
                                class Yes
                                {
                                    name = "Yes";
                                    value = true;
                                    default = 1;
                                };
                                class No
                                {
                                    name = "No";
                                    value = false;
                                };
                            };
                        };
                        class limitTransportToFaction
                        {
                                displayName = "$STR_ALIVE_ML_LIMIT";
                                description = "$STR_ALIVE_ML_LIMIT_COMMENT";
                                class Values
                                {
                                        class No
                                        {
                                                name = "Side and Faction";
                                                value = false;
                                                default = 1;
                                        };
                                        class Yes
                                        {
                                                name = "Faction Only";
                                                value = true;
                                        };
                                };
                        };
                };
                class ModuleDescription
                {
                    //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_ML_COMMENT",
                            "",
                            "$STR_ALIVE_ML_USAGE"
                    };
                    sync[] = {"ALiVE_mil_OPCOM"}; // Array of synced entities (can contain base classes)

                    class ALiVE_mil_OPCOM
                    {
                        description[] = { // Multi-line descriptions are supported
                            "$STR_ALIVE_OPCOM_COMMENT",
                            "",
                            "$STR_ALIVE_OPCOM_USAGE"
                        };
                        position = 0; // Position is taken into effect
                        direction = 0; // Direction is taken into effect
                        optional = 1; // Synced entity is optional
                        duplicate = 1; // Multiple entities of this type can be synced
                    };

                };
        };

        class NATO_Box_Base;
        class IND_Box_Base;
        class EAST_Box_Base;
        class Box_IND_AmmoVeh_F : IND_Box_Base
        {
            class Eventhandlers;
        };
        class Box_NATO_AmmoVeh_F : NATO_Box_Base
        {
            class Eventhandlers;
        };
        class Box_East_AmmoVeh_F : EAST_Box_Base
        {
            class Eventhandlers;
        };
        class ALIVE_O_supplyCrate_F : Box_East_AmmoVeh_F
        {
            transportSoldier = 3;
            scope = 1;
            mass = 650;
            class EventHandlers : Eventhandlers
            {
                class ADDON
                {
                    init = "(_this select 0) setMass 650";
                };
            };
        };
        class ALIVE_I_supplyCrate_F : Box_IND_AmmoVeh_F
        {
            transportSoldier = 3;
            scope = 1;
            mass = 650;
            class EventHandlers : Eventhandlers
            {
                class ADDON
                {
                    init = "(_this select 0) setMass 650";
                };
            };
        };
        class ALIVE_B_supplyCrate_F : Box_NATO_AmmoVeh_F
        {
            transportSoldier = 3;
            scope = 1;
            mass = 650;
            class EventHandlers : Eventhandlers
            {
                class ADDON
                {
                    init = "(_this select 0) setMass 650";
                };
            };
        };
};

class CfgVehicles
{
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
        };
        class ModuleDescription;
    };
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
                class Attributes : AttributesBase
                {
                        // ---- General --------------------------------------------------------
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_logistics_HDR_GENERAL"; displayName = "GENERAL"; };
                        class debug : Combo
                        {
                                property = "ALiVE_mil_logistics_debug";
                                displayName = "$STR_ALIVE_ML_DEBUG";
                                tooltip = "$STR_ALIVE_ML_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class persistent : Combo
                        {
                                property = "ALiVE_mil_logistics_persistent";
                                displayName = "$STR_ALIVE_ML_PERSISTENT";
                                tooltip = "$STR_ALIVE_ML_PERSISTENT_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class No { name = "No"; value = false; default = 1; };
                                    class Yes { name = "Yes"; value = true; };
                                };
                        };
                        class type : Combo
                        {
                                property = "ALiVE_mil_logistics_type";
                                displayName = "$STR_ALIVE_ML_TYPE";
                                tooltip = "$STR_ALIVE_ML_TYPE_COMMENT";
                                defaultValue = """DYNAMIC""";
                                class Values
                                {
                                    class Dynamic { name = "$STR_ALIVE_ML_TYPE_DYNAMIC"; value = "DYNAMIC"; default = 1; };
                                    class FP1000 { name = "$STR_ALIVE_ML_TYPE_STATIC"; value = "STATIC"; };
                                };
                        };
                        class forcePool : Combo
                        {
                                property = "ALiVE_mil_logistics_forcePool";
                                displayName = "$STR_ALIVE_ML_FORCE_POOL";
                                tooltip = "$STR_ALIVE_ML_FORCE_POOL_COMMENT";
                                defaultValue = """1000""";
                                class Values
                                {
                                    class Dynamic { name = "$STR_ALIVE_ML_FORCE_POOL_DYNAMIC"; value = "10"; };
                                    class FPInfinite { name = "$STR_ALIVE_ML_FORCE_POOL_INFINITE"; value = "100000"; };
                                    class FP20000 { name = "$STR_ALIVE_ML_FORCE_POOL_20000"; value = "20000"; };
                                    class FP10000 { name = "$STR_ALIVE_ML_FORCE_POOL_10000"; value = "10000"; };
                                    class FP5000 { name = "$STR_ALIVE_ML_FORCE_POOL_5000"; value = "5000"; };
                                    class FP2500 { name = "$STR_ALIVE_ML_FORCE_POOL_2500"; value = "2500"; };
                                    class FP1000 { name = "$STR_ALIVE_ML_FORCE_POOL_1000"; value = "1000"; default = 1; };
                                    class FP500 { name = "$STR_ALIVE_ML_FORCE_POOL_500"; value = "500"; };
                                    class FP200 { name = "$STR_ALIVE_ML_FORCE_POOL_200"; value = "200"; };
                                    class FP100 { name = "$STR_ALIVE_ML_FORCE_POOL_100"; value = "100"; };
                                    class FP50 { name = "$STR_ALIVE_ML_FORCE_POOL_50"; value = "50"; };
                                };
                        };
                        // ---- Reinforcement Types --------------------------------------------
                        class HDR_REINF : ALiVE_ModuleSubTitle { property = "ALiVE_mil_logistics_HDR_REINF"; displayName = "REINFORCEMENT TYPES"; };
                        class allowInfantryReinforcement : Combo
                        {
                                property = "ALiVE_mil_logistics_allowInfantryReinforcement";
                                displayName = "$STR_ALIVE_ML_ALLOW_INF";
                                tooltip = "$STR_ALIVE_ML_ALLOW_INF_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class allowMechanisedReinforcement : Combo
                        {
                                property = "ALiVE_mil_logistics_allowMechanisedReinforcement";
                                displayName = "$STR_ALIVE_ML_ALLOW_MECH";
                                tooltip = "$STR_ALIVE_ML_ALLOW_MECH_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class allowMotorisedReinforcement : Combo
                        {
                                property = "ALiVE_mil_logistics_allowMotorisedReinforcement";
                                displayName = "$STR_ALIVE_ML_ALLOW_MOT";
                                tooltip = "$STR_ALIVE_ML_ALLOW_MOT_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class allowArmourReinforcement : Combo
                        {
                                property = "ALiVE_mil_logistics_allowArmourReinforcement";
                                displayName = "$STR_ALIVE_ML_ALLOW_ARM";
                                tooltip = "$STR_ALIVE_ML_ALLOW_ARM_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class allowHeliReinforcement : Combo
                        {
                                property = "ALiVE_mil_logistics_allowHeliReinforcement";
                                displayName = "$STR_ALIVE_ML_ALLOW_HELI";
                                tooltip = "$STR_ALIVE_ML_ALLOW_HELI_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class allowPlaneReinforcement : Combo
                        {
                                property = "ALiVE_mil_logistics_allowPlaneReinforcement";
                                displayName = "$STR_ALIVE_ML_ALLOW_PLANE";
                                tooltip = "$STR_ALIVE_ML_ALLOW_PLANE_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class excludeKinds : Edit
                        {
                                property = "ALiVE_mil_logistics_excludeKinds";
                                displayName = "$STR_ALIVE_ML_EXCLUDE_KINDS";
                                tooltip = "$STR_ALIVE_ML_EXCLUDE_KINDS_COMMENT";
                                defaultValue = """""";
                                typeName = "STRING";
                        };
                        // ---- Transport ------------------------------------------------------
                        class HDR_TRANSPORT : ALiVE_ModuleSubTitle { property = "ALiVE_mil_logistics_HDR_TRANSPORT"; displayName = "TRANSPORT"; };
                        class enableAirTransport : Combo
                        {
                                property = "ALiVE_mil_logistics_enableAirTransport";
                                displayName = "$STR_ALIVE_ML_ENABLE_AIR_TRANSPORT";
                                tooltip = "$STR_ALIVE_ML_ENABLE_AIR_TRANSPORT_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class limitTransportToFaction : Combo
                        {
                                property = "ALiVE_mil_logistics_limitTransportToFaction";
                                displayName = "$STR_ALIVE_ML_LIMIT";
                                tooltip = "$STR_ALIVE_ML_LIMIT_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class No { name = "Side and Faction"; value = false; default = 1; };
                                    class Yes { name = "Faction Only"; value = true; };
                                };
                        };
                        class airliftAircraftClass : Edit
                        {
                                property = "ALiVE_mil_logistics_airliftAircraftClass";
                                displayName = "$STR_ALIVE_ML_AIRLIFT_AIRCRAFT_CLASS";
                                tooltip = "$STR_ALIVE_ML_AIRLIFT_AIRCRAFT_CLASS_DESC";
                                defaultValue = """""";
                        };
                        class airliftSourceAirportID : Edit
                        {
                                property = "ALiVE_mil_logistics_airliftSourceAirportID";
                                displayName = "$STR_ALIVE_ML_AIRLIFT_SOURCE_AIRPORT_ID";
                                tooltip = "$STR_ALIVE_ML_AIRLIFT_SOURCE_AIRPORT_ID_DESC";
                                defaultValue = """""";
                        };
                        class airliftFleetSize : Edit
                        {
                                property = "ALiVE_mil_logistics_airliftFleetSize";
                                displayName = "$STR_ALIVE_ML_AIRLIFT_FLEET_SIZE";
                                tooltip = "$STR_ALIVE_ML_AIRLIFT_FLEET_SIZE_DESC";
                                defaultValue = """999""";
                        };
                        class airliftCargoSlots : Edit
                        {
                                property = "ALiVE_mil_logistics_airliftCargoSlots";
                                displayName = "$STR_ALIVE_ML_AIRLIFT_CARGO_SLOTS";
                                tooltip = "$STR_ALIVE_ML_AIRLIFT_CARGO_SLOTS_DESC";
                                defaultValue = """0""";
                        };
                        // ---- Custom Static Data ---------------------------------------------
                        class HDR_CUSTOM : ALiVE_ModuleSubTitle { property = "ALiVE_mil_logistics_HDR_CUSTOM"; displayName = "CUSTOM TRANSPORT CLASSES"; };
                        class customStaticDataMode : Combo
                        {
                                property = "ALiVE_mil_logistics_customStaticDataMode";
                                displayName = "$STR_ALIVE_ML_CUSTOM_MODE";
                                tooltip = "$STR_ALIVE_ML_CUSTOM_MODE_COMMENT";
                                defaultValue = """REPLACE""";
                                class Values
                                {
                                    class Replace { name = "Replace"; value = "REPLACE"; default = 1; };
                                    class Append  { name = "Append";  value = "APPEND";  };
                                };
                        };
                        class customLandTransport
                        {
                                property     = "ALiVE_mil_logistics_customLandTransport";
                                displayName  = "$STR_ALIVE_ML_CUSTOM_LAND_TRANSPORT";
                                tooltip      = "$STR_ALIVE_ML_CUSTOM_LAND_TRANSPORT_COMMENT";
                                control      = "ALiVE_FactionStaticDataChoice_LandTransport";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['customLandTransport', _value];";
                                defaultValue = """""";
                        };
                        class customAirTransport
                        {
                                property     = "ALiVE_mil_logistics_customAirTransport";
                                displayName  = "$STR_ALIVE_ML_CUSTOM_AIR_TRANSPORT";
                                tooltip      = "$STR_ALIVE_ML_CUSTOM_AIR_TRANSPORT_COMMENT";
                                control      = "ALiVE_FactionStaticDataChoice_AirTransport";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['customAirTransport', _value];";
                                defaultValue = """""";
                        };
                        class customContainers
                        {
                                property     = "ALiVE_mil_logistics_customContainers";
                                displayName  = "$STR_ALIVE_ML_CUSTOM_CONTAINERS";
                                tooltip      = "$STR_ALIVE_ML_CUSTOM_CONTAINERS_COMMENT";
                                control      = "ALiVE_FactionStaticDataChoice_Containers";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['customContainers', _value];";
                                defaultValue = """""";
                        };
                        // ---- Starting Force Strength ----------------------------------------
                        class HDR_STRENGTH : ALiVE_ModuleSubTitle { property = "ALiVE_mil_logistics_HDR_STRENGTH"; displayName = "STARTING FORCE STRENGTH"; };
                        class startForceStrengthInc : Combo
                        {
                                property = "ALiVE_mil_logistics_startForceStrengthInc";
                                displayName = "$STR_ALIVE_ML_START_FORCE_STRENGTH_INC";
                                tooltip = "$STR_ALIVE_ML_START_FORCE_STRENGTH_INC_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class No { name = "No"; value = false; default = 1; };
                                    class Yes { name = "Yes"; value = true; };
                                };
                        };
                        class startForceStrengthIncFactor : Combo
                        {
                                property = "ALiVE_mil_logistics_startForceStrengthIncFactor";
                                displayName = "$STR_ALIVE_ML_START_FORCE_STRENGTH_INC_FACTOR";
                                tooltip = "$STR_ALIVE_ML_START_FORCE_STRENGTH_INC_FACTOR_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class LOWEST { name = "1%"; value = "1"; default = 1; };
                                    class LOW { name = "4%"; value = "4"; };
                                    class MEDIUM { name = "6%"; value = "6"; };
                                    class HIGH { name = "8%"; value = "8"; };
                                    class VHIGH { name = "10%"; value = "10"; };
                                };
                        };
                        class startForceStrengthDec : Combo
                        {
                                property = "ALiVE_mil_logistics_startForceStrengthDec";
                                displayName = "$STR_ALIVE_ML_START_FORCE_STRENGTH_DEC";
                                tooltip = "$STR_ALIVE_ML_START_FORCE_STRENGTH_DEC_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class No { name = "No"; value = false; default = 1; };
                                    class Yes { name = "Yes"; value = true; };
                                };
                        };
                        class startForceStrengthDecFactor : Combo
                        {
                                property = "ALiVE_mil_logistics_startForceStrengthDecFactor";
                                displayName = "$STR_ALIVE_ML_START_FORCE_STRENGTH_DEC_FACTOR";
                                tooltip = "$STR_ALIVE_ML_START_FORCE_STRENGTH_DEC_FACTOR_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class LOWEST { name = "1%"; value = "1"; default = 1; };
                                    class LOW { name = "4%"; value = "4"; };
                                    class MEDIUM { name = "6%"; value = "6"; };
                                    class HIGH { name = "8%"; value = "8"; };
                                    class VHIGH { name = "10%"; value = "10"; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_ML_COMMENT","","$STR_ALIVE_ML_USAGE"};
                    sync[] = {"ALiVE_mil_OPCOM"};
                    class ALiVE_mil_OPCOM
                    {
                        description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"};
                        position = 0; direction = 0; optional = 1; duplicate = 1;
                    };
                };
        };
        class NATO_Box_Base;
        class IND_Box_Base;
        class EAST_Box_Base;
        class Box_IND_AmmoVeh_F : IND_Box_Base { class Eventhandlers; };
        class Box_NATO_AmmoVeh_F : NATO_Box_Base { class Eventhandlers; };
        class Box_East_AmmoVeh_F : EAST_Box_Base { class Eventhandlers; };
        class ALIVE_O_supplyCrate_F : Box_East_AmmoVeh_F
        {
            transportSoldier = 3; scope = 1; mass = 650;
            class EventHandlers : Eventhandlers { class ADDON { init = "(_this select 0) setMass 650"; }; };
        };
        class ALIVE_I_supplyCrate_F : Box_IND_AmmoVeh_F
        {
            transportSoldier = 3; scope = 1; mass = 650;
            class EventHandlers : Eventhandlers { class ADDON { init = "(_this select 0) setMass 650"; }; };
        };
        class ALIVE_B_supplyCrate_F : Box_NATO_AmmoVeh_F
        {
            transportSoldier = 3; scope = 1; mass = 650;
            class EventHandlers : Eventhandlers { class ADDON { init = "(_this select 0) setMass 650"; }; };
        };
};

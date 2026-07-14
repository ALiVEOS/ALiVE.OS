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
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_TRANSPORT";
                function = "ALIVE_fnc_TRANSPORTInit";
                author = MODULE_AUTHOR;
                functionPriority = 163;
                isGlobal = 2;
                icon = "x\alive\addons\sup_transport\icon_sup_transport.paa";
                picture = "x\alive\addons\sup_transport\icon_sup_transport.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_transport_HDR_GENERAL"; displayName = "GENERAL"; };
                        class transport_callsign : Edit { property = "ALiVE_sup_transport_transport_callsign"; displayName = "$STR_ALIVE_TRANSPORT_CALLSIGN"; tooltip = "$STR_ALIVE_TRANSPORT_CALLSIGN_DESC"; defaultValue = """RODEO TWO"""; };
                        class transport_type
                        {
                                property     = "ALiVE_sup_transport_transport_type";
                                displayName  = "$STR_ALIVE_TRANSPORT_TYPE";
                                tooltip      = "$STR_ALIVE_TRANSPORT_TYPE_DESC";
                                control      = "ALiVE_VehicleCombo_Transport";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['transport_type', _value];";
                                defaultValue = """B_Heli_Transport_01_camo_F""";
                        };
                        class transport_type_custom : Edit
                        {
                                property     = "ALiVE_sup_transport_transport_type_custom";
                                displayName  = "$STR_ALIVE_TRANSPORT_TYPE_CUSTOM";
                                tooltip      = "$STR_ALIVE_TRANSPORT_TYPE_CUSTOM_DESC";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['transport_type_custom', _value];";
                                defaultValue = """""";
                        };
                        class transport_height : Edit { property = "ALiVE_sup_transport_transport_height"; displayName = "$STR_ALIVE_TRANSPORT_HEIGHT"; tooltip = "$STR_ALIVE_TRANSPORT_HEIGHT_DESC"; defaultValue = """0"""; };
                        class transport_code : Edit { property = "ALiVE_sup_transport_transport_code"; displayName = "$STR_ALIVE_TRANSPORT_CODE"; tooltip = "$STR_ALIVE_TRANSPORT_CODE_DESC"; defaultValue = """"""; };
                        class HDR_SLINGLOAD : ALiVE_ModuleSubTitle { property = "ALiVE_sup_transport_HDR_SLINGLOAD"; displayName = "SLINGLOADING"; };
                        class transport_slingloading : Combo
                        {
                                property = "ALiVE_sup_transport_transport_slingloading";
                                displayName = "$STR_ALIVE_TRANSPORT_SLINGLOADING";
                                tooltip = "$STR_ALIVE_TRANSPORT_SLINGLOADING_DESC";
                                defaultValue = """1""";
                                class Values
                                {
                                    class No { name = "No"; value = 0; };
                                    class Yes { name = "Yes"; value = 1; default = 1; };
                                };
                        };
                        class transport_containers : Edit { property = "ALiVE_sup_transport_transport_containers"; displayName = "$STR_ALIVE_TRANSPORT_CONTAINERS"; tooltip = "$STR_ALIVE_TRANSPORT_CONTAINERS_DESC"; defaultValue = """0"""; typeName = "NUMBER"; };
                        class HDR_LOGISTICS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_transport_HDR_LOGISTICS"; displayName = "LOGISTICS"; };
                        class transport_logistics : Combo
                        {
                                property = "ALiVE_sup_transport_transport_logistics";
                                displayName = "$STR_ALIVE_TRANSPORT_LOGISTICS";
                                tooltip = "$STR_ALIVE_TRANSPORT_LOGISTICS_DESC";
                                defaultValue = """0""";
                                class Values
                                {
                                    class No { name = "No"; value = 0; default = 1; };
                                    class Yes { name = "Yes"; value = 1; };
                                };
                        };
                        class transport_logisticssource : Combo
                        {
                                property = "ALiVE_sup_transport_transport_logisticssource";
                                displayName = "$STR_ALIVE_TRANSPORT_LOGISTICSSOURCE";
                                tooltip = "$STR_ALIVE_TRANSPORT_LOGISTICSSOURCE_DESC";
                                defaultValue = """0""";
                                class Values
                                {
                                    class Static { name = "Static (LOGCOM Base)"; value = 0; default = 1; };
                                    class Dynamic { name = "Dynamic (Nearest Objective)"; value = 1; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_TRANSPORT_COMMENT","","$STR_ALIVE_TRANSPORT_USAGE"};
                };
        };
};

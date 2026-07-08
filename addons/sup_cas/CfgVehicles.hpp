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
                displayName = "$STR_ALIVE_CAS";
                function = "ALIVE_fnc_CASInit";
                author = MODULE_AUTHOR;
                functionPriority = 162;
                isGlobal = 2;
                icon = "x\alive\addons\sup_cas\icon_sup_cas.paa";
                picture = "x\alive\addons\sup_cas\icon_sup_cas.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_cas_HDR_GENERAL"; displayName = "GENERAL"; };
                        class cas_callsign : Edit { property = "ALiVE_sup_cas_cas_callsign"; displayName = "$STR_ALIVE_CAS_CALLSIGN"; tooltip = "$STR_ALIVE_CAS_CALLSIGN_DESC"; defaultValue = """EAGLE ONE"""; };
                        class cas_type
                        {
                                property     = "ALiVE_sup_cas_cas_type";
                                displayName  = "$STR_ALIVE_CAS_TYPE";
                                tooltip      = "$STR_ALIVE_CAS_TYPE_DESC";
                                control      = "ALiVE_VehicleCombo_CAS";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['cas_type', _value];";
                                defaultValue = """B_Heli_Attack_01_F""";
                        };
                        class cas_type_custom : Edit
                        {
                                property     = "ALiVE_sup_cas_cas_type_custom";
                                displayName  = "$STR_ALIVE_CAS_TYPE_CUSTOM";
                                tooltip      = "$STR_ALIVE_CAS_TYPE_CUSTOM_DESC";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['cas_type_custom', _value];";
                                defaultValue = """""";
                        };
                        class cas_height : Edit { property = "ALiVE_sup_cas_cas_height"; displayName = "$STR_ALIVE_CAS_HEIGHT"; tooltip = "$STR_ALIVE_CAS_HEIGHT_DESC"; defaultValue = """0"""; };
                        class cas_code : Edit { property = "ALiVE_sup_cas_cas_code"; displayName = "$STR_ALIVE_CAS_CODE"; tooltip = "$STR_ALIVE_CAS_CODE_DESC"; defaultValue = """"""; };
                        class HDR_LOGISTICS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_cas_HDR_LOGISTICS"; displayName = "LOGISTICS"; };
                        class cas_logistics : Combo
                        {
                                property = "ALiVE_sup_cas_cas_logistics";
                                displayName = "$STR_ALIVE_CAS_LOGISTICS";
                                tooltip = "$STR_ALIVE_CAS_LOGISTICS_DESC";
                                defaultValue = """0""";
                                class Values
                                {
                                    class No { name = "No"; value = 0; default = 1; };
                                    class Yes { name = "Yes"; value = 1; };
                                };
                        };
                        class cas_logisticssource : Combo
                        {
                                property = "ALiVE_sup_cas_cas_logisticssource";
                                displayName = "$STR_ALIVE_CAS_LOGISTICSSOURCE";
                                tooltip = "$STR_ALIVE_CAS_LOGISTICSSOURCE_DESC";
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
                        description[] = {"$STR_ALIVE_CAS_COMMENT","","$STR_ALIVE_CAS_USAGE"};
                };
        };
};

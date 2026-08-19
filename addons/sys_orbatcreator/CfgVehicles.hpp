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
        class ADDON : ModuleAliveBase {
                scope = 2;
                displayName = "$STR_ALIVE_ORBATCREATOR";
                function = "ALiVE_fnc_orbatCreatorInit";
                functionPriority = 1;
                isGlobal = 2;
                icon = "x\alive\addons\sys_orbatcreator\icon_sys_orbatcreator.paa";
                picture = "x\alive\addons\sys_orbatcreator\icon_sys_orbatcreator.paa";
                author = MODULE_AUTHOR;
                class Attributes : AttributesBase
                {
                    class debug : Combo
                    {
                            property = "ALiVE_sys_orbatcreator_debug";
                            displayName = "$STR_ALIVE_ORBATCREATOR_DEBUG";
                            tooltip = "$STR_ALIVE_ORBATCREATOR_DEBUG_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                class Yes { name = "Yes"; value = true; };
                                class No { name = "No"; value = false; default = 1; };
                            };
                    };
                    class background : Combo
                    {
                            property = "ALiVE_sys_orbatcreator_background";
                            displayName = "$STR_ALIVE_ORBATCREATOR_BACKGROUND";
                            tooltip = "$STR_ALIVE_ORBATCREATOR_BACKGROUND_COMMENT";
                            defaultValue = """true""";
                            class Values
                            {
                                class Yes { name = "Yes"; value = true; default = 1; };
                                class No { name = "No"; value = false; };
                            };
                    };
                    class prefix : Edit
                    {
                            property = "ALiVE_sys_orbatcreator_prefix";
                            displayName = "$STR_ALIVE_ORBATCREATOR_PREFIX";
                            tooltip = "$STR_ALIVE_ORBATCREATOR_PREFIX_COMMENT";
                            defaultValue = """""";
                    };
                    class copyParent : Combo
                    {
                            property = "ALiVE_sys_orbatcreator_copyParent";
                            displayName = "$STR_ALIVE_ORBATCREATOR_COPY";
                            tooltip = "$STR_ALIVE_ORBATCREATOR_COPY_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                class Yes { name = "Yes"; value = true; };
                                class No { name = "No"; value = false; default = 1; };
                            };
                    };
                    class arsenalType
                    {
                            property = "ALiVE_sys_orbatcreator_arsenalType";
                            displayName = "$STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE";
                            tooltip = "$STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_COMMENT";
                            control = "ALiVE_ArsenalType";
                            typeName = "STRING";
                            defaultValue = """BIS""";
                            expression = "_this setVariable ['arsenalType',_value];";
                            class Values
                            {
                                class BIS { name = "$STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_BIS"; value = "BIS"; default = 1; };
                                class ACE { name = "$STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_ACE"; value = "ACE"; };
                            };
                    };
                    class ModuleDescription : ModuleDescription {};
                };
        };
};

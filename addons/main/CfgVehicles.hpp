#define MODULE_NAME ALiVE_require
#define MVAR(var) DOUBLES(MODULE_NAME,var)

// Add a game logic which does nothing except requires the addon in the mission.

class CfgFactionClasses {
    class Alive {
        displayName = "$STR_ALIVE_MODULE";
        priority = 0;
        side = 7;
    };
};

class Cfg3DEN
{
    class Attributes // Attribute UI controls are placed in this pre-defined class
    {
        // Base class templates
        class Default; // Empty template with pre-defined width and single line height
        class TitleWide: Default
        {
            class Controls
            {
                class Title;
            };
        }; // Template with full-width single line title and space for content below it

        // Your attribute class
        class ALiVE_ModuleSubTitle: TitleWide
        {
            // List of controls, structure is the same as with any other controls group
            class Controls: Controls
            {
                class Title: Title
                {
                    style = 2;
                    colorText[] = {1,1,1,0.4};
                }; // Inherit existing title control. Text of any control with class Title will be changed to attribute displayName
            };
        };
    };
};

class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class ArgumentsBaseUnits
        {
            class Units;
        };
        class AttributesBase
        {
            class Default;
            class Edit; // Default edit box (i.e., text input field)
            class Combo; // Default combo box (i.e., drop-down menu)
            class Checkbox; // Default checkbox (returned value is Bool)
            class CheckboxNumber; // Default checkbox (returned value is Number)
            class ModuleDescription; // Module description
        };
        class ModuleDescription
        {
            class AnyBrain;
        };
    };

    class ModuleAliveBase: Module_F {
        scope = 1;
        displayName = "EditorAliveBase";
        category = "Alive";
        class AttributesBase : AttributesBase
        {
            class ALiVE_ModuleSubTitle : Default
            {
                control = "ALiVE_ModuleSubTitle";
                defaultValue = "''";
            };
            class ALiVE_EditMulti3 : Default
            {
                control = "EditMulti3";
                defaultValue = "''";
            };
            class ALiVE_EditMulti5 : Default
            {
                control = "EditMulti5";
                defaultValue = "''";
            };
        };
    };

    class ALiVE_require: ModuleAliveBase
    {
        scope = 2;
        displayName = "$STR_ALIVE_REQUIRES_ALIVE";
        icon = "x\alive\addons\main\icon_requires_alive.paa";
        picture = "x\alive\addons\main\icon_requires_alive.paa";
        functionPriority = 40;
        isGlobal = 2;
        function = "ALiVE_fnc_aliveInit";
        author = MODULE_AUTHOR;

        class Attributes: AttributesBase
        {
            class debug: Combo
            {
                    property =  MVAR(debug);
                    displayName = "$STR_ALIVE_DEBUG";
                    tooltip = "$STR_ALIVE_DEBUG_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = "true";
                            };
                            class No
                            {
                                    name = "No";
                                    value = "false";
                            };
                    };
            };
            class ALiVE_Versioning: Combo
            {
                    property =  MVAR(ALiVE_Versioning);
                    displayName = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING";
                    tooltip = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING_COMMENT";
                    defaultValue = """warning""";
                    class Values
                    {
                            class warning
                            {
                                    name = "Warn players";
                                    value = "warning";
                            };
                            class kick
                            {
                                    name = "Kick players";
                                    value = "kick";
                            };
                    };
            };

            class ALiVE_AI_DISTRIBUTION: Combo
            {
                    property =  MVAR(ALiVE_AI_DISTRIBUTION);
                    displayName = "$STR_ALIVE_REQUIRES_ALIVE_AI_DISTRIBUTION";
                    tooltip = "$STR_ALIVE_REQUIRES_ALIVE_AI_DISTRIBUTION_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {
                            class off
                            {
                                    name = "Server";
                                    value = "false";
                            };
                            class on
                            {
                                    name = "Headless clients";
                                    value = "true";
                            };
                    };
            };

            class ALiVE_DISABLESAVE: Combo
            {
                    property =  MVAR(ALiVE_DISABLESAVE);
                    displayName = "$STR_ALIVE_DISABLESAVE";
                    tooltip = "$STR_ALIVE_DISABLESAVE_COMMENT";
                    defaultValue = """true""";
                    class Values
                    {
                            class warning
                            {
                                    name = "Yes";
                                    value = "true";
                            };
                            class kick
                            {
                                    name = "No";
                                    value = "false";
                            };
                    };
            };
            class ALiVE_DISABLEMARKERS: Combo
            {
                    property =  MVAR(ALiVE_DISABLEMARKERS);
                    displayName = "$STR_ALIVE_DISABLEMARKERS";
                    tooltip = "$STR_ALIVE_DISABLEMARKERS_COMMENT";
                    typeName = "BOOL";
                    defaultValue = "false";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = 1;
                            };
                            class No
                            {
                                    name = "No";
                                    value = 0;
                            };
                    };
            };
            class ALiVE_DISABLEADMINACTIONS: Combo
            {
                    property =  MVAR(ALiVE_DISABLEADMINACTIONS);

                    displayName = "$STR_ALIVE_DISABLEADMINACTIONS";
                    tooltip = "$STR_ALIVE_DISABLEADMINACTIONS_COMMENT";
                    typeName = "BOOL";
                    defaultValue = "false";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = 1;
                            };
                            class No
                            {
                                    name = "No";
                                    value = 0;
                            };
                    };
            };
            class ALiVE_PAUSEMODULES: Combo
            {
                    property =  MVAR(ALiVE_PAUSEMODULES);
                    displayName = "$STR_ALiVE_PAUSEMODULES";
                    tooltip = "$STR_ALiVE_PAUSEMODULES_COMMENT";
                    typeName = "BOOL";
                    defaultValue = "false";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = 1;
                            };
                            class No
                            {
                                    name = "No";
                                    value = 0;
                            };
                    };
            };
            class ALiVE_GC_INTERVAL: Edit
            {
                    property =  MVAR(ALiVE_GC_INTERVAL);
                    displayName = "$STR_ALIVE_GC_INTERVAL";
                    tooltip = "$STR_ALIVE_GC_INTERVAL_COMMENT";
                    defaultValue = """300""";
            };
            class ALiVE_GC_THRESHHOLD: Edit
            {
                    property =  MVAR(ALiVE_GC_THRESHHOLD);
                    displayName = "$STR_ALIVE_GC_THRESHHOLD";
                    tooltip = "$STR_ALIVE_GC_THRESHHOLD_COMMENT";
                    defaultValue = """100""";
            };
            class ALiVE_GC_INDIVIDUALTYPES: Edit
            {
                    property =  MVAR(ALiVE_GC_INDIVIDUALTYPES);
                    displayName = "$STR_ALIVE_GC_INDIVIDUALTYPES";
                    tooltip = "$STR_ALIVE_GC_INDIVIDUALTYPES_COMMENT";
                    defaultValue = """""";
            };
            class ALiVE_TABLET_MODEL: Combo
            {
                property =  MVAR(ALiVE_TABLET_MODEL);
                displayName = "$STR_ALiVE_TABLET_MODEL";
                tooltip = "$STR_ALiVE_TABLET_MODEL_COMMENT";
                typeName = "STRING";
                defaultValue = """Tablet01""";
                class Values
                {
                    class Tablet01
                    {
                        name = "Tablet 1";
                        value = "Tablet01";
                    };
                    class MapBag01
                    {
                        name = "Mapbag 1";
                        value = "Mapbag01";
                    };
                };
            };
            class ModuleDescription: ModuleDescription{};
        };
        class ModuleDescription: ModuleDescription
        {
            //description = "$STR_ALIVE_REQUIRES_COMMENT"; // Short description, will be formatted as structured text
            description[] = {
                "$STR_ALIVE_REQUIRES_ALIVE",
                "",
                "$STR_ALIVE_REQUIRES_USAGE"
            };
            sync[] = {}; // Array of synced entities (can contain base classes)
        };
    };
};

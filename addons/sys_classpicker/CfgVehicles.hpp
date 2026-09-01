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
        displayName = "$STR_ALIVE_CLASSPICKER";
        function = "ALIVE_fnc_classPickerModuleInit";
        author = MODULE_AUTHOR;
        functionPriority = 162;
        isGlobal = 2;
        icon = "x\alive\addons\main\icon_requires_alive.paa";
        picture = "x\alive\addons\main\icon_requires_alive.paa";

        class Attributes : AttributesBase
        {
            class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_classpicker_HDR_GENERAL"; displayName = "GENERAL"; };

            class pickerKinds : Combo
            {
                property     = "ALiVE_sys_classpicker_pickerKinds";
                displayName  = "$STR_ALIVE_CLASSPICKER_KINDS";
                tooltip      = "$STR_ALIVE_CLASSPICKER_KINDS_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerKinds', _value];";
                defaultValue = """buildings""";
                class Values
                {
                    class Buildings { name = "Buildings"; value = "buildings"; default = 1; };
                    class Vehicles  { name = "Vehicles";  value = "vehicles"; };
                    class Units     { name = "Units";     value = "units"; };
                };
            };

            class pickerRadius : Edit
            {
                property     = "ALiVE_sys_classpicker_pickerRadius";
                displayName  = "$STR_ALIVE_CLASSPICKER_RADIUS";
                tooltip      = "$STR_ALIVE_CLASSPICKER_RADIUS_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerRadius', _value];";
                defaultValue = """75""";
            };

            class pickerIndices : Combo
            {
                property     = "ALiVE_sys_classpicker_pickerIndices";
                displayName  = "$STR_ALIVE_CLASSPICKER_INDICES";
                tooltip      = "$STR_ALIVE_CLASSPICKER_INDICES_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerIndices', _value];";
                defaultValue = """true""";
                class Values
                {
                    class Yes { name = "Yes"; value = "true"; default = 1; };
                    class No  { name = "No";  value = "false"; };
                };
            };

            class pickerAutoStart : Combo
            {
                property     = "ALiVE_sys_classpicker_pickerAutoStart";
                displayName  = "$STR_ALIVE_CLASSPICKER_AUTOSTART";
                tooltip      = "$STR_ALIVE_CLASSPICKER_AUTOSTART_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerAutoStart', _value];";
                defaultValue = """true""";
                class Values
                {
                    class Yes { name = "Yes"; value = "true"; default = 1; };
                    class No  { name = "No";  value = "false"; };
                };
            };

            class pickerOnReturn : Combo
            {
                property     = "ALiVE_sys_classpicker_pickerOnReturn";
                displayName  = "$STR_ALIVE_CLASSPICKER_ONRETURN";
                tooltip      = "$STR_ALIVE_CLASSPICKER_ONRETURN_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerOnReturn', _value];";
                defaultValue = """apply""";
                class Values
                {
                    class Apply  { name = "Apply to synced modules"; value = "apply"; default = 1; };
                    class Remind { name = "Remind me";                   value = "remind"; };
                    class Off    { name = "Do nothing";                value = "off"; };
                };
            };

            class HDR_LABELS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_classpicker_HDR_LABELS"; displayName = "LABELS"; };

            class pickerLabelSize : Edit
            {
                property     = "ALiVE_sys_classpicker_pickerLabelSize";
                displayName  = "$STR_ALIVE_CLASSPICKER_LABELSIZE";
                tooltip      = "$STR_ALIVE_CLASSPICKER_LABELSIZE_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerLabelSize', _value];";
                defaultValue = """0.042""";
            };

            class pickerIndexSize : Edit
            {
                property     = "ALiVE_sys_classpicker_pickerIndexSize";
                displayName  = "$STR_ALIVE_CLASSPICKER_INDEXSIZE";
                tooltip      = "$STR_ALIVE_CLASSPICKER_INDEXSIZE_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerIndexSize', _value];";
                defaultValue = """0.06""";
            };

            class pickerFont : Edit
            {
                property     = "ALiVE_sys_classpicker_pickerFont";
                displayName  = "$STR_ALIVE_CLASSPICKER_FONT";
                tooltip      = "$STR_ALIVE_CLASSPICKER_FONT_COMMENT";
                typeName     = "STRING";
                expression   = "_this setVariable ['pickerFont', _value];";
                defaultValue = """PuristaBold""";
            };

            class ModuleDescription : ModuleDescription {};
        };

        // Outside Attributes and NOT inheriting, which is the shape the other
        // modules use and the only one Eden renders. description is an array of
        // lines, and sync names what this is meant to be wired to, which Eden
        // shows as guidance in the same panel.
        class ModuleDescription
        {
            description[] = {"$STR_ALIVE_CLASSPICKER_COMMENT", "", "$STR_ALIVE_CLASSPICKER_DESC"};
            sync[] = {"ALiVE_mil_placement", "ALiVE_mil_placement_custom", "ALiVE_civ_placement", "ALiVE_civ_placement_custom"};
        };
    };
};

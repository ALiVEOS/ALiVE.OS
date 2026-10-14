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
                scope = 1;
                displayName = "$STR_ALIVE_player";
                function = "ALIVE_fnc_emptyInit";
                functionPriority = 202;
                isGlobal = 2;
                icon = "x\alive\addons\sys_player\icon_sys_player.paa";
                picture = "x\alive\addons\sys_player\icon_sys_player.paa";
                author = MODULE_AUTHOR;
                class ModuleDescription
                {
                        description = "This module allows you to persist player state between reconnects and server restarts.";
                };
                class Attributes : AttributesBase
                {
                        class HDR_OPTIONS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_player_HDR_OPTIONS"; displayName = "PLAYER OPTIONS"; };
                        class allowReset : Combo
                        {
                                property = "ALiVE_sys_player_allowReset";
                                displayName = "$STR_ALIVE_player_allowReset";
                                tooltip = "$STR_ALIVE_player_allowReset_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class allowManualSave : Combo
                        {
                                property = "ALiVE_sys_player_allowManualSave";
                                displayName = "$STR_ALIVE_player_allowManualSave";
                                tooltip = "$STR_ALIVE_player_allowManualSave_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class allowDiffClass : Combo
                        {
                                property = "ALiVE_sys_player_allowDiffClass";
                                displayName = "$STR_ALIVE_player_allowDiffClass";
                                tooltip = "$STR_ALIVE_player_allowDiffClass_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class HDR_STORED : ALiVE_ModuleSubTitle { property = "ALiVE_sys_player_HDR_STORED"; displayName = "WHAT IS STORED"; };
                        class saveLoadout : Combo
                        {
                                property = "ALiVE_sys_player_saveLoadout";
                                displayName = "$STR_ALIVE_player_SAVELOADOUT";
                                tooltip = "$STR_ALIVE_player_SAVELOADOUT_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class saveAmmo : Combo
                        {
                                property = "ALiVE_sys_player_saveAmmo";
                                displayName = "$STR_ALIVE_player_SAVEAMMO";
                                tooltip = "$STR_ALIVE_player_SAVEAMMO_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class saveHealth : Combo
                        {
                                property = "ALiVE_sys_player_saveHealth";
                                displayName = "$STR_ALIVE_player_SAVEHEALTH";
                                tooltip = "$STR_ALIVE_player_SAVEHEALTH_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class savePosition : Combo
                        {
                                property = "ALiVE_sys_player_savePosition";
                                displayName = "$STR_ALIVE_player_SAVEPOSITION";
                                tooltip = "$STR_ALIVE_player_SAVEPOSITION_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class saveScores : Combo
                        {
                                property = "ALiVE_sys_player_saveScores";
                                displayName = "$STR_ALIVE_player_SAVESCORES";
                                tooltip = "$STR_ALIVE_player_SAVESCORES_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class HDR_SAVING : ALiVE_ModuleSubTitle { property = "ALiVE_sys_player_HDR_SAVING"; displayName = "SAVING"; };
                        class storeToDB : Combo
                        {
                                property = "ALiVE_sys_player_storeToDB";
                                displayName = "$STR_ALIVE_player_storeToDB";
                                tooltip = "$STR_ALIVE_player_storeToDB_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class autoSaveTime : Edit
                        {
                                property = "ALiVE_sys_player_autoSaveTime";
                                displayName = "$STR_ALIVE_player_autoSaveTime";
                                tooltip = "$STR_ALIVE_player_autoSaveTime_COMMENT";
                                defaultValue = """0""";
                        };
                        class ModuleDescription : ModuleDescription {};
                };
        };
};

class CfgVehicles {
        class ModuleAliveBase;
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
                        description = "This module allows you to persist player state between reconnects and server restarts."; // Short description, will be formatted as structured text
                };
                class Arguments
                {

                        class allowReset
                        {
                                displayName = "$STR_ALIVE_player_allowReset";
                                description = "$STR_ALIVE_player_allowReset_COMMENT";
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

                        class allowManualSave
                        {
                                displayName = "$STR_ALIVE_player_allowManualSave";
                                description = "$STR_ALIVE_player_allowManualSave_COMMENT";
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
                        class allowDiffClass
                        {
                                displayName = "$STR_ALIVE_player_allowDiffClass";
                                description = "$STR_ALIVE_player_allowDiffClass_COMMENT";
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
                        class saveLoadout
                        {
                                displayName = "$STR_ALIVE_player_SAVELOADOUT";
                                description = "$STR_ALIVE_player_SAVELOADOUT_COMMENT";
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
                        class saveAmmo
                        {
                                displayName = "$STR_ALIVE_player_SAVEAMMO";
                                description = "$STR_ALIVE_player_SAVEAMMO_COMMENT";
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
                        class saveHealth
                        {
                                displayName = "$STR_ALIVE_player_SAVEHEALTH";
                                description = "$STR_ALIVE_player_SAVEHEALTH_COMMENT";
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
                        class savePosition
                        {
                                displayName = "$STR_ALIVE_player_SAVEPOSITION";
                                description = "$STR_ALIVE_player_SAVEPOSITION_COMMENT";
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
                        class saveScores
                        {
                                displayName = "$STR_ALIVE_player_SAVESCORES";
                                description = "$STR_ALIVE_player_SAVESCORES_COMMENT";
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
                        class storeToDB
                        {
                                displayName = "$STR_ALIVE_player_storeToDB";
                                description = "$STR_ALIVE_player_storeToDB_COMMENT";
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

                        class autoSaveTime
                        {
                                displayName = "$STR_ALIVE_player_autoSaveTime";
                                description = "$STR_ALIVE_player_autoSaveTime_COMMENT";
                                defaultValue = "0";
                        };
                };

        };
};

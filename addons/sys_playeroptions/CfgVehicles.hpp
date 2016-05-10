class CfgVehicles {
        class ModuleAliveBase;

        class ADDON : ModuleAliveBase
        {
        	scope = 2;
        	displayName = "$STR_ALIVE_playeroptions";
        	function = "ALIVE_fnc_playeroptionsInit";
        	functionPriority = 200;
        	isGlobal = 2;
        	icon = "x\alive\addons\sys_playeroptions\icon_sys_playeroptions.paa";
        	picture = "x\alive\addons\sys_playeroptions\icon_sys_playeroptions.paa";
        	author = MODULE_AUTHOR;

                class ModuleDescription
		{
			description[] = {
					"$STR_ALIVE_playeroptions_COMMENT",
					"",
					"$STR_ALIVE_playeroptions_USAGE"
			};
		};

                class Arguments
                {

                        class debug
                        {
                                displayName = "$STR_ALIVE_playeroptions_DEBUG";
                                description = "$STR_ALIVE_playeroptions_DEBUG_COMMENT";
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
                        // VIEW DISTANCE
                        class VIEW_DISTANCE {
                                displayName = "";
                                class Values
                                {
                                        class Divider
                                        {
                                                name = "----- View Distance ------------------------------------------------------";
                                                value = "";
                                        };
                                };
                        };
                        class maxVD
                        {
                                displayName = "$STR_ALIVE_VDIST_MAX";
                                description = "$STR_ALIVE_VDIST_MAX_COMMENT";
                                defaultvalue = "20000";
                        };
                        class minVD
                        {
                                displayName = "$STR_ALIVE_VDIST_MIN";
                                description = "$STR_ALIVE_VDIST_MIN_COMMENT";
                                defaultvalue = "500";
                        };
                        class maxTG
                        {
                                displayName = "$STR_ALIVE_TGRID_MAX";
                                description = "$STR_ALIVE_TGRID_MAX_COMMENT";
                                defaultvalue = "5";
                        };
                        class minTG
                        {
                                displayName = "$STR_ALIVE_TGRID_MIN";
                                description = "$STR_ALIVE_TGRID_MIN_COMMENT";
                                defaultvalue = "1";
                        };
                        // PERSISTENCE
                        class PERSISTENCE {
                                displayName = "";
                                class Values
                                {
                                        class Divider
                                        {
                                                name = "----- Player Persistence ------------------------------------------------------";
                                                value = "";
                                        };
                                };
                        };
                        class enablePlayerPersistence
                        {
                                displayName = "$STR_ALIVE_player_ENABLE";
                                description = "$STR_ALIVE_player_ENABLE_COMMENT";
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
                        // CREW INFO
                        class CREW_INFO {
                                displayName = "";
                                class Values
                                {
                                        class Divider
                                        {
                                                name = "----- Crew Info ------------------------------------------------------";
                                                value = "";
                                        };
                                };
                        };
                        class crewinfo_ui_setting
                        {
                                displayName = "$STR_ALIVE_CREWINFO_UI";
                                description = "$STR_ALIVE_CREWINFO_UI_COMMENT";
                                class Values
                                {
                                        class none
                                        {
                                                name = "None";
                                                value = 0;
                                                default = 1;
                                        };
                                        class uiRight
                                        {
                                                name = "Right";
                                                value = 1;
                                        };
                                        class uiLeft
                                        {
                                                name = "Left";
                                                value = 2;
                                        };

                                };
                        };
                        // PLAYER TAGS
                        class PLAYER_TAGS {
                                displayName = "";
                                class Values
                                {
                                        class Divider
                                        {
                                                name = "----- Player Tags ------------------------------------------------------";
                                                value = "";
                                        };
                                };
                        };
                        class playertags_style_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_STYLE";
                                description = "$STR_ALIVE_PLAYERTAGS_STYLE_COMMENT";
                                class Values
                                {
                                        class none
                                        {
                                                name = "None";
                                                value = "None";
                                        };
                                        class modern
                                        {
                                                name = "Modern";
                                                value = "modern";
                                                default = 1;
                                        };
                                        class current
                                        {
                                                name = "Default";
                                                value = "default";
                                        };
                                };
                        };

                        class playertags_onview_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_ONVIEW";
                                description = "$STR_ALIVE_PLAYERTAGS_ONVIEW_COMMENT";
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

                        class playertags_displayrank_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_RANK";
                                description = "$STR_ALIVE_PLAYERTAGS_RANK_COMMENT";
                                class Values
                                {

                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;

                                        };
                                };
                        };

                        class playertags_displaygroup_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_GROUP";
                                description = "$STR_ALIVE_PLAYERTAGS_GROUP_COMMENT";
                                class Values
                                {

                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;

                                        };
                                };
                        };

                         class playertags_invehicle_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_INVEHICLE";
                                description = "$STR_ALIVE_PLAYERTAGS_INVEHICLE_COMMENT";
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

                        class playertags_targets_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_TARGETS";
                                description = "$STR_ALIVE_PLAYERTAGS_TARGETS_COMMENT";
                                defaultValue = "[""CAManBase"", ""Car"", ""Tank"", ""StaticWeapon"", ""Helicopter"", ""Plane""]";
                                typeName = "ARRAY";
                        };

                        class playertags_distance_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_DISTANCE";
                                description = "$STR_ALIVE_PLAYERTAGS_DISTANCE_COMMENT";
                                defaultValue = 20;
                                typeName = "NUMBER";
                        };

                        class playertags_tolerance_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_TOLERANCE";
                                description = "$STR_ALIVE_PLAYERTAGS_TOLERANCE_COMMENT";
                                defaultValue = 0.75;
                                typeName = "NUMBER";
                        };

                        class playertags_scale_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_SCALE";
                                description = "$STR_ALIVE_PLAYERTAGS_SCALE_COMMENT";
                                defaultValue = 0.65;
                                typeName = "NUMBER";
                        };


                        class playertags_height_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_HEIGHT";
                                description = "$STR_ALIVE_PLAYERTAGS_HEIGHT_COMMENT";
                                defaultValue = 1.1;
                                typeName = "NUMBER";
                        };


                        class playertags_namecolour_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_NAMECOLOUR";
                                description = "$STR_ALIVE_PLAYERTAGS_NAMECOLOUR_COMMENT";
                                defaultValue = "#FFFFFF"; // white
                                typeName = "STRING";
                        };

                        class playertags_groupcolour_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_GROUPCOLOUR";
                                description = "$STR_ALIVE_PLAYERTAGS_GROUPCOLOUR_COMMENT";
                                defaultValue = "#A8F000"; // green
                                typeName = "STRING";
                        };

                        class playertags_thisgroupleadernamecolour_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_THISGROUPLEADERNAMECOLOUR";
                                description = "$STR_ALIVE_PLAYERTAGS_THISGROUPLEADERNAMECOLOUR_COMMENT";
                                defaultValue = "#FFB300"; // yellow
                                typeName = "STRING";
                        };

                        class playertags_thisgroupcolour_setting
                        {
                                displayName = "$STR_ALIVE_PLAYERTAGS_THISGROUPCOLOUR";
                                description = "$STR_ALIVE_PLAYERTAGS_THISGROUPCOLOUR_COMMENT";
                                defaultValue = "#009D91"; // cyan
                                typeName = "STRING";
                        };
                };
        };
};
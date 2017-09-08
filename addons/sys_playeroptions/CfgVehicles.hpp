#define MODULE_NAME ALiVE_SYS_playeroptions
#define MVAR(var) DOUBLES(MODULE_NAME,var)

class CfgVehicles
{
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase
        {
            class Edit; // Default edit box (i.e., text input field)
            class Combo; // Default combo box (i.e., drop-down menu)
            class ModuleDescription; // Module description
        };
    };
    class ModuleAliveBase: Module_F
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
        displayName = "$STR_ALIVE_playeroptions";
        function = "ALIVE_fnc_playeroptionsInit";
        functionPriority = 200;
        isGlobal = 2;
        icon = "x\alive\addons\sys_playeroptions\icon_sys_playeroptions.paa";
        picture = "x\alive\addons\sys_playeroptions\icon_sys_playeroptions.paa";
        author = MODULE_AUTHOR;

        class Attributes : AttributesBase
        {
            // MODULE PARAMS
            class MODULE_PARAMS: ALiVE_ModuleSubTitle
            {
                    property = QGVAR(__LINE__);
                    displayName = "MODULE PARAMETERS";
            };
            class debug: Combo
            {
                    property = MVAR(debug);
                    displayName = "$STR_ALIVE_playeroptions_DEBUG";
                    tooltip = "$STR_ALIVE_playeroptions_DEBUG_COMMENT";
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

            // VIEW DISTANCE
            class VIEW_DISTANCE: ALiVE_ModuleSubTitle
            {
                    property = MVAR(VIEW_DISTANCE);
                    displayName = "ViEW DISTANCE PARAMETERS";
            };
            class maxVD: Edit
            {
                    property = MVAR(maxVD);
                    displayName = "$STR_ALIVE_VDIST_MAX";
                    tooltip = "$STR_ALIVE_VDIST_MAX_COMMENT";
                    defaultvalue = """20000""";
            };
            class minVD: Edit
            {
                    property = MVAR(minVD);
                    displayName = "$STR_ALIVE_VDIST_MIN";
                    tooltip = "$STR_ALIVE_VDIST_MIN_COMMENT";
                    defaultvalue = """500""";
            };
            class maxTG: Edit
            {
                    property = MVAR(maxTG);
                    displayName = "$STR_ALIVE_TGRID_MAX";
                    tooltip = "$STR_ALIVE_TGRID_MAX_COMMENT";
                    defaultvalue = """5""";
            };
            class minTG: Edit
            {
                    property = MVAR(minTG);
                    displayName = "$STR_ALIVE_TGRID_MIN";
                    tooltip = "$STR_ALIVE_TGRID_MIN_COMMENT";
                    defaultvalue = """1""";
            };

            // PERSISTENCE
            class PERSISTENCE: ALiVE_ModuleSubTitle
            {
                    property = QGVAR(__LINE__);
                    displayName = "PLAYER PERSISTENCE PARAMETERS";
            };
            class enablePlayerPersistence: Combo
            {
                    property = MVAR(enablePlayerPersistence);
                    displayName = "$STR_ALIVE_player_ENABLE";
                    tooltip = "$STR_ALIVE_player_ENABLE_COMMENT";
                    defaultValue = """true""";
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
            class allowReset: Combo
            {
                    property = MVAR(allowReset);
                    displayName = "$STR_ALIVE_player_allowReset";
                    tooltip = "$STR_ALIVE_player_allowReset_COMMENT";
                    defaultValue = """true""";
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
            class allowManualSave: Combo
            {
                    property = MVAR(allowManualSave);
                    displayName = "$STR_ALIVE_player_allowManualSave";
                    tooltip = "$STR_ALIVE_player_allowManualSave_COMMENT";
                    defaultValue = """true""";
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
            class allowDiffClass: Combo
            {
                    property = MVAR(allowDiffClass);
                    displayName = "$STR_ALIVE_player_allowDiffClass";
                    tooltip = "$STR_ALIVE_player_allowDiffClass_COMMENT";
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
            class saveLoadout: Combo
            {
                    property = MVAR(saveLoadout);
                    displayName = "$STR_ALIVE_player_SAVELOADOUT";
                    tooltip = "$STR_ALIVE_player_SAVELOADOUT_COMMENT";
                    defaultValue = """true""";
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
            class saveAmmo: Combo
            {
                    property = MVAR(saveAmmo);
                    displayName = "$STR_ALIVE_player_SAVEAMMO";
                    tooltip = "$STR_ALIVE_player_SAVEAMMO_COMMENT";
                    defaultValue = """true""";
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
            class saveHealth: Combo
            {
                    property = MVAR(saveHealth);
                    displayName = "$STR_ALIVE_player_SAVEHEALTH";
                    tooltip = "$STR_ALIVE_player_SAVEHEALTH_COMMENT";
                    defaultValue = """true""";
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
            class savePosition: Combo
            {
                    property = MVAR(savePosition);
                    displayName = "$STR_ALIVE_player_SAVEPOSITION";
                    tooltip = "$STR_ALIVE_player_SAVEPOSITION_COMMENT";
                    defaultValue = """true""";
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
            class saveScores: Combo
            {
                    property = MVAR(saveScores);
                    displayName = "$STR_ALIVE_player_SAVESCORES";
                    tooltip = "$STR_ALIVE_player_SAVESCORES_COMMENT";
                    defaultValue = """true""";
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
            class storeToDB: Combo
            {
                    property = MVAR(storeToDB);
                    displayName = "$STR_ALIVE_player_storeToDB";
                    tooltip = "$STR_ALIVE_player_storeToDB_COMMENT";
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
            class autoSaveTime: Edit
            {
                    property = MVAR(autoSaveTime);
                    displayName = "$STR_ALIVE_player_autoSaveTime";
                    tooltip = "$STR_ALIVE_player_autoSaveTime_COMMENT";
                    defaultValue = """0""";
            };

            // CREW INFO
            class CREW_INFO: ALiVE_ModuleSubTitle
            {
                    property = QGVAR(__LINE__);
                    displayName = "CREW INFO PARAMETERS";
            };
            class crewinfo_ui_setting: Combo
            {
                    property = MVAR(crewinfo_ui_setting);
                    displayName = "$STR_ALIVE_CREWINFO_UI";
                    tooltip = "$STR_ALIVE_CREWINFO_UI_COMMENT";
                    defaultValue = """0""";
                    class Values
                    {
                            class none
                            {
                                    name = "None";
                                    value = "0";

                            };
                            class uiRight
                            {
                                    name = "Right";
                                    value = "1";
                            };
                            class uiLeft
                            {
                                    name = "Left";
                                    value = "2";
                            };

                    };
            };

            // PLAYER TAGS
            class PLAYER_TAGS: ALiVE_ModuleSubTitle
            {
                    property = QGVAR(__LINE__);
                    displayName = "PLAYER TAGS PARAMETERS";
            };
            class playertags_style_setting: Combo
            {
                    property = MVAR(playertags_style_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_STYLE";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_STYLE_COMMENT";
                    defaultValue = """modern""";
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

                            };
                            class current
                            {
                                    name = "Default";
                                    value = "default";
                            };
                    };
            };
            class playertags_onview_setting: Combo
            {
                    property = MVAR(playertags_onview_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_ONVIEW";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_ONVIEW_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {

                            class No
                            {
                                    name = "No";
                                    value = "false";

                            };
                            class Yes
                            {
                                    name = "Yes";
                                    value = "true";
                            };
                    };
            };
            class playertags_displayrank_setting: Combo
            {
                    property = MVAR(playertags_displayrank_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_RANK";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_RANK_COMMENT";
                    defaultValue = """true""";
                    class Values
                    {

                            class No
                            {
                                    name = "No";
                                    value = "false";
                            };
                            class Yes
                            {
                                    name = "Yes";
                                    value = "true";


                            };
                    };
            };
            class playertags_displaygroup_setting: Combo
            {
                    property = MVAR(playertags_displaygroup_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_GROUP";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_GROUP_COMMENT";
                    defaultValue = """true""";
                    class Values
                    {

                            class No
                            {
                                    name = "No";
                                    value = "false";
                            };
                            class Yes
                            {
                                    name = "Yes";
                                    value = "true";


                            };
                    };
            };
            class playertags_invehicle_setting: Combo
            {
                    property = MVAR(playertags_invehicle_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_INVEHICLE";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_INVEHICLE_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {

                            class No
                            {
                                    name = "No";
                                    value = "false";

                            };
                            class Yes
                            {
                                    name = "Yes";
                                    value = "true";

                            };
                    };
            };
            class playertags_targets_setting: Edit
            {
                    property = MVAR(playertags_targets_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_TARGETS";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_TARGETS_COMMENT";
                    defaultValue = """['CAManBase', 'Car', 'Tank', 'StaticWeapon', 'Helicopter', 'Plane']""";
            };
            class playertags_distance_setting: Edit
            {
                    property = MVAR(playertags_distance_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_DISTANCE";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_DISTANCE_COMMENT";
                    defaultValue = "20";
                    typeName = "NUMBER";
            };
            class playertags_tolerance_setting: Edit
            {
                    property = MVAR(playertags_tolerance_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_TOLERANCE";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_TOLERANCE_COMMENT";
                    defaultValue = "0.75";
                    typeName = "NUMBER";
            };
            class playertags_scale_setting: Edit
            {
                    property = MVAR(playertags_scale_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_SCALE";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_SCALE_COMMENT";
                    defaultValue = "0.65";
                    typeName = "NUMBER";
            };
            class playertags_height_setting: Edit
            {
                    property = MVAR(playertags_height_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_HEIGHT";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_HEIGHT_COMMENT";
                    defaultValue = "1.1";
                    typeName = "NUMBER";
            };
            class playertags_namecolour_setting: Edit
            {
                    property = MVAR(playertags_namecolour_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_NAMECOLOUR";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_NAMECOLOUR_COMMENT";
                    defaultValue = """#FFFFFF"""; // white
                    typeName = "STRING";
            };
            class playertags_groupcolour_setting: Edit
            {
                    property = MVAR(playertags_groupcolour_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_GROUPCOLOUR";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_GROUPCOLOUR_COMMENT";
                    defaultValue = """#A8F000"""; // green
                    typeName = "STRING";
            };
            class playertags_thisgroupleadernamecolour_setting: Edit
            {
                    property = MVAR(playertags_thisgroupleadernamecolour_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_THISGROUPLEADERNAMECOLOUR";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_THISGROUPLEADERNAMECOLOUR_COMMENT";
                    defaultValue = """#FFB300"""; // yellow
                    typeName = "STRING";
            };
            class playertags_thisgroupcolour_setting: Edit
            {
                    property = MVAR(playertags_thisgroupcolour_setting);
                    displayName = "$STR_ALIVE_PLAYERTAGS_THISGROUPCOLOUR";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_THISGROUPCOLOUR_COMMENT";
                    defaultValue = """#009D91"""; // cyan
                    typeName = "STRING";
            };

            class ModuleDescription: ModuleDescription{};
        };

        class ModuleDescription: ModuleDescription
        {
            description[] = {
                    "$STR_ALIVE_playeroptions_COMMENT",
                    "",
                    "$STR_ALIVE_playeroptions_USAGE"
            };
            sync[] = {};
        };
    };
};
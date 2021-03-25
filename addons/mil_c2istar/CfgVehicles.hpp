class CfgVehicles {
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
        class ADDON: ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_C2ISTAR";
                function = "ALIVE_fnc_C2ISTARInit";
                author = MODULE_AUTHOR;
                functionPriority = 150;
                isGlobal = 1;
                icon = "x\alive\addons\mil_C2ISTAR\icon_mil_C2.paa";
                picture = "x\alive\addons\mil_C2ISTAR\icon_mil_C2.paa";
                class Attributes : AttributesBase
                {
                    class MODULE_PARAMS: ALiVE_ModuleSubTitle
                    {
                            property = QGVAR(__LINE__);
                            displayName = "MODULE PARAMETERS";
                    };
                    class debug : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_debug";
                            displayName = "$STR_ALIVE_C2ISTAR_DEBUG";
                            tooltip = "$STR_ALIVE_C2ISTAR_DEBUG_COMMENT";
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
                    class c2_item : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_c2_item";
                            displayName = "$STR_ALIVE_C2ISTAR_ALLOW";
                            tooltip = "$STR_ALIVE_C2ISTAR_ALLOW_COMMENT";
                            defaultValue = """LaserDesignator""";
                    };
                    // TASKING
                    class TASKING : ALiVE_ModuleSubTitle
                    {
                            property = QGVAR(__LINE__);
                            displayName = " TASKING PARAMETERS";
                    };
                    class persistent : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_persistent";
                            displayName = "$STR_ALIVE_C2ISTAR_PERSISTENT";
                            tooltip = "$STR_ALIVE_C2ISTAR_PERSISTENT_COMMENT";
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
                    class autoGenerateBlufor : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateBlufor";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR_COMMENT";
                            defaultValue = """None""";
                            class Values
                            {
                                    class None
                                    {
                                            name = "None";
                                            value = "None";
                                    };
                                    class Strategic
                                    {
                                            name = "Strategic";
                                            value = "Strategic";
                                    };
                                    class Constant
                                    {
                                            name = "Constant";
                                            value = "Constant";
                                    };
                            };
                    };
                    class autoGenerateBluforFaction : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateBluforFaction";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR_FACTION";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR_FACTION_COMMENT";
                            defaultValue = """BLU_F""";
                    };
                    class autoGenerateBluforEnemyFaction : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateBluforEnemyFaction";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR_ENEMY_FACTION";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR_ENEMY_FACTION_COMMENT";
                            defaultValue = """OPF_F""";
                    };
                    class autoGenerateOpfor : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateOpfor";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR_COMMENT";
                            defaultValue = """None""";
                            class Values
                            {
                                    class None
                                    {
                                            name = "None";
                                            value = "None";
                                    };
                                    class Strategic
                                    {
                                            name = "Strategic";
                                            value = "Strategic";
                                    };
                                    class Constant
                                    {
                                            name = "Constant";
                                            value = "Constant";
                                    };
                            };
                    };
                    class autoGenerateOpforFaction : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateOpforFaction";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR_FACTION";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR_FACTION_COMMENT";
                            defaultValue = """OPF_F""";
                    };
                    class autoGenerateOpforEnemyFaction : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateOpforEnemyFaction";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR_ENEMY_FACTION";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR_ENEMY_FACTION_COMMENT";
                            defaultValue = """BLU_F""";
                    };
                    class autoGenerateIndfor : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateIndfor";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR_COMMENT";
                            defaultValue = """None""";
                            class Values
                            {
                                    class None
                                    {
                                            name = "None";
                                            value = "None";
                                    };
                                    class Strategic
                                    {
                                            name = "Strategic";
                                            value = "Strategic";
                                    };
                                    class Constant
                                    {
                                            name = "Constant";
                                            value = "Constant";
                                    };
                            };
                    };
                    class autoGenerateIndforFaction : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateIndforFaction";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR_FACTION";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR_FACTION_COMMENT";
                            defaultValue = """IND_F""";
                    };
                    class autoGenerateIndforEnemyFaction : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateIndforEnemyFaction";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR_ENEMY_FACTION";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR_ENEMY_FACTION_COMMENT";
                            defaultValue = """OPF_F""";
                    };
                    // GROUP MANAGEMENT
                    class GROUP_MANAGEMENT: ALiVE_ModuleSubTitle
                    {
                            property = QGVAR(__LINE__);
                            displayName = " GROUP MANAGEMENT PARAMETERS";
                    };
                    class gmLimit : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_gmLimit";
                            displayName = "$STR_ALIVE_C2ISTAR_GM_LIMIT";
                            tooltip = "$STR_ALIVE_C2ISTAR_GM_LIMIT_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                    class SIDE
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_GM_LIMIT_SIDE";
                                            value = "SIDE";

                                    };
                                    class FACTION
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_GM_LIMIT_FACTION";
                                            value = "FACTION";
                                    };
                            };
                    };
                    // OPERATIONS
                    class OPERATIONS_TABLET: ALiVE_ModuleSubTitle
                    {
                            property = QGVAR(__LINE__);
                            displayName = " OPERATIONS TABLET PARAMETERS";
                    };
                    class scomOpsLimit : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_scomOpsLimit";
                            displayName = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT";
                            tooltip = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                    class SIDE
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_SIDE";
                                            value = "SIDE";
                                    };
                                    class FACTION
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_FACTION";
                                            value = "FACTION";
                                    };
                                    class ALL
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_ALL";
                                            value = "ALL";
                                    };
                            };
                    };
                    class scomOpsAllowSpectate : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_scomOpsAllowSpectate";
                            displayName = "$STR_ALIVE_C2ISTAR_SCOM_OPS_ALLOW_SPECTATE";
                            tooltip = "$STR_ALIVE_C2ISTAR_SCOM_OPS_ALLOW_SPECTATE_COMMENT";
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
                    class scomOpsAllowInstantJoin : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_scomOpsAllowInstantJoin";
                            displayName = "$STR_ALIVE_C2ISTAR_SCOM_OPS_ALLOW_JOIN";
                            tooltip = "$STR_ALIVE_C2ISTAR_SCOM_OPS_ALLOW_JOIN_COMMENT";
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
                    class scomOpsAllowImageIntelligence : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_scomOpsAllowImageIntelligence";
                            displayName = "$STR_ALIVE_C2ISTAR_SCOM_OPS_ALLOW_IMAGE_INTELLIGENCE";
                            tooltip = "$STR_ALIVE_C2ISTAR_SCOM_OPS_IMAGE_INTELLIGENCE_COMMENT";
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
                    // INTEL TABLET
                    class INTEL_TABLET: ALiVE_ModuleSubTitle
                    {
                            property = QGVAR(__LINE__);
                            displayName = " INTEL TABLET PARAMETERS";
                    };
                    class scomIntelLimit : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_scomIntelLimit";
                            displayName = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT";
                            tooltip = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                    class SIDE
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_SIDE";
                                            value = "SIDE";
                                    };
                                    class FACTION
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_FACTION";
                                            value = "FACTION";
                                    };
                                    class ALL
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_ALL";
                                            value = "ALL";
                                    };
                            };
                    };
                    // INTEL
                    class INTEL : ALiVE_ModuleSubTitle
                    {
                            property = QGVAR(__LINE__);
                            displayName = " GLOBAL INTEL PARAMETERS";
                    };
                    class displayIntel : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_displayIntel";
                            displayName = "$STR_ALIVE_C2ISTAR_DISPLAY_INTEL";
                            tooltip = "$STR_ALIVE_C2ISTAR_DISPLAY_INTEL_COMMENT";
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
                    class displayDiarySpotrep : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_displayDiarySpotrep";
                            displayName = "$STR_ALIVE_C2ISTAR_SPOTREP_DIARY_ENTRIES";
                            tooltip = "$STR_ALIVE_C2ISTAR_SPOTREP_DIARY_ENTRIES_COMMENT";
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
                    class intelChance : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_intelChance";
                            displayName = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE";
                            tooltip = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_COMMENT";
                            defaultValue = """1""";
                            class Values
                            {
                                    class LOW
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_LOW";
                                            value = "0.1";
                                    };
                                    class MEDIUM
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_MEDIUM";
                                            value = "0.2";
                                    };
                                    class HIGH
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_HIGH";
                                            value = "0.4";
                                    };
                                    class TOTAL
                                    {
                                            name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_TOTAL";
                                            value = "1";
                                    };
                            };
                    };
                    class friendlyIntel : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_friendlyIntel";
                            displayName = "$STR_ALIVE_C2ISTAR_FRIENDLY_INTEL";
                            tooltip = "$STR_ALIVE_C2ISTAR_FRIENDLY_INTEL_COMMENT";
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
                    class friendlyIntelRadius : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_friendlyIntelRadius";
                            displayName = "$STR_ALIVE_C2ISTAR_FRIENDLY_INTEL_RADIUS";
                            tooltip = "$STR_ALIVE_C2ISTAR_FRIENDLY_INTEL_RADIUS_COMMENT";
                            defaultValue = """2000""";
                    };
                    class displayMilitarySectors : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_displayMilitarySectors";
                            displayName = "$STR_ALIVE_C2ISTAR_DISPLAY_MIL_SECTORS";
                            tooltip = "$STR_ALIVE_C2ISTAR_DISPLAY_MIL_SECTORS_COMMENT";
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
                    class displayTraceGrid : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_displayTraceGrid";
                            displayName = "$STR_ALIVE_C2ISTAR_DISPLAY_TRACEGRID";
                            tooltip = "$STR_ALIVE_C2ISTAR_DISPLAY_TRACEGRID_COMMENT";
                            defaultValue = """None""";
                            class Values
                            {
                                    class None
                                    {
                                            name = "None";
                                            value = "None";
                                    };
                                    class Solid
                                    {
                                            name = "Solid";
                                            value = "Solid";
                                    };
                                    class Horizontal
                                    {
                                            name = "Horizontal";
                                            value = "Horizontal";
                                    };
                                    class Vertical
                                    {
                                            name = "Vertical";
                                            value = "Vertical";
                                    };
                                    class FDiagonal
                                    {
                                            name = "F-Diagonal";
                                            value = "FDiagonal";
                                    };
                                    class BDiagonal
                                    {
                                            name = "B-Diagonal";
                                            value = "BDiagonal";
                                    };
                                    class Cross
                                    {
                                            name = "Cross";
                                            value = "Cross";
                                    };
                            };
                    };
                    class displayPlayerSectors : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_displayPlayerSectors";
                            displayName = "$STR_ALIVE_C2ISTAR_DISPLAY_PLAYER_SECTORS";
                            tooltip = "$STR_ALIVE_C2ISTAR_DISPLAY_PLAYER_SECTORS_COMMENT";
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
                    class runEvery: Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_runEvery";
                            displayName = "$STR_ALIVE_C2ISTAR_RUN_EVERY";
                            tooltip = "$STR_ALIVE_C2ISTAR_RUN_EVERY_COMMENT";
                            defaultValue = "2";
                            typeName = "NUMBER";
                    };
                    class ModuleDescription: ModuleDescription{};
                };

                class ModuleDescription: ModuleDescription
                {
                    //description = "$STR_ALIVE_C2ISTAR_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_C2ISTAR_COMMENT",
                            "",
                            "$STR_ALIVE_C2ISTAR_USAGE"
                    };
                    sync[] = {}; // Array of synced entities (can contain base classes)
                };
        };

};

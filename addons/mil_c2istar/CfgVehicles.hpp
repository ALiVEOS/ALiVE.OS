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
                    class taskMinDistance : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_taskMinDistance";
                            displayName = "Minimum Task Distance (m)";
                            tooltip = "Optional mission-wide minimum travel distance for auto-picked Short/Medium/Long generated task locations. Set to 0 to disable.";
                            defaultValue = """0""";
                            typeName = "NUMBER";
                    };
                    class vipPanicTimeout : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_vipPanicTimeout";
                            displayName = "VIP Panic Timeout (s)";
                            tooltip = "How long a panicked VIP can stay uncontrolled before the escort task fails.";
                            defaultValue = """180""";
                            typeName = "NUMBER";
                    };
                    class CIVIC_STATE: ALiVE_ModuleSubTitle
                    {
                            property = QGVAR(__LINE__);
                            displayName = " CIVIC STATE PARAMETERS";
                    };
                    class civicStateEnabled : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicStateEnabled";
                            displayName = "Enable Civic-State COIN Model";
                            tooltip = "Enable the multi-axis trust/security/services settlement model used by the fork's Hearts and Minds features.";
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
                    class civicTrustSuccessMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicTrustSuccessMultiplier";
                            displayName = "Trust Success Multiplier";
                            tooltip = "Multiplier applied to trust gains from successful Hearts and Minds tasks.";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicTrustFailureMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicTrustFailureMultiplier";
                            displayName = "Trust Failure Multiplier";
                            tooltip = "Multiplier applied to trust losses from failed Hearts and Minds tasks or backlash.";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicSecuritySuccessMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicSecuritySuccessMultiplier";
                            displayName = "Security Success Multiplier";
                            tooltip = "Multiplier applied to security gains from successful Hearts and Minds tasks.";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicSecurityFailureMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicSecurityFailureMultiplier";
                            displayName = "Security Failure Multiplier";
                            tooltip = "Multiplier applied to security losses from failed Hearts and Minds tasks or backlash.";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicServicesSuccessMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicServicesSuccessMultiplier";
                            displayName = "Services Success Multiplier";
                            tooltip = "Multiplier applied to services gains from successful Hearts and Minds tasks.";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicServicesFailureMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicServicesFailureMultiplier";
                            displayName = "Services Failure Multiplier";
                            tooltip = "Multiplier applied to services losses from failed Hearts and Minds tasks or backlash.";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicCooldownMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicCooldownMultiplier";
                            displayName = "Civic Cooldown Multiplier";
                            tooltip = "Multiplier applied to Hearts and Minds task cooldowns for the civic-state model.";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicDuplicateTaskPenalty : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicDuplicateTaskPenalty";
                            displayName = "Duplicate Task Penalty";
                            tooltip = "Penalty strength applied when the same Hearts and Minds task repeats in a settlement.";
                            defaultValue = """0.15""";
                            typeName = "NUMBER";
                    };
                    class civicEnabledTaskFamilies : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicEnabledTaskFamilies";
                            displayName = "Enabled Civic Task Families";
                            tooltip = "Comma-separated list of Hearts and Minds task types allowed for civic-state generation. Use task type ids with no spaces.";
                            defaultValue = """AidDelivery,SupplyConvoy,MeetLocalLeader,VIPEscort,SecureCommunityEvent,RepairCriticalService,MedicalOutreach,CheckpointPartnership,InformantExfiltration,MarketReopening""";
                    };
                    class civicTaskWeights : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicTaskWeights";
                            displayName = "Civic Task Weights";
                            tooltip = "Comma-separated TaskType=Weight pairs used by civic-state task selection. Use no spaces.";
                            defaultValue = """AidDelivery=1,SupplyConvoy=1,MeetLocalLeader=1,VIPEscort=1,SecureCommunityEvent=1,RepairCriticalService=1,MedicalOutreach=1,CheckpointPartnership=1,InformantExfiltration=1,MarketReopening=1""";
                    };
                    class civicDebugIntel : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicDebugIntel";
                            displayName = "Show Civic Debug Intel";
                            tooltip = "Append civic-state trust/security/services summaries to generated Hearts and Minds task descriptions.";
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
                    class opcomIntelSides : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_opcomIntelSides";
                            displayName = "$STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES";
                            tooltip = "$STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES_COMMENT";
                            typeName = "STRING";
                            defaultValue = """""";
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

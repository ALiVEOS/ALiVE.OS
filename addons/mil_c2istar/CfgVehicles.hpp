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
                    // ---- Module parameters ----------------------------------------------
                    class HDR_MODULE : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_HDR_MODULE"; displayName = "MODULE PARAMETERS"; };
                    class debug : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_debug";
                            displayName = "$STR_ALIVE_C2ISTAR_DEBUG";
                            tooltip = "$STR_ALIVE_C2ISTAR_DEBUG_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No  { name = "No";  value = "false"; };
                            };
                    };
                    class c2_item
                    {
                            property     = "ALiVE_MIL_C2ISTAR_c2_item";
                            displayName  = "$STR_ALIVE_C2ISTAR_ALLOW";
                            tooltip      = "$STR_ALIVE_C2ISTAR_ALLOW_COMMENT";
                            control      = "ALiVE_C2ISTARAccessItemsChoice";
                            typeName     = "STRING";
                            expression   = "_this setVariable ['c2_item', _value];";
                            defaultValue = """LaserDesignators""";
                    };

                    // ---- Faction filters ------------------------------------------------
                    class HDR_FACTION_FILTERS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_HDR_FACTION_FILTERS"; displayName = "FACTION FILTERS"; };
                    class filterEnemyFactions : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_filterEnemyFactions";
                            displayName = "$STR_ALIVE_C2ISTAR_FILTER_ENEMY_FACTIONS";
                            tooltip = "$STR_ALIVE_C2ISTAR_FILTER_ENEMY_FACTIONS_COMMENT";
                            defaultValue = """true""";
                            class Values
                            {
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No  { name = "No";  value = "false"; };
                            };
                    };

                    // ---- Auto-generated tasks ------------------------------------------
                    class HDR_AUTO_TASKS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_HDR_AUTO_TASKS"; displayName = "AUTO-GENERATED TASKS"; };
                    class persistent : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_persistent";
                            displayName = "$STR_ALIVE_C2ISTAR_PERSISTENT";
                            tooltip = "$STR_ALIVE_C2ISTAR_PERSISTENT_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                    class No  { name = "No";  value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
                            };
                    };
                    class taskMinDistance : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_taskMinDistance";
                            displayName = "$STR_ALIVE_C2ISTAR_TASK_MIN_DISTANCE";
                            tooltip = "$STR_ALIVE_C2ISTAR_TASK_MIN_DISTANCE_COMMENT";
                            defaultValue = """0""";
                            typeName = "NUMBER";
                    };
                    class vipPanicTimeout : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_vipPanicTimeout";
                            displayName = "$STR_ALIVE_C2ISTAR_VIP_PANIC_TIMEOUT";
                            tooltip = "$STR_ALIVE_C2ISTAR_VIP_PANIC_TIMEOUT_COMMENT";
                            defaultValue = """180""";
                            typeName = "NUMBER";
                    };
                    class taskAoRadius : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_taskAoRadius";
                            displayName = "$STR_ALIVE_C2ISTAR_TASK_AO_RADIUS";
                            tooltip = "$STR_ALIVE_C2ISTAR_TASK_AO_RADIUS_COMMENT";
                            defaultValue = """0""";
                            typeName = "NUMBER";
                    };

                    class SPACER_AUTOTASK_DEFAULTS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_SPACER_AUTOTASK_DEFAULTS"; displayName = " "; };
                    class autoGenerateBlufor : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateBlufor";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_BLUFOR_COMMENT";
                            defaultValue = """None""";
                            class Values
                            {
                                    class None      { name = "None";      value = "None"; };
                                    class Strategic { name = "Strategic"; value = "Strategic"; };
                                    class Constant  { name = "Constant";  value = "Constant"; };
                            };
                    };
                    class autoGenerateOpfor : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateOpfor";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_OPFOR_COMMENT";
                            defaultValue = """None""";
                            class Values
                            {
                                    class None      { name = "None";      value = "None"; };
                                    class Strategic { name = "Strategic"; value = "Strategic"; };
                                    class Constant  { name = "Constant";  value = "Constant"; };
                            };
                    };
                    class autoGenerateIndfor : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateIndfor";
                            displayName = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR";
                            tooltip = "$STR_ALIVE_C2ISTAR_AUTOGEN_INDFOR_COMMENT";
                            defaultValue = """None""";
                            class Values
                            {
                                    class None      { name = "None";      value = "None"; };
                                    class Strategic { name = "Strategic"; value = "Strategic"; };
                                    class Constant  { name = "Constant";  value = "Constant"; };
                            };
                    };
                    class autoGenerateFactions
                    {
                            property     = "ALiVE_MIL_C2ISTAR_autoGenerateFactions";
                            displayName  = "$STR_ALIVE_C2ISTAR_AUTOGEN_FACTIONS";
                            tooltip      = "$STR_ALIVE_C2ISTAR_AUTOGEN_FACTIONS_COMMENT";
                            control      = "ALiVE_FactionSlotChoice";
                            typeName     = "STRING";
                            expression   = "_this setVariable ['autoGenerateFactions', _value];";
                            defaultValue = """""";
                    };
                    // Legacy per-slot attributes preserved as hidden so the
                    // runtime path in fnc_C2ISTAR.sqf (which reads each by
                    // name) keeps working unchanged. The consolidated picker
                    // above writes to each of these via the SAVE handler.
                    class autoGenerateBluforFaction
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateBluforFaction";
                            displayName = "";
                            control = "ALiVE_HiddenAttribute";
                            typeName = "STRING";
                            expression = "_this setVariable ['autoGenerateBluforFaction', _value];";
                            defaultValue = """BLU_F""";
                    };
                    class autoGenerateBluforEnemyFaction
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateBluforEnemyFaction";
                            displayName = "";
                            control = "ALiVE_HiddenAttribute";
                            typeName = "STRING";
                            expression = "_this setVariable ['autoGenerateBluforEnemyFaction', _value];";
                            defaultValue = """OPF_F""";
                    };
                    class autoGenerateOpforFaction
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateOpforFaction";
                            displayName = "";
                            control = "ALiVE_HiddenAttribute";
                            typeName = "STRING";
                            expression = "_this setVariable ['autoGenerateOpforFaction', _value];";
                            defaultValue = """OPF_F""";
                    };
                    class autoGenerateOpforEnemyFaction
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateOpforEnemyFaction";
                            displayName = "";
                            control = "ALiVE_HiddenAttribute";
                            typeName = "STRING";
                            expression = "_this setVariable ['autoGenerateOpforEnemyFaction', _value];";
                            defaultValue = """BLU_F""";
                    };
                    class autoGenerateIndforFaction
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateIndforFaction";
                            displayName = "";
                            control = "ALiVE_HiddenAttribute";
                            typeName = "STRING";
                            expression = "_this setVariable ['autoGenerateIndforFaction', _value];";
                            defaultValue = """IND_F""";
                    };
                    class autoGenerateIndforEnemyFaction
                    {
                            property = "ALiVE_MIL_C2ISTAR_autoGenerateIndforEnemyFaction";
                            displayName = "";
                            control = "ALiVE_HiddenAttribute";
                            typeName = "STRING";
                            expression = "_this setVariable ['autoGenerateIndforEnemyFaction', _value];";
                            defaultValue = """OPF_F""";
                    };

                    class customStaticDataMode : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_customStaticDataMode";
                            displayName = "$STR_ALIVE_C2_CUSTOM_MODE";
                            tooltip = "$STR_ALIVE_C2_CUSTOM_MODE_COMMENT";
                            defaultValue = """REPLACE""";
                            class Values
                            {
                                    class Replace { name = "Replace"; value = "REPLACE"; default = 1; };
                                    class Append  { name = "Append";  value = "APPEND";  };
                            };
                    };
                    // civicStateEnabled is placed BEFORE customAutoGeneratedTasks
                    // (and before civicEnabledTaskFamilies further down) so the
                    // listbox load handlers can read its state when populating.
                    // When OFF: the 4 civic-only H&M families (MedicalOutreach,
                    // CheckpointPartnership, InformantExfiltration, MarketReopening)
                    // are filtered OUT of both multi-selects. Detailed civic
                    // settings (multipliers, cooldown, weights, enabled-families
                    // listbox) remain grouped under the Civic State header below.
                    class civicStateEnabled : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicStateEnabled";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_ENABLED";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_ENABLED_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                    class No  { name = "No";  value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
                            };
                    };
                    class customAutoGeneratedTasks
                    {
                            property     = "ALiVE_MIL_C2ISTAR_customAutoGeneratedTasks";
                            displayName  = "$STR_ALIVE_C2_CUSTOM_AUTOGEN_TASKS";
                            tooltip      = "$STR_ALIVE_C2_CUSTOM_AUTOGEN_TASKS_COMMENT";
                            control      = "ALiVE_TaskTypeChoice_AutoGenerated";
                            typeName     = "STRING";
                            expression   = "_this setVariable ['customAutoGeneratedTasks', _value];";
                            defaultValue = """""";
                    };

                    // ---- Civic state (Hearts & Minds) ----------------------------------
                    class HDR_CIVIC_STATE : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_HDR_CIVIC_STATE"; displayName = "CIVIC STATE (HEARTS & MINDS)"; };
                    class civicTrustSuccessMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicTrustSuccessMultiplier";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_TRUST_SUCCESS";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_TRUST_SUCCESS_COMMENT";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicTrustFailureMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicTrustFailureMultiplier";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_TRUST_FAILURE";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_TRUST_FAILURE_COMMENT";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicSecuritySuccessMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicSecuritySuccessMultiplier";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_SECURITY_SUCCESS";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_SECURITY_SUCCESS_COMMENT";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicSecurityFailureMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicSecurityFailureMultiplier";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_SECURITY_FAILURE";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_SECURITY_FAILURE_COMMENT";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicServicesSuccessMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicServicesSuccessMultiplier";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_SERVICES_SUCCESS";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_SERVICES_SUCCESS_COMMENT";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicServicesFailureMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicServicesFailureMultiplier";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_SERVICES_FAILURE";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_SERVICES_FAILURE_COMMENT";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };

                    class SPACER_CIVIC_MISC : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_SPACER_CIVIC_MISC"; displayName = " "; };
                    class civicCooldownMultiplier : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicCooldownMultiplier";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_COOLDOWN";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_COOLDOWN_COMMENT";
                            defaultValue = """1""";
                            typeName = "NUMBER";
                    };
                    class civicDuplicateTaskPenalty : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicDuplicateTaskPenalty";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_DUP_PENALTY";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_DUP_PENALTY_COMMENT";
                            defaultValue = """0.15""";
                            typeName = "NUMBER";
                    };
                    class civicEnabledTaskFamilies
                    {
                            property     = "ALiVE_MIL_C2ISTAR_civicEnabledTaskFamilies";
                            displayName  = "$STR_ALIVE_C2ISTAR_CIVIC_FAMILIES";
                            tooltip      = "$STR_ALIVE_C2ISTAR_CIVIC_FAMILIES_COMMENT";
                            control      = "ALiVE_TaskTypeChoice_Civic";
                            typeName     = "STRING";
                            expression   = "_this setVariable ['civicEnabledTaskFamilies', _value];";
                            defaultValue = """AidDelivery,SupplyConvoy,MeetLocalLeader,VIPEscort,SecureCommunityEvent,RepairCriticalService,MedicalOutreach,CheckpointPartnership,InformantExfiltration,MarketReopening""";
                    };
                    class civicTaskWeights : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicTaskWeights";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_WEIGHTS";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_WEIGHTS_COMMENT";
                            defaultValue = """AidDelivery=1,SupplyConvoy=1,MeetLocalLeader=1,VIPEscort=1,SecureCommunityEvent=1,RepairCriticalService=1,MedicalOutreach=1,CheckpointPartnership=1,InformantExfiltration=1,MarketReopening=1""";
                    };
                    class civicDebugIntel : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_civicDebugIntel";
                            displayName = "$STR_ALIVE_C2ISTAR_CIVIC_DEBUG_INTEL";
                            tooltip = "$STR_ALIVE_C2ISTAR_CIVIC_DEBUG_INTEL_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                    class No  { name = "No";  value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
                            };
                    };

                    // ---- Player role scoping -------------------------------------------
                    class HDR_PLAYER_ROLE_SCOPING : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_HDR_PLAYER_ROLE_SCOPING"; displayName = "PLAYER ROLE SCOPING"; };
                    class gmLimit : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_gmLimit";
                            displayName = "$STR_ALIVE_C2ISTAR_GM_LIMIT";
                            tooltip = "$STR_ALIVE_C2ISTAR_GM_LIMIT_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                    class SIDE    { name = "$STR_ALIVE_C2ISTAR_GM_LIMIT_SIDE";    value = "SIDE"; };
                                    class FACTION { name = "$STR_ALIVE_C2ISTAR_GM_LIMIT_FACTION"; value = "FACTION"; };
                            };
                    };

                    class SPACER_ROLE_OPS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_SPACER_ROLE_OPS"; displayName = " "; };
                    class scomOpsLimit : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_scomOpsLimit";
                            displayName = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT";
                            tooltip = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                    class SIDE    { name = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_SIDE";    value = "SIDE"; };
                                    class FACTION { name = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_FACTION"; value = "FACTION"; };
                                    class ALL     { name = "$STR_ALIVE_C2ISTAR_SCOM_OPS_LIMIT_ALL";     value = "ALL"; };
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
                                    class No  { name = "No";  value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
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
                                    class No  { name = "No";  value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
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
                                    class No  { name = "No";  value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
                            };
                    };

                    class SPACER_ROLE_INTEL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_SPACER_ROLE_INTEL"; displayName = " "; };
                    class scomIntelLimit : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_scomIntelLimit";
                            displayName = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT";
                            tooltip = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                    class SIDE    { name = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_SIDE";    value = "SIDE"; };
                                    class FACTION { name = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_FACTION"; value = "FACTION"; };
                                    class ALL     { name = "$STR_ALIVE_C2ISTAR_SCOM_INTEL_LIMIT_ALL";     value = "ALL"; };
                            };
                    };

                    // ---- Global intel ---------------------------------------------------
                    class HDR_GLOBAL_INTEL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_c2istar_HDR_GLOBAL_INTEL"; displayName = "GLOBAL INTEL"; };
                    class opcomIntelSides
                    {
                            property     = "ALiVE_MIL_C2ISTAR_opcomIntelSides";
                            displayName  = "$STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES";
                            tooltip      = "$STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES_COMMENT";
                            control      = "ALiVE_SideChoiceMulti";
                            typeName     = "STRING";
                            expression   = "_this setVariable ['opcomIntelSides', _value];";
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
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No  { name = "No";  value = "false"; };
                            };
                    };
                    class mapIntelVisibility : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_mapIntelVisibility";
                            displayName = "$STR_ALIVE_C2ISTAR_MAP_INTEL_VISIBILITY";
                            tooltip = "$STR_ALIVE_C2ISTAR_MAP_INTEL_VISIBILITY_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                    class SIDE     { name = "$STR_ALIVE_C2ISTAR_MAP_INTEL_VISIBILITY_SIDE";     value = "SIDE"; };
                                    class FACTION  { name = "$STR_ALIVE_C2ISTAR_MAP_INTEL_VISIBILITY_FACTION";  value = "FACTION"; };
                                    class FRIENDLY { name = "$STR_ALIVE_C2ISTAR_MAP_INTEL_VISIBILITY_FRIENDLY"; value = "FRIENDLY"; };
                                    class ALL      { name = "$STR_ALIVE_C2ISTAR_MAP_INTEL_VISIBILITY_ALL";      value = "ALL"; };
                            };
                    };
                    class mapIntelRevealInstallations : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_mapIntelRevealInstallations";
                            displayName = "$STR_ALIVE_C2ISTAR_MAP_INTEL_REVEAL_INSTALLATIONS";
                            tooltip = "$STR_ALIVE_C2ISTAR_MAP_INTEL_REVEAL_INSTALLATIONS_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                    class No  { name = "No";  value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
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
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No  { name = "No";  value = "false"; };
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
                                    class OFF       { name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_OFF";       value = "0"; };
                                    class LOW       { name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_LOW";       value = "0.1"; };
                                    class MEDIUM    { name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_MEDIUM";    value = "0.2"; };
                                    class HIGH      { name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_HIGH";      value = "0.4"; };
                                    class VERY_HIGH { name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_VERY_HIGH"; value = "0.8"; };
                                    class TOTAL     { name = "$STR_ALIVE_C2ISTAR_INTEL_CHANCE_TOTAL";     value = "1"; };
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
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No  { name = "No";  value = "false"; };
                            };
                    };
                    class friendlyIntelRadius : Edit
                    {
                            property = "ALiVE_MIL_C2ISTAR_friendlyIntelRadius";
                            displayName = "$STR_ALIVE_C2ISTAR_FRIENDLY_INTEL_RADIUS";
                            tooltip = "$STR_ALIVE_C2ISTAR_FRIENDLY_INTEL_RADIUS_COMMENT";
                            defaultValue = """2000""";
                            typeName = "NUMBER";
                    };
                    class displayMilitarySectors : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_displayMilitarySectors";
                            displayName = "$STR_ALIVE_C2ISTAR_DISPLAY_MIL_SECTORS";
                            tooltip = "$STR_ALIVE_C2ISTAR_DISPLAY_MIL_SECTORS_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No  { name = "No";  value = "false"; };
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
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No  { name = "No";  value = "false"; };
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
                                    class None       { name = "None";       value = "None"; };
                                    class Solid      { name = "Solid";      value = "Solid"; };
                                    class Horizontal { name = "Horizontal"; value = "Horizontal"; };
                                    class Vertical   { name = "Vertical";   value = "Vertical"; };
                                    class FDiagonal  { name = "F-Diagonal"; value = "FDiagonal"; };
                                    class BDiagonal  { name = "B-Diagonal"; value = "BDiagonal"; };
                                    class Cross      { name = "Cross";      value = "Cross"; };
                            };
                    };
                    class commanderIntelMode : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_commanderIntelMode";
                            displayName = "$STR_ALIVE_C2ISTAR_COP_MODE";
                            tooltip = "$STR_ALIVE_C2ISTAR_COP_MODE_COMMENT";
                            defaultValue = """Off""";
                            class Values
                            {
                                    class Off      { name = "$STR_ALIVE_C2ISTAR_COP_MODE_OFF";      value = "Off"; };
                                    class Basic    { name = "$STR_ALIVE_C2ISTAR_COP_MODE_BASIC";    value = "Basic"; };
                                    class Partial  { name = "$STR_ALIVE_C2ISTAR_COP_MODE_PARTIAL";  value = "Partial"; };
                                    class Full     { name = "$STR_ALIVE_C2ISTAR_COP_MODE_FULL";     value = "Full"; };
                                    class Advanced { name = "$STR_ALIVE_C2ISTAR_COP_MODE_ADVANCED"; value = "Advanced"; };
                            };
                    };
                    class commanderIntelAsymmetric : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_commanderIntelAsymmetric";
                            displayName = "$STR_ALIVE_C2ISTAR_COP_ASYM";
                            tooltip = "$STR_ALIVE_C2ISTAR_COP_ASYM_COMMENT";
                            defaultValue = """false""";
                            class Values
                            {
                                    class No  { name = "$STR_ALIVE_C2ISTAR_COP_ASYM_NO";  value = "false"; };
                                    class Yes { name = "$STR_ALIVE_C2ISTAR_COP_ASYM_YES"; value = "true"; };
                            };
                    };
                    // Legacy Eden attribute preserved as hidden so the migration shim
                    // in fnc_C2ISTAR.sqf can still read its value off existing missions
                    // (a true legacy setting auto-maps to commanderIntelMode="Advanced"
                    // when the new attribute is at its default "Off"). New missions
                    // should configure via commanderIntelMode instead.
                    class enableLiveCommanderIntel
                    {
                            property = "ALiVE_MIL_C2ISTAR_enableLiveCommanderIntel";
                            displayName = "";
                            control = "ALiVE_HiddenAttribute";
                            typeName = "STRING";
                            expression = "_this setVariable ['enableLiveCommanderIntel', _value];";
                            defaultValue = """false""";
                    };
                    class copAnchorDistance : Combo
                    {
                            property = "ALiVE_MIL_C2ISTAR_copAnchorDistance";
                            displayName = "$STR_ALIVE_C2ISTAR_COP_ANCHOR_DISTANCE";
                            tooltip = "$STR_ALIVE_C2ISTAR_COP_ANCHOR_DISTANCE_COMMENT";
                            defaultValue = """1000""";
                            class Values
                            {
                                    class m100
                                    {
                                            name = "100 m";
                                            value = "100";
                                    };
                                    class m200
                                    {
                                            name = "200 m";
                                            value = "200";
                                    };
                                    class m500
                                    {
                                            name = "500 m";
                                            value = "500";
                                    };
                                    class m1000
                                    {
                                            name = "1000 m";
                                            value = "1000";
                                    };
                                    class m3000
                                    {
                                            name = "3000 m";
                                            value = "3000";
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
                            "$STR_ALIVE_C2ISTAR_USAGE",
                            "",
                            "$STR_ALIVE_C2ISTAR_USAGE_MARKERS"
                    };
                    // OPCOM is read by this module's OPCOM-side code path (fnc_OPCOM.sqf ~328-341
                    // iterates synchronizedObjects looking for ALiVE_mil_C2ISTAR to set up the
                    // G2 intel pipeline per-OPCOM). Declare the peer here so Eden's module-info
                    // panel lists it and downstream sync validation treats the edge as legitimate.
                    sync[] = {"ALiVE_mil_OPCOM"};
                    class ALiVE_mil_OPCOM { description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                };
        };

};

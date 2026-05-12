class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; class ALiVE_HiddenAttribute; };
        class ModuleDescription;
    };
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_OPCOM";
                function = "ALIVE_fnc_OPCOMInit";
                author = MODULE_AUTHOR;
                functionPriority = 180;
                isGlobal = 1;
                icon = "x\alive\addons\mil_opcom\icon_mil_opcom.paa";
                picture = "x\alive\addons\mil_opcom\icon_mil_opcom.paa";
                class Attributes : AttributesBase
                {
                        // ---- General --------------------------------------------------------
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_HDR_GENERAL"; displayName = "GENERAL"; };
                        class debug : Combo
                        {
                                property = "ALiVE_mil_opcom_debug";
                                displayName = "$STR_ALIVE_OPCOM_DEBUG";
                                tooltip = "$STR_ALIVE_OPCOM_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class persistent : Combo
                        {
                                property = "ALiVE_mil_opcom_persistent";
                                displayName = "$STR_ALIVE_OPCOM_PERSISTENT";
                                tooltip = "$STR_ALIVE_OPCOM_PERSISTENT_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class No { name = "No"; value = false; default = 1; };
                                    class Yes { name = "Yes"; value = true; };
                                };
                        };
                        class customName : Edit
                        {
                                property = "ALiVE_mil_opcom_customName";
                                displayName = "$STR_ALIVE_OPCOM_NAME";
                                tooltip = "$STR_ALIVE_OPCOM_NAME_COMMENT";
                                defaultValue = """""";
                        };

                        // ---- Control Type ---------------------------------------------------
                        class HDR_CONTROL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_HDR_CONTROL"; displayName = "CONTROL TYPE"; };
                        class controltype : Combo
                        {
                                property = "ALiVE_mil_opcom_controltype";
                                displayName = "$STR_ALIVE_OPCOM_CONTROLTYPE";
                                tooltip = "$STR_ALIVE_OPCOM_CONTROLTYPE_COMMENT";
                                defaultValue = """invasion""";
                                class Values
                                {
                                    class invasion { name = "Invasion"; value = "invasion"; default = 1; };
                                    class occupation { name = "Occupation"; value = "occupation"; };
                                    class asymmetric { name = "Asymmetric"; value = "asymmetric"; };
                                };
                        };
                        class reinforcements : Combo
                        {
                                property = "ALiVE_mil_opcom_reinforcements";
                                displayName = "$STR_ALIVE_OPCOM_REINFORCEMENTS";
                                tooltip = "$STR_ALIVE_OPCOM_REINFORCEMENTS_COMMENT";
                                defaultValue = """0.75""";
                                class Values
                                {
                                    class Aggressive   { name = "Aggressive (90%)";   value = "0.9";  };
                                    class Moderate     { name = "Moderate (75%)";     value = "0.75"; default = 1; };
                                    class Conservative { name = "Conservative (50%)"; value = "0.5";  };
                                };
                        };

                        // ---- Factions -------------------------------------------------------
                        // Phase 4 design:
                        //   - `factions` (multi-select listbox) is the primary
                        //     UI. Inherits ALiVE_FactionChoiceMulti_Military
                        //     directly - control class's Save handler writes
                        //     to logic.factions, matching the attribute name.
                        //     Multi-select Load handler accepts SQF array
                        //     literal AND CSV AND single-faction string for
                        //     backward compat, so old missions that used
                        //     this slot as a free-text Edit (CSV / array)
                        //     load cleanly into the visual ticked state.
                        //   - `factionsManual` (Edit field, NEW attribute and
                        //     property) is the manual override: type extra
                        //     classnames here for mods not currently loaded
                        //     (authoring for someone else's modset) or as a
                        //     free-text supplement to the visual selection
                        //     above. Combined with `factions` at runtime.
                        //
                        // Pre-Phase-4 mil_opcom had separate faction1-faction4
                        // single-faction Combo dropdowns (each with hardcoded
                        // 9-option lists). Those are removed - the multi-
                        // select supersedes them. Missions saved with values
                        // in those four slots will lose those values on first
                        // re-save in this version (the SQM data still exists
                        // but no attribute reads it). Mission-makers re-pick
                        // their factions in the multi-select on first open.
                        //
                        // Multi-select UX hint: Ctrl+click toggles an
                        // individual row in/out of the selection.
                        // Shift+click range-selects. Plain click replaces
                        // the selection with just that one item.
                        class HDR_FACTIONS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_HDR_FACTIONS"; displayName = "FACTIONS"; };
                        class factions
                        {
                                property     = "ALiVE_mil_opcom_factions";
                                displayName  = "$STR_ALIVE_OPCOM_FACTIONS";
                                tooltip      = "Pick one or more factions for this AI Commander to control.\n\nLeft-click = replace selection with just that item.\nCtrl + Left-click = toggle individual item (multi-select).\nShift + Left-click = select range.\n\nList is auto-populated from currently-loaded faction mods. Selections here are combined with the manual override field below at runtime.";
                                // Default-BLU_F variant of FactionChoiceMulti_Military.
                                // Pre-ticks BLU_F in the listbox when the resolved
                                // selection is empty. Mirrors the runtime fallback in
                                // fnc_OPCOM.sqf (warn + default to BLU_F when the
                                // factions list is empty) so the listbox visual state
                                // matches what the runtime is going to use.
                                control      = "ALiVE_FactionChoiceMulti_Military_Default_BLU_F";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['factions', _value];";
                                defaultValue = """[]""";
                        };
                        class factionsManual : Edit
                        {
                                property     = "ALiVE_mil_opcom_factionsManual";
                                displayName  = "Factions (manual override):";
                                tooltip      = "Optional. Type extra faction classnames here for mods not currently loaded but expected at mission time (e.g. when authoring for someone else's modset), or to supplement the visual selection above. Format: SQF array literal like [""rhs_faction_xyz""] or comma-separated like rhs_faction_xyz,uk3cb_faction_abc. Combined (unioned) with the Factions multi-select at runtime.";
                                defaultValue = """""";
                        };
                        // Hidden legacy slots - render no UI but apply
                        // SQM-saved values via expression at module init
                        // so missions that picked factions through the
                        // pre-Phase-4 single-faction dropdowns continue
                        // to work. Runtime in fnc_OPCOM.sqf reads them
                        // alongside the multi-select and manual override.
                        class faction1 : ALiVE_HiddenAttribute
                        {
                                property     = "ALiVE_mil_opcom_faction1";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction1', _value];";
                                defaultValue = """""";
                        };
                        class faction2 : ALiVE_HiddenAttribute
                        {
                                property     = "ALiVE_mil_opcom_faction2";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction2', _value];";
                                defaultValue = """""";
                        };
                        class faction3 : ALiVE_HiddenAttribute
                        {
                                property     = "ALiVE_mil_opcom_faction3";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction3', _value];";
                                defaultValue = """""";
                        };
                        class faction4 : ALiVE_HiddenAttribute
                        {
                                property     = "ALiVE_mil_opcom_faction4";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction4', _value];";
                                defaultValue = """""";
                        };

                        // ---- Objectivest ----------------------------------------
                        class HDR_OBJ : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_HDR_OBJ"; displayName = "OBJECTIVES"; };
                        class simultanObjectives : Edit
                        {
                                property = "ALiVE_mil_opcom_simultanObjectives";
                                displayName = "$STR_ALIVE_OPCOM_SIMULTAN";
                                tooltip = "$STR_ALIVE_OPCOM_SIMULTAN_COMMENT";
                                defaultValue = """10""";
                                typeName = "NUMBER";
                        };
                        // ----  Recruitment ----------------------------------------
                        class ASYM_SET : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_ASYM_SET"; displayName = "ASYMMETRIC SETTINGS"; };
                        class asym_occupation : Combo
                        {
                                property = "ALiVE_mil_opcom_asym_occupation";
                                displayName = "$STR_ALIVE_OPCOM_OCCUPATION";
                                tooltip = "$STR_ALIVE_OPCOM_OCCUPATION_COMMENT";
                                defaultValue = """-100""";
                                class Values
                                {
                                    class unused { name = "Unused"; value = -100; default = 1; };
                                    class low { name = "Low"; value = 25; };
                                    class medium { name = "Medium"; value = 50; };
                                    class high { name = "High"; value = 75; };
                                    class extreme { name = "Extreme"; value = 100; };
                                };
                        };
                        class roadblocks : Combo
                        {
                                property = "ALiVE_mil_opcom_roadblocks";
                                displayName = "$STR_ALIVE_OPCOM_ROADBLOCKS";
                                tooltip = "$STR_ALIVE_OPCOM_ROADBLOCKS_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = 1; default = 1; };
                                    class No { name = "No"; value = 0; };
                                };
                        };
                        class intelchance : Combo
                        {
                                property = "ALiVE_mil_opcom_intelchance";
                                displayName = "$STR_ALIVE_OPCOM_INTELCHANCE";
                                tooltip = "$STR_ALIVE_OPCOM_INTELCHANCE_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                    class none { name = "None"; value = 0; default = 1; };
                                    class seldom { name = "Seldom"; value = 5; };
                                    class often { name = "Often"; value = 10; };
                                };
                        };
                        class asym_friendlyDisableInstallations : Combo
                        {
                                property = "ALiVE_mil_opcom_asym_friendlyDisableInstallations";
                                displayName = "$STR_ALIVE_OPCOM_ASYM_FRIENDLY_DISABLE";
                                tooltip = "$STR_ALIVE_OPCOM_ASYM_FRIENDLY_DISABLE_COMMENT";
                                typeName = "STRING";
                                defaultValue = """proximity""";
                                class Values
                                {
                                    class off       { name = "$STR_ALIVE_OPCOM_ASYM_FRIENDLY_DISABLE_OFF";       value = "off"; };
                                    class proximity { name = "$STR_ALIVE_OPCOM_ASYM_FRIENDLY_DISABLE_PROXIMITY"; value = "proximity"; default = 1; };
                                    class capture   { name = "$STR_ALIVE_OPCOM_ASYM_FRIENDLY_DISABLE_CAPTURE";   value = "capture"; };
                                    class both      { name = "$STR_ALIVE_OPCOM_ASYM_FRIENDLY_DISABLE_BOTH";      value = "both"; };
                                };
                        };
                        class asym_escalationIntensity : Combo
                        {
                                property = "ALiVE_mil_opcom_asym_escalationIntensity";
                                displayName = "$STR_ALIVE_OPCOM_ASYM_ESCALATION_INTENSITY";
                                tooltip = "$STR_ALIVE_OPCOM_ASYM_ESCALATION_INTENSITY_COMMENT";
                                typeName = "STRING";
                                defaultValue = """off""";
                                class Values
                                {
                                    class off    { name = "$STR_ALIVE_OPCOM_ASYM_ESCALATION_INTENSITY_OFF";    value = "off"; default = 1; };
                                    class low    { name = "$STR_ALIVE_OPCOM_ASYM_ESCALATION_INTENSITY_LOW";    value = "low"; };
                                    class medium { name = "$STR_ALIVE_OPCOM_ASYM_ESCALATION_INTENSITY_MEDIUM"; value = "medium"; };
                                    class high   { name = "$STR_ALIVE_OPCOM_ASYM_ESCALATION_INTENSITY_HIGH";   value = "high"; };
                                };
                        };
                        class asym_excludeKinds : Edit
                        {
                                property = "ALiVE_mil_opcom_asym_excludeKinds";
                                displayName = "$STR_ALIVE_OPCOM_ASYM_EXCLUDE_KINDS";
                                tooltip = "$STR_ALIVE_OPCOM_ASYM_EXCLUDE_KINDS_COMMENT";
                                defaultValue = """Tank,Plane,Helicopter,Ship""";
                                typeName = "STRING";
                        };
                        class minAgents : Edit
                        {
                                property = "ALiVE_mil_opcom_minAgents";
                                displayName = "$STR_ALIVE_OPCOM_MINAGENTS";
                                tooltip = "$STR_ALIVE_OPCOM_MINAGENTS_COMMENT";
                                defaultValue = """2""";
                                typeName = "NUMBER";
                        };
                        class asymForceLimit : Edit
                        {
                                property = "ALiVE_mil_opcom_asymForceLimit";
                                displayName = "$STR_ALIVE_OPCOM_ASYM_FORCE_LIMIT";
                                tooltip = "$STR_ALIVE_OPCOM_ASYM_FORCE_LIMIT_COMMENT";
                                defaultValue = """-1""";
                                typeName = "NUMBER";
                        };
                        class recruitCycleMin : Edit
                        {
                                property = "ALiVE_mil_opcom_recruitCycleMin";
                                displayName = "$STR_ALIVE_OPCOM_RECRUIT_CYCLE_MIN";
                                tooltip = "$STR_ALIVE_OPCOM_RECRUIT_CYCLE_MIN_COMMENT";
                                defaultValue = """30""";
                                typeName = "NUMBER";
                        };
                        class recruitCycleMax : Edit
                        {
                                property = "ALiVE_mil_opcom_recruitCycleMax";
                                displayName = "$STR_ALIVE_OPCOM_RECRUIT_CYCLE_MAX";
                                tooltip = "$STR_ALIVE_OPCOM_RECRUIT_CYCLE_MAX_COMMENT";
                                defaultValue = """60""";
                                typeName = "NUMBER";
                        };
                        class recruitAttemptLimit : Edit
                        {
                                property = "ALiVE_mil_opcom_recruitAttemptLimit";
                                displayName = "$STR_ALIVE_OPCOM_RECRUIT_ATTEMPT_LIMIT";
                                tooltip = "$STR_ALIVE_OPCOM_RECRUIT_ATTEMPT_LIMIT_COMMENT";
                                defaultValue = """0""";
                                typeName = "NUMBER";
                        };
                        class recruitSuccessChance : Edit
                        {
                                property = "ALiVE_mil_opcom_recruitSuccessChance";
                                displayName = "$STR_ALIVE_OPCOM_RECRUIT_SUCCESS_CHANCE";
                                tooltip = "$STR_ALIVE_OPCOM_RECRUIT_SUCCESS_CHANCE_COMMENT";
                                defaultValue = """50""";
                                typeName = "NUMBER";
                        };
                        // ----  Task Overrides ----------------------------------------
                        class TSK_OVR : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_TSK_OVR"; displayName = "TASK OVERRIDES"; };
                        class taskProfileCountOverrides : Edit
                        {
                                property = "ALiVE_mil_opcom_taskProfileCountOverrides";
                                displayName = "$STR_ALIVE_OPCOM_TASK_PROFILE_COUNT_OVERRIDES";
                                tooltip = "$STR_ALIVE_OPCOM_TASK_PROFILE_COUNT_OVERRIDES_COMMENT";
                                defaultValue = """""";
                        };
                        class taskProfileTypeOverrides : Edit
                        {
                                property = "ALiVE_mil_opcom_taskProfileTypeOverrides";
                                displayName = "$STR_ALIVE_OPCOM_TASK_PROFILE_TYPE_OVERRIDES";
                                tooltip = "$STR_ALIVE_OPCOM_TASK_PROFILE_TYPE_OVERRIDES_COMMENT";
                                defaultValue = """""";
                        };

                        // ---- Hostility ------------------------------------------------------
                        class HDR_HOSTILITY : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_HDR_HOSTILITY"; displayName = "ASYMMETRIC HOSTILITY"; };
                        class hostilityPresenceMultiplier : Edit
                        {
                                property = "ALiVE_mil_opcom_hostilityPresenceMultiplier";
                                displayName = "$STR_ALIVE_OPCOM_HOSTILITY_PRESENCE_MULTIPLIER";
                                tooltip = "$STR_ALIVE_OPCOM_HOSTILITY_PRESENCE_MULTIPLIER_COMMENT";
                                defaultValue = """1""";
                                typeName = "NUMBER";
                        };
                        class hostilityInstallationMultiplier : Edit
                        {
                                property = "ALiVE_mil_opcom_hostilityInstallationMultiplier";
                                displayName = "$STR_ALIVE_OPCOM_HOSTILITY_INSTALLATION_MULTIPLIER";
                                tooltip = "$STR_ALIVE_OPCOM_HOSTILITY_INSTALLATION_MULTIPLIER_COMMENT";
                                defaultValue = """1""";
                                typeName = "NUMBER";
                        };
                        class hostilityInstallationInterval : Edit
                        {
                                property = "ALiVE_mil_opcom_hostilityInstallationInterval";
                                displayName = "$STR_ALIVE_OPCOM_HOSTILITY_INSTALLATION_INTERVAL";
                                tooltip = "$STR_ALIVE_OPCOM_HOSTILITY_INSTALLATION_INTERVAL_COMMENT";
                                defaultValue = """10""";
                                typeName = "NUMBER";
                        };

                        // ---- Civic State (Hearts & Minds) -----------------------------------
                        class HDR_CIVIC : ALiVE_ModuleSubTitle { property = "ALiVE_mil_opcom_HDR_CIVIC"; displayName = "CIVIC STATE (HEARTS & MINDS)"; };
                        class civicRecruitmentMultiplier : Edit
                        {
                                property = "ALiVE_mil_opcom_civicRecruitmentMultiplier";
                                displayName = "$STR_ALIVE_OPCOM_CIVIC_RECRUITMENT_MULTIPLIER";
                                tooltip = "$STR_ALIVE_OPCOM_CIVIC_RECRUITMENT_MULTIPLIER_COMMENT";
                                defaultValue = """1""";
                                typeName = "NUMBER";
                        };
                        class civicInstallationMultiplier : Edit
                        {
                                property = "ALiVE_mil_opcom_civicInstallationMultiplier";
                                displayName = "$STR_ALIVE_OPCOM_CIVIC_INSTALLATION_MULTIPLIER";
                                tooltip = "$STR_ALIVE_OPCOM_CIVIC_INSTALLATION_MULTIPLIER_COMMENT";
                                defaultValue = """1""";
                                typeName = "NUMBER";
                        };
                        class civicRetaliationChance : Edit
                        {
                                property = "ALiVE_mil_opcom_civicRetaliationChance";
                                displayName = "$STR_ALIVE_OPCOM_CIVIC_RETALIATION_CHANCE";
                                tooltip = "$STR_ALIVE_OPCOM_CIVIC_RETALIATION_CHANCE_COMMENT";
                                defaultValue = """0""";
                                typeName = "NUMBER";
                        };
                        class civicRetaliationIntensity : Edit
                        {
                                property = "ALiVE_mil_opcom_civicRetaliationIntensity";
                                displayName = "$STR_ALIVE_OPCOM_CIVIC_RETALIATION_INTENSITY";
                                tooltip = "$STR_ALIVE_OPCOM_CIVIC_RETALIATION_INTENSITY_COMMENT";
                                defaultValue = """1""";
                                typeName = "NUMBER";
                        };

                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"};
                    // Sync peers reflect the code paths that actually treat this
                    // OPCOM's synchronizedObjects as peers (either this module's
                    // own synchronizedObjects iteration in fnc_OPCOM.sqf, or a
                    // peer module's iteration that walks this OPCOM's synced list
                    // looking for itself). mil_intelligence dropped - no code
                    // path reads it. mil_placement_spe deliberately omitted - the
                    // module is designed as a fixed-position placement that
                    // should NOT be synced to OPCOM (runtime filter at
                    // fnc_OPCOM.sqf:437 / :545 is a known-bug leftover pending
                    // separate cleanup).
                    sync[] = {
                        "ALiVE_civ_placement",
                        "ALiVE_civ_placement_custom",
                        "ALiVE_mil_placement",
                        "ALiVE_mil_placement_custom",
                        "ALiVE_mil_cqb",
                        "ALiVE_mil_C2ISTAR",
                        "ALiVE_mil_ato",
                        "ALiVE_mil_ied",
                        "ALiVE_mil_logistics"
                    };
                    class ALiVE_civ_placement { description[] = {"$STR_ALIVE_CP_COMMENT","","$STR_ALIVE_CP_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_civ_placement_custom { description[] = {"$STR_ALIVE_CPC_COMMENT","","$STR_ALIVE_CPC_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_placement { description[] = {"$STR_ALIVE_MP_COMMENT","","$STR_ALIVE_MP_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_placement_custom { description[] = {"$STR_ALIVE_CMP_COMMENT","","$STR_ALIVE_CMP_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_cqb { description[] = {"$STR_ALIVE_CQB_COMMENT","","$STR_ALIVE_CQB_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_C2ISTAR { description[] = {"$STR_ALIVE_C2ISTAR_COMMENT","","$STR_ALIVE_C2ISTAR_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_ato { description[] = {"$STR_ALIVE_ATO_COMMENT","","$STR_ALIVE_ATO_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_ied { description[] = {"$STR_ALIVE_IED_COMMENT","","$STR_ALIVE_IED_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                    class ALiVE_mil_logistics { description[] = {"$STR_ALIVE_ML_COMMENT","","$STR_ALIVE_ML_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                };
        };

        class Item_Base_F;
        class Item_ItemALiVEPhoneOld: Item_Base_F
        {
            scope = 2; scopeCurator = 2;
            displayName = "Mobile Phone (Old)";
            author = "ALiVE Mod Team"; vehicleClass = "Items";
            class TransportItems { class ItemALiVEPhoneOld { name = "ItemALiVEPhoneOld"; count = 1; }; };
        };
        class Vest_Base_F;
        class Vest_V_ALiVE_Suicide_Belt: Vest_Base_F
        {
            scope = 2; scopeCurator = 2;
            displayName = "Suicide Belt";
            author = "ALiVE Mod Team"; vehicleClass = "ItemsVests";
            class TransportItems { class V_ALiVE_Suicide_Belt { name = "V_ALiVE_Suicide_Belt"; count = 1; }; };
        };
};

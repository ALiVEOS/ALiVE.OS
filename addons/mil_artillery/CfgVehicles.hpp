class CfgVehicles
{
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase
        {
            class Edit;
            class Combo;
            class ModuleDescription;
        };
    };
    class ModuleAliveBase : Module_F
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
        displayName = "$STR_ALIVE_MIL_ARTILLERY";
        function = "ALIVE_fnc_MilArtilleryInit";
        author = MODULE_AUTHOR;
        functionPriority = 190;
        isGlobal = 1;
        icon = "x\alive\addons\mil_artillery\icon_mil_artillery.paa";
        picture = "x\alive\addons\mil_artillery\icon_mil_artillery.paa";
        class Attributes : AttributesBase
        {
                // ---- General --------------------------------------------------------
                class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_artillery_HDR_GENERAL"; displayName = "GENERAL"; };
                class debug : Combo
                {
                        property = "ALiVE_mil_artillery_debug";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_DEBUG";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_DEBUG_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; };
                            class No { name = "No"; value = false; default = 1; };
                        };
                };
                // ---- Fire Missions --------------------------------------------------
                class HDR_FIRES : ALiVE_ModuleSubTitle { property = "ALiVE_mil_artillery_HDR_FIRES"; displayName = "FIRE MISSIONS"; };
                class intensity : Combo
                {
                        property = "ALiVE_mil_artillery_intensity";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_COMMENT";
                        defaultValue = """MEDIUM""";
                        class Values
                        {
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_MEDIUM"; value = "MEDIUM"; default = 1; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_HIGH"; value = "HIGH"; };
                            class EXTREME { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_EXTREME"; value = "EXTREME"; };
                        };
                };
                class generateTasks : Combo
                {
                        property = "ALiVE_mil_artillery_generateTasks";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_TASKS";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_TASKS_COMMENT";
                        defaultValue = """true""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; default = 1; };
                            class No { name = "No"; value = false; };
                        };
                };
                // ---- Fine Tuning ----------------------------------------------------
                // per-parameter overrides; "Use intensity preset" leaves the master
                // dial in charge of that parameter
                class HDR_TUNING : ALiVE_ModuleSubTitle { property = "ALiVE_mil_artillery_HDR_TUNING"; displayName = "FINE TUNING"; };
                // How many fire missions the whole side may run at once - the real
                // limit on how often shells land. Own dial because it has no
                // intensity-preset dimension. SCALE ties it to the battery count.
                class concurrencyLevel : Combo
                {
                        property = "ALiVE_mil_artillery_concurrencyLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_CONCURRENCY";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_CONCURRENCY_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class C1 { name = "1"; value = "1"; };
                            class C2 { name = "2"; value = "2"; };
                            class C3 { name = "3"; value = "3"; };
                            class C4 { name = "4"; value = "4"; };
                            class SCALE { name = "$STR_ALIVE_MIL_ARTILLERY_CONCURRENCY_SCALE"; value = "SCALE"; };
                        };
                };
                class cadenceLevel : Combo
                {
                        property = "ALiVE_mil_artillery_cadenceLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_CADENCE";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_CADENCE_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_CADENCE_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_CADENCE_MED"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_CADENCE_HIGH"; value = "HIGH"; };
                        };
                };
                class spreadLevel : Combo
                {
                        property = "ALiVE_mil_artillery_spreadLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_SPREAD";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_SPREAD_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_SPREAD_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_SPREAD_MED"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_SPREAD_HIGH"; value = "HIGH"; };
                        };
                };
                class roundsLevel : Combo
                {
                        property = "ALiVE_mil_artillery_roundsLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_ROUNDS";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_ROUNDS_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_ROUNDS_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_ROUNDS_MED"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_ROUNDS_HIGH"; value = "HIGH"; };
                        };
                };
                class ammoLevel : Combo
                {
                        property = "ALiVE_mil_artillery_ammoLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_AMMO";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_AMMO_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_AMMO_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_AMMO_MED"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_AMMO_HIGH"; value = "HIGH"; };
                            class VERYHIGH { name = "$STR_ALIVE_MIL_ARTILLERY_AMMO_VERYHIGH"; value = "VERYHIGH"; };
                            class EXTREME { name = "$STR_ALIVE_MIL_ARTILLERY_AMMO_EXTREME"; value = "EXTREME"; };
                            class INFINITE { name = "$STR_ALIVE_MIL_ARTILLERY_AMMO_INFINITE"; value = "INFINITE"; };
                        };
                };
                class selectivityLevel : Combo
                {
                        property = "ALiVE_mil_artillery_selectivityLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_SELECTIVITY";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_SELECTIVITY_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOOSE { name = "$STR_ALIVE_MIL_ARTILLERY_SEL_LOOSE"; value = "LOOSE"; };
                            class STANDARD { name = "$STR_ALIVE_MIL_ARTILLERY_SEL_STANDARD"; value = "STANDARD"; };
                            class STRICT { name = "$STR_ALIVE_MIL_ARTILLERY_SEL_STRICT"; value = "STRICT"; };
                        };
                };
                class counterBatteryLevel : Combo
                {
                        property = "ALiVE_mil_artillery_counterBatteryLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_CB";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_CB_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class OFF { name = "$STR_ALIVE_MIL_ARTILLERY_CB_OFF"; value = "OFF"; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_CB_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_CB_MED"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_CB_HIGH"; value = "HIGH"; };
                        };
                };
                // Safety override: fire even with friendlies in the impact area.
                // Default off; the tooltip flags the friendly-fire risk.
                class dangerClose : Combo
                {
                        property = "ALiVE_mil_artillery_dangerClose";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_DANGERCLOSE";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_DANGERCLOSE_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class No { name = "No"; value = false; default = 1; };
                            class Yes { name = "Yes"; value = true; };
                        };
                };
                // real-fire radius: how close a player must be (to target or
                // battery) for shells to actually spawn and be visible. Beyond
                // it the mission resolves on the ledger. Default 3 km.
                class visualRange : Combo
                {
                        property = "ALiVE_mil_artillery_visualRange";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_VISUALRANGE";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_VISUALRANGE_COMMENT";
                        defaultValue = """3000""";
                        class Values
                        {
                            class R1500 { name = "1.5 km"; value = "1500"; };
                            class R3000 { name = "3 km"; value = "3000"; default = 1; };
                            class R5000 { name = "5 km"; value = "5000"; };
                            class R8000 { name = "8 km"; value = "8000"; };
                            class R12000 { name = "12 km"; value = "12000"; };
                        };
                };
                // call-for-fire rate: above Normal, commanders fan fire missions
                // across several known contacts per scan (needs OPCOM + batteries).
                // Default Normal = today's request cadence, unchanged.
                class requestRateLevel : Combo
                {
                        property = "ALiVE_mil_artillery_requestRateLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_REQUESTRATE";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_REQUESTRATE_COMMENT";
                        defaultValue = """NORMAL""";
                        class Values
                        {
                            class Normal { name = "Normal (1 target)"; value = "NORMAL"; default = 1; };
                            class High { name = "High (3 targets)"; value = "HIGH"; };
                            class Surge { name = "Surge (6 targets)"; value = "SURGE"; };
                        };
                };
                class ModuleDescription : ModuleDescription {};
        };
        class ModuleDescription
        {
            description[] = {"$STR_ALIVE_MIL_ARTILLERY_DESCRIPTION"};
        };
    };
};

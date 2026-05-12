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
            displayName = "$STR_ALIVE_LOGISTICS";
            function = "ALIVE_fnc_emptyInit";
            functionPriority = 45;
            isGlobal = 2;
            icon = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
            picture = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
            author = MODULE_AUTHOR;
        };
        class ALiVE_SYS_LOGISTICSDISABLE : ModuleAliveBase
        {
            scope = 2;
            displayName = "$STR_ALIVE_LOGISTICSDISABLE";
            function = "ALIVE_fnc_logisticsDisable";
            functionPriority = 10;
            isGlobal = 2;
            icon = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
            picture = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
            author = MODULE_AUTHOR;
            class ModuleDescription
            {
                description[] = {"$STR_ALIVE_LOGISTICSDISABLE_COMMENT","","$STR_ALIVE_LOGISTICSDISABLE_USAGE"};
            };
            class Attributes : AttributesBase
            {
                // ── GENERAL ─────────────────────────────────────────────────
                class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_logistics_HDR_GENERAL"; displayName = "GENERAL"; };
                class DEBUG : Combo { property = "ALiVE_sys_logistics_DEBUG"; displayName = "$STR_ALIVE_LOGISTICS_DEBUG"; tooltip = "$STR_ALIVE_LOGISTICS_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class Yes { name = "Yes"; value = true; }; class No { name = "No"; value = false; default = 1; }; }; };
                // ── FEATURES ────────────────────────────────────────────────
                class HDR_FEATURES : ALiVE_ModuleSubTitle { property = "ALiVE_sys_logistics_HDR_FEATURES"; displayName = "FEATURES"; };
                class DISABLELOG : Combo { property = "ALiVE_sys_logistics_DISABLELOG"; displayName = "$STR_ALIVE_LOGISTICS_DISABLELOG"; tooltip = "$STR_ALIVE_LOGISTICS_DISABLELOG_COMMENT"; defaultValue = """false"""; class Values { class Yes { name = "Yes"; value = true; }; class No { name = "No"; value = false; default = 1; }; }; };
                class DISABLECARRY : Combo { property = "ALiVE_sys_logistics_DISABLECARRY"; displayName = "$STR_ALIVE_LOGISTICS_DISABLECARRY"; tooltip = "$STR_ALIVE_LOGISTICS_DISABLECARRY_COMMENT"; defaultValue = """false"""; class Values { class Yes { name = "Yes"; value = true; }; class No { name = "No"; value = false; default = 1; }; }; };
                class DISABLETOW : Combo { property = "ALiVE_sys_logistics_DISABLETOW"; displayName = "$STR_ALIVE_LOGISTICS_DISABLETOW"; tooltip = "$STR_ALIVE_LOGISTICS_DISABLETOW_COMMENT"; defaultValue = """false"""; class Values { class Yes { name = "Yes"; value = true; }; class No { name = "No"; value = false; default = 1; }; }; };
                class DISABLELIFT : Combo { property = "ALiVE_sys_logistics_DISABLELIFT"; displayName = "$STR_ALIVE_LOGISTICS_DISABLELIFT"; tooltip = "$STR_ALIVE_LOGISTICS_DISABLELIFT_COMMENT"; defaultValue = """false"""; class Values { class Yes { name = "Yes"; value = true; }; class No { name = "No"; value = false; default = 1; }; }; };
                class DISABLELOAD : Combo { property = "ALiVE_sys_logistics_DISABLELOAD"; displayName = "$STR_ALIVE_LOGISTICS_DISABLELOAD"; tooltip = "$STR_ALIVE_LOGISTICS_DISABLELOAD_COMMENT"; defaultValue = """false"""; class Values { class Yes { name = "Yes"; value = true; }; class No { name = "No"; value = false; default = 1; }; }; };
                class DISABLEPERSISTENCE : Combo { property = "ALiVE_sys_logistics_DISABLEPERSISTENCE"; displayName = "$STR_ALIVE_LOGISTICS_DISABLEPERSISTENCE"; tooltip = "$STR_ALIVE_LOGISTICS_DISABLEPERSISTENCE_COMMENT"; defaultValue = """false"""; class Values { class Yes { name = "Yes"; value = true; }; class No { name = "No"; value = false; default = 1; }; }; };
                // ── FILTERS ─────────────────────────────────────────────────
                class HDR_FILTERS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_logistics_HDR_FILTERS"; displayName = "FILTERS"; };
                class BLACKLIST : Edit { property = "ALiVE_sys_logistics_BLACKLIST"; displayName = "$STR_ALIVE_LOGISTICS_BLACKLIST"; tooltip = "$STR_ALIVE_LOGISTICS_BLACKLIST_COMMENT"; defaultValue = """"""; };
                class WHITELIST : Edit { property = "ALiVE_sys_logistics_WHITELIST"; displayName = "$STR_ALIVE_LOGISTICS_WHITELIST"; tooltip = "$STR_ALIVE_LOGISTICS_WHITELIST_COMMENT"; defaultValue = """"""; };
                class ModuleDescription : ModuleDescription {};
            };
        };
};

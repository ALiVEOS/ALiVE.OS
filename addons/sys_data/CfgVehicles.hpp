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
                scope = 2;
                displayName = "$STR_ALIVE_DATA";
                function = "ALIVE_fnc_dataInit";
                functionPriority = 30;
                isGlobal = 2;
                icon = "x\alive\addons\sys_data\icon_sys_data.paa";
                picture = "x\alive\addons\sys_data\icon_sys_data.paa";
                author = MODULE_AUTHOR;
                class ModuleDescription
                {
                        description = "This module allows you to persist mission data to an external database as well as enabling data storage for all other modules. This module is required for statistics too.";
                };
                class Attributes : AttributesBase
                {
                        class debug : Combo { property = "ALiVE_sys_data_debug"; displayName = "$STR_ALIVE_data_DEBUG"; tooltip = "$STR_ALIVE_data_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class source : Combo
                        {
                                property = "ALiVE_sys_data_source";
                                displayName = "$STR_ALIVE_data_SOURCE";
                                tooltip = "$STR_ALIVE_data_SOURCE_COMMENT";
                                defaultValue = """CouchDB""";
                                class Values
                                {
                                    class COUCHDB { name = "Cloud"; value = "CouchDB"; default = 1; };
                                    class pns { name = "Local"; value = "pns"; };
                                };
                        };
                        class saveDateTime : Combo { property = "ALiVE_sys_data_saveDateTime"; displayName = "$STR_ALIVE_data_SAVEDATETIME"; tooltip = "$STR_ALIVE_data_SAVEDATETIME_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class saveCompositions : Combo { property = "ALiVE_sys_data_saveCompositions"; displayName = "$STR_ALIVE_data_SAVECOMPOSITIONS"; tooltip = "$STR_ALIVE_data_SAVECOMPOSITIONS_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class killFeed : Combo
                        {
                                property = "ALiVE_sys_data_killFeed";
                                displayName = "$STR_ALIVE_data_killFeed";
                                tooltip = "$STR_ALIVE_data_killFeed_COMMENT";
                                defaultValue = """None""";
                                class Values
                                {
                                    class Group { name = "Group"; value = "group"; };
                                    class Yes { name = "Side"; value = "side"; };
                                    class None { name = "None"; value = "None"; default = 1; };
                                };
                        };
                        class disableStats : Combo { property = "ALiVE_sys_data_disableStats"; displayName = "$STR_ALIVE_data_disableStats"; tooltip = "$STR_ALIVE_data_disableStats_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class disableAAR : Combo { property = "ALiVE_sys_data_disableAAR"; displayName = "$STR_ALIVE_data_disableAAR"; tooltip = "$STR_ALIVE_data_disableAAR_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class disablePerf : Combo { property = "ALiVE_sys_data_disablePerf"; displayName = "$STR_ALIVE_data_disablePerf"; tooltip = "$STR_ALIVE_data_disablePerf_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                        class disablePerfMon : Combo { property = "ALiVE_sys_data_disablePerfMon"; displayName = "$STR_ALIVE_data_disablePerfMon"; tooltip = "$STR_ALIVE_data_disablePerfMon_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                        class customPerfMonCode : Edit
                        {
                                property = "ALiVE_sys_data_customPerfMonCode";
                                displayName = "$STR_ALIVE_data_customPerfMonCode";
                                tooltip = "$STR_ALIVE_data_customPerfMonCode_COMMENT";
                                defaultValue = """[['entities',150],['vehicles',300],['agents',450],['allDead',600],['objects',750],['triggers',900],['activeScripts',1050]]""";
                        };
                        class saveAllowlist : Edit
                        {
                                property = "ALiVE_sys_data_saveAllowlist";
                                displayName = "$STR_ALIVE_data_saveAllowlist";
                                tooltip = "$STR_ALIVE_data_saveAllowlist_COMMENT";
                                defaultValue = """""";
                        };
                        class ModuleDescription : ModuleDescription {};
                };
        };
};

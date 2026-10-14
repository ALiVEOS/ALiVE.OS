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
                displayName = "$STR_ALIVE_COMBATSUPPORT";
                function = "ALIVE_fnc_CombatSupportInit";
                author = MODULE_AUTHOR;
                functionPriority = 160;
                isGlobal = 2;
                icon = "x\alive\addons\sup_combatsupport\icon_sup_combatsupport.paa";
                picture = "x\alive\addons\sup_combatsupport\icon_sup_combatsupport.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_combatsupport_HDR_GENERAL"; displayName = "GENERAL"; };
                        class combatsupport_debug : Combo
                        {
                                property = "ALiVE_sup_combatsupport_combatsupport_debug";
                                displayName = "$STR_ALIVE_CS_DEBUG";
                                tooltip = "$STR_ALIVE_CS_DEBUG_COMMENT";
                                expression = "_this setVariable ['combatsupport_debug', _value];";
                                defaultValue = """0""";
                                class Values
                                {
                                    class off { name="No"; value = 0; default = 1; };
                                    class on { name="Yes"; value = 1; };
                                };
                        };

                        class HDR_ACCESS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_combatsupport_HDR_ACCESS"; displayName = "ACCESS"; };
                        class combatsupport_item
                        {
                                property     = "ALiVE_sup_combatsupport_combatsupport_item";
                                displayName  = "$STR_ALIVE_CS_ALLOW";
                                tooltip      = "$STR_ALIVE_CS_ALLOW_COMMENT";
                                control      = "ALiVE_CSAccessItemsChoice";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['combatsupport_item', _value];";
                                defaultValue = """LaserDesignators""";
                        };
                        class combatsupport_item_custom : Edit
                        {
                                property     = "ALiVE_sup_combatsupport_combatsupport_item_custom";
                                displayName  = "$STR_ALIVE_CS_CUSTOM_ITEMS";
                                tooltip      = "$STR_ALIVE_CS_CUSTOM_ITEMS_COMMENT";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['combatsupport_item_custom', _value];";
                                defaultValue = """""";
                        };
                        class combatsupport_singleoperator : Combo
                        {
                                property = "ALiVE_sup_combatsupport_combatsupport_singleoperator";
                                displayName = "$STR_ALIVE_CS_SINGLEOP";
                                tooltip = "$STR_ALIVE_CS_SINGLEOP_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class all { name="All players"; value = 0; };
                                    class first { name="First player only"; value = 1; default = 1; };
                                };
                        };

                        class HDR_RESPAWN : ALiVE_ModuleSubTitle { property = "ALiVE_sup_combatsupport_HDR_RESPAWN"; displayName = "ASSET REPLACEMENT"; };
                        // a typed number of seconds since #1079; the old drop-down's 60/600/1200/1800 load into it as they are
                        class combatsupport_respawn : Edit
                        {
                                property = "ALiVE_sup_combatsupport_combatsupport_respawn";
                                displayName = "$STR_ALIVE_CS_RESPAWN";
                                tooltip = "$STR_ALIVE_CS_RESPAWN_COMMENT";
                                defaultValue = """600""";
                        };
                        class combatsupport_casrespawnlimit : Edit { property = "ALiVE_sup_combatsupport_combatsupport_casrespawnlimit"; displayName = "$STR_ALIVE_CAS_LIMIT"; tooltip = "$STR_ALIVE_CAS_LIMIT_COMMENT"; defaultValue = """3"""; };
                        class combatsupport_transportrespawnlimit : Edit { property = "ALiVE_sup_combatsupport_combatsupport_transportrespawnlimit"; displayName = "$STR_ALIVE_TRANS_LIMIT"; tooltip = "$STR_ALIVE_TRANS_LIMIT_COMMENT"; defaultValue = """3"""; };
                        class combatsupport_groundrespawnlimit : Edit { property = "ALiVE_sup_combatsupport_combatsupport_groundrespawnlimit"; displayName = "$STR_ALIVE_GROUND_LIMIT"; tooltip = "$STR_ALIVE_GROUND_LIMIT_COMMENT"; defaultValue = """3"""; };
                        class combatsupport_artyrespawnlimit : Edit { property = "ALiVE_sup_combatsupport_combatsupport_artyrespawnlimit"; displayName = "$STR_ALIVE_ARTY_LIMIT"; tooltip = "$STR_ALIVE_ARTY_LIMIT_COMMENT"; defaultValue = """3"""; };

                        class HDR_MISC : ALiVE_ModuleSubTitle { property = "ALiVE_sup_combatsupport_HDR_MISC"; displayName = "MISC"; };
                        class combatsupport_audio : Combo
                        {
                                property = "ALiVE_sup_combatsupport_combatsupport_audio";
                                displayName = "$STR_ALIVE_CS_AUDIO";
                                tooltip = "$STR_ALIVE_CS_AUDIO_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class true { name="Yes"; value = 1; default = 1; };
                                    class false { name="No"; value = 0; };
                                };
                        };
                        // an order's destination (and a road patrol's two ends) stay on the map while it runs
                        class combatsupport_ordermarkers : Combo
                        {
                                property = "ALiVE_sup_combatsupport_combatsupport_ordermarkers";
                                displayName = "$STR_ALIVE_CS_ORDERMARKERS";
                                tooltip = "$STR_ALIVE_CS_ORDERMARKERS_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class true { name="Yes"; value = 1; default = 1; };
                                    class false { name="No"; value = 0; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_CS_COMMENT","","$STR_ALIVE_CS_USAGE"};
                    sync[] = {"ALiVE_SUP_TRANSPORT","ALiVE_SUP_GROUND","ALiVE_SUP_CAS","ALiVE_SUP_ARTILLERY"};
                    class ALiVE_SUP_TRANSPORT { description[] = {"$STR_ALIVE_TRANSPORT_COMMENT","","$STR_ALIVE_TRANSPORT_USAGE"}; position=1; direction=1; optional=1; duplicate=1; };
                    class ALiVE_SUP_GROUND { description[] = {"$STR_ALIVE_GROUND_COMMENT","","$STR_ALIVE_GROUND_USAGE"}; position=1; direction=1; optional=1; duplicate=1; };
                    class ALiVE_SUP_CAS { description[] = {"$STR_ALIVE_CAS_COMMENT","","$STR_ALIVE_CAS_USAGE"}; position=1; direction=1; optional=1; duplicate=1; };
                    class ALiVE_SUP_ARTILLERY { description[] = {"$STR_ALIVE_ARTILLERY_COMMENT","","$STR_ALIVE_ARTILLERY_USAGE"}; position=1; direction=1; optional=1; duplicate=1; };
                };
        };
};

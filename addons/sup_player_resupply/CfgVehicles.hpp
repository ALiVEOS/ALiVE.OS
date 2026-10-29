class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Default; class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; };
        class ModuleDescription;
    };
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_PR";
                function = "ALIVE_fnc_PRInit";
                author = MODULE_AUTHOR;
                functionPriority = 170;
                isGlobal = 1;
                icon = "x\alive\addons\sup_player_resupply\icon_sup_PR.paa";
                picture = "x\alive\addons\sup_player_resupply\icon_sup_PR.paa";
                class Attributes : AttributesBase
                {
                    // ── GENERAL ──────────────────────────────────────────────
                    class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_player_resupply_HDR_GENERAL"; displayName = "GENERAL"; };
                    class pr_debug : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_debug";
                            displayName = "$STR_ALIVE_PR_DEBUG";
                            tooltip = "$STR_ALIVE_PR_DEBUG_COMMENT";
                            expression = "_this setVariable ['pr_debug', _value];";
                            defaultValue = """0""";
                            class Values
                            {
                                class off { name="No"; value = 0; default = 1; };
                                class on { name="Yes"; value = 1; };
                            };
                    };
                    class pr_item
                    {
                            property     = "ALiVE_sup_player_resupply_pr_item";
                            displayName  = "$STR_ALIVE_PR_ALLOW";
                            tooltip      = "$STR_ALIVE_PR_ALLOW_COMMENT";
                            control      = "ALiVE_PRAccessItemsChoice";
                            typeName     = "STRING";
                            expression   = "_this setVariable ['pr_item', _value];";
                            defaultValue = """LaserDesignators""";
                    };
                    class pr_item_custom : Edit
                    {
                            property     = "ALiVE_sup_player_resupply_pr_item_custom";
                            displayName  = "$STR_ALIVE_PR_CUSTOM_ITEMS";
                            tooltip      = "$STR_ALIVE_PR_CUSTOM_ITEMS_COMMENT";
                            typeName     = "STRING";
                            expression   = "_this setVariable ['pr_item_custom', _value];";
                            defaultValue = """""";
                    };
                    class pr_audio : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_audio";
                            displayName = "$STR_ALIVE_PR_AUDIO";
                            tooltip = "$STR_ALIVE_PR_AUDIO_COMMENT";
                            defaultValue = """1""";
                            class Values
                            {
                                class true { name="Yes"; value = 1; default = 1; };
                                class false { name="No"; value = 0; };
                            };
                    };
                    // ── FACTION RESTRICTIONS ──────────────────────────────────
                    class HDR_FACTIONS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_player_resupply_HDR_FACTIONS"; displayName = "FACTION RESTRICTIONS"; };
                    class pr_restrictionType : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_restrictionType";
                            displayName = "$STR_ALIVE_PR_RESTRICTION_TYPE";
                            tooltip = "$STR_ALIVE_PR_RESTRICTION_TYPE_COMMENT";
                            defaultValue = """SIDE""";
                            class Values
                            {
                                class Side { name = "$STR_ALIVE_PR_RESTRICTION_TYPE_SIDE"; value = "SIDE"; default = 1; };
                                class Faction { name = "$STR_ALIVE_PR_RESTRICTION_TYPE_FACTION"; value = "FACTION"; };
                            };
                    };
                    class pr_factionWhitelist
                    {
                        property     = "ALiVE_sup_player_resupply_pr_factionWhitelist";
                        displayName  = "$STR_ALIVE_PR_FACTION_WHITELIST";
                        tooltip      = "$STR_ALIVE_PR_FACTION_WHITELIST_COMMENT";
                        // Per-consumer variant of FactionChoiceMulti_Military.
                        // Visible Title "Faction Whitelist:" plus tooltip
                        // $STR_ALIVE_PR_FACTION_WHITELIST_COMMENT set by
                        // the LOAD handler on idc 101.
                        control      = "ALiVE_FactionChoiceMulti_Military_FactionWhitelist";
                        typeName     = "STRING";
                        expression   = "_this setVariable ['pr_factionWhitelist', _value, true];";
                        defaultValue = """[]""";
                    };
                    class pr_factionWhitelistManual : Edit { property = "ALiVE_sup_player_resupply_pr_factionWhitelistManual"; displayName = "$STR_ALIVE_PR_FACTION_WHITELIST_MANUAL"; tooltip = "$STR_ALIVE_PR_FACTION_WHITELIST_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class filterFriendlyFactions : Combo
                    {
                            property = "ALiVE_sup_player_resupply_filterFriendlyFactions";
                            displayName = "$STR_ALIVE_PR_FILTER_FRIENDLY_FACTIONS";
                            tooltip = "$STR_ALIVE_PR_FILTER_FRIENDLY_FACTIONS_COMMENT";
                            defaultValue = """true""";
                            class Values
                            {
                                class Yes { name = "Yes"; value = "true"; default = 1; };
                                class No  { name = "No";  value = "false"; };
                            };
                    };
                    // ── DELIVERY METHODS ──────────────────────────────────────
                    class HDR_DELIVERY : ALiVE_ModuleSubTitle { property = "ALiVE_sup_player_resupply_HDR_DELIVERY"; displayName = "DELIVERY METHODS"; };
                    class pr_restrictionDeliveryAirDrop : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_restrictionDeliveryAirDrop";
                            displayName = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_AIRDROP";
                            tooltip = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_AIRDROP_COMMENT";
                            defaultValue = """true""";
                            class Values
                            {
                                class Yes { name = "Yes"; value = true; default = 1; };
                                class No { name = "No"; value = false; };
                            };
                    };
                    class pr_restrictionDeliveryInsert : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_restrictionDeliveryInsert";
                            displayName = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_INSERT";
                            tooltip = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_INSERT_COMMENT";
                            defaultValue = """true""";
                            class Values
                            {
                                class Yes { name = "Yes"; value = true; default = 1; };
                                class No { name = "No"; value = false; };
                            };
                    };
                    class pr_restrictionDeliveryConvoy : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_restrictionDeliveryConvoy";
                            displayName = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_CONVOY";
                            tooltip = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_CONVOY_COMMENT";
                            defaultValue = """true""";
                            class Values
                            {
                                class Yes { name = "Yes"; value = true; default = 1; };
                                class No { name = "No"; value = false; };
                            };
                    };
                    // ── TABLET CATALOGUE ──────────────────────────────────────
                    // The catalogue page's link, then the three lists it fills: Only These and Never keep
                    // their old property names so every saved mission keeps its lists.
                    class HDR_FILTERS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_player_resupply_HDR_FILTERS"; displayName = "TABLET CATALOGUE"; };
                    class pr_catalogue : Default { property = "ALiVE_sup_player_resupply_pr_catalogue"; displayName = "$STR_ALIVE_PR_CATALOGUE"; tooltip = "$STR_ALIVE_PR_CATALOGUE_COMMENT"; control = "ALiVE_PRCatalogueLink"; typeName = "STRING"; defaultValue = "''"; };
                    class pr_list : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_list";
                            displayName = "$STR_ALIVE_PR_LIST";
                            tooltip = "$STR_ALIVE_PR_LIST_COMMENT";
                            defaultValue = """""";
                            typeName = "STRING";
                            class Values
                            {
                                class NotSet { name = "$STR_ALIVE_LISTS_NOTSET"; value = ""; default = 1; };
                                class All { name = "$STR_ALIVE_LISTS_ALL"; value = "ALL"; };
                                class Supplies { name = "$STR_ALIVE_LISTS_SUPPLIES"; value = "SUPPLIES"; };
                                class Light { name = "$STR_ALIVE_LISTS_LIGHT"; value = "LIGHT"; };
                                class StaticsSupplies { name = "$STR_ALIVE_LISTS_STATICS_SUPPLIES"; value = "STATICS_SUPPLIES"; };
                                class Troops { name = "$STR_ALIVE_LISTS_TROOPS"; value = "TROOPS"; };
                                class Infantry { name = "$STR_ALIVE_LISTS_INFANTRY"; value = "INFANTRY"; };
                                class Custom { name = "$STR_ALIVE_LISTS_CUSTOM"; value = "CUSTOM"; };
                            };
                    };
                    class pr_list_name : Edit { property = "ALiVE_sup_player_resupply_pr_list_name"; displayName = "$STR_ALIVE_PR_LIST_NAME"; tooltip = "$STR_ALIVE_PR_LIST_NAME_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class pr_restrictionWhitelist : Edit { property = "ALiVE_sup_player_resupply_pr_restrictionWhitelist"; displayName = "$STR_ALIVE_PR_RESTRICTION_WHITELIST"; tooltip = "$STR_ALIVE_PR_RESTRICTION_WHITELIST_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class pr_restrictionBlacklist : Edit { property = "ALiVE_sup_player_resupply_pr_restrictionBlacklist"; displayName = "$STR_ALIVE_PR_RESTRICTION_BLACKLIST"; tooltip = "$STR_ALIVE_PR_RESTRICTION_BLACKLIST_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class pr_restrictionAlso : Edit { property = "ALiVE_sup_player_resupply_pr_restrictionAlso"; displayName = "$STR_ALIVE_PR_RESTRICTION_ALSO"; tooltip = "$STR_ALIVE_PR_RESTRICTION_ALSO_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class ModuleDescription : ModuleDescription {};
                };
        };
        // Logistics Hub (#1091): the objects synced to it are hubs, where a player collects a
        // tablet requisition straight away instead of having it delivered
        class ALiVE_sup_logistics_hub : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_HUB";
                function = "ALIVE_fnc_hubInit";
                author = MODULE_AUTHOR;
                // after Player Combat Logistics (170); it waits on Military Logistics itself
                functionPriority = 171;
                isGlobal = 0;
                icon = "x\alive\addons\sup_player_resupply\icon_sup_logistics_hub.paa";
                picture = "x\alive\addons\sup_player_resupply\icon_sup_logistics_hub.paa";
                class Attributes : AttributesBase
                {
                    class HDR_HUB : ALiVE_ModuleSubTitle { property = "ALiVE_sup_logistics_hub_HDR_HUB"; displayName = "LOGISTICS HUB"; };
                    class hub_side : Combo
                    {
                            property = "ALiVE_sup_logistics_hub_hub_side";
                            displayName = "$STR_ALIVE_HUB_SIDE";
                            tooltip = "$STR_ALIVE_HUB_SIDE_COMMENT";
                            defaultValue = """WEST""";
                            typeName = "STRING";
                            class Values
                            {
                                    class WEST { name = "BLUFOR"; value = "WEST"; };
                                    class EAST { name = "OPFOR"; value = "EAST"; };
                                    class GUER { name = "Independent"; value = "GUER"; };
                            };
                    };
                    class hub_radius : Edit { property = "ALiVE_sup_logistics_hub_hub_radius"; displayName = "$STR_ALIVE_HUB_RADIUS"; tooltip = "$STR_ALIVE_HUB_RADIUS_COMMENT"; typeName = "STRING"; defaultValue = """30"""; };

                    class HDR_COLLECT : ALiVE_ModuleSubTitle { property = "ALiVE_sup_logistics_hub_HDR_COLLECT"; displayName = "WHO CAN COLLECT"; };
                    class hub_collect_who { property = "ALiVE_sup_logistics_hub_hub_collect_who"; displayName = "$STR_ALIVE_HUB_COLLECT_WHO"; tooltip = "$STR_ALIVE_HUB_COLLECT_WHO_COMMENT"; control = "ALiVE_HubCollectChoice"; typeName = "STRING"; expression = "_this setVariable ['hub_collect_who', _value];"; defaultValue = """SIDE"""; };
                    class hub_collect_list : Edit { property = "ALiVE_sup_logistics_hub_hub_collect_list"; displayName = "$STR_ALIVE_HUB_COLLECT_LIST"; tooltip = "$STR_ALIVE_HUB_COLLECT_LIST_COMMENT"; typeName = "STRING"; defaultValue = """"""; };

                    // the same catalogue page and the same three lists as the tablet's own, for what is
                    // collected at these hubs
                    class HDR_CATALOGUE : ALiVE_ModuleSubTitle { property = "ALiVE_sup_logistics_hub_HDR_CATALOGUE"; displayName = "HUB CATALOGUE"; };
                    class hub_catalogue : Default { property = "ALiVE_sup_logistics_hub_hub_catalogue"; displayName = "$STR_ALIVE_HUB_LIST"; tooltip = "$STR_ALIVE_HUB_LIST_COMMENT"; control = "ALiVE_HubListLink"; typeName = "STRING"; defaultValue = "''"; };
                    class hub_only : Edit { property = "ALiVE_sup_logistics_hub_hub_only"; displayName = "$STR_ALIVE_HUB_ONLY"; tooltip = "$STR_ALIVE_HUB_ONLY_COMMENT"; typeName = "STRING"; defaultValue = """"""; };
                    class hub_never : Edit { property = "ALiVE_sup_logistics_hub_hub_never"; displayName = "$STR_ALIVE_HUB_NEVER"; tooltip = "$STR_ALIVE_HUB_NEVER_COMMENT"; typeName = "STRING"; defaultValue = """"""; };
                    class hub_also : Edit { property = "ALiVE_sup_logistics_hub_hub_also"; displayName = "$STR_ALIVE_HUB_ALSO"; tooltip = "$STR_ALIVE_HUB_ALSO_COMMENT"; typeName = "STRING"; defaultValue = """"""; };

                    // losing a hub: destroyed, or dismantled by the enemy or its own side, and the repair
                    class HDR_LOSING : ALiVE_ModuleSubTitle { property = "ALiVE_sup_logistics_hub_HDR_LOSING"; displayName = "LOSING A HUB"; };
                    class hub_dismantle : Combo
                    {
                            property = "ALiVE_sup_logistics_hub_hub_dismantle";
                            displayName = "$STR_ALIVE_HUB_DISMANTLE";
                            tooltip = "$STR_ALIVE_HUB_DISMANTLE_COMMENT";
                            defaultValue = """true""";
                            typeName = "STRING";
                            class Values
                            {
                                    class Yes { name = "Yes"; value = "true"; };
                                    class No { name = "No"; value = "false"; };
                            };
                    };
                    class hub_dismantle_time : Edit { property = "ALiVE_sup_logistics_hub_hub_dismantle_time"; displayName = "$STR_ALIVE_HUB_DISMANTLE_TIME"; tooltip = "$STR_ALIVE_HUB_DISMANTLE_TIME_COMMENT"; typeName = "STRING"; defaultValue = """15"""; };
                    class hub_repair_time : Edit { property = "ALiVE_sup_logistics_hub_hub_repair_time"; displayName = "$STR_ALIVE_HUB_REPAIR_TIME"; tooltip = "$STR_ALIVE_HUB_REPAIR_TIME_COMMENT"; typeName = "STRING"; defaultValue = """0"""; };

                    class HDR_DISMANTLE : ALiVE_ModuleSubTitle { property = "ALiVE_sup_logistics_hub_HDR_DISMANTLE"; displayName = "WHO CAN DISMANTLE"; };
                    class hub_dismantle_who { property = "ALiVE_sup_logistics_hub_hub_dismantle_who"; displayName = "$STR_ALIVE_HUB_DISMANTLE_WHO"; tooltip = "$STR_ALIVE_HUB_DISMANTLE_WHO_COMMENT"; control = "ALiVE_HubDismantleChoice"; typeName = "STRING"; expression = "_this setVariable ['hub_dismantle_who', _value];"; defaultValue = """"""; };
                    class hub_dismantle_list : Edit { property = "ALiVE_sup_logistics_hub_hub_dismantle_list"; displayName = "$STR_ALIVE_HUB_DISMANTLE_LIST"; tooltip = "$STR_ALIVE_HUB_DISMANTLE_LIST_COMMENT"; typeName = "STRING"; defaultValue = """"""; };

                    class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_logistics_hub_HDR_GENERAL"; displayName = "GENERAL"; };
                    class hub_debug : Combo
                    {
                            property = "ALiVE_sup_logistics_hub_hub_debug";
                            displayName = "$STR_ALIVE_HUB_DEBUG";
                            tooltip = "$STR_ALIVE_HUB_DEBUG_COMMENT";
                            defaultValue = """false""";
                            typeName = "STRING";
                            class Values
                            {
                                    class No { name = "No"; value = "false"; };
                                    class Yes { name = "Yes"; value = "true"; };
                            };
                    };
                    class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_HUB_COMMENT"};
                        sync[] = {"AnyStaticObject", "ALiVE_SUP_PLAYER_RESUPPLY", "ALiVE_mil_logistics"};
                };
        };
};

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
                    class pr_item : Edit { property = "ALiVE_sup_player_resupply_pr_item"; displayName = "$STR_ALIVE_PR_ALLOW"; tooltip = "$STR_ALIVE_PR_ALLOW_COMMENT"; defaultValue = """LaserDesignator"""; typeName = "STRING"; };
                    class pr_audio : Combo
                    {
                            property = "ALiVE_sup_player_resupply_pr_audio";
                            displayName = "$STR_ALIVE_CS_AUDIO";
                            tooltip = "$STR_ALIVE_CS_AUDIO_COMMENT";
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
                        control      = "ALiVE_FactionChoiceMulti_Military";
                        typeName     = "STRING";
                        expression   = "_this setVariable ['pr_factionWhitelist', _value];";
                        defaultValue = """[]""";
                    };
                    class pr_factionWhitelistManual : Edit { property = "ALiVE_sup_player_resupply_pr_factionWhitelistManual"; displayName = "$STR_ALIVE_PR_FACTION_WHITELIST_MANUAL"; tooltip = "$STR_ALIVE_PR_FACTION_WHITELIST_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class SPACER_FACTIONS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_player_resupply_SPACER_FACTIONS"; displayName = " "; };
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
                    // ── ITEM FILTERS ──────────────────────────────────────────
                    class HDR_FILTERS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_player_resupply_HDR_FILTERS"; displayName = "ITEM FILTERS"; };
                    class pr_restrictionBlacklist : Edit { property = "ALiVE_sup_player_resupply_pr_restrictionBlacklist"; displayName = "$STR_ALIVE_PR_RESTRICTION_BLACKLIST"; tooltip = "$STR_ALIVE_PR_RESTRICTION_BLACKLIST_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class pr_restrictionWhitelist : Edit { property = "ALiVE_sup_player_resupply_pr_restrictionWhitelist"; displayName = "$STR_ALIVE_PR_RESTRICTION_WHITELIST"; tooltip = "$STR_ALIVE_PR_RESTRICTION_WHITELIST_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
                    class ModuleDescription : ModuleDescription {};
                };
        };
};

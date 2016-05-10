class CfgVehicles {
        class ModuleAliveBase;
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
                class Arguments
                {
                    class pr_item
                    {
                            displayName = "$STR_ALIVE_PR_ALLOW";
                            description = "$STR_ALIVE_PR_ALLOW_COMMENT";
                            defaultValue = "LaserDesignator";
                    };
                    class pr_restrictionType
                    {
                            displayName = "$STR_ALIVE_PR_RESTRICTION_TYPE";
                            description = "$STR_ALIVE_PR_RESTRICTION_TYPE_COMMENT";
                            class Values
                            {
                                    class Side
                                    {
                                            name = "$STR_ALIVE_PR_RESTRICTION_TYPE_SIDE";
                                            value = "SIDE";
                                            default = 1;
                                    };
                                    class Faction
                                    {
                                            name = "$STR_ALIVE_PR_RESTRICTION_TYPE_FACTION";
                                            value = "FACTION";
                                    };
                            };
                    };
                    class pr_restrictionDeliveryAirDrop
                    {
                            displayName = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_AIRDROP";
                            description = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_AIRDROP_COMMENT";
                            class Values
                            {
                                    class Yes
                                    {
                                            name = "Yes";
                                            value = true;
                                            default = 1;
                                            typeName = "BOOL";
                                    };
                                    class No
                                    {
                                            name = "No";
                                            value = false;
                                            typeName = "BOOL";
                                    };
                            };
                    };
                    class pr_restrictionDeliveryInsert
                    {
                            displayName = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_INSERT";
                            description = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_INSERT_COMMENT";
                            class Values
                            {
                                    class Yes
                                    {
                                            name = "Yes";
                                            value = true;
                                            default = 1;
                                            typeName = "BOOL";
                                    };
                                    class No
                                    {
                                            name = "No";
                                            value = false;
                                            typeName = "BOOL";
                                    };
                            };
                    };
                    class pr_restrictionDeliveryConvoy
                    {
                            displayName = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_CONVOY";
                            description = "$STR_ALIVE_PR_RESTRICTION_DELIVERY_CONVOY_COMMENT";
                            class Values
                            {
                                    class Yes
                                    {
                                            name = "Yes";
                                            value = true;
                                            default = 1;
                                            typeName = "BOOL";
                                    };
                                    class No
                                    {
                                            name = "No";
                                            value = false;
                                            typeName = "BOOL";
                                    };
                            };
                    };
                    
                    class pr_restrictionBlacklist
                    {
                                displayName = "$STR_ALIVE_PR_RESTRICTION_BLACKLIST";
                                description = "$STR_ALIVE_PR_RESTRICTION_BLACKLIST_COMMENT";
                                typeName = "STRING";
                                defaultValue = "";
                    };
                    
                    class pr_restrictionWhitelist
                    {
                                displayName = "$STR_ALIVE_PR_RESTRICTION_WHITELIST";
                                description = "$STR_ALIVE_PR_RESTRICTION_WHITELIST_COMMENT";
                                typeName = "STRING";
                                defaultValue = "";
                    };
                };

        };

};
